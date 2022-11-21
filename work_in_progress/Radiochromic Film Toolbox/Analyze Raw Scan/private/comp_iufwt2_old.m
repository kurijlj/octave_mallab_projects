function f = comp_iufwt2(ca, cv, g, a, J, scaling)
%COMP_IUFWT Compute Inverse Undecimated DWT
%   Usage:  f = comp_iufwt2(ca, cv, g, a, J, scaling);
%
%   Input parameters:
%         ca     : L*W array of approximation coefficients.
%         cv     : L*W*M array of vertical coefficients, M = J*(filtNo - 1).
%         g     : Synthesis wavelet filters-Cell-array of length *filtNo*.
%         J     : Number of filterbank iterations.
%         a     : Upsampling factors - array of length *filtNo*.
%
%   Output parameters:
%         f     : Reconstructed data - L*W array.
%
%

    % see comp_fwt2 for explanantion
    assert( ...
        a(1) == a(2), ...
        sprintf( ...
            '%s %s', ...
            'First two elements of a are not equal.', ...
            'Such wavelet filterbank is not suported.' ...
            ) ...
        );

    % For holding the impulse responses.
    filtNo = length(g);
    gOffset = cellfun(@(gEl) gEl.offset, g(:));

    % Optionally scale the filters
    g = comp_filterbankscale(g(:), a(:), scaling);

    %Change format to a matrix
    gMat = cell2mat(cellfun(@(gEl) gEl.h(:), g(:)', 'UniformOutput', 0));

    c = ca;
    cRunPtr = 1;
    jj = J;
    while(1 <= jj)
        % Current iteration filter upsampling factor.
        filtUps = a(1)^(jj - 1);

        % Zero index position of the upsampled filetrs.
        offset = filtUps.*gOffset ;%+ filtUps;

        % Rearrange vertical coeficients
        ii = 0;
        cr = zeros(size(cv, 1), filtNo - 1, size(cv, 2));
        while(filtNo - 2 >= ii)
            cvr(:, ii + 1, :) = reshape( ...
                cv(:, :, cRunPtr + ii), ...
                size(cv, 1), ...
                1, ...
                size(cv, 2) ...
                );
            ++ii;

        endwhile;

        % Run the filterbank
        c = comp_iatrousfilterbank_td( ...
            [ ...
                reshape(c, size(c, 1), 1, size(c, 2)), ...
                cr ...
                ], ...
            gMat, ...
            filtUps, ...
            offset ...
            );

        % Bookkeeping
        cRunPtr = cRunPtr + (filtNo - 1);

        --jj;

     endwhile;

     % Copy to the output.
     f = c;

endfunction;
