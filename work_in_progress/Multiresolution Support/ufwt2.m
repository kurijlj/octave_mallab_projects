function [A, V, H, D, info] = ufwt2(f, w, J, scaling='sqrt')
% -----------------------------------------------------------------------------
%
% Function 'ufwt2':
%
% Use:
%       -- [A, V, H, D, info] = ufwt2(f, w, J)
%       -- [A, V, H, D, info] = ufwt2(f, w, J, scaling)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
%%  Define function name and use cases strings --------------------------------
    fname = 'ufwt2';
    use_case_a = ' -- [A, V, H, D, info] = ufwt2(f, w, J)';
    use_case_b = ' -- [A, V, H, D, info] = ufwt2(f, w, J, scaling)';

%%  Add required packages to the path -----------------------------------------
    pkg load ltfat;

%%  Validate input arguments --------------------------------------------------
    % Check the number of input parameters
    if(3 ~= nargin && 4 ~= nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate input signal format
    validateattributes( ...
        f, ...
        {'float'}, ...
        { ...
            '2d', ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'f' ...
        );

    % Validate value(s) supplied for the wavelet filterbank definition
    try
        w = fwtinit(w);

    catch err
        error( ...
            '%s: %s', ...
            fname, ...
            err.message ...
            );

    end_try_catch;

    % This could be removed with some effort. The question is, are there such
    % wavelet filters? If your filterbank has different subsampling factors
    % after first two filters, please send a feature request.
    assert(
        w.a(1) == w.a(2),
        cstrcat(
            "First two elements of a vector 'w.a' are not equal. ",
            "Such wavelet filterbank is not suported."
            )
        );

    % For holding the time-reversed, complex conjugate impulse responses.
    filtNo = length(w.h);

    % Validate value supplied for the number of filterbank iterations
    validateattributes( ...
        J, ...
        {'numeric'}, ...
        { ...
            'scalar', ...
            'finite', ...
            'nonempty', ...
            'nonnan', ...
            'integer', ...
            'positive', ...
            '>=', 1 ...
            }, ...
        fname, ...
        'J' ...
        );

    % Validate value supplied for the filter scaling
    validatestring( ...
        scaling, ...
        {'noscale', 'scale', 'sqrt'}, ...
        fname, ...
        'scaling' ...
        );

%%  Verify length of the input signal -----------------------------------------
    if(2 > size(f, 1) || 2 > size(f, 2))
        error(
            '%s: Input signal seems not to be a matrix of at least 2x2 size.',
            fname
            );

    endif;

%%  Run computation -----------------------------------------------------------
    % Optionally scale the filters
    h = comp_filterbankscale(w.h(:), w.a(:), scaling);

    %Change format to a matrix
    hMat = cell2mat(cellfun(@(hEl) hEl.h(:), h(:)', 'UniformOutput', 0));

    % Delays
    hOffset = cellfun(@(hEl) hEl.offset, h(:));

    % Allocate output and mid result
    [L, W] = size(f);
    A = f;
    b = zeros(filtNo, W, filtNo, L, assert_classname(f, hMat));
    V = H = zeros(J, filtNo - 1, L, W, assert_classname(f, hMat));
    D = zeros(J, filtNo - 1, filtNo - 1, L, W, assert_classname(f, hMat));

    runPtr = J;
    jj = 1;
    while(J >= jj)
        % Zero index position of the upsampled filters.
        offset = w.a(1)^(jj-1).*(hOffset);

        % Run filterbank
        % First run on columns
        A = comp_atrousfilterbank_td(A, hMat, w.a(1)^(jj-1), offset);
        % Run on rows
        kk = 1;
        while(filtNo >= kk)
            b(kk, :, :, :) = comp_atrousfilterbank_td(
                squeeze(A(:, kk, :))',
                hMat,
                w.a(1)^(jj-1),
                offset
                );

            ++kk;

        endwhile;

        % Bokkeeping
        kk = 1;
        while(filtNo >= kk)
            ll = 1;
            while(filtNo >= ll)
                if(1 == kk)
                    if(1 == ll)
                        A = squeeze(b(1, :, 1, :))';
                    else
                        H(runPtr, ll - 1, :, :) = squeeze(b(1, :, ll, :))';
                    endif;
                else
                    if(1 == ll)
                        V(runPtr, kk - 1, :, :) = squeeze(b(kk, :, 1, :))';
                    else
                        D(runPtr, kk - 1, ll - 1, :, :) = squeeze(b(kk, :, ll, :))';
                    endif;
                endif;

                ++ll;;

            endwhile;

            ++kk;

        endwhile;

        --runPtr;
        ++jj;

    endwhile;

%%  Optionally : Fill info struct ---------------------------------------------
    if(nargout > 1)
        info.fname = 'ufwt2';
        info.wt = w;
        info.J = J;
        info.scaling = scaling;

    endif;

endfunction;
