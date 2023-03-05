function F = ufwt2denoise(f, w, J, varargin)
% -----------------------------------------------------------------------------
%
% Function 'ufwt2thresh':
%
% Use:
%       -- [Vt, Ht, Dt] = ufwt2thresh(f, wt, J)
%       -- [Vt, Ht, Dt] = ufwt2thresh(..., "PROPERTY", VALUE, ...)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
%%  Define function name and use cases strings --------------------------------
    fname = 'ufwt2denoise';
    use_case_a = sprintf(' -- F = %s(f, wt, J)', fname);
    use_case_b = sprintf( ...
        ' -- F = %s(..., "PROPERTY", VALUE, ...)', ...
        fname ...
        );

%%  Add required packages to the path -----------------------------------------
    pkg load image;
    pkg load ltfat;

%%  Validate input arguments --------------------------------------------------

    % Check positional parameters ---------------------------------------------

    % Check the number of positional parameters
    if(3 > nargin)
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

    % Check optional arguments (if any) ---------------------------------------

    % Parse optional arguments
    [ ...
        pos, ...
        scaling, ...
        thrtype, ...
        modifier, ...
        setype ...
        ] = parseparams( ...
        varargin, ...
        'FilterScaling', 'sqrt', ...
        'ThresholdType', 'hard', ...
        'Modifier', 'none', ...
        'SEType', 'x' ...
        );

    % We don't take any more positional arguments
    if(0 ~= numel(pos))
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate value supplied for the filter scaling
    validatestring( ...
        scaling, ...
        {'noscale', 'scale', 'sqrt'}, ...
        fname, ...
        'FilterScaling' ...
        );

    % Validate value supplied for the ThresholdType
    validatestring( ...
        thrtype, ...
        {'hard', 'soft'}, ...
        fname, ...
        'ThresholdType' ...
        );

    % Validate value supplied for the Modifier
    validatestring( ...
        modifier, ...
        {'none', 'erode', 'dilate'}, ...
        fname, ...
        'Modifier' ...
        );

    % Validate value supplied for the SEType
    validatestring( ...
        setype, ...
        {'.', '+', 'x', 'square'}, ...
        fname, ...
        'SEType' ...
        );

%%  Run computation -----------------------------------------------------------
    [A, V, H, D] = ufwt2(f, w, J, scaling);
    [V, H, D] = ufwt2thresh( ...
        V, H, D, ...
        'ThresholdType', thrtype, ...
        'Modifier', modifier, ...
        'SEType', setype ...
        );
    F = iufwt2(A, V, H, D, w, J, scaling);

endfunction;  % ufwt2denoise