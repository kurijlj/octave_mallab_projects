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
        % Wavelet type ('db8' if 'Wavelet' selected for the method, otherwise 'None')
        wavelet = 'None';

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
                    ds.wavelet = varargin{1}.wavelet;

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

            elseif(2 <= nargin && 8 >= nargin)
                % Regular constructor invoked ---------------------------------

                % Parse arguments
                [ ...
                    pos, ...
                    title, ...
                    method, ...
                    window, ...
                    wavelet ...
                    ] = parseparams( ...
                    varargin, ...
                    'Title', 'None', ...
                    'Method', 'None', ...
                    'Window', [], ...
                    'Wavelet', 'None' ...
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
                if(~isequal('Wavelet', method))
                    % For these options window must be an empty vector
                    if(~isequal('None', wavelet))
                        warning( ...
                            '%s: Wavelet option not supported for the given method: %s', ...
                            fname, ...
                            method ...
                            );

                    endif;

                    % reset to default
                    wavelet = 'None';

                else
                    validatestring( ...
                        wavelet, ...
                        {'db8'}, ...
                        fname, ...
                        'Wavelet' ...
                        );

                endif;

                % Assign values to a new instance -----------------------------
                ds.title   = title;
                ds.method  = method;
                ds.window  = window;
                ds.wavelet = wavelet;

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

            printf('\tPixelDataSmoothing(\n');
            printf('\t\tTitle:   %s,\n', ds.title);
            printf('\t\tMethod:  %s,\n', ds.method);
            printf('\t\tWindow:  %s,\n', win);
            printf('\t\tWavelet: %s,\n', ds.wavelet);
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

            printf( ...
                'PixelDataSmoothing(%s, %s, %s, %s)', ...
                ds.title, ...
                ds.method, ...
                win, ...
                ds.wavelet ...
                );

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
            cds = {ds.title, ds.method, ds.window, ds.wavelet;};

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

    endmethods;

endclassdef;
