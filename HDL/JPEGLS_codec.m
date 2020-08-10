 fid = fopen('/home/u1249940/Downloads/Ztest.mat','r');
 pixels = int8(fread(fid));
 fclose(fid);
 s = size(pixels);
 frames = int8(zeros(70,120,20));
 column_index = 1;
 row_index = 1;
 depth_index = 1;
 
Current_Row = [];
Converted_Row = [];
Converted_Data = zeros(3110,135);
for i = 1 : 10
    for j = 1 : 311
        Current_Row = Z(j,:, i);
        Converted_Row = typecast(Z(j,:, i), 'uint8');
        Converted_Data(j + ((i-1) * 311) ,:) = Converted_Row;
    end
end
 

Compress_Accum = [];
Recover_Accum = [];
Frame_Size = [];
Current_Frame = [];
Compressed_Size = [];
[Compress, Recover, Size, Compressed_Bits] = JPEG_LS_codec(Converted_Data, 1);
Compress_Accum(:,:,i) = Compress;
Recover_Accum(:,:,i) = Recover;
Frame_Size(i) = Size;
Compressed_Size(1,i) = Compressed_Bits;


function [Compress Recover, Frame_Size compressed_bits] = JPEG_LS_codec(image, useRunMode) % only regular mode if useRunMode == 0
% Converted from C code, which can be downloaded from following URL.
%       C code URL: http://www.stat.columbia.edu/~jakulin/jpeg-ls/mirror.htm (jpeg_ls_v2.2)
% Caution :
%1. This program is JPEG-LS Lossless Encoder/Decoder.
%2. This is without JPEG-LS header data. just compressing image data. 
%3. Compress 8-bit image, only one component(such as each R, G, B, or gray plate), encoding line by line
%4. Each byte of outstream is stored at "buff" array
% Ex]
% >> [Compress Recover] = JPEGLS_codec(IM, 1);  % 1: use Run Mode.  0: only Regular Mode
global CREGIONS; global CONTEXTS1; global CONTEXTS; global EOR_CONTEXTS; global TOT_CONTEXTS; global EOR_0;
global EOLINE; global NOEOLINE; global MAX_C; global MIN_C; global MELCSTATES;
global vLUT; global classmap; global zeroLUT;
global T1; global T2; global T3; global J; global C; global B; global N; global A; 
global BITBUFSIZE; global bits; global Reg; global fp; global buff; global lutmax; global bpp; global qbpp;
global Alpha; global ceil_half_Alpha; global Reset; global limit; global Cols; global limit_reduce;
global near; global melcstate; global melclen; global melcorder;
global decbuff; global decfp;                   % variables for decoding

%quantization regions; default 8-qbpp
global T1;
global T2;
global T3;

%quantization regions; default 8-qbpp
T1 = 3; T2 = 7; T3 = 21;

%For frame size of each encoding
global compressed_bits;
%

compressed_bits = 0;

global num_of_bits;
num_of_bits = [];

SIZE = size(image);  % assign height and width
height = SIZE(1); 
width = SIZE(2);
if length(SIZE) > 2  % if color image, 
    image = image(:,:,Color);  % choose Red component. Modify as you want.
end
ImageSize = height*width; Cols = width;
image = double(image);

% -4, -3, -2, -1, 0, 1, 2, 3, 4
CREGIONS = 9;
% We will compute 3 gradients which can take on any one of the above values
CONTEXTS1 = CREGIONS*CREGIONS*CREGIONS;
% Negative contexts are equal to positive contexts
CONTEXTS = (CONTEXTS1+1)/2; 
EOR_CONTEXTS = 2; 
TOT_CONTEXTS = CONTEXTS + EOR_CONTEXTS; 
EOR_0 = CONTEXTS+1; % N[EOR_0]
EOLINE = 1; 
NOEOLINE = 0; 

% C is the bias prediction value, used to "re-center" the TSGD
MAX_C = 127; 
MIN_C = -128; 
MELCSTATES = 32;

%This is the max value our image alphabet can take
Alpha0 = 255; % maxval
Alpha = Alpha0+1; 
ceil_half_Alpha =  ceil(Alpha/2);  % Alpha : range

%Periodicly reset the Adaptive coding parameters
Reset = 64; 

%Gradient values
lutmax = 256; 
% # of bits used (8 in our case)
bpp = max(2, ceil(log2(Alpha))); 
qbpp = bpp; % bit depth

