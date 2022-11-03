classdef PixelDataSmoothing
% -----------------------------------------------------------------------------
%
% Class 'PixelDataSmoothing':
%
% Description:
%       Data structure representing algorithm and parameters of the selected
%       algorithm to be used for the pixel data smoothing of the image data.
%
%       Multiple property-value pairs may be specified for the
%       PixelDataSmoothing object, but they must appear in pairs.
%
%       Properties of 'PixelDataSmoothing' objects:
%
%       Title: string, def. "None"
%           A string containing a title describing pixel data smoothing
%           algorithm and parameters.
%
%       Filter: "Median"|{"None"}|"UWT"|"Wiener"
%           Defines the algorithm to be applied for the data smoothing.
%
%       Window: two-element vector, def. []
%           A vector specifying the size of the NHOOD matrix to be used for
%           median and wiener filters if selected. Otherwise, this property is
%           ignored.
%
%       WtFb: string, def. "None"
%           Wavelet filterbank. For all accepted paramter formats, see the
%           fwtinit function of the ltfat package. If the Filter property is
%           set to other than "UFWT" this property is ignored.
%
%`      WtFbIter: def. 0
%           The number of filterbank iterations. If the Filter property is set
%           to other than "UFWT" this property is ignored.
%
%       WtFs: {"none"}|"noscale"|"scale"|"sqrt"
%           Wavelet filter scaling. See ufwt of the ltfat package for more
%           information.
%
%       WtThrType: "hard"|{"none"}|"soft"|"wiener"
%           Thresholding type. See thresh of the ltfat package for more
%           information.
%
% -----------------------------------------------------------------------------

    properties (SetAccess = private, GetAccess = public)
% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------

        % Pixel data smoothing title (unique ID)
        title   = 'None';
        % Filter ('None', 'Median', 'Wiener', 'UWT')
        filter  = 'None';
        % Smoothing window ('[] if filt = 'None' or filt = 'Wavelet')
        window  = [];
        % Wavelet definition
        w       = 'none';
        % Number of wavelet filterban iterations
        J       = 0;
        % Wavelet transform filter scaling ('none', 'sqrt', 'noscale', 'scale')
        fs      = 'none';
        % Wavelet threshoding type ('none', 'hard', 'soft', 'wiener')
        thrtype = 'none';

    endproperties;

    methods (Access = public)
% -----------------------------------------------------------------------------
%
% Public methods section
%
% -----------------------------------------------------------------------------

        function ds = PixelDataSmoothing(varargin)
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
                    ds.filt   = varargin{1}.filter;
                    ds.window = varargin{1}.window;
                    ds.wt     = varargin{1}.w;
                    ds.J      = varargin{1}.J;
                    ds.fs     = varargin{1}.fs;
                    ds.thrsh  = varargin{1}.thrtype;

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
                    filter, ...
                    window, ...
                    w, ...
                    J, ...
                    fs, ...
                    thrtype ...
                    ] = parseparams( ...
                    varargin, ...
                    'Title', 'None', ...
                    'Filter', 'None', ...
                    'Window', [], ...
                    'WtFb', 'None', ...
                    'WtFbIter', 0, ...
                    'WtFs', 'None', ...
                    'WtThrType', 'None' ...
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
                    filter, ...
                    {'None', 'Median', 'Wiener', 'UWT'}, ...
                    fname, ...
                    'Filter' ...
                    );

                % Validate value supplied for the Window
                if(isequal('Median', filter) || isequal('Wiener', filter))
                    % Window property value is only required if filter is set to
                    % Median or Wiener ...

                    % If window is empty assign the default value
                    if(isempty(window))
                        window = [3 3];

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

                else
                    % ... for all other filter selections we ignore value of the
                    % Window property
                    window = [];

                endif;

                % Validate values of the properties related to 'UWT' filter
                if(isequal('UWT', filter))
                    % Wavelet filterbank definition (WtFb), number of filterbank
                    % iterations (WtFbIter), filter scaling (WtFs) and threshold
                    % type (WtThrType) properties are only required if filter is
                    % set to 'UFWT' ...

                    % Validate value of the wavelet filterbank definition
                    % property (WtFb)

                    % Use the default value if 'None' assigned
                    if(isequal('None', w))
                        w = 'syn:spline3:7';

                    endif;

                    try
                        w = fwtinit(w);

                    catch err
                        error( ...
                            '%s: %s', ...
                            fname, ...
                            err.message ...
                            );

                    end_try_catch;

                    % Validate value of the number of wavelet filterbank
                    % iterations property (WtFbIter)

                    % Use the default value if none (0) assigned
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
                        'WtFbIter' ...
                        );

                    % Validate the value of the wavelet filter scaling
                    % property (WtFs)

                    % Use the default value if 'None' assigned
                    if(isequal('none', fs))
                        fs = 'sqrt';

                    endif;

                    validatestring( ...
                        fs, ...
                        {'sqrt', 'noscale', 'scale'}, ...
                        fname, ...
                        'WtFs' ...
                        );

                    % Validate the value of the wavelet threshold type
                    % property (WtThrType)

                    % Use the default value if 'None' assigned
                    if(isequal('none', thrtype))
                        thrtype = 'soft';

                    endif;

                    validatestring( ...
                        thrtype, ...
                        {'hard', 'soft', 'wiener'}, ...
                        fname, ...
                        'WtThrType' ...
                        );

                else
                    % ... for all other cases we ignore the values of these
                    % properties
                    w       = 'none';
                    J       = 0;
                    fs      = 'none';
                    thrtype = 'none';

                endif;

                % Assign values to a new instance -----------------------------
                ds.title   = title;
                ds.filter  = filter;
                ds.window  = window;
                ds.w       = w;
                ds.J       = J;
                ds.fs      = fs;
                ds.thrtype = thrtype;

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

        function disp(ds)
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
            printf('\tPixelDataSmoothing(\n');
            if(ds.isnone())
                printf('\t\tTitle:  "%s",\n', ds.title);
                printf('\t\tFilter: "%s"\n', ds.filter);

            elseif(isequal('Wavelet', ds.filt))
                printf('\t\tTitle:                "%s",\n', ds.title);
                printf('\t\tFilter:               "%s",\n', ds.filter);
                printf('\t\tWavelet filterbank:   "%s",\n', ds.w);
                printf('\t\tNumber of iterations: %d,\n', ds.J);
                printf('\t\tFilter scaling:       "%s",\n', ds.fs);
                printf('\t\tThresholding:         "%s",\n', ds.thrtype);

            else
                printf('\t\tTitle:  "%s",\n', ds.title);
                printf('\t\tFilter: "%s",\n', ds.filter);
                printf('\t\tWindow: [%d %d]\n', ds.window(1), ds.window(2));

            endif;
            printf('\t)\n');

        endfunction;

        function result = str_rep(ds)
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
            p = 'PixelDataSmoothing';
            if(ds.isnone())
                result = sprintf('%s("%s", "%s")', p, ds.title, ds.filter);

            elseif(isequal('Wavelet', ds.filt))
                result = sprintf( ...
                    '%s("%s", "%s", "%s", %d, "%s", "%s")', ...
                    p, ...
                    ds.title, ...
                    ds.filter, ...
                    ds.w, ...
                    ds.J, ...
                    ds.fs, ...
                    ds.thrtype ...
                    );

            else
                result = sprintf( ...
                    '%s("%s", "%s", [%d %d])', ...
                    p, ...
                    ds.title, ...
                    ds.filter, ...
                    ds.window(1), ...
                    ds.window(2) ...
                    );

            endif;

        endfunction;

        function cds = cellarray(ds)
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
            cds = {};
            cds = { ...
                ds.title, ...
                ds.filter ...
                };
            if(isequal('Median', ds.filter) || isequal('Wiener', ds.filter))
                cds{end + 1} = ds.window;

            else
                cds{end + 1} = ds.w;
                cds{end + 1} = ds.J;
                cds{end + 1} = ds.fs;
                cds{end + 1} = ds.thrtype;

            endif;

        endfunction;

        function result = isnone(ds)
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
            result = isequal('None', ds.filter);

        endfunction;

        function result = isequivalent(ds, other)
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
            fname = 'isequivalent';

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
                    && isequal(ds.filter, other.filter) ...
                    );
                result = true;

            endif;

        endfunction;

        function result = isequal(ds, other)
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
                    && isequal(ds.filter, other.filter) ...
                    && isequal(ds.window, other.window) ...
                    && isequal(ds.w, other.w) ...
                    && isequal(ds.J, other.J) ...
                    && isequal(ds.fs, other.fs) ...
                    && isequal(ds.thrtype, other.thrtype) ...
                    )
                result = true;

            endif;

        endfunction;

        function sf = smooth(ds, f)
% -----------------------------------------------------------------------------
%
% Method 'smooth':
%
% Use:
%       -- sim = ds.smooth(f)
%
% Description:
%          Return smoothed pixel data of input data f.
%
% -----------------------------------------------------------------------------
            fname = 'smooth';

            % Validate input pixel data
            validateattributes( ...
                f, ...
                {'float'}, ...
                { ...
                    '3d', ...
                    'finite', ...
                    'nonempty', ...
                    'nonnan', ...
                    }, ...
                fname, ...
                'im' ...
                );

%       Filter: "Median"|{"None"}|"UWT"|"Wiener"
            if(isequal('None', ds.filter))
                % Just return the unmodified input data
                sf = f;

            elseif(isequal('Median', ds.filter))
                % Call the median algorithm
                sf = ds._median_smooth();

            elseif(isequal('Wiener', ds.filter))
                % Call the wiener algorithm
                sf = ds._wiener_smooth();

            else
                % Call the UWT algorithm
                sf = ds._uwt_smooth();

            endif;

        endfunction;

    endmethods;

    methods (Access = private)
% -----------------------------------------------------------------------------
%
% Private methods section
%
% -----------------------------------------------------------------------------

        function sm = _median_smooth(ds, f)
% -----------------------------------------------------------------------------
%
% Method '_median_smooth':
%
% Description:
%          Perform the median smoothing of the inut data
%
% -----------------------------------------------------------------------------

            % Load required package
            pkg load image;

            % Initilize data structure for the resulting image
            sf = zeros(size(f));

            idx = 1;
            while(size(f, 3) >= idx)
                sf(:, :, idx) = medfilt2(double(f(:, :, idx)), ds.window);

                ++idx;

            endwhile;

        endfunction;

        function sm = _wiener_smooth(ds, f)
% -----------------------------------------------------------------------------
%
% Method '_wiener_smooth':
%
% Description:
%          Perform the wiener smoothing of the inut data
%
% -----------------------------------------------------------------------------

            % Load required package
            pkg load image;

            % Initilize data structure for the resulting image
            sf = zeros(size(f));

            idx = 1;
            while(size(f, 3) >= idx)
                sf(:, :, idx) = wiener2(double(f(:, :, idx)), ds.window);

                ++idx;

            endwhile;

        endfunction;

        function sm = _uwt_smooth(ds, m)
% -----------------------------------------------------------------------------
%
% Method 'wtsmooth':
%
% Description:
%          Calculate wavelet smoothing of the image.
%
% -----------------------------------------------------------------------------

            % Load required package
            pkg load ltfat;

            % Initilize data structure for the resulting image
            sf = zeros(size(f));

        endfunction;

    endmethods;

endclassdef;
