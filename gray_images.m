clc
clear all
close all
infolder = 'D:\dataset\diaretdb1_v_1_1\resources\images\ddb1_fundusimages';  % give the path of the folder where your images are present 
outfolder = 'D:\dataset\output';   % give the path of the folder where you want to save images 
imgFiles = dir([infolder,filesep,'\*.png']) ;  % give extension of your images 
N = 89;   % total images in the foder 
for i = 1:N
    thisFile = [infolder,filesep,imgFiles(i).name] ;   % each image file 
    [filepath,name,ext] = fileparts(thisFile) ;  % get name of the image file and extension 
    outFile = [outfolder,filesep,[name,ext]] ;   % write image file on this name here 
    I = imread(thisFile) ; % read image into
    I = imresize(I,[512 512]);
    I = rgb2gray(I);
    imwrite(I,outFile) ;   % write the image in the said folder on the name 
end