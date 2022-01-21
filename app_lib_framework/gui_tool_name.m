% TODO:'<gui_tool_name>' is a GUI tool from the package: TODO:<App/Lib Framework>
%
%  -- gui_tool_name (msg)
%      Print 'msg' to the stdout. If  'msg' is not supplied it prints 'Hello
%      Wrold!'.
%
%      See also: tool1, tool2.

function gui_tool_name(msg='Hello GUI!')

    % Load graphics toolkit
    graphics_toolkit qt;

    % Call library function.
    dummy_function(msg);

    % TODO:
    main_figure = figure( ...
        'name', 'App/Lib Framework - tool_name' ...
        );

    msg_label = uicontrol( ...
        main_figure, ...
        'style', 'text', ...
        'units', 'normalized', ...
        'string', sprintf("%s", msg), ...
        'horizontalalignment', 'center', ...
        'position', [0.0, 0.0, 1.0, 1.0], ...
        'callback', @tool_name_update ...
        );

    % Generate a structure for storing GUI handles.
    handles = guihandles(main_figure);

    handles.main_figure = main_figure;
    handles.msg_label = msg_label;
    handles.msg = msg;

    % Save GUI handles and userdata to main_figure.
    guidata(main_figure, handles);

endfunction;


% =============================================================================
%
% Callbacks
%
% =============================================================================

function tool_name_update(caller_h, event_data)
    handles = guidata(caller_h);

    switch(gcbo)
        case {handles.msg_label}
            set(h.msg_label, 'string', sprintf("%s", handles.msg));

    endswitch;

endfunction;
