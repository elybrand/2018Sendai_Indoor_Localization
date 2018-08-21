function predicted = trueDistance710S1(data)
    
    % Distances from AP to RP's in July 10th S1 walk
    values = [  5.385164807
                3.605551275
                2.236067977
                2.236067977
                3.605551275
                5.385164807
                7.280109889
                9.219544457
                11.18033989
                13.15294644
                15.13274595
                17.11724277];
            
    time = [25, 190];
    
    predicted = zeros(size(data.SignalStrength));
    predicted(:) = NaN;
    for i=1:size(values,1)
        start = time(1)+15*(i-1);
        stop = start+10;
        % Populate distances in the interval [start, stop)
        predicted(start <= data.Time & data.Time < stop) = values(i);
    end

end