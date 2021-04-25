function sp = setupStimulusParams(conditions, eegMode, initials)
%
% function sp = setupStimulusParams(paramSet);
%
% Specifies the parameters for the stimulus
% Multiple set of parameters can be specified (e.g., for psychophysics,
% scanning etc.) by calling the 'paramSet' variable
%
% Katyal, 10/13: Wrote it
%

if ~exist('paramSet', 'var')
    sp.paramSet = 1;
else
    sp.paramSet = paramSet;
end

if ~exist('initials', 'var')
    sp.initials = input('Subject initials: ', 's');
else
    sp.initials = initials;
end

sp.eegMode = eegMode;
sp.feedback = false;

sp.frate = 60;
sp.adjustFixation = -30; % in degrees, if positive move the fixation and the entire stimulus inwards

% Paramters specific to a stimulus profile

% For initial rivalry practice short and without flicker

% Binocular stimulus stepwise becomes a monocular one blocked for
% SSVEP experiment
spatialFrequency = 1.8;

sp.fixDotSize = 0.2;
sp.fixDotColour = [0 0 255 255];

sp.conditions = conditions;
sp.eccentricity = [.5 2.2]; % Annulus eccentricity of the stimulus
sp.gauss_sigma = 1.5;
sp.grat_type = 'square';

sp.fixationLength = 0.3; % in degrees
sp.fixationColor = 200;
sp.fixationLineWidth = 0.08;

sp.frameType = 'square';
sp.frameLength = [5 6];
sp.frameColor = [0 0 255; 20 200 20];
sp.frameLineWidth = 0.25;

% Left Eye Stimulus Parameters
sp.left.type = 2; % 1. Grating annulus, 2. Grating annulus with smooth edges
sp.left.spatialFrequency = spatialFrequency; % in cycles/degree
sp.left.orientation = -45; % in degrees from the vertical
sp.left.contrast = .9;
sp.left.colour = [0 1 .25];
%         sp.left.colour = [];
%sp.left.flickerRate =  sp.frate/20; % in Hz
%         sp.left.flickerRate =  sp.frate/10; % in Hz
sp.left.flickerRate =  [0 0 sp.frate/8 sp.frate/10]; % in Hz
sp.left.rotationSpeed = 00; % in degrees/sec
sp.left.fixationCross = [1 1 1 1]; % Lines at Up-Right-0-0 - number specifies the length of the segment in degrees


% Right Eye Stimulus Parameters
sp.right.type = 2; % Grating
sp.right.spatialFrequency = spatialFrequency; % in cycles/degree
sp.right.orientation = 45; % in degrees from the vertical
sp.right.contrast = .9;
sp.right.colour = [1 0 1];
%         sp.right.colour = [];
%sp.right.flickerRate = sp.frate/12; % in Hz
%         sp.right.flickerRate =  sp.frate/8; % in Hz
sp.right.flickerRate =  [0 0 sp.frate/10 sp.frate/8]; % in Hz
sp.right.rotationSpeed = -0; % in degrees/sec
sp.right.fixationCross = [1 1 1 1]; % Lines at 0-0-Down-Left

sp.orientation = [sp.left.orientation sp.right.orientation];
sp.gratPhase = 2*pi*rand(1, 2);

sp.contrastIncs = [0 1];
sp.nContrastSteps = length(sp.contrastIncs); % Number of contrast steps
%         sp.propNoChange = 0;
% Overall timing parameters
sp.numberScans = length(conditions);
sp.stimDuration = [30 80 80 80]; % Display first grating, variable switch time, display second grating
% sp.trialDuration = sp.stimDuration; % in seconds - duration of a single block
% sp.numTrials = 1;
sp.scanDuration = sp.stimDuration; % in seconds



end