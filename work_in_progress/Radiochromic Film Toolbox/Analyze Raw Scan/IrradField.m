% -----------------------------------------------------------------------------
%
% Class 'IrradField':
%
% Description:
%       TODO: Add class descritpion here.
%
% -----------------------------------------------------------------------------
classdef IrradField

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (SetAccess = private, GetAccess = public)
        % Irradiation field title (unique ID)
        title   = 'Unknown';
        % Beam type ('Unknown', 'Photon', 'Electron', 'Proton')
        bm_type = 'Unknown';
        % Beam energy (i.e. Unknown, Co60, 6MV, 4MeV, ...)
        bme     = 'Unknown';
        % Field shape ('Unknown', 'Rectangular', 'Circular', 'Irregular')
        fld_shp = 'Unknown';
        % Field size (i.e. Unknown, 4mm, 100x100 mm^2, ...)
        fld_sze = 'Unknown';

    endproperties;

% -----------------------------------------------------------------------------
%
% Public methods section
%
% -----------------------------------------------------------------------------
    methods (Access = public)

% -----------------------------------------------------------------------------
%
% Method 'IrradField':
%
% Use:
%       -- fld = IrradField()
%       -- fld = IrradField(..., "PROPERTY", VALUE, ...)
%       -- fld = IrradField(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function fld = IrradField(varargin)
            fname = 'IrradField';
            use_case_a = ' -- if = IrradField()';
            use_case_b = ' -- if = IrradField(..., "PROPERTY", VALUE, ...)';
            use_case_c = ' -- if = IrradField(other)';

            if(0 == nargin)
                % Default constructor invoked ---------------------------------

            elseif(1 == nargin)
                if(isa(varargin{1}, 'IrradField'))
                    % Copy constructor invoked
                    fld.title   = varargin{1}.title;
                    fld.bm_type = varargin{1}.bm_type;
                    fld.bme     = varargin{1}.bme;
                    fld.fld_shp = varargin{1}.fld_shp;
                    fld.fld_sze = varargin{1}.fld_sze;

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

            elseif(2 <= nargin && 10 >= nargin)
                % Regular constructor invoked ---------------------------------

                % Parse arguments
                [ ...
                    pos, ...
                    title, ...
                    bm_type, ...
                    bme, ...
                    fld_shp, ...
                    fld_sze ...
                    ] = parseparams( ...
                    varargin, ...
                    'Title', 'Unknown', ...
                    'BeamType', 'Unknown', ...
                    'BeamEnergy', 'Unknown', ...
                    'FieldShape', 'Unknown', ...
                    'FieldSize', 'Unknown' ...
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

                % Validate value supplied for the BeamType
                validatestring( ...
                    bm_type, ...
                    {'Unknown', 'Photon', 'Electron', 'Proton'}, ...
                    fname, ...
                    'BeamType' ...
                    );

                % Validate value supplied for the BeamEnergy
                if(~ischar(bme) || isempty(bme))
                    error('%s: BeamEnergy must be a non-empty string', fname);

                endif;

                % Validate value supplied for the FieldShape
                validatestring( ...
                    fld_shp, ...
                    {'Unknown', 'Rectangular', 'Circular', 'Irregular'}, ...
                    fname, ...
                    'FieldShape' ...
                    );

                % Validate value supplied for the FieldSize
                if(~ischar(fld_sze) || isempty(fld_sze))
                    error('%s: FieldSize must be a non-empty string', fname);

                endif;

                % Assign values to a new instance -----------------------------
                fld.title   = title;
                fld.bm_type = bm_type;
                fld.bme     = bme;
                fld.fld_shp = fld_shp;
                fld.fld_sze = fld_sze;

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
%       -- fld.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(fld)
            printf('\tIrradField(\n');
            printf('\t\tTitle:       %s,\n', fld.title);
            printf('\t\tBeam type:   %s,\n', fld.bm_type);
            printf('\t\tBeam energy: %s,\n', fld.bme);
            printf('\t\tField shape: %s,\n', fld.fld_shp);
            printf('\t\tField size:  %s\n', fld.fld_sze);
            printf('\t)\n');

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp_short':
%
% Use:
%       -- fld.disp_short()
%
% Description:
%          A convenience method used to display shorthand info about the
%          instances of the type IrradField.
%
% -----------------------------------------------------------------------------
        function disp_short(fld)
            printf( ...
                'IrradField(%s, %s, %s, %s, %s)', ...
                fld.title, ...
                fld.bm_type, ...
                fld.bme, ...
                fld.fld_shp, ...
                fld.fld_sze ...
                );

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'cellarray':
%
% Use:
%       -- cfld = fld.cellarry()
%
% Description:
%          Return field object structure as cell array.
%
% -----------------------------------------------------------------------------
        function cfld = cellarray(fld)
            cfld = {};
            cfld = {fld.title, fld.bm_type, fld.bme, fld.fld_shp, fld.fld_sze;};

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = fld.isequivalent(other)
%
% Description:
%          Return whether or not two IrradField instances are equivalent. Two
%          instances are equivalent if they have identical titles.
% -----------------------------------------------------------------------------
        function result = isequivalent(fld, other)
            fname = 'isequivalent';

            if(~isa(other, 'IrradField'))
                error( ...
                    '%s: other must be an instance of the "IrradField" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if(isequal(fld.title, other.title));
                result = true;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = fld.isequal(other)
%
% Description:
%          Return whether or not two 'IrradField' instances are equal. Two
%          instances are equal if all of their fields have identical values.
%
% -----------------------------------------------------------------------------
        function result = isequal(fld, other)
            fname = 'isequal';

            if(~isa(other, 'IrradField'))
                error( ...
                    '%s: other must be an instance of the "IrradField" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if( ...
                    isequal(fld.title, other.title) ...
                    && isequal(fld.bm_type, other.bm_type) ...
                    && isequal(fld.bme, other.bme) ...
                    && isequal(fld.fld_shp, other.fld_shp) ...
                    && isequal(fld.fld_sze, other.fld_sze) ...
                    )
                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
