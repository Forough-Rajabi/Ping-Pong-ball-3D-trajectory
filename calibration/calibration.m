close all
clear
clc

%% detect checkerboard points
num_images = 4;
imgs = imageDatastore('calibration/data/iphonx/*.jpg');
[imagePoints,boardSize,imagesUsed] = detectCheckerboardPoints(imgs.Files(1:num_images), 'MinCornerMetric', 0.3, 'PartialDetections', false);

for i = 1:num_images
  % Read image
  I = readimage(imgs, i);
  figure(i);
  % Insert markers at detected point locations
  I = insertMarker(I, imagePoints(:,:,i), '*', 'Color', 'green', 'Size', 7);

  imshow(I);
end

%% generate world points
squareSize = 0.0185; %squar size in mm
worldPoints = generateCheckerboardPoints(boardSize,squareSize);
[Params,imagesUsed,estimationErrors] = estimateCameraParameters(imagePoints,worldPoints);

%%

figure;
u = undistortImage(imread('calibration/data/iphonx/1.jpg'), Params);
imshow(u);
