% -----------------------------------------------------------------------------
%
% Function 'OkCancelDialogController':
%
% Use:
%       -- OkCancelDialogController()
%
% Description:
%          Demo and functionality test controller for the OkCancelPanel view.
%
% -----------------------------------------------------------------------------
function OkCancelDialogController()
    global handles;
    uistyle = AppUiStyle();
    handles = OkCancelDialog('OK/Cancel Dialog', uistyle);

    set(handles.main_view.btn_ok, 'callback', @onPushOk);
    set(handles.main_view.btn_cancel, 'callback', @onPushCancel);

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
