fid = fopen('ROM_letter_show_init_hex.txt');
allText = textscan(fid,'%s','delimiter','\n');
allText = allText{1,1};
fid = fopen('ROM_letter_show_init_bin.txt','wt');


for i = 1 : 128
    str = allText{i};
    for j = 1 : 32
        if str(j) == '0'
            fprintf(fid,'0\n0\n0\n0\n');
        elseif str(j) == '1'
            fprintf(fid,'0\n0\n0\n1\n');
        elseif str(j) == '2'
            fprintf(fid,'0\n0\n1\n0\n');
        elseif str(j) == '3'
            fprintf(fid,'0\n0\n1\n1\n');
        elseif str(j) == '4'
            fprintf(fid,'0\n1\n0\n0\n');
        elseif str(j) == '5'
            fprintf(fid,'0\n1\n0\n1\n');
        elseif str(j) == '6'
            fprintf(fid,'0\n1\n1\n0\n');
        elseif str(j) == '7'
            fprintf(fid,'0\n1\n1\n1\n');
        elseif str(j) == '8'
            fprintf(fid,'1\n0\n0\n0\n');
        elseif str(j) == '9'
            fprintf(fid,'1\n0\n0\n1\n');
        elseif str(j) == 'A'
            fprintf(fid,'1\n0\n1\n0\n');
        elseif str(j) == 'B'
            fprintf(fid,'1\n0\n1\n1\n');
        elseif str(j) == 'C'
            fprintf(fid,'1\n1\n0\n0\n');
        elseif str(j) == 'D'
            fprintf(fid,'1\n1\n0\n1\n');
        elseif str(j) == 'E'
            fprintf(fid,'1\n1\n1\n0\n');
        elseif str(j) == 'F'
            fprintf(fid,'1\n1\n1\n1\n');
        end
    end
end