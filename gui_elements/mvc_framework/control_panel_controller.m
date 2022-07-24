control_panel_controller_version = '1.0';

source('./control_panel_view.m');

% -----------------------------------------------------------------------------
%
% Function: newControlPanelController
%
% Use:
%       -- controller = newControlPanelController(parent_controller)
%
% Description:
% Create new 'Control Panel View' ui displaying control buttons, and assign
% controller to it. If assigned 'parent controller' is a controller of a
% container holding the 'Control Panel View', and handling size changed events.
% If no parent container is supplied 'Control Panel Controller' will create a
% figure containing the view.
%
% Parent controller must be a structure containing at least following fields:
%       order;
%       layout;
%       ui_handles;
% where: order is integer valu (0 or 1) indicating the order of a parent
% controller. This data is used to determine proper invocation of the callback
% for the size changed event.'layout; is a structure containing 'padding_px',
% 'row_height_px', and 'btn_width_px' fields, and 'ui_handles' is a structure
% containing field 'control_panel_container' with a handle to the 'Control Panel'
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
%                               |   |  +====================================+
%                               |   +->| layout                             |
%                               |      +====================================+
%                               |      | padding_px                         |
%                               |      +------------------------------------+
%                               |      | row_height_px                      |
%                               |      +------------------------------------+
%                               |      | btn_width_px                       |
%                               |      +------------------------------------+
%                               |
%                               |
%                               |      +====================================+
%                               +----->| ui_handles                         |
%                                      +====================================+
%                                      | control_panel_container (uihandle) |
%                                      +------------------------------------+
%
% -----------------------------------------------------------------------------
function controller = newControlPanelController(parent_controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newControlPanelController';
    use_case = ' -- controller = newControlPanelController(parent_controller)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(0 ~= nargin && 1 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    controller = struct();

    if(0 == nargin)
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
        controller.parent.layout.btn_height_px = 32;

        % Create figure and define it as parent to 'Item' view
        controller.parent.ui_handles = struct();
        controller.parent.ui_handles.control_panel_container = figure( ...
            'name', 'Control Panel', ...
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
        if(~isfield(parent_controller.ui_handles, 'control_panel_container'))
            error('%s: control_panel_container field is missing in the ui_handles structure', fname);
        endif;
        if(~ishandle(parent_controller.ui_handles.control_panel_container))
            error('%s: control_panel_container field must be a hendle to a graphics object', fname);
        endif;

        % User supplied a valid parent controller
        controller.parent = parent_controller;

    endif;

    controller = newControlPanelView(controller);

    if(0 == nargin)
        % Define callbacks for events we handle
        set( ...
            controller.parent.ui_handles.control_panel_container, ...
            'sizechangedfcn', @(src, evt)handleControlPanelViewSzChng(controller) ...
            );
        set( ...
            controller.ui_handles.cancel_button, ...
            'callback', @(src, evt)handleControlPanelPushAccept(controller) ...
            );
        set( ...
            controller.ui_handles.accept_button, ...
            'callback', @(src, evt)handleControlPanelPushCancel(controller) ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'handleControlPanelViewSzChng':
%
% Use:
%       -- handleControlPanelViewSzChng(controller)
%
% Description:
% Handle size changed events from the container. This function is to be called
% by the container callback to the 'size changed' event.
%
% -----------------------------------------------------------------------------
function handleControlPanelViewSzChng(controller)

    updateControlPanelView(controller);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'handleControlPanelPushAccept':
%
% Use:
%       -- handleControlPanelPushAccept(controller)
%
% Description:
% Handle push 'Accept' button event from the container. This function is to be
% called by the container callback to the puch 'Accept' button event.
%
% -----------------------------------------------------------------------------
function handleControlPanelPushAccept(controller)

    delete(gcbf());

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'handleControlPanelPushCancel':
%
% Use:
%       -- handleControlPanelPushCancel(controller)
%
% Description:
% Handle push 'Cancel' button event from the container. This function is to be
% called by the container callback to the puch 'Cancel' button event.
%
% -----------------------------------------------------------------------------
function handleControlPanelPushCancel(controller)

    delete(gcbf());

endfunction;
