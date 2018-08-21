function fig = genJumpPlot(experiment, plotTitle, plotFiltered)
% VARIABLES
%   experiment:     An experiment data structure as generated from
%                   getExperimentData().
%   plotTitle:      Optional argument for the title of the plot generated.
%                   Defaults to 'Filtered RSSI vs Time'.
%   plotFiltered:   Optional boolean expression indicating if the plot should be
%                   of the filtered signal. If false, plots unfiltered.
%                   Defaults to true.

% Generates a plot of the RSSI data with the detected jump locations
% highlighted.
    
    if nargin < 3
        if nargin < 2
           plotTitle = [experiment.name, '   Filtered RSSI vs Time'];
        end
        plotFiltered = true;
    end
    
    %Make an indicator function on the jumps.
    jump_indicate = zeros(size(experiment.time));
    for i=1:size(experiment.jumps,1)
        jump_indicate(experiment.jumps(i,1):experiment.jumps(i,2)) = 1;
    end

    if plotFiltered == true
        signal = experiment.filtered;
    else
        signal = experiment.RSS;
    end
    
    fig = figure();
    set(gcf, 'Position', [000, 900, 800, 700])
    plot(experiment.time, signal, '-x', 'color', [0 0.4470 0.7410], 'linewidth', 2)
    hold on;
    %Now plot what the wavelet coefficients detect.
    scatter(experiment.time(logical(jump_indicate)), signal(logical(jump_indicate)), 56, [1,0,0], 'filled')
    hold off;
    title(plotTitle, 'Interpreter', 'none')
    xlabel('Time (sec)','fontsize',24)
    ylabel('RSSI (dBm)','fontsize',24)
    set(gca,'fontsize',24)
    hold off;

end