function intervals = cleanUpIntervals(endpts)
% VARIABLES
%   endpts:           J x 2 table which mark the start and end indices of a
%                     jump for a particular experiment.
%
% Takes endpts and removes any jump intervals which are nested.

    % Clean up nested intervals.
    endpts = sortrows(endpts);
    intervals = zeros(size(endpts));
    
    uniq_starts = unique(endpts(:,1));
    max_endpt = 0;
    row_ctr = 1;
    for i=1:size(uniq_starts,1)
        % Find all the intervals that start at uniq_starts(i)
        temp = endpts(endpts(:,1) == uniq_starts(i),:);
        
        % Take the one with the largest endpt. Remember it's sorted.
        candidate = temp(end,:);
        
        % Add it to intervals only if it's endpoint is strictly greater
        % than the maximum endpoint in intervals so far.
        if candidate(1,2) > max_endpt
            intervals(row_ctr,:) = candidate;
            row_ctr = row_ctr + 1;
            max_endpt = candidate(1,2);
        end
        
        % Trim off any zero rows.
        indicator = intervals > 0;
        intervals = intervals(indicator(:,1),:);
    
end