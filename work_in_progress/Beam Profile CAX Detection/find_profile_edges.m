function [lE, rE] = find_profile_edges(x, Dp)
% -----------------------------------------------------------------------------
%
% Function 'find_profile_edges':
%
% Use:
%       -- [lE, rE] = find_profile_edges(x, Dp)
%
% Description:
%       Find field edges from the 1D beam profile.
%
%       x  1D array representing detector positions in milimeters in the water
%          tank during beam scanning procedure.
%
%       Dp 1D array representing detector reading for the given detector
%          positions in the water tank during beam scanning procedure.
%
% -----------------------------------------------------------------------------
    fname = 'find_profile_edges';
    use_case_a = sprintf('-- [lE, rE] = %s(x, Dp)', fname);

    if(2 ~= nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case_a ...
            );

    endif;

    % Validate detector positions array
    validateattributes( ...
        x, ...
        {'float'}, ...
        { ...
            'nonempty', ...
            '2d', ...
            'vector', ...
            'finite', ...
            'real' ...
            }, ...
        fname, ...
        'x' ...
        );

    % Validate detector reading array
    validateattributes( ...
        x, ...
        {'float'}, ...
        { ...
            'nonempty', ...
            '2d', ...
            'vector', ...
            'finite', ...
            'real' ...
            }, ...
        fname, ...
        'x' ...
        );

    % Validate that inupt arrays match in number of elements
    if(numel(x) ~= numel(Dp))
        error( ...
            '%s: Arrays x and Dp must have same number of elements (%d ~= %d)', ...
            fname, ...
            numel(x), ...
            numel(Dp) ...
            );

    endif;

    % We work with coumn vectors so reshape input arrays as column vectors,
    % if not
    if(1 == size(x, 1))
        x = x';

    endif;
    if(1 == size(Dp, 1))
        Dp = Dp';

    endif;

    % Calculate minimal detector step from the array of detector positions
    dstep = min(arrayfun(@(x, y) y-x, x(1:end-1, 1), x(2:end, 1)));

    % Calculate minimum step for the data resampling
    rstep = dstep / 16;

    % Resample imput data to get smoother numerical derivates
    xR   = x(1):rstep:x(end);
    DpR  = interp1(x, Dp, xR, 'spline');

    % Normalize profile data if not normalized
    if(100.00 ~= max(DpR))
        DpR = DpR * 100 / max(DpR);

    endif;

    % Calculate the first derivate of the data
    DpD1 = zeros(size(DpR));
    idx = 2;
    while(numel(DpR)-1 >= idx)
        DpD1(idx) = (DpR(idx+1) - DpR(idx-1))/(2*rstep);

        ++idx;

    endwhile;
    DpD1(1) = DpD1(2);
    DpD1(end) = DpD1(end - 1);

    % Calculate the second derivate of the data
    % DpD2 = zeros(size(DpR));
    % idx = 2;
    % while(numel(DpR)-1 >= idx)
    %     DpD2(idx) = (DpR(idx+1) - 2*DpR(idx) + DpR(idx-1))/(rstep^2);

    %     ++idx;

    % endwhile;
    % DpD2(1) = DpD2(2);
    % DpD2(end) = DpD2(end - 1);

    % Calculate the third derivate of the data
    % DpD3 = zeros(size(DpR));
    % idx = 3;
    % while(numel(DpR)-2 >= idx)
    %     DpD3(idx) = (DpR(idx+2) - 2*DpR(idx+1) + 2*DpR(idx-1) - DpR(idx-2))/(2*rstep^3);

    %     ++idx;

    % endwhile;
    % DpD3(1) = DpD3(2) = DpD3(3);
    % DpD3(end) = DpD3(end - 1) = DpD3(end - 2);

    % plot(xR, DpR, xR, DpD1);
    % plot(xR, DpR, xR, DpD1, xR, DpD2, xR, DpD3);

    % Segment left penumbra derivate values
    lROI = find(DpD1 >= 0.2*(max(DpD1)));
    c = polyfit(xR(lROI), log(DpD1(lROI)), 2);
    % sigma = sqrt(-0.5/c(1))
    % mu = -0.5*c(2)/c(1)
    % A = exp(c(3) - (c(2)^2)/(4*c(1)))
    % fit = arrayfun(@(x) A*exp(-0.5*((x - mu)/sigma)^2), xR(lROI));
    % plot(xR(lROI), DpD1(lROI), xR(lROI), fit);
    lE = -0.5*c(2)/c(1);

    rROI = find(DpD1 < 0.2*(min(DpD1)));
    c = polyfit(xR(rROI), log(abs(DpD1(rROI))), 2);
    rE = -0.5*c(2)/c(1);
    % sigma = sqrt(-0.5/c(1))
    % mu = -0.5*c(2)/c(1)
    % A = exp(c(3) - (c(2)^2)/(4*c(1)))
    % fit = arrayfun(@(x) -A*exp(-0.5*((x - mu)/sigma)^2), xR(rROI));
    % plot(xR(rROI), DpD1(rROI), xR(rROI), fit);

    plot(xR, DpR, xR, DpD1);
    hold on;
    plot([lE, lE], [min(DpD1)*2, max(DpR)*1.2], 'linestyle', '--', 'color', 'red');
    plot([rE, rE], [min(DpD1)*2, max(DpR)*1.2], 'linestyle', '--', 'color', 'red');
    hold off;

endfunction;
