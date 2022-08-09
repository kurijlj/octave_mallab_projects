item_list_model_version = '1.0';

source('./item_data_model.m');

% -----------------------------------------------------------------------------
%
% Function 'itemListModelNewList':
%
% Use:
%       -- list = itemListModelNewList(item1, item2, ...)
%
% Description:
% Generate a new 'Item List' data structure with item1, item2, ... as list
% items.
%
% -----------------------------------------------------------------------------
function list = itemListModelNewList(varargin)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListModelNewList';
    use_case = ' -- list = itemListModelNewList(item1, item2, item3, ...)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 > nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate user supplied arguments value
    idx = 1;
    while(nargin >= idx)
        if(~itemDataModelIsItemObject(varargin{idx}))
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
        % Check if list already contains the item
        [tf, itidx] = itemListModelIsListMember(list, varargin{idx});

        if(tf)
            % Item already exists in the list. Update item's value
            list{itidx}.value = varargin{idx}.value;

        else
            % Item does not exist in the list. Append it to the end of the list
            list = {list{:}, varargin{idx}};

        endif;

        idx = idx + 1;

    endwhile;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListModelLoadFromFile':
%
% Use:
%       -- list = itemListModelLoadFromFile(file_path)
%
% Description:
% Load list of 'Item' objects from a file designated with file_path.
%
% -----------------------------------------------------------------------------
function list = itemListModelLoadFromFile(file_path)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListModelLoadFromFile';
    use_case = ' -- list = itemListModelLoadFromFile(file_path)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate file_path parameter value
    if(~ischar(file_path) || isempty(file_path))
        error( ...
            '%s: file_path must be a non-empty string containing the path to a file', ...
            fname ...
            );

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
    %     itemListModelCheckDBIntegrity(file_path);

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
        item = itemDataModelNewItem(db_entries{idx, 1}, db_entries{idx, 2});

        % Check if list already contains the item
        [tf, itidx] = itemListModelIsListMember(list, item);

        if(tf)
            % Item already exists in the list. Update item's value
            list{itidx}.value = item.value;

        else
            % Item does not exist in the list. Append it to the end of the list
            list = {list{:}, item};

        endif;

        idx = idx + 1;

    endwhile;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListModelIsItemListObj':
%
% Use:
%       -- result = itemListModelIsItemListObj(obj)
%
% Description:
% Return true if passed object is a proper 'Item List' data sructure, i.e. is
% cell array of 'Item' objects.
%
% -----------------------------------------------------------------------------
function result = itemListModelIsItemListObj(obj)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListModelIsItemListObj';
    use_case = ' -- result = itemListModelIsItemListObj(obj)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
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
        if(~itemDataModelIsItemObject(obj{idx}))
            return;

        endif;

        idx = idx + 1;

    endwhile;

    % Return result of validation ---------------------------------------------

    % If we got this far it must be an 'Item List' instance
    result = true;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListModelCheckDBIntegrity':
%
% Use:
%       -- itemListModelCheckDBIntegrity(file_path)
%
% Description:
%       TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = itemListModelCheckDBIntegrity(file_path)
    % TODO: Add function implementation here.

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListModelListTitles':
%
% Use:
%       -- title_list = itemListModelListTitles(item_list)
%
% Description:
% Retrieve cell array of item titles of the passed item_list.
%
% -----------------------------------------------------------------------------
function title_list = itemListModelListTitles(item_list)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListModelListTitles';
    use_case = ' -- title_list = itemListModelListTitles(item_list)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate if item_list is a 'Item List' object
    if(~itemListModelIsItemListObj(item_list))
        error( ...
            '%s: item_list must be an instance of the Item List data structure', ...
            fname ...
            );

    endif;

    % Traverse list and create cell array containing item titles --------------

    % Initialize title cell array to default value
    title_list = {};

    if(~isempty(item_list))
        idx = 1;
        while(numel(item_list) >= idx)
            title_list = {title_list{:}, item_list{idx}.title};

            idx = idx + 1;

        endwhile;

    endif;

    % We are dealing with an empty list so return default value

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListModel2CellArray':
%
% Use:
%       -- item_cell_list = itemListModel2CellArray(item_list)
%
% Description:
% Retrieve item list as cell array of item fields.
%
% -----------------------------------------------------------------------------
function item_cell_list = itemListModel2CellArray(item_list)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListModel2CellArray';
    use_case = ' -- title_list = itemListModel2CellArray(item_list)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate if item_list is a 'Item List' object
    if(~itemListModelIsItemListObj(item_list))
        error( ...
            '%s: item_list must be an instance of the Item List data structure', ...
            fname ...
            );

    endif;

    % Convert list entries to cell array --------------------------------------

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

