item_list_view_version = '1.0';

source('./item_list_model.m');

% -----------------------------------------------------------------------------
%
% Function 'newItemListView':
%
% Use:
%       -- handle = newItemListView(controller)
%
% Description:
% Create an new 'Item List View' and assign it to the parent container.
%
% -----------------------------------------------------------------------------
function controller = newItemListView(controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemListView';
    use_case = ' -- result = newItemListView(controller)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Initialize struct to store GUI handles
    controller.ui_handles = struct();

    % Create 'Item List View' panel -------------------------------------------
    position = itemListViewElementsPosition(controller);
    controller.ui_handles.main_container = uipanel( ...
        'parent', controller.parent.ui_handles.item_list_view_container, ...
        'title', 'Item List', ...
        'position', position(1, :) ...
        );

    % Create items table ------------------------------------------------------
    controller.ui_handles.item_table = uitable( ...
        'parent', controller.ui_handles.main_container, ...
        'Data', itemList2CellArray(controller.data.item_list), ...
        'tooltipstring', 'Select row to select Item', ...
        'ColumnName', {'Title', 'Value'}, ...
        'CellSelectionCallback', @onItemListViewCellSelect, ...
        'ButtonDownFcn', @onBtnDwn, ...
        % 'ColumnEditable', true, ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'updateItemSelectView':
%
% Use:
%       -- updateItemSelectView(controller)
%
% Description:
% Update the view in response to the change of data or GUI elements
% repositioning due to size changed event. This function is meant to be called
% by the controller. Calling this function on its own can lead to undefined
% behavior.
%
% -----------------------------------------------------------------------------
function updateItemListView(controller)

    % Get GUI elements postions
    position = itemListViewElementsPosition(controller);

    set( ...
        controller.ui_handles.main_container, ...
        'position', position(1, :) ...
        );
    set( ...
        controller.ui_handles.item_table, ...
        'position', position(2, :) ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewElementsPosition':
%
% Use:
%       -- position = itemListViewElementsPosition(controller)
%
% Description:
% Calculate GUI elements position within set container.
%
% -----------------------------------------------------------------------------
function position = itemListViewElementsPosition(controller)

    % Define return value as matrix -------------------------------------------
    position = [];

    % Calculate relative extents ----------------------------------------------
    cexts = getpixelposition(controller.parent.ui_handles.item_list_view_container);
    horpadabs = controller.parent.layout.padding_px / cexts(3);
    verpadabs = controller.parent.layout.padding_px / cexts(4);
    btnwdtabs = controller.parent.layout.btn_width_px / cexts(3);
    clmwdtabs = controller.parent.layout.column_width_px / cexts(3);
    rowhghabs = controller.parent.layout.row_height_px / cexts(4);

    % Set padding for the main panel ------------------------------------------
    position = [ ...
        position; ...
        horpadabs, ...
        verpadabs, ...
        1.00 - 2*horpadabs, ...
        1.00 - 2*verpadabs; ...
        ];

    % Set table view position -------------------------------------------------
    position = [ ...
        position; ...
        horpadabs, ...
        verpadabs, ...
        1.00 - 2*horpadabs, ...
        1.00 - 2*verpadabs; ...
        ];

endfunction;

function onItemListViewCellSelect(x, y)
    controllers = guidata(gcbf());
    controller = controllers.item_list_view;
    idx = unique(y.Indices(:, 1));
    if(2 == size(y.Indices)(1) && 1 == numel(idx))
        controller.data.selected_item_idx = idx;
        controller.data.selected_item = controller.data.item_list{idx};

    else
        controller.data.selected_item_idx = 0;
        controller.data.selected_item = newItem('Empty', 'None');

    endif;

    controllers.item_list_view = controller;
    guidata(controller.parent.ui_handles.item_list_view_container, controllers);

endfunction;

function onBtnDwn(src, evt)
    display('Processing');
    display(src);
    display(evt);
endfunction;
