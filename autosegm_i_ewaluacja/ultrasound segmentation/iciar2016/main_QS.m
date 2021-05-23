clc;close all;clear all; warning('off','all');
addpath(genpath('./Libs'));
run('E:\Pulpit\vlfeat-0.9.21-bin\vlfeat-0.9.21\toolbox\vl_setup');
%%
% NC-FR , NC-PPB_NoItr , NC-DPAD

method = 'NC-FILT';
inputPath = './data/Input/';
gtPath = './data/GT/';
outputPath = ['./results/' method '/'];
matPath = ['./mat/' method '.mat'];
fileList = getAllFiles(inputPath,'*.tif');
if exist(outputPath, 'dir')
    rmdir(outputPath,'s');
end
mkdir(outputPath);


for i=1:numel(fileList)
    file = fileList{i};
    [~,name,ext] = fileparts(file);
    disp(['File #' num2str(i) ' of ' num2str(numel(fileList)) ...
        ' Processing ... ' file]);
    
    img = im2double(imread(file));
    imgSize(i) = numel(img);
    figure('Visible', 'on'); imshow(img,[]);
    saveas(gcf,[outputPath name '_0Input.jpg']); close;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Preprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %-Adjust image intensity values
    img=rgb2gray(img)
    img = imadjust(img);
    figure('Visible', 'on'); imshow(img,[]);
    saveas(gcf,[outputPath name '_1Pre1.jpg']); close;
    
    %-Inverse pixel values of input image 
    img = imcomplement(img);
    figure('Visible', 'on'); imshow(img,[]); 
    saveas(gcf,[outputPath name '_1Pre2.jpg']); close;
    
    %%% Image smoothing process
    
    %-DPAD
    stepsize = 0.2;
    nosteps = 100;
    wnSize = 5;
    img_DPAD =  dpad(img, stepsize, nosteps,'cnoise',wnSize,'big',wnSize,'aja');
    
%     %-PPB_NoItr
%     L = 1;
%     hW = 23;
%     hD = 7;
%     alpha = 0.92;
%     T = 0.2;
%     nbit = 4;
%     img = ppb_nakagami(img, L, hW, hD, alpha, T, nbit);
    
%     %-Frost filter
%     M_Radius = 3;
%     img = fcnFrostFilter(img,getnhood(strel('disk',M_Radius)));
    
    figure('Visible', 'on'); imshow(img,[]); 
    saveas(gcf,[outputPath name '_1Pre3.jpg']); close;
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Segmentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %-Apply Quick Shift (QS) as segementation candidate 
    ratio = 0.8;
    kernelsize = 5;
    maxdist = 20;
    Iseg = vl_quickseg(img, ratio, kernelsize, maxdist);
    figure('Visible', 'on'); imshow(Iseg,[]); 
    saveas(gcf,[outputPath name '_2Seg.jpg']); close;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Postprocessing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %-Convert segemented (gray-scale) image into binary image by one-point
    %-thresholding using some scalar value after unit normalization
    IBW = (normalise(Iseg) >= 0.8);
    figure('Visible', 'on'); imshow(IBW,[]); 
    saveas(gcf,[outputPath name '_3Post1.jpg']); close;
    
    %-Remove boundary regions
    IBW = imclearborder(IBW);
    figure('Visible', 'on'); imshow(IBW,[]); 
    saveas(gcf,[outputPath name '_3Post2.jpg']); close;
    
    %-Select region with largest area
    stat=regionprops(IBW,'Area','PixelIdxList');
    [~,indMax] = max([stat.Area]);
    IBW2 = false(size(IBW));
    if(~isempty(indMax))
        IBW2(stat(indMax).PixelIdxList) = 1;
    end
    figure('Visible', 'on'); imshow(IBW2,[]); 
    saveas(gcf,[outputPath name '_3Post3.jpg']); close;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%% Results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %-Compute quantative and qualitative results
    
    outPost{i} = double(IBW2);
    gtFile{i}= double(imread([gtPath name '_maska' ext]));
    
    if max(max(gtFile{i}))==255
        gtFile{i} = gtFile{i}./255;
    end
    
    P = sum(sum(gtFile{i}));
    N = sum(sum(~gtFile{i}));
    
    conf_TP(i) = sum(sum(  gtFile{i}  &   outPost{i}));
    conf_FP(i) = sum(sum((~gtFile{i}) &   outPost{i}));
    conf_TN(i) = sum(sum((~gtFile{i}) & (~outPost{i})));
    conf_FN(i) = sum(sum(  gtFile{i}  & (~outPost{i})));

    statJAC(i) = conf_TP(i)/(conf_TP(i)+conf_FP(i)+conf_FN(i));
    
    OutComp = PlotAnnotations_General(gtFile{i},outPost{i});
    %figure('Visible', 'on'); imshow(OutComp,[]); 
    %saveas(gcf,[outputPath '_4Out.jpg']); close;
    
    
    
    disp("Jaccard: ");
    disp(statJAC(i));
    disp("Mean: ");
    avgJAC = mean(statJAC);
    disp(avgJAC);
end

avgJAC = mean(statJAC);
disp(avgJAC);
  
