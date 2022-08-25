% -----------------------------------------------------------------------------
%
% Function 'ItemListDialog':
%
% Use:
%       -- handles = ItemListDialog(name, uistyle)
%
% Description:
%          Demo and functionality test dialog for the ItemListView view.
%
% -----------------------------------------------------------------------------
function handles = ItemListDialog(name, uistyle, list)
    fname = 'ItemListDialog';
    use_case_a = ' -- handles = ItemListDialog(name, uistyle, list)';

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

    if(~isa(list, 'ItemList'))
        error( ...
            '%s: list must be an instance of the "ItemList" class', ...
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
    handles.list_view = ItemListView( ...
        view, ...
        'Edit Items', ...
        uistyle, ...
        list ...
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
    position = itemListViewElementsPosition(handles.list_view.main_panel, uistyle);
    set(handles.list_view.tbl_items, 'position', position(1, :));

    % Reset Ok-Cancel panel
    position = okCancelPanelElementsPosition(handles.control_panel.main_panel, uistyle);
    set(handles.control_panel.btn_ok, 'position', position(1, :));
    set(handles.control_panel.btn_cancel, 'position', position(2, :));

endfunction;
