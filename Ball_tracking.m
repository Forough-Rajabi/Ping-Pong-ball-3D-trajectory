close all;
clear;
clc;


% Setup
frameWidth = 852; %for reducing the size of the video
frameHeight = 480;

videoFile = 'videos/iphonx.mp4'; % Path to the video file
outputFile = 'results/tracked_ball.avi';

% Video reader and writer
video = VideoReader(videoFile);
videoWriter = VideoWriter(outputFile, 'Motion JPEG AVI');
videoWriter.FrameRate = 10;
open(videoWriter);

% Parameters for corner detection
maxCorners = 2;
qualityLevel = 0.6;
minDistance = 25;
blockSize = 9;

% Background subtractor
foregroundDetector = vision.ForegroundDetector('NumGaussians', 50,'LearningRate', 0.05);

% Structuring element for morphological operations
se = strel('square', 5); 

ballLocations = [];
frameCounter=0;
while hasFrame(video)
    frameCounter = frameCounter + 1;
    oframe = readFrame(video);
    oframe = imresize(oframe, [frameHeight, frameWidth]);

    % Apply background subtraction
    mask = foregroundDetector(oframe);

    % Morphological operation (Opening)
    frame = imopen(mask, se);

    
    % Convert frame to double and detect corners
    frame_double = double(frame);
    corners = detectMinEigenFeatures(frame_double,'MinQuality', qualityLevel,'FilterSize', blockSize);

    % Filter the detected corners based on distance and quality
    if ~isempty(corners) && corners.Count >= maxCorners
        strongestCorners = selectStrongest(corners, maxCorners);
        pos = strongestCorners.Location;
        x = pos(1, 1);
        y = pos(1, 2);
        % Store the location of the ball
        ballLocations = [ballLocations; x, y];
        oframe = insertShape(oframe, 'Circle', [x, y, 8], 'Color', ...
                                         [250, 0, 0], 'LineWidth', 2);

    end

    % Display the tracking result
    imshow(oframe);

    % Write frame to the output video
    writeVideo(videoWriter, oframe);

    % Break on key press ('q' or ESC)
    if ~isempty(get(gcf, 'CurrentCharacter'))
        key = get(gcf, 'CurrentCharacter');
        if key == 'q' || key == char(27)
            break;
        end
    end
    pause(0.03); % Simulate cv2.waitKey(30)

end

% Release the video writer
close(videoWriter);

% Save the ball locations to a file
%save('ballLocations-a70.mat', 'ballLocations');
