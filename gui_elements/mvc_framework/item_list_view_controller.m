item_list_view_controller_version = '1.0';

source('./app_data.m');
source('./item_list_model.m');
source('./item_list_view.m');

% -----------------------------------------------------------------------------
%
% Function 'newItemListView':
%
% Use:
%       -- handle = newItemListView(view_tag, item_list, hparent)
%
% Description:
%
% TODO: Add function description here
% -----------------------------------------------------------------------------
function handle = newItemListView(view_tag, item_list, hparent)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemListView';
    use_case_a = ' -- controller = newItemListView(view_tag, item_list)';
    use_case_b = ' -- controller = newItemListView(view_tag, item_list, hparent)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin && 3 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
            fname
            );
    endif;

    % Validate item_list argument
    if(~isItemListObject(item_list))
        error( ...
            '%s: item_list must be an instance of the Item List data structure', ...
            fname
            );

    endif;

    % Validate hparent argument
    if(2 == nargin && ~ishandle(hparent))
        error( ...
            '%s: hparent must be handle to a graphics object', ...
            fname
            );

    endif;

    % Initialize variable for storing all relevant app data
    app_data = NaN;

    if(1 == nargin)
        % We don't have handle to a parent UI container, so we need to run 'Item
        % List View' as a standalone application, within it's own figure and
        % with underlying app_data

        % Create figure and define it as parent to 'Item' view
        hparent = figure( ...
            'name', 'Item List', ...
            'menubar', 'none' ...
            );

        % Create new 'App Data' structure
        app_data = newAppData(hparent);

    else
        % We have a handle to the parent container. Get handle to the app
        % figure and validate underlying app_data structure
        app_data = guidata(gcf());

        % Check if object returned by guidata() is an actual 'App Data'
        % structure
        if(~isAppDataStructure(app_data))
            error( ...
                '%s: GUI data does not hold actual App Data structure', ...
                fname
                );

        endif;

    endif;

    view_data = struct());
    view_data.item_list = item_list;
    view_data.selected_item = 1;
    if(isempty(item_list))
        view_data.item_list = {newItem('Empty', 'None')};

    endif;
    handle = newItemListView(hparent, view_data);

    app_data.data = setfield(app_data.data, 'view_tag', view_data);
    app_data.ui_handles = setfield( ...
        app_data.ui_handles, ...
        'view_tag', ...
        handle ...
        );

    if(1 == nargin)
        % Define callbacks for events we handle
        set( ...
            hparent, ...
            'sizechangedfcn', @(src, evt)handleItemListViewSzChng(handle) ...
            );

    endif;

    guidata(app_data.ui_handles.hfigure, app_data);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'isItemListViewParentController':
