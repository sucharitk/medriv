function drawFrame(ds, sp, eyeBuff, frameType, frameInd)
%
% function drawFrame(ds, sp, eyeBuff, frameType)
%

if ~exist('frameInd', 'var'), frameInd = 1; end

if exist('eyeBuff', 'var')
    Screen('SelectStereoDrawBuffer', ds.windowPtr, eyeBuff);
end

switch(frameType)
    case 1
        % Full square
        eyeAdjust = (.5-eyeBuff) * ds.adjustFixation;
        frameRect = [-1 -1 1 1] * ds.frameLength(frameInd)/2;
        frameRect = CenterRect(frameRect, ds.windowRect) + [eyeAdjust 0 eyeAdjust 0];
        Screen('FrameRect', ds.windowPtr, sp.frameColor(frameInd, :), frameRect, ...
            round(ds.frameLineWidth));
        
    case 2
        % Half square upper
        frameXY = [-1 -1, -1 1, 1  1;...
                    0  1,  1 1, 1  0] * ds.frameLength(frameInd)/2;
        Screen('DrawLines', ds.windowPtr, frameXY, round(ds.frameLineWidth), ...
            sp.frameColor(frameInd, :), ds.windowRect(3:4)/2, 1); % Line up
    
    case 3
        % Half square lower
        frameXY = [-1 -1, -1  1,  1  1;...
                    0 -1, -1 -1, -1  0] * ds.frameLength(frameInd)/2;
        Screen('DrawLines', ds.windowPtr, frameXY, round(ds.frameLineWidth), ...
            sp.frameColor(frameInd, :), ds.windowRect(3:4)/2, 1); % Line up
    
    case 4
        % Half square left
        frameXY = [0 -1, -1 -1, -1  0;...
                   1  1,  1 -1, -1 -1] * ds.frameLength(frameInd)/2;
        Screen('DrawLines', ds.windowPtr, frameXY, round(ds.frameLineWidth), ...
            sp.frameColor(frameInd, :), ds.windowRect(3:4)/2, 1); % Line up
        
    case 5
        % Half square right
        frameXY = [0  1,  1  1,  1  0;...
                   1  1,  1 -1, -1 -1] * ds.frameLength(frameInd)/2;
        Screen('DrawLines', ds.windowPtr, frameXY, round(ds.frameLineWidth), ...
            sp.frameColor(frameInd, :), ds.windowRect(3:4)/2, 1); % Line up
end
end