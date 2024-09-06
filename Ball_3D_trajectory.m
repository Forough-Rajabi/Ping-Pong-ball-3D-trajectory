close all
clear all
clc

%% Load Calibration Parameters, videos and, ball locations
params_a59 = load("calibration/params/a59.mat");
params_a70 = load("calibration/params/a70.mat");
params_iphonx = load("calibration/params/iphonx.mat");
%params_promax = load("calibration/params/promax.mat");

vid_a59 = VideoReader('videos/a59.mp4');
vid_a70 = VideoReader('videos/a70.mp4');
vid_iphonx = VideoReader('videos/iphonx.mp4');
%v_promax = VideoReader('videos/promax.mp4');

% For simplicity, assume ballLocations for each frame are in separate MAT files
BallLoc_a59 = load("results/ballLocations-a59.mat");
BallLoc_a70 = load("results/ballLocations-a70.mat");
BallLoc_iphonx = load("results/ballLocations-iphonx.mat");



%% Setup for Processing
poses = table;
poses.ViewId = uint32([1; 2; 3]);
poses.Orientation = {params_a59.orientation; params_a70.orientation; params_iphonx.orientation};
poses.Location = {params_a59.location; params_a70.location; params_iphonx.location};
intrinsics = [params_a59.intrinsics, params_a70.intrinsics, params_iphonx.intrinsics];


wp_x_bound = [0, 1.525];
wp_y_bound = [0, 2.74];
re_thresh = 45;

%% Plot Results
field_fig = figure('Position', [10 10 1000 1000]);
figure(field_fig);
hold on;
pcshow([0 0 0.76], 'red','VerticalAxisDir', 'up', 'MarkerSize', 5);


frameNum = 1;
while frameNum <= 82 %with respect to the size of the min{BallLoc1,BallLoc2,BallLoc3}
   
    BallLoc1 = BallLoc_a59.ballLocations(frameNum, :);
    BallLoc2 = BallLoc_a70.ballLocations(frameNum,:);
    BallLoc3 = BallLoc_iphonx.ballLocations(frameNum,:);
    
    %% Triangulate Points
    % Create pointTrack objects for triangulation
   for b1 = 1:size(BallLoc1, 1)
        for b2 = size(BallLoc2, 1)
            for b3 = size(BallLoc3, 1)
                p1 = BallLoc1(b1, :);
                p2 = BallLoc2(b2, :);
                p3 = BallLoc3(b3, :);
    
                track = pointTrack([1; 2; 3], [p1; p2; p3]);
                [wp, re] = triangulateMultiview(track, poses, intrinsics);
                
                % Plot the triangulated points
               if re < re_thresh && wp(1) >= wp_x_bound(1) && wp(1) <= wp_x_bound(2) && ...
                   wp(2) >= wp_y_bound(1) && wp(2) <= wp_y_bound(2)
                   plot3(wp(1), wp(2), wp(3),'.', 'MarkerSize', 10, 'Color', 'red');
                   hold on;
               end
            
            end
        end
   end
   frameNum = frameNum +1;
    
end



plotCamera('Location', params_a59.location, 'Orientation', params_a59.orientation, 'Size', 0.1, 'Color', [1,1,0]);
plotCamera('Location', params_a70.location, 'Orientation', params_a70.orientation, 'Size', 0.1, 'Color', [0,1,1]);
plotCamera('Location', params_iphonx.location, 'Orientation', params_iphonx.orientation, 'Size', 0.1, 'Color', [1,0,1]);
%plotCamera('Location', params_promax.location, 'Orientation', params_promax.orientation, 'Size', 0.1, 'Color', [0,0,0]);

pong_table = [
%   x1     y1      z1      x2       y2      z2       
    0      0       0.76    0        2.74    0.76; % Bottom edge (width: 2.74m)
    1.525  1.37    0.76    1.525    2.74    0.76; % Right edge (length: 1.525m)
    1.525  1.525   0.76    1.525    0       0.76; % Top edge
    1.525  0       0.76    0        0       0.76; % Left edge
    0      1.37    0.76    1.525    1.37    0.76; % Centerline (divides table into two halves)
    0      0       0.76    0        0       0.76; % Left edge (height of the table, z=0.76m)
    0      2.74    0.76    0        2.74    0.76; % Right edge (height of the table, z=0.76m)
    1.525  0       0.76    1.525    0       0.76; % Top edge (height of the table, z=0.76m)
    1.525  2.74    0.76    0        2.74    0.76; % Bottom edge (height of the table, z=0.76m)
];


for i = 1:size(pong_table, 1)
    x = [pong_table(i, 1), pong_table(i, 4)];
    y = [pong_table(i, 2), pong_table(i, 5)];
    z = [pong_table(i, 3), pong_table(i, 6)];
    plot3(x, y, z, 'k-', 'LineWidth', 2, 'Color','white');
end


set(gcf,'color','black');
set(gca,'color','black');
xlabel('X');
ylabel('Y');
zlabel('Z');

