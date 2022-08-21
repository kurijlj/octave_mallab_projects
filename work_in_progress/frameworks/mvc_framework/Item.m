% -----------------------------------------------------------------------------
%
% Class 'Item':
%
% Description:
%       TODO: Put class description here
%
% -----------------------------------------------------------------------------
classdef Item
    properties (Access = public)
        name  = 'Item #A';
        value = 'A';

    endproperties;

    methods
        function item = Item(varargin)
            fname = 'Item';
            use_case_a = ' -- item = Item()';
            use_case_b = ' -- item = Item(obj)';
            use_case_c = ' -- item = Item(name, value)';

            if(0 == nargin)
                % Default constructor invoked

            elseif(1 == nargin)
                % Copy constructor invoked
                if(isa(varargin{1}, 'Item'))
                    item.name = varargin{1}.name;
                    item.value = varargin{1}.value;

                else
                    error( ...
                        '%s: obj must be an instance of the "Item" class', ...
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

        function disp(item)
            printf('Item("%s\", "%s")\n', item.name, item.value);

        endfunction;

        function result = isequivalent(obj, item)
            fname = 'isequivalent';

            if(~isa(item, 'Item'))
                error( ...
                    '%s: item must be an instance of the "Item" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;
            if(isequal(obj.name, item.name));
                result = true;

            endif;

        endfunction;

        function result = isequal(obj, item)
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
                    isequal(obj.name, item.name) ...
                    && isequal(obj.value, item.value) ...
                    );
                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
