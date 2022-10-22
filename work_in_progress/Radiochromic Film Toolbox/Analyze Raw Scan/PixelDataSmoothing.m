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
        filt  = 'None';
        % Smoothing window ('[] if filt = 'None' or filt = 'Wavelet')
        window  = [];
        % Wavelet definition
        wt      = 'None';
        % Number of wavelet filterban iterations
        J       = 0;
        % Wavelet transform filter scaling
        fs      = 'None';
        % Wavelet threshoding type ('hard', 'soft', 'wiener')
        thrsh

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
                    ds.title  = varargin{1}.title;
                    ds.filt   = varargin{1}.filt;
                    ds.window = varargin{1}.window;
                    ds.wt     = varargin{1}.wt;
                    ds.J      = varargin{1}.J;
                    ds.fs     = varargin{1}.fs;
                    ds.thrsh  = varargin{1}.thrsh;

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
                    filt, ...
                    window, ...
                    wt, ...
                    J, ...
                    fs, ...
                    thrsh ...
                    ] = parseparams( ...
                    varargin, ...
                    'Title', 'None', ...
                    'Filter', 'None', ...
                    'Window', [], ...
                    'Wavelet', 'None', ...
                    'WtFbNoIterations', 0, ...
                    'WtFilterScaling', 'None', ...
                    'WtThresholding', 'None' ...
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
                    filt, ...
                    {'None', 'Median', 'Wiener', 'Wavelet'}, ...
                    fname, ...
                    'Filter' ...
                    );

                % Validate value supplied for the Window
                if(isequal('None', filt) || isequal('Wavelet', filt))
                    % For these options window must be an empty vector
                    if(~isempty(window))
                        warning( ...
                            '%s: Filter "%s" does not support nonempty window', ...
                            fname, ...
                            filt ...
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

                % Validate value supplied for the Wavelet
                if(~isequal('Wavelet', filt))
                    % FilterBank option is not needed for other than Wavelet
                    if(~isequal('None', wt))
                        warning( ...
                            '%s: Wavelet option not supported for the given method: %s', ...
                            fname, ...
                            filt ...
                            );

                    endif;

                    % reset to default
                    wt = 'None';

                else
                    % Use the default value if 'None' assigned
                    if(isequal('None', wt))
                        wt = 'syn:spline3:7';

                    endif;

                    if(~ischar(wt) || isempty(wt))
                        error( ...
                            '%s: Wavelet parameter must be a non-empty string', ...
                            fname ...
                            );

                    endif;

                endif;

                % Validate value supplied for the WtFbNoIterations
                if(~isequal('Wavelet', filt))
                    % WtFbNoIterations option is not needed for other than Wavelet
                    if(0 ~= J)
                        warning( ...
                            '%s: WtFbNoIterations option not supported for the given method: %s', ...
                            fname, ...
                            filt ...
                            );

                    endif;

                    % reset to default
                    J = 0;

                else
                    % Use the default value if 'None' assigned
                    if(0 == J)
                        J = 3;

                    endif;

                    validateattributes( ...
                        J, ...
                        {'numeric'}, ...
                        { ...
                            'nonnan', ...
                            'nonempty', ...
                            'integer', ...
                            'scalar', ...
                            '>=', 1 ...
                            }, ...
                        fname, ...
                        'WtFbNoIterations' ...
                        );

                endif;

                % Validate value supplied for the WtFilterScaling
                if(~isequal('Wavelet', filt))
                    % WtFilterScaling option is not needed for other than Wavelet
                    if(~isequal('None', fs))
                        warning( ...
                            '%s: WtFilterScaling option not supported for the given method: %s', ...
                            fname, ...
                            filt ...
                            );

                    endif;

                    % reset to default
                    fs = 'None';

                else
                    % Use the default value if 'None' assigned
                    if(isequal('None', wt))
                        fs = 'sqrt';

                    endif;

                    validatestring( ...
                        fs, ...
                        {'sqrt', 'noscale', 'scale'}, ...
                        fname, ...
                        'WtFilterScaling' ...
                        );

                endif;

                % Validate value supplied for the WtThresholding
                if(~isequal('Wavelet', filt))
                    % WtThresholding option is not needed for other than Wavelet
                    if(~isequal('None', thrsh))
                        warning( ...
                            '%s: WtThresholding option not supported for the given method: %s', ...
                            fname, ...
                            filt ...
                            );

                    endif;

                    % reset to default
                    thrsh = 'None';

                else
                    % Use the default value if 'None' assigned
                    if(isequal('None', thrsh))
                        thrsh = 'hard';

                    endif;

                    validatestring( ...
                        thrsh, ...
                        {'hard', 'soft', 'wiener'}, ...
                        fname, ...
                        'WtThresholding' ...
                        );

                endif;

                % Assign values to a new instance -----------------------------
                ds.title  = title;
                ds.filt   = filt;
                ds.window = window;
                ds.wt     = wt;
                ds.J      = J;
                ds.fs     = fs;
                ds.thrsh  = thrsh;

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
                printf('\t\tFilter: "%s"\n', ds.filt);

            elseif(isequal('Wavelet', ds.filt))
                printf('\t\tTitle:                "%s",\n', ds.title);
                printf('\t\tFilter:               "%s",\n', ds.filt);
                printf('\t\tWavelet:              "%s",\n', ds.wt);
                printf('\t\tNumber of iterations: %d,\n', ds.J);
                printf('\t\tFilter scaling:       "%s",\n', ds.fs);
                printf('\t\tThresholding:         "%s",\n', ds.fs);

            else
                printf('\t\tTitle:  "%s",\n', ds.title);
                printf('\t\tFilter: "%s",\n', ds.filt);
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
                result = sprintf('%s("%s", "%s")', p, ds.title, ds.filt);

            elseif(isequal('Wavelet', ds.filt))
                result = sprintf( ...
                    '%s("%s", "%s", "%s", %d, "%s", "%s")', ...
                    p, ...
                    ds.title, ...
                    ds.filt, ...
                    ds.wt, ...
                    ds.J, ...
                    ds.fs, ...
                    ds.thrsh ...
                    );

            else
                result = sprintf( ...
                    '%s("%s", "%s", [%d %d])', ...
                    p, ...
                    ds.title, ...
                    ds.filt, ...
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
                ds.filt ...
                };
            if(isequal('Median', ds.filt) || isequal('Wiener', ds.filt))
                cds{end + 1} = ds.window;

            else
                cds{end + 1} = ds.wt;
                cds{end + 1} = ds.J;
                cds{end + 1} = ds.fs;
                cds{end + 1} = ds.thrsh;

            endif;

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
            result = isequal('None', ds.filt);

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
%          titles and filters.
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
            if(isequal(ds.title, other.title) && isequal(ds.filt, other.filt));
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
                    && isequal(ds.filt, other.filt) ...
                    && isequal(ds.window, other.window) ...
                    && isequal(ds.wt, other.wt) ...
                    && isequal(ds.J, other.J) ...
                    && isequal(ds.fs, other.fs) ...
                    && isequal(ds.thrsh, other.thrsh) ...
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
                    % 'positive', ...
                    'integer' ...
                    }, ...
                fname, ...
                'im' ...
                );

            % Load required package
            pkg load image;

            % Initilize data structure for the resulting image
            sim = zeros(size(im));

            if(isgray(im))
                if(isequal('Median', ds.filt))
                    % Smooth data using median filter
                    sim = medfilt2(double(im), ds.window);

                elseif(isequal('Wiener', ds.filt))
                    % Smooth data using wiener filter
                    sim = wiener2(double(im), ds.window);

                elseif(isequal('Wavelet', ds.filt))
                    sim = ds.wtsmooth(double(im));

                else
                    % No filtering
                    sim = im;

                endif;

            elseif(isrgb(im))
                if(isequal('Median', ds.filt))
                    % Smooth data using median filter
                    sim(:, :, 1) = medfilt2(im(:, :, 1), ds.window);
                    sim(:, :, 2) = medfilt2(im(:, :, 2), ds.window);
                    sim(:, :, 3) = medfilt2(im(:, :, 3), ds.window);

                elseif(isequal('Wiener', ds.filt))
                    % Smooth data using wiener filter
                    sim(:, :, 1) = wiener2(im(:, :, 1), ds.window);
                    sim(:, :, 2) = wiener2(im(:, :, 2), ds.window);
                    sim(:, :, 3) = wiener2(im(:, :, 3), ds.window);

                elseif(isequal('Wavelet', ds.filt))
                    sim(:, :, 1) = ds.wtsmooth(im(:, :, 1));
                    sim(:, :, 2) = ds.wtsmooth(im(:, :, 2));
                    sim(:, :, 3) = ds.wtsmooth(im(:, :, 3));

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

