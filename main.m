clear all
clc
close all

%% Create a video input object.
vid = videoinput("winvideo", 1, "YUY2_320x240");

%% To identify the target color
start(vid);
snapshot1 = ycbcr2rgb(getsnapshot(vid));
stop(vid);
figure(1);
imshow(snapshot1);
region = roipoly();
colorMask = snapshot1 .* uint8(region);  % Use integer operations directly
promColor = sum(reshape(colorMask, [], 3), 1) ./ sum(region(:));

% Set parameters for video input.
set(vid, 'FramesPerTrigger', 1);
set(vid, 'TriggerRepeat', Inf);
triggerconfig(vid, 'manual');

% Start the video input object.
start(vid);

% Create a figure window to display the live video.
figure;
hImage = image(zeros(240, 320, 3), 'CDataMapping', 'scaled'); % Initialize a blank image
axis image off; % Turn off axis
set(gca, 'unit', 'normalized', 'position', [0 0 1 1]); % Expand axis to fill figure

% Initialize the plot for the centroid with a dummy point
hold on;
hCentroid = plot(0, 0, 'ro'); % Initialize centroid marker
hold off;

% Keep running the loop until the figure is closed.
while ishandle(gcf)
    trigger(vid);
    snapshot1 = ycbcr2rgb(getsnapshot(vid));
    umbral = 30;
    diff = abs(double(snapshot1) - reshape(promColor, [1, 1, 3]));  % Broadcasting mean color across the image dimensions
    Mascara = all(diff < umbral, 3);

    [x, y] = find(Mascara);
    if ~isempty(x) && ~isempty(y)
        Cx = mean(x);
        Cy = mean(y);
        set(hCentroid, 'XData', Cy, 'YData', Cx); % Update centroid position
    end

    set(hImage, 'CData', snapshot1); % Update the image
    drawnow; % Update the figure window
end

%% Clean up: Stop the video input object and delete it to free hardware resources.
stop(vid);
delete(vid);
