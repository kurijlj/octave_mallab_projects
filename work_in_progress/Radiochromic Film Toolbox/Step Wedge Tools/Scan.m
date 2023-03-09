classdef Scan
%% -----------------------------------------------------------------------------
%%
%% Class 'Scan':
%%
%% -----------------------------------------------------------------------------
%
%% Description:
%       Data structure representing a single data scan.
%
%       The class constructor can be invoked with a string representing the
%       path to a 'TIFF' image, a 2D or 3D matrix representing scan pixel data,
%       or with another class instance.
%
%       The minimum required scan signal size is 12x12 pixels, which roughly
%       corresponds to an 4 mm x 4 mm area if a film piece is scanned using
%       lowest acceptable resolution (72 dpi x 72 dpi). If the scan signal
%       is loaded from an image file, the following requirements are mandatory:
%           - must be a TIFF file;
%           - must be an RGB image;
%           - must be 16 bits per sample (uint16);
%           - must be an uncompressed image.
%
%       Two scan objects are equivalent if they are of the same type, same
%       size, same date of scanning, same date of irradiation, and of the same
%       resolution.
%
%       The scan object is valid if there are no warnings generated (sc.ws =
%       'None') during object initialization. The validity of the scan object
%       can be checked using 'is_valid' method.
%
%       Multiple property-value pairs may be specified for the scan object, but
%       they must appear in pairs.
%
%       Properties of 'Scan' objects:
%
%       title: string, def. "Signal scan"
%           A string containing a title describing scanned data.
%
%       DateOfIrradiation: serial date number (see: datenum), def. NaN
%           Serial date number representing the date of irradiation of the
%           scan, if applicable. The date of irradiation must be no older than
%           01-Jan-2022.
%
%       DateOfScan: serial date number (see: datenum), def. current date, or
%               file modification date
%           Serial date number representing the date when the pixel data of the
%           image were generated. If pixel data are read from the file, the
%           date of scan is automatically set from the file metadata.
%           Otherwise, it is set as the current date. The date of the scan
%           must be no older than 01-Jan-2022.
%
%       ScanType: "BkgScan"|"DummyBkg"|"DummyScan"|"DummyZeroL"|{"SignalScan"}
%               |"ZeroLScan"
%           Defines the type of scan. This property defines how the object will
%           be used for the calculation of the optical density of the
%           measurement, and is one of the parameters determining which scan
%           objects are mutually equivalent and can form a scan set.
%
% -----------------------------------------------------------------------------

    properties (SetAccess = private, GetAccess = public)
%% ----------------------------------------------------------------------------
%%
%% Properties section
%%
%% ----------------------------------------------------------------------------
        % Film piece title (unique ID)
        title  = 'Signal scan';
        % Source file (if applicable)
        file   = 'None';
        % Date of irradiation (if applicable)
        dtofir = NaN;
        % Date of scanning (mandatory)
        dtofsc = NaN;
        % Scan type (mandatory)
        sctype = 'SignalScan';
        % Raw pixel data
        pd     = [];
        % Image resolution (if applicable)
        rsl    = [];
        % Resolution units (if applicable)
        rslu   = 'None';
        % Warning generated during the initialization of the object
        ws     = {};

    endproperties;


    methods (Access = public)
%% ----------------------------------------------------------------------------
%%
%% Public methods section
%%
%% ----------------------------------------------------------------------------

        function sc = Scan(varargin)
