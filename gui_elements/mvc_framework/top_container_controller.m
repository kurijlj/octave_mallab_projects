top_container_controller_version = '1.0';

source('./top_container_view.m');
source('./item_view_controller.m');
source('./item_edit_controller.m');
source('./control_panel_controller.m');

% -----------------------------------------------------------------------------
%
% Function: newTopContainerController
%
% Use:
%       -- newTopContainerController()
%
% Description:
% Create new 'Top Container View' ui displaying various item views and assign a
% controller to it.
%
% -----------------------------------------------------------------------------
function newTopContainerController()

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newTopContainerController';
    use_case = ' -- controller = newTopContainerController()';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(0 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    controller = struct();

    % Define 'Top Container' as higher order parent
    controller.order = 1;

    % Define common layout parameters
    controller.layout = struct();
    controller.layout.padding_px = 6;
    controller.layout.row_height_px = 24;
    controller.layout.btn_width_px = 128;
    controller.layout.btn_height_px = 32;

    % Create figure and define it as parent to 'Item' view
    controller.ui_handles = struct();
    controller.ui_handles.main_container = figure( ...
        'name', 'MVC Framework Test', ...
        'menubar', 'none' ...
        );

    controller = newTopContainerView(controller);
    controller.sub_contollers = struct();
    controller.sub_controllers.item_view = ...
        newItemViewController(newItem('Item #1', 'Value #1'), controller);
    controller.sub_controllers.item_edit = ...
        newItemEditController(newItem('Item #2', 'Value #2'), controller);
    controller.sub_controllers.control_panel = ...
        newControlPanelController(controller);

    % Define callbacks for events we handle
    set( ...
        controller.ui_handles.main_container, ...
        'sizechangedfcn', @(src, evt)handleTopContainerViewSzChng(controller.ui_handles.main_container) ...
        );
    set( ...
        controller.sub_controllers.control_panel.ui_handles.accept_button, ...
        'callback', @(src, evt)handleTopContainerPushAccept(controller.ui_handles.main_container) ...
        );
    set( ...
        controller.sub_controllers.control_panel.ui_handles.cancel_button, ...
        'callback', @(src, evt)handleTopContainerPushCancel(controller.ui_handles.main_container) ...
        );

    % Attach controller to figure data
    guidata(controller.ui_handles.main_container, controller);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'handleTopContainerViewSzChng':
%
% Use:
%       -- handleTopContainerViewSzChng(main_container)
%
% Description:
% Handle size changed events. This function is to be called by the container
% callback to the 'size changed' event.
%
% -----------------------------------------------------------------------------
function handleTopContainerViewSzChng(main_container)

    controller = guidata(main_container);
    updateTopContainerView(controller);
    handleItemViewSzChng(controller.sub_controllers.item_view);
    handleItemEditViewSzChng(controller.sub_controllers.item_edit);
    handleControlPanelViewSzChng(controller.sub_controllers.control_panel);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'handleTopContainerPushAccept':
%
% Use:
%       -- handleTopContainerPushAccept(main_container)
%
% Description:
% Handle push 'Accept' button events. This function is to be called by the
% container callback to the puch 'Accept' button event.
%
% -----------------------------------------------------------------------------
function handleTopContainerPushAccept(main_container)

    controller = guidata(main_container);
    controller.sub_controllers.item_edit = ...
        updateEditedItem(controller.sub_controllers.item_edit);
    controller.sub_controllers.item_view = ...
        updateViewedItem( ...
            controller.sub_controllers.item_view, ...
            controller.sub_controllers.item_edit.item ...
            );
    guidata(main_container, controller);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'handleTopContainerPushCancel':
%
% Use:
%       -- handleTopContainerPushCancel(main_container)
%
% Description:
% Handle push 'Cancel' button events. This function is to be called by the
% container callback to the puch 'Cancel' button event.
%
% -----------------------------------------------------------------------------
function handleTopContainerPushCancel(main_container)

    handleControlPanelPushCancel(main_container);

endfunction;
