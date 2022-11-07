classdef Scan
% -----------------------------------------------------------------------------
%
% Class 'Scan':
%
% Description:
%       Data structure representing a single data scan.
%
%       The class constructor can be invoked with a string representing the
%       path to a 'TIFF' image, a 2D or 3D matrix representing scan pixel data,
%       or with another class instance.
%
%       The minimum required scan signal size is 8x8 pixels. If the scan signal
%       is loaded from an image file, the following requirements are mandatory:
%           - must be a TIFF file;
%           - must be an RGB image;
%           - must be 16 bits per sample (uint16);
%           - must be an uncompressed image.
%
%       Two scan objects are equivalent if they are of the same type, same size,
%       same date of scanning, same date of irradiation, and of the same
%       resolution.
%
%       The scan object is valid if there are no warnings generated (sc.wrn =
%       'None') during object initialization. The validity of the scan object
%       can be checked using 'is_valid' method.
%
%       Multiple property-value pairs may be specified for the scan object, but
%       they must appear in pairs.
%
%       Properties of 'Scan' objects:
%
%       Title: string, def. "Signal scan"
%           A string containing a title describing scanned data.
%
%       DateOfIrradiation: serial date number (see: datenum), def. NaN
%           Serial date number representing the date of irradiation of the scan,
%           if applicable. The date of irradiation must be no older than
%           01-Jan-2022.
%
%       DateOfScan: serial date number (see: datenum), def. NaN
%           Serial date number representing the date when the pixel data of the
%           image were generated. If pixel data are read from the file, the date
%           of scan is automatically set from the file metadata. Otherwise, it
%           is set as the current date. The date of the scan must be no older
%           than 01-Jan-2022.
%
%       Type: "BkgScan"|"DummyBkg"|"DummyScan"|"DummyZeroL"|{"SignalScan"}|"ZeroLScan"
%           Define the type of scan. This property defines how the object will
%           be used for the calculation of the optical density of the
%           measurement, and is one of the parameters determining which scan
%           objects are mutually equivalent and can form a scan set.
%
%       DataSmoothing: PixelDataSmoothing object, def. PixelDataSmoothing("None", "None")
%           Defines the denoising algorithm used for pixel data smoothing of
%           individual scan objects.
%
% -----------------------------------------------------------------------------

    properties (SetAccess = private, GetAccess = public)
% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
        % Film piece title (unique ID)
        title   = 'Signal scan';
        % Source file (if applicable)
        file    = 'None';
        % Date of irradiation (if applicable)
        dt_irrd = NaN;
        % Date of scanning (mandatory)
        dt_scan = NaN;
        % Type (mandatory)
        type    = 'SignalScan';
        % Data smoothing (mandatory)
        ds      = NaN;
        % Raw pixel data
        pd      = [];
        % Image resolution (if applicable)
        rs      = [];
        % Resolution units (if applicable)
        ru      = 'None';
        % Warning generated during the initialization of the object
        wrn     = 'None';

    endproperties;

    methods (Access = public)
% -----------------------------------------------------------------------------
%
% Public methods section
%
% -----------------------------------------------------------------------------

        function sc = Scan(varargin)
