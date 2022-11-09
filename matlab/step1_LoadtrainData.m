clc;
clear;
close all;
warning off;
addpath 'func\'

data = importdata('pic_process\vott-csv-export\Gowin_Selfpurchase-export.csv');
len = length(data.rowheaders);
num_1 = 0;
num_2 = 0; 
num_3 = 0; 
num_4 = 0; 
num_5 = 0; 
for i = 1 : len
    file_name = data.rowheaders(i);
    file_name = strcat('pic_process\vott-csv-export\', file_name{1,1});
    I_origin = imread(file_name);
    I = rgb2gray(I_origin);
    if data.data(i,5) == 1
        num_1 = num_1 + 1;
        train_x_1(:,:,num_1) = imresize(I(data.data(i,2):data.data(i,4), data.data(i,1):data.data(i,3)),[30,32]);
    elseif data.data(i,5) == 2
        num_2 = num_2 + 1;
        train_x_2(:,:,num_2) = imresize(I(data.data(i,2):data.data(i,4), data.data(i,1):data.data(i,3)),[30,32]);        
    elseif data.data(i,5) == 3
        num_3 = num_3 + 1;
        train_x_3(:,:,num_3) = imresize(I(data.data(i,2):data.data(i,4), data.data(i,1):data.data(i,3)),[30,32]);        
    elseif data.data(i,5) == 4
        num_4 = num_4 + 1;
        train_x_4(:,:,num_4) = imresize(I(data.data(i,2):data.data(i,4), data.data(i,1):data.data(i,3)),[30,32]);          
    elseif data.data(i,5) == 5
        num_5 = num_5 + 1;
        train_x_5(:,:,num_5) = imresize(I(data.data(i,2):data.data(i,4), data.data(i,1):data.data(i,3)),[30,32]);        
    end    
    
    if i >= 1 && i <= 5
        I = imresize(I_origin(data.data(i,2):data.data(i,4), data.data(i,1):data.data(i,3)),[32,32]);
        imshow(imresize(I, [256,256]));
        figure;
    end
end

train_x = cat(3, train_x_1, train_x_2);
train_x = cat(3, train_x, train_x_3);
train_x = cat(3, train_x, train_x_4);
train_x = cat(3, train_x, train_x_5);

for i = 1 : num_1
    train_y_1(:,i) = [ones(1,1); -1*ones(1,1); -1*ones(1,1); -1*ones(1,1); -1*ones(1,1)];
end
for i = 1 : num_2
    train_y_2(:,i) = [-1*ones(1,1); ones(1,1); -1*ones(1,1); -1*ones(1,1); -1*ones(1,1)];
end
for i = 1 : num_3
    train_y_3(:,i) = [-1*ones(1,1); -1*ones(1,1); ones(1,1); -1*ones(1,1); -1*ones(1,1)];
end
for i = 1 : num_4
    train_y_4(:,i) = [-1*ones(1,1); -1*ones(1,1); -1*ones(1,1); ones(1,1); -1*ones(1,1)];
end
for i = 1 : num_5
    train_y_5(:,i) = [-1*ones(1,1); -1*ones(1,1); -1*ones(1,1); -1*ones(1,1); ones(1,1)];
end

train_y = cat(2, train_y_1, train_y_2);
train_y = cat(2, train_y, train_y_3);
train_y = cat(2, train_y, train_y_4);
train_y = cat(2, train_y, train_y_5);

train_y = uint8(train_y);
test_x  = train_x;
test_y  = train_y;

save imgdata_uint0.mat train_x train_y test_x test_y
