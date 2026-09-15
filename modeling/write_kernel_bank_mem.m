function write_kernel_bank_mem(bank, file, bits)
% Writes all 3x3 kernels consecutively, 9 coefficients per filter.

fid = fopen(file, "w");
assert(fid ~= -1, "Could not open %s for writing.", file);

modulus = int64(2^bits);
digits = ceil(bits / 4);
num_filters = size(bank, 3);

for f = 1:num_filters
    kernel = bank(:,:,f);
    for i = 1:9
        value = mod(int64(kernel(i)), modulus);
        fprintf(fid, "%0*X\n", digits, uint64(value));
    end
end

fclose(fid);
end
