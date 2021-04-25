function plotRivalry(fName, scans)
%
%
%

load(fName);

nscans = numel(scans);

figure
dur_all = cell(1, 3);
nsubs = ceil(sqrt(nscans));
for ns = 1:nscans
    hold on
    scan = scans(ns);
    psycho = results(scan).psycho;
    scan_dur = results(scan).params.scanDuration(ns);
    if ~isempty(psycho.responseKey)
        [tt, rr] = interp_to_next_response(psycho.tKeyPress, psycho.responseKey, ...
            0, scan_dur, 1000);
        [rdur, kt] = rivalry_duration(rr, tt, false, true);
        subplot(nsubs, nsubs, ns)
        plot(tt, rr)
        for kk2 = 1:numel(kt)
            kk = kt(kk2);
            dur_all{kk} = [dur_all{kk} rdur{kk2}];
        end
    end
end

figure
plot_cols = 'brg';
% for all runs
nhist = linspace(0, 10, 20);
for kk = 1:3
    hold on
    [nn, xx] = hist(dur_all{kk}, nhist);
    plot(xx, nn, [plot_cols(kk) '-o'], 'LineWidth', 2)
    sprintf('median duration for condition %g: %g', kk, ...
        median(dur_all{kk}))
end
[nn, xx] = hist([dur_all{1} dur_all{2}], nhist);
plot(xx, nn, 'k-*', 'LineWidth', 4)
sprintf('median duration for combined: %g', ...
    median([dur_all{1} dur_all{2}]))

end