%Used for context lookup
vLUT = zeros(3, 2 * lutmax); 
classmap = zeros(1, CONTEXTS1); 
zeroLUT = zeros(1, 256);

% These are the values that decide which quantization area we are in
% So the quantization regions are {0}, {1,2}, {3,4,5,6}, {7..20}, {21..}
T1 = 3; T2 = 7; T3 = 21; % quantization threshold

near = 0; % 0: lossless. but not used in this program
limit = 4*bpp - qbpp - 1;  % length limit

%C, B, N, Nn, A : adaptive correction parameters
C = zeros(1,TOT_CONTEXTS); % (cumulative) prediction correction values, added to predicted value
B = zeros(1,TOT_CONTEXTS); % bias correction
N = ones(1,TOT_CONTEXTS); % Golomb code k is computed from N(Q) and A(Q), Number of occurances of each context
A_init = max(2,floor((Alpha+2^5)/2^6));% Initialize A, = 4, A is predicted sum of residuals
A = ones(1,TOT_CONTEXTS) * A_init; % 366 and 367 is for run mode. % A(366) if a~=b, A(367) if a==b
% Mapping M(error)
J = [0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,5,5,6,6,7,7,8,9,10,11,12,13,14,15];

pscanline = zeros(1, width+1);    % previous line, last one element is for Rd of nextline (Rd is NE sample)
BITBUFSIZE = 32; 
bits = BITBUFSIZE; 
Reg = uint32(0); 
fp = 1;
buff = zeros(1, height*width);

%Used for run mode
melcstate = 1; 
melclen = J(melcstate); 
melcorder = bitsll(1, melclen); % melcorder = 2^melclen
prepareLUTs();  % initializing vLUT and classmap
% end of initializing

psl_0 = 0; % 'Rc' of first pixel

for row=1:height  % encoding process
	['Encoding row : ' num2str(row) ]   % nevigation
    cscanline = image(row,:); % read line by line
    sl_0 = pscanline(1); % Ra of current line
    psl=pscanline; % previous line
    sl=cscanline;  % current line
    lossless_doscanline(psl, sl, psl_0, sl_0, useRunMode);  % compressing process
    pscanline = [cscanline cscanline(end)]; % move current line ot previous line. 
    psl_0 = sl_0; 
end
while (bits < 32)  % ending process of encoding. 
	temp = bitsrl(Reg, 24);  % MSB 8 bits
    buff(1, fp) = temp;
    fp = fp + 1;
	if ( temp == 255 )
		bits = bits + 7;
		Reg = bitsll(Reg, 7);
        Reg = bitand(Reg, bitcmp(uint32(bitsll(1, BITBUFSIZE-1))));
    else
	    bits = bits + 8;
	    Reg = bitsll(Reg, 8);
    end
end
fp = fp - 1; 
Compress = buff;
['Output is ' num2str(fp*8) ' bits.']    % print the output bit size
compressed_bits = fp*8;
Frame_Size = fp*8;
%save ('buff.mat','buff', 'fp');
decbuff = [buff 0 0 0 0 0 0 0 0 0 0 0 0 ];  % initializing for decoding (pad some '0's...)
C = zeros(1,TOT_CONTEXTS); B = zeros(1,TOT_CONTEXTS); N = ones(1,TOT_CONTEXTS); A = ones(1,TOT_CONTEXTS) * A_init; 
melcstate = 1; melclen = J(melcstate); melcorder = bitsll(1, melclen); 
decfp = 1; bits = 0; Reg = uint32(0); 
fillbuffer(24);
createzeroLUT();
pscanline = zeros(1, width+1);  psl_0 = 0;
Recover = zeros(height, width);
for row=1:height  % decoding process
    if(row == 2)
        ['test']
    end
    sl_0 = pscanline(1); % 'Ra' of current line
    psl=pscanline; % previous line
    cscanline = lossless_undoscanline(psl, width, psl_0, sl_0, useRunMode);  % compressing process
    Recover(row, :) = cscanline;
    imerr = cscanline - image(row, :);
    if length(find(imerr ~= 0)) > 0
    	['Decoding row : ' num2str(row) ', Error occurs in this row' ]               % print current line if error occurs
    else
    	['Decoding row : ' num2str(row)]               % print current line if error occurs
    end
    pscanline = [cscanline cscanline(end)]; % move current line ot previous line. 
    psl_0 = sl_0; 
