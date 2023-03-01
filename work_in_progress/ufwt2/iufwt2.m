function f = iufwt2(A, V, H, D, w, J, scaling='sqrt')
% -----------------------------------------------------------------------------
%
% Function 'iufwt2':
%
% Use:
%       -- f = iufwt2(A, V, H, D, w, J)
%       -- f = iufwt2(A, V, H, D, w, J, scaling)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
%%  Define function name and use cases strings --------------------------------
    fname = 'iufwt2';
    use_case_a = ' -- f = iufwt2(A, V, H, D, w, J)';
    use_case_b = ' -- f = iufwt2(A, V, H, D, w, J, scaling)';

%%  Add required packages to the path -----------------------------------------
    pkg load ltfat;

%%  Validate input arguments --------------------------------------------------
    % Check the number of input parameters
    if(6 ~= nargin && 7 ~= nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

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
    filtNo = length(w.g);

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

    % Validate input coeficients format
    validateattributes( ...
        A, ...
        {'float'}, ...
        { ...
            '2d', ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'A' ...
        );

    [L, W] = size(A);

    validateattributes( ...
        V, ...
        {'float'}, ...
        { ...
            'ndims', 4, ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'V' ...
        );

    if(J ~= size(V, 1))
        error(
            cstrcat(
                fname,
                ": Number of levels in the coefficients matrix V does not",
                " match given number of filterbank iterations J."
                )
            );

    elseif((filtNo - 1) ~= size(V, 2))
        error(
            cstrcat(
                fname,
                ": Number of coefficients in the coefficients matrix V does",
                " not match number of filterbank filters."
                )
            );

    elseif(L ~= size(V, 3) || W ~= size(V, 4))
        error(
            cstrcat(
                fname,
                ": Size of coefficients matrix V does not match the size of",
                " residuals matrix A."
                )
            );

    endif;

    validateattributes( ...
        H, ...
        {'float'}, ...
        { ...
            'ndims', 4, ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'H' ...
        );

    if(J ~= size(H, 1))
        error(
            cstrcat(
                fname,
                ": Number of levels in the coefficients matrix H does not",
                " match given number of filterbank iterations J."
                )
            );

    elseif((filtNo - 1) ~= size(H, 2))
        error(
            cstrcat(
                fname,
                ": Number of coefficients in the coefficients matrix H does",
                " not match number of filterbank filters."
                )
            );

    elseif(L ~= size(H, 3) || W ~= size(H, 4))
        error(
            cstrcat(
                fname,
                ": Size of coefficients matrix H does not match the size of",
                " residuals matrix A."
                )
            );

    endif;

    validateattributes( ...
        D, ...
        {'float'}, ...
        { ...
            'ndims', 5, ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'D' ...
        );

    if(J ~= size(D, 1))
        error(
            cstrcat(
                fname,
                ": Number of levels in the coefficients matrix D does not",
                " match given number of filterbank iterations J."
                )
            );

    elseif((filtNo - 1) ~= size(D, 2) || (filtNo - 1) ~= size(D, 3))
        error(
            cstrcat(
                fname,
                ": Number of coefficients in the coefficients matrix D does",
                " not match number of filterbank filters."
                )
            );

    elseif(L ~= size(D, 4) || W ~= size(D, 5))
        error(
            cstrcat(
                fname,
                ": Size of coefficients matrix D does not match the size of",
                " residuals matrix A."
                )
            );

    endif;

    % Validate value supplied for the filter scaling
    validatestring( ...
        scaling, ...
        {'noscale', 'scale', 'sqrt'}, ...
        fname, ...
        'scaling' ...
        );

    % Use the "oposite" scaling
    if strcmp(scaling,'scale')
        scaling = 'noscale';
    elseif strcmp(scaling,'noscale')
        scaling = 'scale';
    endif;

%%  Run computation -----------------------------------------------------------
    % For holding the impulse responses.
    gOffset = cellfun(@(gEl) gEl.offset, w.g(:));

    % Optionally scale the filters
    g = comp_filterbankscale(w.g(:), w.a(:), scaling);

    % Change format to a matrix
    gMat = cell2mat(cellfun(@(gEl) gEl.h(:), g(:)', 'UniformOutput', 0));

    % Allocate mid result
    d = zeros(L, filtNo, W);
    e = zeros(filtNo, W, filtNo, L, assert_classname(A, gMat));

    % Read top-level appr. coefficients.
    ca = A;
    jj = 1;
    while(J >= jj)
        % Current iteration filter upsampling factor.
        filtUps = w.a(1)^(J-jj);

        % Zero index position of the upsampled filetrs.
        offset = filtUps.*gOffset ;%+ filtUps;

        % Run the filterbank
        % Reconstruct rows
        kk = 1;
        while(filtNo >= kk)
            ll = 1;
            while(filtNo >= ll)
                if(1 == kk)
                    if(1 == ll)
                        e(1, :, 1, :) = reshape(ca', 1, W, 1, L);
                    else
                        e(1, :, ll, :) = reshape(squeeze(H(jj, ll - 1, :, :))', 1, W, 1, L);
                    endif;
                else
                    if(1 == ll)
                        e(kk, :, 1, :) = reshape(squeeze(V(jj, kk - 1, :, :))', 1, W, 1, L);
                    else
                        e(kk, :, ll, :) = reshape(squeeze(D(jj, kk - 1, ll - 1, :, :))', 1, W, 1, L);
                    endif;
                endif;

                ++ll;

            endwhile;

            ++kk;

        endwhile;

        % Reconstruct columns
        kk = 1;
        while(filtNo >= kk)
            ie = comp_iatrousfilterbank_td(
                squeeze(e(kk, :, :, :)),
                gMat,
                filtUps,
                offset
                )';
            % size(ie)
            d(:, kk, :) = reshape(ie, L, 1, W);

            ++kk;

        endwhile;

        ca = comp_iatrousfilterbank_td(d, gMat, filtUps, offset);

        ++jj;

    endwhile;

    % Copy to the output.
    f = ca;

endfunction;
