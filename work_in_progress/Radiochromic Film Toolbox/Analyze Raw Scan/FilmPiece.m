% -----------------------------------------------------------------------------
%
% Class 'FilmPiece':
%
% Description:
%       TODO: Add class descritpion here.
%
% -----------------------------------------------------------------------------
classdef FilmPiece

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (SetAccess = private, GetAccess = public)
        % Film piece title (unique ID)
        title   = 'Unknown';
        % Film manufacturer name
        mnfc    = 'Unknown';
        % Film model (type and model)
        model   = 'Unknown';
        % Film LOT
        lot     = 'Unknown';
        % Whether film was custom cut or no ('Yes', 'No' or 'Unknown')
        cst_cut = 'Unknown';

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
%       -- fp = FilmPiece()
%       -- fp = FilmPiece(..., "PROPERTY", VALUE, ...)
%       -- fp = FilmPiece(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function fp = FilmPiece(varargin)
            fname = 'FilmPiece';
            use_case_a = ' -- fp = FilmPiece()';
            use_case_b = ' -- fp = FilmPiece(..., "PROPERTY", VALUE, ...)';
            use_case_c = ' -- fp = FilmPiece(other)';

            if(0 == nargin)
                % Default constructor invoked ---------------------------------

            elseif(1 == nargin)
                if(isa(varargin{1}, 'FilmPiece'))
                    % Copy constructor invoked
                    fp.title   = varargin{1}.title;
                    fp.mnfc    = varargin{1}.mnfc;
                    fp.model   = varargin{1}.model;
                    fp.lot     = varargin{1}.lot;
                    fp.cst_cut = varargin{1}.cst_cut;

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
                    lot, ...
                    cst_cut ...
                    ] = parseparams( ...
                    varargin, ...
                    'Title', 'Unknown', ...
                    'Manufacturer', 'Unknown', ...
                    'Model', 'Unknown', ...
                    'LOT', 'Unknown', ...
                    'CustomCut', 'Unknown' ...
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
                if(~ischar(lot) || isempty(lot))
                    error('%s: LOT must be a non-empty string', fname);

                endif;

                % Validate value supplied for the ScanningMode
                validatestring( ...
                    cst_cut, ...
                    {'Unknown', 'Yes', 'No'}, ...
                    fname, ...
                    'CustomCut' ...
                    );

                % Assign values to a new instance -----------------------------
                fp.title   = title;
                fp.mnfc    = mnfc;
                fp.model   = model;
                fp.lot     = lot;
                fp.cst_cut = cst_cut;

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
%       -- fp.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(fp)
            printf('\tFilmPiece(\n');
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
%          FilmPiece instance should be displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp_short(fp)
            printf( ...
                '\tFilmPiece(%s, %s, %s, %s)\n', ...
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
%          Return whether or not two FilmPiece instances are equivalent. Two
%          instances are equivalent if they have identical titles.
% -----------------------------------------------------------------------------
        function result = isequivalent(fp, other)
            fname = 'isequivalent';

            if(~isa(other, 'FilmPiece'))
                error( ...
                    '%s: other must be an instance of the "FilmPiece" class', ...
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
%          Return whether or not two 'FilmPiece' instances are equal. Two
%          instances are equal if all of their fields have identical values.
%
% -----------------------------------------------------------------------------
        function result = isequal(fp, other)
            fname = 'isequal';

            if(~isa(other, 'FilmPiece'))
                error( ...
                    '%s: other must be an instance of the "FilmPiece" class', ...
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
