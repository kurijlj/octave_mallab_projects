% -----------------------------------------------------------------------------
%
% Function 'ItemViewDialogController':
%
% Use:
%       -- ItemViewDialogController(item)
%
% Description:
%          Demo and functionality test controller for the ItemViewView.
%
% -----------------------------------------------------------------------------
function ItemViewDialogController(item)
    fname = 'ItemViewDialogController';

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
        item = Item('N/A', 'N/A');

    endif;
    models.item = item;

    % Create dialog -----------------------------------------------------------
    handles = ItemViewDialog('Item Edit Dialog', uistyle, models.item);

    % Connect signals to corresponding callbacks ------------------------------
    set(handles.control_panel.btn_ok, 'callback', @onPushOk);
    set(handles.control_panel.btn_cancel, 'callback', @onPushCancel);

endfunction;


% -----------------------------------------------------------------------------
%
% Callbacks section
%
% -----------------------------------------------------------------------------

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

    close(handles.figure);

endfunction;
