function loss = dynamicModelLoss(experiment, n, beta)
%   VARIABLES
%       experiment:     Experiment structure as generated from
%                       getExperimentData()
%       n:              Initial path loss exponent
%       beta:           Rate of change paramater for path loss exponent.
%
% Outputs L2 loss for the dynamic path loss model given an initial path 
% loss exponent n and rate of change parameter beta.

    % Some constants. Tx is the output power in dBm of our wireless access 
    % point. Change to your needs.
    Tx = 10;
    m = size(experiment.time,1);
    distance = experiment.distance;

    % Compute L2 loss. CAVEAT: true_dists likely has NaN's in it because
    % we only kept track of distances at reference points and not as we
    % move between them. So only compare at the relevant indices.
    good_idxs = ~isnan(distance);
    predict = getDistance(experiment, n, beta);
    loss = 1/sqrt(m)*sqrt(sum(abs(distance(good_idxs) - predict(good_idxs)).^2));

end