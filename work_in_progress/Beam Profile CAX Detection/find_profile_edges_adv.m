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

    % Validate number of passed arguments
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
            '%s: Nonconformant arguments (numel(x)=%d ~= numel(Dp)=%d)', ...
            fname, ...
            numel(x), ...
            numel(Dp) ...
            );

    endif;

    % We work with column vectors so reshape input arrays as column vectors,
    % if not
    if(1 == size(x, 1))
        x = x';

    endif;
    if(1 == size(Dp, 1))
        Dp = Dp';

    endif;

    % Calculate smalest detector step from the array of detector positions
    dstep = min(arrayfun(@(x, y) y-x, x(1:end-1, 1), x(2:end, 1)));

    % Calculate step for the data resampling
    rstep = dstep/4;

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

    % Assume that endpoints of the first derivates array does not differ
    % significantly from the neighboring points
    DpD1(1) = DpD1(2);
    DpD1(end) = DpD1(end - 1);

    % Segment left penumbra
    lROI = find(DpD1 >= 0.2*(max(DpD1)));

    % Fit Gaussian to fist derivates of the left penumbra
    c = polyfit(xR(lROI), log(DpD1(lROI)), 2);

    % Center of Gaussian represnets penumbra's mid point
    lE = -0.5*c(2)/c(1);

    % Segment right penumbra
    rROI = find(DpD1 < 0.2*(min(DpD1)));

    % Fit Gaussian
    c = polyfit(xR(rROI), log(abs(DpD1(rROI))), 2);

    % Calculate right field edge
    rE = -0.5*c(2)/c(1);

    % Plot results
    % plot(xR, DpR, xR, DpD1);
    % hold on;
    % plot([lE, lE], [min(DpD1)*2, max(DpR)*1.2], 'linestyle', '--', 'color', 'red');
    % plot([rE, rE], [min(DpD1)*2, max(DpR)*1.2], 'linestyle', '--', 'color', 'red');
    % hold off;

endfunction;
