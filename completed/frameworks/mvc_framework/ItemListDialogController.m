% -----------------------------------------------------------------------------
%
% Function 'ItemListDialogController':
%
% Use:
%       -- ItemListDialogController()
%
% Description:
%          Demo and functionality test controller for the ItemListView.
%
% -----------------------------------------------------------------------------
function ItemListDialogController(list)
    fname = 'ItemListDialogController';

    % Validate input arguments ------------------------------------------------

    if(~isa(list, 'ItemList'))
        error( ...
            '%s: list must be an instance of the "ItemList" class', ...
            fname ...
            );

    endif;

    % Initialize global variables ---------------------------------------------
    global uistyle;
    global handles;
    global models;

    uistyle = AppUiStyle();
    models = struct();
    models.selec = ItemListSelection(list);

    % Create dialog -----------------------------------------------------------
    handles.dlg_list = ItemListDialog('Item List Dialog', uistyle, models.selec.list);
    handles.dlg_edit = NaN;

    % Connect signals to corresponding callbacks ------------------------------
    set(handles.dlg_list.list_view.tbl_items, 'cellselectioncallback', @onCellSelect);
    set(handles.dlg_list.list_view.mnu_add, 'callback', @onCntxMnuOptSelect);
    set(handles.dlg_list.list_view.mnu_remove, 'callback', @onCntxMnuOptSelect);
    set(handles.dlg_list.control_panel.btn_ok, 'callback', @onPushOk);
    set(handles.dlg_list.control_panel.btn_cancel, 'callback', @onPushCancel);
    set(handles.dlg_list.figure, 'deletefcn', @onDeleteListDialog);

endfunction;


% -----------------------------------------------------------------------------
%
% Callbacks section
%
% -----------------------------------------------------------------------------

% -----------------------------------------------------------------------------
%
% Callback 'onCellSelect':
%
% Use:
%       -- onCellSelect(hsrc, evt)
%
% Description:
%          Callback to be called when user one of the cells in the 'Item List'
%          table.
%
% -----------------------------------------------------------------------------
function onCellSelect(hsrc, evt)
    global handles;
    global models;

    % Get selected cells
    idx = unique(evt.Indices(:, 1));

    % If user selected just a row idx will be a scalar holding row index
    if(2 == size(evt.Indices)(1) && 1 == numel(idx))

        % Change index of the selected item
        models.selec = models.selec.select_index(idx);

        % Enable 'Remove Item' option in the table's context menu
        set(handles.dlg_list.list_view.mnu_remove, 'enable', 'on');

    else
        % User selected a single cell or a column, set selected item index
        % to 'no selection' (0)
        models.selec = models.selec.select_index(0);

        % Disable 'Remove Item' option in the table's context menu
        set(handles.dlg_list.list_view.mnu_remove, 'enable', 'off');

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Callback 'onCntxMnuOptSelect':
%
% Use:
%       -- onCntxMnuOptSelect(hsrc, evt)
%
% Description:
%          Callback to be called when user one selects one option from the
%          table's context menu.
%
% -----------------------------------------------------------------------------
function onCntxMnuOptSelect(hsrc, evt)
    global uistyle;
    global handles;
    global models;

    switch(hsrc)
        case handles.dlg_list.list_view.mnu_add
            handles.dlg_edit = ItemEditDialog( ...
                'Item List Dialog: Add Item', ...
                uistyle, ...
                Item('Enter item name', 'Enter item value') ...
                );

            set(handles.dlg_edit.control_panel.btn_ok, 'callback', @onPushOk);
            set(handles.dlg_edit.control_panel.btn_cancel, 'callback', @onPushCancel);

        case handles.dlg_list.list_view.mnu_remove
            % Update the model
            list = models.selec.list.remove(models.selec.idx);
            % If the removed item was the last on the list reduce idx by one,
            % otherwise keep idx
            if(models.selec.idx > list.numel())
                display(models.selec.idx);
                models.selec = ItemListSelection(list, list.numel());
                display(models.selec);

            else
                models.selec = ItemListSelection(list, models.selec.idx);

            endif;

            % Update the view
            set(handles.dlg_list.list_view.tbl_items, 'data', list.cellarray());

        otherwise
            % Respond to all other options yet to be implemented
            msgbox(...
                'Feature not yet implemented.', ...
                'Item List Dialog: Feature not yet implemented.', ...
                'warn', ...
                'modal'
                );

    endswitch;

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

    switch(hsrc)
        case handles.dlg_list.control_panel.btn_ok
            % Close the edit dialog if open
            if(isstruct(handles.dlg_edit) && isfigure(handles.dlg_edit.figure))
                close(handles.dlg_edit.figure);

            endif;

            % Close the dialog
            close(handles.dlg_list.figure);

        case handles.dlg_edit.control_panel.btn_ok
            % Add item to the selection list
            item = Item( ...
                get(handles.dlg_edit.edit_view.fld_name, 'string'), ...
                get(handles.dlg_edit.edit_view.fld_value, 'string') ...
                );
            list = models.selec.list.add(item);
            models.selec = ItemListSelection(list);

            % Update the view
            set(handles.dlg_list.list_view.tbl_items, 'data', list.cellarray());

            % Close the dialog
            close(handles.dlg_edit.figure);

            % Clean-up the handles
            handles.dlg_edit = NaN;

    endswitch;

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

    switch(hsrc)
        case handles.dlg_list.control_panel.btn_cancel
            % Reset selected item
            models.selec = models.selec.select_index(0);

            % Close the edit dialog if open
            if(isstruct(handles.dlg_edit) && isfigure(handles.dlg_edit.figure))
                close(handles.dlg_edit.figure);

            endif;

            % Close the dialog
            close(handles.dlg_list.figure);

        case handles.dlg_edit.control_panel.btn_cancel
            % Close the dialog
            close(handles.dlg_edit.figure);

            % Clean-up the handles
            handles.dlg_edit = NaN;

    endswitch;

endfunction;

% -----------------------------------------------------------------------------
%
% Callback 'onDeleteListDialog':
%
% Use:
%       -- onDeleteListDialog(hsrc, evt)
%
% Description:
%          Callback to be called when the 'Item List' dialog is about
%          to be deleted.
%
% -----------------------------------------------------------------------------
function onDeleteListDialog(hsrc, evt)
    global models;

    models.selec.disp();

endfunction;
