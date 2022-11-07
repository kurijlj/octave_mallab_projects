% -----------------------------------------------------------------------------
%
% Function 'iufwt2':
%
% Use:
%       -- f = iufwt2(A, H, V, D, w, fs)
%
% Description:
%       Performs a multilevel 2-D stationary wavelet reconstruction of the
%       signal f using wavelet filters defined by w.
%
%       For all accepted formats of the parameter w see the fwtinit function of
%       the package 'ltfat'.
%
%       For all accepted formats of the parameter fs see the ufwt function of
%       the package 'ltfat'.
%
%       The function requires 'ltfat' package installed to work.
%
% -----------------------------------------------------------------------------
function f = iufwt2(A, H, V, D, w, fs='sqrt')
    fname = 'iufwt2';
    use_case_a = ' -- iufwt2(A, H, V, D, w)';
    use_case_b = ' -- iufwt2(A, H, V, D, w, fs)';

    % Validate input arguments ------------------------------------------------

    % Check the number of input parameters
    if(5 ~= nargin && 6 ~= nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate input coeficients format
    validateattributes( ...
        A, ...
        {'float'}, ...
        { ...
            '3d', ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'A' ...
        );
    validateattributes( ...
        H, ...
        {'float'}, ...
        { ...
            '3d', ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'H' ...
        );
    validateattributes( ...
        V, ...
        {'float'}, ...
        { ...
            '3d', ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'V' ...
        );
    validateattributes( ...
        D, ...
        {'float'}, ...
        { ...
            '3d', ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'D' ...
        );

    % All cofiecients must match in size
    if(size(A) ~= size(H))
        error( ...
            '%s: Coeficiens matrix H size does not match that of A', ...
            fname ...
            );
    elseif(size(A) ~= size(V))
        error( ...
            '%s: Coeficiens matrix V size does not match that of A', ...
            fname ...
            );
    elseif(size(A) ~= size(D))
        error( ...
            '%s: Coeficiens matrix D size does not match that of A', ...
            fname ...
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

    % Validate value supplied for the filter scaling
    validatestring( ...
        fs, ...
        {'noscale', 'scale', 'sqrt'}, ...
        fname, ...
        'fs' ...
        );

    % Add required packages to the path ---------------------------------------
    pkg load ltfat;

    % Reconstruct the signal f ------------------------------------------------
    a = zeros(size(A));
    a(:, :, end) = A(:, :, end);
    idx = size(A, 3);
    while(1 <= idx)
        v = V(:, :, idx)';
        d = D(:, :, idx)';
        c = zeros(size(v, 1), 2, size(v, 2));
        c(:, 1, :) = reshape(v, size(v, 1), 1, size(v, 2));
        c(:, 2, :) = reshape(d, size(d, 1), 1, size(d, 2));
        hpr = iufwt(c, w, 1, fs)';

        h = H(:, :, idx)';
        c(:, 1, :) = reshape( ...
            a(:, :, idx)', ....
            size(a(:, :, idx)', 1), ...
            1, ...
            size(a(:, :, idx)', 2) ...
            );
        c(:, 2, :) = reshape(h, size(h, 1), 1, size(h, 2));
        lpr = iufwt(c, w, 1, fs)';

        c = zeros(size(lpr, 1), 2, size(lpr, 2));
        c(:, 1, :) = reshape(lpr, size(lpr, 1), 1, size(lpr, 2));
        c(:, 2, :) = reshape(hpr, size(hpr, 1), 1, size(hpr, 2));

        if(1 == idx)
            f = iufwt(c, w, 1, fs);

        else
            a(:, :, idx - 1) = iufwt(c, w, 1, fs);

        endif;

        --idx;

    endwhile;

endfunction;