end
Recover = uint8(Recover);
imshow(Recover);
end
function cl = clip(x, Range)
cl=x;
if(x < 0) 
    cl = 0;
elseif (x >= Range) 
    cl = Range - 1;
end
end
function Px= predict(Rb, Ra, Rc)
if (Rb > Ra)
    minx = Ra;
    maxx = Rb;
else
    maxx = Ra;
    minx = Rb;
end
if (Rc >= maxx)
	Px = minx;
elseif (Rc <= minx)
    Px = maxx;
else
    Px = Ra + Rb - Rc;
end
end
%{
Reg is 32 since thats the total number of bits that can be put on bitstream
in one go, fp is the number of bytes, we accumulate bits till its equal to
a byte then put that byte into buff which holds the data
%}
function putbits(x, n) % assert that 0<=n<=24 and x<2^n. store x value in n-bit
global BITBUFSIZE; global bits; global Reg; global fp; global buff;

if(fp == 69)
    disp('test');
end

bits = bits - n; % remaining bits of Reg
Reg = bitor(Reg, bitsll(uint32(x), bits));  % concatenate x. 

%% for testing
if(bits <= 16)
    disp('test');
end
while (bits <= 24) % storing bit size >= 8
    temp = bitsrl(Reg, 24);  % MSB 8 bits
    buff(1, fp) = temp;
    fp = fp + 1;
    if ( temp == 255 )  % MSB 8 bits are all 1, 7-bit leftshift and stuff 0 at MSB, stuffed bit is used to say it is not part of marker segment
        bits = bits + 7;
        Reg = bitsll(Reg, 7);
        Reg = bitand(Reg, bitcmp(uint32(bitsll(1, BITBUFSIZE-1))));
    else
        bits = bits + 8;
        Reg =  bitsll(Reg, 8);
    end
end
end
function put_ones(hits) 
if ( hits < 24 ) 
    putbits(bitsll(1, hits)-1,hits); 
else
    nn = hits;
    while ( nn >= 24 )
		putbits(bitsll(1, 24)-1,24);
		nn = nn - 24;
    end
    if ( nn > 0 ) 
        putbits(bitsll(1, nn)-1, nn);
    end
end
end
function put_zeros(n)
global bits; global Reg; global fp; global buff;
bits = bits - n;
while (bits <= 24)
    temp = bitsrl(Reg, 24);
    buff(1, fp) = temp ;
    fp = fp + 1;
	Reg = bitsll(Reg, 8);
    bits = bits + 8;
end
end

function process_run(runlen, eoline)
global MELCSTATES; global EOLINE; global J; global melcstate; global melclen; global melcorder; global limit_reduce;
hits = 0; 
while ( runlen >= melcorder ) 
	hits = hits + 1;
	runlen = runlen - melcorder;
	if ( melcstate < MELCSTATES ) 
        melcstate = melcstate + 1;
		melclen = J(melcstate);
		melcorder = bitsll(1, melclen);
    end
end
put_ones(hits); % 1. store 1's as much as hits  
if ( eoline==EOLINE ) 	% end-of-line, if there is a non-null remainder, send it as if it were a max length run
	if ( runlen ) 
        put_ones(1); % 2. concatenate '1' and end, if EOLINE
    end
else  %  now send the length of the remainder, 
    limit_reduce = melclen+1; % we add the +1 to account for the '0'
    %put_zeros(1); %% Concatenate a 0
    putbits(runlen,limit_reduce); % 3. concatenate '0' and 'runlen', if not EOLINE
    if ( melcstate > 1 )    % adjust melcoder parameters 
        melcstate = melcstate - 1;
        melclen = J(melcstate); 
        melcorder = bitsll(1, melclen);
    end
end
end
function lossless_end_of_run(Ra, Rb, lx, RItype)
global EOR_0; global B; global N; global A; global Alpha; global ceil_half_Alpha; global Reset; global limit; global limit_reduce; global qbpp;
Q = EOR_0 + RItype;  % Q = 367 if Ra == Rb, else Q = 366
Nt = N(Q);
At = A(Q);
Errval = lx - Rb;
if (RItype) 
    At = At + floor(Nt/2);
elseif ( Rb < Ra ) 
    Errval = -Errval;
end
for k=0:32    
    if Nt >= At	% Estimate k 
        break;
    end
    Nt = bitsll(Nt, 1);
