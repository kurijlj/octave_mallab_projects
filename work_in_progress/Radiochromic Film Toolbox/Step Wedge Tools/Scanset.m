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
%       Scanset object can be checked calling 'is_valid' method.
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
%       - Scanset(varargin):
%
%       - disp():
%
%       - str_rep():
%
%       - ascell():
%
%       - isequivalent(other):
%
%       - isequal(other):
%
%       - size():
%
%       - is_valid():
%
%       - pixel_data(pds):
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
                    ss.dtofir = varargin{1}.dtofir;
                    ss.dtofsc = varargin{1}.dtofsc;
                    ss.sstype  = varargin{1}.sstype;
                    ss.pd      = varargin{1}.pd;
                    ss.pdsd    = varargin{1}.pdsd;
                    ss.ws      = varargin{1}.ws;

                    return;

                % Check if constructor called with a path to a file or with a
                % pixel data matrix object
                elseif(ischar(varargin{1}) || isnumeric(varargin{1}))
                    scref = Scan(varargin{1});

                else
                    scref = varargin{1};

                endif;  % isa(varargin{1}, 'Scanset')

                if(~scref.is_valid())
                    % Add warning message to the warnings stack
                    ss.ws{end + 1} = scref.ws;

                    % Stop further constructor execution
                    return;

                endif;  % scref.is_valid()

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

                        if(~scref.is_valid())
                            % Add the waring to the warnings stack
                            ss.ws{end + 1} = scref.ws{:};

                            return;

                        endif;  % ~scref.is_valid()

                    endif;

                    % Initialize Scan instance if needed
                    sc = NaN;
                    if(isa(pos{idx}, 'Scan'))
                        sc = pos{idx};

                    else
                        sc = Scan(pos{idx}, 'Title', sprintf('Scan #%d', idx));

                    endif;

                    if(~sc.is_valid())
                        % Add the waring to the warnings stack
                        ss.ws{end + 1} = sc.ws{:};

                        % Invalidate pixel data and stop further constructor
                        % execution
                        ss.files = {};
                        ss.pd    = [];

                        return;

                    endif;  % ~sc.is_valid()

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

                endwhile;

                % Determine scanset attributes --------------------------------
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
                    ss.sstitle = ss.sctype;

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
            if(~ss.is_valid())
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
            if(~ss.is_valid())
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

            if(~ss.is_valid())
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
%          instances are equivalent if their pixel data are of the same size.
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
            if(ss.is_valid() && other.is_valid())
                % Check for equivalency
                if(size(ss.pwmean) == size(other.pwmean));
                    result = true;

                endif;

            endif;

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
            if(ss.is_valid() && other.is_valid())
                % Check for equality
                if( ...
                        isequal(ss.sstitle, other.sstitle) ...
                        && isequal(ss.files, other.files) ...
                        && isequal(ss.dtofir, other.dtofir) ...
                        && isequal(ss.dtofsc, other.dtofsc) ...
                        && isequal(ss.sstype, other.sstype) ...
                        && isequal(ss.pd, other.pd) ...
                        && isequal(ss.ws, other.ws) ...
                        )
                    result = true;

                endif;

            endif;  % ss.is_valid() && other.is_valid()

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
            if(ss.is_valid())
                result = size(ss.pd);

            else
                result = [0, 0, 0];

            endif;

        endfunction;


        function result = is_valid(ss)
% -----------------------------------------------------------------------------
%
% Method 'is_valid':
%
% Use:
%       -- result = ss.is_valid()
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

            endif;

            if(ss.is_valid())
                pd = pds.smooth(ss.pd);

            else
                pd = ss.pd;

            endif;  % ss.is_valid()

        endfunction;  % pixel_data(pds)

    endmethods;  % Public methods

endclassdef;  % Scanset
