function golden_model_main()

clc;
close all;

%% ================================================================
%  MATLAB GOLDEN MODEL
%  2D Convolution - FPGA Project
%
%  Input      : 16x16 grayscale image
%  Pixel      : 8-bit unsigned
%  Kernel     : 3x3 signed
%  Stride     : 1
%  Padding    : VALID
%  Output     : 14x14
% ================================================================


%% PARAMETERS

IMAGE_WIDTH  = 16;
IMAGE_HEIGHT = 16;
PIXEL_BITS   = 8;

KERNEL_SIZE = 3;
STRIDE      = 1;
PADDING     = 'VALID';

% Pre-stored kernel selection
%
% 0 = Identity
% 1 = Edge Horizontal
% 2 = Edge Vertical
% 3 = Sharpen
% 4 = Blur
% 5 = Custom Edge
% 6 = emboss
% 7 = bottom_sobel
% 8 = outline
FILTER_SELECT = 2;

% Signed accumulator width
ACC_BITS = 20;


%% INPUT IMAGE

% Put your 16x16 image in the same folder
% and give it this name.

IMAGE_FILE = 'input_image.png';

if ~exist(IMAGE_FILE,'file')
    error('Input image file "%s" was not found.', IMAGE_FILE);
end

image_in = imread(IMAGE_FILE);


% Convert RGB image to grayscale

if ndims(image_in) == 3

    image_in = uint8( ...
        0.299 * double(image_in(:,:,1)) + ...
        0.587 * double(image_in(:,:,2)) + ...
        0.114 * double(image_in(:,:,3)) );

end


% Check image size

if size(image_in,1) ~= IMAGE_HEIGHT || ...
   size(image_in,2) ~= IMAGE_WIDTH

    error('Input image must be exactly 16x16 pixels.');

end


image_in = uint8(image_in);


fprintf('\n============================================\n');
fprintf('MATLAB 2D CONVOLUTION GOLDEN MODEL\n');
fprintf('============================================\n');

fprintf('Input image : %d x %d\n', ...
    IMAGE_HEIGHT, IMAGE_WIDTH);

fprintf('Pixel width : %d bits\n', PIXEL_BITS);


%% KERNEL BANK

[kernel_bank, kernel_names] = get_kernel_bank();


if FILTER_SELECT < 0 || ...
   FILTER_SELECT >= size(kernel_bank,3)

    error('Invalid FILTER_SELECT.');

end


kernel = int64(kernel_bank(:,:,FILTER_SELECT + 1));

selected_name = kernel_names{FILTER_SELECT + 1};


fprintf('Kernel      : 3 x 3\n');
fprintf('Stride      : %d\n', STRIDE);
fprintf('Padding     : %s\n', PADDING);
fprintf('Filter      : %d (%s)\n', ...
    FILTER_SELECT, selected_name);

fprintf('============================================\n');


disp('Selected kernel:');
disp(kernel);


%% GOLDEN CONVOLUTION

[golden_raw, golden_display] = ...
    conv2d_golden(image_in, kernel, STRIDE, PADDING);


[OUT_H, OUT_W] = size(golden_raw);


fprintf('\nOutput size : %d x %d\n', OUT_H, OUT_W);
fprintf('Total outputs = %d\n', numel(golden_raw));


disp('Golden raw output:');
disp(golden_raw);


%% FIRST WINDOW CHECK

first_window = int64(image_in(1:3,1:3));

manual_result = sum(sum(first_window .* kernel));


fprintf('\nFirst 3x3 window check:\n');

disp(first_window);

fprintf('Manual result = %d\n', manual_result);

fprintf('Golden result = %d\n', golden_raw(1,1));


if manual_result == golden_raw(1,1)

    fprintf('First window check: PASS\n');

else

    fprintf('First window check: FAIL\n');

end


%% DISPLAY INPUT AND OUTPUT

figure('Name','Input Image');

imagesc(image_in);
axis image;
colormap gray;
colorbar;

