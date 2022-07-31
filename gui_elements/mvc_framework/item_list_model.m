item_list_model_version = '1.0';

source('./item_data_model.m');

% -----------------------------------------------------------------------------
%
% Function 'newItemList':
%
% Use:
%       -- newItemList(item1, item2, ...)
%
% Description:
% Generate a new Item data structure with given item_title and item_value
% values.
%
% -----------------------------------------------------------------------------
function list = newItemList(varargin)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemList';
    use_case = ' -- item = newFilm(item1, item2, item3, ...)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 > nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate user supplied arguments value
    idx = 1;
    while(nargin >= idx)
        if(~isItemDataStruct(varargin{idx}))
            error( ...
                '%s: varargin{%d} must be an instance of the Item data structure', ...
                fname, ...
                idx ...
                );

        endif;

        idx = idx + 1;

    endwhile;

    % Create and populate 'Item List' structure -------------------------------
    list = {};
    idx = 1;
    while(nargin >= idx)
        list = {list{:}, varargin{idx}};

        idx = idx + 1;

    endwhile;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'loadItemListFromFile':
%
% Use:
%       -- loadItemListFromFile(file_path)
%
% Description:
% Load list of 'Item' objects from a file designated with file_path.
%
% -----------------------------------------------------------------------------
function list = loadItemListFromFile(file_path)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'loadListFromFile';
    use_case = ' -- list = loadListFromFile(file_path)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate file_path parameter value
    if(~ischar(file_path) || isempty(file_path))
        error('%s: file_path must be a non-empty string containing the path to a file', fname);

    endif;

    % Initialize cell array for storin items ----------------------------------
    list = {};

    % Check if given file path poins to actual file ---------------------------
    if(~isfile(file_path))
        % Database does not exist, print error message and return empty list
        fprintf( ...
            stderr(), ...
            'warning: %s: file "%s" does not exist\nUsing defaul values\n', ...
            fname, ...
            file_path ...
            );
        return;

    endif;

    % Given file exist, check if it is actual 'Item' database file --
    % try
    %     checkItemDatabaseIntegrity(file_path);

    % catch err
    %     % Database integrity failed. Print error message and return empty list
    %     fprintf(stderr(), '%s: %s\n', fname, err.message);
    %     return;

    % end_try_catch;

    % Load database entries ---------------------------------------------------

    % Load required packages
    pkg load io;  % Required by 'csv2cell'

    % Load database entries as cell array
    db_entries = csv2cell(file_path);

    % Unload loaded packages
    pkg unload io;

    % Popuate 'Item List'
    idx = 2;  % We skip column headers
    while(size(db_entries, 1) >= idx)
        item = newItem(db_entries{idx, 1}, db_entries{idx, 2});
        list = {list{:}, item};

        idx = idx + 1;

    endwhile;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'isItemListObject':
%
% Use:
%       -- isItemListObject(obj)
%
% Description:
% Return true if passed object is a proper 'Item List' data sructure, i.e. is
% cell array of 'Item' objects.
%
% -----------------------------------------------------------------------------
function result = isItemListObject(obj)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'isItemListObject';
    use_case = ' -- result = isItemListObject(obj)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Initialize return value to default
    result = false;

    % Check if obj is a cell array
    if(~iscell(obj))
        return;

    endif;

    % Check if empty cell array
    if(isempty(obj))
        result = true; %  We accept empty cell arrays as empty 'Item List'
        return;

    endif;

    % We don't allow multidimensional 'Item' lists
    if(max(size(obj)) ~= numel(obj))
        return;

    endif;

    % Check if list entries are instances of 'List' data sructure
    idx = 1;
    while(numel(obj) >= idx)
        if(~isItemDataStruct(obj{idx}))
            return;

        endif;

        idx = idx + 1;

    endwhile;

    % If we got this far it must be an 'Item List' instance
    result = true;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'checkItemDatabaseIntegrity':
%
% Use:
%       -- checkItemDatabaseIntegrity(file_path)
%
% Description:
%       TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = checkItemDatabaseIntegrity(file_path)
    % TODO: Add function implementation here.

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'listItemTitles':
%
% Use:
%       -- title_list = listItemTitles(item_list)
%
% Description:
% Retrieve cell array of item titles of the passed item_list.
%
% -----------------------------------------------------------------------------
function title_list = listItemTitles(item_list)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'listItemTitles';
    use_case = ' -- title_list = listItemTitles(item_list)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate if item_list is a 'Item List' object
    if(~isItemListObject(item_list))
        error( ...
            '%s:item_list must be an instance of the Item List data structure', ...
            fname ...
            );

    endif;

    % Initialize title cell array
    title_list = {};

    if(~isempty(item_list))
        idx = 1;
        while(numel(item_list) >= idx)
            title_list = {title_list{:}, item_list{idx}.title};

            idx = idx + 1;

        endwhile;

    else
        % We are dealing with an empty list so return default value
        title_list = {title_list{:}, 'Empty'};

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemList2CellArray':
%
% Use:
%       -- item_cell_list = itemList2CellArray(item_list)
%
% Description:
% Retrieve item list as cell array of item fields.
%
% -----------------------------------------------------------------------------
function item_cell_list = itemList2CellArray(item_list)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemList2CellArray';
    use_case = ' -- title_list = itemList2CellArray(item_list)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate if item_list is a 'Item List' object
    if(~isItemListObject(item_list))
        error( ...
            '%s:item_list must be an instance of the Item List data structure', ...
            fname ...
            );

    endif;

    % Initialize title cell array
    item_cell_list = {};

    if(~isempty(item_list))
        item_cell_list = cell(numel(item_list), 2);
        idx = 1;
        while(numel(item_list) >= idx)
            item_cell_list{idx, 1} = item_list{idx}.title;
            item_cell_list{idx, 2} = item_list{idx}.value;

            idx = idx + 1;

        endwhile;

    else
        % We are dealing with an empty list so return default value
        item_cell_list = {'Empty', 'None';};

    endif;

endfunction;
