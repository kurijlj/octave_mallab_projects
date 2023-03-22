classdef OpticalDensity
%% -----------------------------------------------------------------------------
%%
%% Class 'OpticalDensity':
%%
%% -----------------------------------------------------------------------------
%
%% Description:
%       Net optical density of data scans (film scans)
%
%       Invoke class constructor with:
%
%
%% Public methods:
%
%       - OpticalDensity(varargin): Class constructor.
%
%       - disp(): The disp method is used by Octave whenever a class instance
%         should be displayed on the screen.
%
%       - str_rep(): A convenience method that is used to format string
%         representation of the OpticalDensity instance.
%
%       - ascell(): Return optical density object structure as cell array.
%
%       - data_size(): Return size of the pixel data matrix.
%
%       - pixel_data(pds): Return copy of the optical density pixel data. If
%         pixel data smoothing is defined, return smoothed data.
%
%       - inprofile(pds, rsp, x): Return in profile data for the given optical
%         density instance and the given column index.
%
%       - crossprofile(pds, rsp, y): Return cross profile data for the given
%         optical density instance and the given row index.
%
%       - inplot(pds, x): Plot in profile data for the given optical density
%         instance and the given column index.
%
%       - crossplot(pds, y): Plot cross profile data for the given optical
%         density and the given row index.
%
%       - imshow(pds, rsp): Plot optical density pixel data as image.
%
% -----------------------------------------------------------------------------

    properties (SetAccess = private, GetAccess = public)
%% -----------------------------------------------------------------------------
%%
%% Properties section
%%
%% -----------------------------------------------------------------------------
        % Instance title title (unique ID)
        odtitle = 'Optical Density';
        % Date of irradiation (if applicable)
        dtofir  = NaN;
        % Date of scanning (mandatory)
        dtofsc  = NaN;
        % Pixel data
        pd      = [];
        % Underlying pixel data resolution (if applicable)
        rsl     = [];
        % Resolution units (if applicable)
        rslu    = 'None';

    endproperties;


    methods (Access = public)
%% -----------------------------------------------------------------------------
%%
%% Public methods section
%%
%% -----------------------------------------------------------------------------

        function od = OpticalDensity(varargin)
