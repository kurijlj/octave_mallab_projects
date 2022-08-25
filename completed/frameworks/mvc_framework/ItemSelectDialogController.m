% -----------------------------------------------------------------------------
%
% Function 'ItemSelectDialogController':
%
% Use:
%       -- ItemSelectDialogController()
%
% Description:
%          Demo and functionality test controller for the ItemSelectView.
%
% -----------------------------------------------------------------------------
function ItemSelectDialogController(list)
    fname = 'ItemSelectDialogController';

    % Validate input arguments ------------------------------------------------

    if(~isa(list, 'ItemList'))
        error( ...
            '%s: list must be an instance of the "ItemList" class', ...
            fname ...
            );

    endif;

    % Initialize global variables ---------------------------------------------
    global handles;
    global models

    uistyle = AppUiStyle();
    models = struct();
    if(list.isempty())
        models.selec = ItemListSelection(ItemList(Item('N/A', 'N/A')), 1);

    else
        models.selec = ItemListSelection(list, 1);

    endif;

    % Create dialog -----------------------------------------------------------
    handles = ItemSelectDialog('Item Select Dialog', uistyle, models.selec.list);

    % Connect signals to corresponding callbacks ------------------------------
    set(handles.select_view.fld_name, 'callback', @onItemSelect);
    set(handles.control_panel.btn_ok, 'callback', @onPushOk);
    set(handles.control_panel.btn_cancel, 'callback', @onPushCancel);
    set(handles.figure, 'deletefcn', @onDeleteFigure);

endfunction;


% -----------------------------------------------------------------------------
%
% Callbacks section
%
% -----------------------------------------------------------------------------

% -----------------------------------------------------------------------------
%
% Callback 'onItemSelect':
%
% Use:
%       -- onItemSelect(hsrc, evt)
%
% Description:
%          Callback to be called when user picks one of item names from the
%          dropdown list.
%
% -----------------------------------------------------------------------------
function onItemSelect(hsrc, evt)
    global handles;
    global models;

    models.selec = models.selec.select_index( ...
        get(handles.select_view.fld_name, 'value') ...
        );
    set( ...
        handles.select_view.fld_value, ...
        'string', models.selec.selected_item().value ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Callback 'onPushOk':
%
% Use:
%       -- onPushOk(hsrc, evt)
%
% Description:
%          Callback to be called when user pushes the 'OK' button in the dialog.
%
% -----------------------------------------------------------------------------
function onPushOk(hsrc, evt)
    global handles;
    global models;

    close(handles.figure);

endfunction;

% -----------------------------------------------------------------------------
%
% Callback 'onPushCancel':
%
% Use:
%       -- onPushCancel(hsrc, evt)
%
% Description:
%          Callback to be called when user pushes the 'Cancel' button in
%          the dialog.
%
% -----------------------------------------------------------------------------
function onPushCancel(hsrc, evt)
    global handles;
    global models;

    models.selec = models.selec.select_index(0);

    close(handles.figure);

endfunction;

% -----------------------------------------------------------------------------
%
% Callback 'onDeleteFigure':
%
% Use:
%       -- onDeleteFigure(hsrc, evt)
%
% Description:
%          Callback to be called when the figure is about to be deleted.
%
% -----------------------------------------------------------------------------
function onDeleteFigure(hsrc, evt)
    global handles;
    global models;

    models.selec.selected_item().disp();

endfunction;
