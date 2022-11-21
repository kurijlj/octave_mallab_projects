function [ca, ch, cv, cd] = comp_ufwt2(f, h, a, J, scaling)
%COMP_UFWT Compute Undecimated DWT
%   Usage:  [ca, ch, cv, cd] = comp_ufwt(f, h, J, a);
%
%   Input parameters:
%       f    : Input data - L*W array.
%       h    : Analysis Wavelet filters - cell-array of length *filtNo*.
%       J    : Number of filterbank iterations.
%       a    : Subsampling factors - array of length *filtNo*.
%
%   Output parameters:
%       ca   : L*W array of approximation coefficients,.
%       ch   : L*W*M array of horizontal coefficients, where M = J*(filtNo - 1).
%       cv   : L*W*M array of vertical coefficients, where M = J*(filtNo - 1).
%       cd   : L*W*M array of diagonal coefficients, where M = J*(filtNo - 1).
%


    % This could be removed with some effort. The question is, are there such
    % wavelet filters? If your filterbank has different subsampling factors
    % after first two filters, please send a feature request
    assert( ...
        a(1) == a(2), ...
        sprintf( ...
            '%s %s', ...
            'First two elements of a are not equal.', ...
            'Such wavelet filterbank is not suported.' ...
            ) ...
        );

    % For holding the time-reversed, complex conjugate impulse responses
    filtNo = length(h);
    % Optionally scale the filters
    h = comp_filterbankscale(h(:), a(:), scaling);
    %Change format to a matrix
    hMat = cell2mat(cellfun(@(hEl) hEl.h(:), h(:)', 'UniformOutput', 0));

    % Delays
    hOffset = cellfun(@(hEl) hEl.offset, h(:));

    % Allocate output
    [L, W] = size(f);
    M = J*(filtNo - 1);
    ca = f;
    ch = cv = cd = zeros(L, W, M, assert_classname(f, hMat));

    % runPtr = M - (filtNo - 2);
    runPtr = jj = 1;
    while(J >= jj)
        % Current iteration filter downsampling factor
        filtDowns = a(1)^(jj - 1);

        % Zero index position of the upsampled filters
        offset = filtDowns.*(hOffset);

        % Calculate vertical coefficients
        c = comp_atrousfilterbank_td(ca, hMat, filtDowns, offset);

        % Bookkeeping for vertical coeficients
        ii = 0;
        while(filtNo - 2 >= ii)
            cv(:, :, runPtr + ii) = squeeze(c(:, end - ii, :));

            ++ii;

        endwhile;

        % Update approximation coefficients
        ca = squeeze(c(:, 1, :));

        % Calculate horizontal cefficients
        c = comp_atrousfilterbank_td(ca', hMat, filtDowns, offset);

        % Bookkeeping for horizontal cefficients
        ii = 0;
        while(filtNo - 2 >= ii)
            ch(:, :, runPtr + ii) = squeeze(c(:, end - ii, :))';

            ++ii;

        endwhile;

        % Update approximation coefficients
        ca = squeeze(c(:, 1, :))';

        % Calculate diagonal cefficients
        dd = 0;
        while(filtNo - 2 >= dd)
            c = comp_atrousfilterbank_td( ...
                cv(:, :, runPtr + dd)', ...
                hMat, ...
                filtDowns, ...
                offset ...
                );

            % Bookkeeping for diagonal cefficients
            ii = 0;
            while(filtNo - 2 >= ii)
                cd(:, :, runPtr + ii) = squeeze(c(:, end - ii, :))';

                ++ii;

            endwhile;

            % Update vertical coefficients
            cv(:, :, runPtr + dd) = squeeze(c(:, 1, :))';

            ++dd;

        endwhile;

        % Update pointer position
        runPtr = runPtr + (filtNo - 1);

        ++jj;

    endwhile;

endfunction;
