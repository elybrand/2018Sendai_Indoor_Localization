function loss = staticModelLoss(experiment, n)
%   VARIABLES
%       experiment:     Experiment structure as generated from
%                       getExperimentData()
%       n:              Path loss exponent
%
% Outputs L2 loss for the static path loss model given path loss exponent n.

    % Some constants. Tx is the output power in dBm of our wireless access 
    % point. Change to your needs.
    Tx = 10;
    m = size(experiment.time,1);
    distance = experiment.distance;
    
    % Compute L2 loss. CAVEAT: experiment.distance likely has NaN's in it because
    % we only kept track of distances at reference points and not as we
    % move between them. So only compare at the relevant indices.
    good_idxs = ~isnan(experiment.distance);
    
    predict = 10.^((Tx-experiment.filtered)/(10*n));
    loss = 1/sqrt(m)*sqrt(sum(abs(distance(good_idxs) - predict(good_idxs)).^2));

end