% -----------------------------------------------------------------------------
%
% Method 'OpticalDensity':
%
% Use:
%       -- od = OpticalDensity(sssig, ssbkg)
%       -- od = OpticalDensity(sssig, ssbkg, sszrl)
%       -- od = OpticalDensity(..., "PROPERTY", VALUE, ...)
%       -- od = OpticalDensity(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
            fname = 'OpticalDensity';
            use_case_a = ' -- od = Scanset(sssig, ssbkg)';
            use_case_b = ' -- od = Scanset(sssig, ssbkg, sszrl)';
            use_case_c = ' -- od = Scanset(..., "PROPERTY", VALUE, ...)';
            use_case_d = ' -- od = Scanset(other)';

            if(0 == nargin)
                % We don't support default constructor ------------------------
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

                % End of case 0 == nargin
            elseif(1 == nargin)
                % Check if copy constructor invoked ---------------------------
                if(isa(varargin{1}, 'OpticalDensity'))
                    % Copy constructor invoked. Copy parameter values of the
                    % given optical density instance to the new one
                    od.odtitle = varargin{1}.odtitle;
                    od.dtofir  = varargin{1}.dtofir;
                    od.dtofsc  = varargin{1}.dtofsc;
                    od.pd      = varargin{1}.pd;
                    od.rsl     = varargin{1}.rsl;
                    od.rslu    = varargin{1}.rslu;

                    return;

                else
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

                endif;  % isa(varargin{1}, 'OpticalDensity')

                % End of case 1 == nargin
            else
                % Regular constructor invoked ---------------------------------

                % Parse constructor call arguments
                [ ...
                    pos, ...
                    odtitle, ...
                    pds ...
                    ] = parseparams( ...
                    varargin, ...
                    'Title', 'Net Optical Density', ...
                    'Smoothing', PixelDataSmoothing() ...
                    );

                if(2 > numel(pos) || 3 < numel(pos))
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

                endif;  % 2 > numel(pos) || 3 < numel(pos)

                % Validate argument supplied for the signal scanset -----------
                if(~isa(pos{1}, 'Scanset'))
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

                endif;  % ~isa(pos{1}, 'Scanset')

                % Check if scanset is of the correct type
                if(~isequal('Signal', pos{1}.sstype))
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                '%s: varargin{1}: Wrong scanset type', ...
                                ' (expected "Signal", got "%s")' ...
                                ), ...
                            fname, ...
                            pos{1}.sstype ...
                            ) ...
                        );

                endif;  % ~isequal('Signal', pos{1}.sstype)

                % Validate argument supplied for the background scanset -------
                if(~isa(pos{2}, 'Scanset'))
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

                endif;  % ~isa(pos{2}, 'Scanset')

                % Check if scanset is of the correct type
                if(~isequal('Background', pos{2}.sstype))
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                '%s: varargin{2}: Wrong scanset type', ...
                                ' (expected "Background", got "%s")' ...
                                ), ...
                            fname, ...
                            pos{2}.sstype ...
                            ) ...
                        );

                endif;  % ~isequal('Signal', pos{2}.sstype)

                % Check if background scanset is equivalent to the signal (we
                % use signal scanset as a reference)
                if(~pos{1}.isequivalent(pos{2}))
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                '%s: Background scanset not eqivalent to', ...
                                ' the Signal scanset' ...
                                ), ...
                            fname ...
                            ) ...
                        );
                endif;  % ~pos{1}.isequivalent(pos{2})

                % Validate argument supplied for the zero-light scanset -------

                % Check if zero-light scanset supplied at all
                if(3 == numel(pos))
                    % It seems that user supplied a zero-light scanset. Do the
                    % validation
                    if(~isa(pos{3}, 'Scanset'))
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

                    endif;  % ~isa(pos{3}, 'Scanset')

                    % Check if scanset is of the correct type
                    if(~isequal('ZeroLight', pos{3}.sstype))
                        error( ...
                            sprintf( ...
                                cstrcat( ...
                                    '%s: varargin{3}: Wrong scanset type', ...
                                    ' (expected "ZeroLight", got "%s")' ...
                                    ), ...
                                fname, ...
                                pos{3}.sstype ...
                                ) ...
                            );

                    endif;  % ~isequal('Signal', pos{2}.sstype)

                    % Check if zero-light scanset is equivalent to the signal
                    if(~pos{1}.isequivalent(pos{3}))
                        error( ...
                            sprintf( ...
                                cstrcat( ...
                                    '%s: ZeroLight scanset not eqivalent', ...
                                    ' to the Signal scanset' ...
                                    ), ...
                                fname ...
                                ) ...
                            );
                    endif;  % ~pos{1}.isequivalent(pos{3})

                endif;  % 3 == numel(pos)

                % Validate value supplied for the Title -----------------------
                if(~ischar(odtitle) || isempty(odtitle))
                    error('%s: Title must be a non-empty string', fname);

                endif;  % ~ischar(odtitle) || isempty(odtitle)

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

            endif;  % End of case 0 ~= nargin && 1 ~= nargin

            % Use signal scanset values for the date of scan, date of
            % irradiation and resolution
            od.dtofsc = pos{1}.dtofsc;
            od.dtofir = pos{1}.dtofir;
            od.rsl    = pos{1}.rsl;
            od.rslu   = pos{1}.rslu;

            % Calculate optical density image. We trim edge pixels to avoid
            % resulting complex values
            if(3 == numel(pos))
                % Compute maximal dimensions of the resulting
                % optical density image
                L = min( ...
                    [ ...
                        pos{1}.data_size()(1), ...
                        pos{2}.data_size()(1), ...
                        pos{3}.data_size()(1) ...
                        ] ...
                    );
                W = min( ...
                    [ ...
                        pos{1}.data_size()(2), ...
                        pos{2}.data_size()(2), ...
                        pos{3}.data_size()(2) ...
                        ] ...
                    );

                od.pd = log10( ...
                        ( ...
                            pos{2}.pixel_data(pds)(2:L-1, 2:W-1, :) ...
                            - pos{3}.pixel_data(pds)(2:L-1, 2:W-1, :) ...
                        ) ...
                        ./ ( ...
                            pos{1}.pixel_data(pds)(2:L-1, 2:W-1, :) ...
                            - pos{3}.pixel_data(pds)(2:L-1, 2:W-1, :) ...
                        ) ...
                    );

            else
                L = min( ...
                    [ ...
                        pos{1}.data_size()(1), ...
                        pos{2}.data_size()(1) ...
                        ] ...
                    );
                W = min( ...
                    [ ...
                        pos{1}.data_size()(2), ...
                        pos{2}.data_size()(2) ...
                        ] ...
                    );

                od.pd = log10( ...
                        pos{2}.pixel_data(pds)(2:L-1, 2:W-1, :) ...
                        ./ pos{1}.pixel_data(pds)(2:L-1, 2:W-1, :) ...
                    );

            endif;  % 3 == numel(pos)

        endfunction;  % OpticalDensity()


        function disp(od)
% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- od.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
            printf('\tScanset(\n');
            printf('\t\tTitle:               "%s",\n', od.odtitle);
            printf( ...
                '\t\tDate of scan:        %s,\n', ...
                datestr(od.dtofsc, 'dd-mmm-yyyy') ...
                );
            if(~isnan(od.dtofir))
                printf( ...
                    '\t\tDate of irradiation: %s,\n', ...
                    datestr(od.dtofir, 'dd-mmm-yyyy') ...
                    );

            else
                printf('\t\tDate of irradiation: N/A\n');

            endif;
            printf('\t\tOptical density data:          ');
            printf('[%dx%dx%d],\n', size(od.pd));
            printf( ...
                '\t\tResolution:                    [%d %s, %d %s\n', ...
                od.rsl(1), od.rslu, ...
                od.rsl(2), od.rslu ...
                );
            printf('\t)\n');

        endfunction;  % disp()


        function result = str_rep(od)
% -----------------------------------------------------------------------------
%
% Method 'str_rep':
%
% Use:
%       -- result = od.str_rep()
%
% Description:
%          A convenience method that is used to format string representation of
%          the OpticalDensity instance.
%
% -----------------------------------------------------------------------------
            if(isnan(od.dtofir))
                if(isequal('None', od.rslu))
                    result = sprintf( ...
                        'OpticalDensity("%s", %s, [%dx%dx%d])', ...
                        od.odtitle, ...
                        datestr(od.dtofsc, 'dd-mmm-yyyy'), ...
                        size(od.pd) ...
                        );

                else
                    result = sprintf( ...
                        'OpticalDensity("%s", %s, [%dx%dx%d], [%d %d], %s)', ...
                        od.odtitle, ...
                        datestr(od.dtofsc, 'dd-mmm-yyyy'), ...
                        size(od.pd), ...
                        od.rsl, od.rslu ...
                        );

                endif;  % isequal('None', od.rslu)

            else
                if(isequal('None', od.rslu))
                    result = sprintf( ...
                        'OpticalDensity("%s", %s, %s, [%dx%dx%d])', ...
                        od.odtitle, ...
                        datestr(od.dtofsc, 'dd-mmm-yyyy'), ...
                        datestr(od.dtofir, 'dd-mmm-yyyy') ...
                        );

                else
                    result = sprintf( ...
                        cstrcat( ...
                            'OpticalDensity("%s", %s, %s, [%dx%dx%d], ', ...
                            '[%d %d], %s)' ...
                            ), ...
                        od.odtitle, ...
                        datestr(od.dtofsc, 'dd-mmm-yyyy'), ...
                        datestr(od.dtofir, 'dd-mmm-yyyy'), ...
                        size(od.pd), ...
                        od.rsl, od.rslu ...
                        );

                endif;  % isequal('None', od.rslu)

            endif;  % isnan(ss.dtofir)

        endfunction;  % str_rep()


        function cod = ascell(od)
% -----------------------------------------------------------------------------
%
% Method 'ascell':
%
% Use:
%       -- cod = od.ascell()
%
% Description:
%          Return Scanset object as cell array.
%
% -----------------------------------------------------------------------------
            cod = {};

            cod{end + 1} = od.odtitle;
            cod{end + 1} = datestr(ss.dtofsc, 'dd-mmm-yyyy');
            if(~isnan(od.dtofir))
                cod{end + 1} = datestr(od.dtofir, 'dd-mmm-yyyy');

            else
                cod{end + 1} = 'N/A';

            endif;  % ~isnan(od.dtofir)
            cod{end + 1} = sprintf('%d', size(od.pd)(1));
            cod{end + 1} = sprintf('%d', size(od.pd)(2));
            cod{end + 1} = sprintf('%d', size(od.pd)(3));
            if(~isequal('None', od.rslu))
                cod{end + 1} = sprintf('%d %s', od.rsl(1), od.rslu);
                cod{end + 1} = sprintf('%d %s', od.rsl(2), od.rslu);
            endif;  % ~isequal('None', od.rslu)

        endfunction;  % ascell()


        function result = data_size(od)
