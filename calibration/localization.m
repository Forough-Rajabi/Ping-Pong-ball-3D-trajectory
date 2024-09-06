%% Localization
close all
clear all
clc 


%{
% a59
P1 = [0 1.37];
P2 = [0.765 1.37];
P3 = [0.765 2.74];
P4 = [0 2.74];
%}

% iphonx
P1 = [0 1.37];
P2 = [0.765 1.37];
P3 = [0.765 2.74];
P4 = [0 2.74];
%}

%{
% a70
P1 = [0.765 0];
P2 = [1.53 0];
P3 = [1.53 1.37];
P4 = [0.765 1.37];
%}

%{
%promax
P1 = [0 1.37];
P2 = [1.53 1.37];
P3 = [1.53 2.74];
P4 = [0 2.74];
%}

%loading calibration parameters
params_promax = load("calibration/params/iphonx.mat");

%read the video
v = VideoReader('videos/iphonx.mp4');
frame = read(v, 1);

imshow(frame);

%%
hold on;
[x, y] = getpts();
hold off;

%computing extrinsics
[rotationMatrix,translationVector] = extrinsics([x y], [P1; P2; P3; P4], params_promax.intrinsics);

orientation = rotationMatrix'; 
location = -translationVector * orientation; %location of the camera

Params.ImageSize = size(frame, 1:2);