% -----------------------------------------------------------------------------
%
% Private methods section
%
% -----------------------------------------------------------------------------
    methods (Access = private)

% -----------------------------------------------------------------------------
%
% Method 'wtsmooth':
%
% Description:
%          Calculate wavelet smoothing of the image.
%
% -----------------------------------------------------------------------------
        function sm = wtsmooth(ds, m)
            % Load required package
            pkg load ltfat;

            mask = ones(size(m, 1), size(m, 2));
            c    = [];
            w    = [];

            idx = 1;
            while(ds.J >= idx)
                [coef, info] = uwfbt( ...
                    m, ...
                    {ds.wt, idx, 'full'}, ...
                    ds.fs ...
                    );
                c = reshape(coef(:, 1, :), size(coef, 1), size(coef, 3));
                w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));
                % We use MAD for the estimation of the noise sdev
                s = median(abs(w)(:))/0.6745;
                % We use unified threshold method
                % mask = mask & imdilate( ...
                %     w >= s*sqrt(2*log(numel(w))), ...
                %     [0, 1, 0; 1, 1, 1; 0, 1, 0;] ...
                %     );
                mask = mask & (w >= s*sqrt(2*log(numel(w))));

                ++idx;

            endwhile;

            nssdev = median(abs(w(~mask))(:))/0.6745;
            lambda = nssdev*sqrt(2*log(sum(sum(~mask))));
            nsr = m - c;
            [coef, info] = uwfbt(nsr, {ds.wt, 1, 'full'}, ds.fs);
            coef = thresh(coef, lambda, ds.thrsh);

            wtsyn = ds.wt;
            fssyn = ds.fs;
            if(4 < numel(ds.wt))
                if(isequal('ana:', ds.wt(1:4)))
                    wtsyn = sprintf('syn:%s', ds.wt(5, end));

                elseif(isequal('syn:', ds.wt(1:4)))
                    wtsyn = sprintf('ana:%s', ds.wt(5:end));

                endif;

            endif;

            if(isequal('scale', ds.fs))
                fssyn = 'noscale';

            elseif(isequal('noscale', ds.fs))
                fssyn = 'scale';

            endif;

            sm = c + ~mask.*iuwfbt(coef, {wtsyn, 1, 'full'}, fssyn);

        endfunction;

    endmethods;

endclassdef;
