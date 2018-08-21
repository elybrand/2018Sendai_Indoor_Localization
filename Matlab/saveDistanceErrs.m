function [] = saveDistanceErrs(exp_name, data, errs)

% Saves RSS data and jump data into a .txt file formatted as follows:
% first line: data.Time
% second line: unfiltered RSS
% third line: filtered RSS
% fourth line: detected jumps (time interval endpts)
%
% No guarantees if the file already exists!

    cd ./jumpData/distance_errors/staticErrs

    filename = [exp_name, '_distErrsStatic.txt'];
    fileID = fopen(filename, 'wt');
    
    fprintf(fileID, '%.4f ', data.Time');
    fprintf(fileID, '\n');
    
    fprintf(fileID, '%.4f ', errs');
    
    cd ../../..

end