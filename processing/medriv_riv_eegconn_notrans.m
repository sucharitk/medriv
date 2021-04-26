function medriv_riv_eegconn_notrans(exp_medriv, freq_range,...
    remov_artif, conn_type, freq_to_eval)
%
% for each subject calculate the connectivity during each block 1) after excluding the transitions, 2) for only dominance periods
% 3) for only mixed periods - for control analysis
%
% exp_medriv: data structure containing information about the experimental sessions
% freq_range: the frequency range over which to calculate the connectivity. for this study, we are focusing on beta and gamma
% remov_artif: whether to remove the flagged data
% conn_type: the type of connectivity to calculate. for this experiment, we are using the debiased weighted phase lag index (dwpli), so value is set to 3
% freq_to_eval: frequency range indices to calculate 
%

group_n = zeros(1, 3);

filename = 'icacomprem_riv_medriv_physio';

cd(exp_medriv.session_dir)

nsubj = exp_medriv.nsubj;

fs = 250;
nfreqs = numel(freq_to_eval);

fname = {'plv_connectivity','wpli_connectivity','wpli_debiased_connectivity',...
    'pli_connectivity'};
if remov_artif
    fileapp = '_noartif';
else
    fileapp = '';
end

nanwind = [-.5 .2];
nwl = ones(1, (diff(nanwind)*fs));

riv_runs = {1:5, 6:10, 11:15};
nblocks = 3; % 3 times rivalry is measured
nbchan = 32;
nchanan = 32;

subjblkconn = NaN(nsubj, nblocks, nfreqs, nbchan, nbchan);
subjblkconn_trans = subjblkconn;
subjblkconn_dom = subjblkconn;
subjblkconn_mix = subjblkconn;

fprintf('\ncalculating connectivity\n')

for ns = 1:nsubj
    
    subj_data = exp_medriv.data(ns);
    
    if subj_data.subj_valid_riv
        if subj_data.group==1 || subj_data.group==2 % || subj_data.group==2
            
            cd(fullfile(exp_medriv.session_dir, subj_data.dir_name))
            group_n(subj_data.group) = group_n(subj_data.group)+1;
            
            fprintf('\nanalyzing subject %g\n', subj_data.subj_code)
            load(['Epochs/' filename '_conn'])
            resfname = sprintf('BR_Rivalry_%g_%s', subj_data.subj_code,...
                subj_data.session_date);
            load(fullfile('Behavior', resfname))
            
            if ~exist('chanlab32', 'var')
                chanlab32 = {chanlocs.labels};
                chanlab32 = chanlab32(1:32);
            end
            
            chanlabels = {chanlocs.labels};

            chanloc_inds = ~isemptycell({chanlocs.X});
            chanlabels = chanlabels(chanloc_inds);
            [chanvals,chaninds] = get_channels_from_labels(chanlab32, chanlabels);
            nochans = find(~chanvals);
            chaninds = [chaninds nochans];
            chaninds = inds2inds(chaninds);
            numnochans = numel(nochans);

            fprintf('run number: ')
            runnum = 0;
            for blknum = 1:nblocks
                if isempty(subj_data.riv_runs)
                    epochs_to_an = riv_runs{blknum};
                else
                    epochs_to_an = subj_data.riv_runs{blknum};
                end
                nepochs = numel(epochs_to_an);
                epochs = filt_data{blknum};
                artif = artif_data{blknum};

                conn = NaN(nepochs, nfreqs, nchanan, nchanan);
                conn_trans = conn; conn_dom = conn; conn_mix = conn;
                
                for epnum = 1:nepochs
                    runnum = runnum + 1;
                    fprintf(' %g', runnum)
                    
                    if ~isempty(epochs{epnum})
                        
                        if remov_artif
                            if ~isempty(artif{epnum})
                                valid_epoch = epochs{epnum}(:, :, artif{epnum});
                            else
                                valid_epoch = epochs{epnum};
                            end
                        else
                            valid_epoch = epochs{epnum};
                        end
                        if numnochans
                            valid_epoch(:, end+1:end+numnochans, :) = NaN;
                        end
                        valid_epoch = valid_epoch(:, chaninds, :);
                        
                        psych = [results(runnum).psycho];
                        [~,rr] = interp_to_next_response(psych.tKeyPress, ...
                            psych.responseKey, 0, psych.scanEndTime, size(valid_epoch,3));
                        drr = logical(diff(rr));
                        drr(end+1)=drr(end);

                        drr = conv(drr,nwl);
                        drr = logical(drr(1-nanwind(1)*fs:end-nanwind(2)*fs+1));
                        
                                                
                        conn(epnum, :, :, :) = ...
                            calc_conn(valid_epoch(:,:,~drr), ...
                            conn_type, freq_to_eval);

                        conn_trans(epnum, :, :, :) = ...
                            calc_conn(valid_epoch(:,:,drr), ...
                            conn_type, freq_to_eval);

                        conn_dom(epnum, :, :, :) = ...
                            calc_conn(valid_epoch(:,:,rr~=3), ...
                            conn_type, freq_to_eval);
                        conn_mix(epnum, :, :, :) = ...
                            calc_conn(valid_epoch(:,:,rr==3), ...
                            conn_type, freq_to_eval);

                        
                    else
                        disp('err')
                    end
                    
                end
                if conn_type==3
                    conn = sqrt(conn);
                    conn_trans = sqrt(conn_trans);
                    conn_dom = sqrt(conn_dom);
                    conn_mix = sqrt(conn_mix);
                end
                meanconn = (squeeze(nanmean(conn, 1)));
                meanconn_trans = (squeeze(nanmean(conn_trans, 1)));
                meanconn_dom = (squeeze(nanmean(conn_dom, 1)));
                meanconn_mix = (squeeze(nanmean(conn_mix, 1)));
                %                 if conn_type==3
                %                     meanconn = sqrt(meanconn);
                %                     meanconn_trans = sqrt(meanconn_trans);
                %                     meanconn_dom = sqrt(meanconn_dom);
                %                     meanconn_mix = sqrt(meanconn_mix);
                %                 end
                subjblkconn(ns, blknum, :, :, :) = meanconn;
                subjblkconn_trans(ns, blknum, :, :, :) = meanconn_trans;
                subjblkconn_dom(ns, blknum, :, :, :) = meanconn_dom;
                subjblkconn_mix(ns, blknum, :, :, :) = meanconn_mix;
                
            end
            fprintf('\n')
        end
    end
    
