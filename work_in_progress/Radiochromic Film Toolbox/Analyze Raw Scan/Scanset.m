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
        title   = 'Unknown';
        % List of files defining the scanset
        files    = {};
        % Date of irradiation (is applicable)
        dt_irrd   = NaN;
        % Date of scanning (mandatory)
        dt_scan   = NaN;
        % Pixel data
        pwmean = [];
        % Pixelwise standard deviation
        pwstdev = [];
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

            % Validate supplied file paths
            idx = 1;

            % Initilize variables holding reference parameters
            RU = 0;
            R  = 0;
            W  = 0;
            H  = 0;

            while(numel(pos) >= idx)

                % Check if we are dealing with non-empty string
                if(~ischar(pos{idx}) || isempty(pos{idx}))
                    error( ...
                        '%s: pos{%d} must be a non-empty string', ...
                        fname, ...
                        idx ...
                        );

                endif;

                % Check if we have a regular file
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

                % Load image file info
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

                % Check if we have a TIFF image
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

                % Check if we have an RGB TIFF image
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

                % Check if we have the right bit depth
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

                % Check if we are dealing with an uncompressed image
                if(1 ~= tiff_tag_read(pos{idx}, 259))
                    % We don't have an uncompressed image. Format warning message
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

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- fp.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(fp)
            printf('\tScanset(\n');
            printf('\t\tTitle:        %s,\n', fp.title);
            printf('\t\tManufacturer: %s,\n', fp.mnfc);
            printf('\t\tModel:        %s,\n', fp.model);
            printf('\t\tLOT:          %s,\n', fp.lot);
            printf('\t\tCustom cut:   %s\n', fp.cst_cut);
            printf('\t)\n');

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp_short':
%
% Use:
%       -- fp.disp_short()
%
% Description:
%          The disp_short method is used by 'List' class whenever a
%          Scanset instance should be displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp_short(fp)
            printf( ...
                'Scanset(%s, %s, %s, %s)', ...
                fp.title, ...
                fp.model, ...
                fp.lot, ...
                fp.cst_cut ...
                );

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'cellarray':
%
% Use:
%       -- cell_fp = fp.cellarry()
%
% Description:
%          Return film object structure as cell array.
%
% -----------------------------------------------------------------------------
        function cell_fp = cellarray(fp)
            cell_fp = {};
            cell_fp = {fp.title, fp.mnfc, fp.model, fp.lot, fp.cst_cut;};

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = fp.isequivalent(other)
%
% Description:
%          Return whether or not two Scanset instances are equivalent. Two
%          instances are equivalent if they have identical titles.
% -----------------------------------------------------------------------------
        function result = isequivalent(fp, other)
            fname = 'isequivalent';

            if(~isa(other, 'Scanset'))
                error( ...
                    '%s: other must be an instance of the "Scanset" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if(isequal(fp.title, other.title));
                result = true;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = fp.isequal(other)
%
% Description:
%          Return whether or not two 'Scanset' instances are equal. Two
%          instances are equal if all of their fields have identical values.
%
% -----------------------------------------------------------------------------
        function result = isequal(fp, other)
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
                    isequal(fp.title, other.title) ...
                    && isequal(fp.mnfc, other.mnfc) ...
                    && isequal(fp.model, other.model) ...
                    && isequal(fp.lot, other.lot) ...
                    && isequal(fp.cst_cut, other.cst_cut) ...
                    )
                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