% -----------------------------------------------------------------------------
%
% Method 'data_size':
%
% Use:
%       -- result = od.data_size()
%
% Description:
%          Return size of the pixel data matrix.
%
% -----------------------------------------------------------------------------
            result = size(od.pd);

        endfunction;  % data_size()


        function PD = pixel_data(od, pds=PixelDataSmoothing())
% -----------------------------------------------------------------------------
%
% Method 'pixel_data':
%
% Use:
%       -- pd = od.pixel_data()
%       -- pd = od.pixel_data(pds)
%
% Description:
%          Return copy of the optical density pixel data. If pixel data
%          smoothing is defined, return smoothed data.
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

            PD = pds.smooth(od.pd);

        endfunction;  % pixel_data(pds)


        function IP = inprofile(od, varargin)
% -----------------------------------------------------------------------------
%
% Method 'inprofile':
%
% Use:
%       -- IP = od.inprofile()
%       -- IP = od.inprofile(..., "PROPERTY", VALUE, ...)
%
% Description:
%          Return in profile data for the given optical density instance and the
%          given column index. If default value is used for the column index it
%          extracts data for the calculated column at the middle of the columns
%          range.
%
%          For additional data smoothing one may pass a PixelDataSmoothing
%          instance to the method call.
%
% -----------------------------------------------------------------------------
            fname = 'inprofile';
            use_case_a = ' -- IP = od.inprofile()';
            use_case_b = ' -- IP = od.inprofile(..., "PROPERTY", VALUE, ...)';

            % Parse optional arguments ----------------------------------------
            [ ...
                pos, ...
                pds, ...
                rsp, ...
                x ...
                ] = parseparams( ...
                varargin, ...
                'Smoothing', PixelDataSmoothing(), ...
                'ResampleTo', 0, ...
                'Column', 0 ...
                );

            if(0 ~= numel(pos))
                % Invalid call to constructor
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            'Invalid call to %s. Correct usage ', ...
                            'is:\n%s\n%s' ...
                            ), ...
                        fname, ...
                        use_case_a, ...
                        use_case_b ...
                        ) ...
                    );

            endif;  % 0 ~= numel(pos)

            % Validate value supplied for the PixelDataSmoothing
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

            % Validate value supplied for the ResampleTo
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
                'ResampleTo' ...
                );

            % Validate value supplied for the Column
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
                'Column' ...
                );

            IP = [];

            % ResampleTo value must be equal to or greater than number of
            % rows in the OD's pixel data. So check if this is true. If zero is
            % given use the default value i.e. od.data_size()(1)
            if(0 ~= rsp)
                if(size(od.pd)(1) > rsp)
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                '%s: ResampleTo must be >= number of', ...
                                ' rows in the pixel data' ...
                                ), ...
                            fname ...
                            )
                        );

                endif;  % size(od.pd)(1) > rsp

            else
                rsp = size(od.pd)(1);

            endif;  % 0 ~= rsp

            % If column index set to default value (i.e. 0) calculate index of
            % the middle column in the columns index range
            if(0 == x)
                % Column index set to default value. Calculate the index
                % of the middle column of the column range
                x = round(size(od.pd)(2) / 2);

            endif;

            % Validate value supplied for the column index
            if(size(od.pd)(2) < x)
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: column index out of bound (expected', ...
                            ' value <= %d, got %d)' ...
                            ), ...
                        fname, ...
                        size(od.pd)(2), ...
                        x ...
                        ) ...
                    );

            endif;  % size(od.pd)(2) < x

            % Extract the profile data ----------------------------------------
            IP = squeeze(od.pixel_data(pds)(:, x, :));
            k = size(IP, 1) - numel(0:1/size(IP, 1):1);
            IP = interp1( ...
                0:1/size(IP, 1):(1 + k/size(IP, 1)), ...
                IP, ...
                0:1/rsp:(1 + k/rsp) ...
                );

            if(1 == size(IP, 1))
                IP = IP';

            endif;

        endfunction;  % inprofile()


% TODO: Try varargin for the function arguments
        function CP = crossprofile(od, varargin)
