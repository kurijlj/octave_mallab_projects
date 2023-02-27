function [W, info] = comp_mrs(f, w, J, scaling='sqrt')
% -----------------------------------------------------------------------------
%
% Function 'ufwt2':
%
% Use:
%       -- [M, info] = comp_mrs(f, w, J)
%       -- [M, info] = comp_mrs(f, w, J, scaling)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
%%  Define function name and use cases strings --------------------------------
    fname = 'comp_mrs';
    use_case_a = ' -- [M, info] = comp_mrs(f, w, J)';
    use_case_b = ' -- [M, info] = comp_mrs(f, w, J, scaling)';

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
    W = zeros(L, W, J + 1);
    W(:, :, 1) = f;

    runPtr = J + 1;
    jj = 1;
    while(J >= jj)
        % Zero index position of the upsampled filters.
        offset = w.a(1)^(jj-1).*(hOffset);

        % Run filterbank
        % First run on columns
        c = comp_atrousfilterbank_td(
            W(:, :, 1),
            hMat,
            w.a(1)^(jj-1),
            offset
            );

        % Run on rows
        c = comp_atrousfilterbank_td(
            squeeze(c(:, 1, :))',
            hMat,
            w.a(1)^(jj-1),
            offset
            );

        W(:, :, runPtr) = W(:, :, 1) - squeeze(c(:, 1, :))';
        W(:, :, 1) = squeeze(c(:, 1, :))';

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
