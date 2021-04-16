function total_conn = plot_connectivity(conn_matrix, chanlocs, linescale,...
    chan_from, chan_to)
szm = size(conn_matrix);
i1 = szm(1); i2 = szm(2);
mxval = max(abs(conn_matrix(:)));
plotcols = {'red', 'blue'};
if nargout
    total_conn = [];
end
if ~exist('chan_from', 'var')
    for ni1 = 1:i1
        for ni2 = ni1+1:i2
            cm = conn_matrix(ni1,ni2);
            if ~cm, cm = conn_matrix(ni2,ni1); end
            line([chanlocs(ni1).X chanlocs(ni2).X],...
                [chanlocs(ni1).Y chanlocs(ni2).Y],...
                'LineWidth', abs(cm)*linescale*mxval,...
                'Color', plotcols{single(cm>=0)+1})
            if nargout, total_conn = [total_conn cm]; end
        end
    end
else
    [~, cf] = get_channels_from_labels({chanlocs.labels}, chan_from);
    [~, ct] = get_channels_from_labels({chanlocs.labels}, chan_to);
    for ni1 = cf
        for ni2 = ct
            if ni1~=ni2
                cm = conn_matrix(ni1,ni2);
                if ~cm, cm = conn_matrix(ni2,ni1); end
                if ~isnan(cm)
                    line([chanlocs(ni1).X chanlocs(ni2).X],...
                        [chanlocs(ni1).Y chanlocs(ni2).Y],...
                        'LineWidth', abs(cm)*linescale*mxval,...
                        'Color', plotcols{single(cm>=0)+1})
                end
                if nargout, total_conn = [total_conn cm]; end
            end
        end
    end
    
end
end