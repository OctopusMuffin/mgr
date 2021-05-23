function US_NcutImage;
% US_NcutImage
% 
% func for NcutImage
% Timothee Cour, Stella Yu, Jianbo Shi, 2004.

addpath("E:\Pulpit\bus-segmentation-master\bus-segmentation-master\iciar2016\libs\pre\DPAD2006_OK");

%% read image, change color image to brightness image, resize to 160x160
i=34; %choose slice number
I = imread_ncut('E:\Pulpit\magisterium\dicomvol2\2014_2014-03-25-08-35-37_1.dcm', 160, 160, i); %%dicom file directory
% I = imread_ncut('E:\Pulpit\magisterium\dicomvol2\2014_2014-03-25-08-35-37_1.dcm', 256, 256, i);
% lewo góra prawo dó³
% imageCrop = imcrop(I,[20 45 200 160]); %crop do ramki detekcji dla resize 256x256 Python
imageCrop = imcrop(I,[14 26 125 100]); %crop do ramki detekcji dla resize 160x160
%high-resolution ultrasound: Image size.......: 904 x 1208
%ultrasound BUS: width, height: 479 485
%imageCrop = imcrop(I,[21 35 110 90]); %medium crop dla resize 160x160 wg seam
%carving
% lewo góra prawo dó³
figure
imshow(imageCrop);
% %bit depth: 64-bit (8-byte) double-precision
%     J = imnlmfilt(imageCrop); %Non-local means filtering of image
     %-DPAD
%     stepsize = 0.01;
%     nosteps = 200; % 10
%     wnSize = 17; % 5
%     J = dpad(imageCrop, stepsize, nosteps,'cnoise',5,'big',wnSize,'aja');
    J=dpad(imageCrop,0.2,100,'cnoise',5,'big',5,'aja');
    
    %J=ppb_nakagami(imageCrop, 1, 23, 7, 0.29, 0.2, 4); % i.e the NL-Means filter,
    %z 2012 roku, dzia³a wolniej ni¿ imnlmfilt

     %-Frost filter
    %J = fcnFrostFilter(imageCrop,getnhood(strel('disk',5)));
%% display the image
figure(1);clf; imagesc(J);colormap(gray);axis off;
% disp('This is the input image to segment, press Enter to continue...');
% pause;

%% compute the edges imageEdges, the similarity matrix W based on
%% Intervening Contours, the Ncut eigenvectors and discrete segmentation
nbSegments = 4;
disp('computing Ncut eigenvectors ...');
tic;
[SegLabel,NcutDiscrete,NcutEigenvectors,NcutEigenvalues,W,imageEdges]= NcutImage(J,nbSegments);
disp(['The computation took ' num2str(toc) ' seconds on the ' num2str(size(imageCrop,1)) 'x' num2str(size(imageCrop,2)) ' image']);


%% display the edges
figure(2);clf; imagesc(imageEdges); axis off
% disp('This is the edges computed, press Enter to continue...');
% pause;

%% display the segmentation
figure(3);clf
bw = edge(SegLabel,0.01);
J1=showmask(J,imdilate(bw,ones(2,2))); imagesc(J1);axis off
% disp('This is the segmentation, press Enter to continue...');
% pause;

%% display Ncut eigenvectors
figure(4);clf;set(gcf,'Position',[100,500,200*(nbSegments+1),200]);
[nr,nc,nb] = size(J);
for i=1:nbSegments
    subplot(1,nbSegments,i);
    imagesc(reshape(NcutEigenvectors(:,i) , nr,nc));axis('image');axis off;
end
% disp('This is the Ncut eigenvectors...');
% disp('Finished.');
end