end
if (Errval < 0) 
    Errval = Errval + Alpha;
end
if( Errval >= ceil_half_Alpha ) 
    Errval = Errval - Alpha;
end
oldmap = double( k==0 && Errval && bitsll(B(Q), 1) < Nt );	   
if( Errval < 0)  %  Error mapping for run-interrupted sample (Figure A.22)	
	MErrval = int16(-bitsll(Errval, 1)-1-RItype+oldmap);
	B(Q) = B(Q) + 1; 
else
    MErrval = int16(bitsll(Errval, 1)-RItype-oldmap);
end
absErrval = bitsrl(int16(MErrval+1-RItype), 1);
A(Q) = A(Q) + absErrval;  % Update variables for run-interruped sample (Figure A.23) 
if (N(Q) == Reset)
	N(Q) = floor(N(Q)/2);
	A(Q) = floor(A(Q)/2);
	B(Q) = floor(B(Q)/2);
end
N(Q) = N(Q)+1; % for next pixel
eor_limit = limit - limit_reduce;   % Do the actual Golomb encoding
unary = bitsrl(int16(MErrval), k);
if ( unary < eor_limit ) 
	put_zeros(unary);
	putbits(bitsll(1,k) + bitand(uint32(MErrval), uint32(bitsll(1,k)) - 1), k + 1);
else
	put_zeros(eor_limit);
	putbits(bitsll(1,qbpp) + MErrval-1, qbpp+1);
end
end
function lossless_regular_mode(Q, SIGN, Px, lx)
global C; global B; global N; global A; global MAX_C; global MIN_C; global Alpha; global ceil_half_Alpha; global limit; global Reset; global qbpp;

if(Q == 4) 
    disp('test');
end

Nt = N(Q);
At = A(Q);
Ct = C(Q);
Px = Px + SIGN*C(Q);
Px = clip(Px, Alpha);
Errval = SIGN * (lx - Px);
nst = Nt;
for k=0:32
    if nst >= At
        break;
    end
    nst = bitsll(nst, 1);  % Estimate k - Golomb coding variable computation (A.5.1), k=getk[Nt][At];
end
Bt = B(Q);	% Do Rice mapping and compute magnitude of Errval
temp = double( k==0 && (bitsll(Bt, 1) <= -Nt));   % Error Mapping (A.5.2) 
if (Errval < 0) 
    Errval = Errval + Alpha;     % Modulo reduction of predication error (A.4.5), Errval is now in [0.. Alpha-1]
end
if (Errval >= ceil_half_Alpha) 
	Errval = Errval - Alpha;
	absErrval = -Errval;
	MErrval = int16(bitsll(absErrval, 1) - 1 - temp);
else
	absErrval = Errval;
	MErrval = int16(bitsll(absErrval, 1) + temp);
end

%% for TB
%{
A_values = [A_values; A(Q)];
B_values = [B_values; B(Q)];
C_values = [C_values; C(Q)];
N_values = [N_values; Nt];
%}
Bt = Bt + Errval;
B(Q) = Bt;	% update bias (after correction of difference) (A.6.1)
At = At + absErrval;
A(Q) = A(Q) + absErrval;  % update Golomb stats
if (Nt == Reset)	% Reset for Golomb and bias cancelation at the same time
    Nt = floor(Nt/2);
	N(Q) = Nt;
	A(Q) = floor(A(Q)/2);
    Bt = floor(Bt/2);
	B(Q) = Bt;
end
Nt = Nt+1;
N(Q) = Nt;
if ( Bt <= -Nt )% Do bias estimation for NEXT pixel, Bias cancelation tries to put error in (-1,0] (A.6.2)	
    if (C(Q) > MIN_C)
        C(Q) = C(Q) - 1;
    end
    B(Q) = B(Q) + Nt;
    if ( B(Q) <= -Nt )  
        B(Q) = -Nt+1;
    end
elseif ( Bt > 0 )
    if (C(Q) < MAX_C)
        C(Q) = C(Q) + 1;
    end
    B(Q) = B(Q) - Nt;
	if ( B(Q) > 0 ) 
        B(Q) = 0;
    end
end

%% for TB
At = A(Q);
Bt = B(Q);
Ct = C(Q);
Nt = N(Q);
%{
A_final = [A_final; A(Q)];
B_final = [B_final; B(Q)];
C_final = [C_final; C(Q)];
N_final = [N_final; Nt];
%}
unary = bitsrl(MErrval, k);    % Actually output the code: Mapped Error Encoding (Appendix G)

