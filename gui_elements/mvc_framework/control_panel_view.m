control_panel_view_version = '1.0';

% -----------------------------------------------------------------------------
%
% Function 'newControlPanelView':
%
% Use:
%       -- controller = newControlPanelView(controller)
%
% Description:
% Create an new 'Control Panel View' and assign it to the parent container.
%
% -----------------------------------------------------------------------------
function controller = newControlPanelView(controller)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newControlPanelView';
    use_case = ' -- result = newControlPanelView(controller)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    controller.ui_handles = struct();

    % Create 'Item' view panel ------------------------------------------------
    position = controlPanelViewElementsPosition(controller);
    controller.ui_handles.main_container = uipanel( ...
        'parent', controller.parent.ui_handles.control_panel_container, ...
        'title', 'Control Panel', ...
        'position', position(1, :) ...
        );

    % Create button elements --------------------------------------------------

    % Set 'Accept' button -----------------------------------------------------
    controller.ui_handles.accept_button = uicontrol( ...
        'parent', controller.ui_handles.main_container, ...
        'style', 'pushbutton', ...
        'string', 'Accept', ...
        'units', 'normalized', ...
        'position', position(3, :) ...
        );

    % Set 'Cancel' button -----------------------------------------------------
    controller.ui_handles.cancel_button = uicontrol( ...
        'parent', controller.ui_handles.main_container, ...
        'style', 'pushbutton', ...
        'string', 'Cancel', ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'updateControlPanelView':
%
% Use:
%       -- updateControlPanelView(controller)
%
% Description:
% Update the view in response to the change of data or GUI elements
% repositioning due to size changed event. This function is meant to be called
% by the controller. Calling this function on its own can lead to undefined
% behavior.
%
% -----------------------------------------------------------------------------
function updateControlPanelView(controller)

    position = controlPanelViewElementsPosition(controller);
    set( ...
        controller.ui_handles.main_container, ...
        'position', position(1, :) ...
        );
    set( ...
        controller.ui_handles.cancel_button, ...
        'position', position(2, :) ...
        );
    set( ...
        controller.ui_handles.accept_button, ...
        'position', position(3, :) ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'controlPanelViewElementsPosition':
%
% Use:
%       -- position = controlPanelViewElementsPosition(controller)
%
% Description:
% Calculate GUI elements position within set container.
%
% -----------------------------------------------------------------------------
function position = controlPanelViewElementsPosition(controller)

    % Define return value as matrix -------------------------------------------
    position = [];

    % Calculate relative extents ----------------------------------------------
    cexts = getpixelposition(controller.parent.ui_handles.control_panel_container);
    horpadabs = controller.parent.layout.padding_px / cexts(3);
    verpadabs = controller.parent.layout.padding_px / cexts(4);
    rowhghabs = controller.parent.layout.row_height_px / cexts(4);
    btnwdtabs = controller.parent.layout.btn_width_px / cexts(3);
    btnhghabs = controller.parent.layout.btn_height_px / cexts(4);

    % Set padding for the main panel ------------------------------------------
    position = [ ...
        position; ...
        horpadabs, ...
        verpadabs, ...
        1.00 - 2*horpadabs, ...
        1.00 - 2*verpadabs; ...
        ];

    % Set button positions ----------------------------------------------------
    idx = 1;
    while(2 >= idx)
        position = [ ...
            position; ...
            (1.00 - btnwdtabs)/2, ...
            verpadabs + (idx - 1)*(btnhghabs + verpadabs), ...
            btnwdtabs, ...
            btnhghabs; ...
            ];

        idx = idx + 1;

    endwhile;

endfunction;
