classdef OpticalDensity
classdef Scanset
%% -----------------------------------------------------------------------------
%%
%% Class 'NetOpticalDensity':
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
                % Regular constructor invoked ---------------------------------

                % Parse constructor call arguments
                [ ...
                    pos, ...
                    odtitle, ...
                    dtofir, ...
                    dtofsc, ...
                    pds ...
                    ] = parseparams( ...
                    varargin(idx:end), ...
                    'Title', 'Net Optical Density', ...
                    'DateOfIrradiation', NaN, ...
                    'DateOfScan', NaN, ...
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

            endif;  % End of nargin validation

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
            result = '';

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
            result = size(ss.pd);

        endfunction;  % data_size()


        function pd = pixel_data(od, pds=PixelDataSmoothing())
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
            pd = [];

        endfunction;  % pixel_data(pds)


% TODO: Try varargin for the function arguments
        function IP = inprofile(od, pds=PixelDataSmoothing(), rsp=0, x=0)
% -----------------------------------------------------------------------------
%
% Method 'inprofile':
%
% Use:
%       -- IP = od.inprofile()
%       -- IP = od.inprofile(pds)
%       -- IP = od.inprofile(pds, rsp)
%       -- IP = od.inprofile(pds, rsp, x)
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
            IP = [];

        endfunction;  % inprofile(x, pds)


% TODO: Try varargin for the function arguments
        function CP = crossprofile(od, pds=PixelDataSmoothing(), rsp=0, y=0)
% -----------------------------------------------------------------------------
%
% Method 'crossprofile':
%
% Use:
%       -- CP = od.crossprofile()
%       -- CP = od.crossprofile(pds)
%       -- CP = od.crossprofile(pds, rsp)
%       -- CP = od.crossprofile(pds, rsp, y)
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
            CP = [];

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
