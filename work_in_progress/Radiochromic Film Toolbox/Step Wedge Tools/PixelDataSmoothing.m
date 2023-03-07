classdef PixelDataSmoothing
%% -----------------------------------------------------------------------------
%%
%% Class 'PixelDataSmoothing':
%%
%% -----------------------------------------------------------------------------
%
%% Description:
%       Data structure representing algorithm and parameters of the selected
%       algorithm to be used for the pixel data smoothing of the image data.
%
%       Multiple property-value pairs may be specified for the
%       PixelDataSmoothing object, but they must appear in pairs.
%
%       Properties of 'PixelDataSmoothing' objects:
%
%       filter: "median"|{"none"}|"UWT"|"MRS"|"wiener"
%           Defines the algorithm to be applied for the data smoothing.
%
%       window: two-element vector, def. []
%           A vector specifying the size of the NHOOD matrix to be used for
%           median and wiener filters if selected. Otherwise, this property is
%           ignored.
%
%       wdef: string, def. "none"
%           Wavelet filterbank. For all accepted paramter formats, see the
%           fwtinit function of the ltfat package. If the "filter" property is
%           set to other than "UWT" or "MRS" this property is ignored.
%
%`      J: double, def. 1
%           The number of filterbank iterations. If the "filter" property is
%           set to other than "UWT" or "MRS" this property is ignored.
%
%       scaling: {"none"}|"noscale"|"scale"|"sqrt"
%           Wavelet filter scaling. See ufwt of the ltfat package for more
%           information. If the "filter" property is set to other than "UWT"
%           or "MRS" this property is ignored.
%
%       threshold: {"none"}|"hard"|"soft"
%           Type of thresholding to bbe used when pixel data smoothing is done
%           using wavelet transform algorithms ("UWT" and "MRS"). For "hard"
%           thresholding, threshold level is determined by formula:
%
%               t(i) = 3 * stdev(w(i))
%
%           for each of the decomposition coefficients. While for "soft"
%           thresholding, threshold level is determined by the formula:
%
%               t(i) = stdev(w(i)) * sqrt(2 * log(n))
%
%           where n  is the number of samples (pixels) in the coefficients
%           matrix.
%
%           If the "filter" property is set to other than "UWT" or "MRS" this
%           property is ignored.
%
%       modifier: {"none"}|"erode"|"dilate"
%           Threshold mask modifier. It uses imdilate() or imerode() functions
%           of the Octave's "image" package to additionally modify
%           coefficients threshold mask. The modification is performed using
%           structuring element defined with "setype" parameter.
%
%           If the "filter" property is set to other than "UWT" or "MRS" this
%           property is ignored.
%
%       setype: "none"|"."|"+"|"x"|"square"
%           Structuring element used to perform mask dilation. For types of
%           structuring elements are currently supported: ".", "+", "x" and
%           "square", defined by 3x3 matrices respectively:
%
%               | 0 0 0 |   | 0 1 0 |   | 1 0 1 |   | 1 1 1 |
%               | 0 1 0 |   | 1 1 1 |   | 0 1 0 |   | 1 1 1 |
%               | 0 0 0 |,  | 0 1 0 |,  | 1 0 1 |,  | 1 1 1 |
%
%           If the "filter" property is set to other than "UWT" or "MRS" this
%           property is ignored.
%
%
%% Public methods:
%
%       - PixelDataSmoothing(varargin): Class constructor.
%
%       - disp(): The disp method is used by Octave whenever a class instance
%         should be displayed on the screen.
%
%       - str_rep(): A convenience method that is used to format string
%         representation of the PixelDataSmoothing instance.
%
%       - ascell(): Return smoothing object structure as cell array.
%
%       - isnone(): Return whether the PixelDataSmoothing object is 'None' or
%         not. PixelDataSmoothing instance is None if it's filter value is
%         equal to 'none'.
%
%       - isequal(other): Return whether or not two 'PixelDataSmoothing'
%         instances are equal. Two instances are equal if all of their fields
%         have identical values.
%
%       - smooth(f): Return smoothed pixel data of input data f.
%
% -----------------------------------------------------------------------------


    properties (SetAccess = private, GetAccess = public)
%% -----------------------------------------------------------------------------
%%
%% Properties section
%%
%% -----------------------------------------------------------------------------

        % Filter ('none', 'median', 'wiener', 'UWT', 'MRS')
        filter    = 'none';
        % Smoothing window (equals [] if filter is 'none'|'UWT'|'MRS')
        window    = [];
        % Wavelet definition (equals 'none' if filter is 'none'|'median'|
        % |'wiener')
        w         = 'none';
        % Number of wavelet filterban iterations (equals 0 if filter is 'none'|
        % |'median'|'wiener')
        J         = 0;
        % Wavelet transform filter scaling ('none', 'sqrt', 'noscale', 'scale'.
        % Equals 'none' if filter is 'none'|'median'|'wiener')
        fs        = 'none';
        % Wavelet denoising threshold type ('none', 'hard', 'soft'. Equals
        % 'none' if filter is 'none'|'median'|'wiener')
        threshold = 'none';
        % Wavelet denoising threshold mask modifier ('none', 'erode', 'dilate'.
        % Equals 'none' if filter is 'none'|'median'|'wiener')
        modifier  = 'none';
        % Structuring element used to perform threshold mask dilation|errosion
        % ('none', '+', 'x', 'square'. Equals 'none' if filter is 'none'|
        % |'median'|'wiener')
        setype    = 'none';

    endproperties;  % Public properties section


    methods (Access = public)
%% ----------------------------------------------------------------------------
%%
%% Public methods section
%%
%% ----------------------------------------------------------------------------

        function pds = PixelDataSmoothing(varargin)
% -----------------------------------------------------------------------------
%
% Method 'PixelDataSmoothing':
%
% Use:
%      -- pds = PixelDataSmoothing()
%      -- pds = PixelDataSmoothing(..., "PROPERTY", VALUE, ...)
%      -- pds = PixelDataSmoothing(other)
%
% Description:
%         Class constructor.
%
%         Class constructor supports following property-value pairs:
%
%         filter: "median"|{"none"}|"UWT"|"MRS"|"wiener"
%             Defines the algorithm to be applied for the data smoothing.
%
%         window: two-element vector, def. []
%             A vector specifying the size of the NHOOD matrix to be used for
%             median and wiener filters if selected. Otherwise, this property
%             is ignored.
%
%         wdef: string, def. "none"
%             Wavelet filterbank. For all accepted paramter formats, see the
%             fwtinit function of the ltfat package. If the "filter" property
%             is`set to other than "UWT" or "MRS" this property is ignored.
%
%`        J: double, def. 1
%             The number of filterbank iterations. If the "filter" property is
%             set to other than "UWT" or "MRS" this property is ignored.
%
%         scaling: {"none"}|"noscale"|"scale"|"sqrt"
%             Wavelet filter scaling. See ufwt of the ltfat package for more
%             information. If the "filter" property is set to other than "UWT"
%             or "MRS" this property is ignored.
%
%         threshold: {"none"}|"hard"|"soft"
%             Type of thresholding to bbe used when pixel data smoothing is
%             done using wavelet transform algorithms ("UWT" and "MRS"). For
%             "hard" thresholding, threshold level is determined by formula:
%
%                 t(i) = 3 * stdev(w(i))
%
%             for each of the decomposition coefficients. While for "soft"
%             thresholding, threshold level is determined by the formula:
%
%                 t(i) = stdev(w(i)) * sqrt(2 * log(n))
%
%             where n  is the number of samples (pixels) in the coefficients
%             matrix.
%
%             If the "filter" property is set to other than "UWT" or "MRS" this
%             property is ignored.
%
%         modifier: {"none"}|"erode"|"dilate"
%             Threshold mask modifier. It uses imdilate() or imerode()
%             functions of the Octave's "image" package to additionally modify
%             coefficients threshold mask. The modification is performed using
%             structuring element defined with "setype" parameter.
%
%             If the "filter" property is set to other than "UWT" or "MRS" this
%             property is ignored.
%
%         setype: "none"|"."|"+"|"x"|"square"
%             Structuring element used to perform mask dilation. For types of
%             structuring elements are currently supported: ".", "+", "x" and
%             "square", defined by 3x3 matrices respectively:
%
%                 | 0 0 0 |   | 0 1 0 |   | 1 0 1 |   | 1 1 1 |
%                 | 0 1 0 |   | 1 1 1 |   | 0 1 0 |   | 1 1 1 |
%                 | 0 0 0 |,  | 0 1 0 |,  | 1 0 1 |,  | 1 1 1 |
%
%             If the "filter" property is set to other than "UWT" or "MRS" this
%             property is ignored.
%
% -----------------------------------------------------------------------------
            fname = 'PixelDataSmoothing';
            use_case_a = sprintf(' -- pds = %s()', fname);
            use_case_b = sprintf( ...
                ' -- pds = %s(..., "PROPERTY", VALUE, ...)', ...
                fname ...
                );
            use_case_c = sprintf(' -- pds = %s(other)', fname);

            if(0 == nargin)
                % Default constructor invoked ---------------------------------

            elseif(1 == nargin)
                if(isa(varargin{1}, 'PixelDataSmoothing'))
                    % Copy constructor invoked --------------------------------
                    pds.filt      = varargin{1}.filter;
                    pds.window    = varargin{1}.window;
                    pds.wt        = varargin{1}.w;
                    pds.J         = varargin{1}.J;
                    pds.fs        = varargin{1}.fs;
                    pds.threshold = varargin{1}.threshold;
                    pds.modifier  = varargin{1}.modifier;
                    pds.setype    = varargin{1}.fs;

                else
                    % Invalid call to the copy constructor --------------------
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
                    filter, ...
                    window, ...
                    w, ...
                    J, ...
                    fs, ...
                    threshold, ...
                    modifier, ...
                    setype ...
                    ] = parseparams( ...
                    varargin, ...
                    'filter', 'none', ...
                    'window', [], ...
                    'wdef', 'none', ...
                    'J', 0, ...
                    'scaling', 'none', ...
                    'threshold', 'none', ...
                    'modifier', 'none', ...
                    'setype', 'none' ...
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

                % Validate value supplied for the Filter
                validatestring( ...
                    filter, ...
                    {'none', 'median', 'wiener', 'UWT', 'MRS'}, ...
                    fname, ...
                    'filter' ...
                    );

                % Validate value supplied for the Window
                if(isequal('median', filter) || isequal('wiener', filter))
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

                % Validate values of the properties related to wavelet denoising
                if(isequal('UWT', filter) || isequal('MRS', filter))
                    % Wavelet filterbank definition (wdef), number of filterbank
                    % iterations (J), filter scaling (scaling), threshold type
                    % (threshold), threshold mask modifier (modifier),
                    % structuring element (setype) are properties only required
                    % if filter is set to 'UWT' or 'MRS' ...

                    % Validate value of the wavelet filterbank definition
                    % property (WtFb)

                    % Load required packages
                    pkg load ltfat;

                    % Use the default value if 'None' assigned
                    if(isequal('none', w))
                        w = 'spline2:2';

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

                    % Validate value for the number of wavelet filterbank
                    % iterations property (WtFbIter)

                    % Use the default value if none (0) assigned
                    if(0 == J)
                        J = 2;

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
                        'J' ...
                        );

                    % Validate the value for the wavelet filter scaling
                    % property (scaling)

                    % Use the default value if 'none' assigned
                    if(isequal('none', fs))
                        fs = 'sqrt';

                    endif;

                    validatestring( ...
                        fs, ...
                        {'sqrt', 'noscale', 'scale'}, ...
                        fname, ...
                        'scaling' ...
                        );

                    % Validate the value for the wavelet threshold property
                    % (threshold)

                    % Use the default value if 'none' assigned
                    if(isequal('none', threshold))
                        fs = 'hard';

                    endif;

                    validatestring( ...
                        threshold, ...
                        {'hard', 'soft'}, ...
                        fname, ...
                        'threshold' ...
                        );

                    % Validate the value for the wavelet mask modifier property
                    % (modifier)
                    validatestring( ...
                        modifier, ...
                        {'none', 'erode', 'dilate'}, ...
                        fname, ...
                        'modifier' ...
                        );

                    % Validate the value for the structuring element property
                    % (setype)
                    validatestring( ...
                        setype, ...
                        {'none', '.', '+', 'x', 'square'}, ...
                        fname, ...
                        'setype' ...
                        );

                    % If modifier not specified ignore valeu of the structuring
                    % element property
                    if(isequal('none', modifier))
                        setype = 'none';

                    endif;

                else
                    % ... for all other cases we ignore the values of these
                    % properties
                    w         = 'none';
                    J         = 0;
                    fs        = 'none';
                    threshold = 'none';
                    modifier  = 'none';
                    setype    = 'none';

                endif;

                % Assign values to a new instance -----------------------------
                pds.filter    = filter;
                pds.window    = window;
                pds.w         = w;
                pds.J         = J;
                pds.fs        = fs;
                pds.threshold = threshold;
                pds.modifier  = modifier;
                pds.setype    = setype;

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

        endfunction;  % PixelDataSmoothing()


        function disp(pds)
% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- pds.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
            printf('\tPixelDataSmoothing(\n');
            if(pds.isnone())
                printf('\t\tFilter: "%s"\n', pds.filter);

            elseif(isequal('UWT', pds.filter) || isequal('MRS', pds.filter))
                printf('\t\tFilter:               "%s",\n', pds.filter);
                % Format the wavelet filterbank description string
                wstr = '';
                idx = 1;
                while(size(pds.w.origArgs, 2) >= idx)
                    if(1 == idx)
                        wstr = sprintf('%s', pds.w.origArgs{1, idx});

                    else
                        if(isequal('double', class(pds.w.origArgs{1, idx})))
                            wstr = sprintf( ...
                                '%s:%d', ...
                                wstr, ...
                                pds.w.origArgs{1, idx} ...
                                );

                        else
                            wstr = sprintf( ...
                                '%s:%s', ...
                                wstr, ...
                                pds.w.origArgs{1, idx} ...
                                );

                        endif;

                    endif;
                    ++idx;
                endwhile;
                printf('\t\tWavelet filterbank:   "%s",\n', wstr);
                printf('\t\tNumber of iterations: %d,\n', pds.J);
                printf('\t\tFilter scaling:       "%s",\n', pds.fs);
                printf('\t\tThreshold:            "%s",\n', pds.threshold);
                printf('\t\tMask modifier:        "%s",\n', pds.modifier);
                printf('\t\tStructuring element:  "%s",\n', pds.setype);

            else
                printf('\t\tFilter: "%s",\n', pds.filter);
                printf('\t\tWindow: [%d %d]\n', pds.window(1), pds.window(2));

            endif;
            printf('\t)\n');

        endfunction;


        function result = str_rep(pds)
% -----------------------------------------------------------------------------
%
% Method 'str_rep':
%
% Use:
%       -- result = pds.str_rep()
%
% Description:
%          A convenience method that is used to format string representation of
%          the PixelDataSmoothing instance.
%
% -----------------------------------------------------------------------------
            p = 'PixelDataSmoothing';
            if(pds.isnone())
                result = sprintf('%s("%s", "%s")', p, pds.filter);

            elseif(isequal('UWT', pds.filter) || isequal('MRS', pds.filter))
                % Format the wavelet filterbank description string
                wstr = '';
                idx = 1;
                while(size(pds.w.origArgs, 2) >= idx)
                    if(1 == idx)
                        wstr = sprintf('%s', pds.w.origArgs{1, idx});

                    else
                        if(isequal('double', class(pds.w.origArgs{1, idx})))
                            wstr = sprintf( ...
                                '%s:%d', ...
                                wstr, ...
                                pds.w.origArgs{1, idx} ...
                                );

                        else
                            wstr = sprintf( ...
                                '%s:%s', ...
                                wstr, ...
                                pds.w.origArgs{1, idx} ...
                                );

                        endif;

                    endif;

                    ++idx;

                endwhile;

                result = sprintf( ...
                    '%s("%s", "%s", %d, "%s", "%s" "%s", "%s")', ...
                    p, ...
                    pds.filter, ...
                    wstr, ...
                    pds.J, ...
                    pds.fs, ...
                    pds.threshold, ...
                    pds.modifier, ...
                    pds.setype ...
                    );

            else
                result = sprintf( ...
                    '%s("%s", "%s", [%d %d])', ...
                    p, ...
                    pds.filter, ...
                    pds.window(1), ...
                    pds.window(2) ...
                    );

            endif;

        endfunction;


        function pdscell = ascell(pds)
% -----------------------------------------------------------------------------
%
% Method 'ascell':
%
% Use:
%       -- pdscell = pds.ascell()
%
% Description:
%          Return smoothing object structure as cell array.
%
% -----------------------------------------------------------------------------
            pdscell = {};
            pdscell{end + 1} = pds.filter;
            if(isequal('median', pds.filter) || isequal('wiener', pds.filter))
                pdscell{end + 1} = pds.window;

            else
                pdscell{end + 1} = pds.w;
                pdscell{end + 1} = pds.J;
                pdscell{end + 1} = pds.fs;
                pdscell{end + 1} = pds.threshold;
                pdscell{end + 1} = pds.modifier;
                pdscell{end + 1} = pds.setype;

            endif;

        endfunction;


        function result = isnone(pds)
% -----------------------------------------------------------------------------
%
% Method 'isnone':
%
% Use:
%       -- result = pds.isnone()
%
% Description:
%          Return whether the PixelDataSmoothing object is 'None' or not.
%          PixelDataSmoothing instance is None if it's filter value is equal to
%          'none'.
%
% -----------------------------------------------------------------------------
            result = isequal('none', pds.filter);

        endfunction;


        function result = isequal(pds, other)
% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = pds.isequal(other)
%
% Description:
%          Return whether or not two 'PixelDataSmoothing' instances are equal.
%          Two instances are equal if all of their fields have identical values.
%
% -----------------------------------------------------------------------------
            fname = 'isequal';

            if(~isa(other, 'PixelDataSmoothing'))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: other must be an instance of the ', ...
                            '"PixelDataSmoothing" class' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if( ...
                    isequal(pds.filter, other.filter) ...
                    && isequal(pds.window, other.window) ...
                    && isequal(pds.w, other.w) ...
                    && isequal(pds.J, other.J) ...
                    && isequal(pds.fs, other.fs) ...
                    && isequal(pds.fs, other.threshold) ...
                    && isequal(pds.fs, other.modifier) ...
                    && isequal(pds.fs, other.setype) ...
                    )
                result = true;

            endif;

        endfunction;


        function sf = smooth(pds, f)
% -----------------------------------------------------------------------------
%
% Method 'smooth':
%
% Use:
%       -- sim = pds.smooth(f)
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
            if(isequal('none', pds.filter))
                % Just return the unmodified input data
                sf = f;

            elseif(isequal('median', pds.filter))
                % Call the median algorithm
                sf = pds._median_smooth(f);

            elseif(isequal('wiener', pds.filter))
                % Call the wiener algorithm
                sf = pds._wiener_smooth(f);

            elseif(isequal('UWT', pds.filter))
                % Call the UWT algorithm
                sf = pds._uwt_smooth(f);

            else(isequal('MRS', pds.filter))
                % Call the MRS algorithm
                sf = pds._mrs_smooth(f);

            endif;

        endfunction;

    endmethods;  % Public methods section


    methods (Access = private)
%% ----------------------------------------------------------------------------
%%
%% Private methods section
%%
%% ----------------------------------------------------------------------------

        function sf = _median_smooth(pds, f)
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
                sf(:, :, idx) = medfilt2(double(f(:, :, idx)), pds.window);

                ++idx;

            endwhile;

        endfunction;


        function sf = _wiener_smooth(pds, f)
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
                sf(:, :, idx) = wiener2(double(f(:, :, idx)), pds.window);

                ++idx;

            endwhile;

        endfunction;


        function sf = _uwt_smooth(pds, f)
% -----------------------------------------------------------------------------
%
% Method '_uwt_smooth':
%
% Description:
%          Smooth pixel data using undecimated wavelet transform.
%
% -----------------------------------------------------------------------------

            % Initilize data structure for the resulting image
            sf = zeros(size(f));

            idx = 1;
            while(size(f, 3) >= idx)
                sf(:, :, idx) = ufwt2denoise( ...
                    double(f(:, :, idx)), ...
                    pds.w, ...
                    pds.J, ...
                    'FilterScaling', pds.fs, ...
                    'ThresholdType', pds.threshold, ...
                    'Modifier', pds.modifier, ...
                    'SEType', pds.setype ...
                    );

                ++idx;

            endwhile;

        endfunction;


        function sf = _mrs_smooth(pds, f)
% -----------------------------------------------------------------------------
%
% Method '_mrs_smooth':
%
% Description:
%          Smooth pixel data using multi-resolution support, using undecimated
%          wavelet transform.
%
% -----------------------------------------------------------------------------

            % Initilize data structure for the resulting image
            sf = zeros(size(f));

            idx = 1;
            while(size(f, 3) >= idx)
                sf(:, :, idx) = mrs_denoise_soft( ...
                    double(f(:, :, idx)), ...
                    pds.w, ...
                    pds.J, ...
                    pds.fs ...
                    );

                ++idx;

            endwhile;

        endfunction;

    endmethods;  % Private methods section

endclassdef;  % PixelDataSmoothing
