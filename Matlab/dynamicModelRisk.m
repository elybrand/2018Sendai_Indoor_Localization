function risk = dynamicModelRisk(experiments, n, beta)
%   VARIABLES
%       experiment:     Vector of experiment structures as generated from
%                       getExperimentData()
%       n:              Initial path loss exponent
%       beta:           Rate of change paramater for path loss exponent.
%
% Outputs risk under L2 loss for the dynamic path loss model given an initial path 
% loss exponent n and rate of change parameter beta.
    
    N = size(experiments(:),1);
    thisModelLoss = @(experiment) dynamicModelLoss(experiment, n, beta);
    risk = (1/N)*sum(arrayfun(thisModelLoss, experiments));

end