title('Input Image - 16x16');


figure('Name','Golden Output');

imagesc(golden_display);
axis image;
colormap gray;
colorbar;

title('Golden Output - 14x14');


%% OUTPUT DIRECTORY

OUT_DIR = 'FPGA_TEST_VECTORS';

if ~exist(OUT_DIR,'dir')

    [status,msg] = mkdir(OUT_DIR);

    if ~status

        error('Could not create folder %s: %s', ...
            OUT_DIR, msg);

    end

end


%% WRITE INPUT IMAGE

write_hex_mem( ...
    image_in, ...
    fullfile(OUT_DIR,'input_image.mem'), ...
    PIXEL_BITS);


%% WRITE SELECTED KERNEL

write_signed_hex_mem( ...
    kernel, ...
    fullfile(OUT_DIR,'kernel_selected.mem'), ...
    PIXEL_BITS);


%% WRITE ALL PRE-STORED KERNELS

write_kernel_bank_mem( ...
    kernel_bank, ...
    fullfile(OUT_DIR,'kernel_rom.mem'), ...
    PIXEL_BITS);


%% WRITE GOLDEN RAW OUTPUT

write_signed_hex_mem( ...
    golden_raw, ...
    fullfile(OUT_DIR,'golden_output_raw.mem'), ...
    ACC_BITS);


%% WRITE DISPLAY OUTPUT

write_hex_mem( ...
    golden_display, ...
    fullfile(OUT_DIR,'golden_output_display.mem'), ...
    PIXEL_BITS);


%% WRITE DECIMAL GOLDEN OUTPUT

write_decimal_mem( ...
    golden_raw, ...
    fullfile(OUT_DIR,'golden_output_raw_decimal.txt'));


%% WRITE TEST CONFIGURATION

config_file = fullfile(OUT_DIR,'test_config.txt');

fid = fopen(config_file,'w');

if fid == -1
    error('Cannot create test_config.txt');
end


fprintf(fid,'IMAGE_WIDTH=%d\n', IMAGE_WIDTH);
fprintf(fid,'IMAGE_HEIGHT=%d\n', IMAGE_HEIGHT);
fprintf(fid,'PIXEL_BITS=%d\n', PIXEL_BITS);

fprintf(fid,'KERNEL_WIDTH=3\n');
fprintf(fid,'KERNEL_HEIGHT=3\n');

fprintf(fid,'STRIDE=%d\n', STRIDE);
fprintf(fid,'PADDING=%s\n', PADDING);

fprintf(fid,'OUTPUT_WIDTH=%d\n', OUT_W);
fprintf(fid,'OUTPUT_HEIGHT=%d\n', OUT_H);

fprintf(fid,'ACC_BITS=%d\n', ACC_BITS);

fprintf(fid,'FILTER_SELECT=%d\n', FILTER_SELECT);
fprintf(fid,'SELECTED_FILTER=%s\n', selected_name);

fprintf(fid,'NUM_FILTERS=%d\n', size(kernel_bank,3));


fclose(fid);


%% WRITE FILTER LIST

filter_file = fullfile(OUT_DIR,'filter_list.txt');

fid = fopen(filter_file,'w');

if fid == -1
    error('Cannot create filter_list.txt');
end


for f = 1:size(kernel_bank,3)

    fprintf(fid, ...
        'FILTER_SELECT=%d  NAME=%s\n', ...
        f-1, kernel_names{f});

end


fclose(fid);


%% RTL COMPARISON

RTL_FILE = fullfile(OUT_DIR,'rtl_output.mem');


fprintf('\n============================================\n');
fprintf('RTL vs MATLAB GOLDEN\n');
fprintf('============================================\n');


