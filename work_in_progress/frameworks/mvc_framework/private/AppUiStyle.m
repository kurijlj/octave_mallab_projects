% -----------------------------------------------------------------------------
%
% Class 'AppUiStyle':
%
% Description:
%       Custom data type used to represent application wide UI style like, UI
%       elements padding, buttons widht and height, input fields width an
%       height, etc.
%
% -----------------------------------------------------------------------------

classdef AppUiStyle

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (Access = public)
        padding      = 6;
        column_width = 128;
        row_height   = 24;
        btn_width    = 128;
        btn_height   = 32;

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
%       -- style = AppUiStyle()
%       -- style = AppUiStyle(..., "PROPERTY", value, ...)
%       -- style = AppUiStyle(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function style = AppUiStyle(varargin)
            fname = 'AppUiStyle';
            use_case_a = ' -- style = AppUiStyle()';
            use_case_b = ' -- style = AppUiStyle(..., "PROPERTY", value, ...)';
            use_case_c = ' -- style = AppUiStyle(other)';

            if(0 == nargin)
                % Default constructor invoked

            else
                % Parse arguments
                [ ...
                    pos, ...
                    padding, ...
                    column_width, ...
                    row_height, ...
                    btn_width, ...
                    btn_height ...
                    ] = parseparams( ...
                    varargin, ...
                    'Padding', 6, ...
                    'ColumnWidth', 128, ...
                    'RowHeigth', 24, ...
                    'ButtonWidth', 128, ...
                    'ButtonHeight', 32 ...
                    );

                % Validate the number of positional parameters
                if(0 == numel(pos))
                    % Regular constructor invoked

                    % Validate argument values
                    validateattributes( ...
                        padding, ...
                        {'numeric'}, ...
                        { ...
                            'scalar', ...
                            'nonnan', ...
                            'integer', ...
                            '>=', 0 ...
                            }, ...
                        fname, ...
                        'Padding' ...
                        );
                    validateattributes( ...
                        column_width, ...
                        {'numeric'}, ...
                        { ...
                            'scalar', ...
                            'nonnan', ...
                            'integer', ...
                            '>=', 1 ...
                            }, ...
                        fname, ...
                        'ColumnWidth' ...
                        );
                    validateattributes( ...
                        row_height, ...
                        {'numeric'}, ...
                        { ...
                            'scalar', ...
                            'nonnan', ...
                            'integer', ...
                            '>=', 1 ...
                            }, ...
                        fname, ...
                        'RowHeight' ...
                        );
                    validateattributes( ...
                        btn_width, ...
                        {'numeric'}, ...
                        { ...
                            'scalar', ...
                            'nonnan', ...
                            'integer', ...
                            '>=', 1 ...
                            }, ...
                        fname, ...
                        'ButtonWidth' ...
                        );
                    validateattributes( ...
                        btn_height, ...
                        {'numeric'}, ...
                        { ...
                            'scalar', ...
                            'nonnan', ...
                            'integer', ...
                            '>=', 1 ...
                            }, ...
                        fname, ...
                        'ButtonHeight' ...
                        );

                    % Assign passed values to the object
                    style.padding = padding;
                    style.column_width = column_width;
                    style.row_height = row_height;
                    style.btn_width = btn_width;
                    style.btn_height = btn_height;

                elseif(1 == numel(pos) && 1 == nargin)
                    % Copy constructor invoked
                    if(~isa(pos{1}, 'AppUiStyle'))
                        error( ...
                            '%s: other must be an instance of the "AppUiStyle" class', ...
                            fname, ...
                            idx ...
                            );
                    endif;

                    style.padding      = pos{1}.padding;
                    style.column_width = pos{1}.column_width;
                    style.row_height   = pos{1}.row_height;
                    style.btn_width    = pos{1}.btn_width;
                    style.btn_height   = pos{1}.btn_height;

                else
                    error( ...
                        'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
                        fname, ...
                        use_case_a, ...
                        use_case_b, ...
                        use_case_c ...
                        );

                endif;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- style.disp()
%
% Description:
%          The disp method is used by Octave whenever a class should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(style)
            printf('\tAppUiStyle( ...\n');
            printf('\t\t"Padding": %d, ...\n', style.padding);
            printf('\t\t"ColumnWidth": %d, ...\n', style.column_width);
            printf('\t\t"RowHeight": %d, ...\n', style.row_height);
            printf('\t\t"ButtonWidth": %d, ...\n', style.btn_width);
            printf('\t\t"ButtonHeight": %d, ...\n', style.btn_height);
            printf('\t)\n');

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'normalized':
%
% Use:
%       -- nstyle = style.normalized(ref_ext)
%
% Description:
%          Return the UI style parameters normalized to given reference extents
%          ref_ext. ref_ext is a 4-element vector with values [ lower_left_X,
%          lower_left_Y, width, height ] obtained with getpixelposition
%          function.
%
% -----------------------------------------------------------------------------
        function nstyle = normalized(style, ref_ext)
            fname = 'normalized';

            validateattributes( ...
                ref_ext, ...
                {'numeric'}, ...
                { ...
                    'vector', ...
                    'row', ...
                    'numel', 4, ...
                    'nonnan', ...
                    '>=', 0 ...
                    }, ...
                fname, ...
                'ref_ext' ...
                );

            nstyle              = struct();
            nstyle.padding_hor  = style.padding / ref_ext(3);
            nstyle.padding_ver  = style.padding / ref_ext(4);
            nstyle.column_width = style.column_width / ref_ext(3);
            nstyle.row_height   = style.row_height / ref_ext(4);
            nstyle.btn_width    = style.btn_width / ref_ext(3);
            nstyle.btn_height   = style.btn_height / ref_ext(4);

        endfunction;

    endmethods;

endclassdef;
