item_edit_controller_version = '1.0';

source('./item_data_model.m');
source('./item_edit_view.m');

% -----------------------------------------------------------------------------
%
% Function 'newItemEditViewController':
%
% Use:
%       -- controller = newItemEditViewController(item, parent_controller)
%
% Description:
% Create new 'Item Edit View' ui displaying item fields, and assign controller
% to it. If assigned 'parent controller' is a controller of a container holding
% the 'Item Edit View', and handling size changed events. If no parent
% container is supplied 'Item Edit View Controller' will create a figure
% containing the view.
%
%
% Parent controller must be a structure containing at least following fields:
%       order;
%       layout;
%       ui_handles;
% where: order is integer valu (0 or 1) indicating the order of a parent
% controller. This data is used to determine proper invocation of the callback
% for the size changed event.'layout; is a structure containing 'padding_px',
% 'row_height_px', and 'btn_width_px' fields, and 'ui_handles' is a structure
% containing field 'item_edit_container' with a handle to the 'Item Edit'
% container:
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
%        | ui_callbacks      |  |   |
%        +-------------------+  |   |
%                               |   |
%                               |   |  +================================+
%                               |   +->| layout                         |
%                               |      +================================+
%                               |      | padding_px                     |
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
%                                      | item_edit_container (uihandle) |
%                                      +--------------------------------+
%
% -----------------------------------------------------------------------------
function controller = newItemEditViewController(item, parent_controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemEditController';
    use_case_a = ' -- controller = newItemEditController(item)';
    use_case_b = ' -- controller = newItemEditController(item, parent_controller)';

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
        controller.parent.layout.row_height_px = 24;
        controller.parent.layout.btn_width_px = 128;

        % Create figure and define it as parent to 'Item' view
        controller.parent.ui_handles = struct();
        controller.parent.ui_handles.item_edit_container = figure( ...
            'name', 'Item Edit', ...
            'menubar', 'none' ...
            );

    else
        % Check if parent controller has all the required fields and all
        % supplied data values are valid
        if(~isstruct(parent_controller))
            error('%s: parent_controller must be a data structure', fname);
        endif;
        if(~isfield(parent_controller, 'layout'))
            error('%s: layout field is missing in the parent_controller structure', fname);
        endif;
        if(~isfield(parent_controller, 'ui_handles'))
            error('%s: ui_handles field is missing in the parent_controller structure', fname);
        endif;
        if(~isstruct(parent_controller.layout))
            error('%s: layout must be a data structure', fname);
        endif;
        if(~isfield(parent_controller.layout, 'padding_px'))
            error('%s: padding_px field is missing in the layout structure', fname);
        endif;
        validateattributes( ...
            parent_controller.layout.padding_px, ...
            {'numeric'}, ...
            { ...
                'scalar', ...
                'integer', ...
                '>=', 0 ...
                }, ...
            fname, ...
            'padding_px' ...
            );
        if(~isfield(parent_controller.layout, 'row_height_px'))
            error('%s: row_height_px field is missing in the layout structure', fname);
        endif;
        validateattributes( ...
            parent_controller.layout.row_height_px, ...
            {'numeric'}, ...
            { ...
                'scalar', ...
                'integer', ...
                '>=', 0 ...
                }, ...
            fname, ...
            'row_height_px' ...
            );
        if(~isfield(parent_controller.layout, 'btn_width_px'))
            error('%s: btn_width_px field is missing in the layout structure', fname);
        endif;
        validateattributes( ...
            parent_controller.layout.btn_width_px, ...
            {'numeric'}, ...
            { ...
                'scalar', ...
                'integer', ...
                '>=', 0 ...
                }, ...
            fname, ...
            'btn_width_px' ...
            );
        if(~isstruct(parent_controller.ui_handles))
            error('%s: ui_handles must be a data structure', fname);
        endif;
        if(~isfield(parent_controller.ui_handles, 'item_edit_container'))
            error('%s: item_edit_container field is missing in the ui_handles structure', fname);
        endif;
        if(~ishandle(parent_controller.ui_handles.item_edit_container))
            error('%s: item_edit_container field must be a hendle to a graphics object', fname);
        endif;

        % User supplied a valid parent controller
        controller.parent = parent_controller;

    endif;

    controller.item = item;
    controller = newItemEditView(controller);

    if(1 == nargin)
        % Define callbacks for events we handle
        set( ...
            controller.parent.ui_handles.item_edit_container, ...
            'sizechangedfcn', @(src, evt)handleItemEditViewSzChng(controller) ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'isItemEditViewControllerObject':
%
% Use:
%       -- isItemEditViewControllerObject(obj)
%
% Description:
% Return true if passed object is a proper 'Item Edit View Controller'
% data sructure.
%
% -----------------------------------------------------------------------------
function result = isItemEditViewControllerObject(obj)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'isItemEditViewControllerObject';
    use_case = ' -- result = isItemEditViewControllerObject(obj)';

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
            && isfield(obj, 'item') ...
            && isItemDataStruct(obj.item_list)...
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
            && isstruct(obj.parent.layout) ...
            && isfield(obj.parent.layout, 'padding_px') ...
            && isscalar(obj.parent.layout.padding_px) ...
            && isfloat(obj.parent.layout.padding_px) ...
            && (0 < obj.parent.layout.padding_px) ...
            && isfield(obj.parent.layout, 'row_height_px') ...
            && isscalar(obj.parent.layout.row_height_px) ...
            && isfloat(obj.parent.layout.row_height_px) ...
            && (0 < obj.parent.layout.row_height_px) ...
            && isfield(obj.parent.layout, 'btn_width_px') ...
            && isscalar(obj.parent.layout.btn_width_px) ...
            && isfloat(obj.parent.layout.btn_width_px) ...
            && (0 < obj.parent.layout.btn_width_px) ...
            && isfield(obj.parent, 'ui_handles') ...
            && isstruct(obj.parent.ui_handles) ...
            && isfield(obj.parent.ui_handles, 'item_view_container') ...
            && ishandle(obj.parent.ui_handles.item_view_container) ...
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
% Function 'updateEditedItem':
%
% Use:
%       -- controller = updateEditedItem(controller)
%       -- controller = updateEditedItem(controller, item)
%
% Description:
% Update controller item to the values enetered by a user in the view or,
% set the view to the item supplied by the user.
%
% -----------------------------------------------------------------------------
function controller = updateEditedItem(controller, item)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'updateViewedItem';
    use_case_a = ' -- result = updateViewedItem(controller)';
    use_case_b = ' -- result = updateViewedItem(controller, item_list)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin && 2 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate controller argument
    if(~isItemViewControllerObject(controller))
        error( ...
            '%s:controller must be an instance of the Item Edit View Controller data structure', ...
            fname ...
            );

    endif;

    if(2 == nargin)
        % Validate item argument
        if(~isItemDataStruct(item_list))
            error( ...
                '%s:item must be an instance of the Item data structure', ...
                fname ...
                );

        endif;

    endif;

    if(1 == nargin)

        values = getEditViewFieldValues(controller);
        controller.item = newItem(values{1}, values{2});

    else

        controller.item = item;

    endif;

    if(0 == controller.parent.order)
        set( ...
            controller.parent.ui_handles.item_edit_container, ...
            'sizechangedfcn', @(src, evt)handleItemEditViewSzChng(controller) ...
            );

    endif;

    updateItemEditView(controller);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'handleItemEditViewSzChng':
%
% Use:
%       -- handleItemEditViewSzChng(controller)
%
% Description:
% Handle size changed events from the container. This function is to be called
% by the container callback to the 'size changed' event.
%
% -----------------------------------------------------------------------------
function handleItemEditViewSzChng(controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'updateViewedItem';
    use_case = ' -- result = updateViewedItem(controller, item_list)';

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
    if(~isItemViewControllerObject(controller))
        error( ...
            '%s:controller must be an instance of the Item Edit View Controller data structure', ...
            fname ...
            );

    endif;

    updateItemEditView(controller);

endfunction;