%  ----------------------------------------------------------------------------
%
%  Method 'Scan':
%
%  Use:
%       -- sc = Scan(tif)
%       -- sc = Scan(pd)
%       -- sc = Scan(..., "PROPERTY", VALUE, ...)
%       -- sc = Scan(other)
%
%  Description:
%          Class constructor.
%
%  ----------------------------------------------------------------------------
            fname = 'Scan';
            use_case_a = sprintf(' -- sc = %s(tif)', fname);
            use_case_b = sprintf(' -- sc = %s(pd)', fname);
            use_case_c = sprintf( ...
                ' -- sc = %s(..., "PROPERTY", VALUE, ...)', ...
                fname ...
                );
            use_case_d = sprintf(' -- sc = %s(other)', fname);

            if(0 == nargin)
                % We don't support default constructor. Invalid call to
                % constructor
                error( ...
                    'Invalid call to %s. Correct usage is:\n%s\n%s\n%s\n%s', ...
                    fname, ...
                    use_case_a, ...
                    use_case_b, ...
                    use_case_c, ...
                    use_case_d ...
                    );

            else
                % Parse arguments
                [ ...
                    pos, ...
                    title, ...
                    dtofir, ...
                    dtofsc, ...
                    sctype ...
                    ] = parseparams( ...
                    varargin, ...
                    'title', 'Signal scan', ...
                    'DateOfIrradiation', NaN, ...
                    'DateOfScan', NaN, ...
                    'ScanType', 'SignalScan' ...
                    );

                if(1 ~= numel(pos))
                    % Invalid call to constructor
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                'Invalid call to %s. Correct usage ', ...
                                'is:\n%s\n%s\n%s\n%s' ...
                                ), ...
                            fname, ...
                            use_case_a, ...
                            use_case_b, ...
                            use_case_c, ...
                            use_case_d ...
                            ) ...
                        );

                endif;  % (1 ~= numel(pos))

                % Validate value supplied for the Title
                if(~ischar(title) || isempty(title))
                    error('%s: Title must be a non-empty string', fname);

                endif;

                % Validate value supplied for the Scan type
                validatestring( ...
                    sctype, ...
                    { ...
                        'ZeroLScan', ...
                        'BkgScan', ...
                        'SignalScan', ...
                        'DummyZeroL', ...
                        'DummyBkg', ...
                        'DummyScan' ...
                        }, ...
                    fname, ...
                    'ScanType' ...
                    );

                % Validate value supplied for the DateOfIrradiation
                if(~isnan(dtofir))
                    validateattributes( ...
                        dtofir, ...
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
                    if(datenum(2000, 1, 1) > dtofir)
                        error( ...
                            '%s: Date of irradiation (dtofir) too old: %s', ...
                            datestr(dtofir) ...
                            );

                    endif;

                endif;  % ~isnan(dtofir)

                % Validate value supplied for the DateOfScan
                if(~isnan(dtofsc))
                    validateattributes( ...
                        dtofsc, ...
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

                    % Check if the given date comes after the 01-Jan-2000
                    if(datenum(2000, 1, 1) > props{2, 2})
                        error( ...
                            '%s: Date of scan (dtofsc) too old: %s', ...
                            datestr(dtofsc) ...
                            );

                    endif;

                endif;  % ~isnan(dtofsc)

                % Determine the type of the constructor by the data type of the
                % supplied positional argument.
                if(isnumeric(pos{1}))
                    % It seems that the user passed pixel data as a matrix.
                    % Validate if supplied pixel data matrix is of the proper
                    % format
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
                        % We have neither a grayscale nor an RGB image. Format
                        % the warning message and add the message to the
                        % warnings stack
                        w = sprintf( ...
                            cstrcat( ...
                                'Unsupported pixel data format. ', ...
                                'Expected single channel, or three ', ...
                                'channel image, got %d channels' ...
                                ), ...
                            size(pos{1}, 3) ...
                            );

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring pixel data ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        sc.ws{end + 1} = w;

                        % Stop further constructor execution
                        return;

                    % Check if the image size complies with minimal required
                    % signal size
                    elseif(12 > size(pos{1}, 1) || 12 > size(pos{1}, 2))
                        % The size doesn't comply with the minimum required
                        % image size of 12 pixels x 12 pixels (4 mm x 4 mm).
                        % Format the warning message and add the message to the
                        % warnings stack
                        w = sprintf( ...
                            cstrcat( ...
                                'Unsupported pixel data format. ', ...
                                'Expected at least 12 pixels x 12 ', ...
                                'pixels image, got %d pixels x %d ', ...
                                'pixels' ...
                                ), ...
                            size(pos{1}, 1), ...
                            size(pos{1}, 2) ...
                            );

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring pixel data ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        sc.ws{end + 1} = w;

                        % Stop further constructor execution
                        return;

                    endif;  % 12x12 > LxW

                    % Set given matrix as pixel data
                    sc.pd = pos{1};

                    % Check if user supplied date of scan
                    if(isnan(dtofsc))
                        % Date of scan not set, use the current date
                        dtofsc = datenum(date());

                    endif;

                elseif(ischar(pos{1}))
                    % It seems that the user passed pixel data as a path to a
                    % tif file.

                    % Check if we are dealing with non-empty string
                    if(~ischar(pos{1}) || isempty(pos{1}))
                        error( ...
                            '%s: tif path must be a non-empty string', ...
                            fname ...
                            );

                    endif;

                    % Check if we have a regular file
                    if(~isfile(pos{1}))
                        % We don't have a regular file. Format the warning
                        % message and add the message to the warnings stack
                        w = sprintf('%s is not a regular file', pos{1});

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring file ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        sc.ws{end + 1} = w;

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
                        % We don't have an image file. Format the warning
                        % message and add the message to the warnings stack
                        w = sprintf('%s is not an image file', pos{1});

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring file ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        sc.ws{end + 1} = w;

                        % Stop further constructor execution
                        return;

                    end_try_catch;

                    % Check if we have a TIFF image
                    if(~isequal('TIFF', ifi.Format))
                        % We don't have a TIFF image. Format the warning message
                        % and add the message to the warnings stack
                        w = sprintf('%s is not an TIFF image', pos{1});

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring file ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        sc.ws{end + 1} = w;

                        % Stop further constructor execution
                        return;

                    endif;

                    % Check if we have an RGB TIFF image
                    if(2 ~= tiff_tag_read(pos{1}, 262))
                        % We don't have an RGB image. Format the warning message
                        % and add the message to the wrnings stack
                        w = sprintf('%s is not an RGB image', pos{1});

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring file ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        sc.ws{end + 1} = w;

                        % Stop further constructor execution
                        return;

                    endif;

                    % Check if we have the right bit depth
                    if(16 ~= ifi.BitDepth)
                        % We don't have 16 bits per sample. Format the warning
                        % message and add the message to the warnings stack
                        w = sprintf( ...
                            cstrcat( ...
                                '%s has noncomplying bit depth ', ...
                                '(%d bps, expected 16 bps)' ...
                                ), ...
                            pos{1}, ...
                            ifi.BitDepth ...
                            );

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring file ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        sc.ws{end + 1} = w;

                        % Stop further constructor execution
                        return;

                    endif;

                    % Check if we are dealing with an uncompressed image
                    if(1 ~= tiff_tag_read(pos{1}, 259))
                        % We don't have an uncompressed image. Format the
                        % warning message and add the message to the warnings
                        % stack
                        w = sprintf( ...
                            '%s is not an uncompressed TIFF image', ...
                            pos{1} ...
                            );

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring file ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        sc.ws{end + 1} = w;

                        % Stop further constructor execution
                        return;

                    endif;

                    % Check if horizontal and vertical image resolutions
                    % are the same
                    if(ifi.XResolution ~= ifi.YResolution)
                        % Vertical and horisontal image resolutions are not the
                        % same. Format the warning message and add the message
                        % to the warnings stack
                        w = sprintf( ...
                            cstrcat( ...
                                '%s vertical and horisontal resolutions ', ...
                                'do not comply (%d ~= %d)' ...
                                ), ...
                            pos{1}, ...
                            ifi.XResolution, ...
                            ifi.YResolution ...
                            );

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring file ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        sc.ws{end + 1} = w;

                        % Stop further constructor execution
                        return;

                    endif;

                    % Check if the image size complies with minimal required
                    % signal size
                    if(12 > ifi.Height || 12 > ifi.Width)
                        % The size doesn't comply with the minimum required
                        % image size of 12 pixels x 12 pixels (4 mm x 4 mm).
                        % Format the warning message and add the message to the
                        % warnings stack
                        w = sprintf( ...
                            cstrcat( ...
                                'Unsupported image size. ', ...
                                'Expected at least 12 pixels x 12 ', ...
                                'pixels image, got %d pixels x %d ', ...
                                'pixels' ...
                                ), ...
                            ifi.Width, ...
                            ifi.Height ...
                            );

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring pixel data ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        sc.ws{end + 1} = w;

                        % Stop further constructor execution
                        return;

                    endif;

                    % Assign file name to the file attribute
                    sc.file = pos{1};
                    % Load pixel data from file to a temporary variable
                    sc.pd = double(imread(pos{1}));
                    % Assign resolution to temporary variable
                    sc.rsl = [ifi.XResolution, ifi.YResolution];
                    % Load resolution units from the file
                    rslu = tiff_tag_read(pos{1}, 296);
                    % Convert units number to units string
                    if(1 == ru)
                        sc.rslu = 'None';

                    elseif(2 == ru)
                        sc.rslu = 'dpi';

                    else
                        sc.rslu = 'dpcm';

                    endif;

                    % Check if user passed the date of scan
                    if(isnan(dtofsc))
                        % DateOfScan not set, use the file modification date as
                        % the default for the DateOfScan
                        dtofsc = datenum(strsplit(ifi.FileModDate){1});

                    endif;

                else
                    % Unsupported data type passed as positional argument.
                    % Invalid call to constructor
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                'Invalid call to %s. Correct usage ', ...
                                'is:\n%s\n%s\n%s\n%s' ...
                                ), ...
                            fname, ...
                            use_case_a, ...
                            use_case_b, ...
                            use_case_c, ...
                            use_case_d ...
                            ) ...
                        );

                endif;  % ischar(pos{1})

                % Assign validated values to the instance parameters
                sc.title  = title;
                sc.dtofir = dtofir;
                sc.dtofsc = dtofsc;
                sc.sctype = sctype;

            endif;  % 0 == nargin

        endfunction;  % Scan()


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
                printf('\t\tScan type:            %s,\n', sc.sctype);
                if(~isequal('None', sc.file))
                    printf('\t\tFile:                 "%s",\n', sc.file);

                endif;
                printf('\t\tValid:                True,\n');
                printf('\t\tDate of scan:         %s,\n', ...
                    datestr(sc.dtofsc, 'dd-mmm-yyyy') ...
                    );
                if(~isnan(sc.dtofir))
                    printf('\t\tDate of irradiation:  %s,\n', ...
                        datestr(sc.dtofir, 'dd-mmm-yyyy') ...
                        );

                endif;
                printf('\t\tPixel data:           [%dx%dx%d],\n', ...
                    size(sc.pd, 1), ...
                    size(sc.pd, 2), ...
                    size(sc.pd, 3) ...
                    );
                if(~isempty(sc.rsl))
                    printf('\t\tXResolution:          %d,\n', sc.rsl(1));
                    printf('\t\tYResolution:          %d,\n', sc.rsl(2));
                    printf('\t\tResolution units:     %s,\n', sc.rslu);

                endif;
            else
                printf('\t\tTitle:      %s,\n', sc.title);
                printf('\t\tScan type:  %s,\n', sc.sctype);
                if(~isequal('None', sc.file))
                    printf('\t\tFile:      "%s",\n', sc.file);

                endif;
                printf('\t\tValid:      False\n');
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


        function sccell = ascell(sc)
