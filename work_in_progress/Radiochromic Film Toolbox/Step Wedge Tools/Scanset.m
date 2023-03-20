classdef Scanset
%% -----------------------------------------------------------------------------
%%
%% Class 'Scanset':
%%
%% -----------------------------------------------------------------------------
%
%% Description:
%       Ordered set of data scans (film scans).
%
%       Invoke class constructor with:
%           -- sequence of strings representing paths to equivalent 'TIFF' scans
%              (see help on Scan class for details);
%           -- sequence of a 2D or a 3D matrix representing scan pixel data;
%           -- sequence of equivalent Scan instances;
%           -- other instance of the Scanset class (yield a copy)
%
%       See help on the Scan class for details on minimum required scan size.
%
%       Two Scanset instances are equivalent if their pixel data is the same
%       size.
%
%       The Scanset object are equivalent if their opixel data is of the same
%       size.
%
%       The Scanset object is valid if there was no warnings generated
%       (Scanset.ws = {}) during object initialization. The validity of the
%       Scanset object can be checked calling 'isvalid' method.
%
%       Multiple property-value pairs may be specified for the Scanset object,
%       but they must appear in pairs.
%
%       Properties of 'Scanset' objects:
%
%       Title: string, def. 'Signal scanset'
%           A string containing a title describing scanned data.
%
%       DateOfIrradiation: serial date number (see: datenum), def. NaN
%           Serial date number representing the date of irradiation of the
%           scanset, if applicable. The date of irradiation must be no older
%           than 01-Jan-2022.
%
%       DateOfScan: serial date number (see: datenum), def. current date, or
%               scan modification date
%           Serial date number representing the date when the pixel data of the
%           scanset were generated. If pixel data are read from the file, the
%           date of scan is automatically set from the file metadata.
%           Otherwise, it is set as the current date. The date of the scan
%           must be no older than 01-Jan-2022.
%
%       ScansetType: 'Background'|'ZeroLight'|{'Signal'}
%           Defines the type of scan. This property defines how the object will
%           be used for the calculation of the optical density of the
%           measurement.
%
%       Smoothing: PixelDataSmotthing, def. PixelDataSmoothing()
%           Data smoothing algorithm and parameters of the smoothing algorithm
%           to be used on each individual scan before averasging pixel data.
%           By default no smoothing is applied to the pixel data. See help on
%           PixelDataSmoothing class for details.
%
%
%% Public methods:
%
%       - Scanset(varargin): Class constructor.
%
%       - disp(): The disp method is used by Octave whenever a class instance
%         should be displayed on the screen.
%
%       - str_rep(): A convenience method that is used to format string
%         representation of the Scanset instance.
%
%       - ascell(): Return scanset object structure as cell array.
%
%       - isequivalent(other): Return whether or not two Scanset instances are
%         equivalent. Two instances are equivalent if they have same resolution,
%         and linear dimensions of their pixel data do not differ more than 10
%         pixels for each linear dimension.
%
%       - isequal(other): Return whether or not two 'Scanset' instances are
%         equal. Two instances are equal if all of their fields have
%         identical values.
%
%       - data_size(): Return size of the pixel data matrix.
%
%       - isvalid(): Return if scan set is valid or not. The scan set is valid
%         if during object initialization no waning was generated
%         (i.e. ss.ws = {}).
%
%       - pixel_data(pds): Return copy of the scan set pixel data. If pixel data
%         smoothing is defined, return smoothed data.
%
%       - inprofile(pds, x): Return in profile data for the given scanset and
%         the given column index.
%
%       - crossprofile(pds, y): Return cross profile data for the given scanset
%         and the given row index.
%
%       - inplot(pds, x): Plot in profile data for the given scanset and the
%         given column index.
%
%       - crossplot(pds, y): Plot cross profile data for the given scanset and
%         the given row index.
%
%       - imshow(pds, heq): Plot scan set pixel data as image.
%
% -----------------------------------------------------------------------------

    properties (SetAccess = private, GetAccess = public)
%% -----------------------------------------------------------------------------
%%
%% Properties section
%%
%% -----------------------------------------------------------------------------
        % Scanset title (unique ID)
        sstitle = 'Signal';
        % List of files defining the scanset (if applicable)
        files   = {};
        % Date of irradiation (if applicable)
        dtofir  = NaN;
        % Date of scanning (mandatory)
        dtofsc  = NaN;
        % Type (mandatory)
        sstype  = 'Signal';
        % Pixel data
        pd      = [];
        % Image resolution (if applicable)
        rsl     = [];
        % Resolution units (if applicable)
        rslu    = 'None';
        % List of warnings generated during the initialization of the object
        ws      = {};

    endproperties;


    methods (Access = public)
%% -----------------------------------------------------------------------------
%%
%% Public methods section
%%
%% -----------------------------------------------------------------------------

        function ss = Scanset(varargin)
