% -----------------------------------------------------------------------------
%
% Class 'Item':
%
% Description:
%       Represents a simple database recordset where name is a uniq identifier
%       and value represents data stored in the recordset. Two items are
%       equivalent if they have common name (e.g. unique ID), whtether two items
%       are equal if they have common name and identical values.
%
% -----------------------------------------------------------------------------
classdef Item

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (Access = public)
        name  = NaN;
        value = NaN;

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
%       -- item = Item()
%       -- item = Item(name, value)
%       -- item = Item(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function item = Item(varargin)
            fname = 'Item';
            use_case_a = ' -- item = Item()';
            use_case_b = ' -- item = Item(name, value)';
            use_case_c = ' -- item = Item(other)';

            if(0 == nargin)
                % Default constructor invoked

            elseif(1 == nargin)
                % Copy constructor invoked
                if(isa(varargin{1}, 'Item'))
                    item.name = varargin{1}.name;
                    item.value = varargin{1}.value;

                else
                    error( ...
                        '%s: other must be an instance of the "Item" class', ...
                        fname ...
                        );

                endif;

            elseif(2 == nargin)
                % Regular constructor invoked

                % Validate name argument
                if(~ischar(varargin{1}) || isempty(varargin{1}))
                    error( ...
                        '%s: name must be a non-empty string', ...
                        fname ...
                        );

                endif;

                % Validate value argument
                if(~ischar(varargin{2}) || isempty(varargin{2}))
                    error( ...
                        '%s: value must be a non-empty string', ...
                        fname ...
                        );

                endif;

                % Assign argument values to item object
                item.name = varargin{1};
                item.value = varargin{2};

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
%       -- item.disp()
%
% Description:
%          The disp method is used by Octave whenever a class should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(item)
            printf('\tItem("%s\", "%s")\n', item.name, item.value);

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isnan':
%
% Use:
%       -- item.isnan()
%
% Description:
%          Check if given item is a NaN item. Item instance is NaN if name
%          field has value NaN. Value field is ignored.
%
% -----------------------------------------------------------------------------
        function result = isnan(item)
            result = false;
            if(isnan(item.name))
                result = true;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = item.isequivalent(other)
%
% Description:
%          Return whether or not two items are equivalent. Two items are
%          equivalent if they have common name (unique ID).
%
% -----------------------------------------------------------------------------
        function result = isequivalent(item, other)
            fname = 'isequivalent';

            if(~isa(item, 'Item'))
                error( ...
                    '%s: other must be an instance of the "Item" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if(isequal(item.name, other.name));
                result = true;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = item.isequal(other)
%
% Description:
%          Return whether or not two items are equal. Two items are equal if
%          they are equivalent and their values are identical.
%
% -----------------------------------------------------------------------------
        function result = isequal(item, other)
            fname = 'isequal';

            if(~isa(item, 'Item'))
                error( ...
                    '%s: item must be an instance of the "Item" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if( ...
                    item.isequivalent(other) ...
                    && isequal(item.value, other.value) ...
                    );
                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
