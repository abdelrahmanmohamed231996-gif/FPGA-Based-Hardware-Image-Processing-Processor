function v = read_rtl_mem(file, bits)
% Reads decimal or hexadecimal signed values from an RTL output file.

fid = fopen(file, "r");
assert(fid ~= -1, "Could not open %s for reading.", file);

cells = textscan(fid, "%s");
fclose(fid);

cells = cells{1};
v = zeros(numel(cells), 1, "int64");

modulus = uint64(2^bits);
sign_limit = uint64(2^(bits - 1));

for i = 1:numel(cells)
    token = strtrim(cells{i});

    if startsWith(lower(token), "0x")
        token = token(3:end);
    end

    if ~isempty(regexp(token, "[A-Fa-f]", "once"))
        u = uint64(hex2dec(token));
        if u >= sign_limit
            v(i) = int64(u - modulus);
        else
            v(i) = int64(u);
        end
    else
        v(i) = int64(str2double(token));
    end
end
end
