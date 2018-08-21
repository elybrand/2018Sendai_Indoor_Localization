function  [staticRisk, dynamicRisk, n_opt, beta_opt] = trainLossModels(room)       
%   VARIABLES:
%       room:           an optional flag to indicate which room to train on.
%                       Options include 'S1', 'S2', 'S3', or 'all'. Default is
%                       'all'.
%
%   Optimizes the choice of initial path loss exponent n_opt and choice of
%   rate of change beta_opt for the dynamic path loss model via cross validation. 
%   Outputs the loss for the static (i.e. constant path loss exponent) 
%   path loss model and the loss for the dynamic model over all
%   experiments.    

    if nargin < 1
        room = 'all';
    end

    experiments = getExperimentData(room);
    N = size(experiments,1);
    
    % Calculate how many rooms there are. Form your test group for cross
    % validation.
    if strcmp(room, 'all') == 0
        % Take  max(0.2*N, 2) experiments as a test group.
        m = max(round(0.2*N),2);
        testGroup = datasample(1:N, m, 'Replace', false);
    else
        % Take 2 samples from each room.
        rooms = arrayfun(@(z) z.room, experiments, 'UniformOutput', false);
        roomNames = unique(rooms);
        numRooms = size(roomNames,1);
        testGroup = zeros(2*numRooms,1);
        for k=1:numRooms
            % Find the experiment indices which correspond to this room.
            thisRoom = find(strcmp(rooms, roomNames(k))==1);
            testGroup((2*k-1):2*k) = datasample(thisRoom, 2, 'Replace', false);
        end
    end
        
    % The rest (of the indices) are for training.
    trainGroup = setdiff(1:N, testGroup(:)');
    
    % First train the static model for the optimal initial path loss
    % exponent. It doesn't really matter what beta is in this case,
    % so just set it to zero for now. Choose n between 0 and 10.
    options = [];%optimset('Display','iter');
    staticTrainRisk = @(n)staticModelRisk(experiments(trainGroup), n);
    n_opt = fminbnd(staticTrainRisk, 0, 10, options);

    % Now train the dynamic model using n_opt as the initial path loss
    % exponent. Choose beta between 0 and 200.
    dynamicTrainRisk = @(beta)dynamicModelRisk(experiments(trainGroup), n_opt, beta);
    beta_opt = fminbnd(dynamicTrainRisk, -1, 1, options);
    sprintf('static training risk: %0.5f\n dynamic training risk: %0.5f',staticTrainRisk(n_opt), dynamicTrainRisk(beta_opt))

    % Now get an estimate for the risks using the testGroup.
    staticRisk = staticModelRisk(experiments(testGroup), n_opt);
    dynamicRisk = dynamicModelRisk(experiments(testGroup), n_opt, beta_opt);
    
end


