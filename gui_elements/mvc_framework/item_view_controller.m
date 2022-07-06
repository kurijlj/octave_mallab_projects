display('Item View Controller Loaded');

source('./item_data_model.m');
source('./item_view.m');

% -----------------------------------------------------------------------------
%
% Function: newItemViewController
%
% Use:
%       -- controller = newItemViewController(item, parent_controller)
%
% Description: Create new 'Item View' ui displaying item fields, and assign
% controller to it. If assigned 'parent controller' is a controller of a
% container holding the 'Item View', and handling size changed events. If no
% parent container is supplaid 'Item View Controller' will create a figure
% containing the view.
%
% Parent controller must be a structure containing at least following fields:
%       layout;
%       ui_handles;
% where 'layout; is a structure containing 'padding_px', 'row_height_px', and
% 'btn_width_px' fields, and 'ui_handles' is a structure containing field
% 'main_container' with a handle to the 'Item View' container:
%
%
%        +===================+
%        | parent_controller |
%        +===================+
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
function controller = newItemViewController(item, parent_controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemViewController';
    use_case_a = ' -- controller = newItemViewController(item)';
    use_case_b = ' -- controller = newItemViewController(item, parent_controller)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin && 4 ~= nargin)
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

        % Define common layout parameters
        controller.parent.layout = struct();
        controller.parent.layout.padding_px = 6;
        controller.parent.layout.row_height_px = 24;
        controller.parent.layout.btn_width_px = 128;

        % Create figure and define it as parent to 'Item' view
        controller.parent.ui_handles = struct();
        controller.parent.ui_handles.main_container = figure( ...
            'name', 'Item View', ...
            'menubar', 'none' ...
            );

    else
        % Check if parent controller has all the required fields
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
        if(~isfield(parent_controller.layout, 'row_height_px'))
            error('%s: row_height_px field is missing in the layout structure', fname);
        endif;
        if(~isfield(parent_controller.layout, 'btn_width_px'))
            error('%s: btn_width_px field is missing in the layout structure', fname);
        endif;
        if(~isstruct(parent_controller.ui_handles))
            error('%s: ui_handles must be a data structure', fname);
        endif;
        if(~isfield(parent_controller.ui_handles, 'main_container'))
            error('%s: main_container field is missing in the ui_handles structure', fname);
        endif;

    endif;

    controller.item = item;
    controller = newItemView(controller);

    if(1 ==nargin)
        set( ...
            controller.parent.ui_handles.main_container, ...
            'sizechangedfcn', @(src, evt)handleItemViewSzChng(controller) ...
            );

    endif;

endfunction;

function controller = updateItem(controller, item)
    controller.item = item;
    updateItemView(controller);

endfunction;

function handleItemViewSzChng(controller)
    updateItemView(controller);

endfunction;
