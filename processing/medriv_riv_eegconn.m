function medriv_riv_eegconn(exp_medriv, freq_range,...
    remov_artif, conn_type, freq_to_eval)
%
% for each subject calculate the connectivity during each block
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

nfreqs = numel(freq_to_eval);

fname = {'plv_connectivity','wpli_connectivity','wpli_debiased_connectivity',...
    'pli_connectivity','wpli_debiased_connectivity'};
if remov_artif
    fileapp = '_noartif';
else
    fileapp = '';
end


riv_runs = {1:5, 6:10, 11:15};
nblocks = 3; % 3 times rivalry is measured
fs = 250;
nbchan = 32;
subjblkconn = NaN(nsubj, nblocks, nfreqs, nbchan, nbchan);
fprintf('\ncalculating connectivity\n')

for ns = 1:nsubj
% subject loop
    
    subj_data = exp_medriv.data(ns);
    
    if subj_data.subj_valid_riv
    % subjects for whom there was a valid rivalry task
    
        if subj_data.group==1 || subj_data.group==2
        % include the 2 experimental group (leave the pilot group)
            
            cd(fullfile(exp_medriv.session_dir, subj_data.dir_name))
            group_n(subj_data.group) = group_n(subj_data.group)+1;
            
            fprintf('\ncalculating connectivity for subject %g. %g\n', ...
                ns, subj_data.subj_code)
            load(['Epochs/' filename '_conn'])
            
            if ~exist('NFFT', 'var')
                NFFT = 2^16;
                freqs = linspace(0, fs/2, NFFT/2+1);
                chanlocs32 = chanlocs;
                
                chanlab32 = {chanlocs.labels};
                chanlab32 = chanlab32(1:32);
                nchanan = 32;
            end
            
            chanlabels = {chanlocs.labels};
            
            % get all channels and if in any session the channels indices
            % are different then resort them according to the channel
            % number
            nbchan = numel([chanlocs.X]);
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
            % for each block of the task
            
                if isempty(subj_data.riv_runs)
                    epochs_to_an = riv_runs{blknum};
                else
                    epochs_to_an = subj_data.riv_runs{blknum};
                end
                
                nepochs = numel(epochs_to_an);
                epochs = filt_data{blknum};
                artif = artif_data{blknum};
                conn = NaN(nepochs, nfreqs, nchanan, nchanan);
                
                for epnum = 1:nepochs
                % for each run within a block
                    runnum = runnum + 1;
                    fprintf(' %g', runnum)
                    
                    if ~isempty(epochs{epnum})
                        
                        if remov_artif
                            if ~isempty(artif{epnum})
                            % if artifact flagged data is provided
                                valid_epoch = epochs{epnum}(:, :, artif{epnum});
                            else
                                valid_epoch = epochs{epnum};
                            end
                        else
                            valid_epoch = epochs{epnum};
                        end
                        
                        % add missing channels at the end and then re-arrange so that all participants have the same channel order
                        if numnochans
                            valid_epoch(:, end+1:end+numnochans, :) = NaN;
                        end
                        valid_epoch = valid_epoch(:, chaninds, :);

                        % calculate connectivity
                        cc = calc_conn(valid_epoch, conn_type, freq_to_eval);

                        conn(epnum, :, :, :) = cc;
                        
                    else
                        disp('err')
                    end
                    
                end
                
                if conn_type==3||conn_type==5, conn = sqrt(conn); end
                meanconn = (squeeze(nanmean(conn, 1))); % take away the abs
                %                 if conn_type==3, meanconn = sqrt(meanconn); end
                subjblkconn(ns, blknum, :, :, :) = meanconn;
                
            end
            fprintf('\n')
        end
    end
    
end
cd(exp_medriv.session_dir)

load('chanlocs')
save(fullfile(exp_medriv.session_dir,[fname{conn_type} fileapp]), ...
    'subjblkconn', 'chanlocs', 'freq_range', 'freq_to_eval')

end

function conn = calc_conn(eegdata, conn_type, freq_to_eval)
% function to calculate different types of connectivity 

szd = size(eegdata);
nfreqs = numel(freq_to_eval);
nbchan = szd(2);

conn = zeros(nfreqs, nbchan, nbchan);
for nf = 1:nfreqs
    for nc1 = 1:nbchan
        for nc2 = nc1+1:nbchan
            if nc1~=nc2
                if conn_type<5
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
                            dwpli = (sum(sin(p1-p2)).^2-ssq)./...
                                (sum(abs(sin(p1-p2))).^2-ssq);
                            dwpli(dwpli<0) = 0; % make negative values zero
                            conn(nf, nc1, nc2) = dwpli;
                            
                        case 4
                            % pli
                            conn(nf, nc1, nc2) = abs(mean(sign(sin(p1-p2))));

                    end
                else
                    %                     % debiased wpli in frequency domain

                    if ~isnan(eegdata(freq_to_eval(nf), nc1, 1)) &&...
                            ~isnan(eegdata(freq_to_eval(nf), nc1, 1))

                        cdi = imag(cpsd(squeeze(eegdata(freq_to_eval(nf), nc1, :)),...
                            squeeze(eegdata(freq_to_eval(nf), nc2, :))))';
                        imagsum      = sum(cdi,2);
                        imagsumW     = sum(abs(cdi),2);
                        debiasfactor = sum(cdi.^2,2);
                        dwpli =  (imagsum.^2 - debiasfactor)./...
                            (imagsumW.^2 - debiasfactor);
                        dwpli(dwpli<0)=0;
                        conn(nf, nc1, nc2)  = dwpli;
                    else
                        conn(nf, nc1, nc2)  = NaN;
                    end
                    
                end
            end
        end
    end
end
end
