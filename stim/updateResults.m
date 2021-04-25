function [scanIndex, fName] = updateResults(baseName, pp, pa)

% function scanIndex = UpdateResults(baseName, stimParams, scanParams, ...
%   sequence, response, key);
%
% Create or update the results file (if this is a Mac).
%

if ~isfield(pa, 'initials'), pa.initials = ''; end

% Create results directory if necessary:
wDir = pwd;
if ~exist('Results', 'dir')
  ok = mkdir('Results');
  if ~ok
    disp('Problem creating Results directory');
    return
  end
end

% Next, make the file name from today's date and the base name input:
dstr = datestr(now, 'ddmmyy');
dataSumName = sprintf('%s_%s_%s', baseName, upper(pa.initials), dstr);
% Load the data file if it exists
fName = [fullfile(wDir, 'Results', dataSumName), '.mat'];
if exist(fName, 'file')
  load(fName);
end
if exist('results', 'var')
  scanIndex = scanIndex + 1;
  dispString = ['Data file ' dataSumName ' updated with scan #', num2str(scanIndex)];
else
  scanIndex = 1;
  disp(['Data file ' dataSumName ' not found or invalid.']);
  dispString = ['New data file ' dataSumName ' saved.'];
end
results(scanIndex).psycho = pp;
results(scanIndex).params = pa;
results(scanIndex).time = datestr(now);
save(fName, 'results', 'scanIndex');
disp(dispString);