end
cd(exp_medriv.session_dir)

load('chanlocs')
save(fullfile(exp_medriv.session_dir,[fname{conn_type} fileapp '_notrans']), ...
    'subjblkconn', 'chanlocs', 'freq_range', 'freq_to_eval')
subjblkconn = subjblkconn_trans;
save(fullfile(exp_medriv.session_dir,[fname{conn_type} fileapp '_trans']), ...
    'subjblkconn', 'subjblkconn_dom', 'chanlocs', 'freq_range', 'freq_to_eval')
subjblkconn = subjblkconn_mix;
save(fullfile(exp_medriv.session_dir,[fname{conn_type} fileapp '_mix']), ...
    'subjblkconn', 'subjblkconn_dom', 'chanlocs', 'freq_range', 'freq_to_eval')
subjblkconn = subjblkconn_dom;
save(fullfile(exp_medriv.session_dir,[fname{conn_type} fileapp '_dom']), ...
    'subjblkconn', 'subjblkconn_dom', 'chanlocs', 'freq_range', 'freq_to_eval')

end

function conn = calc_conn(eegdata, conn_type, freq_to_eval)

szd = size(eegdata);
nfreqs = numel(freq_to_eval);
nbchan = szd(2);

conn = zeros(nfreqs, nbchan, nbchan);
for nf = 1:nfreqs
    for nc1 = 1:nbchan
        for nc2 = nc1+1:nbchan
            % Apply PLV algorith, from Cohen et al., (2008)
            if nc1~=nc2
                p1 = angle(squeeze(eegdata(freq_to_eval(nf), nc1, :)));
                p2 = angle(squeeze(eegdata(freq_to_eval(nf), nc2, :)));
                switch conn_type
                    case 1
                        % plv
                        conn(nf, nc1, nc2) = abs(mean(exp(1i*(p1-p2))));
                    case 2
                        % wpli
                        conn(nf, nc1, nc2) = mean(sin(p1-p2))./...
                            mean(abs(sin(p1-p2)));
                    case 3
                        % wpli-debiased
                        ssq = sum(sin(p1-p2).^2);
                        conn(nf, nc1, nc2) = (sum(sin(p1-p2)).^2-ssq)./...
                            (sum(abs(sin(p1-p2))).^2-ssq);
                        conn(conn<0) = 0;
                    case 4
                        % pli
                        conn(nf, nc1, nc2) = abs(mean(sign(sin(p1-p2))));
                end
            end
        end
    end
end
end
