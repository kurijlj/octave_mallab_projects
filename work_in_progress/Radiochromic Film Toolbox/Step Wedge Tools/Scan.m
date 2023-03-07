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
%       dateir: serial date number (see: datenum), def. NaN
%           Serial date number representing the date of irradiation of the
%           scan, if applicable. The date of irradiation must be no older than
%           01-Jan-2022.
%
%       datesc: serial date number (see: datenum), def. current date, or file
%               modification date
%           Serial date number representing the date when the pixel data of the
%           image were generated. If pixel data are read from the file, the
%           date of scan is automatically set from the file metadata.
%           Otherwise, it is set as the current date. The date of the scan
%           must be no older than 01-Jan-2022.
%
%       sctype: "BkgScan"|"DummyBkg"|"DummyScan"|"DummyZeroL"|{"SignalScan"}
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
        dateir = NaN;
        % Date of scanning (mandatory)
        datesc = NaN;
        % Scan type (mandatory)
        sctype   = 'SignalScan';
        % Raw pixel data
        pd     = [];
        % Image resolution (if applicable)
        rsl    = [];
        % Resolution units (if applicable)
        rslu   = 'None';
        % Warning generated during the initialization of the object
        ws     = 'None';

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
                    dateir, ...
                    datesc, ...
                    sctype ...
                    ] = parseparams( ...
                    varargin, ...
                    'title', 'Signal scan', ...
                    'dateir', NaN, ...
                    'datesc', NaN, ...
                    'sctype', 'SignalScan' ...
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
                    'sctype' ...
                    );

                % Validate value supplied for the dateir
                if(~isnan(dateir))
                    validateattributes( ...
                        dateir, ...
                        {'numeric'}, ...
                        { ...
                            'nonempty', ...
                            'scalar', ...
                            'integer', ...
                            'finite', ...
                            'positive' ...
                            }, ...
                        fname, ...
                        'dateir' ...
                        );

                    % Check if given date comes after the 01-Jan-2000
                    if(datenum(2000, 1, 1) > dateir)
                        error( ...
                            '%s: Date of irradiation (dateir) too old: %s', ...
                            datestr(dateir) ...
                            );

                    endif;

                endif;  % ~isnan(dateir)

                % Validate value supplied for the datesc
                if(~isnan(datesc))
                    validateattributes( ...
                        datesc, ...
                        {'numeric'}, ...
                        { ...
                            'nonempty', ...
                            'scalar', ...
                            'integer', ...
                            'finite', ...
                            'positive' ...
                            }, ...
                        fname, ...
                        'datesc' ...
                        );

                    % Check if given date comes after the 01-Jan-2000
                    if(datenum(2000, 1, 1) > props{2, 2})
                        error( ...
                            '%s: Date of scan (datesc) too old: %s', ...
                            datestr(datesc) ...
                            );

                    endif;

                endif;  % ~isnan(datesc)

                % Deteremine type of the constructor by the data type of the
                % supplied positional argument.

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
                    datestr(sc.datesc, 'dd-mmm-yyyy') ...
                    );
                if(~isnan(sc.dateir))
                    printf('\t\tDate of irradiation:  %s,\n', ...
                        datestr(sc.dateir, 'dd-mmm-yyyy') ...
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
            if(~isnan(sc.datesc))
                sccell{end + 1} = datestr(sc.datesc, 'dd-mmm-yyyy');

            else
                sccell{end + 1} = 'N/A';

            endif;
            if(~isnan(sc.dateir))
                sccell{end + 1} = datestr(sc.dateir, 'dd-mmm-yyyy');

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
            if(isnan(sc.datesc))
                if(isnan(sc.datesc) && ~isnan(other.datesc))
                    result = false;
                    return;

                endif;

            else
                if(sc.datesc ~= other.datesc)
                    result = false;
                    return;

                endif;

            endif;
            if(isnan(sc.dateir))
                if(isnan(sc.dateir) && ~isnan(other.dateir))
                    result = false;
                    return;

                endif;

            else
                if(sc.dateir ~= other.dateir)
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
            if(isnan(sc.datesc))
                if(isnan(sc.datesc) && ~isnan(other.datesc))
                    result = false;
                    return;

                endif;

            else
                if(sc.datesc ~= other.datesc)
                    result = false;
                    return;

                endif;

            endif;
            if(isnan(sc.dateir))
                if(isnan(sc.dateir) && ~isnan(other.dateir))
                    result = false;
                    return;

                endif;

            else
                if(sc.dateir ~= other.dateir)
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
%          object initialization no waning was generated (i.e. sc.ws = 'None').
%
% -----------------------------------------------------------------------------
            result = isequal('None', sc.ws);

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
