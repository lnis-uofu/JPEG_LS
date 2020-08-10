%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This encoder codes 8 bit per pixel single tone images
% The implementation mirrors the description in the ITU T.87
% and attach the jpeg header for said example.
% This code is to better understand the hardware implementation
% of the algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% example image values from ITU standard, H.3
%image = [0,0,90,74,68,50,43,205,64,145,145,145,100,145,145,145];
%image = [186,184,187,187,68,50,43,205,64,145,145,145,100,145,145,145];
%image = typecast(Z(1,:, 1), 'uint8');

Current_Row = [];
Converted_Row = [];
image = zeros(644,135);
for i = 1 : 2
    for j = 1 : 311
        Current_Row = Z(j,:, i);
        Converted_Row = typecast(Z(j,:, i), 'uint8');
        image(j + ((i-1) * 311) ,:) = Converted_Row;
    end
end

width = 135;
height = 622;
maxval = 255;
bit_depth = 8;
%% initialize JPEG-LS step 1
near = 0; %center region; default, lossless
range = maxval + 1; %percision; default, lossless,  = 256
qbpp = bit_depth; %bit depth, from image, = 8
bpp = max(2,ceil(log2(maxval+1))); %bit depth, used for limit calc, = 8
limit = 2*(bpp + max(8,bpp)); %limit of code length, = 32\
max_error_value_run = 0;
%quantization regions; default 8-qbpp
T1 = 3; T2 = 7; T3 = 21;
g1 = int16(-1);
g2 = int16(-1);
g3 = int16(-255);
%sign variable for adaptive correction
sign = 1; %1 = pos, 0 = neg
error_value = 0; %computed error value residual
%when to reset adaptive parameter counter
reset = 64; %default, lossless
%adaptive correction parameters
C = zeros(1,365); % (cumulative) prediction correction values
B = zeros(1,365); % bias
N = ones(1,367); 
Nn = zeros(1,367); %for run mode, only need last 2 indexes
A_init = max(2,floor((range+2^5)/2^6));
A = ones(1,367) * A_init; %empty array A
%closed range for variable C forall indexes
min_C = -128;
max_C = 127;
%recorded error values for TB
error_residual = [];
error_modulo = [];
x_predict = [];
sign_comp = [];
C_comp = [];
mode_comp = [];
a_b_compare = [];
RIType_comp = [];
A_values = [];
B_values = [];
C_values = [];
N_values = [];
Nn_values = [];
A_final = [];
B_final = [];
C_final = [];
N_final = [];
Nn_final = [];
B_N_Compare = [];
N_Nn_Compare = [];
A_values_for_k = [];
N_values_for_k = [];
temp_values = [];
k_values = [];
limit_overflow_values = [];
encoded_temp_value = '';
encoded_value = [];
encoded_length = [];
run_index_values = [];
remainder_values = [];
unary_values = [];
hits_values = [];
D_1_values = [];
D_2_values = [];
D_3_values = [];
a_values = [];
b_values = [];
c_values = [];
d_values = [];
x_values = [];
EOL_values = [];
run_values = [];
run_count_values = [];
run_count_new_values = [];
C_t_values = [];
run_index_input_values = [];
run_count_compare_values = [];
run_count_compare_new_values = [];
run_count_after_subtract = [];
mode_run_length_adjust = [];
do_run_length_adjust = [];
J_values = [];
J_Comp_values = [];
J_recurring_mode_two_values = [];
start_enc_values = [];
remainder_subtract_accum_values = [];
remainder_subtract_accum = 0;
run_count_compare = 0;
run_index_test = 0;
previous_mode = 0;
two_mode_two = 0;
%run mode variables
run_count = 0; %how long the run is
run_index = 1; %index of run vector J (start at 1 for matlab
run_index_fixed = 1; %refer to this index when coding run intfor. variable
run_value = 0; %comparison variable to check equality of x during run
run_interupt_type = 0; %coding identifier for run length
J = [0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3, ... 
    4,4,5,5,6,6,7,7,8,9,10,11,12,13,14,15];
J_Values = [1,2,3,4,6,7,10,12,16,20,24,28,36,44,52,60,76,92,124,156,220,284,412,540,796,1308,2332,4380,8476,16668,33052,65820];
J_Index = 1;
%context map variables
num_gradients = 729; %based on quantization regions; defaunt 8qbpp
map_size = 365; %size of context map; default
total_quantized_gradients = cell(1,num_gradients); %empty cell of gradients
context_map = cell(1,map_size);
init_q1 = -4; init_q2 = -4; init_q3 = -4;
j = 2;
for i = 1:num_gradients %fill all defined quantized values
    total_quantized_gradients{i} = [init_q1,init_q2,init_q3];
    if(init_q3 < 4)
    init_q3 = init_q3 + 1;
    else
        init_q3 = -4;
        init_q2 = init_q2 + 1;
    end
    
    if(init_q2 > 4)
    init_q1 = init_q1 + 1;
    init_q2 = -4;
    end
end
for i = 1:map_size %fill map with quantized triplets w/o run mode
    
    if(total_quantized_gradients{i}(1) == total_quantized_gradients{i}(2) && ...
            total_quantized_gradients{i}(1) == total_quantized_gradients{i}(3) ...
            && total_quantized_gradients{i}(1) == 0)
        
        context_map{1} = total_quantized_gradients{i}; %[0 0 0] for run length mode
        
    else
        context_map{j} = total_quantized_gradients{i};
        j = j + 1;
    end
    
end
map_index = 1; %pointer index for map -> corrective parameters
var_k = 0; %Golomb variable k
end_of_line = 0; %designate end of line
mode = 0; %what operating mode
%0 - normal mode
%1 - run mode
%2 - run coding
a_from_previous_line = 0; %save previous first 'a' value
encoded_bitstream = char.empty; %final bitstream 
%% start image processing

for row = 1:height
for index = 1:width %for all samples of image
    x = image(row, index); %get new sample
    
    if(length(encoded_value) ~= length(a_values))
        disp('test')
    end
    
    if(length(a_values) == 135)
        disp('test')
    end
    
    if(row == 233)
        disp('test')
    end
    
    if(index == 8)
        disp('end of line');
    end
    
    if(index <= width) %if on the first row of the image
        if(row == 1)
            b = 0; c = 0; d = 0;
        else
            if(index == 1)
                if (row >= 3)
                    c = image(row - 2, index);
                else 
                    c = 0;
                end
            else
                c = b;
            end
            
            if(index == 1)
                b = image(row - 1, index);
            else
                b = d;
            end
            
            if(index < width)
                 d = image(row - 1, index + 1);
            end
        end
        
        if(1 == mod(index,width)) %if also on first col
            a = b;
        else
            a = image(row, index-1);
        end
    else
        if(1 == mod(index,width)) %if also on first col
            b = image(index-width);
            a = b;
            c = a_from_previous_line; %set c to previous 'a'
            a_from_previous_line = a; %update saved 'a'
            d = image((index-width)+1);
                
        elseif(0 == mod(index,width)) %if on last col
            a = image(index-1);
            b = image(index-width);
            c = image((index-width)-1);
            d = b;
        else
            a = image(index-1);
            b = image(index-width);
            c = image((index-width)-1);
            d = image((index-width)+1);
        end
    end
    
    %% for TB
    a_values = [a_values; a];
    b_values = [b_values; b];
    c_values = [c_values; c];
    d_values = [d_values; d];
    x_values = [x_values; x];
    
    %% normal mode
    if(mode == 0) %normal mode
   
        % compute gradients
        g1 = double(d)-double(b); 
        g2 = double(b)-double(c); 
        g3 = double(c)-double(a);
        
        %store in vector for computational purposes
        g_triplet = [g1,g2,g3];
        
        %% mode selection step 3
        if(g1 == g2 && g1 == g3 && g1 == near) 
            mode = 1; %go to run mode
            run_value = a; %very first sample in run
            run_count = 0;
        end
    end
    
    %% normal coding
    if(mode == 0)
        %% quantize g -> q step 4
        %get a quantized triplet
        q_triplet = zeros(1,3);
        for i = 1:3 %loop to quantize each gradient
            if(g_triplet(i) <= -T3)
                q_triplet(i) = -4;
            elseif(g_triplet(i) <= -T2)
                q_triplet(i) = -3;
            elseif(g_triplet(i) <= -T1)
                q_triplet(i) = -2;
            elseif(g_triplet(i) < near)
                q_triplet(i) = -1;
            elseif(g_triplet(i) == near)
                q_triplet(i) = 0;
            elseif(g_triplet(i) < T1)
                q_triplet(i) = 1;
            elseif(g_triplet(i) < T2)
                q_triplet(i) = 2;
            elseif(g_triplet(i) < T3)
                q_triplet(i) = 3;
            else
                q_triplet(i) = 4;
            end
        end
        
        %% for TB
        if(q_triplet(1) < 0)
            if (q_triplet(1) == -1)
                D_1_values = [D_1_values; 15];
            elseif (q_triplet(1) == -2)
                D_1_values = [D_1_values; 14];
            elseif (q_triplet(1) == -3)
                D_1_values = [D_1_values; 13];
            elseif (q_triplet(1) == -4)
                D_1_values = [D_1_values; 12];
            end
        else
            D_1_values = [D_1_values; q_triplet(1)];
        end
        
        if(q_triplet(2) < 0)
            if (q_triplet(2) == -1)
                D_2_values = [D_2_values; 15];
            elseif (q_triplet(2) == -2)
                D_2_values = [D_2_values; 14];
            elseif (q_triplet(2) == -3)
                D_2_values = [D_2_values; 13];
            elseif (q_triplet(2) == -4)
                D_2_values = [D_2_values; 12];
            end
        else
            D_2_values = [D_2_values; q_triplet(2)];
        end
        
        if(q_triplet(3) < 0)
            if (q_triplet(3) == -1)
                D_3_values = [D_3_values; 15];
            elseif (q_triplet(3) == -2)
                D_3_values = [D_3_values; 14];
            elseif (q_triplet(3) == -3)
                D_3_values = [D_3_values; 13];
            elseif (q_triplet(3) == -4)
                D_3_values = [D_3_values; 12];
            end
        else
            D_3_values = [D_3_values; q_triplet(3)];
        end
        
        run_count_values = [run_count_values; 0];
        run_count_new_values = [run_count_new_values; 0];
        run_values = [run_values; x];
        current_hit = 0;
        if(previous_mode == 2)
            if(run_index_fixed >= 2)
                run_index_values = [run_index_values; run_index_fixed - 2]; 
            else
                run_index_values = [run_index_values; run_index_fixed - 1];
            end
 % - 2 since we are index 0-32 in TB and this is 1-32, and we need to subtract 1 extra so -2 to get index right, in addition these are the output values for the decrement of run index
            run_index_input_values = [run_index_input_values; run_index_fixed - 1];
            run_count_compare_values = [run_count_compare_values; bitsll(1,J(run_index_fixed))];
            run_count_compare_new_values = [run_count_compare_new_values; bitsll(1,J(run_index))];
            if (two_mode_two == 1)
                J_values = [J_values; J(run_index_fixed)];
                J_Comp_values = [J_Comp_values; J(run_index_fixed)];
                two_mode_two = 0;
            else
                J_values = [J_values; J(run_index)];
                J_Comp_values = [J_Comp_values; J(run_index)];
            end

        else %% works for previous mode == 3
            run_index_values = [run_index_values; run_index - 1]; %run index is decremented by 1 to refkect 0 indexing
            run_index_input_values = [run_index_input_values; run_index - 1];
            run_count_compare_values = [run_count_compare_values; bitsll(1,J(run_index))]; % updating the J value to the previous run index value
            run_count_compare_new_values = [run_count_compare_new_values; bitsll(1,J(run_index))];
            J_values = [J_values; J(run_index)];
            J_Comp_values = [J_Comp_values; J(run_index)];
        end
        remainder_subtract_accum_values = [remainder_subtract_accum_values; 0];
        J_recurring_mode_two_values = [J_recurring_mode_two_values; J(run_index)];
        previous_mode = 0;
        run_count_after_subtract = [run_count_after_subtract; 0];
        start_enc_values = [start_enc_values; 1];
        
            
        
        
        %% compare triplet to map, get index and sign step 5
        for i=1:map_size
            test = isequal(context_map{i},q_triplet);
            if(isequal(context_map{i},q_triplet) > 0)
                sign = 0; %flip, all values in map start negative
                map_index = i; %refer to this index when correcting
                break %since map is 1 to 1, no need to continue
            elseif(isequal(context_map{i},-q_triplet) > 0)
                sign = 1; %dont flip, -q_triplet must be positive
                map_index = i; %refer to this index when correcting
                break %since map is 1 to 1, no need to continue
            else
                %do nothing
            end
        end
        
        %% for TB
        if(sign == 0)
            temp_index = -81*q_triplet(1) + -9*q_triplet(2) + -1*q_triplet(3); 
        else
            temp_index = 81*q_triplet(1) + 9*q_triplet(2) + 1*q_triplet(3); 
        end
        C_t_values = [C_t_values; temp_index];
        
        
        
        %% compute prediction of sample x using edge detection step 6
        if(c >= max(a,b))
            predict_x = min(a,b);
        elseif(c <= min(a,b))
            predict_x = max(a,b);
        else
            predict_x = double(a)+double(b)-double(c);
        end
        
        %% collecting data for TB
        x_predict = [x_predict; predict_x];
        
        %% adaptively correct prediction of x step 7
        if (sign == 1) %positive
            predict_x = predict_x + C(map_index);
        else %negative
            predict_x = double(predict_x) - double(C(map_index));
        end
        if (predict_x > maxval) %clamp to max percision 
            predict_x = maxval;
        elseif (predict_x < 0) %clamp to min value
            predict_x = 0;
        end
        
        %% compute prediction residual (error value) step 8
        %force x to signed 8bit integer
        error_value = cast(x,'int16') - cast(predict_x,'int16');
        %flip sign to keep consistency
        if (sign == 0) %negative sign
            error_value = - error_value; %flip sign
        end
        %% collecting data for TB
        error_residual = [error_residual; error_value];
        if(sign == 0)
            sign_comp = [sign_comp; 1];
        else
            sign_comp = [sign_comp; 0];
        end
        C_comp = [C_comp; C(map_index)];
        mode_comp = [mode_comp; 0];
        a_b_compare = [a_b_compare; 0];
        RIType_comp = [RIType_comp; 0];
        
        %% mod reduce the prediction residual step 9
        if (error_value < 0)
            error_value = error_value + range;
        end
        if (error_value >= ((range+1)/ 2))
            error_value = error_value - range;
        end
        
        %% collecting data for TB
        error_modulo = [error_modulo; error_value];
        
        
        %% for TB
        A_values_for_k = [A_values_for_k; A(map_index)];
        N_values_for_k = [N_values_for_k; N(map_index)];
        temp_values = [temp_values; 0];
        
        %% compute the Golomb variable k step 10
        for k=0:8
            if bitsll(N(map_index),k)>=A(map_index)
                var_k = k; %set Golomb global to k
                break;
            end
        end
        
        %% for TB
        k_values = [k_values; var_k];
       
        
        %% map reduced error residual to non negative number step 11
        if (near == 0 && k == 0 && (2 * B(map_index)) <= (-N(map_index)))
            if error_value >= 0
                mapped_error_value = 2 * error_value + 1;
            else
                mapped_error_value = -2 * (error_value + 1);
            end
        else
            if error_value >= 0
                mapped_error_value = 2 * error_value;
            else
                mapped_error_value = -2 * error_value - 1;
            end
        end
        
        %% encode mapped reduced error residual to limited length code step 12
        %
        %this is only for matlab, since it works with integer..
        %convert to binary string, truncate by k and convert back to uint
        mErrVal_temp_bin = dec2bin(mapped_error_value,qbpp);
        %will need this value as well
        mErrVal_temp_bin_trunc = mErrVal_temp_bin(1:qbpp-k);
        %keep k lsb values, we'll need these for bitstream
        mErrVal_temp_bin_k_values = mErrVal_temp_bin(qbpp-k+1:qbpp);
        encoded_mapped_error_value_truncate = bin2dec(mErrVal_temp_bin_trunc);
        %end matlab extra stuff
        %
        
        %% for TB
        unary_values = [unary_values; encoded_mapped_error_value_truncate];
        hits_values = [hits_values; 0];
        
        if encoded_mapped_error_value_truncate < (limit - qbpp - 1)
            
            %% for TB
            limit_overflow_values = [limit_overflow_values; 0];
            
            %add number of zeros unary by that number
            for g = 1:encoded_mapped_error_value_truncate
                %append bitstream
                encoded_bitstream = strcat(encoded_bitstream,'0');
                
                %% for TB
                encoded_temp_value = strcat(encoded_temp_value, '0');
            end
            %append binary 1 after loop
            encoded_bitstream = strcat(encoded_bitstream,'1');
            %lastly add k lsb values as they are to bitstream
            encoded_bitstream = strcat(encoded_bitstream,mErrVal_temp_bin_k_values);
            
            
            %% for TB
            encoded_temp_value = strcat(encoded_temp_value, '1');
            encoded_temp_value = strcat(encoded_temp_value, mErrVal_temp_bin_k_values);
            encoded_value = [encoded_value; bin2dec(encoded_temp_value)];
            encoded_temp_value = '';
            encoded_length = [encoded_length; encoded_mapped_error_value_truncate + k + 1];
            remainder_values = [remainder_values; 0];
           
        else
            %% for TB
            limit_overflow_values = [limit_overflow_values; 1];
            encoded_length = [encoded_length; limit - qbpp - 1];
            
            %else use this number of 0s
            for g = 1:(limit - qbpp - 1)
                %append bitstream
                encoded_bitstream = strcat(encoded_bitstream,'0');
                
                %% for TB
                encoded_temp_value = strcat(encoded_temp_value, '0');
            end
            %append binary 1 after loop
            encoded_bitstream = strcat(encoded_bitstream,'1');
            %append mapped_error_value-1 in binary to end
            mErrVal_temp_bin_m1 = dec2bin(mapped_error_value-1,qbpp);
            encoded_bitstream = strcat(encoded_bitstream,mErrVal_temp_bin_m1);
            
            %% for TB
            remainder_values = [remainder_values; bin2dec(mErrVal_temp_bin_m1)];
            encoded_value = [encoded_value; bin2dec(encoded_temp_value)];
            encoded_temp_value = char.empty;
        end
        
        %% collecting values for TB
        A_values = [A_values; A(map_index)];
        B_values = [B_values; B(map_index)];
        C_values = [C_values; C(map_index)];
        N_values = [N_values; N(map_index)];
        Nn_values = [Nn_values; 0];
        N_Nn_Compare = [N_Nn_Compare; 0];
        
         %% for TB
         if(2 * B(map_index) <= -N(map_index))
            B_N_Compare = [B_N_Compare; 1];
         else
            B_N_Compare = [B_N_Compare; 0];
         end
        
         if(index  == 85)
                disp('test');
         end
        
        %% NOTE: everything below should be done at the end of the process
        %% update adaptive correction parameters step 13
        B(map_index) = B(map_index) + error_value *(2 *near + 1);
        A(map_index) = A(map_index) + abs(error_value);
        if (N(map_index) == reset)
            A(map_index) = floor(A(map_index)/2);
            N(map_index) = floor(N(map_index)/2);
            B(map_index) = floor(B(map_index)/2);
        end
        N(map_index) = N(map_index) + 1;
        
        
        %% do bias computation and clamp if needed step 14
        if (B(map_index) <= -N(map_index))
            %% continue bias computation
            B(map_index) = B(map_index) + N(map_index);
            if (C(map_index) > min_C)
                C(map_index) = C(map_index) - 1;
            end
            if (B(map_index) <= -N(map_index))
                B(map_index) = -N(map_index) + 1;
            end
        elseif (B(map_index) > 0)

            B(map_index) = B(map_index) - N(map_index);
            if (C(map_index) < max_C)
                C(map_index) = C(map_index) + 1;
            end
            if (B(map_index) > 0)
                B(map_index) = 0;
            end
        end 
        
        %% collecting values for TB
        A_final = [A_final; A(map_index)];
        B_final = [B_final; B(map_index)];
        C_final = [C_final; C(map_index)];
        N_final = [N_final; N(map_index)];
        Nn_final = [Nn_final; 0];
        
    end
    
    
    %% run mode
    if(mode == 1)  %run mode
        
        %% for TB, no need to do gradient Quantization so we are just filling 0's
        D_1_values = [D_1_values; 0];
        D_2_values = [D_2_values; 0];
        D_3_values = [D_3_values; 0];
        run_values = [run_values; x];
       
        
        
        %% run-length determination step 15 (run interruption)
        if(x ~= run_value)
            mode = 2; %run coding
            
            %% for TB
            mode_comp = [mode_comp; 2];
            
            %% for TB
            hits_values = [hits_values; 0];
            run_count_values = [run_count_values; 0];
            run_count_new_values = [run_count_new_values; 0];
        end
        if(mode == 1) %dont count run interupt variable
        %% for TB
        run_count_values = [run_count_values; run_count];
            
        run_count = run_count + 1; %keep going, inc. count
        
        %% for TB
        run_count_new_values = [run_count_new_values; run_count];      
            %% for TB
            if(previous_mode == 2 || previous_mode == 0 || previous_mode == 3)
                %% we need to reset J_index to the base compare value for each respective set
                run_index_test = run_index;
                previous_mode = 1;
                run_count_compare = bitsll(1,J(run_index_test));
                remainder_subtract_accum = 0;
            end
            run_count_compare_values = [run_count_compare_values; run_count_compare];
            if(run_count_compare == run_count)
                run_index_input_values = [run_index_input_values; run_index_test - 1];
                hits_values = [hits_values; 1];
                if(run_index_test < 32)
                    run_index_test = run_index_test + 1;
                end
                
                encoded_value = [encoded_value; 1];
                encoded_length = [encoded_length; 1];
                    
                current_hit = 1;
                run_count_compare = run_count_compare + bitsll(1,J(run_index_test));
                remainder_subtract_accum = run_count;
                
                remainder_subtract_accum_values = [remainder_subtract_accum_values; remainder_subtract_accum];
                J_Comp_values = [J_Comp_values; J(run_index_test - 1)];
            else
                hits_values = [hits_values; 0];
                if(index == width)
                    encoded_value = [encoded_value; 1];
                    encoded_length = [encoded_length; 1];
                else
                    encoded_value = [encoded_value; 0];
                    encoded_length = [encoded_length; 0];
                end
                run_index_input_values = [run_index_input_values; run_index_test - 1];
                current_hit = 0;
                J_Comp_values = [J_Comp_values; J(run_index_test)];
                
                remainder_subtract_accum = remainder_subtract_accum;
                
                remainder_subtract_accum_values = [remainder_subtract_accum_values; remainder_subtract_accum];
            end           
            J_recurring_mode_two_values = [J_recurring_mode_two_values; 0];
            J_values = [J_values; J(run_index_test)];
            limit_overflow_values = [limit_overflow_values; 0];
            encoded_temp_value = char.empty;
            remainder_values = [remainder_values; 0];
            unary_values = [unary_values; 0];
            run_index_values = [run_index_values; run_index_test - 1]; %% -1 is there due to 0 vs 1 base index
            run_count_compare_new_values = [run_count_compare_new_values; run_count_compare];
        end
    end
    
    if(mod(index,width) == 0) %check EOL
        end_of_line = 1; %identify EOL
        
        %% for TB
        EOL_values = [EOL_values; end_of_line];
        
        if(mode == 1) %if just exited run counting
            mode = 2; %run coding
            
            %% for TB
            mode_comp = [mode_comp; 3];
            previous_mode = 3;
        end    
    else
        end_of_line = 0; %not EOL
        
        %% for TB
        EOL_values = [EOL_values; end_of_line];
    end
    
    %% for TB
    if (mode == 1 || end_of_line == 1)
        if(end_of_line == 1 && mode ~= 0 && mode ~=2)
            RIType_comp = [RIType_comp; 0];
            a_b_compare = [a_b_compare; 0];
            C_t_values = [C_t_values; 0];
            x_predict = [x_predict; 0];
            Nn_values = [Nn_values; 0];
            Nn_final = [Nn_final; 0];
            A_values = [A_values; 0];
            A_values_for_k = [A_values_for_k; 0];
            A_final = [A_final; 0];
            B_final = [B_final; 0];
            B_N_Compare = [B_N_Compare; 0];
            B_values = [B_values; 0];
            C_comp = [C_comp; 0];
            C_final = [C_final; 0];
            C_values = [C_values; 0];
            error_modulo = [error_modulo; 0];
            error_residual = [error_residual; 0];
            k_values = [k_values; 0];
            N_final = [N_final; 0];
            N_Nn_Compare = [N_Nn_Compare; 0];
            N_values = [N_values; 0];
            N_values_for_k = [N_values_for_k; 0];
            sign_comp = [sign_comp; 0];
            run_count_after_subtract = [run_count_after_subtract; run_count];
            start_enc_values = [start_enc_values; 1];
            current_hit = 0;
        elseif (previous_mode == 3)
            RIType_comp = [RIType_comp; 0];
            a_b_compare = [a_b_compare; 0];
            C_t_values = [C_t_values; 0];
            x_predict = [x_predict; 0];
            Nn_values = [Nn_values; 0];
            Nn_final = [Nn_final; 0];
            A_values = [A_values; 0];
            A_values_for_k = [A_values_for_k; 0];
            A_final = [A_final; 0];
            B_final = [B_final; 0];
            B_N_Compare = [B_N_Compare; 0];
            B_values = [B_values; 0];
            C_comp = [C_comp; 0];
            C_final = [C_final; 0];
            C_values = [C_values; 0];
            error_modulo = [error_modulo; 0];
            error_residual = [error_residual; 0];
            k_values = [k_values; 0];
            N_final = [N_final; 0];
            N_Nn_Compare = [N_Nn_Compare; 0];
            N_values = [N_values; 0];
            N_values_for_k = [N_values_for_k; 0];
            sign_comp = [sign_comp; 0];
            start_enc_values = [start_enc_values; 1];
            temp_values = [temp_values; 0];
        elseif (mode == 1)
            mode_comp = [mode_comp; 1];
            previous_mode = 1;
            RIType_comp = [RIType_comp; 0];
            a_b_compare = [a_b_compare; 0];
            C_t_values = [C_t_values; 0];
            x_predict = [x_predict; 0];
            Nn_values = [Nn_values; 0];
            Nn_final = [Nn_final; 0];
            A_values = [A_values; 0];
            A_values_for_k = [A_values_for_k; 0];
            A_final = [A_final; 0];
            B_final = [B_final; 0];
            B_N_Compare = [B_N_Compare; 0];
            B_values = [B_values; 0];
            C_comp = [C_comp; 0];
            C_final = [C_final; 0];
            C_values = [C_values; 0];
            error_modulo = [error_modulo; 0];
            error_residual = [error_residual; 0];
            k_values = [k_values; 0];
            N_final = [N_final; 0];
            N_Nn_Compare = [N_Nn_Compare; 0];
            N_values = [N_values; 0];
            N_values_for_k = [N_values_for_k; 0];
            sign_comp = [sign_comp; 0];
            temp_values = [temp_values; 0];
            run_count_after_subtract = [run_count_after_subtract; run_count - remainder_subtract_accum];
            start_enc_values = [start_enc_values; 0];
        end       
    end
    
    
    %% run coding for run interruption
    if(mode == 2) % run coding
        
        %% for TB
        if(previous_mode == 2)
            two_mode_two = 1;
            run_index_values = [run_index_values; run_index - 1];
            run_index_input_values = [run_index_input_values; run_index_fixed - 1];
            run_count_compare_values = [run_count_compare_values; bitsll(1,J(run_index))];
            run_count_compare_new_values = [run_count_compare_new_values; run_count_compare_values(length(run_count_compare_new_values))];
            J_values = [J_values; J(run_index)];
            J_Comp_values = [J_Comp_values; J(run_index)];
            J_recurring_mode_two_values = [J_recurring_mode_two_values; J(run_index)];
            remainder_subtract_accum_values = [remainder_subtract_accum_values; 0];
        end
       
        %% for TB
        if(previous_mode == 0 || previous_mode == 2 || previous_mode == 1)
            run_count_after_subtract = [run_count_after_subtract; 0];
        elseif (previous_mode == 3 && index == 1)
            run_count_after_subtract = [run_count_after_subtract; 0];
        else
            run_count_after_subtract = [run_count_after_subtract; run_count - remainder_subtract_accum];
        end
        start_enc_values = [start_enc_values; 1];
        
        
        %% encode run segments rg step 16
        %run for maximum lenght
        for j=1:run_count
            %else break when condition is met
            if(run_count < bitsll(1,J(run_index)))
                break;
            end
            %append a 1 to bitstream
            encoded_bitstream = strcat(encoded_bitstream,'1');
            %dec. run_count by 1<<J
            run_count = run_count - bitsll(1,J(run_index));
            if(run_index < 32)
                run_index = run_index +1;
            end
        end
        %hold run_index before decrement *(see step 25)
        run_index_fixed = run_index;   
        
        %if we were interupted by a change in value
        %% encode run segments lengths not rg step 17
        if(x ~= run_value)
            
                %append 0 to bitsream
                encoded_bitstream = strcat(encoded_bitstream,'0');
                
                %create J(run_index) size binary with value runcount
                temp_runcount_binary = dec2bin(run_count,J(run_index));      
                %append to bitstream
                encoded_bitstream = strcat(encoded_bitstream,temp_runcount_binary);
                %decrement run index
                if (run_index > 1)
                    run_index = run_index - 1;
                end 
                
                %% for TB this will be updating the previous value for mode == 1 if we hit run interruption on the next pixel
                %% so what we do is we take the previous_mode == 1 if it had a hit and append a (0, bitsll(1, J(run_index)) to it
                if(current_hit == 1 && previous_mode == 1)
                    temp = char.empty
                    temp = strcat('1', '0');
                    temp = strcat(temp, temp_runcount_binary);
                    if(length(encoded_value) == 0)
                        encoded_value(1) = bin2dec(temp);
                        encoded_length(1) = [encoded_length; strlength(temp)];
                    else
                        encoded_value(length(encoded_value)) = bin2dec(temp);
                        encoded_length(length(encoded_length)) = strlength(temp);
                    end
                elseif(current_hit == 0 && previous_mode == 1)
                    temp = char.empty
                    temp = strcat('0');
                    temp = strcat(temp, temp_runcount_binary);
                    if(length(encoded_value) == 0)
                        encoded_value(1) = bin2dec(temp);
                        encoded_length(1) = [encoded_length; strlength(temp)];
                    else
                        encoded_value(length(encoded_value)) = bin2dec(temp);
                        encoded_length(length(encoded_length)) = strlength(temp);
                    end
                elseif(previous_mode == 0 || previous_mode == 2)
                    %% in this case there we were either interrupted by previous_mode == 0 or previous_mode == 2
                    %% so all we need to add is (0,bitsll(1,J(run_index)) and we will in the unary encoding
                    %% sequence we will be appending to this value
                    temp = char.empty;
                    temp = strcat('0', temp_runcount_binary);
                end
        else
                encoded_bitstream = strcat(encoded_bitstream,'1');
                
                %% for TB
                if (current_hit == 1)
                    %encoded_value = [encoded_value; 3];
                   % encoded_length = [encoded_length; 2];
                    remainder_values = [remainder_values; 0];
                else
                    %encoded_value = [encoded_value; 1];
                    %encoded_length = [encoded_length; 1];
                    remainder_values = [remainder_values; 0];
                end
                
                %%put back to normal coding
                mode = 0;
                    
        end
       
        
        if(x ~= run_value) %only code run interupt sample if there is one(not if EOL caused run interruption)
            %% compute index for run interupt sample step 18
            if(a == b)
                run_interupt_type = 1;
            else
                run_interupt_type = 0;
            end
            
            
            %% predict error for run interupt sample step 19
            if (run_interupt_type == 1)
                predict_x = a;
            else
                predict_x = b;
            end
            
            %% collecting data for TB
            x_predict = [x_predict; predict_x];
            if(previous_mode ~= 2)
                run_index_input_values = [run_index_input_values; run_index_fixed - 1];
                run_index_values = [run_index_values; run_index_fixed - 1];
                if (previous_mode == 1 && current_hit == 1)
                    run_count_compare_values = [run_count_compare_values; run_count_compare_values(length(run_count_compare_values)) + bitsll(1, J(run_index_fixed))];
                elseif (previous_mode == 0)
                    run_count_compare_values = [run_count_compare_values; bitsll(1, J(run_index_fixed))];
                elseif(previous_mode == 3)
                    run_count_compare_values = [run_count_compare_values; run_count_compare_new_values(length(run_count_compare_values))];
                else
                    run_count_compare_values = [run_count_compare_values; run_count_compare_values(length(run_count_compare_values))];
                end
                run_count_compare_new_values = [run_count_compare_new_values; run_count_compare_new_values(length(run_count_compare_new_values))];
                J_values = [J_values; J(run_index_fixed)];
                J_Comp_values = [J_Comp_values; J(run_index_fixed)];
                J_recurring_mode_two_values = [J_recurring_mode_two_values; 0];
                remainder_subtract_accum_values = [remainder_subtract_accum_values; 0];
            end
            %{
            if(previous_mode == 0)
                run_index_input_values = [run_index_input_values; run_index - 1];
                run_index_values = [run_index_values; run_index - 1];
                run_count_compare_values = [run_count_compare_values; bitsll(1, J(run_index))];
                run_count_compare_new_values = [run_count_compare_new_values; bitsll(1, J(run_index))];
                J_values = [J_values; J(run_index)];
                J_Comp_values = [J_Comp_values; J(run_index)];
                J_recurring_mode_two_values = [J_recurring_mode_two_values; 0];
                remainder_subtract_accum_values = [remainder_subtract_accum_values; 0];
            end
            %}
            current_hit = 0;
            
            error_value = cast(x,'int16') - cast(predict_x,'int16');
            
            %% error computation (sign designation) step 20
            if ((run_interupt_type == 0) && (a > b))
                error_value = -error_value;
                sign = 0;
            else
                sign = 1;
            end
            
           %% collecting data for TB
           error_residual = [error_residual; error_value];
           if(sign == 0)
                sign_comp = [sign_comp; 1];
           else
                sign_comp = [sign_comp; 0];
           end
           C_comp = [C_comp; 0];
        
           if (a > b)
                a_b_compare = [a_b_compare; 1];
           else
                a_b_compare = [a_b_compare; 0];
           end
           RIType_comp = [RIType_comp; run_interupt_type];
            
            %error_value = -128;
            %error needs to be reduced to between [-alpha/2 <= x <=
            %alpha/2]
            if (error_value < 0 ) 
                error_value = error_value + range;
            end
            if (error_value >= (range + 1) / 2) 
                error_value = error_value - range;
            end
            
          %% collecting data for TB
          error_modulo = [error_modulo; error_value];
            
           %{   
            if(error_value > max_error_value_run)
                max_error_value_run = error_value;
            end
           %}
          
            
            %% compute aux temp variable for run step 21
            if (run_interupt_type == 0)
                temp_run_index = A(366);
            else
                temp_run_index = A(367) + bitsrl(cast(N(367),'uint8'),1);
            end
            %set map index accordingly to run_interupt_type + 366
            map_index = run_interupt_type + 366;
            
            %% for TB
            A_values_for_k = [A_values_for_k; A(map_index)];
            N_values_for_k = [N_values_for_k; N(map_index)];
            temp_values = [temp_values; temp_run_index];
            C_t_values = [C_t_values; map_index - 1];
            
            
            %% compute k like in normal mode, use aux temp step 22
            for k=0:8
                if bitsll(N(map_index),k)>=temp_run_index
                    var_k = k; %set Golomb global to k
                    break;
                end
            end
            
            %% for TB
            k_values = [k_values; var_k];
            
            
            %% for TB
            if (2 * Nn(map_index) < N(map_index))
                N_Nn_Compare = [N_Nn_Compare; 0];
            elseif (2 * Nn(map_index) >= N(map_index))
                N_Nn_Compare = [N_Nn_Compare; 1];
            else
                N_Nn_Compare = [N_Nn_Compare; 2];
            end
            
            %% compute aux 'map' variable for error mapping step 23
            if ((k == 0) && (error_value > 0) && (2 * Nn(map_index) < N(map_index)))
                map = 1;
            elseif ((error_value < 0) && (2 * Nn(map_index) >= N(map_index)))
                map = 1;
            elseif ((error_value < 0) && (k ~= 0))
                map = 1;
            else
                map = 0;
            end
            
            %% error mapping complete for run interrupt sample step 24
            if(error_value < 0)
                mapped_run_error_value = (-2 * error_value)-run_interupt_type - map;
            else
                mapped_run_error_value = (2 * error_value)-run_interupt_type - map;
            end
            %% encode this run variable like normal mode step 25
            %
            %this is only for matlab, since it works with integer..
            %convert to binary string, truncate by k and convert back to uint
            mErrVal_temp_bin = dec2bin(mapped_run_error_value,qbpp);
            %will need this value as well
            mErrVal_temp_bin_trunc = mErrVal_temp_bin(1:qbpp-k);
            %keep k lsb values, we'll need these for bitstream
            mErrVal_temp_bin_k_values = mErrVal_temp_bin(qbpp-k+1:qbpp);
            encoded_mapped_error_value_truncate = bin2dec(mErrVal_temp_bin_trunc);
            %end matlab extra stuff
            %
            
             %% for TB
             unary_values = [unary_values; encoded_mapped_error_value_truncate];
             
            
            if encoded_mapped_error_value_truncate < ((limit - J(run_index_fixed) - 1) - qbpp - 1)
                %% for TB
                limit_overflow_values = [limit_overflow_values; 0];
               
                %add number of zeros unary by that number
                for g = 1:encoded_mapped_error_value_truncate
                    %append bitstream
                    encoded_bitstream = strcat(encoded_bitstream,'0');
                    
                    %% for TB
                    encoded_temp_value = strcat(encoded_temp_value, '0');
                end
                %append binary 1 after loop
                encoded_bitstream = strcat(encoded_bitstream,'1');
                %lastly add k lsb values as they are to bitstream
                encoded_bitstream = strcat(encoded_bitstream,mErrVal_temp_bin_k_values);
                
                %% for TB
                encoded_temp_value = strcat(encoded_temp_value, '1');
                encoded_temp_value = strcat(encoded_temp_value, mErrVal_temp_bin_k_values);
                if(previous_mode == 0 || previous_mode == 2)
                     encoded_temp_value = strcat(temp, encoded_temp_value);
                     encoded_value = [encoded_value; bin2dec(encoded_temp_value)];
                     encoded_length = [encoded_length; strlength(encoded_temp_value)];
                else
                    encoded_value = [encoded_value; bin2dec(encoded_temp_value)];
                    encoded_length = [encoded_length; encoded_mapped_error_value_truncate + k + 1];
                end
                encoded_temp_value = char.empty;
                remainder_values = [remainder_values; 0];
                
            else
                
                %% for TB
                limit_overflow_values = [limit_overflow_values; 1];
                encoded_length = [encoded_length; limit - qbpp - 1];
                
                %else use this number of 0s
                for g = 1:(limit - qbpp - 1)
                    %append bitstream
                    encoded_bitstream = strcat(encoded_bitstream,'0');
                end
                %append binary 1 after loop
                encoded_bitstream = strcat(encoded_bitstream,'1');
                %append mapped_error_value-1 in binary to end
                mErrVal_temp_bin_m1 = dec2bin(mapped_run_error_value-1,qbpp);
                encoded_bitstream = strcat(encoded_bitstream,mErrVal_temp_bin_m1);
                
                
                %% for TB
                encoded_temp_value = strcat('1', mErrVal_temp_bin_m1);
                remainder_values = [remainder_values; bin2dec(encoded_temp_value)];
                encoded_temp_value = char.empty;
                encoded_value = [encoded_value; 0];
                
            end
            
        %% collecting values for TB
        A_values = [A_values; A(map_index)];
        B_values = [B_values; 0];
        C_values = [C_values; 0];
        N_values = [N_values; N(map_index)];
        Nn_values = [Nn_values; Nn(map_index)];
        B_N_Compare = [B_N_Compare; 0];
        previous_mode = 2;
            
            %% update variables after run interrupt mapping step 26
            if (error_value < 0)
                Nn(map_index) = Nn(map_index) + 1;
            end
            A(map_index) = A(map_index) + bitsrl(cast((mapped_run_error_value + 1 - run_interupt_type),'uint8'),1);
            if (N(map_index) == reset)
                A(map_index) = floor(A(map_index)/2);
                N(map_index) = floor(N(map_index)/2);
                Nn(map_index) = floor(Nn(map_index)/2);
            end
            N(map_index) = N(map_index) + 1;
            
            %done with run coding, go back to normal mode
            mode = 0;
            
        %% collecting values for TB
        A_final = [A_final; A(map_index)];
        B_final = [B_final; 0];
        C_final = [C_final; 0];
        N_final = [N_final; N(map_index)];
        Nn_final = [Nn_final; Nn(map_index)];
            
        end
    end
  
end %end of code
% Dont know what this is for yet
%% pad to nearest byte
%%while(mod(length(encoded_bitstream),8) ~= 0)
    %encoded_bitstream = strcat(encoded_bitstream,'0');
%end

%% for TB need to get mode_values(i+1) for Run_length_adjust because it depends on the next mode input in Verilog
%{
mode_run_length_adjust = [mode_run_length_adjust; 0];
for i = 2:(length(mode_comp) - 1)
    mode_run_length_adjust = [mode_run_length_adjust; mode_comp(i+1)];
end
mode_run_length_adjust = [mode_run_length_adjust; 0];

for i = 1:length(mode_comp)
    if(mode_comp(i) == 2)
        do_run_length_adjust = [do_run_length_adjust; 1];
    else
        do_run_length_adjust = [do_run_length_adjust; 0];
    end
end
%}
end

%}
%% build jpeg container
%keep these
SOI = 65496; %start of image
SOF = 65527; %stat of jls frame
marker_SOF = 11; %length of sof marker
SOS = 65498; %start of scan marker
marker_SOS = 8; %length of SOS marker
EOI = 65497; %end of image
%variable
P = 8; %init precision
Y = height; %init number of lines
X = width; %init number of cols
Nf = 1; %init number of components
C1 = 1; %init component ID
H1 = 1; V1 = 1; %init subsampling per comp.
Tq1 = 0; %KEEP ZERO
Ns = 1; %init number of components
Ci = 1; %init component ID
Tm1 = 0; %init mapping table index
near = 0; %init loss/lossless
ILV = 0; %init interleave mode
Al = 0; Ah = 0; %init point transform
jpeg_header = char.empty;
%populate header
%%
temp_b = dec2bin(SOI,16);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(SOF,16);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(marker_SOF,16);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(P,8);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(Y,16);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(X,16);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(Nf,8);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(C1,8);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(H1,4);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(V1,4);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(Tq1,8);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(SOS,16);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(marker_SOS,16);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(Ns,8);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(Ci,8);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(Tm1,8);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(near,8);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(ILV,8);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(Al,4);
jpeg_header = strcat(jpeg_header,temp_b);
temp_b = dec2bin(Ah,4);
jpeg_header = strcat(jpeg_header,temp_b);
%add header to data
full_file = strcat(jpeg_header,encoded_bitstream);
%add EOI marker
temp_b = dec2bin(EOI,16);
full_file = strcat(full_file,temp_b);

%% file IO for TB
cwd = '/home/u1249940/Desktop/JPEG_LS/HDL/RTL';
a_file = strcat(cwd, '/a_test.mem');
fileID = fopen(a_file, 'w');
for i = 1:length(a_values)
    fprintf(fileID,'%d\n', a_values(i))
end
fclose(fileID); 

b_file = strcat(cwd, '/b_test.mem');
fileID = fopen(b_file, 'w');
for i = 1:length(b_values)
    fprintf(fileID,'%d\n', b_values(i))
end
fclose(fileID); 

c_file = strcat(cwd, '/c_test.mem');
fileID = fopen(c_file, 'w');
for i = 1:length(c_values)
    fprintf(fileID,'%d\n', c_values(i))
end
fclose(fileID); 

d_file = strcat(cwd, '/d_test.mem');
fileID = fopen(d_file, 'w');
for i = 1:length(d_values)
    fprintf(fileID,'%d\n', d_values(i))
end
fclose(fileID); 

x_file = strcat(cwd, '/x_test.mem');
fileID = fopen(x_file, 'w');
for i = 1:length(x_values)
    fprintf(fileID,'%d\n', x_values(i))
end
fclose(fileID); 

D_1_file = strcat(cwd, '/D_1_gradient_quant_test.mem');
fileID = fopen(D_1_file, 'w');
for i = 1:length(D_1_values)
    fprintf(fileID,'%d\n', D_1_values(i))
end
fclose(fileID); 

D_2_file = strcat(cwd, '/D_2_gradient_quant_test.mem');
fileID = fopen(D_2_file, 'w');
for i = 1:length(D_2_values)
    fprintf(fileID,'%d\n', D_2_values(i))
end
fclose(fileID); 

D_3_file = strcat(cwd, '/D_3_gradient_quant_test.mem');
fileID = fopen(D_3_file, 'w');
for i = 1:length(D_3_values)
    fprintf(fileID,'%d\n', D_3_values(i))
end
fclose(fileID); 

mode_file = strcat(cwd, '/mode_test.mem');
fileID = fopen(mode_file, 'w');
for i = 1:length(mode_comp)
    fprintf(fileID,'%d\n', mode_comp(i))
end
fclose(fileID); 

RIType_file = strcat(cwd, '/RIType_test.mem');
fileID = fopen(RIType_file, 'w');
for i = 1:length(RIType_comp)
    fprintf(fileID,'%d\n', RIType_comp(i))
end
fclose(fileID); 

a_b_compare_file = strcat(cwd, '/a_b_compare_test.mem');
fileID = fopen(a_b_compare_file, 'w');
for i = 1:length(a_b_compare)
    fprintf(fileID,'%d\n', a_b_compare(i))
end
fclose(fileID); 

EOL_file = strcat(cwd, '/EOL_test.mem');
fileID = fopen(EOL_file, 'w');
for i = 1:length(EOL_values)
    fprintf(fileID,'%d\n', EOL_values(i))
end
fclose(fileID); 

run_count_file = strcat(cwd, '/run_count_test.mem');
fileID = fopen(run_count_file, 'w');
for i = 1:length(run_count_values)
    fprintf(fileID,'%d\n', run_count_values(i))
end
fclose(fileID); 

run_count_new_file = strcat(cwd, '/run_count_new_test.mem');
fileID = fopen(run_count_new_file, 'w');
for i = 1:length(run_count_new_values)
    fprintf(fileID,'%d\n', run_count_new_values(i))
end
fclose(fileID); 

run_values_file = strcat(cwd, '/run_value_test.mem');
fileID = fopen(run_values_file, 'w');
for i = 1:length(run_values)
    fprintf(fileID,'%d\n', run_values(i))
end
fclose(fileID); 

C_t_file = strcat(cwd, '/C_t_test.mem');
fileID = fopen(C_t_file, 'w');
for i = 1:length(C_t_values)
    fprintf(fileID,'%d\n', C_t_values(i))
end
fclose(fileID); 

Px_file = strcat(cwd, '/Px_test.mem');
fileID = fopen(Px_file, 'w');
for i = 1:length(x_predict)
    fprintf(fileID,'%d\n', x_predict(i))
end
fclose(fileID); 

Run_index_input_file = strcat(cwd, '/Run_index_input_test.mem');
fileID = fopen(Run_index_input_file, 'w');
for i = 1:length(run_index_input_values)
    fprintf(fileID,'%d\n', run_index_input_values(i))
end
fclose(fileID); 

Run_index_file = strcat(cwd, '/Run_index_output_test.mem');
fileID = fopen(Run_index_file, 'w');
for i = 1:length(run_index_values)
    fprintf(fileID,'%d\n', run_index_values(i))
end
fclose(fileID); 

Run_count_file = strcat(cwd, '/Run_count_input_test.mem');
fileID = fopen(Run_count_file, 'w');
for i = 1:length(run_count_values)
    fprintf(fileID,'%d\n', run_count_values(i))
end
fclose(fileID); 

Run_count_new_file = strcat(cwd, '/Run_count_output_test.mem');
fileID = fopen(Run_count_new_file, 'w');
for i = 1:length(run_count_new_values)
    fprintf(fileID,'%d\n', run_count_new_values(i))
end
fclose(fileID); 

Run_count_compare_file = strcat(cwd, '/Run_count_compare_input_test.mem');
fileID = fopen(Run_count_compare_file, 'w');
for i = 1:length(run_count_compare_values)
    fprintf(fileID,'%d\n', run_count_compare_values(i))
end
fclose(fileID); 

Run_count_compare_new_file = strcat(cwd, '/Run_count_compare_output_test.mem');
fileID = fopen(Run_count_compare_new_file, 'w');
for i = 1:length(run_count_compare_new_values)
    fprintf(fileID,'%d\n', run_count_compare_new_values(i))
end
fclose(fileID); 

hit_file = strcat(cwd, '/hit_test.mem');
fileID = fopen(hit_file, 'w');
for i = 1:length(hits_values)
    fprintf(fileID,'%d\n', hits_values(i))
end
fclose(fileID); 

C_file = strcat(cwd, '/C_test.mem');
fileID = fopen(C_file, 'w');
for i = 1:length(C_values)
    fprintf(fileID,'%d\n', C_values(i))
end
fclose(fileID); 

sign_file = strcat(cwd, '/sign_test.mem');
fileID = fopen(sign_file, 'w');
for i = 1:length(sign_comp)
    fprintf(fileID,'%d\n', sign_comp(i))
end
fclose(fileID); 

Residual_file = strcat(cwd, '/Residual_test.mem');
fileID = fopen(Residual_file, 'w');
for i = 1:length(error_residual)
    fprintf(fileID,'%d\n', error_residual(i))
end
fclose(fileID); 

Residual_modulo_file = strcat(cwd, '/Residual_modulo_test.mem');
fileID = fopen(Residual_modulo_file, 'w');
for i = 1:length(error_modulo)
    fprintf(fileID,'%d\n', error_modulo(i))
end
fclose(fileID); 

Temp_file = strcat(cwd, '/Temp_test.mem');
fileID = fopen(Temp_file, 'w');
for i = 1:length(temp_values)
    fprintf(fileID,'%d\n', temp_values(i))
end
fclose(fileID); 

A_file = strcat(cwd, '/A_test.mem');
fileID = fopen(A_file, 'w');
for i = 1:length(A_values)
    fprintf(fileID,'%d\n', A_values(i))
end
fclose(fileID);

B_file = strcat(cwd, '/B_test.mem');
fileID = fopen(B_file, 'w');
for i = 1:length(B_values)
    fprintf(fileID,'%d\n', B_values(i))
end
fclose(fileID);

N_file = strcat(cwd, '/N_test.mem');
fileID = fopen(N_file, 'w');
for i = 1:length(N_values)
    fprintf(fileID,'%d\n', N_values(i))
end
fclose(fileID); 

Nn_file = strcat(cwd, '/Nn_test.mem');
fileID = fopen(Nn_file, 'w');
for i = 1:length(Nn_values)
    fprintf(fileID,'%d\n', Nn_values(i))
end
fclose(fileID); 

A_final_file = strcat(cwd, '/A_final_test.mem');
fileID = fopen(A_final_file, 'w');
for i = 1:length(A_final)
    fprintf(fileID,'%d\n', A_final(i))
end
fclose(fileID);

B_final_file = strcat(cwd, '/B_final_test.mem');
fileID = fopen(B_final_file, 'w');
for i = 1:length(B_final)
    fprintf(fileID,'%d\n', B_final(i))
end
fclose(fileID); 

C_final_file = strcat(cwd, '/C_final_test.mem');
fileID = fopen(C_final_file, 'w');
for i = 1:length(C_final)
    fprintf(fileID,'%d\n', C_final(i))
end
fclose(fileID); 


N_final_file = strcat(cwd, '/N_final_test.mem');
fileID = fopen(N_final_file, 'w');
for i = 1:length(N_final)
    fprintf(fileID,'%d\n', N_final(i))
end
fclose(fileID); 

Nn_final_file = strcat(cwd, '/Nn_final_test.mem');
fileID = fopen(Nn_final_file, 'w');
for i = 1:length(Nn_final)
    fprintf(fileID,'%d\n', Nn_final(i))
end
fclose(fileID); 

N_Nn_Compare_file = strcat(cwd, '/N_Nn_Compare_test.mem');
fileID = fopen(N_Nn_Compare_file, 'w');
for i = 1:length(N_Nn_Compare)
    fprintf(fileID,'%d\n', N_Nn_Compare(i))
end
fclose(fileID); 

B_N_Compare_file = strcat(cwd, '/B_N_Compare_test.mem');
fileID = fopen(B_N_Compare_file, 'w');
for i = 1:length(B_N_Compare)
    fprintf(fileID,'%d\n', B_N_Compare(i))
end
fclose(fileID); 

k_file = strcat(cwd, '/k_test.mem');
fileID = fopen(k_file, 'w');
for i = 1:length(k_values)
    fprintf(fileID,'%d\n', k_values(i))
end
fclose(fileID); 

Run_count_remainder_file = strcat(cwd, '/Run_count_remainder_test.mem');
fileID = fopen(Run_count_remainder_file, 'w');
for i = 1:length(run_count_after_subtract)
    fprintf(fileID,'%d\n', run_count_after_subtract(i))
end
fclose(fileID); 

Do_run_length_adjust_file = strcat(cwd, '/Do_run_length_adjust_test.mem');
fileID = fopen(Do_run_length_adjust_file, 'w');
for i = 1:length(do_run_length_adjust)
    fprintf(fileID,'%d\n', do_run_length_adjust(i))
end
fclose(fileID); 

encoded_length_file = strcat(cwd, '/encoded_length_test.mem');
fileID = fopen(encoded_length_file, 'w');
for i = 1:length(encoded_length)
    fprintf(fileID,'%d\n', encoded_length(i))
end
fclose(fileID); 

encoded_value_file = strcat(cwd, '/encoded_value_test.mem');
fileID = fopen(encoded_value_file, 'w');
for i = 1:length(encoded_value)
    fprintf(fileID,'%d\n', encoded_value(i))
end
fclose(fileID); 

remainder_value_file = strcat(cwd, '/remainder_value_test.mem');
fileID = fopen(remainder_value_file, 'w');
for i = 1:length(remainder_values)
    fprintf(fileID,'%d\n', remainder_values(i))
end
fclose(fileID); 

unary_file = strcat(cwd, '/unary_value_test.mem');
fileID = fopen(unary_file, 'w');
for i = 1:length(unary_values)
    fprintf(fileID,'%d\n', unary_values(i))
end
fclose(fileID); 

J_file = strcat(cwd, '/J_value_test.mem');
fileID = fopen(J_file, 'w');
for i = 1:length(J_values)
    fprintf(fileID,'%d\n', J_values(i))
end
fclose(fileID); 

J_Comp_file = strcat(cwd, '/J_Comp_value_test.mem');
fileID = fopen(J_Comp_file, 'w');
for i = 1:length(J_Comp_values)
    fprintf(fileID,'%d\n', J_Comp_values(i))
end
fclose(fileID); 

J_recurring_mode_two_file = strcat(cwd, '/J_recurring_mode_two_value_test.mem');
fileID = fopen(J_recurring_mode_two_file, 'w');
for i = 1:length(J_recurring_mode_two_values)
    fprintf(fileID,'%d\n', J_recurring_mode_two_values(i))
end
fclose(fileID); 

limit_overflow_file = strcat(cwd, '/limit_overflow_test.mem');
fileID = fopen(limit_overflow_file, 'w');
for i = 1:length(limit_overflow_values)
    fprintf(fileID,'%d\n', limit_overflow_values(i))
end
fclose(fileID); 

start_enc_file = strcat(cwd, '/start_enc_test.mem');
fileID = fopen(start_enc_file, 'w');
for i = 1:length(start_enc_values)
    fprintf(fileID,'%d\n', start_enc_values(i))
end
fclose(fileID);

encoded_bitstream_file = strcat(cwd, '/encoded_bitstream_test.mem');
fileID = fopen(encoded_bitstream_file, 'w');
fprintf(fileID,'%s\n', encoded_bitstream)
fclose(fileID); 

image_file = strcat(cwd, '/image_test.mem');
fileID = fopen(image_file, 'w');
for i = 1:length(image)
    fprintf(fileID,'%d\n', image(i))
end
fclose(fileID);

remainder_subtract_accum_file = strcat(cwd, '/remainder_subtract_accum_test.mem');
fileID = fopen(remainder_subtract_accum_file, 'w');
for i = 1:length(remainder_subtract_accum_values)
    fprintf(fileID,'%d\n', remainder_subtract_accum_values(i))
end
fclose(fileID);



%% file IO
fileID = fopen('test_data_mycode.txt','w');
for i = 1:4:length(full_file)
temp1 = full_file(i:i+3);
fprintf(fileID,'%s\r\n',temp1);
end
fclose(fileID);
%% hex outputs for checking
%array_stream = encoded_bitstream-'0';
%full_array = full_file-'0';
%hex_stream = binaryVectorToHex(array_stream);
%full_hex = binaryVectorToHex(full_array);