function drawFixation(ds, sp, eyeBuff, fixationType, fixDotColour)
%
% function drawFixation(ds, sp, eYe, fixationType);
%
% Draws a fixation mask specific to the left and right eyes defined by
% fixationType (1 = half crosses)
%

eyes = {'right', 'left'};
eYe = eyes{eyeBuff+1};

if exist('eyeBuff', 'var')
    Screen('SelectStereoDrawBuffer', ds.windowPtr, eyeBuff);
end

switch(fixationType)
    case 1
        % Fixation cross
        fixParamsEye = sp.(eYe).fixationCross;
        fixXY = [0 0, 0 fixParamsEye(2), 0 0, 0, -fixParamsEye(4);...
            0 fixParamsEye(1), 0 0, 0 -fixParamsEye(3), 0, 0] * ds.fixationLength;
        fixCenter = ds.windowRect(3:4)/2 + [(0.5-eyeBuff)*ds.adjustFixation 0];
        Screen('DrawLines', ds.windowPtr, fixXY, round(ds.fixationLineWidth), ...
            sp.fixationColor, fixCenter, 1); % Line up
        Screen('DrawDots', ds.windowPtr, [0; 0], ds.fixDotSize, fixDotColour, ...
            fixCenter, 2);
end
end