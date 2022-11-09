clc;
clear;
close all;
warning off;
addpath 'func\'

M = 2;
N = 4;

load imgdata_uint0.mat
train_x = double(train_x);
train_x=BoundMirrorExpand(train_x);   %����
test_x = double(test_x);
test_x=BoundMirrorExpand(test_x);     %����
train_y = double(train_y);
test_y = double(test_y);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cnn.layers = {
    struct('type', 'i') %�����
    struct('type', 'c', 'outputmaps', M, 'kernelsize', 5) %�����
    struct('type', 's', 'scale', 2) %�ػ���
    struct('type', 'c', 'outputmaps', N, 'kernelsize', 5) %�����
    struct('type', 's', 'scale', 2) %�ػ���
};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opts.alpha = 0.01;
opts.batchsize = 2;
opts.numepochs = 1000;   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cnn = cnnsetup(cnn, train_x, train_y);
cnn = cnntrain(cnn, train_x, train_y, opts);
[er, bad,net,h,a] = cnntest(cnn, test_x, test_y);


%���ۺ�������ͼ��
figure; plot(net.rL);
 
save cnn2.mat cnn M N