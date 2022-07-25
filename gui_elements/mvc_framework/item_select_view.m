item_select_view_version = '1.0';

% -----------------------------------------------------------------------------
%
% Function 'newItemSelectView':
%
% Use:
%       -- controller = newItemSelectView(controller)
%
% Description:
% Create an new 'Item Select View' and assign it to the parent container.
%
% -----------------------------------------------------------------------------
function controller = newItemSelectView(controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemSelectView';
    use_case = ' -- result = newItemSelectView(controller)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    controller.ui_handles = struct();

    % Create 'Item Select' view panel -----------------------------------------
    position = itemSelectViewElementsPosition(controller);
    controller.ui_handles.main_container = uipanel( ...
        'parent', controller.parent.ui_handles.item_view_container, ...
        'title', 'Item View', ...
        'position', position(1, :) ...
        );

    % Create fields view elements ---------------------------------------------

    % Set 'Title' view elemets ------------------------------------------------
    controller.ui_handles.item_title_label = uicontrol( ...
        'parent', controller.ui_handles.main_container, ...
        'style', 'text', ...
        'string', 'Select item', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(5, :) ...
        );
    controller.ui_handles.item_title_field = uicontrol( ...
        'parent', controller.ui_handles.main_container, ...
        'style', 'edit', ...
        'enable', 'inactive', ...
        'string', controller.item.title, ...
        'tooltipstring', 'Select item', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(4, :) ...
        );

    % Set 'Value' view elemets ------------------------------------------------
    controller.ui_handles.item_value_label = uicontrol( ...
        'parent', controller.ui_handles.main_container, ...
        'style', 'text', ...
        'string', 'Item Value', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(3, :) ...
        );
    controller.ui_handles.item_value_field = uicontrol( ...
        'parent', controller.ui_handles.main_container, ...
        'style', 'edit', ...
        'enable', 'inactive', ...
        'string', controller.item.value, ...
        'tooltipstring', 'Item value', ...
        'horizontalalignment', 'left', ...
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
function updateItemSelectView(controller)

    position = itemViewElementsPosition(controller);
    set( ...
        controller.ui_handles.main_container, ...
        'position', position(1, :) ...
        );
    set( ...
        controller.ui_handles.item_value_field, ...
        'position', position(2, :), ...
        'string', controller.item.value ...
        );
    set( ...
        controller.ui_handles.item_value_label, ...
        'position', position(3, :) ...
        );
    set( ...
        controller.ui_handles.item_title_field, ...
        'position', position(4, :), ...
        'string', controller.item.title ...
        );
    set( ...
        controller.ui_handles.item_title_label, ...
        'position', position(5, :) ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemSelectViewElementsPosition':
%
% Use:
%       -- position = itemSelectViewElementsPosition(controller)
%
% Description:
% Calculate GUI elements position within set container.
%
% -----------------------------------------------------------------------------
function position = itemSelectViewElementsPosition(controller)

    % Define return value as matrix -------------------------------------------
    position = [];

    % Calculate relative extents ----------------------------------------------
    cexts = getpixelposition(controller.parent.ui_handles.item_view_container);
    horpadabs = controller.parent.layout.padding_px / cexts(3);
    verpadabs = controller.parent.layout.padding_px / cexts(4);
    btnwdtabs = controller.parent.layout.btn_width_px / cexts(3);
    rowhghabs = controller.parent.layout.row_height_px / cexts(4);

    % Set padding for the main panel ------------------------------------------
    position = [ ...
        position; ...
        horpadabs, ...
        verpadabs, ...
        1.00 - 2*horpadabs, ...
        1.00 - 2*verpadabs; ...
        ];

    % Set fields position -----------------------------------------------------
    idx = 2;
    while(1 <= idx)
        position = [ ...
            position; ...
            horpadabs, ...
            1.00 - idx*verpadabs - (2*idx)*rowhghabs, ...
            1.00 - 2*horpadabs, ...
            rowhghabs; ...
            horpadabs, ...
            1.00 - idx*verpadabs - (2*idx - 1)*rowhghabs, ...
            1.00 - 2*horpadabs, ...
            rowhghabs; ...
            ];

        idx = idx - 1;

    endwhile;

endfunction;
