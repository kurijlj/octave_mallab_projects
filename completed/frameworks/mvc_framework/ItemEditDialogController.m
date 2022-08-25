% -----------------------------------------------------------------------------
%
% Function 'ItemEditDialogController':
%
% Use:
%       -- ItemEditDialogController()
%
% Description:
%          Demo and functionality test controller for the ItemEditView.
%
% -----------------------------------------------------------------------------
function ItemEditDialogController(item)
    fname = 'ItemEditDialogController';

    % Validate input arguments ------------------------------------------------

    if(~isa(item, 'Item'))
        error( ...
            '%s: item must be an instance of the "Item" class', ...
            fname ...
            );

    endif;

    % Initialize global variables ---------------------------------------------
    global handles;
    global models

    uistyle = AppUiStyle();
    models = struct();
    if(item.isnan())
        item = Item('Enter item name', 'Enter item value');

    endif;
    models.item = item;

    % Create dialog -----------------------------------------------------------
    handles = ItemEditDialog('Item Edit Dialog', uistyle, models.item);

    % Connect signals to corresponding callbacks ------------------------------
    set(handles.edit_view.fld_name, 'callback', @onFieldEdit);
    set(handles.edit_view.fld_value, 'callback', @onFieldEdit);
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
% Callback 'onFieldEdit':
%
% Use:
%       -- onFieldEdit(hsrc, evt)
%
% Description:
%          Callback to be called when user enters texte in one of the dialog's
%          fields.
%
% -----------------------------------------------------------------------------
function onFieldEdit(hsrc, evt)
    global handles;
    global models;

    name = get(handles.edit_view.fld_name, 'string');
    value = get(handles.edit_view.fld_value, 'string');
    models.item = Item(name, value);

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

    name = get(handles.edit_view.fld_name, 'string');
    value = get(handles.edit_view.fld_value, 'string');
    models.item = Item(name, value);

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

    models.item = Item();

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
    global models;

    models.item.disp();

endfunction;
