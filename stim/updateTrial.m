function trial = updateTrial(sp, trial, currentTime)
%
% function sp = updateTrial(sp, eYe, currentTime)
%
% Called at the beginning of a new trial
%

trial.curTrial = trial.curTrial + 1;

trial.trialStartTime = currentTime;

end