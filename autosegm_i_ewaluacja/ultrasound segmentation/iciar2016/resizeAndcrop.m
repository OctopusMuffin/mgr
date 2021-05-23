gtPath = './folder/';
fileList = getAllFiles(gtPath,'*.jpg');


for i=1:numel(fileList)
    file = fileList{i};
    [~,name,ext] = fileparts(file);
    x = imread(fileList{i});
    
    img = imresize(x,[160, 160]);
    imageCrop = imcrop(img,[14 26 125 100]);
    imshow(imageCrop) ;
    imwrite(imageCrop,[name ext]);
    close;
end