if(unary > 8) 
    disp('test');
end
if ( unary < limit )
    put_zeros(unary);
    test = bitsll(1, k) + bitand(MErrval, bitsll(1, k) - 1);
    if(k + 1 > 8) 
        disp('test');
    end
	 putbits(bitsll(1, k) + bitand(MErrval, bitsll(1, k) - 1), k + 1);
else
    put_zeros(limit);
    putbits(bitsll(1, qbpp) + MErrval - 1, qbpp+1);
end
end
function lossless_doscanline(psl, sl, psl_0, sl_0, useRunMode)
global EOLINE; global NOEOLINE; global vLUT; global lutmax; global classmap; global Cols;
global T1; global T2; global T3;
i=1; % pixel index
%These grab the psl's values for residual calulation
Rc = psl_0;
Rb = psl(1);
Ra = sl_0;
eol = NOEOLINE; 
while (i <= Cols)
    % Current Pixel
    lx = sl(i);
    
%% to determine the number of bits each iteration
global fp;
global bits;
global num_of_bits;
global buff;
total_bits = ((fp-1) * 8) + 32-bits;
num_of_bits = [num_of_bits; total_bits];

if(fp == 3)
    disp('test')
end
if(i == 47)
    disp('test');
end
    
    % NE pixel
    Rd = psl(i+1);
    
    %Context
   %{ 
    gradient_1 = vLUT(1, Rd-Rb+lutmax+1);
    gradient_2 = vLUT(2, Rb-Rc+lutmax+1);
    gradient_3 = vLUT(3, Rc-Ra+lutmax+1);
    cont = gradient_1 + gradient_2 + gradient_3;
    %}
   
    gradient_1 = double(Rd) - double(Rb);
    gradient_2 = double(Rb) - double(Rc);
    gradient_3 = double(Rc) - double(Ra);
    
    g_triplet = [gradient_1, gradient_2, gradient_3];
    
    q_triplet = zeros(1,3);
        for y = 1:3 %loop to quantize each gradient
            if(g_triplet(y) <= -T3)
                q_triplet(y) = -4;
            elseif(g_triplet(y) <= -T2)
                q_triplet(y) = -3;
            elseif(g_triplet(y) <= -T1)
                q_triplet(y) = -2;
            elseif(g_triplet(y) < 0)
                q_triplet(y) = -1;
            elseif(g_triplet(y) == 0)
                q_triplet(y) = 0;
            elseif(g_triplet(y) < T1)
                q_triplet(y) = 1;
            elseif(g_triplet(y) < T2)
                q_triplet(y) = 2;
            elseif(g_triplet(y) < T3)
                q_triplet(y) = 3;
            else
                q_triplet(y) = 4;
            end
        end
        
        if(q_triplet(1) < 0)
            SIGN = -1;
        elseif (q_triplet(1) > 0)
            SIGN = 1;
        else
            if(q_triplet(2) < 0)
                SIGN = -1;
            elseif(q_triplet(2) > 0)
                SIGN = 1;
            else
                if(gradient_3 < 0)
                    SIGN = -1;
                else
                    SIGN = 1;
                end
            end
        end
        
        if(SIGN == -1)
            cont = -81*q_triplet(1) - 9*q_triplet(2) - q_triplet(3);
        else
            cont = 81*q_triplet(1) + 9*q_triplet(2) + q_triplet(3);
        end
        
    
    if(cont == 171)
        disp('test')
    end
    
    if(cont == 0 && useRunMode)  % Run state
        RUNcnt = 0;
        if lx == Ra
            while (1)
                RUNcnt = RUNcnt + 1;
                i = i+1;
                if i > Cols
                    process_run(RUNcnt, EOLINE);
                    eol = EOLINE;
                    break;
                end
                lx = sl(i);
                if lx ~= Ra
                    Rd = psl(i+1);
                    Rb = psl(i);
                    break;  % out of while loop
                end
            end
        end
        if eol ~= EOLINE 
            process_run(RUNcnt,NOEOLINE);
            RItype = 0; 
            if (Ra==Rb)
                RItype = 1;
            end
            lossless_end_of_run(Ra, Rb, lx, RItype);	% END_OF_RUN state
        end
    else                    % Regualr state
        Px = predict(Rb, Ra, Rc);
     %{   
        cont = classmap(cont+1);
        if (cont<0)
            SIGN = -1;
            cont = -cont;
        else
            SIGN = 1;
        end
        
        Q = cont + 1;  % C-language index converted to matlab index
       %}
        Q = cont;
        lossless_regular_mode(Q, SIGN, Px, lx);
    end
    if eol ~= EOLINE 
        %sl(i) = lx;  % context for next pixel, ** needed? 
        Ra = lx;
        Rc = Rb;
        Rb = Rd;
        i = i+1;
    end
