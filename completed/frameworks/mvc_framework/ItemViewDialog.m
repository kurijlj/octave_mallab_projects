% -----------------------------------------------------------------------------
%
% Function 'ItemViewDialog':
%
% Use:
%       -- handles = ItemViewDialog(name, uistyle, item)
%
% Description:
%          Demo and functionality test dialog for the ItemView view.
%
% -----------------------------------------------------------------------------
function handles = ItemViewDialog(name, uistyle, item)
    fname = 'ItemViewDialog';
    use_case_a = ' -- handles = ItemViewDialog(name, uistyle, item)';

    % Validate input arguments ------------------------------------------------

    if(~ischar(name) || isempty(name))  % name can be an empty string
        error( ...
            '%s: name must be an nonempty character array', ...
            fname
            );

    endif;

    if(~isa(uistyle, 'AppUiStyle'))
        error( ...
            '%s: uistyle must be an instance of the "AppUiStyle" class', ...
            fname ...
            );

    endif;

    if(~isa(item, 'Item'))
        error( ...
            '%s: item must be an instance of the "Item" class', ...
            fname ...
            );

    endif;

    % Create the GUI elements -------------------------------------------------
    handles = struct();

    % Create main figure
    handles.figure = figure('name', name);

    % Create main view
    view = uipanel( ...
        'parent', handles.figure, ...
        'bordertype', 'none', ...
        'position', [0.00, 0.20, 1.00, 0.80] ...
        );
    controls = uipanel( ...
        'parent', handles.figure, ...
        'bordertype', 'none', ...
        'position', [0.00, 0.00, 1.00, 0.20] ...
        );

    % Create the edit view
    handles.item_view = ItemView( ...
        view, ...
        'Edit Item', ...
        uistyle, ...
        item ...
        );

    % Create conrols
    handles.control_panel = OkCancelPanel( ...
        controls, ...
        '', ...
        uistyle ...
        );

    % Connect callbacks to events ---------------------------------------------
    set( ...
        handles.figure, ...
        'sizechangedfcn', {@onWindowResize, handles, uistyle} ...
        );

endfunction;


% -----------------------------------------------------------------------------
%
% Callbacks section
%
% -----------------------------------------------------------------------------

% -----------------------------------------------------------------------------
%
% Callback 'onWindowResize':
%
% Use:
%       -- onWindowResize(hsrc, evt, handles, uistyle)
%
% Description:
%          Callback for the 'SizeChangedFcn' event.
%
% -----------------------------------------------------------------------------
function onWindowResize(hsrc, evt, handles, uistyle)

    % Reset edit view
    position = itemViewElementsPosition(handles.item_view.main_panel, uistyle);
    set(handles.item_view.lbl_name, 'position', position(1, :));
    set(handles.item_view.fld_name, 'position', position(2, :));
    set(handles.item_view.lbl_value, 'position', position(3, :));
    set(handles.item_view.fld_value, 'position', position(4, :));

    % Reset Ok-Cancel panel
    position = okCancelPanelElementsPosition(handles.control_panel.main_panel, uistyle);
    set(handles.control_panel.btn_ok, 'position', position(1, :));
    set(handles.control_panel.btn_cancel, 'position', position(2, :));

endfunction;