% -----------------------------------------------------------------------------
%
% Method 'ascell':
%
% Use:
%       -- sccell = sc.ascell()
%
% Description:
%          Return scan object structure as cell array.
%
% -----------------------------------------------------------------------------
            sccell = {};
            sccell = {sc.title, sc.sctype};
            if(~isequal('None', sc.file))
                sccell{end + 1} = sc.file;

            endif;
            if(~isnan(sc.dtofsc))
                sccell{end + 1} = datestr(sc.dtofsc, 'dd-mmm-yyyy');

            else
                sccell{end + 1} = 'N/A';

            endif;
            if(~isnan(sc.dtofir))
                sccell{end + 1} = datestr(sc.dtofir, 'dd-mmm-yyyy');

            else
                sccell{end + 1} = 'N/A';

            endif;
            if(~isempty(sc.pd))
                sccell{end + 1} = sprintf( ...
                    'Pixel data: [%dx%dx%d]', ...
                    size(sc.pd, 1), ...
                    size(sc.pd, 2), ...
                    size(sc.pd, 3) ...
                    );
            else
                sccell{end + 1} = 'Pixel data: [0x0x0]';

            endif;
            if(~isempty(sc.rsl))
                sccell{end + 1} = sprintf('%d', sc.rsl(1));
                sccell{end + 1} = sprintf('%d', sc.rsl(2));
                sccell{end + 1} = sprintf('%s', sc.rslu);

            endif;

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
            if(~isequal(sc.sctype, other.sctype));
                result = false;
                return;

            endif;
            if(sc.scan_size() ~= other.scan_size());
                result = false;
                return;

            endif;
            if(isnan(sc.dtofsc))
                if(isnan(sc.dtofsc) && ~isnan(other.dtofsc))
                    result = false;
                    return;

                endif;

            else
                if(sc.dtofsc ~= other.dtofsc)
                    result = false;
                    return;

                endif;

            endif;
            if(isnan(sc.dtofir))
                if(isnan(sc.dtofir) && ~isnan(other.dtofir))
                    result = false;
                    return;

                endif;

            else
                if(sc.dtofir ~= other.dtofir)
                    result = false;
                    return;

                endif;

            endif;
            if(~isequal(sc.rslu, sc.rslu))
                result = false;
                return;

            endif;
            if(~isequal(sc.rsl, sc.rsl))
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
            if(~isequal(sc.sctype, other.sctype));
                result = false;
                return;

            endif;
            if(sc.scan_size() ~= other.scan_size());
                result = false;
                return;

            endif;
            if(isnan(sc.dtofsc))
                if(isnan(sc.dtofsc) && ~isnan(other.dtofsc))
                    result = false;
                    return;

                endif;

            else
                if(sc.dtofsc ~= other.dtofsc)
                    result = false;
                    return;

                endif;

            endif;
            if(isnan(sc.dtofir))
                if(isnan(sc.dtofir) && ~isnan(other.dtofir))
                    result = false;
                    return;

                endif;

            else
                if(sc.dtofir ~= other.dtofir)
                    result = false;
                    return;

                endif;

            endif;
            if(~isequal(sc.rslu, sc.rslu))
                result = false;
                return;

            endif;
            if(~isequal(sc.rsl, sc.rsl))
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
%          object initialization no waning was generated (i.e. sc.ws = {}).
%
% -----------------------------------------------------------------------------
            result = isempty(sc.ws);

        endfunction;


        function pd = pixel_data(sc, pds)
% -----------------------------------------------------------------------------
%
% Method 'pixel_data':
%
% Use:
%       -- pd = sc.pixel_data(pds)
%
% Description:
%          Return copy of the scan pixel data. If pixel data smoothing is
%          defined, return smoothed data.
%
% -----------------------------------------------------------------------------
        fname = 'pixel_data';

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

        pd = pds.smooth(sc.pd);

        endfunction;

    endmethods;

endclassdef;