end
end
function prepareLUTs()
global T1; global T2; global T3; global vLUT; global classmap; global CREGIONS; global CONTEXTS1; 
idx = 0;
for i = -255:255 
	if ( i <= -T3  )
        idx = 7;       % ...... -T3  
    elseif ( i <= -T2 ) 
        idx = 5;   % -(T3-1) ... -T2 
    elseif ( i <= -T1 )
        idx = 3;   % -(T2-1) ... -T1 
    elseif ( i <= -1 )
        idx = 1;   % -(T1-1) ...  -1 
    elseif ( i == 0 )
        idx = 0;     %  just 0 
    elseif ( i < T1 ) 
        idx = 2;     % 1 ... T1-1 
    elseif ( i < T2 ) 
        idx = 4;     % T1 ... T2-1
    elseif ( i < T3 )
        idx = 6;     % T2 ... T3-1
    else
        idx = 8;     % T3 ... 
    end
	vLUT(1, i + 256 + 1) = CREGIONS * CREGIONS * idx; 
	vLUT(2, i + 256 + 1) = CREGIONS * idx;
	vLUT(3, i + 256 + 1) = idx;
end
j=0;
for i=1:CONTEXTS1-1
    if classmap(i+1) == 0	
        q1 = floor(i/(CREGIONS*CREGIONS));          % first digit
        q2 = mod(floor(i/CREGIONS), CREGIONS);		% second digit
        q3 = mod(i, CREGIONS);                      % third digit 
        sgn = 1;
        if(mod(q1,2)==1 || (q1==0 && mod(q2,2)==1) || (q1==0 && q2==0 && mod(q3,2)==1))	
            sgn = -1;
        else
            sgn = 1;
        end
        n1 = 0; n2 = 0; n3 = 0;
        if (q1)
            if mod(q1, 2) == 1
                n1 = q1 + 1;    % compute negative context
            else
                n1 = q1 - 1;    % compute negative context
            end
        end
        if (q2) 
            if mod(q2, 2) == 1
                n2 = q2 + 1;
            else
                n2 = q2 - 1;
            end
        end
        if (q3) 
            if mod(q3, 2) == 1
                n3 = q3 + 1;
            else
                n3 = q3 - 1;
            end
        end
        ineg = (n1*CREGIONS+n2)*CREGIONS+n3;
        j = j+1;    % next class number
        classmap(i+1) = sgn*j;	
        classmap(ineg+1) = -sgn*j;
%        [i classmap(i+1) ineg  classmap(ineg+1)]
    end
end
end
%%%%%%%%%%%%% encoding functions end %%%%%%%%%%%%%%%%
function fillbuffer(no) % read from decbuff, then store into Reg 
global Reg; global bits; global decbuff; global decfp;
Reg = bitsll(Reg, no);
bits = bits + no;
while (bits >= 0)
    x = decbuff(decfp);
    decfp = decfp + 1;
	if ( x == 255 ) % continuous eigit of '1's
		if ( bits < 8 ) 
            decfp = decfp - 1;
            decbuff(decfp)= 255; 
            break;
		else 
			x = uint32(decbuff(decfp));
            decfp = decfp + 1;
			if bitand(x,128) == 0  % '0' after 11111111, then drop the '0'
				Reg = bitor(Reg, bitor(bitsll(uint32(255), bits), bitsll(bitand(x, 127), bits-7)));
				bits = bits - 15;
			else 
				Reg = bitor(Reg, bitor(bitsll(uint32(255), bits), bitsll(x, bits-8)));
				bits = bits - 16;
            end
            continue;
        end
    end
	Reg = bitor(Reg, bitsll(x, bits));
	bits = bits - 8;
