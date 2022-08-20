function handles = AppController()
    global handles;
    handles = struct();
    handles.main_window = NaN;
    handles.slave_window = NaN;

    handles.main_window = MainWindow();

    set(handles.main_window.btn_launch, 'callback', @onPushLaunch);
    set(handles.main_window.btn_enable, 'callback', @onPushEnable);
    set(handles.main_window.btn_disable, 'callback', @onPushDisable);
    set(handles.main_window.btn_inactivate, 'callback', @onPushInactivate);

endfunction;

function onPushLaunch(hsrc, evt)
    global handles;
    set(handles.main_window.btn_launch, 'enable', 'off');
    set(handles.main_window.btn_enable, 'enable', 'on');
    set(handles.main_window.btn_disable, 'enable', 'on');
    set(handles.main_window.btn_inactivate, 'enable', 'on');

    handles.slave_window = SlaveWindow(handles.main_window.figure);

    set(handles.slave_window.figure, 'deletefcn', @onDeleteSlave);
    set(handles.slave_window.btn_1, 'callback', @onPushBtn1);
    set(handles.slave_window.btn_2, 'callback', @onPushBtn2);
    set(handles.slave_window.btn_close, 'callback', @onPushCloseSlave);

endfunction;

function onPushEnable(hsrc, evt)
    global handles;
    set(handles.slave_window.btn_1, 'enable', 'on');
    set(handles.slave_window.btn_2, 'enable', 'on');
    set(handles.slave_window.btn_close, 'enable', 'on');

endfunction;

function onPushDisable(hsrc, evt)
    global handles;
    set(handles.slave_window.btn_1, 'enable', 'off');
    set(handles.slave_window.btn_2, 'enable', 'off');
    set(handles.slave_window.btn_close, 'enable', 'off');

endfunction;

function onPushInactivate(hsrc, evt)
    global handles;
    set(handles.slave_window.btn_1, 'enable', 'inactive');
    set(handles.slave_window.btn_2, 'enable', 'inactive');
    set(handles.slave_window.btn_close, 'enable', 'inactive');

endfunction;

function onPushBtn1(hsrc, evt)
    global handles;
    set(handles.main_window.figure, 'name', 'Master - Button 1 Pushed');

endfunction;

function onPushBtn2(hsrc, evt)
    global handles;
    set(handles.main_window.figure, 'name', 'Master - Button 2 Pushed');

endfunction;

function onPushCloseSlave(hsrc, evt)
    global handles;
    set(handles.main_window.figure, 'name', 'Master');
    set(handles.main_window.btn_launch, 'enable', 'on');
    set(handles.main_window.btn_enable, 'enable', 'off');
    set(handles.main_window.btn_disable, 'enable', 'off');
    set(handles.main_window.btn_inactivate, 'enable', 'off');

    close(handles.slave_window.figure);

    handles.slave_window = NaN;

endfunction;

function onDeleteSlave(hsrc, evt)
    global handles;
    set(handles.main_window.figure, 'name', 'Master');
    set(handles.main_window.btn_launch, 'enable', 'on');
    set(handles.main_window.btn_enable, 'enable', 'off');
    set(handles.main_window.btn_disable, 'enable', 'off');
    set(handles.main_window.btn_inactivate, 'enable', 'off');

    handles.slave_window = NaN;

endfunction;
