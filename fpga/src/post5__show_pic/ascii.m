clc;
clear;
close all;
warning off;

for i = 0 : 127
    filename = strcat(strcat('32_32_character_gen\ascii\', int2str(i)), '.png');
    img_single = imread(filename);
    for i_ = 1 : 32
        for j_ = 1 : 16
            for k_ = 1 : 3
                img(i_ + i * 32, j_, k_) = img_single(i_, j_, k_);
            end
        end
    end
end

fid = fopen('ascii.mi','wt');
fprintf(fid,'#File_format=Bin\n');
fprintf(fid,'#Address_depth=65536\n');
fprintf(fid,'#Data_width=1\n');

for i = 1 : 4096
    for j = 1 : 16
        if img(i, j, 1) + img(i, j, 2) + img(i, j, 3) >= 250
            img(i, j, 1) = 0;
            img(i, j, 2) = 0;
            img(i, j, 3) = 0;
            fprintf(fid,'0\n');
        else
            img(i, j, 1) = 255;
            img(i, j, 2) = 255;
            img(i, j, 3) = 255;
            fprintf(fid,'1\n');
        end
    end
end

imshow(img);