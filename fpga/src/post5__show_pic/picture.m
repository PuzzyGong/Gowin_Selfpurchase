clc;
clear;
close all;
warning off;

fid = fopen('picture.mi','wt');
fprintf(fid,'#File_format=Bin\n');
fprintf(fid,'#Address_depth=131072\n');
fprintf(fid,'#Data_width=1\n');

%%
for i = 0 : 7
    filename = strcat(strcat('32_32_character_gen\title\', int2str(i)), '.png');
    img_single = imread(filename);
    for i_ = 1 : 64
        for j_ = 1 : 64
            for k_ = 1 : 3
                imgall(i_ + i * 64, j_, k_) = img_single(i_, j_, k_);
            end
        end
    end
end

for i = 1 : 512
    for j = 1 : 64
        if imgall(i, j, 1) + imgall(i, j, 2) + imgall(i, j, 3) >= 250
            imgall(i, j, 1) = 0;
            imgall(i, j, 2) = 0;
            imgall(i, j, 3) = 0;
            fprintf(fid,'0\n');
        else
            imgall(i, j, 1) = 255;
            imgall(i, j, 2) = 255;
            imgall(i, j, 3) = 255;
            fprintf(fid,'1\n');
        end
    end
end
imshow(imgall);

%%
filename = ['pic\free.jpg'; 'pic\get_.jpg'; 'pic\give.jpg'; 'pic\pay_.jpg'; 'pic\warn.jpg'; 'pic\free.jpg'];
for index = 1 : 6
    img = imread(filename(index, :));
    img = imresize(img, [128, 128]);
    for i = 1 : 128
        for j = 1 : 128
            if img(i, j, 1) <= 128
                img(i, j, 1) = 255;
                img(i, j, 2) = 255;
                img(i, j, 3) = 255;
            else
                img(i, j, 1) = 0;
                img(i, j, 2) = 0;
                img(i, j, 3) = 0;
            end
        end
    end

    for i_ = 1 : 128
        for j_ = 1 : 128
            for k_ = 1 : 3
                imgall(i_ + (index - 1) * 128, j_, k_) = img(i_, j_, k_);
            end
        end
    end
end

for i = 1 : 768
    for j = 1 : 128
        if imgall(i, j, 1) + imgall(i, j, 2) + imgall(i, j, 3) >= 250
            imgall(i, j, 1) = 0;
            imgall(i, j, 2) = 0;
            imgall(i, j, 3) = 0;
            fprintf(fid,'0\n');
        else
            imgall(i, j, 1) = 255;
            imgall(i, j, 2) = 255;
            imgall(i, j, 3) = 255;
            fprintf(fid,'1\n');
        end
    end
end
figure;
imshow(imgall);