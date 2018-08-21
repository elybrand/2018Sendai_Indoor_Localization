function predicted = trueDistance723S1(data)

    values = [3.61
              2.24
              2.24
              3.61
              2.24
              2.24
              3.61];
    
    time = [30,140];
    
    predicted = zeros(size(data.SignalStrength));
    predicted(:) = NaN;
    for i=1:size(values,1)
        start = time(1)+15*(i-1);
        stop = start+10;
        % Populate distances in the interval [start, stop)
        predicted(start <= data.Time & data.Time < stop) = values(i);
    end

end