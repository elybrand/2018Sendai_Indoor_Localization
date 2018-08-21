function [jumpUpLocs, jumpDownLocs, filtered_signal, noise] = normalizedFindJumps(data, k)
% VARIABLES
%   data:           N x 2 table with Time and SignalStrength data.
%   k:              (optional) Vector of wavelet scales. Must be integers.
%                   Default is one wavelet scale chosen dynamically to
%                   correspond to a time interval of roughly 5 seconds.
%
% normalizedFindJumps centers the RSS signal and scales by the reciprocal
% of the empirical standard deviation to make it have unit variance.
    
    
    if nargin < 2
        % Get an estimate for sampling rate 
        rate = 1/median(diff(data.Time));
        k = round(log2(5*rate));
    end
    
    signal = data.SignalStrength;
    
    % Center the signal.
    mu = mean(signal);
    transformedSignal = signal - mu;
    
    % Divide by the standard deviation.
    sigma = std(transformedSignal);
    transformedSignal = (1/sigma)*transformedSignal;
    
    Time = data.Time;
    SignalStrength = transformedSignal;
    newdata = table(Time, SignalStrength);
    
    % Now call another findJumps
    [jumpUpLocs, jumpDownLocs, filtered_signal, noise] = findJumps(newdata,k);
    
    % Rescale the filtered_signal to return.
    filtered_signal = filtered_signal*sigma + mu;
    noise = noise*sigma;
    
end