% -----------------------------------------------------------------------------
%
% Method 'Scanset':
%
% Use:
%       -- ss = Scanset(tif1, tif2, ...)
%       -- ss = Scanset(PD1, PD2, ...)
%       -- ss = Scanset(sc1, sc2, ...)
%       -- ss = Scanset(..., "PROPERTY", VALUE, ...)
%       -- ss = Scanset(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
            fname = 'Scanset';
            use_case_a = ' -- ss = Scanset(tif1, tif2, ...)';
            use_case_b = ' -- ss = Scanset(PD1, PD2, ...)';
            use_case_c = ' -- ss = Scanset(sc1, sc2, ...)';
            use_case_d = ' -- ss = Scanset(..., "PROPERTY", VALUE, ...)';
            use_case_e = ' -- ss = Scanset(other)';

            if(0 == nargin)
                % We don't support default constructor ------------------------
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            'Invalid call to %s. Correct usage ', ...
                            'is:\n%s\n%s\n%s\n%s\n%s' ...
                            ), ...
                        fname, ...
                        use_case_a, ...
                        use_case_b, ...
                        use_case_c, ...
                        use_case_d, ...
                        use_case_e ...
                        ) ...
                    );

                % End of case 0 == nargin
            elseif(1 == nargin)
                scref = NaN;

                % Check if copy constructor invoked ---------------------------
                if(isa(varargin{1}, 'Scanset'))
                    % Copy constructor invoked
                    ss.sstitle = varargin{1}.sstitle;
                    ss.files   = varargin{1}.files;
                    ss.dtofir  = varargin{1}.dtofir;
                    ss.dtofsc  = varargin{1}.dtofsc;
                    ss.sstype  = varargin{1}.sstype;
                    ss.pd      = varargin{1}.pd;
                    ss.rsl     = varargin{1}.rsl;
                    ss.rslu    = varargin{1}.rslu;
                    ss.ws      = varargin{1}.ws;

                    return;

                % Check if constructor called with a path to a file or with a
                % pixel data matrix object
                elseif(ischar(varargin{1}) || isnumeric(varargin{1}))
                    scref = Scan(varargin{1});

                else
                    scref = varargin{1};

                endif;  % isa(varargin{1}, 'Scanset')

                if(~scref.isvalid())
                    % Add warning message to the warnings stack
                    ss.ws{end + 1} = scref.ws;

                    % Stop further constructor execution
                    return;

                endif;  % scref.isvalid()

                ss.files{end + 1} = scref.file;
                ss.dtofir         = scref.dtofir;
                ss.dtofsc         = scref.dtofsc;
                ss.pd             = scref.pixel_data();
                ss.ws             = scref.ws;

                if( ...
                        isequal('ZeroLScan', scref.sctype) ...
                        || isequal('DummyZeroL', scref.sctype) ...
                        )
                    ss.sstype = 'ZeroLight';
                    ss.sstitle  = 'Zero light';

                elseif( ...
                        isequal('BkgScan', scref.sctype) ...
                        || isequal('DummyBkg', scref.sctype) ...
                        )
                    ss.sstype = 'Background';
                    ss.sstitle  = 'Background';

                else
                    ss.sstype = 'Signal';
                    ss.sstitle  = 'Signal';

                endif;  % 'ZeroLScan' || 'DummyZeroL'

                % End of case 1 == nargin
            else
                % Determine index of the first optional argument
                idx = 1;
                while(nargin >= idx);
                    if(ischar(varargin{idx}))
                        switch(varargin{idx})
                            case 'Title'
                                break;
                            case 'DateOfIrradiation'
                                break;
                            case 'DateOfScan'
                                break;
                            case 'ScansetType'
                                break;
                            case 'Smoothing'
                                break;

                        endswitch;

                    endif;

                    ++idx;

                endwhile;

                % Parse optional arguments ------------------------------------
                [ ...
                    pos, ...
                    sstitle, ...
                    dtofir, ...
                    dtofsc, ...
                    sstype, ...
                    pds ...
                    ] = parseparams( ...
                    varargin(idx:end), ...
                    'Title', 'Unknown', ...
                    'DateOfIrradiation', NaN, ...
                    'DateOfScan', NaN, ...
                    'ScansetType', 'Unknown', ...
                    'Smoothing', PixelDataSmoothing() ...
                    );

                if(0 ~= numel(pos))
                    % Invalid call to constructor
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                'Invalid call to %s. Correct usage ', ...
                                'is:\n%s\n%s\n%s\n%s\n%s' ...
                                ), ...
                            fname, ...
                            use_case_a, ...
                            use_case_b, ...
                            use_case_c, ...
                            use_case_d, ...
                            use_case_e ...
                            ) ...
                        );

                endif;  % 0 ~= numel(pos)

                pos = varargin(1:idx - 1);

                % Validate value supplied for the Title -----------------------
                if(~ischar(sstitle) || isempty(sstitle))
                    error('%s: Title must be a non-empty string', fname);

                endif;  % ~ischar(sstitle) || isempty(sstitle)

                % Validate value supplied for the ScansetType -----------------
                validatestring( ...
                    sstype, ...
                    { ...
                        'Signal', ...
                        'Background', ...
                        'ZeroLight' ...
                        }, ...
                    fname, ...
                    'ScansetType' ...
                    );

                % Validate value supplied for the DateOfIrradiation -----------
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

                    endif;  % datenum(2000, 1, 1) > dtofir

                endif;  % ~isnan(dtofir)

                % Validate value supplied for the DateOfScan ------------------
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

                    endif;  % datenum(2000, 1, 1) > props{2, 2}

                endif;  % ~isnan(dtofsc)

                % Validate value supplied for the Smoothing -------------------
                if(~isa(pds, 'PixelDataSmoothing'))
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                '%s: Smoothing must be an instance of the ', ...
                                '"PixelDataSmoothing" class' ...
                                ), ...
                            fname ...
                            ) ...
                        );

                endif;  % ~isa(pds, 'PixelDataSmoothing')

                % Determine the type of input data passed to a constructor call
                % and check if all argument are of teh same type
                if(ischar(pos{1}))
                    r = ~cellfun('ischar', pos);
                    if(0 ~= sum(r))
                        error( ...
                            '%s: varargin(%d) must be a string', ...
                            fname, ...
                            find(r)(1) ...
                            );

                    endif;

                    % End of ischar(pos{1})
                elseif(isnumeric(pos{1}))
                    r = ~cellfun('isnumeric', pos);
                    if(0 ~= sum(r))
                        error( ...
                            '%s: varargin(%d) must be a numerical matrix', ...
                            fname, ...
                            find(r)(1) ...
                            );

                    endif;

                    % End of isnumeric(pos{1})
                elseif(isa(pos{1}, 'Scan'))
                    r = ~cellfun(@(x) isa(x, 'Scan'), pos);
                    if(0 ~= sum(r))
                        error( ...
                            sprintf( ...
                                cstrcat( ...
                                    '%s: varargin(%d) must be an instance ', ...
                                    'of the "Scan" class' ...
                                    ), ...
                                fname, ...
                                find(r)(1) ...
                                ) ...
                            );

                    endif;

                    % End of isa(pos{1}, 'Scan')
                else
                    % Invalid call to constructor
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                'Invalid call to %s. Correct usage ', ...
                                'is:\n%s\n%s\n%s\n%s\n%s' ...
                                ), ...
                            fname, ...
                            use_case_a, ...
                            use_case_b, ...
                            use_case_c, ...
                            use_case_d, ...
                            use_case_e ...
                            ) ...
                        );

                    % End of invalid call to constructor
                endif;  % ischar(pos{1}

                % Process all input arguments ---------------------------------
                scref = NaN;
                idx = 1;
                while(numel(pos) >= idx)
                    if(1 == idx && isa(pos{idx}, 'Scan'))
                        scref = pos{idx};

                    else
                        scref = Scan( ...
                            pos{idx}, ...
                            'Title', sprintf('Scan #%d', idx) ...
                            );

                        if(~scref.isvalid())
                            % Add the waring to the warnings stack
                            ss.ws{end + 1} = scref.ws{:};

                            return;

                        endif;  % ~scref.isvalid()

                    endif;

                    % Initialize Scan instance if needed
                    sc = NaN;
                    if(isa(pos{idx}, 'Scan'))
                        sc = pos{idx};

                    else
                        sc = Scan(pos{idx}, 'Title', sprintf('Scan #%d', idx));

                    endif;

                    if(~sc.isvalid())
                        % Add the waring to the warnings stack
                        ss.ws{end + 1} = sc.ws{:};

                        % Invalidate pixel data and stop further constructor
                        % execution
                        ss.files = {};
                        ss.pd    = [];

                        return;

                    endif;  % ~sc.isvalid()

                    % Check if argument with the index idx is equivalent to the
                    % reference (first) argument
                    if(~scref.isequivalent(sc))
                        w = sprintf( ...
                            '%s and and reference %s are not equivalent', ...
                            sc.str_rep(), ...
                            scref.str_rep() ...
                            );

                        % Display the warning in the Command Window prompt
                        warning( ...
                            '%s: %s. Ignoring pixel data ...', ...
                            fname, ...
                            w ...
                            );

                        % Add the warning to the warnings stack
                        ss.ws{end + 1} = w;

                        % Invalidate scan set data
                        ss.files = {};
                        ss.pd    = [];

                        % Stop further constructor execution
                        return;

                    endif;  % ~scref.isequivalent(sc)

                    % Compute the pixel data
                    if(1 == idx)
                        ss.pd = sc.pixel_data(pds)./numel(pos);

                    else
                        ss.pd = ss.pd + sc.pixel_data(pds)./numel(pos);

                    endif;

                    ss.files{end + 1} = sc.file;

                    ++idx;

                endwhile;  % End of go through all positional arguments

                % Determine scanset attributes --------------------------------
                ss.rsl = scref.rsl;
                ss.rslu = scref.rslu;

                if(isequal('Unknown', sstype))
                    if( ...
                            isequal('ZeroLScan', scref.sctype) ...
                            || isequal('DummyZeroL', scref.sctype) ...
                            )
                        ss.sstype = 'ZeroLight';

                    elseif( ...
                            isequal('BkgScan', scref.sctype) ...
                            || isequal('DummyBkg', scref.sctype) ...
                            )
                        ss.sstype = 'Background';

                    else
                        ss.sstype = 'Signal';

                    endif;  % 'ZeroLScan' || 'DummyZeroL'

                else
                    ss.sstype = sstype;

                endif;  % isequal('Unknown', sstype)

                if(isequal('Unknown', sstitle))
                    ss.sstitle = ss.sstype;

                else
                    ss.sstitle = sstitle;

                endif;  % isequal('Unknown', sstitle)

                if(isnan(dtofir))
                    ss.dtofir = sc.dtofir;

                else
                    ss.dtofir = dtofir;

                endif;  % isnan(dtofir)

                if(isnan(dtofsc))
                    ss.dtofsc = scref.dtofsc;

                else
                    ss.dtofsc = dtofsc;

                endif;  % isnan(dtofsc)

            endif;  % ~(0 == nargin) && ~(1 == nargin)

        endfunction;  % Scanset(varargin)


        function disp(ss)
% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- ss.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
            printf('\tScanset(\n');

            % We use three output formats for the printing of the 'Scanset'
            % structure depending on whether the Scanset is valid, irradiation
            % date (dtofir) is set, or not. If the irradiation date is set we
            % need more space for the fields, so we need to ident field values
            % more
            if(~ss.isvalid())
                printf('\t\tTitle:               "Invalid",\n');
                printf('\t\tType:                Invalid,\n');
                printf('\t\tDate of scan:        Invalid,\n');
                printf('\t\tDate of irradiation: Invalid,\n');
                printf('\t\tPixel data:          Invalid,\n');
                printf('\t\tScan:                Invalid,\n');

            else
                printf('\t\tTitle:               "%s",\n', ss.sstitle);
                printf('\t\tType:                %s,\n', ss.sstype);
                printf( ...
                    '\t\tDate of scan:        %s,\n', ...
                    datestr(ss.dtofsc, 'dd-mmm-yyyy') ...
                    );
                if(~isnan(ss.dtofir))
                    printf( ...
                        '\t\tDate of irradiation: %s,\n', ...
                        datestr(ss.dtofir, 'dd-mmm-yyyy') ...
                        );

                else
                    printf('\t\tDate of irradiation: N/A\n');

                endif;

                printf('\t\tPixel data:          ');
                if(isempty(ss.pd))
                    printf('[],\n');

                else
                    printf('[%dx%dx%d],\n', size(ss.pd));

                endif;

                % Format files output
                idx = 1;
                while(numel(ss.files) >= idx)
                    [d, n, e] = fileparts(ss.files{idx});
                    if(numel(ss.files) == idx)
                        % Last entry. Omit the comma at the end
                        printf('\t\tScan #%d:             %s%s\n', idx, n, e);

                    else
                        % Not the last entry. Putt the comma at the end
                        printf('\t\tScan #%d:             %s%s,\n', idx, n, e);

                    endif;

                    ++idx;

                endwhile;

            endif;

            printf('\t)\n');

        endfunction;  % disp()


        function result = str_rep(ss)
% -----------------------------------------------------------------------------
%
% Method 'str_rep':
%
% Use:
%       -- result = ss.str_rep()
%
% Description:
%          A convenience method that is used to format string representation of
%          the Scanset instance.
%
% -----------------------------------------------------------------------------
            if(~ss.isvalid())
                result = sprintf( ...
                        'Scanset("Invalid", Invalid, Invalid, Invalid)' ...
                    );

            elseif(isnan(ss.dtofir))
                result = sprintf( ...
                    'Scanset("%s", %s, %s, N/A, %d scan(s))', ...
                    ss.sstitle, ...
                    ss.sstype, ...
                    datestr(ss.dtofsc, 'dd-mmm-yyyy'), ...
                    numel(ss.files) ...
                    );

            else
                result = sprintf( ...
                    'Scanset("%s", %s, %s, %s, %d scan(s))', ...
                    ss.sstitle, ...
                    ss.sstype, ...
                    datestr(ss.dtofsc, 'dd-mmm-yyyy'), ...
                    datestr(ss.dtofir, 'dd-mmm-yyyy'), ...
                    numel(ss.files) ...
                    );


            endif;  % isnan(ss.dtofir)

        endfunction;  % str_rep()


        function css = ascell(ss)
% -----------------------------------------------------------------------------
%
% Method 'ascell':
%
% Use:
%       -- css = ss.ascell()
%
% Description:
%          Return Scanset object as cell array.
%
% -----------------------------------------------------------------------------
            css = {};

            if(~ss.isvalid())
                css = {'Invalid', 'Invalid', 'Invalid', 'Invalid', 'Invalid'};

            else
                css{end + 1} = ss.sstitle;
                css{end + 1} = ss.sstype;
                css{end + 1} = datestr(ss.dtofsc, 'dd-mmm-yyyy');

                if(~isnan(ss.dtofir))
                    css{end + 1} = datestr(ss.dtofir, 'dd-mmm-yyyy');

                else
                    css{end + 1} = 'N/A';

                endif;

                idx = 1;
                while(numel(ss.files) >= idx)
                    [d, n, e] = fileparts(ss.files{idx});
                    css{end + 1} = sprintf('%s%s', n, e);

                    ++idx;

                endwhile;

            endif;

        endfunction;  % ascell()


        function result = isequivalent(ss, other)
% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = ss.isequivalent(other)
%
% Description:
%          Return whether or not two Scanset instances are equivalent. Two
%          instances are equivalent if they have same resolution, and linear
%          dimensions of their pixel data do not differ more than 2 pixels for
%          each linear dimension.
%
% -----------------------------------------------------------------------------
            fname = 'isequivalent';

            if(~isa(other, 'Scanset'))
                error( ...
                    '%s: other must be an instance of the "Scanset" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;

            % If either of object is invalid we return false
            if(ss.isvalid() && other.isvalid())
                % Check for equivalency
                if( ...
                        size(ss.pwmean, 3) == size(other.pwmean, 3) ...
                        && 10 >= abs( ...
                            size(ss.pwmean, 2) - size(other.pwmean, 2) ...
                            ) ...
                        && 10 >= abs( ...
                            size(ss.pwmean, 1) - size(other.pwmean, 1) ...
                            ) ...
                        && isequal(ss.rslu, other.rslu) ...
                        && isequal(ss.rsl, other.rsl) ...
                        );
                    result = true;

                endif;

            endif;  % ss.isvalid() && other.isvalid()

            % Rise a warning if sizes differ within acceptable limits
            delta = size(ss.pwmean, 1) - size(other.pwmean, 1);
            if(0 ~= delta)
                warning( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: Number of rows of the scan sets "%s" and', ...
                            ' "%s" differ for %d pixels' ...
                            ), ...
                        fname, ...
                        ss.sstitle, ...
                        other.sstitle, ...
                        delta ...
                        ) ...
                    );

            endif;  % 0 ~= delta

            delta = size(ss.pwmean, 2) - size(other.pwmean, 2);
            if(0 ~= delta)
                warning( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: Number of columns of the scan sets "%s" and', ...
                            ' "%s" differ for %d pixels' ...
                            ), ...
                        fname, ...
                        ss.sstitle, ...
                        other.sstitle, ...
                        delta ...
                        ) ...
                    );

            endif;  % 0 ~= delta

        endfunction;  % isequivalent()


        function result = isequal(ss, other)
% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = ss.isequal(other)
%
% Description:
%          Return whether or not two 'Scanset' instances are equal. Two
%          instances are equal if all of their fields have identical values.
%
% -----------------------------------------------------------------------------
            fname = 'isequal';

            if(~isa(other, 'Scanset'))
                error( ...
                    '%s: other must be an instance of the "Scanset" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;

            % If either of object is invalid we return false
            if(ss.isvalid() && other.isvalid())
                % Check for equality
                if( ...
                        isequal(ss.sstitle, other.sstitle) ...
                        && isequal(ss.files, other.files) ...
                        && isequal(ss.dtofir, other.dtofir) ...
                        && isequal(ss.dtofsc, other.dtofsc) ...
                        && isequal(ss.sstype, other.sstype) ...
                        && isequal(ss.pd, other.pd) ...
                        && isequal(ss.rslu, other.rslu) ...
                        && isequal(ss.rsl, other.rsl) ...
                        && isequal(ss.ws, other.ws) ...
                        )
                    result = true;

                endif;

            endif;  % ss.isvalid() && other.isvalid()

        endfunction;  % isequal()


        function result = data_size(ss)
% -----------------------------------------------------------------------------
%
% Method 'data_size':
%
% Use:
%       -- result = ss.data_size()
%
% Description:
%          Return size of the pixel data matrix.
%
% -----------------------------------------------------------------------------
            if(ss.isvalid())
                result = size(ss.pd);

            else
                result = [0, 0, 0];

            endif;

        endfunction;


        function result = isvalid(ss)
% -----------------------------------------------------------------------------
%
% Method 'isvalid':
%
% Use:
%       -- result = ss.isvalid()
%
% Description:
%          Return if scan set is valid or not. The scan set is valid if during
%          object initialization no waning was generated (i.e. ss.ws = {}).
%
% -----------------------------------------------------------------------------
            result = isempty(ss.ws);

        endfunction;


        function pd = pixel_data(ss, pds=PixelDataSmoothing())
% -----------------------------------------------------------------------------
%
% Method 'pixel_data':
%
% Use:
%       -- pd = ss.pixel_data()
%       -- pd = ss.pixel_data(pds)
%
% Description:
%          Return copy of the scan set pixel data. If pixel data smoothing is
%          defined, return smoothed data.
%
% -----------------------------------------------------------------------------
            fname = 'pixel_data';

            if(~isa(pds, 'PixelDataSmoothing'))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: other must be an instance of the ', ...
                            '"PixelDataSmoothing" class' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;  % ~isa(pds, 'PixelDataSmoothing')

            if(ss.isvalid())
                pd = pds.smooth(ss.pd);

            else
                pd = ss.pd;

            endif;  % ss.isvalid()

        endfunction;  % pixel_data()


        function IP = inprofile(ss, pds=PixelDataSmoothing(), rsp=0, x=0)
% -----------------------------------------------------------------------------
%
% Method 'inprofile':
%
% Use:
%       -- IP = ss.inprofile()
%       -- IP = ss.inprofile(pds)
%       -- IP = ss.inprofile(pds, rsp)
%       -- IP = ss.inprofile(pds, rsp, x)
%
% Description:
%          Return in profile data for the given scanset and the given column
%          index. If default value is used for the column index it extracts data
%          for the calculated column at the middle of the columns range.
%
%          For additional data smoothing one may pass a PixelDataSmoothing
%          instance to the method call.
%
%          If instance is not valid it returns an empty array;
%
% -----------------------------------------------------------------------------
            fname = 'inprofile';

            if(~isa(pds, 'PixelDataSmoothing'))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: pds must be an instance of the ', ...
                            '"PixelDataSmoothing" class' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;  % ~isa(pds, 'PixelDataSmoothing')

            validateattributes( ...
                rsp, ...
                {'numeric'}, ...
                { ...
                    'nonempty', ...
                    'scalar', ...
                    'integer', ...
                    'finite', ...
                    '>=', 0 ...
                    }, ...
                fname, ...
                'rsp' ...
                );

            validateattributes( ...
                x, ...
                {'numeric'}, ...
                { ...
                    'nonempty', ...
                    'scalar', ...
                    'integer', ...
                    'finite', ...
                    '>=', 0 ...
                    }, ...
                fname, ...
                'x' ...
                );

            IP = [];

            if(ss.isvalid())
                % Check if resample points has viable value
                if(0 ~= rsp)
                    if(ss.data_size()(1) > rsp)
                        error( ...
                            '%s: rsp must have a value >= number of rows', ...
                            fname ...
                            );

                    endif;  % ss.data_size()(1) > rsp

                else
                    rsp = ss.data_size()(1);

                endif;  % 0 ~= rsp

                % Check if column index set to default value
                if(0 == x)
                    % Column index set to default value. Calculate the position
                    % of the middle of the column range
                    x = ceil(ss.data_size()(2) / 2);

                endif;

                % Validate if given column index is within viable index range
                if(ss.data_size()(2) < x)
                    error( ...
                        '%s: x out of bound (expected value <= %d, got %d', ...
                        fname, ...
                        ss.data_size()(2), ...
                        x ...
                        );

                endif;  % ss.data_size()(2) < x

                IP = squeeze(ss.pixel_data(pds)(:, x, :));
                k = size(IP, 1) - numel(0:1/size(IP, 1):1);
                IP = interp1( ...
                    0:1/size(IP, 1):(1 + k/size(IP, 1)), ...
                    IP, ...
                    0:1/rsp:(1 + k/rsp) ...
                    );

                if(1 == size(IP, 1))
                    IP = IP';

                endif;

            endif;  % ss.isvalid()

        endfunction;  % inprofile()


        function CP = crossprofile(ss, pds=PixelDataSmoothing(), rsp=0, y=0)
% -----------------------------------------------------------------------------
%
% Method 'crossprofile':
%
% Use:
%       -- CP = ss.crossprofile()
%       -- CP = ss.crossprofile(pds)
%       -- CP = ss.crossprofile(pds, rsp)
%       -- CP = ss.crossprofile(pds, rsp, y)
%
% Description:
%          Return cross profile data for the given scanset and the given row
%          index. If default value is used for the row index it extracts data
%          for the calculated column at the middle of the rows range.
%
%          For additional data smoothing one may pass a PixelDataSmoothing
%          instance to the method call.
%
%          If instance is not valid it returns an empty array;
%
% -----------------------------------------------------------------------------
            fname = 'crossprofile';

            if(~isa(pds, 'PixelDataSmoothing'))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: pds must be an instance of the ', ...
                            '"PixelDataSmoothing" class' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;  % ~isa(pds, 'PixelDataSmoothing')

            validateattributes( ...
                rsp, ...
                {'numeric'}, ...
                { ...
                    'nonempty', ...
                    'scalar', ...
                    'integer', ...
                    'finite', ...
                    '>=', 0 ...
                    }, ...
                fname, ...
                'rsp' ...
                );

            validateattributes( ...
                y, ...
                {'numeric'}, ...
                { ...
                    'nonempty', ...
                    'scalar', ...
                    'integer', ...
                    'finite', ...
                    '>=', 0 ...
                    }, ...
                fname, ...
                'y' ...
                );

            CP = [];

            if(ss.isvalid())
                % Check if resample points has viable value
                if(0 ~= rsp)
                    if(ss.data_size()(2) > rsp)
                        error( ...
                            '%s: rsp must have a value >= number of rows', ...
                            fname ...
                            );

                    endif;  % ss.data_size()(1) > rsp

                else
                    rsp = ss.data_size()(2);

                endif;  % 0 ~= rsp


                % Check if row index set to default value
                if(0 == y)
                    % Row index set to default value. Calculate the position
                    % of the middle of the row range
                    y = ceil(ss.data_size()(1) / 2);

                endif;

                % Validate if given row index is within viable index range
                if(ss.data_size()(1) < y)
                    error( ...
                        '%s: y out of bound (expected value <= %d, got %d', ...
                        fname, ...
                        ss.data_size()(1), ...
                        y ...
                        );

                endif;  % ss.data_size()(1) < x

                CP = squeeze(ss.pixel_data(pds)(y, :, :));
                k = size(CP, 1) - numel(0:1/size(CP, 1):1);
                CP = interp1( ...
                    0:1/size(CP, 1):(1 + k/size(CP, 1)), ...
                    CP, ...
                    0:1/rsp:(1 + k/rsp) ...
                    );

                if(1 == size(CP, 1))
                    CP = CP';

                endif;

            endif;  % ss.isvalid()

        endfunction;  % crossprofile(y, pds)


        function inplot(ss, pds=PixelDataSmoothing(), x=0)
% -----------------------------------------------------------------------------
%
% Method 'inplot':
%
% Use:
%       -- ss.inplot()
%       -- ss.inplot(pds)
%       -- ss.inplot(pds, x)
%
% Description:
%          Plot in profile data for the given scanset and the given column
%          index. If default value is used for the column index it extracts data
%          for the calculated column at the middle of the columns range.
%
%          For additional data smoothing one may pass a PixelDataSmoothing
%          instance to the method call.
%
%          If instance is not valid it ignores a function call.
%
% -----------------------------------------------------------------------------
            fname = 'inplot';

            if(~isa(pds, 'PixelDataSmoothing'))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: pds must be an instance of the ', ...
                            '"PixelDataSmoothing" class' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;  % ~isa(pds, 'PixelDataSmoothing')

            validateattributes( ...
                x, ...
                {'numeric'}, ...
                { ...
                    'nonempty', ...
                    'scalar', ...
                    'integer', ...
                    'finite', ...
                    '>=', 0 ...
                    }, ...
                fname, ...
                'x' ...
                );

            if(ss.isvalid())

                % Check if column index set to default value
                if(0 == x)
                    % Column index set to default value. Calculate the position
                    % of the middle of the column range
                    x = ceil(ss.data_size()(2) / 2);

                endif;

                % Validate if given column index is within viable index range
                if(ss.data_size()(2) < x)
                    error( ...
                        '%s: x out of bound (expected value <= %d, got %d', ...
                        fname, ...
                        ss.data_size()(2), ...
                        x ...
                        );

                endif;  % ss.data_size()(2) < x

                IP = squeeze(ss.pixel_data(pds)(:, x, :));
                xscale = 1:1:size(IP, 1);

                switch(ss.rslu)
                    case 'dpi'
                        xscale = (xscale.*25.4)./ss.rsl(2);

                    case 'dpcm'
                        xscale = (xscale.*10.0)./ss.rsl(2);

                endswitch;

                hfig  = figure();
                haxes = axes( ...
                    'parent', hfig, ...
                    'xlim', [xscale(1) xscale(end)], ...
                    'ylim', [0 65535] ...
                    );
                hold(haxes, 'on');
                if(1 < size(IP, 2))
                    plot(xscale, IP(:, 1), 'color', 'r');
                    plot(xscale, IP(:, 2), 'color', 'g');
                    plot(xscale, IP(:, 3), 'color', 'b');

                else
                    plot(xscale, IP, 'color', 'k');

                endif;  % 1 < size(IP, 2)
                hold(haxes, 'off');
                xlabel('Y [mm]');
                ylabel('pixel intensity');
                if(1 < size(IP, 2))
                    legend( ...
                        haxes, ...
                        { ...
                            'red channel', ...
                            'green channel', ...
                            'blue channel' ...
                            }, ...
                        'Location', 'northeast' ...
                        );

                else
                    legend( ...
                        haxes, ...
                        { ...
                            'gray channel' ...
                            }, ...
                        'Location', 'northeast' ...
                        );

                endif;  % 1 < size(IP, 2)
                title( ...
                    haxes, ...
                    cstrcat( ...
                        datestr(ss.dtofsc, 'dd-mmm-yyyy'), ...
                        ' - ', ...
                        ss.sstitle ...
                        ) ...
                    );

            endif;  % ss.isvalid()

        endfunction;  % inplot(x, pds)


        function crossplot(ss, pds=PixelDataSmoothing(), y=0)
% -----------------------------------------------------------------------------
%
% Method 'crossplot':
%
% Use:
%       -- ss.crossplot()
%       -- ss.crossplot(pds)
%       -- ss.crossplot(pds, y)
%
% Description:
%          Plot cross profile data for the given scanset and the given row
%          index. If default value is used for the row index it extracts data
%          for the calculated row at the middle of the rows range.
%
%          For additional data smoothing one may pass a PixelDataSmoothing
%          instance to the method call.
%
%          If instance is not valid it ignores a function call.
%
% -----------------------------------------------------------------------------
            fname = 'inplot';

            if(~isa(pds, 'PixelDataSmoothing'))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: pds must be an instance of the ', ...
                            '"PixelDataSmoothing" class' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;  % ~isa(pds, 'PixelDataSmoothing')

            validateattributes( ...
                y, ...
                {'numeric'}, ...
                { ...
                    'nonempty', ...
                    'scalar', ...
                    'integer', ...
                    'finite', ...
                    '>=', 0 ...
                    }, ...
                fname, ...
                'y' ...
                );

            if(ss.isvalid())

                % Check if row index set to default value
                if(0 == y)
                    % Row index set to default value. Calculate the position
                    % of the middle of the row range
                    y = ceil(ss.data_size()(1) / 2);

                endif;

                % Validate if given row index is within viable index range
                if(ss.data_size()(1) < y)
                    error( ...
                        '%s: y out of bound (expected value <= %d, got %d', ...
                        fname, ...
                        ss.data_size()(1), ...
                        y ...
                        );

                endif;  % ss.data_size()(1) < x

                CP = squeeze(ss.pixel_data(pds)(y, :, :));
                xscale = 1:1:size(CP, 1);

                switch(ss.rslu)
                    case 'dpi'
                        xscale = (xscale.*25.4)./ss.rsl(1);

                    case 'dpcm'
                        xscale = (xscale.*10.0)./ss.rsl(1);

                endswitch;

                hfig  = figure();
                haxes = axes( ...
                    'parent', hfig, ...
                    'xlim', [xscale(1) xscale(end)], ...
                    'ylim', [0 65535] ...
                    );
                hold(haxes, 'on');
                if(1 < size(CP, 2))
                    plot(xscale, CP(:, 1), 'color', 'r');
                    plot(xscale, CP(:, 2), 'color', 'g');
                    plot(xscale, CP(:, 3), 'color', 'b');

                else
                    plot(xscale, CP, 'color', 'k');

                endif;  % 1 < size(IP, 2)
                hold(haxes, 'off');
                xlabel('X [mm]');
                ylabel('pixel intensity');
                if(1 < size(CP, 2))
                    legend( ...
                        haxes, ...
                        { ...
                            'red channel', ...
                            'green channel', ...
                            'blue channel' ...
                            }, ...
                        'Location', 'northeast' ...
                        );

                else
                    legend( ...
                        haxes, ...
                        { ...
                            'gray channel' ...
                            }, ...
                        'Location', 'northeast' ...
                        );

                endif;  % 1 < size(IP, 2)
                title( ...
                    haxes, ...
                    cstrcat( ...
                        datestr(ss.dtofsc, 'dd-mmm-yyyy'), ...
                        ' - ', ...
                        ss.sstitle ...
                        ) ...
                    );

            endif;  % ss.isvalid()

        endfunction;  % crossplot(y, pds)


        function imshow(ss, pds=PixelDataSmoothing(), heq='off')
% -----------------------------------------------------------------------------
%
% Method 'imshow':
%
% Use:
%       -- ss.imshow()
%       -- ss.imshow(pds)
%       -- ss.imshow(pds, heq)
%
% Description:
%          Plot scan set pixel data as image.
%
%          heq: string, def. 'off'
%              If set to 'on' perform histogram equivalization of each image
%              channel.
%
% -----------------------------------------------------------------------------
            fname = 'imshow';

            if(~isa(pds, 'PixelDataSmoothing'))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: pds must be an instance of the ', ...
                            '"PixelDataSmoothing" class' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;  % ~isa(pds, 'PixelDataSmoothing')

            validatestring( ...
                heq, ...
                { ...
                    'on', ...
                    'off' ...
                    }, ...
                fname, ...
                'heq' ...
                );

            if(ss.isvalid())
                PD = uint16(ss.pixel_data(pds));

                xscale = 1:1:size(PD, 2);
                yscale = 1:1:size(PD, 1);
                cc = size(PD, 3);

                if(isequal('on', heq))
                    idx = 1;
                    while(cc >= idx)
                        PD(:, :, idx) = histeq(PD(:, :, idx));

                        ++idx;

                    endwhile;

                endif;

                switch(ss.rslu)
                    case 'dpi'
                        xscale = (xscale.*25.4)./ss.rsl(1);
                        yscale = (yscale.*25.4)./ss.rsl(2);

                    case 'dpcm'
                        xscale = (xscale.*10.0)./ss.rsl(1);
                        yscale = (yscale.*10.0)./ss.rsl(2);

                endswitch;

                hfig  = figure();
                haxes = axes( ...
                    'parent', hfig, ...
                    'xlim', [xscale(1) xscale(end)], ...
                    'ylim', [yscale(1) yscale(end)] ...
                    );
                imshow(PD);
                xlabel('X [mm]');
                ylabel('Y [mm]');
                title( ...
                    haxes, ...
                    cstrcat( ...
                        datestr(ss.dtofsc, 'dd-mmm-yyyy'), ...
                        ' - ', ...
                        ss.sstitle ...
                        ) ...
                    );

            endif;  % ss.isvalid()

        endfunction;  % imshow(varargin)

    endmethods;  % Public methods

endclassdef;  % Scanset
