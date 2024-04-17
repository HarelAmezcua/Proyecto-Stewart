clear;
clc;
close all;

%% Create a video input object.
vid = videoinput("winvideo", 1, "YUY2_320x240");

%% To identify the target color
start(vid);
snapshot1 = ycbcr2rgb(getsnapshot(vid));
stop(vid);

% Get region of interest for target color
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

% Create a figure window to display the live video and the mask
figure;
subplot(1,2,1); % Image subplot
hImage = image(zeros(240, 320, 3), 'CDataMapping', 'scaled'); % Initialize a blank image
axis image off; % Turn off axis
subplot(1,2,2); % Mask subplot
hMask = imshow(false(240, 320)); % Initialize a blank logical image for the mask
axis image off; % Turn off axis

% Keep running the loop until the figure is closed.
while ishandle(gcf)
    trigger(vid);
    snapshot1 = ycbcr2rgb(getsnapshot(vid));
    umbral = 30;
    diff = abs(double(snapshot1) - reshape(promColor, [1, 1, 3]));  % Broadcasting mean color across the image dimensions
    Mascara = all(diff < umbral, 3);

    % Update the live video display
    set(hImage, 'CData', snapshot1); % Update the image data
    set(hMask, 'CData', Mascara); % Update the mask data
    drawnow; % Update the figure window
end

%% Clean up: Stop the video input object and delete it to free hardware resources.
stop(vid);
delete(vid);