end
end
function createzeroLUT() % creates the bit counting look-up table. 
global zeroLUT;
j = 1;
k = 1;
l = 8;
for i = 1:256
	zeroLUT(i) = l;
	k = k-1;
	if (k == 0)
        k = j;
        l = l - 1;
        j = bitsll(j, 1);
    end
end
end
function temp = getbits(no)
global Reg; global BITBUFSIZE;
temp = double(bitsrl(Reg, BITBUFSIZE - no));
fillbuffer(no);
end
function current = lossless_regular_mode_d(Q, SIGN, Px)
global Reg; global B; global C; global N; global A; global Alpha; global Reset; global limit; global zeroLUT; global qbpp; global MAX_C; global MIN_C;
absErrval = 0; 
Nt = N(Q);
At = A(Q);
nst = Nt;
for k=0:32  % Estimate k
    if nst >= At
        break;
    end
    nst = bitsll(nst, 1);
end
while (1) 		% Get the number of leading zeros 
	temp = zeroLUT(bitsrl(Reg, 24)+1);
	absErrval = absErrval + temp;
	if (temp ~= 8)   % if bitsrl(reg, 24) ~= 0
        fillbuffer(temp + 1); 
        break;
    end
	fillbuffer(8);
end
if ( absErrval < limit ) % now add the binary part of the Rice code 
	if (k)
		absErrval = bitsll(absErrval, k);
		absErrval = absErrval + getbits(k);
    end
else
    absErrval = getbits(qbpp) + 1; 
end
% Do the Rice mapping 
if bitand(int16(absErrval), 1)            % negative 
	absErrval = (absErrval + 1) / 2;
	Errval = -absErrval;
else
	absErrval = absErrval/2;
	Errval = absErrval;
end
Bt = B(Q);
if ( k==0 && (2*Bt <= -Nt) )   % special case: see encoder side 
	Errval = -(Errval+1);
    if Errval<0
        absErrval = -Errval;
    else
        absErrval = Errval;
    end
end
if ( SIGN == -1 )  % center, clip if necessary, and mask final error
	Px = Px - C(Q);
	Px = clip(Px, Alpha);
	current = Px - Errval;
else
	Px = Px + C(Q);
	Px = clip(Px, Alpha);
	current = Px + Errval;
end
if (current < 0) 
    current = current + Alpha;
elseif (current >= Alpha)
    current = current - Alpha;
end
Bt = Bt + Errval;
B(Q) = Bt; 
A(Q) = A(Q) + absErrval;
if(Nt == Reset) 
    Nt = floor(Nt/2);
	N(Q) = Nt;
	A(Q) = floor(A(Q)/2);
	Bt = floor(Bt/2);
	B(Q) = Bt;
end
Nt = Nt + 1;
N(Q) = Nt;
if  ( Bt <= -Nt )
	if (C(Q) > MIN_C)
        C(Q) = C(Q) - 1;
    end
    B(Q) = B(Q) + Nt;
	Bt = B(Q);
	if ( Bt <= -Nt ) 
        B(Q) = -Nt+1;
    end
elseif ( Bt > 0 )
	if (C(Q) < MAX_C) 
        C(Q) = C(Q) + 1;
    end
    B(Q) = B(Q) - Nt;
	Bt = B(Q);
	if ( Bt > 0 ) 
        B(Q) = 0;
    end
end
end
function LEFT = process_run_dec(lineleft) %
global Reg; global J; global melcstate; global melclen; global melcorder; global zeroLUT; global EOLINE; global NOEOLINE; global limit_reduce; global MELCSTATES;
runlen = 0;
eol = NOEOLINE; 
while eol == NOEOLINE
    temp = zeroLUT(bitcmp(uint8(bitsrl(Reg, 24)))+1);
	for hits = 1:temp
		runlen = runlen + melcorder;
		if ( runlen >= lineleft )  % reached end-of-line 
			if (runlen==lineleft && melcstate < MELCSTATES)
                melcstate = melcstate + 1;
                melclen=J(melcstate); 
                melcorder=bitsll(1, melclen);
            end
			fillbuffer(hits); 
            LEFT = lineleft;
            eol = EOLINE;
            break;
        end
        if eol ~= EOLINE
            if ( melcstate < MELCSTATES )
                melcstate = melcstate + 1;
                melclen = J(melcstate); 
                melcorder = bitsll(1, melclen);
            end
        end
    end
    if eol ~= EOLINE
		if (temp ~= 8)       %  if reg >> 24  is not 11111111
            fillbuffer(temp + 1);
            break;
        end
		fillbuffer(8);
    end