% -----------------------------------------------------------------------------
%
% Method 'crossprofile':
%
% Use:
%       -- CP = od.crossprofile()
%       -- CP = od.crossrofile(..., "PROPERTY", VALUE, ...)
%
% Description:
%          Return cross profile data for the given optical density instance and
%          the given row index. If default value is used for the row index it
%          extracts data for the calculated column at the middle of the rows
%          range.
%
%          For additional data smoothing one may pass a PixelDataSmoothing
%          instance to the method call.
%
% -----------------------------------------------------------------------------
            fname = 'crossprofile';
            use_case_a = ' -- CP = od.crossprofile()';
            use_case_b = ' -- CP = od.crossprofile(..., "PROPERTY", VALUE, ...)';

            % Parse optional arguments ----------------------------------------
            [ ...
                pos, ...
                pds, ...
                rsp, ...
                y ...
                ] = parseparams( ...
                varargin, ...
                'Smoothing', PixelDataSmoothing(), ...
                'ResampleTo', 0, ...
                'Row', 0 ...
                );

            if(0 ~= numel(pos))
                % Invalid call to constructor
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            'Invalid call to %s. Correct usage ', ...
                            'is:\n%s\n%s' ...
                            ), ...
                        fname, ...
                        use_case_a, ...
                        use_case_b ...
                        ) ...
                    );

            endif;  % 0 ~= numel(pos)

            % Validate value supplied for the PixelDataSmoothing
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

            % Validate value supplied for the ResampleTo
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
                'ResampleTo' ...
                );

            % Validate value supplied for the Column
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
                'Row' ...
                );

            CP = [];

            % ResampleTo value must be equal to or greater than number of
            % columns in the OD's pixel data. So check if this is true. If zero
            % is given use the default value i.e. od.data_size()(2)
            if(0 ~= rsp)
                if(size(od.pd)(2) > rsp)
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                '%s: ResampleTo must be >= number of', ...
                                ' columns in the pixel data' ...
                                ), ...
                            fname ...
                            )
                        );

                endif;  % size(od.pd)(2) > rsp

            else
                rsp = size(od.pd)(2);

            endif;  % 0 ~= rsp

            % If row index set to default value (i.e. 0) calculate index of
            % the middle row in the rows index range
            if(0 == y)
                % Column index set to default value. Calculate the index
                % of the middle column of the column range
                y = round(size(od.pd)(1) / 2);

            endif;

            % Validate value supplied for the column index
            if(size(od.pd)(1) < y)
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: row index out of bound (expected', ...
                            ' value <= %d, got %d)' ...
                            ), ...
                        fname, ...
                        size(od.pd)(1), ...
                        x ...
                        ) ...
                    );

            endif;  % size(od.pd)(1) < x

            % Extract the profile data ----------------------------------------
            CP = squeeze(od.pixel_data(pds)(y, :, :));
            k = size(CP, 1) - numel(0:1/size(CP, 1):1);
            CP = interp1( ...
                0:1/size(CP, 1):(1 + k/size(CP, 1)), ...
                CP, ...
                0:1/rsp:(1 + k/rsp) ...
                );

            if(1 == size(CP, 1))
                CP = CP';

            endif;

        endfunction;  % crossprofile()


% TODO: Try varargin for the function arguments
        function inplot(od, pds=PixelDataSmoothing(), x=0)
% -----------------------------------------------------------------------------
%
% Method 'inplot':
%
% Use:
%       -- od.inplot()
%       -- od.inplot(pds)
%       -- od.inplot(pds, x)
%
% Description:
%          Plot in profile data for the given optical density instance and the
%          given column index. If default value is used for the column index it
%          extracts data for the calculated column at the middle of the columns
%          range.
%
%          For additional data smoothing one may pass a PixelDataSmoothing
%          instance to the method call.
%
% -----------------------------------------------------------------------------

        endfunction;  % inplot()


% TODO: Try varargin for the function arguments
        function crossplot(od, pds=PixelDataSmoothing(), y=0)
% -----------------------------------------------------------------------------
%
% Method 'crossplot':
%
% Use:
%       -- od.crossplot()
%       -- od.crossplot(pds)
%       -- od.crossplot(pds, y)
%
% Description:
%          Plot cross profile data for the given optical density instance and
%          the given row index. If default value is used for the row index it
%          extracts data for the calculated row at the middle of the rows range.
%
%          For additional data smoothing one may pass a PixelDataSmoothing
%          instance to the method call.
%
% -----------------------------------------------------------------------------

        endfunction;  % crossplot()


% TODO: Try varargin for the function arguments
        function imshow(od, pds=PixelDataSmoothing(), rsp=[])
% -----------------------------------------------------------------------------
%
% Method 'imshow':
%
% Use:
%       -- od.imshow()
%       -- od.imshow(pds)
%       -- od.imshow(pds, heq)
%
% Description:
%          Plot scan set pixel data as image.
%
% -----------------------------------------------------------------------------

        endfunction;  % imshow()

    endmethods;  % Public methods

endclassdef;  % Scanset
