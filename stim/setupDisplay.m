function ds = setupDisplay(dispType, stereoMode, sp)


AssertOpenGL;

Screen('Preference', 'SkipSyncTests', 1);

screenNum = max(Screen('Screens'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Select display type %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display 1 - HP LP2065 20.1-inch monitor
% Display 2 - MacBook Pro 13-inch
% Display 4 - ASUS VG248 (144 Hz monitor)

switch(dispType)
    case 1
        ds.SCREENXCM = 40.8; % Width of the screen
        ds.VIEWINGDISTANCE = 50; % Distance of the screen from the subjects' eyes
        %         screenNum = 0;
    case 2
        ds.SCREENXCM = 32.5; % Width of the screen
        ds.VIEWINGDISTANCE = 70; % Distance of the screen from the subjects' eyes
    case 3
        ds.SCREENXCM = 41; % Width of the screen
        ds.VIEWINGDISTANCE = 50; % Distance of the screen from the subjects' eyes
        %     case 4
        %         ds.SCREENXCM = 53.34; % Width of the screen
        %         ds.VIEWINGDISTANCE = 45; % Distance of the screen from the subjects' eyes
        %         screenNum = 0;
    case 4
        ds.SCREENXCM = 48; % Width of the screen
        ds.VIEWINGDISTANCE = 50; % Distance of the screen from the subjects' eyes
        %         screenNum = 2;
end


ds.black = BlackIndex(screenNum);
ds.white = WhiteIndex(screenNum);
ds.gray = floor((ds.black + ds.white)/2);
ds.bkg = ds.gray;
% ds.bkg = ds.black;


% Open an onscreen window
[ds.windowPtr, ds.windowRect] = Screen('OpenWindow', screenNum, ds.bkg, [], [], [], stereoMode);


% switch(dispType)
%     case 1
%         % Load Gamma Table
%         load('HP_LP2065_gogglesMacbook','gamInv');
%         ds.oldG = Screen('LoadNormalizedGammaTable', screenNum, gamInv);
%     case 4
%         % Load Gamma Table
%         load('calib-asus-vg248','gamInv');
%         ds.oldG = Screen('LoadNormalizedGammaTable', screenNum, gamInv);
% end

% Determine degree to pixel conversion factor
rad2Deg = 180/pi;
ds.SCREENXDEG = rad2Deg * 2*atan((ds.SCREENXCM/2)/ds.VIEWINGDISTANCE);
ds.PIXPERDEG = ds.windowRect(3)/ds.SCREENXDEG;
ds = convertParamsDeg2Pix(sp, ds);
ds.screenNum = screenNum;

% Frame rate
ds.frameRate = Screen('GetFlipInterval', ds.windowPtr);

Screen('BlendFunction', ds.windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

ds.t = Screen('Flip', ds.windowPtr);

end