end
if eol ~= EOLINE
    if ( melclen) 
        temp = getbits(melclen); 
        runlen = runlen + temp;
    end
    limit_reduce = melclen+1;
    if ( melcstate > 1 ) 
        melcstate = melcstate -1;
        melclen = J(melcstate); 
        melcorder = bitsll(1, melclen);
    end
    LEFT = runlen;
end
end
function Ix = lossless_end_of_run_d(Ra, Rb, RItype)
global Reg; global EOR_0; global B; global N; global A; global limit; global limit_reduce; global Reset; global zeroLUT; global qbpp; global Alpha;
MErrval=0;
Q = EOR_0 + RItype;
Nt = N(Q);
At = A(Q);
if ( RItype )
    At = At + floor(Nt/2);
end
for k=0:32
    if Nt >= At
        break;
    end
    Nt = Nt * 2;
end
while 1		% Get the number of leading zeros */
	temp = zeroLUT(bitsrl(Reg, 24)+1);
	MErrval = MErrval + temp;
	if (temp ~= 8) 
		fillbuffer(temp + 1);
		break;
    end
	fillbuffer(8);
end
eor_limit = limit - limit_reduce;
if ( MErrval < eor_limit ) 
	if (k) 
		MErrval = bitsll(MErrval, k);
		MErrval = MErrval + getbits(k);
    end
else
    MErrval = getbits(qbpp) + 1;  
end
oldmap = double(( k==0 && (RItype || MErrval) && (2*B(Q)<Nt)));	% 'oldmap' = (qdiff<0) ? (1-map) : map;	
MErrval = MErrval + ( RItype + oldmap );
if ( bitand(int16(MErrval), 1) )    % negative 
	Errval = oldmap - floor((MErrval+1)/2);
	absErrval = -Errval-RItype;
	B(Q) = B(Q) + 1;
else  % nonnegative 
	Errval = floor(MErrval/2);
	absErrval = Errval - RItype;
end
if ( Rb < Ra ) 
    Ix = Rb - Errval;
else
    Ix = Rb + Errval;
end
if (Ix < 0)	
    Ix = Ix + Alpha;
elseif (Ix >= Alpha) 
    Ix = Ix - Alpha;
end
 A(Q) = A(Q) + absErrval;
if (N(Q) == Reset)
	N(Q) = floor(N(Q)/2);
	A(Q) = floor(A(Q)/2);
	B(Q) = floor(B(Q)/2);
end
N(Q) = N(Q) + 1;
end
function sl = lossless_undoscanline(psl, width, psl_0, sl_0, useRunMode) %
global EOLINE; global NOEOLINE; global vLUT; global classmap; global lutmax;
eol = NOEOLINE;
i=1;
sl = zeros(1, width);
Rc = psl_0;
Rb = psl(1);
Ra = sl_0;
while (i <= width)
    Rd = psl(i + 1);
	cont =  vLUT(1, Rd - Rb + lutmax+1) + vLUT(2, Rb - Rc + lutmax+1) + vLUT(3, Rc - Ra + lutmax+1);
	if ( cont == 0 && useRunMode)      %*********** RUN STATE **********
    	n = process_run_dec(width-i+1); 
        m = n;
		if ( m > 0 )  %run of nonzero length, otherwise we go directly to the end-of-run state 
%            n = n-1;
			while (n > 0)
                sl(i) = Ra;
                i = i + 1;
                n = n-1;
            end
			if (i > width) 	
                eol = EOLINE;
                break;
            end 
            if eol ~= EOLINE
			    Rb = psl(i);
			    Rd = psl(i + 1);
            end
        end
        RItype = 0;
        if (Ra==Rb)
            RItype = 1;
        end
		Ra = lossless_end_of_run_d(Ra, Rb, RItype);
    else    % ************ REGULAR CONTEXT **********
		Px = predict(Rb, Ra, Rc);
		cont = classmap(cont+1);
		if (cont < 0) 
            SIGN = -1;	
            cont = -cont;
        else
            SIGN = +1;
        end
        Q = cont + 1;
		Ra = lossless_regular_mode_d(Q, SIGN, Px);
    end
	sl(i) = Ra;
	Rc = Rb;
	Rb = Rd;
	i = i + 1;
end
end
