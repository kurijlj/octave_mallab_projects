% -----------------------------------------------------------------------------
%
% Class 'FilmDigitizer':
%
% Description:
%       TODO: Add class descritpion here.
%
% -----------------------------------------------------------------------------
classdef FilmDigitizer

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (SetAccess = private, GetAccess = public)
        % Scanner title (unique ID)
        title   = 'Unknown';
        % Scanner manufacturer name
        mnfc    = 'Unknown';
        % Scanner model
        model   = 'Unknown';
        % Scanner serial number
        sno     = 'Unknown';
        % Scanner optical resolution (i.e. 2400 dpi)
        opt_res = 'Unknown';
        % Scanner dynamic range (i.e. 3.8 Dmax, for more details read:
        % https://www.modernimaging.com/optical_density.htm)
        opt_dst = 'Unknown';
        % Scanner light source
        lgt_src = 'Unknown';
        % Scanning mode used (i.e. 'Unknown', 'Reflective' or 'Transmissive')
        scn_mod = 'Unknown';
        % Scanning resolution used (i.e. 400 dpi)
        scn_res = 'Unknown';
        % Plate used to fix film on the scanner bed (i.e. 'Unknown', 'None',
        % '3 mm plexi', '4 mm glass', ...)
        flm_fix = 'Unknown';

    endproperties;

% -----------------------------------------------------------------------------
%
% Public methods section
%
% -----------------------------------------------------------------------------
    methods (Access = public)

% -----------------------------------------------------------------------------
%
% Method 'Item':
%
% Use:
%       -- fd = FilmDigitizer()
%       -- fd = FilmDigitizer(..., "PROPERTY", VALUE, ...)
%       -- fd = FilmDigitizer(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function fd = FilmDigitizer(varargin)
            fname = 'FilmDigitizer';
            use_case_a = ' -- fd = FilmDigitizer()';
            use_case_b = ' -- fd = FilmDigitizer(..., "PROPERTY", VALUE, ...)';
            use_case_c = ' -- fd = FilmDigitizer(other)';

            if(0 == nargin)
                % Default constructor invoked ---------------------------------

            elseif(1 == nargin)
                if(isa(varargin{1}, 'FilmDigitizer'))
                    % Copy constructor invoked
                    fd.title   = varargin{1}.title;
                    fd.mnfc    = varargin{1}.mnfc;
                    fd.model   = varargin{1}.model;
                    fd.sno     = varargin{1}.sno;
                    fd.opt_res = varargin{1}.opt_res;
                    fd.opt_dst = varargin{1}.opt_dst;
                    fd.lgt_src = varargin{1}.lgt_src;
                    fd.scn_mod = varargin{1}.scn_mod;
                    fd.scn_res = varargin{1}.scn_res;
                    fd.flm_fix = varargin{1}.flm_fix;

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

            elseif(2 <= nargin && 20 >= nargin)
                % Regular constructor invoked ---------------------------------

                % Parse arguments
                [ ...
                    pos, ...
                    title, ...
                    mnfc, ...
                    model, ...
                    sno, ...
                    opt_res, ...
                    opt_dst, ...
                    lgt_src, ...
                    scn_mod, ...
                    scn_res, ...
                    flm_fix ...
                    ] = parseparams( ...
                    varargin, ...
                    'Title', 'Unknown', ...
                    'Manufacturer', 'Unknown', ...
                    'Model', 'Unknown', ...
                    'SerialNumber', 'Unknown', ...
                    'OpticalResolution', 'Unknown', ...
                    'OpticalDensity', 'Unknown', ...
                    'LightSource', 'Unknown', ...
                    'ScanningMode', 'Unknown', ...
                    'ScanningResolution', 'Unknown', ...
                    'FilmFixation', 'Unknown' ...
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

                % Validate value supplied for the Manufacturer
                if(~ischar(mnfc) || isempty(mnfc))
                    error('%s: Manufacturer must be a non-empty string', fname);

                endif;

                % Validate value supplied for the Model
                if(~ischar(model) || isempty(model))
                    error('%s: Model must be a non-empty string', fname);

                endif;

                % Validate value supplied for the SerialNumber
                if(~ischar(sno) || isempty(sno))
                    error('%s: SerialNumber must be a non-empty string', fname);

                endif;

                % Validate value supplied for the OpticalResolution
                if(~ischar(opt_res) || isempty(opt_res))
                    error('%s: OpticalResolution must be a non-empty string', fname);

                endif;

                % Validate value supplied for the OpticalDensity
                if(~ischar(opt_dst) || isempty(opt_dst))
                    error('%s: OpticalDensity must be a non-empty string', fname);

                endif;

                % Validate value supplied for the LightSource
                if(~ischar(lgt_src) || isempty(lgt_src))
                    error('%s: LightSource must be a non-empty string', fname);

                endif;

                % Validate value supplied for the ScanningMode
                validatestring( ...
                    scn_mod, ...
                    {'Unknown', 'Transmissive', 'Reflective'}, ...
                    fname, ...
                    'ScanningMode' ...
                    );

                % Validate value supplied for the ScanningResolution
                if(~ischar(scn_res) || isempty(scn_res))
                    error('%s: ScanningResolution must be a non-empty string', fname);

                endif;

                % Validate value supplied for the FilmFixation
                if(~ischar(flm_fix) || isempty(flm_fix))
                    error('%s: FilmFixation must be a non-empty string', fname);

                endif;

                % Assign values to a new instance -----------------------------
                fd.title   = title;
                fd.mnfc    = mnfc;
                fd.model   = model;
                fd.sno     = sno;
                fd.opt_res = opt_res;
                fd.opt_dst = opt_dst;
                fd.lgt_src = lgt_src;
                fd.scn_mod = scn_mod;
                fd.scn_res = scn_res;
                fd.flm_fix = flm_fix;

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
%       -- fd.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(fd)
            printf('\tFilmDigitizer(\n');
            printf('\t\tTitle:               %s,\n', fd.title);
            printf('\t\tManufacturer:        %s,\n', fd.mnfc);
            printf('\t\tModel:               %s,\n', fd.model);
            printf('\t\tSerial number:       %s,\n', fd.sno);
            printf('\t\tOptical resolution:  %s,\n', fd.opt_res);
            printf('\t\tOptical density:     %s,\n', fd.opt_dst);
            printf('\t\tLight source:        %s,\n', fd.lgt_src);
            printf('\t\tScanning mode:       %s,\n', fd.scn_mod);
            printf('\t\tScanning resolution: %s,\n', fd.scn_res);
            printf('\t\tFilm fixation:       %s\n', fd.flm_fix);
            printf('\t)\n');

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp_short':
%
% Use:
%       -- fd.disp_short()
%
% Description:
%          The disp_short method is used by 'List' class whenever a
%          FilmDigitizer instance should be displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp_short(fd)
            printf( ...
                'FilmDigitizer(%s, %s, %s, %s)', ...
                fd.title, ...
                fd.scn_mod, ...
                fd.scn_res, ...
                fd.flm_fix ...
                );

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'cellarray':
%
% Use:
%       -- cell_fd = fd.cellarry()
%
% Description:
%          Return digitizer object structure as cell array.
%
% -----------------------------------------------------------------------------
        function cell_fd = cellarray(fd)
            cell_fd = {};
            cell_fd = { ...
                fd.title, fd.mnfc, fd.model, fd.sno, fd.opt_res, fd.opt_dst, ...
                fd.lgt_src, fd.scn_mod, fd.scn_res, fd.flm_fix; ...
                };

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = fd.isequivalent(other)
%
% Description:
%          Return whether or not two FilmDigitizer instances are equivalent. Two
%          instances are equivalent if they have identical titles.
% -----------------------------------------------------------------------------
        function result = isequivalent(fd, other)
            fname = 'isequivalent';

            if(~isa(other, 'FilmDigitizer'))
                error( ...
                    '%s: other must be an instance of the "FilmDigitizer" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if(isequal(fd.title, other.title));
                result = true;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = fd.isequal(other)
%
% Description:
%          Return whether or not two 'FilmDigitizer' instances are equal. Two
%          instances are equal if all of their fields have identical values.
%
% -----------------------------------------------------------------------------
        function result = isequal(fd, other)
            fname = 'isequal';

            if(~isa(other, 'FilmDigitizer'))
                error( ...
                    '%s: other must be an instance of the "FilmDigitizer" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if( ...
                    isequal(fd.title, other.title) ...
                    && isequal(fd.mnfc, other.mnfc) ...
                    && isequal(fd.model, other.model) ...
                    && isequal(fd.sno, other.sno) ...
                    && isequal(fd.opt_res, other.opt_res) ...
                    && isequal(fd.opt_dst, other.opt_dst) ...
                    && isequal(fd.lgt_src, other.lgt_src) ...
                    && isequal(fd.scn_mod, other.scn_mod) ...
                    && isequal(fd.scn_res, other.scn_res) ...
                    && isequal(fd.flm_fix, other.flm_fix) ...
                    )
                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