% -----------------------------------------------------------------------------
%
% Function 'itemListModelAddItem':
%
% Use:
%       -- result_list = itemListModelAddItem(input_list, item)
%
% Description:
% Retrieve copy of input_list with item added to the end of the list.
%
% -----------------------------------------------------------------------------
function result_list = itemListModelAddItem(input_list, item)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListModelAddItem';
    use_case = ' -- result_list = itemListModelAddItem(input_list, item)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate if input_list is a 'Item List' object
    if(~itemListModelIsItemListObj(input_list))
        error( ...
            '%s: input_list must be an instance of the Item List data structure', ...
            fname ...
            );

    endif;

    % Validate item argument
    if(~itemDataModelIsItemObject(item))
        error( ...
            '%s: item must be an instance of the Item data structure', ...
            fname ...
            );

    endif;

    % Append new item to the list end -----------------------------------------
    result_list = {input_list{:}, item};

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListModelRemoveItem':
%
% Use:
%       -- result_list = itemListModelRemoveItem(input_list, idx)
%
% Description:
% Retrieve copy of in_list with item with index idx removed from the list.
%
% -----------------------------------------------------------------------------
function result_list = itemListModelRemoveItem(input_list, idx)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListModelRemoveItem';
    use_case = ' -- result_list = itemListModelRemoveItem(input_list, idx)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate if input_list is a 'Item List' object
    if(~itemListModelIsItemListObj(input_list))
        error( ...
            '%s: input_list must be an instance of the Item List data structure', ...
            fname ...
            );

    endif;

    % Validate idx argument
    if(0 > idx || numel(input_list) < idx)
        error( ...
            '%s: input_list(%d): out of bound %d (dimensions are 1x%d)', ...
            fname, ...
            idx, ...
            numel(input_list), ...
            numel(input_list) ...
            );

    endif;

    % Remove item from the list -----------------------------------------------
    result_list = {input_list{1:idx - 1}, input_list{idx + 1:end}};

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListModelIsListMember':
%
% Use:proton%20business%20validator
%       -- TF = itemListModelIsListMember(input_list, item)
%       -- [TF, S_IDX] = itemListModelIsListMember(input_list, item)
%
% Description:
% Return a logical value which is true (1) if the item is found in input_list
% and false (0) if it is not.
%
% If a second output argument is requested then the index into input_list of
% item is also returned.
%
% -----------------------------------------------------------------------------
function [TF, S_IDX] = itemListModelIsListMember(input_list, item)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListModelIsListMember';
    use_case_a = ' -- TF = itemListModelIsListMember(input_list, item)';
    use_case_b = ' -- [TF, S_IDX] = itemListModelIsListMember(input_list, item)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate if input_list is a 'Item List' object
    if(~itemListModelIsItemListObj(input_list))
        error( ...
            '%s: input_list must be an instance of the Item List data structure', ...
            fname ...
            );

    endif;

    % Validate item argument
    if(~itemDataModelIsItemObject(item))
        error( ...
            '%s: item must be an instance of the Item data structure', ...
            fname ...
            );

    endif;

    % Search list for the given item ------------------------------------------ 
    titles = itemListModelListTitles(input_list);
    [TF, S_IDX] = ismember(item.title, titles);

endfunction;
