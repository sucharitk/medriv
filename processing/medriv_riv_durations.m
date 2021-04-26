function [exp_medriv, indivdurs, indivruns] = medriv_riv_durations(exp_medriv)

% calculate the rivalry durations for each subject

cd(exp_medriv.session_dir)

nsubj = exp_medriv.nsubj;

rem_last = true; % remove the last duration because it is incomplete

for ns = 1:nsubj
    
    subj_data = exp_medriv.data(ns);
    
    if subj_data.subj_valid_riv
        cd(fullfile(exp_medriv.session_dir, subj_data.dir_name))
        
        % load the rivalry behaviour file
        fname = sprintf('BR_Rivalry_%g_%s', subj_data.subj_code,...
            subj_data.session_date);
        load(fullfile('Behavior', fname))
        
        if isempty(subj_data.riv_runs)
            riv_runs = {1:5, 6:10, 11:15};
        else
            % for subjects that had blocks within fewer than 5 runs
            riv_runs = subj_data.riv_runs;
        end
        
        nblocks = numel(riv_runs);
        numrivrun = 0;
        for nb = 1:nblocks
        
            %%% call function to calculate the individual rivalry duraitons for each block as a whole
            [dur_all, trans_times] = plot_rivalry_responses(results, riv_runs{nb},...
                [], 0, [], [], [], rem_last);
            
            exp_medriv.data(ns).riv_durations(nb).dur_all = dur_all;
            
            exp_medriv.data(ns).riv_durations(nb).medians = [median(dur_all{1}), ...
                median(dur_all{2}), median(dur_all{3})];
            
            exp_medriv.data(ns).riv_durations(nb).means = [mean(dur_all{1}), ...
                mean(dur_all{2}), mean(dur_all{3})];
            
            exp_medriv.data(ns).riv_durations(nb).eye_dominance = ...
                max(exp_medriv.data(ns).riv_durations(nb).means([1 2]))/...
                min(exp_medriv.data(ns).riv_durations(nb).means([1 2]));
            
            exp_medriv.data(ns).riv_durations(nb).median_all = median([dur_all{1}...
                dur_all{2}]);
            
            exp_medriv.data(ns).riv_durations(nb).mean_all = mean([dur_all{1},...
                dur_all{2}]);
            
            exp_medriv.data(ns).riv_durations(nb).median_all_3 = median([dur_all{1}...
                dur_all{2} dur_all{3}]);
            
            exp_medriv.data(ns).riv_durations(nb).mean_all_3 = mean([dur_all{1},...
                dur_all{2} dur_all{3}]);

            exp_medriv.data(ns).riv_durations(nb).numdur = [numel(dur_all{1}), ...
                numel(dur_all{2}), numel(dur_all{3})];
            
            exp_medriv.data(ns).riv_durations(nb);
            
            
            %%% calculate rivalry runs for each individual run within a block
            nrr = numel(riv_runs{nb});
            for numr = 1:nrr
                dur_all = plot_rivalry_responses(results, riv_runs{nb}(numr),...
                    [], 0, [], [], [], rem_last);
                
                numrivrun = numrivrun + 1;
                exp_medriv.data(ns).riv_run_durs(numrivrun).means = ...
                    [mean(dur_all{1}), mean(dur_all{2}), mean(dur_all{3})];
                exp_medriv.data(ns).riv_run_durs(numrivrun).mean_all = ...
                    mean([dur_all{1} dur_all{2}]);
                exp_medriv.data(ns).riv_run_durs(numrivrun).medians = ...
                    [median(dur_all{1}), median(dur_all{2}), median(dur_all{3})];
                exp_medriv.data(ns).riv_run_durs(numrivrun).median_all = ...
                    median([dur_all{1} dur_all{2}]);
            end
            
        end
    end
end

fprintf('durations saved!\n')

cd(exp_medriv.session_dir)

end
