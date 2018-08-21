function predicted = trueDistance723S2(data)
    
    % Distances from AP to RP's in July 10th S1 walk
    values = [  8.544003745
                9.433981132
                10.63014581
                9.433981132
                8.544003745];
            
    time = [20, 90];
    
    predicted = zeros(size(data.SignalStrength));
    predicted(:) = NaN;
    for i=1:size(values,1)
        start = time(1)+15*(i-1);
        stop = start+10;
        % Populate distances in the interval [start, stop)
        predicted(start <= data.Time & data.Time < stop) = values(i);
    end

end