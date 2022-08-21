% -----------------------------------------------------------------------------
%
% Class 'ItemList':
%
% Description:
%       TODO: Put class description here
%
% -----------------------------------------------------------------------------
classdef ItemList
    properties (Access = public)
        items = {};

    endproperties;

    methods
        function list = ItemList(varargin)
            fname = 'ItemList';
            use_case_a = ' -- list = ItemList()';
            use_case_b = ' -- list = ItemList(obj)';
            use_case_c = ' -- list = ItemList(...)';

            if(0 == nargin)
                % Default constructor invoked

            elseif(1 == nargin)
                if(isa(varargin{1}, 'ItemList'))
                    % Copy constructor invoked
                    list.items = varargin{1}.items;

                elseif(isa(varargin{1}, 'Item'))
                    % Construct item list out of one item
                    list.items = {varargin{1}};

                elseif(ischar(varargin{1}) && ~isempty(varargin{1}))
                    % Load item list from a database file

                    % Check if given file path poins to actual file
                    if(~isfile(varargin{1}))
                        % Database does not exist, print error message and return empty list
                        warning( ...
                            '%s: file "%s" does not exist\nUsing defaul values\n', ...
                            fname, ...
                            file_path ...
                            );

                        return;

                    endif;

                    % Load required packages
                    pkg load io;  % Required by 'csv2cell'

                    % Load database entries as cell array
                    entries = csv2cell(varargin{1});

                    % Unload loaded packages
                    pkg unload io;

                    % Populate the list
                    idx = 2;  % We skip column headers
                    while(size(entries, 1) >= idx)
                        item = Item(entries{idx, 1}, entries{idx, 2});
                        list = list.add(item);

                        idx = idx + 1;

                    endwhile;

                else
                    error( ...
                        'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
                        fname, ...
                        use_case_a, ...
                        use_case_b, ...
                        use_case_c ...
                        );

                endif;

            elseif(1 < nargin)
                % Regular constructor invoked
                idx = 1;
                while(nargin >= idx)
                    if(~isa(varargin{idx}, 'Item'))
                        error( ...
                            '%s: varargin{%d} must be an instance of the "Item" class', ...
                            fname, ...
                            idx ...
                            );

                    else
                        list = list.add(varargin{idx});

                    endif;

                    idx = idx + 1;

                endwhile;

            endif;

        endfunction;

        function disp(list)
            fname = 'disp';
            use_case_a = ' -- disp(list)';

            printf('ItemList(\n');
            idx = 1;
            while(numel(list.items) >= idx)
                printf( ...
                    '\tItem("%s\", "%s"), ...\n', ...
                    list.items{idx}.name, ...
                    list.items{idx}.value ...
                    );

                idx = idx + 1;

            endwhile;
            printf(')\n');

        endfunction;

        function [tf, idx] = ismember(list, item)
            fname = 'ismember';

            if(~isa(item, 'Item'))
                error( ...
                    '%s: item must be an instance of the "Item" class', ...
                    fname ...
                    );

            endif;

            [tf, idx] = ismember(item.name, list.names());

        endfunction;

        function name_list = names(list)
            name_list = {};
            idx = 1;
            while(numel(list.items) >= idx)
                name_list = {name_list{:}, list.items{idx}.name};

                idx = idx + 1;

            endwhile;

        endfunction;

        function list = add(list, item)
            fname = 'add';

            if(~isa(item, 'Item'))
                error( ...
                    '%s: item must be an instance of the "Item" class', ...
                    fname ...
                    );

            endif;

            [tf, idx] = list.ismember(item);
            if(tf)
                list.items{idx}.value = item.value;

            else
                list.items = {list.items{:}, item};

            endif;

        endfunction;

        function list = remove(list, idx)
            fname = 'remove';

            validateattributes( ...
                idx, ...
                {'numeric'}, ...
                { ...
                    '>=', 1, ...
                    '<=', list.numel(), ...
                    'integer', ...
                    'nonnan', ...
                    'scalar' ...
                    }, ...
                fname, ...
                'idx' ...
                );

            list.items = { ...
                list.items{1:idx - 1}, ...
                list.items{idx + 1:end} ...
                };

        endfunction;

        function n = numel(list)
            n = numel(list.items);

        endfunction;

        function item = at(list, idx)
            fname = 'at';

            validateattributes( ...
                idx, ...
                {'numeric'}, ...
                { ...
                    '>=', 1, ...
                    '<=', list.numel(), ...
                    'integer', ...
                    'nonnan', ...
                    'scalar' ...
                    }, ...
                fname, ...
                'idx' ...
                );

            item = list.items{idx};

        endfunction;

        function result = isequivalent(obj, list)
            fname = 'isequivalent';

            if(~isa(list, 'ItemList'))
                error( ...
                    '%s: list must be an instance of the "ItemList" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = isequal(sort(obj.names()), sort(list.names()));

        endfunction;

        function result = isequal(obj, list)
            fname = 'isequal';

            if(~isa(list, 'ItemList'))
                error( ...
                    '%s: list must be an instance of the "ItemList" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;

            if(obj.isequivalent(list))
                idx = 1;
                while(obj.numel() >= idx)
                    if(~obj.items{idx}.isequal(list.items{idx}))
                        return;

                    endif;

                    idx = idx + 1;

                endwhile;

                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
