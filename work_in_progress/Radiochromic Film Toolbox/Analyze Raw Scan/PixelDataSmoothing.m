% -----------------------------------------------------------------------------
%
% Class 'PixelDataSmoothing':
%
% Description:
%       TODO: Add class descritpion here.
%
% -----------------------------------------------------------------------------
classdef PixelDataSmoothing

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (SetAccess = private, GetAccess = public)
        % Pixel data smoothing title (unique ID)
        title   = 'None';
        % Smoothing method (algorithm) ('None', 'Median', 'Wiener', 'Wavelet')
        method  = 'None';
        % Smoothing window ('[] if method = 'None' or method = 'Wavelet')
        window  = [];
        % Wavelet filter bank ('db8' if 'Wavelet' selected for the method,
        % otherwise 'None')
        flt_bnk = 'None';
        % Iterations (number of filter bank iterations; for more information
        % see: https://octave.sourceforge.io/ltfat/function/fwt2.html)
        iter_no = 0;
        % Lambda (value used for thresholding operation; for more information
        % see: https://octave.sourceforge.io/ltfat/function/thresh.html)
        lambda = 0;
        % Thresholding type ('hard', 'wiener', 'soft', 'full', 'sparse'; Default
        % is 'hard'; for more information see:
        % https://octave.sourceforge.io/ltfat/function/thresh.html)
        tr_type = 'None';

    endproperties;

% -----------------------------------------------------------------------------
%
% Public methods section
%
% -----------------------------------------------------------------------------
    methods (Access = public)

% -----------------------------------------------------------------------------
%
% Method 'PixelDataSmoothing':
%
% Use:
%       -- ds = PixelDataSmoothing()
%       -- ds = PixelDataSmoothing(..., "PROPERTY", VALUE, ...)
%       -- ds = PixelDataSmoothing(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function ds = PixelDataSmoothing(varargin)
            fname = 'PixelDataSmoothing';
            use_case_a = ' -- ds = PixelDataSmoothing()';
            use_case_b = ' -- ds = PixelDataSmoothing(..., "PROPERTY", VALUE, ...)';
            use_case_c = ' -- ds = PixelDataSmoothing(other)';

            if(0 == nargin)
                % Default constructor invoked ---------------------------------

            elseif(1 == nargin)
                if(isa(varargin{1}, 'PixelDataSmoothing'))
                    % Copy constructor invoked
                    ds.title   = varargin{1}.title;
                    ds.method  = varargin{1}.method;
                    ds.window  = varargin{1}.window;
                    ds.flt_bnk = varargin{1}.flt_bnk;
                    ds.iter_no = varargin{1}.iter_no;
                    ds.lambda  = varargin{1}.lambda;
                    ds.tr_type = varargin{1}.tr_type;

                else
                    % Invalid call to constructor
                    error( ...
                        'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
                        fname, ...
                        use_case_a, ...
                        use_case_b, ...
                        use_case_c ...
                        );

                endif;

            elseif(2 <= nargin && 14 >= nargin)
                % Regular constructor invoked ---------------------------------

                % Parse arguments
                [ ...
                    pos, ...
                    title, ...
                    method, ...
                    window, ...
                    flt_bnk, ...
                    iter_no, ...
                    lambda, ...
                    tr_type ...
                    ] = parseparams( ...
                    varargin, ...
                    'Title', 'None', ...
                    'Method', 'None', ...
                    'Window', [], ...
                    'FilterBank', 'None', ...
                    'Iterations', 0, ...
                    'Lambda', 0, ...
                    'ThresholdType', 'None' ...
                    );

                if(0 ~= numel(pos))
                    % Invalid call to constructor
                    error( ...
                        'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
                        fname, ...
                        use_case_a, ...
                        use_case_b, ...
                        use_case_c ...
                        );

                endif;

                % Validate value supplied for the Title
                if(~ischar(title) || isempty(title))
                    error('%s: Title must be a non-empty string', fname);

                endif;

                % Validate value supplied for the Method
                validatestring( ...
                    method, ...
                    {'None', 'Median', 'Wiener', 'Wavelet'}, ...
                    fname, ...
                    'Method' ...
                    );

                % Validate value supplied for the Window
                if(isequal('None', method) || isequal('Wavelet', method))
                    % For these options window must be an empty vector
                    if(~isempty(window))
                        warning( ...
                            '%s: Method "%s" does not support nonempty window', ...
                            fname, ...
                            method ...
                            );

                    endif;

                    % Reset to default
                    window = [];

                else
                    % If window is empty assign the default value
                    if(isempty(window))
                        window = [5 5];

                    endif;

                    validateattributes( ...
                        window, ...
                        {'numeric'}, ...
                        { ...
                            'vector', ...
                            'numel', 2, ...
                            'integer', ...
                            '>=', 1 ...
                            }, ...
                        fname, ...
                        'window' ...
                        );

                endif;

                % Validate value supplied for the FilterBank
                if(~isequal('Wavelet', method))
                    % FilterBank option is not needed for other than Wavelet
                    if(~isequal('None', flt_bnk))
                        warning( ...
                            '%s: FilterBank option not supported for the given method: %s', ...
                            fname, ...
                            method ...
                            );

                    endif;

                    % reset to default
                    flt_bnk = 'None';

                else
                    % Use the default value if 'None' assigned
                    if(isequal('None', flt_bnk))
                        flt_bnk = 'algmband1';

                    endif;

                    if(~ischar(flt_bnk) || isempty(flt_bnk))
                        error( ...
                            '%s: flt_bnk must be a non-empty string', ...
                            fname ...
                            );

                    endif;

                endif;

                % Validate value supplied for the Iterations
                if(~isequal('Wavelet', method))
                    % Iterations option is not needed for other than Wavelet
                    if(0 ~= iter_no)
                        warning( ...
                            '%s: Iterations option not supported for the given method: %s', ...
                            fname, ...
                            method ...
                            );

                    endif;

                    % reset to default
                    iter_no = 0;

                else
                    % Use the default value if 'None' assigned
                    if(0 == iter_no)
                        iter_no = 3;

                    endif;

                    validateattributes( ...
                        iter_no, ...
                        {'numeric'}, ...
                        { ...
                            'nonempty', ...
                            'nonnan', ...
                            'scalar', ...
                            'integer', ...
                            'finite', ...
                            '>=', 1 ...
                            }, ...
                        fname, ...
                        'Iterations' ...
                        );
                endif;

                % Validate value supplied for the Lambda
                if(~isequal('Wavelet', method))
                    % Lambda option is not needed for other than Wavelet
                    if(0 ~= lambda)
                        warning( ...
                            '%s: Lambda option not supported for the given method: %s', ...
                            fname, ...
                            method ...
                            );

                    endif;

                    % reset to default
                    lambda = 0;

                else
                    % Use the default value if 'None' assigned
                    if(0 == lambda)
                        lambda = 2000;

                    endif;

                    validateattributes( ...
                        lambda, ...
                        {'numeric'}, ...
                        { ...
                            'nonempty', ...
                            'nonnan', ...
                            'scalar', ...
                            'integer', ...
                            'finite', ...
                            '>=', 0 ...
                            }, ...
                        fname, ...
                        'Lambda' ...
                        );
                endif;

                % Validate value supplied for the ThresholdType
                if(~isequal('Wavelet', method))
                    % FilterBank option is not needed for other than Wavelet
                    if(~isequal('None', tr_type))
                        warning( ...
                            '%s: ThresholdType option not supported for the given method: %s', ...
                            fname, ...
                            method ...
                            );

                    endif;

                    % reset to default
                    tr_type = 'None';

                else
                    % Use the default value if 'None' assigned
                    if(isequal('None', tr_type))
                        tr_type = 'hard';

                    endif;

                    validatestring( ...
                        tr_type, ...
                        {'hard', 'wiener', 'soft', 'full', 'sparse'}, ...
                        fname, ...
                        'ThresholdType' ...
                        );

                endif;

                % Assign values to a new instance -----------------------------
                ds.title   = title;
                ds.method  = method;
                ds.window  = window;
                ds.flt_bnk = flt_bnk;
                ds.iter_no = iter_no;
                ds.lambda  = lambda;
                ds.tr_type = tr_type;

            else
                % Invalid call to constructor
                error( ...
                    'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
                    fname, ...
                    use_case_a, ...
                    use_case_b, ...
                    use_case_c ...
                    );

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- ds.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(ds)
            printf('\tPixelDataSmoothing(\n');
            if(ds.isnone())
                printf('\t\tTitle:  %s,\n', ds.title);
                printf('\t\tMethod: %s\n', ds.method);

            elseif(isequal('Wavelet', ds.method))
                printf('\t\tTitle:          %s,\n', ds.title);
                printf('\t\tMethod:         %s,\n', ds.method);
                printf('\t\tFilter bank:    %s,\n', ds.flt_bnk);
                printf('\t\tIterations:     %d,\n', ds.iter_no);
                printf('\t\tLambda:         %d,\n', ds.lambda);
                printf('\t\tThreshold type: %s\n', ds.tr_type);

            else
                win = '';
                if(isempty(ds.window))
                    win = '[]';

                else
                    win = sprintf( ...
                        '[%d %d]', ...
                        ds.window(1), ...
                        ds.window(2) ...
                        );

                endif;

                printf('\t\tTitle:  %s,\n', ds.title);
                printf('\t\tMethod: %s,\n', ds.method);
                printf('\t\tWindow: %s\n', win);

            endif;
            printf('\t)\n');

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp_short':
%
% Use:
%       -- ds.disp_short()
%
% Description:
%          A convenience method used to display shorthand info about the
%          instances of the type PixelDataSmoothing.
%
% -----------------------------------------------------------------------------
        function disp_short(ds)
            win = '';
            if(isempty(ds.window))
                win = '[]';

            else
                win = sprintf( ...
                    '[%d %d]', ...
                    ds.window(1), ...
                    ds.window(2) ...
                    );

            endif;

            printf('PixelDataSmoothing(%s)', ds.title);

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'cellarray':
%
% Use:
%       -- cds = ds.cellarry()
%
% Description:
%          Return smoothing object structure as cell array.
%
% -----------------------------------------------------------------------------
        function cds = cellarray(ds)
            cds = {};
            cds = { ...
                ds.title, ...
                ds.method, ...
                ds.window, ...
                ds.wavelet, ...
                flt_bnk, ...
                iter_no, ...
                lambda, ...
                tr_type; ...
                };

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isnone':
%
% Use:
%       -- result = ds.isnone()
%
% Description:
%          Return whether the PixelDataSmoothing object is 'None' or not.
%          PixelDataSmoothing instance is None if it's method is equal to
%          'None'.
%
% -----------------------------------------------------------------------------
        function result = isnone(ds)
            result = isequal('None', ds.method);

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = ds.isequivalent(other)
%
% Description:
%          Return whether or not two PixelDataSmoothing instances are
%          equivalent. Two instances are equivalent if they have identical
%          titles.
% -----------------------------------------------------------------------------
        function result = isequivalent(ds, other)
            fname = 'isequivalent';

            if(~isa(other, 'PixelDataSmoothing'))
                error( ...
                    '%s: other must be an instance of the "PixelDataSmoothing" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if(isequal(ds.title, other.title));
                result = true;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = ds.isequal(other)
%
% Description:
%          Return whether or not two 'PixelDataSmoothing' instances are equal.
%          Two instances are equal if all of their fields have identical values.
%
% -----------------------------------------------------------------------------
        function result = isequal(ds, other)
            fname = 'isequal';

            if(~isa(other, 'PixelDataSmoothing'))
                error( ...
                    '%s: other must be an instance of the "PixelDataSmoothing" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if( ...
                    isequal(ds.title, other.title) ...
                    && isequal(ds.method, other.method) ...
                    && isequal(ds.window, other.window) ...
                    && isequal(ds.wavelet, other.wavelet) ...
                    )
                result = true;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'smooth':
%
% Use:
%       -- sim = ds.smooth(im)
%
% Description:
%          Return smoothed pixel data of image im.
%
% -----------------------------------------------------------------------------
        function sim = smooth(ds, im)
            fname = 'smooth';

            % Validate input pixel data
            validateattributes( ...
                im, ...
                {'numeric'}, ...
                { ...
                    'finite', ...
                    'nonempty', ...
                    'nonnan', ...
                    'nonnegative', ...
                    'positive', ...
                    'integer' ...
                    }, ...
                fname, ...
                'im' ...
                );

            % Load required package
            pkg load image;

            % Initilize data structure for the resulting image
            sim = zeros(size(im));

            if(isbw(im))
                if(isequal('Median', ds.method))
                    % Smooth data using median filter
                    sim = medfilt2(im, ds.window);

                elseif(isequal('Wiener', ds.method))
                    % Smooth data using wiener filter
                    sim = wiener2(im, ds.window);

                elseif(isequal('Wavelet', ds.method))
                    % Load required package
                    pkg load ltfat;

                    cf = fwt2(double(im), ds.flt_bnk, ds.iter_no);
                    cf = thresh(cf, ds.lambda);
                    sim = ifwt2( ...
                        cf, ...
                        ds.flt_bnk, ...
                        ds.iter_no, ...
                        [size(im, 1), size(im, 2)] ...
                        );

                else
                    % No filtering
                    sim = im;

                endif;

            elseif(isrgb(im))
                if(isequal('Median', ds.method))
                    % Smooth data using median filter
                    sim(:, :, 1) = medfilt2(im(:, :, 1), ds.window);
                    sim(:, :, 2) = medfilt2(im(:, :, 2), ds.window);
                    sim(:, :, 3) = medfilt2(im(:, :, 3), ds.window);

                elseif(isequal('Wiener', ds.method))
                    % Smooth data using wiener filter
                    sim(:, :, 1) = wiener2(im(:, :, 1), ds.window);
                    sim(:, :, 2) = wiener2(im(:, :, 2), ds.window);
                    sim(:, :, 3) = wiener2(im(:, :, 3), ds.window);

                elseif(isequal('Wavelet', ds.method))
                    % Load required package
                    pkg load ltfat;

                    R_cf = fwt2(double(im(:, :, 1)), ds.flt_bnk, ds.iter_no);
                    G_cf = fwt2(double(im(:, :, 2)), ds.flt_bnk, ds.iter_no);
                    B_cf = fwt2(double(im(:, :, 3)), ds.flt_bnk, ds.iter_no);
                    R_cf = thresh(R_cf, ds.lambda);
                    G_cf = thresh(G_cf, ds.lambda);
                    B_cf = thresh(B_cf, ds.lambda);
                    sim(:, :, 1) = ifwt2( ...
                        R_cf, ...
                        ds.flt_bnk, ...
                        ds.iter_no, ...
                        [size(im, 1), size(im, 2)] ...
                        );
                    sim(:, :, 2) = ifwt2( ...
                        G_cf, ...
                        ds.flt_bnk, ...
                        ds.iter_no, ...
                        [size(im, 1), size(im, 2)] ...
                        );
                    sim(:, :, 3) = ifwt2( ...
                        B_cf, ...
                        ds.flt_bnk, ...
                        ds.iter_no, ...
                        [size(im, 1), size(im, 2)] ...
                        );

                else
                    % No filtering
                    sim = im;

                endif;

            else
                error( ...
                    '%s: Unsupported image format (%dx%dx%d)', ...
                    fname, ...
                    size(im, 2), ...
                    size(im, 1), ...
                    size(im, 3) ...
                    );

            endif;

        endfunction;

    endmethods;

endclassdef;
