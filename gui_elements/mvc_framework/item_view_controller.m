display('Item View Controller Loaded');

source('./item_data_model.m');
source('./item_view.m');

function controller = newItemViewController(item, parent_controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemViewController';
    use_case_a = ' -- controller = newItemViewController(item)';
    use_case_b = ' -- controller = newItemViewController(item, parent_controller)';

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
