item_edit_controller_version = '1.0';

source('./item_data_model.m');
source('./item_edit.m');

% -----------------------------------------------------------------------------
%
% Function: newItemEditController
%
% Use:
%       -- controller = newItemEditController(item, parent_controller)
%
% Description:
% Create new 'Item Edit' ui displaying item fields, and assign controller to it.
% If assigned 'parent controller' is a controller of a container holding the
% 'Item View', and handling size changed events. If no parent container is
% supplied 'Item View Controller' will create a figure containing the view.
%
% Parent controller must be a structure containing at least following fields:
%       order;
%       layout;
%       ui_handles;
% where: order is integer valu (0 or 1) indicating the order of a parent
% controller. This data is used to determine proper invocation of the callback
% for the size changed event.'layout; is a structure containing 'padding_px',
% 'row_height_px', and 'btn_width_px' fields, and 'ui_handles' is a structure
% containing field 'main_container' with a handle to the 'Item View' container:
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
%                               |   |  +===========================+
%                               |   +->| layout                    |
%                               |      +===========================+
%                               |      | padding_px                |
%                               |      +---------------------------+
%                               |      | row_height_px             |
%                               |      +---------------------------+
%                               |      | btn_width_px              |
%                               |      +---------------------------+
%                               |
%                               |
%                               |      +===========================+
%                               +----->| ui_handles                |
%                                      +===========================+
%                                      | main_container (uihandle) |
%                                      +---------------------------+
%
%
% -----------------------------------------------------------------------------
function controller = newItemEditController(item, parent_controller)

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
        controller.parent.ui_handles.main_container = figure( ...
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
        if(~isfield(parent_controller.ui_handles, 'main_container'))
            error('%s: main_container field is missing in the ui_handles structure', fname);
        endif;
        if(~ishandle(parent_controller.ui_handles.main_container))
            error('%s: main_container field must be a hendle to a graphics object', fname);
        endif;

        % User supplied a valid parent controller
        controller.parent = parent_controller;

    endif;

    controller.item = item;
    controller = newItemEdit(controller);

    if(1 == nargin)
        set( ...
            controller.parent.ui_handles.main_container, ...
            'sizechangedfcn', @(src, evt)handleItemEditSzChng(controller) ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditUpdateItem':
%
% Use:
%       -- controller = itemEditUpdateItem(controller, item)
%
% Description:
% Update an 'Item Edit' to the item supplied by user.
%
% -----------------------------------------------------------------------------
function controller = updateEditItem(controller, item)

    if(1 == nargin)

        values = getEditFieldValues(controller);
        controller.item = newItem(values{1}, values{2});

    else

        controller.item = item;

    endif;

    if(0 == controller.parent.order)
        set( ...
            controller.parent.ui_handles.main_container, ...
            'sizechangedfcn', @(src, evt)handleItemEditSzChng(controller) ...
            );

    endif;

    updateEditView(controller);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'handleItemEditSzChng':
%
% Use:
%       -- handleItemEditSzChng(controller)
%
% Description:
% Handle size changed events from the container. This function is to be called
% by the container callback to the 'size changed' event.
%
% -----------------------------------------------------------------------------
function handleItemEditSzChng(controller)

    updateItemEdit(controller);

endfunction;
