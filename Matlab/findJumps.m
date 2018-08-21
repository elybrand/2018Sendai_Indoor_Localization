function [jumpUpLocs, jumpDownLocs, filtered_signal, noise] = findJumps(data, k)
% VARIABLES
%   data:           a N x 2 table with Time and SignalStrength data.
%   k:              (optional) Vector of wavelet scales. Must be integers.
%                   Default is one wavelet scale chosen dynamically to
%                   correspond to a time interval of roughly 5 seconds.
%
% Compares wavelet coefficients of filtered_signal to noise at scales 
% stored in the vector k. Returns a J x 2^k matrix where each row 
% corresponds to a range of indices in filtered_signal where a jump is 
% suspected.
    
    % This constant is really for pre-allocation purposes. Adjust it to
    % your needs.
    MAX_JUMPS = 100;
    
    % Get an estimate for sampling rate 
    rate = 1/median(diff(data.Time));
    if nargin < 2
        macro_scale = round(log2(5*rate));
        if macro_scale >= 3;
            k = [macro_scale-2, macro_scale-1, macro_scale];
        else
            k = macro_scale;
        end
        sprintf('Wavelet scales set to %i\n', k)
    end

    [filtered_signal, noise] = filterSignal(data);

    % Zero pad the filtered_signal and noise so that their length is a power of
    % 2.
    n = size(filtered_signal,1);
    N = ceil(log2(n));
    filtered_signal = [filtered_signal(:); zeros(N-n, 1)];
    noise = [noise(:); zeros(N-n,1)];

    [C, L] = wavedec(filtered_signal, max(k), 'haar');
    sig_coeffs = detcoef(C, L, k);

    [Cn, Ln] = wavedec(noise, max(k), 'haar');
    noise_coeffs = detcoef(Cn, Ln, k);
    
    jumpUpLocs = zeros(MAX_JUMPS, 2);
    jumpDownLocs = zeros(MAX_JUMPS, 2);
    up_ctr = 1;
    down_ctr = 1;
    
    alphas = zeros(size(k));
    alphas = alphas + 25;
    k = sort(k,'descend');
    for i=size(k(:),1):-1:1
        
        % MATLAB either returns a vector or a table depending on whether k
        % is a scalar or a vector.
        if size(k(:),1) == 1
            ck = sig_coeffs;
            cnk = noise_coeffs;
        else
            ck = sig_coeffs{i};
            cnk = noise_coeffs{i};
        end
        
        % Pick a cutoff threshold for a significant wavelet coefficient by looking
        % at those of the noise. Below, we choose the 1-alpha percentile.
        alpha = alphas(i);
        jump_cutoff = prctile(abs(cnk), 100-alpha);

        % Now find the significant wavelet coefficents from the filtered signal.
        [maxes, locs_max] = findpeaks(ck);
        % Check the endpoints too!
        maxes = [ck(1); maxes; ck(end)];
        locs_max = [1; locs_max; size(ck,1)];
        locs_max = locs_max(maxes > jump_cutoff);

    %     locs_max = find(ck > jump_cutoff);
         J_max = size(locs_max,1);

       [mins, locs_min] = findpeaks(-ck);
       % Check the endpoints too!
       mins = [-ck(1); mins; -ck(end)];
       locs_min = [1; locs_min; size(ck,1)];
       locs_min = locs_min(mins > jump_cutoff);
    %     locs_min = find(ck < -jump_cutoff);
       J_min = size(locs_min,1);

        % We are almost done. Locs right now corresponds to the coefficients'
        % indices within the coefficient vector. To put it back into the time
        % scale, we rescale locs accordingly. Wavelet coefficient j corresponds to
        % the range of indices [1+(j-1)2^k, j2^k] in filtered_signal.

        for j = 1:J_max
            x = locs_max(j);
            start = 1+(x-1)*2^k(i);
            stop = x*2^k(i);

            jumpUpLocs(up_ctr,:) = [start, stop];
            if x*2^k(i) >= size(data,1) % Stop index overflow.
                jumpUpLocs(up_ctr,:) = [start, size(data,1)];
                break;
            end
            up_ctr = up_ctr + 1;
        end

        for j = 1:J_min
            x = locs_min(j);
            jumpDownLocs(down_ctr,:) = [1+(x-1)*2^k(i), x*2^k(i)];
            if x*2^k(i) >= size(data,1) % Stop index overflow.
                jumpDownLocs(down_ctr,:) = [1+(x-1)*2^k(i), size(data,1)];
                break;
            end
            down_ctr = down_ctr + 1;
        end
        
%         m = size(k(:),1) - i;
%         if m < 3
%             %Plot the four highest scales' coefficients.
%             if m==0
%                 figure()
%                 p = min(size(k(:),1),4);
%                 set(gcf, 'Position', [900, 900, 500, 400])
%             end
%             subplot(p,1,m+1)
%             plot(ck, '-x', 'linewidth', 2)
%             % Plot cutoff line
%             line([1, size(ck,1)], [jump_cutoff, jump_cutoff],'LineWidth', 1, 'Color', [1,0,0])
%             line([1, size(ck,1)], [-jump_cutoff, -jump_cutoff],'LineWidth', 1, 'Color', [1,0,0])
%             title(sprintf('Wavelet Coefficients, k=%i (%0.2f sec)', k(i), 2^k(i)/rate))
%             xlabel('Coefficient Index','fontsize',24)
%             ylabel('Coefficient Value','fontsize',24)
%             set(gca,'fontsize',16)
%         end
    end
    
    jumpUpLocs = cleanUpIntervals(jumpUpLocs);
    jumpDownLocs = cleanUpIntervals(jumpDownLocs);

end