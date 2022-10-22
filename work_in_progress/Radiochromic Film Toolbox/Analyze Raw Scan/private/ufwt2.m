% -----------------------------------------------------------------------------
%
% Function 'ufwt2':
%
% Use:
%       -- [A, H, V, D] = ufwt2(f, w, J, fs)
%
% Description:
%       Performs a multilevel 2-D stationary wavelet decomposition of the input
%       signal f using wavelet filters defined by w. The input signal must be
%       of the type float.
%
%       For all accepted formats of the parameter w see the fwtinit function of
%       the package 'ltfat'.
%
%       For all accepted formats of the parameter fs see the ufwt function of
%       the package 'ltfat'.
%
%       Outputs [A,H,V,D] are 3-D arrays, which contain the coefficients:
%           i) For 1 <= i <= J, the output matrix A(:,:,i) contains
%              the coefficients of approximation of level i;
%          ii) The output matrices H(:,:,i), V(:,:,i) and D(:,:,i) contain
%              the coefficients of details of level i (Horizontal, Vertical
%              and Diagonal):
%
%       The function requires 'ltfat' package installed to work.
%
% -----------------------------------------------------------------------------
function [A, H, V, D] = ufwt2(f, w, J, fs='sqrt')
    fname = 'ufwt2';
    use_case_a = ' -- ufwt2(f, w, J)';
    use_case_b = ' -- ufwt2(f, w, J, fs)';

    % Validate input arguments ------------------------------------------------

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
        fs, ...
        {'noscale', 'scale', 'sqrt'}, ...
        fname, ...
        'fs' ...
        );

    % Add required packages to the path ---------------------------------------
    pkg load ltfat;

    % Decompose the input signal ----------------------------------------------
    A = H = V = D = zeros(size(f, 1), size(f, 2), J);

    idx = 1;
    while(J >= idx)
        c = [];

        if(1 == idx)
            c = ufwt(f, w, 1, fs);

        else
            c = ufwt(A(:, :, idx - 1), w, 1, fs);

        endif;

        lp_dn1 = [reshape(c(:, 1, :), size(c, 1), size(c, 3));];
        hp_dn1 = [reshape(c(:, 2, :), size(c, 1), size(c, 3));];

        c = ufwt(lp_dn1', w, 1, fs);
        A(:, :, idx) = [reshape(c(:, 1, :), size(c, 1), size(c, 3))';];
        H(:, :, idx) = [reshape(c(:, 2, :), size(c, 1), size(c, 3))';];

        c = ufwt(hp_dn1', w, 1, fs);
        V(:, :, idx) = [reshape(c(:, 1, :), size(c, 1), size(c, 3))';];
        D(:, :, idx) = [reshape(c(:, 2, :), size(c, 1), size(c, 3))';];

    ++idx;

    endwhile;

endfunction;
