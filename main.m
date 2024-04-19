clear;
clc;
close all;

%% Create a video input object.
vid = videoinput("winvideo", 1, "YUY2_320x240");

%% To identify the target colortic
start(vid);
snapshot1 = ycbcr2rgb(getsnapshot(vid));
snapshot1 = rgb2hsv(snapshot1);  % Convert RGB to HSV
stop(vid);

% Get region of interest for target color
figure(1);
imshow(hsv2rgb(snapshot1));
region = roipoly();
colorMask = snapshot1 .* cat(3, region, region, region);  % Apply the region mask to each channel
promColor = sum(reshape(colorMask, [], 3), 1) ./ sum(region(:));  % Gets an average color
close(figure(1));  % Close the figure after selecting the region

% Set parameters for video input.
set(vid, 'FramesPerTrigger', 1);
set(vid, 'TriggerRepeat', Inf);
triggerconfig(vid, 'manual');

% Start the video input object.
start(vid);

% Create a figure window to display the live video and the mask
figure;
subplot(1,2,1); % Image subplot
hImage = image(zeros(240, 320, 3), 'CDataMapping', 'scaled'); % Initialize a blank image
axis image off; % Turn off axis
hold on;
hCentroidImage = plot(0, 0, 'ro'); % Initialize centroid marker for the image

subplot(1,2,2); % Mask subplot
hMask = imshow(false(240, 320)); % Initialize a blank logical image for the mask
axis image off; % Turn off axis
hold on;
hCentroidMask = plot(0, 0, 'ro'); % Initialize centroid marker for the mask

% Keep running the loop until the figure is closed.
while ishandle(gcf)
    trigger(vid);
    snapshot1 = ycbcr2rgb(getsnapshot(vid));
    snapshot1 = rgb2hsv(snapshot1);  % Convert RGB to HSV in the loop
    umbral = 0.1;  % Adjust threshold for HSV comparison
    diff = abs(snapshot1 - reshape(promColor, [1, 1, 3]));  % Broadcasting mean color
    Mascara = all(diff < umbral, 3);  % Change comparison logic for HSV

    [x, y] = find(Mascara);
    if ~isempty(x) && ~isempty(y)
        Cx = mean(x);
        Cy = mean(y);
        set(hCentroidImage, 'XData', Cy, 'YData', Cx); % Update centroid position in image
        set(hCentroidMask, 'XData', Cy, 'YData', Cx); % Update centroid position in mask
    end

    % Update the live video display
    set(hImage, 'CData', hsv2rgb(snapshot1)); % Convert back to RGB for display
    set(hMask, 'CData', Mascara); % Update the mask data
    drawnow; % Update the figure window
end

%% Clean up: Stop the video input object and delete it to free hardware resources.
stop(vid);
delete(vid);
