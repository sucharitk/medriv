function [exp_medriv, indivdurs, indivruns] = medriv_riv_durations(exp_medriv)

cd(exp_medriv.session_dir)

nsubj = exp_medriv.nsubj;

if nargout>1
    indiv_durs = [];
    indivdur_perc = [];
    indivdur_group = [];
    indivdur_block = [];
    indivdur_runnum = [];
    indivdur_subj = [];
    indivdur_valid = [];
    indivdur_eyedom = [];
end
rem_last = true; % remove the last duration because it is incomplete
for ns = 1:nsubj
    
    subj_data = exp_medriv.data(ns);
    
    if subj_data.subj_valid_riv
        cd(fullfile(exp_medriv.session_dir, subj_data.dir_name))
        
        % evaluate rivalry durations
        fname = sprintf('BR_Rivalry_%g_%s', subj_data.subj_code,...
            subj_data.session_date);
        load(fullfile('Behavior', fname))
        
        if isempty(subj_data.riv_runs)
            riv_runs = {1:5, 6:10, 11:15};
        else
            riv_runs = subj_data.riv_runs;
        end
        nblocks = numel(riv_runs);
        numrivrun = 0;
        for nb = 1:nblocks
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
                
                if nargout==2
                    ndurs = [numel(dur_all{1}) numel(dur_all{2}) ...
                        numel(dur_all{3})];
                    indiv_durs = [indiv_durs dur_all{1} dur_all{2} ...
                        dur_all{3}];
                    indivdur_perc = [indivdur_perc 1*ones(1, ndurs(1)), ...
                        2*ones(1, ndurs(2)), 3*ones(1, ndurs(3))];
                    indivdur_group = [indivdur_group ...
                        subj_data.group*ones(1, sum(ndurs))];
                    indivdur_block = [indivdur_block ...
                        nb*ones(1, sum(ndurs))];
                    indivdur_runnum = [indivdur_runnum  ...
                        numr*ones(1, sum(ndurs))];
                    indivdur_subj = [indivdur_subj  ...
                        subj_data.subj_code*ones(1, sum(ndurs))];
                    indivdur_valid = [indivdur_valid ...
                        subj_data.subj_valid_riv*ones(1, sum(ndurs))];
                    indivdur_eyedom = [indivdur_eyedom...
                        exp_medriv.data(ns).riv_durations(nb).eye_dominance*...
                        ones(1, sum(ndurs))];
                end
                if nargout==3
                    ndurs = [numel(dur_all{1}) numel(dur_all{2}) ...
                        numel(dur_all{3})];
                    indiv_durs = [indiv_durs mean([dur_all{1} dur_all{2}])];
                    indivdur_perc = [indivdur_perc 1];
                    indivdur_group = [indivdur_group ...
                        subj_data.group];
                    indivdur_block = [indivdur_block ...
                        nb];
                    indivdur_runnum = [indivdur_runnum  ...
                        numr];
                    indivdur_subj = [indivdur_subj  ...
                        subj_data.subj_code];
                    indivdur_valid = [indivdur_valid ...
                        subj_data.subj_valid_riv];
                    indivdur_eyedom = [indivdur_eyedom...
                        exp_medriv.data(ns).riv_durations(nb).eye_dominance];
                    if ndurs(3)>0
                        indiv_durs = [indiv_durs mean([dur_all{3}])];
                        indivdur_perc = [indivdur_perc 2];
                        indivdur_group = [indivdur_group ...
                            subj_data.group];
                        indivdur_block = [indivdur_block ...
                            nb];
                        indivdur_runnum = [indivdur_runnum  ...
                            numr];
                        indivdur_subj = [indivdur_subj  ...
                            subj_data.subj_code];
                        indivdur_valid = [indivdur_valid ...
                            subj_data.subj_valid_riv];
                        indivdur_eyedom = [indivdur_eyedom...
                            exp_medriv.data(ns).riv_durations(nb).eye_dominance];
                    end
                end
            end
        end
    end
end

fprintf('durations saved!\n')

if nargout==2
    indivdurs.durs = indiv_durs;
    indivdurs.perc = indivdur_perc;
    indivdurs.group = indivdur_group;
    indivdurs.block = indivdur_block;
    indivdurs.runnum = indivdur_runnum;
    indivdurs.subj = indivdur_subj;
    indivdurs.valriv = indivdur_valid;
    indivdurs.eyedom = indivdur_eyedom;
end

if nargout==3
    indivdurs = [];
    indivruns.durs = indiv_durs;
    indivruns.perc = indivdur_perc;
    indivruns.group = indivdur_group;
    indivruns.block = indivdur_block;
    indivruns.runnum = indivdur_runnum;
    indivruns.subj = indivdur_subj;
    indivruns.valriv = indivdur_valid;
    indivruns.eyedom = indivdur_eyedom;
end
cd(exp_medriv.session_dir)

end