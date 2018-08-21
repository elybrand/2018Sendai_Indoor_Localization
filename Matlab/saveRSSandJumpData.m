function [] = saveRSSandJumpData(exp_name, data, filtered_signal, detected_jumps)

% Saves RSS data and jump data into a .txt file formatted as follows:
% first line: data.Time
% second line: unfiltered RSS
% third line: filtered RSS
% fourth line: detected jumps (time interval endpts)
%
% No guarantees if the file already exists!

    cd ./jumpData

    filename = [exp_name, '_jumpData.txt'];
    fileID = fopen(filename, 'wt');
    
    fprintf(fileID, '%.4f ', data.Time');
    fprintf(fileID, '\n');
    
    fprintf(fileID, '%i ', data.SignalStrength');
    fprintf(fileID, '\n');
    
    fprintf(fileID, '%.4f ', filtered_signal(:)');
    fprintf(fileID, '\n');
    
    fprintf(fileID, '%.4f ', detected_jumps(:)');
    fprintf(fileID, '\n');
    
    fclose(fileID);
    
    cd ..

end