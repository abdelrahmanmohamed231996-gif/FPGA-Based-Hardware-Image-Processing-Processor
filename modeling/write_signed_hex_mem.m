function write_signed_hex_mem(v, file, bits)
% Writes signed values using two's-complement hexadecimal representation.

v = int64(v(:));
modulus = int64(2^bits);
digits = ceil(bits / 4);

fid = fopen(file, "w");
assert(fid ~= -1, "Could not open %s for writing.", file);

for i = 1:numel(v)
    value = mod(v(i), modulus);
    fprintf(fid, "%0*X\n", digits, uint64(value));
end

fclose(fid);
end