if exist(RTL_FILE,'file')

    rtl = read_rtl_mem(RTL_FILE, ACC_BITS);

    golden = int64(golden_raw(:));


    fprintf('Golden outputs = %d\n', numel(golden));
    fprintf('RTL outputs    = %d\n', numel(rtl));


    if numel(rtl) ~= numel(golden)

        fprintf('FAIL: Output count mismatch.\n');

    else

        bad = find(rtl(:) ~= golden(:));


        fprintf('Mismatches = %d\n', numel(bad));


        if isempty(bad)

            fprintf('\nPASS: RTL exactly matches MATLAB Golden Model.\n');

        else

            fprintf('\nFAIL: RTL does not match MATLAB Golden Model.\n');

            fprintf('\nFirst mismatches:\n');


            for k = 1:min(10,numel(bad))

                i = bad(k);

                row = floor((i-1)/OUT_W) + 1;

                col = mod(i-1,OUT_W) + 1;


                fprintf( ...
                    'Index=%d  Row=%d  Col=%d  Golden=%d  RTL=%d\n', ...
                    i, row, col, golden(i), rtl(i));

            end

        end

    end

else

    fprintf('No rtl_output.mem found.\n');
    fprintf('Golden files were generated successfully.\n');

end


%% DONE

fprintf('\n============================================\n');
fprintf('DONE\n');
fprintf('============================================\n');

fprintf('Generated folder: %s\n', OUT_DIR);

fprintf('\nFiles generated:\n');

fprintf('input_image.mem\n');
fprintf('kernel_selected.mem\n');
fprintf('kernel_rom.mem\n');
fprintf('golden_output_raw.mem\n');
fprintf('golden_output_display.mem\n');
fprintf('golden_output_raw_decimal.txt\n');
fprintf('test_config.txt\n');
fprintf('filter_list.txt\n');

fprintf('\n');


end


%% ================================================================
% FUNCTION 1
% Kernel Bank
% ================================================================

function [bank,names] = get_kernel_bank()

% =========================================================
% KERNEL NAMES
% =========================================================

names = { ...
    'identity', ...
    'edge_h', ...
    'edge_v', ...
    'sharpen', ...
    'blur', ...
    'custom_edge', ...
    'emboss', ...
    'bottom_sobel', ...
    'outline'};

% Filter 0 - Identity

bank(:,:,1) = int64([ ...
     0  0  0;
     0  1  0;
     0  0  0]);


% Filter 1 - Horizontal Edge

bank(:,:,2) = int64([ ...
    -1 -1 -1;
     0  0  0;
     1  1  1]);


% Filter 2 - Vertical Edge

bank(:,:,3) = int64([ ...
    -1  0  1;
    -1  0  1;
    -1  0  1]);


% Filter 3 - Sharpen

bank(:,:,4) = int64([ ...
     0 -1  0;
    -1  5 -1;
     0 -1  0]);


% Filter 4 - Blur

bank(:,:,5) = int64([ ...
     1  1  1;
     1  1  1;
     1  1  1]);


% Filter 5 - Custom Edge

bank(:,:,6) = int64([ ...
     1  2  1;
     0  0  0;
    -1 -2 -1]);

% Filter 6 - emboss
bank(:,:,7) = int64([ ...
    -2  -1   0;
    -1   1   1;
     0   1   2 ]);


% Filter 7 - bottom_sobel
bank(:,:,8) = int64([ ...
    -1  -2  -1;
     0   0   0;
     1   2   1 ]);


% Filter 8 - outline
bank(:,:,9) = int64([ ...
    -1  -1  -1;
    -1   8  -1;
    -1  -1  -1 ]);




end


%% ================================================================
% FUNCTION 2
% 3x3 Convolution
% ================================================================

function [raw,display] = ...
    conv2d_golden(img,kernel,stride,padding)


if ~strcmpi(padding,'VALID')

    error('Only VALID padding is supported.');

end


[H,W] = size(img);


if H ~= 16 || W ~= 16

    error('Input image must be 16x16.');

end


if size(kernel,1) ~= 3 || ...
   size(kernel,2) ~= 3

    error('Kernel must be 3x3.');

end


% VALID convolution with 3x3 kernel and stride 1

