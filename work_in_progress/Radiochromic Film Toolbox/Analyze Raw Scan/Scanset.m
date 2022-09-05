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
        % Date of irradiation (is applicable)
        dt_irrd  = NaN;
        % Date of scanning (mandatory)
        dt_scan  = NaN;
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

            % Parse arguments -------------------------------------------------
            [ ...
                pos, ...
                title, ...
                dt_irrd, ...
                dt_scan ...
                ] = parseparams( ...
                varargin, ...
                'Title', 'Unknown', ...
                'DateOfIrradiation', NaN, ...
                'DateOfScan', NaN ...
                );

            if(0 == numel(pos))
                % Invalid call to constructor
                error( ...
                    'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
                    fname, ...
                    use_case_a, ...
                    use_case_b, ...
                    use_case_c ...
                    );

            endif;

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
                    R  = tiff_tag_read(pos{idx}, 282);

                endif;

                ru = tiff_tag_read(pos{idx}, 296);
                RX = tiff_tag_read(pos{idx}, 282);
                RY = tiff_tag_read(pos{idx}, 283);

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
                ss.files = {ss.files, pos{idx}};

                ++idx;

            endwhile;

            % Validate value supplied for the Title
            if(~ischar(title) || isempty(title))
                error('%s: Title must be a non-empty string', fname);

            endif;

            % Validate value supplied for the DateOfIrradiation
            if(~isnan(dt_irrd))
                validateattributes( ...
                    dt_irrd, ...
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
                if(datenum(2000, 1, 1) > dt_irrd)
                    error('%s: DateOfIrradiation too old: %s', datestr(dt_irrd));

                endif;

            endif;

            % Validate value supplied for the DateOfScan
            if(~isnan(dt_scan))
                validateattributes( ...
                    dt_scan, ...
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
                dt_scan = datenum(strsplit(ifi.FileModDate){1});

            endif;

            % Check if given date is after the 01-Jan-2000
            if(datenum(2000, 1, 1) > dt_scan)
                error('%s: DateOfScan too old: %s', datestr(dt_scan));

            endif;

            % Assign values to a new instance ---------------------------------
            ss.title   = title;
            ss.dt_irrd = dt_irrd;
            ss.dt_scan = dt_scan;

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
            if(~isnan(ss.dt_irrd))
                printf('\t\tTitle:               %s,\n', ss.title);
                printf('\t\tDate of scan:        %s,\n', ss.dt_scan);
                printf('\t\tDate of irradiation: %s,\n', ss.dt_irrd);
                printf('\t\tPixel data:          ');
                if(isempty(ss.pwmean))
                    printf('[],\n');

                else
                    printf('[...],\n');
                    printf('\t\tPixelwise SD:        [...]\n');

                endif;

            else
                printf('\t\tTitle:        %s,\n', ss.title);
                printf('\t\tDate of scan: %s,\n', ss.dt_scan);
                printf('\t\tPixel data:   ');
                if(isempty(ss.pwmean))
                    printf('[],\n');

                else
                    printf('[...],\n');
                    printf('\t\tPixelwise SD: [...]\n');

                endif;


            endif;
            printf('\t)\n');

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp_short':
%
% Use:
%       -- ss.disp_short()
%
% Description:
%          The disp_short method is used by 'List' class whenever a
%          Scanset instance should be displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp_short(ss)
            printf('Scanset(%s)', ss.title);

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
            ss = {};
            ss = {ss.title, ss.dt_scan, ss.dt_irrd;};

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
%          instances are equivalent if they have identical number of input files
%          with identical size.
% -----------------------------------------------------------------------------
        function result = isequivalent(ss, other)
            fname = 'isequivalent';

            if(~isa(other, 'Scanset'))
                error( ...
                    '%s: other must be an instance of the "Scanset" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if( ...
                    numel(ss.files) == numel(other.files) ...
                    && size(ss.files{1}) == size(other.files{1}) ... 
                    );
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

            % Initialize result to a default value
            result = false;
            if( ...
                    isequal(ss.title, other.title) ...
                    && isequal(ss.files, other.files) ...
                    && isequal(ss.dt_irrd, other.dt_irrd) ...
                    && isequal(ss.dt_scan, other.dt_scan) ...
                    && isequal(ss.pwmean, other.pwmean) ...
                    && isequal(ss.pwsd, other.pwsd) ...
                    )
                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
