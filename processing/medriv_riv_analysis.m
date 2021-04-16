%% add paths

load_medriv_project

%% initialize experiment parameters

exp_medriv = medriv_experiment;

%%% evaluate rivalry for three periods

exp_medriv = medriv_riv_durations(exp_medriv);

%% extract epochs from the eeglab dataset

per = 'riv'; % rivalry period
% per = 'med'; 
switch per
    case 'riv'
        filename = 'icacomprem_riv_medriv_physio';
    case 'med'
        filename = 'icacomprem_med_medriv_physio';
end
medriv_extract_epochs(exp_medriv, per, filename)

%% step 1 - extract frequency bands for each run

freq_range = [15 25; 30 50]; % beta and gamma
hilb_flag = true; % whether to take the hilbert transform - no if using spectral wpli conn_type = 5
medriv_riv_extract_freqspect(exp_medriv, freq_range, hilb_flag);

%% step 2 - extract blockwise eeg frequency band connectivity 

remove_artif = false;
freq_to_eval = [1 2];
conn_type =3; % 1-plv, 2-wpli, 3-debiased wpli, 4-pli, 5-debiased wpli in frequncy domain

medriv_riv_eegconn(exp_medriv, freq_range, ...
    remove_artif, conn_type, freq_to_eval);

%% step 2.2 - extract blockwise eeg frequency band connectivity remove data before and after the perceptual transitions (control analysis)
% also includes data with only transitions and exclusively mixed and
% dominant percepts 
remove_artif = false;
freq_to_eval = [1 2];
conn_type =3; % 1-plv, 2-wpli, 3-debiased wpli, 4-pli

medriv_riv_eegconn_notrans(exp_medriv, freq_range, ...
    remove_artif, conn_type, freq_to_eval);


%% step 3 - plot topography of correlation of connectivity and mixed durations

chan_from = {};
chan_to = {};

remove_artif = false;

plot_freq = 2;
conn_type = 3; % 2-wpli
mean_or_median = 2; %1-mean, 2-median
mix_or_dom = 1; %1- mix, 2-dom
cortype = 3;
plot_type = 2; % 1 for both med 1 and med 2, 2 for med 1 (paper figure 2)
behav_or_pheno = 0; %0- behav, 1-5-pheno (questionnaire cluster)
pthresh = .01;

% if chan_to is empty, it plots one way correlation between pairs of
% channels, if chan_from is also empty plot the connections that are
% significant
medriv_conncorrs_topo(exp_medriv, conn_type, chan_from, chan_to, plot_freq,...
    mean_or_median, behav_or_pheno, remove_artif, cortype, mix_or_dom ,plot_type,...
    pthresh)

%% step 4 - save data for analysis in R

conn_type = 3; % 2-wpli
load('chanlocs')
chanlabs = {chanlocs.labels};
periphchans = {'FT9', 'FT10', 'TP9', 'TP10', 'FP1', 'Fp2'};
periphchans = get_channels_from_labels(chanlabs, periphchans);

chans_from = chanlabs(~periphchans);
chans_to = chanlabs(~periphchans);

plot_freqs = [1 2];
nfreqs = numel(plot_freqs);
freq_names = {'beta', 'gamma'};

append = 04;
switch append
    case 0
        append = '';
    case 1
        append = '_notrans';
    case 2
        append = '_trans';
    case 3
        append = '_dom';
    case 4
        append = '_mix';
end

for nf = 1:nfreqs
    outfilename = ['wpli_blockwise_' freq_names{nf} append];
    medriv_export_connectivity_to_R(exp_medriv, conn_type, ...
        chans_from, chans_to, nf, outfilename, append)
end

