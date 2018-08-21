function predicted = simulatedRSS723S1NLOS(data)
    
    % The following is for comparing simulated RSS in 13-15.
    values = [-39.78
              -36.29
              -37.18
              -40.97];
            
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