function medriv_riv_extract_freqspect(exp_medriv, freq_range, hilb_flag)

group_n = zeros(1, 3);

filename = 'icacomprem_riv_medriv_physio';
% filename = 'ica_riv_medriv_physio';

cd(exp_medriv.session_dir)

nsubj = exp_medriv.nsubj;

riv_runs = {1:5, 6:10, 11:15};
nblocks = 3; % 3 times rivalry is measured

fs = 250;
fw_fr = define_filters(freq_range, fs);

fprintf('\nextracting frequency band envelopes\n')

for ns = 1:nsubj
    
    subj_data = exp_medriv.data(ns);
    
    if subj_data.subj_valid_riv
        if subj_data.group==1 || subj_data.group==2
                        
            cd(fullfile(exp_medriv.session_dir, subj_data.dir_name))
            group_n(subj_data.group) = group_n(subj_data.group)+1;
            
            load(['Epochs/' filename])
            fprintf('\nextracting frequency spectra of subject %g\n', subj_data.subj_code)
            
            % average over all available channels
            chanlabels = {chanlocs.labels};
            chanloc_inds = ~isemptycell({chanlocs.X});

            fprintf('run number: ')
            runnum = 0;
            for blknum = 1:nblocks
                if isempty(subj_data.riv_runs)
                    epochs_to_an = riv_runs{blknum};
                else
                    epochs_to_an = subj_data.riv_runs{blknum};
                end
                nepochs = numel(epochs_to_an);
                for epnum = 1:nepochs
                    runnum = runnum + 1;
                    fprintf(' %g', runnum)

                    ne = epochs_to_an(epnum);

                    if ~isempty(epochs{ne})
                        
                        epoch = double(epochs{ne}(chanloc_inds, :));
                        
                        fd = single(filter_chans(epoch, fw_fr));
                        if hilb_flag
                            fd = env_data(fd); % take the hilber transform
                        end
                        
                        filt_data{blknum}{epnum} = fd;
                        if ~isempty(artif)
                            artif_data{blknum}{epnum} = artif{ne};
                        else
                            artif_data{blknum}{epnum} = [];
                        end
                    else
                        disp('err')
                    end

                end
                
            end
            
            chanlocs = chanlocs(chanloc_inds);
            save(['Epochs/' filename '_conn'], 'filt_data', 'artif_data', 'fs', 'chanlocs', ...
                'eegchans', 'freq_range')
        end
    end
    
end
fprintf('\n')

cd(exp_medriv.session_dir)


end

function fw_fr = define_filters(freq_range, fs)

nfreqs = size(freq_range, 1);
nyquist = fs/2;

fw_fr = cell(1, nfreqs);
% design filters outside the loop
for f1 = 1:nfreqs
    
    % alpha filters
    filtbound = freq_range(f1, :); % Hz
    % transition width
    trans_width = 0.01; % fraction of 1, thus 20%
    % filter order
    filt_order = round(4*(fs/filtbound(1)));
    % filt_order = 100;
    % frequency vector (as fraction of Nyquist
    ffrequencies  = [ 0 (1-trans_width)*filtbound(1) filtbound (1+trans_width)*filtbound(2) nyquist ]/nyquist;
    % shape of filter (must be the same number of elements as frequency vector
    idealresponse = [ 0 0 1 1 0 0 ];
    % get filter weights
    fw_fr{f1} = firls(filt_order,ffrequencies,idealresponse);
    
end

end

function filt_data = filter_chans(eegdata, fw_fr)
nfreqs = numel(fw_fr);
nbchan = size(eegdata, 1);
pnts = size(eegdata, 2);
filt_data = zeros(nfreqs,nbchan,pnts);
for nf = 1:nfreqs
    for chani=1:nbchan
        filt_data(nf,chani,:) = filtfilt(...
            fw_fr{nf},1,eegdata(chani,:));
    end
end
end

function filt_data = env_data(filt_data)
filt_data = permute(filt_data, [3 1 2]);
filt_data = hilbert(detrend(filt_data));
filt_data = permute(filt_data, [2 3 1]);
end