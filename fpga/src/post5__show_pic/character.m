clc;
clear;
close all;
warning off;

img_money = imread('32_32_character_gen\character\39.png');
img_money = imresize(img_money, [32, 16]);

for i = 0 : 7
    for j = 0 : 3
        index = i * 5 + j;
        index_ = i * 4 + j;
        filename = strcat(strcat('32_32_character_gen\character\', int2str(index)), '.png');
        img_single = imread(filename);
        if j >= 0 && j <= 2
            for i_ = 1 : 32
                for j_ = 1 : 32
                    for k_ = 1 : 3
                        img(i_ + index_ * 32, j_, k_) = img_single(i_, j_, k_);
                    end
                end
            end
        elseif j == 3
            img_tmp = cat(2, img_money, img_single(1:32, 1:16, 1:3));
            for i_ = 1 : 32
                for j_ = 1 : 32
                    for k_ = 1 : 3
                        img(i_ + index_ * 32, j_, k_) = img_tmp(i_, j_, k_);
                    end
                end
            end
        end  
    end
end

fid = fopen('character.mi','wt');
fprintf(fid,'#File_format=Bin\n');
fprintf(fid,'#Address_depth=32768\n');
fprintf(fid,'#Data_width=1\n');

for i = 1 : 1024
    for j = 1 : 32
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