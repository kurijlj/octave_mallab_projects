% 'gui_value_return' is a function from the package: 'GUI Elements RND'
%
%  -- result = gui_value_return()
%       Testing mechanismo how to return value on exit from GUI

function gui_value_return()

    % Store function name into variable for easier management of error messages
    fname = 'gui_select_point';

    % Initialize GUI toolkit
    graphics_toolkit qt;

    app = struct();
    app.intensity = [ 0, ];
    app.destvar = 'intensity';
    app = build_gui(app);
    guidata(gcf(), app);

    % Wait for user to close the figure and then continue
    uiwait(app.gui.main_figure);

endfunction;


function [app] = build_gui(app)

    % Allocate structure for storing gui elemnents
    gui = struct();

    % Spawn GUI elements
    gui.main_figure = figure( ...
        'name', 'GUI Value Return', ...
        'tag', 'main_figure', ...
        'menubar', 'none', ...
        'sizechangedfcn', @ui_resize, ...
        'deletefcn', @ui_destroy, ...
        'position', ui_init_position(get(0, 'ScreenSize')) ...
        );

    % Spawn main panel
    gui.main_panel = uipanel( ...
        'parent', gui.main_figure, ...
        'tag', 'main_panel', ...
        'bordertype', 'none', ...
        'position', [0, 0, 1, 1] ...
        );

    % Define dimensions for panel elements with fixed size
    gui.slider_panel_height = 50;

    % Calculate normalized position of panel elements
    position = ui_main_panel_elements_position(gui);

    % Spawn slider panel
    gui.slider_panel = uipanel( ...
        'parent', gui.main_panel, ...
        'tag', 'slider_panel', ...
        'title', 'Select intensity', ...
        'position', position(1, :) ...
        );

    % Spawn slider
    gui.selector = uicontrol( ...
        'parent', gui.slider_panel, ...
        'style', 'slider', ...
        'tag', 'intensity_slider', ...
        'tooltipstring', 'Select intesity', ...
        'callback', @update_intensity, ...
        'min', 0, 'max', 100, ...
        'value', app.intensity(1), ...
        'units', 'normalized', ...
        'position', [0, 0, 1, 1] ...
        );

    % Spawn table panel
    gui.table_panel = uipanel( ...
        'parent', gui.main_panel, ...
        'tag', 'table_panel', ...
        'title', 'Selection history', ...
        'position', position(2, :) ...
        );

    % Spawn table view
    gui.selection_view = uitable( ...
        'parent', gui.table_panel, ...
        'Data', app.intensity', ...
        'units', 'normalized', ...
        'position', [0, 0, 1, 1] ...
        );
    set(gui.selection_view, 'Data', app.intensity');

    % Spawn destination panel
    gui.destvar_panel = uipanel( ...
        'parent', gui.main_panel, ...
        'tag', 'destvar_panel', ...
        'title', 'Save to', ...
        'position', position(3, :) ...
        );

    % Spawn destination input
    gui.destvar_input = uicontrol( ...
        'parent', gui.destvar_panel, ...
        'style', 'edit', ...
        'units', 'normalized', ...
        'string', app.destvar, ...
        'callback', @update_destination, ...
        'horizontalalignment', 'left', ...
        'position', [0, 0, 1, 1] ...
        );

    app.gui = gui;

endfunction;


function ui_position = ui_init_position(screen_size)

    % Init return value to default
    ui_position = [0 0 400 400];

    % Calculate app position and extents according to available screen extents
    ui_width = round(screen_size(3)*0.25);
    ui_height = round(screen_size(4)*0.5);
    ui_x_origin = floor((screen_size(3) - ui_width)*0.5);
    ui_y_origin = floor((screen_size(4) - ui_height)*0.5);

    % Update return value
    ui_position = [ui_x_origin, ui_y_origin, ui_width, ui_height];

endfunction;


function position = ui_main_panel_elements_position(gui_handle)

    % Init return
    position = zeros(3, 4);

    % Calculate elements position
    mainpanel_extents = getpixelposition(gui_handle.main_panel);
    width  = mainpanel_extents(3) - mainpanel_extents(1);
    height = mainpanel_extents(4) - mainpanel_extents(2);
    slider_rel_height = gui_handle.slider_panel_height/height;
    table_rel_height = 1 - 2*slider_rel_height;
    destvar_rel_height = slider_rel_height;

    % Update return variable
    position(1, 1) = 0;
    position(1, 2) = 0;
    position(1, 3) = 1;
    position(1, 4) = slider_rel_height;
    position(2, 1) = 0;
    position(2, 2) = slider_rel_height;
    position(2, 3) = 1;
    position(2, 4) = table_rel_height;
    position(3, 1) = 0;
    position(3, 2) = slider_rel_height + table_rel_height;
    position(3, 3) = 1;
    position(3, 4) = destvar_rel_height;

endfunction;


function update_intensity(src, evt)

    % Retrieve slider position
    value = get(src, 'value');

    % Retrieve handle to app data
    app = guidata(src);

    % Update intensities array
    app.intensity = [app.intensity, value];
    guidata(gcf(), app);

    % Update selection history view
    set(app.gui.selection_view, 'Data', app.intensity');

endfunction;


function update_destination(src, evt)

    % Retrieve slider position
    value = get(src, 'string');

    % Retrieve handle to app data
    app = guidata(src);

    % Update destination
    app.destvar = value;
    guidata(gcf(), app);

endfunction;


function ui_resize(src, evt)

    % Retrieve handle to app data
    app = guidata(src);

    % Recalculate GUI elements position inside main panel
    position = ui_main_panel_elements_position(app.gui);
    set(app.gui.slider_panel, 'position', position(1, :));
    set(app.gui.table_panel, 'position', position(2, :));

endfunction;


function ui_destroy(src, evt)
    % Retrieve handle to app data
    app = guidata(src);

    % Assign intensities array to a workspace variable
    assignin('base', app.destvar, app.intensity);

endfunction;
