% -----------------------------------------------------------------------------
%
% Class 'ItemList':
%
% Description:
%       Represents an unordered set of 'Item' instances. Two lists are
%       equivalent if they have same number of items with same names. Two lists
%       are equal if they are equivalent and their items have same values too.
%
% -----------------------------------------------------------------------------
classdef ItemList

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (Access = public)
        items = {};

    endproperties;

% -----------------------------------------------------------------------------
%
% Public methods section
%
% -----------------------------------------------------------------------------
    methods (Access = public)

% -----------------------------------------------------------------------------
%
% Method 'ItemList':
%
% Use:
%       -- list = ItemList()
%       -- list = ItemList(item1, item2, ...)
%       -- list = ItemList("DB_FILE_PATH")
%       -- list_copy = ItemList(list)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function list = ItemList(varargin)
            fname = 'ItemList';
            use_case_a = ' -- list = ItemList()';
            use_case_b = ' -- list = ItemList(item1, item2, ...)';
            use_case_b = ' -- list = ItemList("DB_FILE_PATH")';
            use_case_c = ' -- list_copy = ItemList(list)';

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
                        'Invalid call to %s. Correct usage is:\n%s\n%s\n%s\n%s', ...
                        fname, ...
                        use_case_a, ...
                        use_case_b, ...
                        use_case_c, ...
                        use_case_d ...
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

% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- list.disp()
%
% Description:
%          The disp method is used by Octave whenever a class should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(list)
            printf('ItemList(\n');
            idx = 1;
            while(list.numel() >= idx)
                printf( ...
                    '\tItem("%s\", "%s"), ...\n', ...
                    list.items{idx}.name, ...
                    list.items{idx}.value ...
                    );

                idx = idx + 1;

            endwhile;
            printf(')\n');

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'ismember':
%
% Use:
%       -- result = list.ismember(item)
%
% Description:
%          Return 'true' if item with name item.name exists in the list.
%          Otherwise return 'false'.
%
% -----------------------------------------------------------------------------
        function result = ismember(list, item)
            fname = 'ismember';

            if(~isa(item, 'Item'))
                error( ...
                    '%s: item must be an instance of the "Item" class', ...
                    fname ...
                    );

            endif;

            [result, idx] = ismember(item.name, list.names());

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'index':
%
% Use:
%       -- idx = list.index(item)
%
% Description:
%          Search for item with name item.name in the list. If item exists in
%          the list return item index, otherwise return 0.
%
% -----------------------------------------------------------------------------
        function idx = index(list, item)
            fname = 'index';

            if(~isa(item, 'Item'))
                error( ...
                    '%s: item must be an instance of the "Item" class', ...
                    fname ...
                    );

            endif;

            [tf, idx] = ismember(item.name, list.names());

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'names':
%
% Use:
%       -- name_list = list.names()
%
% Description:
%          Return list of name values of all the items in the list.
%
% -----------------------------------------------------------------------------
        function name_list = names(list)
            name_list = {};
            idx = 1;
            while(numel(list.items) >= idx)
                name_list = {name_list{:}, list.items{idx}.name};

                idx = idx + 1;

            endwhile;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'add':
%
% Use:
%       -- list = list.add(item)
%
% Description:
%          Append item to teh end of the list. If ietm with given item.name
%          already exists in the list update item value to the item.value of the
%          given item.
%
% -----------------------------------------------------------------------------
        function list = add(list, item)
            fname = 'add';

            if(~isa(item, 'Item'))
                error( ...
                    '%s: item must be an instance of the "Item" class', ...
                    fname ...
                    );

            endif;

            if(list.ismember(item))
                list.items{idx}.value = item.value;

            else
                list.items = {list.items{:}, item};

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'remove':
%
% Use:
%       -- list = list.remove(idx)
%
% Description:
%          Remove item with the given index idx from the list.
%
% -----------------------------------------------------------------------------
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

% -----------------------------------------------------------------------------
%
% Method 'numel':
%
% Use:
%       -- n = list.numel()
%
% Description:
%          Return number of items (elements) in the list.
%
% -----------------------------------------------------------------------------
        function n = numel(list)
            n = numel(list.items);

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isempty':
%
% Use:
%       -- result = list.isempty()
%
% Description:
%          Return whether the list contains any item or not.
%
% -----------------------------------------------------------------------------
        function result = isempty(list)
            result = isempty(list.items);

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'at':
%
% Use:
%       -- item = list.at(idx)
%
% Description:
%          Return item with index idx from the list.
%
% -----------------------------------------------------------------------------
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

% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = list.isequivalent(other)
%
% Description:
%          Return whether or not two lists are equivalent. Two list are
%          equivalent if they have same number of items with same names.
%
% -----------------------------------------------------------------------------
        function result = isequivalent(list, other)
            fname = 'isequivalent';

            if(~isa(other, 'ItemList'))
                error( ...
                    '%s: other must be an instance of the "ItemList" class', ...
                    fname ...
                    );

            endif;

            result = isequal(sort(list.names()), sort(other.names()));

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = list.isequal(other)
%
% Description:
%          Return whether or not two lists are equal. Two list are equal if
%          they are equivalent and their items have same values too.
%
% -----------------------------------------------------------------------------
        function result = isequal(list, other)
            fname = 'isequal';

            if(~isa(other, 'ItemList'))
                error( ...
                    '%s: other must be an instance of the "ItemList" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;

            if(list.isequivalent(other))
                idx = 1;
                while(list.numel() >= idx)
                    if(~list.items{idx}.isequal(other.items{idx}))
                        return;

                    endif;

                    idx = idx + 1;

                endwhile;

                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
