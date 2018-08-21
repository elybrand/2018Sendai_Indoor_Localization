function predicted = trueDistance710S2(data)
    
    % Distances from AP to RP's in July 10th S1 walk
    values = [  9.433981132
                8.544003745
                8.062257748
                8.062257748
                8.544003745
                9.433981132
                10.63014581
                12.04159458
                13.60147051
                15.26433752
                17
                18.02775638
                19.20937271
                20.51828453
                21.9317122
                20.61552813
                19.41648784
                18.35755975];
            
    time = [20, 275];
    
    predicted = zeros(size(data.SignalStrength));
    predicted(:) = NaN;
    for i=1:size(values,1)
        start = time(1)+15*(i-1);
        stop = start+10;
        % Populate distances in the interval [start, stop)
        predicted(start <= data.Time & data.Time < stop) = values(i);
    end

end