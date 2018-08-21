function experiments = getExperimentData(room)
%   VARIABLES
%       room:           An optional variable that indicates
%                       which room user wants experiments from.
%                       Options include 'all', 'S1', 'S2', or 'S3'.
%                       Default is 'all'.
%   Loads experiments into an array of structs containing the following
%   fields:
%           - RSS:          Mx1 vector of raw RSS data (dBm)
%           - time:         Mx1 vector of time of measurements (sec)
%           - filtered:     Mx1 vector of filtered RSS signal per filterSignal2)
%           - jumps:        a Jx2 matrix delimiting start and end indices
%                           in RSS where jumps are detected.
%           - room:         room that experiment was taken in.
%           - date:         date that experiment was taken. YYYYMMDD
%           - distance:     Mx1 vector of known distances (m) from AP at various
%                           times. Contains NaN's when moving between
%                           reference points, so be careful when using.
%           - rate:         median sample rate (Hz). We resample our experiments
%                           at this rate FYI.
%           - name:         full name of the experiment.

    % If you'd like to add more experiments, please add them at the
    % BOTTOM of the array. The order of the array is important!
    fileNames = [
        % July 10th tours. Indices 1-9.
        string('../Experimental/20180710_S1_f_1_v2.xlsx')
        string('../Experimental/20180710_S1_f_2_v2.xlsx')
        string('../Experimental/20180710_S1_f_3_v2.xlsx')
        string('../Experimental/20180710_S2_f_1_v2.xlsx')
        string('../Experimental/20180710_S2_f_2_v2.xlsx')
        string('../Experimental/20180710_S2_f_3_v2.xlsx')
        string('../Experimental/20180710_S3_f_1_v2.xlsx')
        string('../Experimental/20180710_S3_f_2_v2.xlsx')
        string('../Experimental/20180710_S3_f_3_v2.xlsx')
        % July 23rd tours. Carefully controlled LOS experiments. Indices 10-30.
        string('../Experimental/20180723_S1_LOS-1.xlsx')
        string('../Experimental/20180723_S1_LOS-2.xlsx')
        string('../Experimental/20180723_S1_LOS-3.xlsx')
        string('../Experimental/20180723_S1_NLOS-1.xlsx')
        string('../Experimental/20180723_S1_NLOS-2.xlsx')
        string('../Experimental/20180723_S1_NLOS-3.xlsx')
        string('../Experimental/20180723_S2_Close-1.xlsx')
        string('../Experimental/20180723_S2_Close-2.xlsx')
        string('../Experimental/20180723_S2_Close-3.xlsx')
        string('../Experimental/20180723_S2_Close-4.xlsx')
        string('../Experimental/20180723_S2_Open-1.xlsx')
        string('../Experimental/20180723_S2_Open-2.xlsx')
        string('../Experimental/20180723_S2_Open-3.xlsx')
        string('../Experimental/20180723_S3_Close_Close-1.xlsx')
        string('../Experimental/20180723_S3_Close_Close-2.xlsx')
        string('../Experimental/20180723_S3_Close_Open-1.xlsx')
        string('../Experimental/20180723_S3_Close_Open-2.xlsx')
        string('../Experimental/20180723_S3_Open_Close-1.xlsx')
        string('../Experimental/20180723_S3_Open_Close-2.xlsx')
        string('../Experimental/20180723_S3_Open_Open-1.xlsx')
        string('../Experimental/20180723_S3_Open_Open-2.xlsx')
        % Changing sampling rates, experiments 31-39
        string('../Experimental/20180724_S1_SR01-1.xlsx')
        string('../Experimental/20180724_S1_SR01-2.xlsx')
        string('../Experimental/20180724_S1_SR01-3.xlsx')
        string('../Experimental/20180724_S1_SR02-1.xlsx')
        string('../Experimental/20180724_S1_SR02-2.xlsx')
        string('../Experimental/20180724_S1_SR02-3.xlsx')
        string('../Experimental/20180724_S1_SR10-1.xlsx')
        string('../Experimental/20180724_S1_SR10-2.xlsx')
        string('../Experimental/20180724_S1_SR10-3.xlsx')
    ];

    experimentTimes = [
        [25, 190]
        [25, 190]
        [25, 190]
        [20, 275]
        [20, 275]
        [20, 275]
        [20, 110]
        [20, 110]
        [20, 110]
        [30, 130]
        [30, 130]
        [30, 130]
        [30, 130]
        [30, 130]
        [30, 130]
        [20,90]
        [20,90]
        [20,90]
        [20,90]
        [20,90]
        [20,90]
        [20,90]
        [30, 130]
        [30, 130]
        [30, 130]
        [30, 130]
        [30, 130]
        [30, 130]
        [30, 130]
        [30, 130]
        [25,200]
        [25,200]
        [25,200]
        [25,200]
        [25,200]
        [25,200]
        [25,200]
        [25,200]
        [25,200]
    ];

    experimentGroups = [1;4;7;10;16;23;31];
    groupDistances = {@trueDistance710S1, @trueDistance710S2, ...
                    @trueDistance710S3, @trueDistance723S1, ...
                    @trueDistance723S2, @trueDistance723S3, ...
                    @trueDistance710S1};
    numGroups = size(experimentGroups,1);
    N = size(fileNames, 1);
    
    if nargin < 1
        expIndices = 1:N;
    else
        switch room
            case 'S1'
                expIndices = [1:3, 10:15, 31,39];
            case 'S2'
                expIndices = [4:6, 16:22];
            case 'S3'
                expIndices = [7:9, 23:30];
            otherwise
                expIndices = 1:N;
        end
    end
    
    numExps = size(expIndices(:),1);

    % Load these experiments into an array of data structures. Preallocate
    % first.
    experiments = repmat(struct('RSS', [], 'time', [], 'filtered', [], 'jumps', [], 'room', '', 'date', '', 'distance', [], 'rate', 0, 'name', ''), numExps, 1 );
    ctr = 1;
    for i=expIndices
      % Load the data from this experiment.
        filename = fileNames(i,:);
        filename = filename.char;
        opts = detectImportOptions(filename);
        opts.SelectedVariableNames = {'Time','SignalStrength'};
        data = readtable(filename, opts);

        % Grab the experiment name without the .xlsx extension
        slashposns = strfind(filename, '/');
        exp_name = filename(slashposns(end)+1:(end-5));
        date = exp_name(1:8);
        room = exp_name(10:11);

        % Dispose of any NaN's
        data=data(~any(ismissing(data),2),:);
        % Get rid of RSSI > -5. This handles spurious jumps in RSSI.
        data=data(data.SignalStrength < -5,:);

        % We are plagued by non-uniform sampling, despite setting a uniform
        % rate during experiments. Resample our signal at the median rate.
        rate = 1/median(diff(data.Time));
        [SignalStrength, Time] = resample(data.SignalStrength, data.Time, rate);
        data = table(Time, SignalStrength);

        % Get rid of data outside experiment window.
        start = experimentTimes(i,1);
        finish = experimentTimes(i,2);
        data = data((start <= data.Time & data.Time <= finish),:);

        % Get jump information and the filtered signal.
        [jumpUpLocs, jumpDownLocs, filtered_signal, ~] = normalizedFindJumps(data);

        % Consolidate for getDistance. Clean up because jumpDowns
        % could be subsets of jumpUps.
        jumpLocs = cleanUpIntervals([jumpUpLocs; jumpDownLocs]);

        % Load the true distances for this experiment.
        trueDists = NaN;
        for j=1:(numGroups-1)
            if (experimentGroups(j) <= i) && (i < experimentGroups(j+1))
                trueDists = groupDistances{j}(data);
            end
        end
        if isnan(trueDists)
            trueDists = groupDistances{end}(data);
        end
        
        % Sanity check.
        assert(size(trueDists,1) == size(data.Time,1), sprintf(['Problem with experiment ', exp_name]))

        experiments(ctr) = struct('RSS', data.SignalStrength, 'time', data.Time, ...
            'filtered', filtered_signal, 'jumps', jumpLocs, 'room', room, ...
            'date', date, 'distance', trueDists, 'rate', rate, 'name', exp_name);
        ctr = ctr + 1;
    end

end