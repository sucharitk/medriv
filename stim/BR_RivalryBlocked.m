function [run_successful, ds, sp] = BR_RivalryBlocked(stereoMode, dispType, ...
    conditions, eegMode, initials, run_num, do_plot, port_handle2)
%
% function BR_MorphFusionRivalryBlocked(stereoMode, dispType);
%
% Flicker at different values of contrast
%
% paramSet: 3- Constrst discrimination experiment
% paramSet: 4- Rivalry experiment
% condSet: 1- Rivalry, 2- Monocular left, 3-Monocular right, 4-Fusion
%
% Katyal, 11/2013: Wrote it
% Katyal, 02/2014: Save scan start and end times
%

if ~exist('stereoMode', 'var'), stereoMode = 5; end
if ~exist('eegMode', 'var'), eegMode = false; end
if ~exist('do_plot', 'var'), do_plot = true; end

HideCursor;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Setup stimulus parameters %%%%
sp = setupStimulusParams(conditions, eegMode, initials);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

baseName = 'BR_Rivalry';

% Create feedback sounds:
% sound(sp.correctResponseSound)


%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Setup keyboard %%%%
kb = setupKeyboard;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Setup display parameters and open a PsychToolbox window %%%%
if ~exist('dispType', 'var'), dispType = 1; end
ds = setupDisplay(dispType, stereoMode, sp);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Create left and right eye textures %%%%
leftEye.curTextures = createTexture(sp, ds, 1); % 1 for left eye
rightEye.curTextures = createTexture(sp, ds, 2); % 2 for right eye
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if eegMode
    addpath('eeg_trig_funcs\')
    %     port_string = 'COM10';
    if ~exist('port_handle2', 'var')
        port_handle = open_port(eegMode);
    else
        port_handle = port_handle2;
    end
    event_num = [1 2 3 4]+100;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Initialize orientation for each eye %%%%
leftEye.orientation = sp.left.orientation;
rightEye.orientation = sp.right.orientation;

try
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% Beginning the scan loop %%%%
    for numScans = 1:sp.numberScans
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Put time stamps on to events %%%%
        % This may occur inside or outside the scan 'for' loop
        %         trials = trialTimingParams(sp, leftEye, numScans);
        curCond = conditions(numScans);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        [~, tt, keyCodeInt] = KbCheck(kb.int);
        [~, ~, keyCodeExt] = KbCheck(kb.ext);
        
        Screen('TextSize', ds.windowPtr, 35);
        if exist('run_num', 'var') && isnumeric(run_num)
            if numScans==1
                ss = sprintf('The next task involves reporting what you\nsee. ');
                ss = sprintf('%s Please look through the lenses and press\none of three following buttons:\n\n', ss);
                ss = sprintf('%s1) LEFT arrow when you see green+black lines.\n', ss);
                ss = sprintf('%s2) RIGHT arrow when you see magenta+black lines.\n', ss);
                ss = sprintf('%s3) DOWN arrow if you see green+black & \n  magenta+black lines mixed together.\n\n', ss);
                ss = sprintf('%sTo the best of your ability try to let the current\npercept continue for as long as you possibly can\n\n', ss);
                ss = sprintf('%sPress CTRL key when ready to start the task.', ss);
            else
                ss = sprintf('\nYou may take a pause for a few seconds.\n\n');
                ss = sprintf('%sWhen you are ready please press the CTRL\n', ss);
                ss = sprintf('%skey to continue with block %g/%g of the same\n', ss, numScans, sp.numberScans);
                ss = sprintf('%sperception reporting task.\n\n', ss);
                ss = sprintf('%sRemember to try to keep the current percept\ncontinue for as long as you possbily can.\n', ss);
            end
            
        else
            ss = sprintf('Rivaling gratings\n\n');
        end
        %         ss = [ss sprintf('\n\n\n\n\n\nPress ''<-'' if you see \\\\\\,')];
        %         ss = [ss sprintf('\n''->'' if you see ///,\nand ''down-arrow'' if\nyou see their mixture')];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Adjust Fusion %%%%
        while(~(keyCodeInt(kb.spaceKey) || keyCodeExt(kb.spaceKey)))
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Render the textures in curTextures %%%%
            if stereoMode
                %             renderTextures(ds, sp, 0); % 0 for left eye
                drawFixation(ds, sp, 1, 1, sp.fixDotColour); % Fixation should be drown right after renderTexture to put it on the correct buffer
                drawFrame(ds, sp, 1, 1, 1);
                %                 drawFrame(ds, sp, 1, 1, 2);
                DrawFormattedText(ds.windowPtr, ss, ds.windowRect(3)/2-400,...
                    ds.windowRect(4)/2+50);
                
                %             renderTextures(ds, sp, 1); % 1 for left eye
                drawFixation(ds, sp, 0, 1, sp.fixDotColour);
                drawFrame(ds, sp, 0, 1, 1);
                %                 drawFrame(ds, sp, 0, 1, 2);
            end
            
            [~, ~, keyCodeInt] = KbCheck(kb.int);
            [~, ~, keyCodeExt] = KbCheck(kb.ext);
            
            tt = Screen('Flip', ds.windowPtr);
        end
        
        scanStartTime = tt;
        currentTime = scanStartTime - tt;
        tKeyPress = [];
        responseKey = [];
        
        if eegMode
            % ----------------------------------------------
            % Trigger; Run begin, Event Code 11
            % ----------------------------------------------
            %%% send baseline start trigger
            write_port(port_handle, eegMode, event_num(1));

        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Stimulus presentation loop %%%%
        while(~(keyCodeInt(kb.escKey) || keyCodeExt(kb.escKey)) ...
                && currentTime <= sp.scanDuration(curCond))
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Render the textures in curTextures %%%%
            if stereoMode

                % Binocular rivalry
                if currentTime-scanStartTime <= sum(sp.stimDuration(curCond))
                    renderTextures(ds, sp, 0, rightEye, currentTime, 1, curCond);
                end
                drawFixation(ds, sp, 0, 1, sp.fixDotColour);
                drawFrame(ds, sp, 0, 1, 1);
                %                     drawFrame(ds, sp, 0, 1, 2);
                
                if currentTime-scanStartTime <= sum(sp.stimDuration(curCond))
                    renderTextures(ds, sp, 1, leftEye, currentTime, 1, curCond);
                end
                drawFixation(ds, sp, 1, 1, sp.fixDotColour); % Fixation should be drown right after renderTexture to put it on the correct buffer
                drawFrame(ds, sp, 1, 1, 1);
                %                     drawFrame(ds, sp, 1, 1, 2);
                %             end
            end
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Handle the responses from the keys %%%%
            [kIsDownExt, tkExt, keyCodeExt] = KbCheck(kb.ext);
            if kIsDownExt
                %             switch sp.paramSet
                %                 case 1
                if(keyCodeExt(kb.cwGrating) || keyCodeExt(kb.acwGrating)...
                        || keyCodeExt(kb.bothGratings))
                    tKeyPress = [tKeyPress tkExt-scanStartTime];
                    if keyCodeExt(kb.bothGratings)
                        responseKey = [responseKey 3];
                    elseif keyCodeExt(kb.cwGrating)
                        responseKey = [responseKey 1]; %#ok<*AGROW>
                    elseif keyCodeExt(kb.acwGrating)
                        responseKey = [responseKey 2];
                    end
                end
                %             end
            end
            
            currentTime = Screen('Flip', ds.windowPtr) - scanStartTime;
        end
                
        
        if(keyCodeInt(kb.escKey) || keyCodeExt(kb.escKey))
            % If we got here from an 'escape' keypress, then bail out
            run_successful = false;
            %             if eegMode
            %                 marker.mark(marker, 115+paramSet);
            %             end
            break;
        else
            run_successful = true;
            if eegMode
                %%% send baseline start trigger
                write_port(port_handle, eegMode, event_num(2));
            end
        end
        %         % If we got here from an 'escape' keypress, then bail out now:
        %         if keyCodeInt(kb.escKey)||keyCodeExt(kb.escKey), break, end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% Save the results %%%%
        if currentTime > sp.scanDuration(curCond)
            % Only if the stimulus completed the run duration
            psychPhys.tKeyPress = tKeyPress;
            psychPhys.responseKey = responseKey;
            psychPhys.scanStartTime = scanStartTime;
            psychPhys.scanEndTime = currentTime;
            sp.paramSet = conditions(numScans);
            [fScanNum(numScans), fName] = updateResults(baseName, psychPhys, sp);
        end
    end
    
    if isfield(ds, 'oldG'), Screen('LoadNormalizedGammaTable', ds.screenNum, ds.oldG); end
    ShowCursor;
    Screen('CloseAll');
    
    if do_plot && exist('fName', 'var')
        plotRivalry(fName, fScanNum)
    end
    
    if eegMode && ~exist('port_handle2', 'var')
        close_port(port_handle, eegMode)
    end
    
catch lasterr
    if isfield(ds, 'oldG'), Screen('LoadNormalizedGammaTable', ds.screenNum, ds.oldG); end
    ShowCursor;
    Screen('CloseAll');
    rethrow(lasterr)
end
end