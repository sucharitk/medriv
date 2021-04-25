function trials = trialTimingParams(sp, trials, scanNum)
%
% function eYe = trialTimingParams(sp, eYe);
%
% SK 10/13: Wrote it
%

if isfield(sp, 'trialDuration')
    trials.trialTimeStamps = 0:sp.trialDuration(end):sp.scanDuration;
else
    trials.trialTimeStamps = [0 sp.scanDuration(scanNum)];
end

trials.initTrials = trials.trialTimeStamps;

trials.nTrials = length(trials.trialTimeStamps);

trials.curTrial = 1;

trials.firstTrial = true;

trials.alphaBlend = sp.conditions(scanNum);
disp(sp.contrastIncs(sp.conditions(scanNum)))

end