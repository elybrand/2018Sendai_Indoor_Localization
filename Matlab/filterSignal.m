function [filtered_signal, noise] = filterSignal(data, k)
% VARIABLES
%   data:           N x 2 table with Time and SignalStrength data.
%   k:              (optional) Integer corresponding to the wavelet scale to
%                   denoise at. Must be in the interval (0, log2(N)). Default is 
%                   chosen dynamically to correspond to a time interval of 
%                   roughly 5 seconds.
%
% Uses Donoho's and Johnstone's RiskShrink to shrink the empirical wavelet
% coefficients at scale k. Returns the filtered curve and the difference
% between the unfiltered curve and the filtered curve which we call
% noise.
    

    if nargin < 2
        % Get an estimate for sampling rate 
        rate = 1/median(diff(data.Time));
        k = round(log2(5*rate));
    end

    filtered_signal = wden(data.SignalStrength,'modwtsqtwolog','s','mln',k,'haar');
    filtered_signal = filtered_signal(:);

    noise = data.SignalStrength - filtered_signal; 
    
end