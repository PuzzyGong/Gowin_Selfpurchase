clc;
clear;
close all;
warning off;
addpath 'func\'

tic
load cnn2.mat
load imgdata_uint0.mat

train_x = double(train_x);
for i_ = 0 : 4
    for j_ = 0 : 15
        I = train_x(:, :, i_ * 16 + j_ + 1);
        test_img = imresize(I, [32,32]);
        imshow(imresize(uint8(test_img), [256,256]));


%I          = imread('faces2\noface\1.jpg');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%第二层卷积结果
% figure(2),
for i=1:M
    for j=1:1
        first_conv(i). img=convn(test_img, cnn.layers{2}.k{j}{i}, 'valid')+cnn.layers{2}.b{i};
    end
%     subplot(2,3,i);imshow(first_conv(i).img);
end

% figure(3),
for i=1:M
    first_conv_sig(i).img=sigm(first_conv(i).img);
%     subplot(2,3,i); imshow(first_conv_sig(i).img);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%第三层池化结果
% figure(4),
for i = 1 : M
    sec_sub(i).img = convn(first_conv_sig(i).img, ones(cnn.layers{3}.scale) / (cnn.layers{3}.scale ^ 2), 'valid');   %  !! replace with variable
    sec_sub(i).img = sec_sub(i).img(1 : cnn.layers{3}.scale : end, 1 : cnn.layers{3}.scale : end);
%     subplot(2,3,i);imshow(sec_sub(i).img);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%第四层卷积层
% figure(5),
for j = 1 : N  
    thir_conv(j).img=zeros(size(sec_sub(1).img) - [cnn.layers{4}.kernelsize - 1 cnn.layers{4}.kernelsize - 1]);
    for i = 1 : M    
        thir_conv(j).img=thir_conv(j).img+convn(sec_sub(i).img, cnn.layers{4}.k{i}{j}, 'valid');        
    end
    thir_conv(j).img=thir_conv(j).img+cnn.layers{4}.b{j};
%     subplot(3,4,j);imshow(thir_conv(j).img);
end

% figure(6),
for i=1:N
    thir_conv_sig(i).img=sigm(thir_conv(i).img);
%     subplot(3,4,i); imshow(thir_conv_sig(i).img);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%第五层池化结果
% figure(7),
for i = 1 : N
    fifth_sub(i).img = convn(thir_conv_sig(i).img, ones(cnn.layers{5}.scale) / (cnn.layers{5}.scale ^ 2), 'valid');   %  !! replace with variable
    fifth_sub(i).img = fifth_sub(i).img(1 : cnn.layers{5}.scale : end, 1 : cnn.layers{5}.scale : end);
%     subplot(3,4,i);imshow(fifth_sub(i).img);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%第六层向量化结果
% figure(8),  
sixth_vector = [];
sa = size(fifth_sub(1).img);
for i = 1 : N   
    sixth_vector = [sixth_vector; reshape(fifth_sub(i).img, sa(1) * sa(2),1)];
end
% imshow(sixth_vector);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%输出向量
% figure(9), 
output = sigm(cnn.ffW * sixth_vector + cnn.ffb);

[~, h] = max(output);
% output
index = i_ * 16 + j_ + 1;
value = 0.5 + 0.5 * output(h);

if h == i_ + 1
   fprintf('%d, %f, True\n', index, value);
else
   fprintf('%d, %f, False\n', index, value);
end

    end
end
    
    