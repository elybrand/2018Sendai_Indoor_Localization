%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Jump Detection and Distance Estimation Plots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% GLOBAL CONSTANTS
Tx = 10; % Power (dBm) of wireless access point transmitter.

% Select which rooms to train the models on. Options include
% 'all', 'S1', 'S2', or 'S3'.
room = 'S3';
[staticRisk, dynamicRisk, n_opt, beta_opt] = trainLossModels(room);

% RECORD HOLDERS (most pronounced improvements)
% Room      Risk Improvement    n_opt               beta_opt             staticRisk          dynamicRisk
% all       0.007075265867357   6.451573399081251   -0.002678405169706   2.101626741690592   2.094551475823235
% S1        0.032886032957195   7.526007990981506   -0.065696535278279   1.441268919793768   1.408382886836573
% S1        0.500507571080926   9.999965272951107   -0.127807733561423   4.271834477871285   3.771326906790359
% S2        0.996811191940892   6.957409374796584   -0.057228426882379   2.113655366571817   1.116844174630925
% S2        1.522955312637923   7.021426420639433   -0.049397795084410   3.719405257839139   2.196449945201216
% S3        0.143183789091513   6.188389956824102    0.023562447417301   1.137614136791836   0.994430347700323
% S3        0.187155585536245   6.208435175457642    0.025798200196559   1.139665040832860   0.952509455296615
% All 2Hz   0.041799129877552   6.312177192698816    0.006634227674893   2.648797174635879   2.606998044758327
% S2 & S3   0.024724290626374   7.741439408593219   -0.012426617356940   2.555567104240087   2.530842813613713

% Load the experiments and tabulate the loss for each experiment.
n_opt = 7.021426420639433;
beta_opt = -0.049397795084410;
experiments = getExperimentData(room);
tableOfErrors = zeros(size(experiments,1),1);
ctr = 1;
for i=1:size(experiments,1)
    
    experiment = experiments(i);
    time = experiment.time;
    distance = experiment.distance;
    m = size(time,1);
    
    % Plot the filtered RSS data along with the detected jumps.
    plotFiltered = false;
    plotTitle = [experiment.name, '   Filtered RSSI vs Time'];
    fig1 = genJumpPlot(experiment, plotTitle, plotFiltered);
    
    % Plot the true distance along with the two estimated distances.
    [dynamicDistance, nDynamic] = getDistance(experiment, n_opt, beta_opt);
    staticDistance = 10.^((Tx-experiment.filtered)/(10*n_opt));
    
    figure(1)
    plot(time, distance, '-x', 'linewidth', 2)
    hold on;
    plot(time, dynamicDistance, '-x', 'linewidth', 2)
    plot(time, staticDistance, '-x', 'linewidth', 2)
    title([experiment.name, ' Distance vs Time'], 'Interpreter', 'none')
    legend('True Distance','Estimated Dynamic Distance', 'Estimated Static Distance', 'Location', 'NorthWest')
    xlabel('Time (sec)','fontsize',16)
    ylabel('Distance (m)','fontsize',16)
    set(gca,'fontsize',16)
    hold off;

%     figure(2)
%     plot(time, nDynamic, '-x', 'linewidth', 2)
%     title(['Path Loss Exponent vs Time'])
%     xlabel('Time (sec)','fontsize',16)
%     ylabel('Path Loss Exponent','fontsize',16)
%     set(gca,'fontsize',16)
    
    % Calculate the loss for this experiment.
    good_idxs = ~isnan(distance);
    tableOfErrors(ctr) = 1/sqrt(m)*sqrt(sum(abs(distance(good_idxs) - dynamicDistance(good_idxs)).^2));
    ctr = ctr + 1;
    
    % Save the pointwise errors to a file.
    %saveDistanceErrs(exp_name, data(good_idxs,:), abs(trueDists(good_idxs) - staticPredict(good_idxs)));
    
    pause;
    close all;
    prev_exp = i;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Cross Validating Path Loss Models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Train dynamic path loss model over 30 cross validation trials.
% M = 30;
% statRisks = zeros(M,1);
% dynamicRisks = zeros(M,1);
% n_opts = zeros(M,1);
% beta_opts = zeros(M,1);
% for i = 1:M
%     [staticRisk, dynamicRisk, n_opt, beta_opt] = trainLossModels('all');
%     statRisks(i) = staticRisk;
%     dynamicRisks(i) = dynamicRisk;
%     n_opts(i) = n_opt;
%     beta_opts(i) = beta_opt;
% end 
% [mx, loc] = max(statRisks-dynamicRisks);
% n_opt = n_opts(loc);
% beta_opt = beta_opts(loc);
