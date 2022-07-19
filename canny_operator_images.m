clear all;
close all;
clc;
infolder = 'D:\dataset\diaretdb1_v_1_1\resources\images\ddb1_fundusimages';  % give the path of the folder where your images are present 
outfolder = 'D:\dataset\segmented1';   % give the path of the folder where you want to save images 
imgFiles = dir([infolder,filesep,'\*.png']);
N = 89;   % total images in the folder 
for i = 1:N
    thisFile = [infolder,filesep,imgFiles(i).name] ;   % each image file 
    [filepath,name,ext] = fileparts(thisFile) ;  % get name of the image file and extension 
    outFile = [outfolder,filesep,[name,ext]] ;   % write image file on this name here
    I = imread(thisFile) ; % read image into
    I = imresize(I,[336 448]);
    I = rgb2gray(I);
    E = edge(I,'canny');
    new_image = bwareaopen(E,100);
    imwrite(new_image,outFile); 
end