%
% Use:
%       -- result = isItemListViewParentController(obj)
%
% Description:
% Return true if passed object is a proper 'Item List View Parent Controller'
% data sructure. See the documentation for the newItemListViewController().
%
% -----------------------------------------------------------------------------
function result = isItemListViewParentControllerObject(obj)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'isItemListViewParentController';
    use_case = ' -- result = isItemListViewParentController(obj)';

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

    if( ...
            isstruct(obj) ...
            && isfield(obj, 'order') ...
            && ( ...
                isequal(0, obj.order) ...
                || isequal(1, obj.order) ...
                ) ...
            && isfield(obj, 'layout') ...
            && isstruct(obj.layout) ...
            && isfield(obj.layout, 'padding_px') ...
            && isscalar(obj.layout.padding_px) ...
            && isfloat(obj.layout.padding_px) ...
            && (0 < obj.layout.padding_px) ...
            && isfield(obj.layout, 'column_width_px') ...
            && isscalar(obj.layout.column_width_px) ...
            && isfloat(obj.layout.column_width_px) ...
            && (0 < obj.layout.column_width_px) ...
            && isfield(obj.layout, 'row_height_px') ...
            && isscalar(obj.layout.row_height_px) ...
            && isfloat(obj.layout.row_height_px) ...
            && (0 < obj.layout.row_height_px) ...
            && isfield(obj.layout, 'btn_width_px') ...
            && isscalar(obj.layout.btn_width_px) ...
            && isfloat(obj.layout.btn_width_px) ...
            && (0 < obj.layout.btn_width_px) ...
            && isfield(obj, 'ui_handles') ...
            && isstruct(obj.ui_handles) ...
            && isfield(obj.ui_handles, 'item_list_view_container') ...
            && ishandle(obj.ui_handles.item_list_view_container) ...
            )

        result = true;

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'isItemListViewControllerObject':
%
% Use:
%       -- result = isItemListViewControllerObject(obj)
%
% Description:
% Return true if passed object is a proper 'Item Select View Controller' data
% sructure.
%
% -----------------------------------------------------------------------------
function result = isItemListViewControllerObject(obj)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'isItemListViewControllerObject';
    use_case = ' -- result = isItemListViewControllerObject(obj)';

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

    if( ...
            isstruct(obj) ...
            && isfield(obj, 'data') ...
            && isstruct(obj.data) ...
            && isfield(obj.data, 'item_list') ...
            && isItemListObject(obj.data.item_list)...
            && isfield(obj.data, 'selected_item') ...
            && isItemDataStruct(obj.data.selected_item)...
            && isfield(obj, 'ui_handles') ...
            && isstruct(obj.ui_handles) ...
            && isfield(obj, 'parent') ...
            && isstruct(obj.parent) ...
            && isfield(obj.parent, 'order') ...
            && ( ...
                isequal(0, obj.parent.order) ...
                || isequal(1, obj.parent.order) ...
                ) ...
            && isfield(obj.parent, 'layout') ...
            && isItemListViewParentControllerObject(obj.parent) ...
            )

        % Check obj.ui_handles fields
        idx = 1;
        flds = fieldnames(obj.ui_handles);
        while(numel(flds) >= idx)
            if(~ishandle(getfield(obj.ui_handles, flds{idx})))
                return;

            endif;

            idx = idx + 1;

        endwhile;

        result = true;

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'updateViewedList':
%
% Use:
%       -- controller = updateViewedList(controller, item_list)
%
% Description:
% Update an 'Item Select View' to the item_list supplied by the user.
%
% -----------------------------------------------------------------------------
function controller = updateViewedList(controller, item_list)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'updateViewedList';
    use_case = ' -- result = updateViewedList(item_list)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate controller argument
    if(~isItemListViewControllerObject(controller))
        error( ...
            '%s:controller must be an instance of the Item List View Controller data structure', ...
            fname ...
            );

    endif;

    % Validate item_list argument
    if(~isItemListObject(item_list))
        error( ...
            '%s:item_list must be an instance of the Item List data structure', ...
            fname ...
            );

    endif;

    controller.data.item_list = item_list;
    controller.data.selected_item_idx = 1;
    set( ...
        controller.ui_handles.item_table, ...
        'Data', itemList2CellArray(controller.data.item_list) ...
        );
    if(isempty(item_list))
        controller.data.selected_item = newItem('Empty', 'None');

    else
        controller.data.selected_item ...
            = item_list{controller.data.selected_item_idx};

    endif;

    if(0 == controller.parent.order)
        set( ...
            controller.parent.ui_handles.item_list_view_container, ...
            'sizechangedfcn', @(src, evt)handleItemListViewSzChng(controller) ...
            );

    endif;

    controllers = guidata(controller.parent.ui_handles.item_list_view_container);
    controllers.item_list_view = controller;
    guidata(controller.parent.ui_handles.item_list_view_container, controllers);

    updateItemListView(controller);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'updateSelectedItem':
%
% Use:
%       -- controller = updateSelectedItem(controller, item_index)
%
% Description:
% Update an controller item to the item selected by a user in the view or,
% set the view to the item with index supplied by the user.
%
% -----------------------------------------------------------------------------
function controller = updateSelectedItem(controller, item_index)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'updateSelectedItem';
    use_case_a = ' -- result = updateSelectedItem(controller)';
    use_case_b = ' -- result = updateSelectedItem(controller, item_index)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate controller argument
    if(~isItemSelectViewControllerObject(controller))
        error( ...
            '%s:controller must be an instance of the Item Select View Controller data structure', ...
            fname ...
            );

    endif;

    if(2 == nargin)
        % Validate item_index argument
        validateattributes( ...
            item_index, ...
            {'numeric'}, ...
            { ...
                '>=', 0, ...
                '<=', numel(controller.item_list), ...
                'finite', ...
                'integer', ...
                'nonempty', ...
                'nonnan', ...
                'scalar' ...
                }, ...
            fname, ...
            'x' ...
            );

    endif;

    if(isempty(item_list))
        controller.data.selected_item_idx = 1;
        controller.data.selected_item = newItem('Empty', 'None');

    else
        controller.data.selected_item_idx = item_index;
        controller.data.selected_item = controller.data.item_list{item_index};

    endif;
    set(controller.ui_handles.item_title_field, 'value', item_index);

    if(0 == controller.parent.order)
        set( ...
            controller.parent.ui_handles.item_list_view_container, ...
            'sizechangedfcn', @(src, evt)handleItemListViewSzChng(controller) ...
            );

    endif;

    controllers = guidata(controller.parent.ui_handles.item_list_view_container);
    controllers.item_list_view = controller;
    guidata(controller.parent.ui_handles.item_list_view_container, controllers);

    updateItemListView(controller);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'handleItemListViewSzChng':
%
% Use:
%       -- handleItemListViewSzChng(controller)
%
% Description:
% Handle size changed events from the container. This function is to be called
% by the container callback to the 'size changed' event.
%
% -----------------------------------------------------------------------------
function handleItemListViewSzChng(controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'handleItemListViewSzChng';
    use_case = ' -- result = handleItemListViewSzChng(controller)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate controller argument
    if(~isItemListViewControllerObject(controller))
        error( ...
            '%s:controller must be an instance of the Item View Controller data structure', ...
            fname ...
            );

    endif;

    updateItemListView(controller);

endfunction;
