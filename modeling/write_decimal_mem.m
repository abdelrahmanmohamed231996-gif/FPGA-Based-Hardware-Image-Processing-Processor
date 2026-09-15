function write_decimal_mem(v, file)
% Writes signed decimal values, one value per line.

fid = fopen(file, "w");
assert(fid ~= -1, "Could not open %s for writing.", file);
fprintf(fid, "%d\n", int64(v(:)));
fclose(fid);
end
