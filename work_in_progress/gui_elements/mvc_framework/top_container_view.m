top_container_view_version = '1.0';

% -----------------------------------------------------------------------------
%
% Function 'newTopContainerView':
%
% Use:
%       -- controller = newTopContainerView(controller)
%
% Description:
% Create the new 'MVC Framework Test' figure and assign a controller to it.
%
% -----------------------------------------------------------------------------
function controller = newTopContainerView(controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newTopContainerView';
    use_case = ' -- result = newTopContainerView(controller)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;


    % Create top panels -------------------------------------------------------
    position = topContainerViewElementsPosition(controller);

    % Create left panel
    controller.ui_handles.item_view_container = uipanel( ...
        'parent', controller.ui_handles.main_container, ...
        'bordertype', 'none',
        'position', position(2, :) ...
        );

    % Create right panel
    controller.ui_handles.item_edit_container = uipanel( ...
        'parent', controller.ui_handles.main_container, ...
        'bordertype', 'none',
        'position', position(3, :) ...
        );

    % Create bottom panel
    controller.ui_handles.control_panel_container = uipanel( ...
        'parent', controller.ui_handles.main_container, ...
        'bordertype', 'none',
        'position', position(1, :) ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'updateTopContainerView':
%
% Use:
%       -- updateTopContainerView(controller)
%
% Description:
% Update the view in response to the change of data or GUI elements
% repositioning due to size changed event. This function is meant to be called
% by the controller. Calling this function on its own can lead to undefined
% behavior.
%
% -----------------------------------------------------------------------------
function updateTopContainerView(controller)

    position = topContainerViewElementsPosition(controller);
    set( ...
        controller.ui_handles.control_panel_container, ...
        'position', position(1, :) ...
        );
    set( ...
        controller.ui_handles.item_view_container, ...
        'position', position(2, :) ...
        );
    set( ...
        controller.ui_handles.item_edit_container, ...
        'position', position(3, :) ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'topContainerViewElementsPosition':
%
% Use:
%       -- position = topContainerViewElementsPosition(controller)
%
% Description:
% Calculate GUI elements position within set container.
%
% -----------------------------------------------------------------------------
function position = topContainerViewElementsPosition(controller)

    % Define return value as matrix -------------------------------------------
    position = [];

    % Calculate relative extents ----------------------------------------------
    cexts = getpixelposition(controller.ui_handles.main_container);
    horpadabs = controller.layout.padding_px / cexts(3);
    verpadabs = controller.layout.padding_px / cexts(4);
    btnwdtabs = controller.layout.btn_width_px / cexts(3);
    rowhghabs = controller.layout.row_height_px / cexts(4);

    % Set top-panel positions -------------------------------------------------

    % Bottom panel position
    position = [ ...
        position; ...
        horpadabs, ...
        verpadabs, ...
        1.00 - 2*horpadabs, ...
        (1.00 - 3*verpadabs)*0.25; ...
        ];

    % Left panel position
    position = [ ...
        position; ...
        horpadabs, ...
        2*verpadabs + (1.00 - 3*verpadabs)*0.25, ...
        (1.00 - 3*horpadabs)*0.50, ...
        (1.00 - 3*verpadabs)*0.75; ...
        ];

    % Right panel position
    position = [ ...
        position; ...
        2*horpadabs + (1.00 - 3*horpadabs)*0.50, ...
        2*verpadabs + (1.00 - 3*verpadabs)*0.25, ...
        (1.00 - 3*horpadabs)*0.50, ...
        (1.00 - 3*verpadabs)*0.75; ...
        ];

endfunction;
