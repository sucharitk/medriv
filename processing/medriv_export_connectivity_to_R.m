function medriv_export_connectivity_to_R(exp_medriv, conn_type, ...
    chans_from, chans_to, plot_freq, outfilename, append)
%
% export data to a csv file for doing statistical analysis in R
%

cd(exp_medriv.session_dir)

fname = {'plv_connectivity','wpli_connectivity','wpli_debiased_connectivity',...
    'pli_connectivity'};

fileapp = '';

connames = [];
% if append
%     append = '_notrans_sepperc';
%     outfilename = [outfilename append];
% else
%     append = '';
% end
outfilename = [outfilename '.csv'];

load(fullfile(exp_medriv.session_dir,...
    [fname{conn_type} fileapp append]))
load('chanlocs')
group = [exp_medriv.data.group];
subj_code = [exp_medriv.data.subj_code];
subj_data = [exp_medriv.data];
riv_durations = {subj_data.riv_durations};
subj_val = [subj_data.subj_valid_riv];
subj_val = subj_val & group~=3;
nsubj = exp_medriv.nsubj;
nconds = 3;
chanlabels = {chanlocs.labels};
xy = [chanlocs.X; chanlocs.Y];

[~, cf] = get_channels_from_labels(chanlabels, chans_from);
[~, ct] = get_channels_from_labels(chanlabels, chans_to);
ncf = numel(cf); nct = numel(ct); ncon = ncf*nct;
subj_conn = zeros(ncon, nsubj, nconds);
connnum = 0;
for ni1 = cf
    for ni2 = ct
        connnum = connnum + 1;
        subj_conn(connnum, :, :) = + subjblkconn(:,:,plot_freq,ni1,ni2) + ...
            subjblkconn(:,:,plot_freq,ni2,ni1);
        connames = sprintf('%s%g,%s,%s,%g,%g,%g,%g\n', connames, connnum, ...
            chanlabels{ni1}, chanlabels{ni2}, ...
            xy(1, ni1), xy(2, ni1), xy(1, ni2), xy(2, ni2));
    end
end
subj_conn = subj_conn(:, subj_val, :);
connfile = fopen('channel_connections.csv', 'w');
fprintf(connfile, connames);
fclose(connfile);
header_text = 'connum,chanfrom,chanto,xfrom,yfrom,xto,yto';
add_header_csv('channel_connections.csv', header_text)

domdurs_median = NaN(nsubj, nconds);
mixdurs_median = NaN(nsubj, nconds);
for ns = 1:nsubj
    if ~isempty(riv_durations{ns})
        for nc = 1:nconds
            rd2 = riv_durations{ns}(nc).medians; % mixed durations
            rd2(isnan(rd2)) = 0;
            mixdurs_median(ns, nc) = rd2(3);

            rd2 = riv_durations{ns}(nc).median_all; % dominance durations
            rd2(isnan(rd2)) = 0;
            domdurs_median(ns, nc) = rd2;
        end
    end
end
domdurs_median = domdurs_median(subj_val, :);
mixdurs_median = mixdurs_median(subj_val, :);
group = group(subj_val);
subj_code = subj_code(subj_val);

nquest = 14;

domdurs_median = repmat(domdurs_median, [1,1,ncon,nquest]); 
domdurs_median = permute(domdurs_median, [3 1 4 2]);
mixdurs_median = repmat(mixdurs_median, [1,1,ncon,nquest]); 
mixdurs_median = permute(mixdurs_median, [3 1 4 2]);
sz_conn = size(domdurs_median);

questresp = [exp_medriv.data.questresp];
questresp(2, :) = []; % remove the second block of questionnaire because no
questresp = reshape(questresp, [3 nquest exp_medriv.nsubj]);
questresp = questresp(:, :, subj_val);
questresp = repmat(questresp, [1,1,1, ncon]);
questresp = permute(questresp, [4 3 2 1]);
questclust = [exp_medriv.questclust];
questclust = squeeze(repmat(questclust, [1,1,sz_conn([1 2 4])]));
questclust = permute(questclust,[2,3,1,4]);

subj_conn = repmat(subj_conn, [1,1,1,nquest]);
subj_conn = permute(subj_conn, [1 2 4 3]);


[conns, subjs, questnum, blknum] = ndgrid(1:sz_conn(1),1:sz_conn(2),1:sz_conn(3),...
    1:sz_conn(4));
groups = squeeze(repmat(group, [1 1 sz_conn([1 3 4])]));
groups = permute(groups, [2 1 3 4]);
subj_code = squeeze(repmat(subj_code, [1 1 sz_conn([1 3 4])]));
subj_code = permute(subj_code, [2 1 3 4]);

dr = double([subj_conn(:), domdurs_median(:), mixdurs_median(:), ...
    conns(:), blknum(:), groups(:), subjs(:), subj_code(:), questresp(:),...
    questnum(:), questclust(:)]);

csvwrite(outfilename, dr)

header_text = 'wpli,dommedian,mixmedian,connum,block,group,subj,subjcode,';
header_text = sprintf('%squestresp,questnum,questclust',header_text);
add_header_csv(outfilename, header_text)

fprintf('saved %s\n', outfilename)
end
