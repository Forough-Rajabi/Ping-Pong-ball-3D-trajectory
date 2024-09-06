close all
clear all
clc

%%
params_a59 = load("calibration/params/a59.mat");
params_a70 = load("calibration/params/a70.mat");
params_iphonx = load("calibration/params/iphonx.mat");
%params_promax = load("calibration/params/promax.mat");

v_a59 = VideoReader('videos/a59.mp4');
v_a70 = VideoReader('videos/a70.mp4');
v_iphonx = VideoReader('videos/iphonx.mp4');
%v_promax = VideoReader('videos/promax.mp4');

%% matching points from different camera views

img_a59 = read(v_a59, 1);
figure(1); imshow(img_a59); hold on; [x, y] = getpts();
pts_a59 = [x, y];
img_a70 = read(v_a70, 1);
figure(2); imshow(img_a70); hold on; [x, y] = getpts();
pts_a70 = [x, y];
img_iphonx = read(v_iphonx, 1);
figure(3); imshow(img_iphonx); hold on; [x, y] = getpts();
pts_iphonx = [x, y];

%img_promax = read(v_promax, 1);
%figure(3); imshow(img_promax); hold on; [x, y] = getpts();
%pts_promax = [x, y];


%% triangulation

track = pointTrack([1; 2; 3], [pts_a59; pts_a70; pts_iphonx]);
poses = table;
poses.ViewId = uint32([1; 2; 3]);
poses.Orientation = {params_a59.orientation;params_a70.orientation; ...
                                        params_iphonx.orientation};
poses.Location = {params_a59.location;params_a70.location; ...
                                  params_iphonx.location};
intrinsics = [params_a59.intrinsics,params_a70.intrinsics, ...
                                params_iphonx.intrinsics];
[wp,re] = triangulateMultiview(track, poses, intrinsics);


%% plot

figure(4);
hold on;
pcshow([0 0 0.76],'red','VerticalAxisDir', 'up', 'MarkerSize', 5);


plotCamera('Location', params_a59.location, 'Orientation', params_a59.orientation, 'Size', 0.1, 'Color', [1,1,0]);
plotCamera('Location', params_a70.location, 'Orientation', params_a70.orientation, 'Size', 0.1, 'Color', [0,1,1]);
plotCamera('Location', params_iphonx.location, 'Orientation', params_iphonx.orientation, 'Size', 0.1, 'Color', [1,0,1]);
%plotCamera('Location', params_promax.location, 'Orientation', params_promax.orientation, 'Size', 0.1, 'Color', [0,0,0]);

%creating the table with standard size
pong_table = [
%   x1     y1      z1      x2       y2      z2       
    0      0       0.76    0       2.74    0.76;   % Bottom edge (width: 2.74m)
    1.525  1.37    0.76    1.525   2.74    0.76;   % Right edge (length: 1.525m)
    1.525  1.525   0.76    1.525   0       0.76;   % Top edge
    1.525  0       0.76    0       0       0.76;   % Left edge
    0      1.37    0.76    1.525   1.37    0.76;   % Centerline (divides table into two halves)
    0      0       0.76    0       0       0.76;   % Left edge (height of the table, z=0.76m)
    0      2.74    0.76    0       2.74    0.76;   % Right edge (height of the table, z=0.76m)
    1.525  0       0.76    1.525   0       0.76;   % Top edge (height of the table, z=0.76m)
    1.525  2.74    0.76    0       2.74    0.76;   % Bottom edge (height of the table, z=0.76m)
    0.762  0       0.76    0.762   2.74    0.76;
];

%ploting the table
for i = 1:size(pong_table, 1)
    x = [pong_table(i, 1), pong_table(i, 4)];
    y = [pong_table(i, 2), pong_table(i, 5)];
    z = [pong_table(i, 3), pong_table(i, 6)];
    plot3(x, y, z, 'k-', 'LineWidth', 2,'Color','white');
end

%ploting the triangulated point
plot3(wp(1), wp(2), wp(3), '.', 'MarkerSize', 30, 'Color', 'green');

set(gcf,'color','black');
set(gca,'color','black');
xlabel('X');
ylabel('Y');
zlabel('Z');

