load_mem_one = 1;
load_mem_two = 0;

mem_one_str = '';
mem_two_str = '';

mem_one_data = [];
mem_two_data = [];
Compressed_Data_Values = [];

temp = '';
%% file IO for TB
cwd = '/home/u1249940/Desktop/JPEG_LS/HDL/RTL';

%{
for i = 1:length(Recover)  
    if (image(i) ~= Recover(i))
        disp('Image was not recovered correctly');
    end
end
%}

for i = 1:10
    for j = 1:311
        for h = 1:135
        
           if(load_mem_one == 1)
               mem_one_data = [mem_one_data; typecast(Z(j,h,i), 'uint8')];
           end
           
           if(load_mem_two == 1)
               mem_two_data = [mem_two_data; typecast(Z(j,h,i), 'uint8')];
           end
           
           if(h == 135)
               if(load_mem_one == 1)
                   load_mem_one = 0;
                   load_mem_two = 1;
               else
                   load_mem_one = 1;
                   load_mem_two = 0;
               end
           end
                   
        end
    end
end

for i = 1:116234
    Test_value = dec2bin(Compress(i), 8);
    Compressed_Data_Values = strcat(Compressed_Data_Values, Test_value);
end

image_one_file = strcat(cwd, '/image_one_final_data.mem');
fileID = fopen(image_one_file, 'w');
for i = 1:209925
    fprintf(fileID,'%d\n', mem_one_data(i))
end
fclose(fileID);

image_two_file = strcat(cwd, '/image_two_final_data.mem');
fileID = fopen(image_two_file, 'w');
for i = 1:209925
    fprintf(fileID,'%d\n', mem_two_data(i))
end
fclose(fileID);

encoded_bitstream_file = strcat(cwd, '/final_encoded_bitstream_test.mem');
fileID = fopen(encoded_bitstream_file, 'w');
fprintf(fileID,'%s\n', Compressed_Data_Values)
fclose(fileID); 