OH = floor((H-3)/stride) + 1;
OW = floor((W-3)/stride) + 1;


raw = zeros(OH,OW,'int64');


for r = 1:OH

    for c = 1:OW


        % Starting position of current window

        rr = (r-1)*stride + 1;
        cc = (c-1)*stride + 1;


        acc = int64(0);


        % 3x3 sliding window

        for kr = 1:3

            for kc = 1:3


                pixel = int64( ...
                    img(rr+kr-1,cc+kc-1));


                coeff = int64(kernel(kr,kc));


                acc = acc + pixel * coeff;


            end

        end


        raw(r,c) = acc;


    end

end


% Saturation for 8-bit display

display = uint8(min(max(raw,0),255));


end


%% ================================================================
% FUNCTION 3
% Write unsigned HEX memory file
% ================================================================

function write_hex_mem(v,file,bits)


vec = row_major_vector(v);

mask = uint64(2^bits - 1);

digits = ceil(bits/4);


fid = fopen(file,'w');


if fid == -1
    error('Cannot create file: %s',file);
end


for i = 1:length(vec)

    value = uint64(vec(i));

    value = bitand(value,mask);

    fprintf(fid,'%0*X\n',digits,value);

end


fclose(fid);


end


%% ================================================================
% FUNCTION 4
% Write signed two's complement HEX
% ================================================================

function write_signed_hex_mem(v,file,bits)


vec = row_major_vector(v);

modulus = int64(2^bits);

digits = ceil(bits/4);


fid = fopen(file,'w');


if fid == -1
    error('Cannot create file: %s',file);
end


for i = 1:length(vec)

    value = mod(int64(vec(i)),modulus);

    fprintf(fid,'%0*X\n', ...
        digits,uint64(value));

end


fclose(fid);


end


%% ================================================================
% FUNCTION 5
% Write Kernel ROM
% ================================================================

function write_kernel_bank_mem(bank,file,bits)


modulus = int64(2^bits);

digits = ceil(bits/4);


fid = fopen(file,'w');


if fid == -1
    error('Cannot create file: %s',file);
end


num_filters = size(bank,3);


for f = 1:num_filters


    for r = 1:3

        for c = 1:3


            value = mod( ...
                int64(bank(r,c,f)), ...
                modulus);


            fprintf(fid,'%0*X\n', ...
                digits,uint64(value));


        end

    end


end


fclose(fid);


end


%% ================================================================
% FUNCTION 6
% Write decimal file
% ================================================================

function write_decimal_mem(v,file)


vec = row_major_vector(v);


fid = fopen(file,'w');


if fid == -1
    error('Cannot create file: %s',file);
end


for i = 1:length(vec)

    fprintf(fid,'%d\n',int64(vec(i)));

end


fclose(fid);


end


%% ================================================================
% FUNCTION 7
% Read RTL output
% ================================================================

function v = read_rtl_mem(file,bits)


fid = fopen(file,'r');


if fid == -1
    error('Cannot open RTL file: %s',file);
end


data = textscan(fid,'%s');

fclose(fid);


tokens = data{1};


v = zeros(length(tokens),1,'int64');


modulus = uint64(2^bits);

sign_limit = uint64(2^(bits-1));


for i = 1:length(tokens)


    token = strtrim(tokens{i});


    % Remove 0x if present

    if length(token) >= 2

        if token(1) == '0' && ...
           (token(2) == 'x' || token(2) == 'X')

            token = token(3:end);

        end

    end


    value = uint64(hex2dec(token));


    % Convert two's complement to signed

    if value >= sign_limit

        v(i) = int64(value) - int64(modulus);

    else

        v(i) = int64(value);

    end


end


end


%% ================================================================
% FUNCTION 8
% Convert matrix to ROW-MAJOR vector
% ================================================================

function vec = row_major_vector(matrix)


if isvector(matrix)

    vec = matrix(:);

else

    temp = matrix.';

    vec = temp(:);

end


end