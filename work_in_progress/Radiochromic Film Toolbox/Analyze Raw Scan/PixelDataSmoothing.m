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
        % Filter ('None', 'Median', 'Wiener', 'Wavelet')
        ds_flt  = 'None';
        % Smoothing window ('[] if ds_flt = 'None' or ds_flt = 'Wavelet')
        window  = [];
        % Wavelet type (algorithm). Supported types are:
        %
        %   uwt:spline3:7:hard - undecimated wavelet transform using
        %                        synthesis 'spline3:7' filterbank with the
        %                        hard thresholding
        %   uwt:spline3:7:soft - undecimated wavelet transform using
        %                        synthesis 'spline3:7' filterbank with the
        %                        soft thresholding
        wt_type = 'None'
        % % Wavelet filter bank ('db8' if 'Wavelet' selected for the method,
        % % otherwise 'None')
        % flt_bnk = 'None';
        % % Iterations (number of filter bank iterations; for more information
        % % see: https://octave.sourceforge.io/ltfat/function/fwt2.html)
        % iter_no = 0;
        % % Lambda (value used for thresholding operation; for more information
        % % see: https://octave.sourceforge.io/ltfat/function/thresh.html)
        % lambda = 0;
        % % Thresholding type ('hard', 'wiener', 'soft', 'full', 'sparse'; Default
        % % is 'hard'; for more information see:
        % % https://octave.sourceforge.io/ltfat/function/thresh.html)
        % tr_type = 'None';

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
                    ds.ds_flt  = varargin{1}.ds_flt;
                    ds.window  = varargin{1}.window;
                    ds.wt_type = varargin{1}.wt_type;

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
                    ds_flt, ...
                    window, ...
                    wt_type ...
                    ] = parseparams( ...
                    varargin, ...
                    'Title', 'None', ...
                    'Filter', 'None', ...
                    'Window', [], ...
                    'WT-Type', 'None' ...
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

                % Validate value supplied for the Filter
                validatestring( ...
                    ds_flt, ...
                    {'None', 'Median', 'Wiener', 'Wavelet'}, ...
                    fname, ...
                    'Filter' ...
                    );

                % Validate value supplied for the Window
                if(isequal('None', ds_flt) || isequal('Wavelet', ds_flt))
                    % For these options window must be an empty vector
                    if(~isempty(window))
                        warning( ...
                            '%s: Filter "%s" does not support nonempty window', ...
                            fname, ...
                            ds_flt ...
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

                % Validate value supplied for the WT-Type
                if(~isequal('Wavelet', ds_flt))
                    % FilterBank option is not needed for other than Wavelet
                    if(~isequal('None', wt_type))
                        warning( ...
                            '%s: WT-Type option not supported for the given method: %s', ...
                            fname, ...
                            method ...
                            );

                    endif;

                    % reset to default
                    wt_type = 'None';

                else
                    % Use the default value if 'None' assigned
                    if(isequal('None', wt_type))
                        wt_type = 'uwt:spline3:7:hard';

                    endif;

                    if(~ischar(wt_type) || isempty(wt_type))
                        error( ...
                            '%s: WT-Type parameter must be a non-empty string', ...
                            fname ...
                            );

                    endif;

                    validatestring( ...
                        wt_type, ...
                        { ...
                            'uwt:spline3:7:hard', ...
                            'uwt:spline3:7:soft' ...
                            }, ...
                        fname, ...
                        'WT-Type' ...
                        );

                endif;

                % Assign values to a new instance -----------------------------
                ds.title   = title;
                ds.ds_flt  = ds_flt;
                ds.window  = window;
                ds.wt_type = wt_type;

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
                printf('\t\tTitle:  "%s",\n', ds.title);
                printf('\t\tFilter: "%s"\n', ds.method);

            elseif(isequal('Wavelet', ds.method))
                printf('\t\tTitle:   "%s",\n', ds.title);
                printf('\t\tFilter:  "%s",\n', ds.method);
                printf('\t\tWT-Type: "%s",\n', ds.wt_type);

            else
                printf('\t\tTitle:  "%s",\n', ds.title);
                printf('\t\tFilter: "%s",\n', ds.method);
                printf('\t\tWindow: [%d %d]\n', ds.window(1), ds.window(2));

            endif;
            printf('\t)\n');

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'str_rep':
%
% Use:
%       -- result = ds.str_rep()
%
% Description:
%          A convenience method that is used to format string representation of
%          the PixelDataSmoothing instance.
%
% -----------------------------------------------------------------------------
        function result = str_rep(ds)
            p = 'PixelDataSmoothing';
            if(ds.isnone())
                result = sprintf('%s("%s", "%s")', p, ds.title, ds.ds_flt);

            elseif(isequal('Wavelet', ds.method))
                result = sprintf( ...
                    '%s("%s", "%s", "%s")', ...
                    p, ...
                    ds.title, ...
                    ds.ds_flt, ...
                    ds.wt_type ...
                    );

            else
                result = sprintf( ...
                    '%s("%s", "%s", [%d %d])', ...
                    p, ...
                    ds.title, ...
                    ds.ds_flt, ...
                    ds.window(1), ...
                    ds.window(2) ...
                    );

            endif;

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
                ds.ds_flt, ...
                ds.window, ...
                ds.wt_type; ...
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
%          PixelDataSmoothing instance is None if it's filter value is equal to
%          'None'.
%
% -----------------------------------------------------------------------------
        function result = isnone(ds)
            result = isequal('None', ds.ds_flt);

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
                    && isequal(ds.ds_flt, other.ds_flt) ...
                    && isequal(ds.window, other.window) ...
                    && isequal(ds.wt_type, other.wt_type) ...
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
