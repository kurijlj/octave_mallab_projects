item_list_view_controller_version = '1.0';

source('./item_list_model.m');
source('./item_list_view.m');

% -----------------------------------------------------------------------------
%
% Function 'newItemListViewController':
%
% Use:
%       -- controller = newItemListViewController(item_list, parent_controller)
%
% Description:
% Create new 'Item List View' ui displaying item fields, and assign
% controller to it. If assigned 'parent controller' is a controller of a
% container holding the view, and handling size changed events. If no
% parent container is supplied 'Item List View Controller' will create a figure
% containing the view.
%
% Parent controller must be a structure containing at least following fields:
%       order;
%       layout;
%       ui_handles;
% where: order is integer valu (0 or 1) indicating the order of a parent
% controller. This data is used to determine proper invocation of the callback
% for the size changed event.'layout; is a structure containing 'padding_px',
% 'row_height_px', and 'btn_width_px' fields, and 'ui_handles' is a structure
% containing field 'item_view_container' with a handle to the view's container:
%
%
%        +===================+
%        | parent_controller |
%        +===================+
%        | order             |
%        +-------------------+
%        | layout            | -----+
%        +-------------------+      |
%        | ui_handles        | -+   |
%        +-------------------+  |   |
%                               |   |
%                               |   |  +================================+
%                               |   +->| layout                         |
%                               |      +================================+
%                               |      | padding_px                     |
%                               |      +--------------------------------+
%                               |      | column_width_px                |
%                               |      +--------------------------------+
%                               |      | row_height_px                  |
%                               |      +--------------------------------+
%                               |      | btn_width_px                   |
%                               |      +--------------------------------+
%                               |
%                               |
%                               |      +================================+
%                               +----->| ui_handles                     |
%                                      +================================+
%                                      | item_view_container (uihandle) |
%                                      +--------------------------------+
%
% -----------------------------------------------------------------------------
function controller = newItemListViewController(item_list, parent_controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemListViewController';
    use_case_a = ' -- controller = newItemListViewController(item_list)';
    use_case_b = ' -- controller = newItemListViewController(item_list, parent_controller)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin && 2 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    controller = struct();

    if(1 == nargin)
        % User did not supply parent controller and is running 'Item View' as
        % standalone GUI app. Create supporting data structures
        controller.parent = struct();

        % Define order of the parent. Since we are creating figure just for
        % showing this view we treat it as a 'first' order parent (value of
        % zero). All other containers we treat as 'higher' order parent (value
        % of 1).
        controller.parent.order = 0;

        % Define common layout parameters
        controller.parent.layout = struct();
        controller.parent.layout.padding_px = 6;
        controller.parent.layout.column_width_px = 128;
        controller.parent.layout.row_height_px = 24;
        controller.parent.layout.btn_width_px = 128;

        % Create figure and define it as parent to 'Item' view
        controller.parent.ui_handles = struct();
        controller.parent.ui_handles.item_view_container = figure( ...
            'name', 'Item List', ...
            'menubar', 'none' ...
            );

        % Initialize structure for storing app data
        controllers = struct();
        controllers.item_list_view = NaN;
        guidata(controller.parent.ui_handles.item_view_container, controllers);

    else
        % Check if parent controller is proper parent for the
        % 'Item List View' controller
        if(~isItemListViewParentControllerObject(controller))
            error( ...
                '%s:controller is not a proper parent controller', ...
                fname ...
                );

        endif;


        % User supplied a valid parent controller
        controller.parent = parent_controller;

    endif;

    controller.data = struct();
    controller.data.item_list = item_list;
    if(isempty(item_list))
        controller.data.selected_item = newItem('Empty', 'None');

    else
        controller.data.selected_item = item_list{1};

    endif;

    controller = newItemListView(controller);

    if(1 == nargin)
        % Define callbacks for events we handle
        set( ...
            controller.parent.ui_handles.item_view_container, ...
            'sizechangedfcn', @(src, evt)handleItemListViewSzChng(controller) ...
            );

    endif;

    controllers = guidata(controller.parent.ui_handles.item_view_container);
    controllers.item_list_view = controller;
    guidata(controller.parent.ui_handles.item_view_container, controllers);

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
            && isfield(obj.ui_handles, 'item_view_container') ...
            && ishandle(obj.ui_handles.item_view_container) ...
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
    set( ...
        controller.ui_handles.item_table, ...
        'Data', itemList2CellArray(controller.data.item_list) ...
        );
    if(isempty(item_list))
        controller.data.selected_item = newItem('Empty', 'None');

    else
        controller.data.selected_item = item_list{1};

    endif;

    if(0 == controller.parent.order)
        set( ...
            controller.parent.ui_handles.item_view_container, ...
            'sizechangedfcn', @(src, evt)handleItemListViewSzChng(controller) ...
            );

    endif;

    controllers = guidata(controller.parent.ui_handles.item_view_container);
    controllers.item_list_view = controller;
    guidata(controller.parent.ui_handles.item_view_container, controllers);

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
        controller.data.selected_item = newItem('Empty', 'None');

    else
        controller.data.selected_item = controller.data.item_list{item_index};

    endif;
    set(controller.ui_handles.item_title_field, 'value', item_index);

    if(0 == controller.parent.order)
        set( ...
            controller.parent.ui_handles.item_view_container, ...
            'sizechangedfcn', @(src, evt)handleItemListViewSzChng(controller) ...
            );

    endif;

    controllers = guidata(controller.parent.ui_handles.item_view_container);
    controllers.item_list_view = controller;
    guidata(controller.parent.ui_handles.item_view_container, controllers);

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
