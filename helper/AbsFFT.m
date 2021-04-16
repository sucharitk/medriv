function varargout = AbsFFT(data, fs, NFFT)
%
% function varargout = AbsFFT_2(data, fs, NFFT)
%
% Input is (n_channels x time_series)
%

l_data = size(data, 2);

if ~exist('NFFT', 'var')
    NFFT = 2^nextpow2(l_data); % Next power of 2 from length of y
end

% fourtrans = fft(data', NFFT)/l_data;
% fft_data = abs(fourtrans)';
% fft_data(:, 2:end) = 2*fft_data(:, 2:end);
% fft_data = fft_data(:, 1:NFFT/2+1);
fourtrans = fft(data', NFFT)/l_data;
fft_data = abs(fourtrans)';
% fft_data(:, 2:end) = 2*fft_data(:, 2:end);
fft_data = 2*fft_data(:, 1:NFFT/2+1);

varargout{1} = fft_data;

if exist('fs', 'var') && nargout>1
    varargout{2} = fs/2*linspace(0,1,NFFT/2+1);
end
if nargout>2
    fft_phase = angle(fourtrans)';
    varargout{3} = fft_phase(:, 1:NFFT/2+1);
end

end