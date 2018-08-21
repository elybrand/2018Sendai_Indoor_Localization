function risk = staticModelRisk(experiments, n)
%   VARIABLES
%       experiment:     Vector of experiment structures as generated from
%                       getExperimentData()
%       n:              Initial path loss exponent
%
% Outputs risk under L2 loss for the dynamic path loss model given an initial path 
% loss exponent n and rate of change parameter beta.
    
    N = size(experiments(:),1);
    thisModelLoss = @(experiment) staticModelLoss(experiment, n);
    risk = (1/N)*sum(arrayfun(thisModelLoss, experiments));

end