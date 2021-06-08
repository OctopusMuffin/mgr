net = importKerasNetwork('ŚCIEŻKA MODEL.h5');
img=imread('ŚCIEŻKA OBRAZ .JPG');
figure(1); imshow(img);

% img = dicomread('ŚCIEŻKA DO .DCM','frames',34);

img = imresize (img, [256 256]);

% figure(1)
% imshow(img)
% imwrite(img, 'slice.jpg', 'jpg')
% 
% readyImg = imread('slice.jpg');
% figure(2); imshow(readyImg);

img = im2double(img);

y = net.predict(img);
figure(3); imshow(y);

