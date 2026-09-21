function [bank, names] = get_kernel_bank()
% Returns the fixed 3x3 filter bank used by the Golden Model.

names = ["identity", "edge_h", "edge_v", "sharpen", "blur", "custom_edge","emboss","bottom_sobel","outline"];

bank = zeros(3, 3, 6, "int64");

bank(:,:,1) = [ 0  0  0;
                0  1  0;
                0  0  0 ];

bank(:,:,2) = [-1 -1 -1;
                0  0  0;
                1  1  1 ];

bank(:,:,3) = [-1  0  1;
               -1  0  1;
               -1  0  1 ];

bank(:,:,4) = [ 0 -1  0;
               -1  5 -1;
                0 -1  0 ];

bank(:,:,5) = [1 1 1;
               1 1 1;
               1 1 1];

bank(:,:,6) = [ 1  2  1;
                0  0  0;
               -1 -2 -1 ];

bank(:,:,7) = int64([ ...
    -2  -1   0;
    -1   1   1;
     0   1   2 ]);

bank(:,:,8) = int64([ ...
    -1  -2  -1;
     0   0   0;
     1   2   1 ]);

bank(:,:,9) = int64([ ...
    -1  -1  -1;
    -1   8  -1;
    -1  -1  -1 ]);

end
