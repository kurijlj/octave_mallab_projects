% -----------------------------------------------------------------------------
%
% Function 'OkCancelPanel':
%
% Use:
%       -- handles = OkCancelPanel(hparent)
%
% Description:
%          Control panel with OK and Cancel buttons.
%
% -----------------------------------------------------------------------------
function handles = OkCancelPanel(hparent, name, uistyle)
    fname = 'OkCancelPanel';
    use_case_a = ' -- handles = OkCancelPanel(hparent)';

    % Validate input arguments ------------------------------------------------
    if(~ishghandle(hparent))
        error( ...
            '%s: hparent must be handle to a graphics object', ...
            fname
            );

    endif;

    if(~ischar(name))  % name can be an empty string
        error( ...
            '%s: name must be a character array', ...
            fname
            );

    endif;

    if(~isa(uistyle, 'AppUiStyle'))
        error( ...
            '%s: uistyle must be an instance of the "AppUiStyle" class', ...
            fname ...
            );

    endif;

    % Create the GUI elements -------------------------------------------------
    handles = struct();

    % Create panel containig the view's elements
    handles.main_panel = uipanel( ...
        'parent', hparent, ...
        'title', name, ...
        'position', [0.00, 0.00, 1.00, 1.00] ...
        );

    % Create view's elements

    % Calculate positions of the view's elements
    position = okCancelPanelElementsPosition(handles.main_panel, uistyle);

    % Button: OK
    handles.btn_ok = uicontrol( ...
        'parent', handles.main_panel, ...
        'string', 'OK', ...
        'units', 'normalized', ...
        'position', position(1, :) ...
        );

    % Button: Cancel
    handles.btn_cancel = uicontrol( ...
        'parent', handles.main_panel, ...
        'string', 'Cancel', ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );

endfunction;
