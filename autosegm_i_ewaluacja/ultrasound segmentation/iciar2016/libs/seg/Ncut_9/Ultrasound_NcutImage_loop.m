function Ultrasound_NcutImage
% Ultrasound_NcutImage

% NcutImage credits: Timothee Cour, Stella Yu, Jianbo Shi, 2004.
addpath("E:\Pulpit\bus-segmentation-master\bus-segmentation-master\iciar2016\libs\pre\PPB(Best)2009_OK\ppbNakagami");
addpath("E:\Pulpit\bus-segmentation-master\bus-segmentation-master\iciar2016\libs\pre\DPAD2006_OK");

%% read image, change color image to brightness image, resize to 160x160

%I = imread_ncut('E:\Pulpit\magisterium\dicomvol2\2014_2014-03-25-08-35-37_1.dcm',160,160,30);

%dicom file directory
D = dicominfo('E:\Pulpit\magisterium\dicomvol2\2014_2014-03-25-08-35-37_1.dcm');
%https://www.mathworks.com/matlabcentral/answers/336333-how-to-extract-data-from-dicom-image-which-shows-a-echocardiogram
%collection = dicomCollection('E:\Pulpit\magisterium\dicomvol2\2014_2014-03-25-08-35-37_1.dcm');
%disp(D);


for i = 1 : D.NumberOfFrames
    I = imread_ncut('E:\Pulpit\magisterium\dicomvol2\2014_2014-03-25-08-35-37_1.dcm',160,160,i);
    imageCrop = imcrop(I,[14 26 125 100]); %crop do ramki detekcji dla resize 160x160
    %                      x1 y1 x2  y2
    %figure(i);
    %imshow(imageCrop,[]);
%     J = imnlmfilt(imageCrop) %Non-local means filtering of image

     %-DPAD
%     stepsize = 0.01;
%     nosteps = 200; % 10
%     wnSize = 17; % 5
%     img = dpad(img, stepsize, nosteps,'cnoise',5,'big',wnSize,'aja');
    J=dpad(imageCrop,0.2,100,'cnoise',5,'big',5,'aja');
    

    %J=ppb_nakagami(imageCrop, 1, 23, 7, 0.29, 0.2, 4); % i.e the NL-Means filter,
    %z 2012 roku, działa wolniej niż imnlmfilt
    %J=dpad(imageCrop, 0.01,200,'cnoise',5,'big',15,'aja');
    %-Frost filter
    %J = fcnFrostFilter(imageCrop,getnhood(strel('disk',5)));
%% display the image
figure(1);clf; imagesc(J);colormap(gray);axis off;
%disp('This is the input image to segment, press Enter to continue...');
%disp('This is the input image to segment');
%pause;

%% compute the edges imageEdges, the similarity matrix W based on
%% Intervening Contours, the Ncut eigenvectors and discrete segmentation
nbSegments = 4;
% disp('computing Ncut eigenvectors ...');
% tic;
[SegLabel,NcutDiscrete,NcutEigenvectors,NcutEigenvalues,W,imageEdges]= NcutImage(J,nbSegments);
% disp(['The computation took ' num2str(toc) ' seconds on the ' num2str(size(I,1)) 'x' num2str(size(I,2)) ' image']);


%% display the edges
figure(2);clf; imagesc(imageEdges); axis off
%disp('This is the edges computed, press Enter to continue...');
%disp('This is the edges computed')
%pause;

%% display the segmentation
figure(3);clf
bw = edge(SegLabel,0.01);
J1=showmask(J,imdilate(bw,ones(2,2))); imagesc(J1);axis off
%disp('This is the segmentation, press Enter to continue...');
%pause;
%disp('This is the segmentation');
%% display Ncut eigenvectors
figure(4);clf;set(gcf,'Position',[100,500,200*(nbSegments+1),200]);
[nr,nc,nb] = size(J);
for i=1:nbSegments
    subplot(1,nbSegments,i);
    imagesc(reshape(NcutEigenvectors(:,i) , nr,nc));axis('image');axis off;
end
%disp('This is the Ncut eigenvectors...');
%disp('Finished.');
end