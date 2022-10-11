% -----------------------------------------------------------------------------
%
% Class 'Scanset':
%
% Description:
%       TODO: Add class descritpion here.
%
% -----------------------------------------------------------------------------
classdef Scanset

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (SetAccess = private, GetAccess = public)
        % Film piece title (unique ID)
        title    = 'Unknown';
        % List of files defining the scanset
        files    = {};
        % Date of irradiation (if applicable)
        dt_irrd  = NaN;
        % Date of scanning (mandatory)
        dt_scan  = NaN;
        % Type (mandatory)
        type     = 'TrueScanset';
        % Data smoothing (mandatory)
        ds       = NaN;
        % Pixel data
        pwmean   = [];
        % Pixelwise standard deviation
        pwsd     = [];
        % List of warnings generated during the initialization of the object
        warnings = {};

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
%       -- ss = Scanset(tif1, tif2, ...)
%       -- ss = Scanset(..., "PROPERTY", VALUE, ...)
%       -- ss = Scanset(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function ss = Scanset(varargin)
            fname = 'Scanset';
            use_case_a = ' -- ss = Scanset(tif1, tif2, ...)';
            use_case_b = ' -- ss = Scanset(..., "PROPERTY", VALUE, ...)';
            use_case_c = ' -- ss = Scanset(other)';

            % Check if copy constructor invoked -------------------------------
            if(1 == nargin && isa(varargin{1}, 'Scanset'))
                % Copy constructor invoked
                ss.title    = varargin{1}.title;
                ss.files    = varargin{1}.files;
                ss.dt_irrd  = varargin{1}.dt_irrd;
                ss.dt_scan  = varargin{1}.dt_scan;
                ss.type     = varargin{1}.type;
                ss.ds       = varargin{1}.ds;
                ss.pwmean   = varargin{1}.pwmean;
                ss.pwsd     = varargin{1}.pwsd;
                ss.warnings = varargin{1}.warnings;

                return;

            endif;

            % Parse arguments -------------------------------------------------
            [pos, props] = parsearguments( ...
                varargin, ...
                { ...
                    'Title', 'Unknown'; ...
                    'DateOfIrradiation', NaN; ...
                    'DateOfScan', NaN; ...
                    'Type', 'TrueScanset'; ...
                    'DataSmoothing', PixelDataSmoothing(); ...
                    } ...
                );

            % Load required packages ------------------------------------------
            pkg load image;

            % Validate input arguments ----------------------------------------

            % Validate given file paths

            % Initilize variables holding reference parameters
            RU = 0;
            R  = 0;
            W  = 0;
            H  = 0;

            % Initialize loop counter
            idx = 1;

            % Traverse file list
            while(numel(pos) >= idx)

                % Check if we are dealing with non-empty string ---------------
                if(~ischar(pos{idx}) || isempty(pos{idx}))
                    error( ...
                        '%s: pos{%d} must be a non-empty string', ...
                        fname, ...
                        idx ...
                        );

                endif;

                % Check if we have a regular file -----------------------------
                if(~isfile(pos{idx}))
                    % We don't have a regular file. Format warning message
                    w = sprintf('%s is not a regular file', pos{idx});

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    ss.warnings = {ss.warnings{:}, w};

                    % Continue to next argument
                    ++idx;
                    continue;

                endif;

                % Load image file info ----------------------------------------
                ifi = NaN;
                try
                    ifi = imfinfo(pos{idx});

                catch
                    % We don't have an image file. Format warning message
                    w = sprintf('%s is not an image file', pos{idx});

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    ss.warnings = {ss.warnings{:}, w};

                    % Continue to next argument
                    ++idx;
                    continue;

                end_try_catch;

                % Check if we have a TIFF image -------------------------------
                if(~isequal('TIFF', ifi.Format))
                    % We don't have a TIFF image. Format warning message
                    w = sprintf('%s is not an TIFF image', pos{idx});

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    ss.warnings = {ss.warnings{:}, w};

                    % Continue to next argument
                    ++idx;
                    continue;

                endif;

                % Check if we have an RGB TIFF image --------------------------
                if(2 ~= tiff_tag_read(pos{idx}, 262))
                    % We don't have an RGB image. Format warning message
                    w = sprintf('%s is not an RGB image', pos{idx});

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    ss.warnings = {ss.warnings{:}, w};

                    % Continue to next argument
                    ++idx;
                    continue;

                endif;

                % Check if we have the right bit depth ------------------------
                if(16 ~= ifi.BitDepth)
                    % We don't have 16 bits per sample. Format warning message
                    w = sprintf( ...
                        '%s has noncomplying bit depth (%d bps, expected 16 bps)', ...
                        pos{idx}, ...
                        ifi.BitDepth ...
                        );

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    ss.warnings = {ss.warnings{:}, w};

                    % Continue to next argument
                    ++idx;
                    continue;

                endif;

                % Check if we are dealing with an uncompressed image ----------
                if(1 ~= tiff_tag_read(pos{idx}, 259))
                    % We don't have an uncompressed image.
                    % Format warning message
                    w = sprintf( ...
                        '%s is not an uncompressed TIFF image', ...
                        pos{idx} ...
                        );

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    ss.warnings = {ss.warnings{:}, w};

                    % Continue to next argument
                    ++idx;
                    continue;

                endif;

                % Check if X and Y resolution comply to each other and if they
                % comply with resolution of the reference image (first image n
                % the stack)
                if(1 == idx)
                    RU = tiff_tag_read(pos{idx}, 296);
                    R = ifi.XResolution;

                endif;

                ru = tiff_tag_read(pos{idx}, 296);
                RX = ifi.XResolution;
                RY = ifi.YResolution;

                % Check if resolution units comply with the reference ---------
                if(RU ~= ru)
                    % Noncompliant resolution units. Format the warning
                    % message
                    w = sprintf( ...
                        '%s noncompliant resolution units (got %d, expected %d)', ...
                        pos{idx}, ...
                        ru, ...
                        RU ...
                        );

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    ss.warnings = {ss.warnings{:}, w};

                    % Continue to next argument
                    ++idx;
                    continue;

                endif;

                % Check if horizontal and vertical resolution are equal -------
                if(RX ~= RY)
                    % X and Y resolution do not comply. Format the warning
                    % message
                    w = sprintf( ...
                        '%s X and Y resolution do not comply (%d ~= %d)', ...
                        pos{idx}, ...
                        RX, ...
                        RY ...
                        );

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    ss.warnings = {ss.warnings{:}, w};

                    % Continue to next argument
                    ++idx;
                    continue;

                endif;

                % Check if resolution comply with the reference ---------------
                if(R ~= RX)
                    % resolution does not comply to the reference. Format the
                    % warning message
                    w = sprintf( ...
                        '%s noncompliant image resolution (got %d, expected %d)', ...
                        pos{idx}, ...
                        RX, ...
                        R ...
                        );

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    ss.warnings = {ss.warnings{:}, w};

                    % Continue to next argument
                    ++idx;
                    continue;

                endif;

                % Check if image width and height comply to the reference width
                % and height (widht and height of the first image in the stack)
                if(1 == idx)
                    W = tiff_tag_read(pos{idx}, 256);
                    H = tiff_tag_read(pos{idx}, 257);

                endif;

                wd = tiff_tag_read(pos{idx}, 256);
                hg = tiff_tag_read(pos{idx}, 257);

                if(W ~= wd || H ~= hg)
                    % image size does not comply to the reference. Format the
                    % warning message
                    w = sprintf( ...
                        '%s noncompliant image size (got %dX%d, expected %dX%d)', ...
                        pos{idx}, ...
                        wd, hg,...
                        W, H ...
                        );

                    % Print warning in the command-line
                    warning( ...
                        '%s: %s. Ignoring file ...', ...
                        fname, ...
                        w ...
                        );

                    % Add warning to the warning stack
                    ss.warnings = {ss.warnings{:}, w};

                    % Continue to next argument
                    ++idx;
                    continue;

                endif;

                % Given file complies to the required image specifications. Add
                % it to the stack
                ss.files = {ss.files{:}, pos{idx}};

                ++idx;

            endwhile; % End of file list traversal

            % Validate value supplied for the Title ---------------------------
            if(~ischar(props{1, 2}) || isempty(props{1, 2}))
                error('%s: Title must be a non-empty string', fname);

            endif;

            % Validate value supplied for the DateOfIrradiation ---------------
            if(~isnan(props{2, 2}))
                validateattributes( ...
                    props{2, 2}, ...
                    {'numeric'}, ...
                    { ...
                        'nonnan', ...
                        'nonempty', ...
                        'scalar', ...
                        'integer', ...
                        'finite', ...
                        'positive' ...
                        }, ...
                    fname, ...
                    'DateOfIrradiation' ...
                    );

                % Check if given date is after the 01-Jan-2000
                if(datenum(2000, 1, 1) > props{2, 2})
                    error( ...
                        '%s: DateOfIrradiation too old: %s', ...
                        datestr(props{2, 2}) ...
                        );

                endif;

            endif;

            % Validate value supplied for the DateOfScan ----------------------
            if(~isnan(props{3, 2}))
                validateattributes( ...
                    props{3, 2}, ...
                    {'numeric'}, ...
                    { ...
                        'nonnan', ...
                        'nonempty', ...
                        'scalar', ...
                        'integer', ...
                        'finite', ...
                        'positive' ...
                        }, ...
                    fname, ...
                    'DateOfScan' ...
                    );

            else
                if(~isempty(ss.files))
                    % If user supplied any file (TrueScanset) use the file
                    % modification date as the default for the DateOfScan
                    props{3, 2} = datenum(strsplit(ifi.FileModDate){1});

                else
                    % otherwise, use the current date
                    props{3, 2} = datenum(date());

                endif;

            endif;

            % Check if given date is after the 01-Jan-2000
            if(datenum(2000, 1, 1) > props{3, 2})
                error('%s: DateOfScan too old: %s', datestr(props{3, 2}));

            endif;

            % Validate value supplied for the Type ----------------------------
            validatestring( ...
                props{4, 2}, ...
                {'TrueScanset', 'DummyBkg', 'DummyZeroL'}, ...
                fname, ...
                'Type' ...
                );

            % If user supplied no files (generate dummy scanset) and it supplied
            % default value for the 'Type' ('TrueScanset'), set it to 'BummyBkg'
            % instead (default value for the dummy scanset)
            if(isempty(ss.files) && isequal('TrueScanset', props{4, 2}))
                props{4, 2} = 'DummyBkg';

            endif;

            % Validate structure supplied for the DataSmoothing ---------------
            if(~isa(props{5, 2}, 'PixelDataSmoothing'))
                error( ...
                    '%s: DataSmoothing must be an instance of the "PixelDataSmoothing" class', ...
                    fname ...
                    );

            endif;

            % Ignore supplied DataSmoothing for the DummyBkg and DummZeroL
            if(~isequal('TrueScanset', props{4, 2}))
                props{5, 2} = PixelDataSmoothing();

            endif;

            % Assign values to a new instance ---------------------------------
            ss.title   = props{1, 2};
            ss.dt_irrd = props{2, 2};
            ss.dt_scan = props{3, 2};
            ss.type    = props{4, 2};
            ss.ds      = props{5, 2};

        endfunction;

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
        function disp(ss)
            printf('\tScanset(\n');

            % We use two output formats for the printing of the 'Scanset'
            % structure depending on whether the irradiation date (dt_irrd) is
            % set or not. If the irradiation date is set we need more space for
            % the fields, i.e. we need to ident field values more
            if(~isnan(ss.dt_irrd))
                % We have irradiation date set
                printf('\t\tTitle:               "%s",\n', ss.title);
                printf('\t\tType:                "%s",\n', ss.type);
                printf( ...
                    '\t\tDate of scan:        "%s",\n', ...
                    datestr(ss.dt_scan, 'dd-mmm-yyyy') ...
                    );
                printf( ...
                    '\t\tDate of irradiation: "%s",\n', ...
                    datestr(ss.dt_irrd, 'dd-mmm-yyyy') ...
                    );
                printf('\t\tData smoothing:      %s,\n', ss.ds.str_rep());

                printf('\t\tPixel data:          ');
                if(isempty(ss.pwmean))
                    printf('Not loaded,\n');

                else
                    printf('[...],\n');
                    printf('\t\tPixelwise SD:        [...],\n');

                endif;

                if(0 == numel(ss.files))
                    printf('\t\tScan #1:            "Dummy"\n');

                else
                    idx = 1;
                    while(numel(ss.files) >= idx)
                        [d, n, e] = fileparts(ss.files{idx});
                        if(numel(ss.files) == idx)
                            % Last entry. Omit the comma at the end
                            printf('\t\tScan #%d:             "%s%s"\n', idx, n, e);

                        else
                            % Not the last entry. Putt the comma at the end
                            printf('\t\tScan #%d:             "%s%s",\n', idx, n, e);

                        endif;

                        ++idx;

                    endwhile;

                endif;

            else
                % We have irradiation date not set
                printf('\t\tTitle:          "%s",\n', ss.title);
                printf('\t\tType:           "%s",\n', ss.type);
                printf( ...
                    '\t\tDate of scan:   "%s",\n', ...
                    datestr(ss.dt_scan, 'dd-mmm-yyyy') ...
                    );
                printf('\t\tData smoothing: %s,\n', ss.ds.str_rep());

                printf('\t\tPixel data:     ');
                if(isempty(ss.pwmean))
                    printf('Not loaded,\n');

                else
                    printf('[...],\n');
                    printf('\t\tPixelwise SD:   [...],\n');

                endif;

                if(0 == numel(ss.files))
                    printf('\t\tScan #1:        "Dummy"\n');

                else
                    idx = 1;
                    while(numel(ss.files) >= idx)
                        [d, n, e] = fileparts(ss.files{idx});
                        if(numel(ss.files) == idx)
                            % Last entry. Omit the comma at the end
                            printf('\t\tScan #%d:        "%s%s"\n', idx, n, e);

                        else
                            % Not the last entry. Putt the comma at the end
                            printf('\t\tScan #%d:        "%s%s",\n', idx, n, e);

                        endif;

                        ++idx;

                    endwhile;

                endif;

            endif;
            printf('\t)\n');

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'str_rep':
%
% Use:
%       -- result = ds.str_rep()
%
% Description:
%          A convenience method that is used to format string representation of
%          the Scanset instance.
%
% -----------------------------------------------------------------------------
        function result = str_rep(ss)
            result = sprintf( ...
                'Scanset("%s", "%s", "%s", %s, %d scan(s))', ...
                ss.title, ...
                ss.type, ...
                datestr(ss.dt_scan, 'dd-mmm-yyyy'), ...
                ss.ds.str_rep(), ...
                numel(ss.files) ...
                );

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'cellarray':
%
% Use:
%       -- css = ss.cellarry()
%
% Description:
%          Return film object structure as cell array.
%
% -----------------------------------------------------------------------------
        function css = cellarray(ss)
            css = {};
            css = {ss.title, ss.type, datestr(ss.dt_scan, 'dd-mmm-yyyy')};

            if(~isnan(ss.dt_irrd))
                css = {css{:}, datestr(ss.dt_irrd, 'dd-mmm-yyyy')};

            else
                css = {css{:}, 'N/A'};

            endif;

            css = {css{:}, ss.ds.cellarray()};

            if(~isempty(ss.files))

                idx = 1;
                while(numel(ss.files) >= idx)
                    [d, n, e] = fileparts(ss.files{idx});
                    css = {css{:}, sprintf('%s%s', n, e)};

                    ++idx;

                endwhile;

            endif;

        endfunction;

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
%          Pixel values must be loaded, otherwise error is thrown.
% -----------------------------------------------------------------------------
        function result = isequivalent(ss, other)
            fname = 'isequivalent';

            if(~isa(other, 'Scanset'))
                error( ...
                    '%s: other must be an instance of the "Scanset" class', ...
                    fname ...
                    );

            endif;

            if(isempty(ss.pwmean))
                error( ...
                    '%s: pixel data not loaded (self)', ...
                    fname ...
                    );

            endif;

            if(isempty(other.pwmean))
                error( ...
                    '%s: pixel data not loaded (other)', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if(size(ss.pwmean) == size(other.pwmean));
                result = true;

            endif;

        endfunction;

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
%          Pixel values must be loaded, otherwise error is thrown.
%
% -----------------------------------------------------------------------------
        function result = isequal(ss, other)
            fname = 'isequal';

            if(~isa(other, 'Scanset'))
                error( ...
                    '%s: other must be an instance of the "Scanset" class', ...
                    fname ...
                    );

            endif;

            if(isempty(ss.pwmean))
                error( ...
                    '%s: pixel data not loaded (self)', ...
                    fname ...
                    );

            endif;

            if(isempty(other.pwmean))
                error( ...
                    '%s: pixel data not loaded (other)', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if( ...
                    isequal(ss.title, other.title) ...
                    && isequal(ss.files, other.files) ...
                    && isequal(ss.dt_irrd, other.dt_irrd) ...
                    && isequal(ss.dt_scan, other.dt_scan) ...
                    && isequal(ss.type, other.type) ...
                    && isequal(ss.ds.isequal(other.ds)) ...
                    && isequal(ss.pwmean, other.pwmean) ...
                    && isequal(ss.pwsd, other.pwsd) ...
                    )
                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
