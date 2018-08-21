function predicted = trueDistance710S3(data)
    
    % Distances from AP to RP's in July 10th S1 walk
    values = [  14.86606875
                14.31782106
                14.03566885
                14.03566885
                14.31782106
                14.86606875
                15.65247584];
            
    time = [20, 110];
    
    predicted = zeros(size(data.SignalStrength));
    predicted(:) = NaN;
    for i=1:size(values,1)
        start = time(1)+15*(i-1);
        stop = start+10;
        % Populate distances in the interval [start, stop)
        predicted(start <= data.Time & data.Time < stop) = values(i);
    end

end