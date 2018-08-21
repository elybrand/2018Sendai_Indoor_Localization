function predicted = simulatedRSS723S3(data)
    
    % The following is for comparing simulated RSS in 23-30
    values = [-60.86
              -66.8
              -61.7
              -66.9];
            
    time = [30, 130];
    
    predicted = zeros(size(data.SignalStrength));
    predicted(:) = NaN;
    for i=1:size(values,1)
        start = time(1)+15*(i-1);
        stop = start+10;
        % Populate RSS in the interval [start, stop)
        predicted(start <= data.Time & data.Time < stop) = values(i);
    end

end