% -----------------------------------------------------------------------------
%
% Method 'Scan':
%
% Use:
%       -- sc = Scan(tif)
%       -- sc = Scan(pd)
%       -- sc = Scan(..., "PROPERTY", VALUE, ...)
%       -- sc = Scan(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
            fname = 'Scan';
            use_case_a = ' -- sc = Scan(tif)';
            use_case_b = ' -- sc = Scan(pd)';
            use_case_c = ' -- sc = Scan(..., "PROPERTY", VALUE, ...)';
            use_case_d = ' -- sc = Scan(other)';

            % Check if copy constructor invoked -------------------------------
            if(1 == nargin && isa(varargin{1}, 'Scan'))
                % Copy constructor invoked
                sc.title   = varargin{1}.title;
                sc.file    = varargin{1}.file;
                sc.dt_irrd = varargin{1}.dt_irrd;
                sc.dt_scan = varargin{1}.dt_scan;
                sc.type    = varargin{1}.type;
                sc.ds      = varargin{1}.ds;
                sc.pd      = varargin{1}.pd;
                sc.rs      = varargin{1}.rs;
                sc.ru      = varargin{1}.ru;
                sc.wrn     = varargin{1}.wrn;

                return;

            endif;

            % Parse arguments -------------------------------------------------
            [pos, props] = parsearguments( ...
                varargin, ...
                { ...
                    'Title', 'Signal scan'; ...
                    'DateOfIrradiation', NaN; ...
                    'DateOfScan', NaN; ...
                    'Type', 'SignalScan'; ...
                    'DataSmoothing', PixelDataSmoothing(); ...
                    } ...
                );

            % Validate input arguments ----------------------------------------

            % Validate the number of positional arguments
            if(1 ~= numel(pos))
                % Invalid call to constructor
                error( ...
                    'Invalid call to %s. Correct usage is:\n%s\n%s\n%s\n%s', ...
                    fname, ...
                    use_case_a, ...
                    use_case_b, ...
                    use_case_c, ...
                    use_case_d ...
                    );

            endif;

            % Validate value supplied for the Title
            if(~ischar(props{1, 2}) || isempty(props{1, 2}))
                error('%s: Title must be a non-empty string', fname);

            endif;

            % Assign value to the title
            sc.title = props{1, 2};

            % Validate value supplied for the DateOfIrradiation
            if(~isnan(props{2, 2}))
                validateattributes( ...
                    props{2, 2}, ...
                    {'numeric'}, ...
                    { ...
                        'nonempty', ...
                        'scalar', ...
                        'integer', ...
                        'finite', ...
                        'positive' ...
                        }, ...
                    fname, ...
                    'DateOfIrradiation' ...
                    );

                % Check if given date comes after the 01-Jan-2000
                if(datenum(2000, 1, 1) > props{2, 2})
                    error( ...
                        '%s: DateOfIrradiation too old: %s', ...
                        datestr(props{2, 2}) ...
                        );

                endif;

            endif;

            % Assign value to the DateOfIrradiation
            sc.dt_irrd = props{2, 2};

            % Validate value supplied for the DateOfScan
            if(~isnan(props{3, 2}))
                validateattributes( ...
                    props{3, 2}, ...
                    {'numeric'}, ...
                    { ...
                        'nonempty', ...
                        'scalar', ...
                        'integer', ...
                        'finite', ...
                        'positive' ...
                        }, ...
                    fname, ...
                    'DateOfScan' ...
                    );

                % Check if given date comes after the 01-Jan-2000
                if(datenum(2000, 1, 1) > props{2, 2})
                    error( ...
                        '%s: DateOfScan too old: %s', ...
                        datestr(props{2, 2}) ...
                        );

                endif;

            endif;

            % Assign value to the DateOfScan
            sc.dt_scan = props{3, 2};

            % Validate value supplied for the Type
            validatestring( ...
                props{4, 2}, ...
                { ...
                    'ZeroLScan', ...
                    'BkgScan', ...
                    'SignalScan', ...
                    'DummyZeroL', ...
                    'DummyBkg', ...
                    'DummyScan' ...
                    }, ...
                fname, ...
                'Type' ...
                );

            % Assign value to the Type
            sc.type = props{4, 2};

            % Validate structure supplied for the DataSmoothing
            if(~isa(props{5, 2}, 'PixelDataSmoothing'))
                error( ...
                    '%s: DataSmoothing must be an instance of the "PixelDataSmoothing" class', ...
                    fname ...
                    );

            endif;

            % Assign value to the DataSmoothing
            sc.ds = props{5, 2};

            if(ischar(pos{1}))
                % Pixel data supplied as path to a tif file

                % Check if we are dealing with non-empty string
                if(~ischar(pos{1}) || isempty(pos{1}))
                    error( ...
                        '%s: tif path must be a non-empty string', ...
                        fname ...
                        );

                endif;

                % Check if we have a regular file
                if(~isfile(pos{1}))
                    % We don't have a regular file. Format warning message
                    w = sprintf('%s is not a regular file', pos{1});

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    sc.wrn = w;

                    % Stop further constructor execution
                    return;

                endif;

                % Load required packages
                pkg load image;

                % Load image file info
                ifi = NaN;
                try
                    ifi = imfinfo(pos{1});

                catch
                    % We don't have an image file. Format warning message
                    w = sprintf('%s is not an image file', pos{1});

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    sc.wrn = w;

                    % Stop further constructor execution
                    return;

                end_try_catch;

                % Check if we have a TIFF image
                if(~isequal('TIFF', ifi.Format))
                    % We don't have a TIFF image. Format warning message
                    w = sprintf('%s is not an TIFF image', pos{1});

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    sc.wrn = w;

                    % Stop further constructor execution
                    return;

                endif;

                % Check if we have an RGB TIFF image
                if(2 ~= tiff_tag_read(pos{1}, 262))
                    % We don't have an RGB image. Format warning message
                    w = sprintf('%s is not an RGB image', pos{1});

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    sc.wrn = w;

                    % Stop further constructor execution
                    return;

                endif;

                % Check if we have the right bit depth
                if(16 ~= ifi.BitDepth)
                    % We don't have 16 bits per sample. Format warning message
                    w = sprintf( ...
                        '%s has noncomplying bit depth (%d bps, expected 16 bps)', ...
                        pos{1}, ...
                        ifi.BitDepth ...
                        );

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    sc.wrn = w;

                    % Stop further constructor execution
                    return;

                endif;

                % Check if we are dealing with an uncompressed image
                if(1 ~= tiff_tag_read(pos{1}, 259))
                    % We don't have an uncompressed image.
                    % Format warning message
                    w = sprintf( ...
                        '%s is not an uncompressed TIFF image', ...
                        pos{1} ...
                        );

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    sc.wrn = w;

                    % Stop further constructor execution
                    return;

                endif;

                % Check if horizontal and vertical image resolution are equal
                if(ifi.XResolution ~= ifi.YResolution)
                    % X and Y resolution do not comply. Format the warning
                    % message
                    w = sprintf( ...
                        '%s X and Y resolution do not comply (%d ~= %d)', ...
                        pos{1}, ...
                        ifi.XResolution, ...
                        ifi.YResolution ...
                        );

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    sc.wrn = w;

                    % Stop further constructor execution
                    return;

                endif;

                % Assign file name to the file attribute
                sc.file = pos{1};
                % Load pixel data from file to a temporary variable
                sc.pd = double(imread(pos{1}));
                % Assign resolution to temporary variable
                sc.rs = [ifi.XResolution, ifi.YResolution];
                % Load resolution units from the file
                ru = tiff_tag_read(pos{1}, 296);
                % Convert units number to units string
                if(1 == ru)
                    sc.ru = 'None';

                elseif(2 == ru)
                    sc.ru = 'dpi';

                else
                    sc.ru = 'dpcm';

                endif;
                % Check if user supplied date of scan
                if(isnan(props{3, 2}))
                    % DateOfScan not set, use the file modification date as the
                    % default for the DateOfScan
                    sc.dt_scan = datenum(strsplit(ifi.FileModDate){1});

                endif;

            elseif(isnumeric(pos{1}))
                % Pixel data supplied as matrix

                % Check if have a proper data format
                validateattributes( ...
                    pos{1}, ...
                    {'float'}, ...
                    { ...
                        '3d', ...
                        'finite', ...
                        'nonempty', ...
                        'nonnan' ...
                        }, ...
                    fname, ...
                    'pd' ...
                    );

                % Check if we are dealing with an grayscale or an RGB image
                if(1 ~= size(pos{1}, 3) || 3 ~= size(pos{1}, 3))
                    % We don't have gray nor RGB image. Format warning message
                    w = sprintf( ...
                        'unsupported pixel data format. Expected single channel, or three channel image, got %d channels', ...
                        size(pos{1}, 3) ...
                        );

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring pixel data ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    sc.wrn = w;

                    % Stop further constructor execution
                    return;

                endif;

                % Set given matrix as pixel data
                sc.pd = pos{1};

                % Check if user supplied date of scan
                if(isnan(props{3, 2}))
                    % Date of scan not set, use the current date
                    sc.dt_scan = datenum(date());

                endif;

            else
                % Invalid call to constructor
                error( ...
                    'Invalid call to %s. Correct usage is:\n%s\n%s\n%s\n%s', ...
                    fname, ...
                    use_case_a, ...
                    use_case_b, ...
                    use_case_c, ...
                    use_case_d ...
                    );

            endif;

            % Check if signal size complies with required minimum signal size
            % (i.e. 8x8 pixels)
            if(8 > size(sc.pd, 1) || 8 > size(sc.pd, 2))
                % Signal size too small. Format warning message
                w = sprintf( ...
                    'pixel data signal too small. Got %dx%d pixels, expected at least 8x8 pixels', ...
                    size(sc.pd, 1), ...
                    size(sc.pd, 2) ...
                    );

                % Print warning in the command-line
                warning( ...
                    '%s: %s. Ignoring pixel data ...', ...
                    fname, ...
                    w ...
                    );

                % Add warning to the warning stack
                sc.wrn = w;

                % Stop further constructor execution
                return;

            endif;

        endfunction;

        function disp(sc)
% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- sc.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
            printf('\tScan(\n');
            if(sc.is_valid())
                printf('\t\tTitle:                %s,\n', sc.title);
                printf('\t\tType:                 %s,\n', sc.type);
                if(~isequal('None', sc.file))
                    printf('\t\tFile:                 "%s",\n', sc.file);

                endif;
                printf('\t\tValid:                True,\n');
                printf('\t\tDate of scan:         %s,\n', ...
                    datestr(sc.dt_scan, 'dd-mmm-yyyy') ...
                    );
                if(~isnan(sc.dt_irrd))
                    printf('\t\tDate of irradiation:  %s,\n', ...
                        datestr(sc.dt_irrd, 'dd-mmm-yyyy') ...
                        );

                endif;
                printf('\t\tPixel data:           [%dx%dx%d],\n', ...
                    size(sc.pd, 1), ...
                    size(sc.pd, 2), ...
                    size(sc.pd, 3) ...
                    );
                if(~isempty(sc.rs))
                    printf('\t\tXResolution:          %d,\n', sc.rs(1));
                    printf('\t\tYResolution:          %d,\n', sc.rs(2));
                    printf('\t\tResolution units:     %s,\n', sc.ru);

                endif;
                printf('\t\tPixel data smoothing: %s\n', sc.ds.title);
            else
                printf('\t\tTitle: %s,\n', sc.title);
                printf('\t\tType:  %s,\n', sc.type);
                if(~isequal('None', sc.file))
                    printf('\t\tFile:  "%s",\n', sc.file);

                endif;
                printf('\t\tValid: False\n');
            endif;
            printf('\t)\n');

        endfunction;

        function result = str_rep(sc)
% -----------------------------------------------------------------------------
%
% Method 'str_rep':
%
% Use:
%       -- result = sc.str_rep()
%
% Description:
%          A convenience method that is used to format string representation of
%          the Scan instance.
%
% -----------------------------------------------------------------------------
            if(~isequal('None', sc.file))
                result = sprintf('Scan("%s")', sc.file);

            else
                result = sprintf('Scan("%s")', sc.title);

            endif;

        endfunction;

        function css = cellarray(sc)
% -----------------------------------------------------------------------------
%
% Method 'cellarray':
%
% Use:
%       -- css = sc.cellarry()
%
% Description:
%          Return film object structure as cell array.
%
% -----------------------------------------------------------------------------
            css = {};
            css = {sc.title, sc.type};
            if(~isequal('None', sc.file))
                css{end + 1} = sc.file;

            endif;
            if(~isnan(sc.dt_scan))
                css{end + 1} = datestr(sc.dt_scan, 'dd-mmm-yyyy');

            else
                css{end + 1} = 'N/A';

            endif;
            if(~isnan(sc.dt_irrd))
                css{end + 1} = datestr(sc.dt_irrd, 'dd-mmm-yyyy');

            else
                css{end + 1} = 'N/A';

            endif;
            if(~isempty(sc.pd))
                css{end + 1} = sprintf( ...
                    'Pixel data: [%dx%dx%d]', ...
                    size(sc.pd, 1), ...
                    size(sc.pd, 2), ...
                    size(sc.pd, 3) ...
                    );
            else
                css{end + 1} = 'Pixel data: [0x0x0]';

            endif;
            if(~isempty(sc.rs))
                css{end + 1} = sprintf('%d', sc.rs(1));
                css{end + 1} = sprintf('%d', sc.rs(2));
                css{end + 1} = sprintf('%s', sc.ru);

            endif;
            css{end + 1} = sc.ds.title();

        endfunction;

        function result = isequivalent(sc, other)
% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = sc.isequivalent(other)
%
% Description:
%          Return whether or not two Scan instances are equivalent. Two
%          instances are equivalent if they are of the same type, same size,
%          same date of scanning, same date of irradiation, and of same
%          resolution.
% -----------------------------------------------------------------------------
            fname = 'isequivalent';

            if(~isa(other, 'Scan'))
                error( ...
                    '%s: other must be an instance of the "Scan" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = true;
            if(~isequal(sc.type, other.type));
                result = false;
                return;

            endif;
            if(sc.scan_size() ~= other.scan_size());
                result = false;
                return;

            endif;
            if(isnan(sc.dt_scan))
                if(isnan(sc.dt_scan) && ~isnan(other.dt_scan))
                    result = false;
                    return;

                endif;

            else
                if(sc.dt_scan ~= other.dt_scan)
                    result = false;
                    return;

                endif;

            endif;
            if(isnan(sc.dt_irrd))
                if(isnan(sc.dt_irrd) && ~isnan(other.dt_irrd))
                    result = false;
                    return;

                endif;

            else
                if(sc.dt_irrd ~= other.dt_irrd)
                    result = false;
                    return;

                endif;

            endif;
            if(~isequal(sc.ru, sc.ru))
                result = false;
                return;

            endif;
            if(~isequal(sc.rs, sc.rs))
                result = false;
                return;

            endif;

        endfunction;

        function result = isequal(sc, other)
% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = sc.isequal(other)
%
% Description:
%          Return whether or not two 'Scan' instances are equal. Two
%          instances are equal if all of their fields have identical values.
%
% -----------------------------------------------------------------------------
            fname = 'isequal';

            if(~isa(other, 'Scan'))
                error( ...
                    '%s: other must be an instance of the "Scan" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = true;
            if(~isequal(sc.title, other.title));
                result = false;
                return;

            endif;
            if(~isequal(sc.file, other.file));
                result = false;
                return;

            endif;
            if(~isequal(sc.type, other.type));
                result = false;
                return;

            endif;
            if(sc.scan_size() ~= other.scan_size());
                result = false;
                return;

            endif;
            if(isnan(sc.dt_scan))
                if(isnan(sc.dt_scan) && ~isnan(other.dt_scan))
                    result = false;
                    return;

                endif;

            else
                if(sc.dt_scan ~= other.dt_scan)
                    result = false;
                    return;

                endif;

            endif;
            if(isnan(sc.dt_irrd))
                if(isnan(sc.dt_irrd) && ~isnan(other.dt_irrd))
                    result = false;
                    return;

                endif;

            else
                if(sc.dt_irrd ~= other.dt_irrd)
                    result = false;
                    return;

                endif;

            endif;
            if(~isequal(sc.ru, sc.ru))
                result = false;
                return;

            endif;
            if(~isequal(sc.rs, sc.rs))
                result = false;
                return;

            endif;
            if(~sc.ds.isequal(other.ds))
                result = false;
                return;

            endif;
            if(~isequal(sc.pd, other.pd))
                result = false;
                return;

            endif;


        endfunction;

        function result = scan_size(sc)
% -----------------------------------------------------------------------------
%
% Method 'scan_size':
%
% Use:
%       -- result = sc.scan_size()
%
% Description:
%          Return scan size (size of the pixel data matrix).
%
% -----------------------------------------------------------------------------
            if(sc.is_valid())
                result = [size(sc.pd, 1), size(sc.pd, 2), size(sc.pd, 3)];

            else
                result = [0, 0, 0];

            endif;

        endfunction;

        function result = is_valid(sc)
% -----------------------------------------------------------------------------
%
% Method 'is_valid':
%
% Use:
%       -- result = sc.is_valid()
%
% Description:
%          Return if scan is whether valid or not. The scan is valid if during
%          object initialization no waning was generated (i.e. sc.wrn = 'None').
%
% -----------------------------------------------------------------------------
            result = isequal('None', sc.wrn);

        endfunction;

        function pd = pixel_data(sc)
% -----------------------------------------------------------------------------
%
% Method 'pixel_data':
%
% Use:
%       -- pd = sc.pixel_data()
%
% Description:
%          Return copy of the scan pixel data. If pixel data smoothing is
%          defined, return smoothed data.
%
% -----------------------------------------------------------------------------
        pd = sc.ds.smooth(sc.pd);

        endfunction;

    endmethods;

endclassdef;
