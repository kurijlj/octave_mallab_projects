item_list_selection_model_version = '1.0';

source('./item_list_model.m');

% -----------------------------------------------------------------------------
%
% Function 'itemListSelectionModelNewSelection':
%
% Use:
%       -- list_selection = itemListSelectionModelNewSelection(item_list)
%       -- list_selection = itemListSelectionModelNewSelection(item_list, idx)
%
% Description:
% Generate a new 'Item List Selection' data structure with given item_list and
% idx representing the index of the selected item in the list.
%
% -----------------------------------------------------------------------------
function list_selection = itemListSelectionModelNewSelection(item_list, idx=0)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListSelectionModelNewSelection';
    use_case_a = ' -- list_selection = itemListSelectionModelNewSelection(item_list)';
    use_case_b = ' -- list_selection = itemListSelectionModelNewSelection(item_list, idx)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin && 2 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate if item_list is a 'Item List' object
    if(~itemListModelIsItemListObj(item_list))
        error( ...
            '%s: item_list must be an instance of the Item List data structure', ...
            fname ...
            );

    endif;

    % Validate selection index. We allow idx to be yero because it indicates
    % that nothing is selected.
    if(numel(item_list) < idx)
        error( ...
            '%s: item_list(%d): out of bound %d (dimensions are 1x%d)', ...
            fname, ...
            idx, ...
            numel(item_list), ...
            numel(item_list) ...
            );

    endif;

    % Create and populate 'Item List Selection' structure ---------------------
    list_selection = struct();
    list_selection.item_list = item_list;
    list_selection.selected_item = idx;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListSelectionModelIsSelectionObj':
%
% Use:
%       -- itemListSelectionModelIsSelectionObj(obj)
%
% Description:
% Return true if passed object is a proper 'Item List Selection' data sructure,
% i.e. is cell array of 'Item' objects and holds index of selected item.
%
% -----------------------------------------------------------------------------
function result = itemListSelectionModelIsSelectionObj(obj)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListSelectionModelIsSelectionObj';
    use_case = ' -- result = itemListSelectionModelIsSelectionObj(obj)';

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

    % Check validity of all fields
    if( ...
            isstruct(obj) ...
            && isfield(obj, 'item_list') ...
            && itemListModelIsItemListObj(obj.item_list) ...
            && isfield(obj, 'selected_item') ...
            && isfloat(obj.selected_item) ...
            && (0 <= obj.selected_item) ...
            )

        % Evrything is as should be, set return value to true
        result = true;

    endif;

endfunction;

