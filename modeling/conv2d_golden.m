function [raw, display] = conv2d_golden(img, kernel, stride, padding)

    % Check padding
    if ~strcmpi(padding, 'VALID')
        error('Only VALID padding is supported.');
    end

    % Check input sizes
    [H, W] = size(img);
    [KH, KW] = size(kernel);

    if KH ~= 3 || KW ~= 3
        error('Kernel must be 3x3.');
    end

    % Output size
    OH = floor((H - KH) / stride) + 1;
    OW = floor((W - KW) / stride) + 1;

    raw = zeros(OH, OW, 'int64');

    % 2D convolution
    for r = 1:OH
        for c = 1:OW

            rr = (r-1) * stride + 1;
            cc = (c-1) * stride + 1;

            acc = int64(0);

            for kr = 1:3
                for kc = 1:3
                    acc = acc + ...
                        int64(img(rr + kr - 1, cc + kc - 1)) * ...
                        int64(kernel(kr, kc));
                end
            end

            raw(r,c) = acc;

        end
    end

    % Saturate to 8-bit for display
    display = uint8(min(max(raw, 0), 255));

end