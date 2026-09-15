function write_hex_mem(v, file, bits)
% Writes unsigned values as one hexadecimal value per line.

v = uint64(v(:));
mask = uint64(2^bits - 1);
digits = ceil(bits / 4);

fid = fopen(file, "w");
assert(fid ~= -1, "Could not open %s for writing.", file);

for i = 1:numel(v)
    fprintf(fid, "%0*X\n", digits, bitand(v(i), mask));
end

fclose(fid);
end
