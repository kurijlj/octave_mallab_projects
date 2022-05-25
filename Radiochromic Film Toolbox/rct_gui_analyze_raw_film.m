% 'rctGUIAnalyzeFilm' is an application from the package: 'Radiochromi Film Toolbox'
%
%  -- rctGUIAnalyzeFilm()

% TODO: Remove following line when release is complete
pkg_name = 'Radiochromic Toolbox'

% =============================================================================
%
% Main Script Body Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function 'rct_gui_analyze_film'
%
% -----------------------------------------------------------------------------
% TODO: Rename script's name and function's name to
% 'rct_gui_analyze_raw_film_v1' when release is complete
% function rct_gui_analyze_raw_film()
function rcGuiAnalyzeRawFilm()

    % Initialize GUI toolkit
    graphics_toolkit qt;

    % Initialize structure for keeping app data
    % display('Creating App structure');
    app = struct();

    % Set apps databases locations
    app.scannerdb = 'scannerdb.csv';
    app.filmdb = 'filmdb.csv';

    % display('Creating Measurement structure');
    app.measurement = NaN;
    % display('Creating GUI structure');
    app = buildGUI(app);
    % display('Saving App data');
    guidata(gcf(), app);

    % Update display
    % display('Refreshing GUI display');
    refresh(gcf());

    % Wait for user to close the figure and then continue
    uiwait(app.gui.main_figure);

endfunction;




% =============================================================================
%
% Data Handling Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Measurement Routines
%
% -----------------------------------------------------------------------------
function [app] = newMeasurement(app)
    measurement = struct();
    measurement.title = 'New Measurement';
    measurement.date = strftime('%d.%m.%Y', localtime(time()));;
    measurement = newScannerDevice(measurement, app.scannerdb);
    measurement = newFilm(measurement, app.filmdb);
    measurement = newField(measurement);;
    measurement.irradiated = NaN;
    measurement.background = NaN;
    measurement.zero_light = NaN;
    measurement.dead_pixels = NaN;
    measurement.optical_density = NaN;
    measurement.roi = NaN;

endfunction;

% -----------------------------------------------------------------------------
%
% Scanner Data Structure Routines
%
% -----------------------------------------------------------------------------
function measurement = newScannerDevice(measurement, path_to_devicedb)
    device = loadScannerDatabase(path_to_devicedb);
    measurement.scanner_device = struct();
    measurement.scanner_device.manufacturer        = device{2, 1};
    measurement.scanner_device.model               = device{2, 2};
    measurement.scanner_device.serial_number       = device{2, 3};
    measurement.scanner_device.native_resolution   = device{2, 4};
    measurement.scanner_device.scanning_mode       = device{2, 5};
    measurement.scanner_device.scanning_resolution = device{2, 6};

endfunction;

function device = loadScannerDatabase(path_to_file)

    % Load required packages
    pkg load io;

    % Initialize to default values
    device = { ...
        'Manufacturer', ...
        'Model', ...
        'Serial Number', ...
        'Native Resolution', ...
        'Scanning Mode', ...
        'Scanning Resolution'; ...
        'Unknown', ...
        'Unknown', ...
        'Unknown', ...
        'Unknown', ...
        'Unknown', ...
        'Unknown' ...
        };

    if(~scannerDatabaseExists(path_to_file))
        errordlg( ...
            'Scanner database is missing. Using default values ...', ...
            'RCT Analyze Raw Film: Missing Database' ...
            );

        % Unload loaded packages
        pkg unload io;

        return;

    endif;

    % if(~scannerDatabaseIntegrityOk(path_to_file))
    %     errordlg( ...
    %         'Scanner database integrity check failed. Using default values ...', ...
    %         'RCT Analyze Raw Film: Missing Database' ...
    %         );
    %
    %     % Unload loaded packages
    %     pkg unload io;
    %
    %     return;
    %
    % endif;

    % Load default device
    device = csv2cell(path_to_file);

    % Unload loaded packages
    pkg unload io;

endfunction;

function result = scannerDatabaseExists(path_to_file)
    result = isfile(path_to_file);

endfunction;

function result = scannerDatabaseIntegrityOk(path_to_file)
    % TODO: Add function implementation here

endfunction;

% -----------------------------------------------------------------------------
%
% Film Data Structure Routines
%
% -----------------------------------------------------------------------------
function measurement = newFilm(measurement, path_to_filmdb)
    film = loadFilmDatabase(path_to_filmdb);
    measurement.film = struct();
    measurement.film.manufacturer = film{2, 1};
    measurement.film.model        = film{2, 2};
    measurement.film.custom_cut   = film{2, 3};

endfunction;

function film = loadFilmDatabase(path_to_file)

    % Load required packages
    pkg load io;

    % Initialize to default values
    film = { ...
        'Manufacturer', ...
        'Model', ...
        'Custom Cut'; ...
        'Unknown', ...
        'Unknown', ...
        'Unknown' ...
        };

    if(~filmDatabaseExists(path_to_file))
        errordlg( ...
            'Film database is missing. Using default values ...', ...
            'RCT Analyze Raw Film: Missing Database' ...
            );

        % Unload loaded packages
        pkg unload io;

        return;

    endif;

    % if(~filmDatabaseIntegrityOk(path_to_file))
    %     errordlg( ...
    %         'Film database integrity check failed. Using default values ...', ...
    %         'RCT Analyze Raw Film: Missing Database' ...
    %         );
    %
    %     % Unload loaded packages
    %     pkg unload io;
    %
    %     return;
    %
    % endif;

    % Load all known film models
    film = csv2cell(path_to_file);

    % Unload loaded packages
    pkg unload io;

endfunction;

function result = filmDatabaseExists(path_to_file)
    result = isfile(path_to_file);

endfunction;

function result = filmDatabaseIntegrityOk(path_to_file)
    % TODO: Add function implementation here

endfunction;

% -----------------------------------------------------------------------------
%
% Field Data Structure Routines
%
% -----------------------------------------------------------------------------
function measurement = newField(measurement)
    measurement.field = struct();
    measurement.field.beam_type   = 'Unknown';
    measurement.field.beam_energy = 'Unknown';
    measurement.field.field_shape = 'Unknown';
    measurement.field.field_size  = 'Unknown';

endfunction;

% -----------------------------------------------------------------------------
%
% Irradiated Data Structure Routines
%
% -----------------------------------------------------------------------------
function measurement = loadIrradiatedDataset(measurement, varargin)

    irradiated = struct();

    % Validate input files
    idx = 1;
    while(nargin - 1 >= idx)
        if(~isfile(varargin{idx}))
            % Show error dialog
            errordlg( ...
                sprintf( ...
                    'Not a regular file \"%s\". Aborting loading operation ...', ...
                    varargin{idx} ...
                    ), ...
                'RCT Analyze Raw Film: Missing Database' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                sprintf( ...
                    'Not a regular file \"%s\". Aborting loading operation ...\n', ...
                    varargin{idx} ...
                    ) ...
                );

            % Abort further execution
            return;

        endif;

        idx = idx + 1;

    endwhile;

    irradiated.file_list = varargin;

    measurement.irradiated = irradiated;

endfunction;

% -----------------------------------------------------------------------------
%
% Background Data Structure Routines
%
% -----------------------------------------------------------------------------

% -----------------------------------------------------------------------------
%
% Zero Light Data Structure Routines
%
% -----------------------------------------------------------------------------

% -----------------------------------------------------------------------------
%
% Dead Pixels Data Structure Routines
%
% -----------------------------------------------------------------------------

% -----------------------------------------------------------------------------
%
% Optical Density Data Structure Routines
%
% -----------------------------------------------------------------------------



% =============================================================================
%
% GUI Creation Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function 'buildGUI'
%
% -----------------------------------------------------------------------------
function [app] = buildGUI(app)

    % Allocate structure for storing gui elemnents ----------------------------
    gui = struct();

    % Create main figure ------------------------------------------------------
    gui.main_figure = figure( ...
        'name', 'RCT Analyze Film', ...
        'tag', 'main_figure', ...
        'menubar', 'none', ...
        'sizechangedfcn', @uiResize, ...
        'position', uiCalculateInitialPosition(get(0, 'ScreenSize')) ...
        );

    % Create custom menu bar --------------------------------------------------

    % Create file menu and file menu entries
    gui.file_menu = uimenu( ...
        'parent', gui.main_figure, ...
        'tag', 'file_menu', ...
        'label', '&File', ...
        'accelerator', 'f' ...
        );
    gui.fm_load_background = uimenu( ...
        'parent', gui.file_menu, ...
        'tag', 'fm_load_background', ...
        'label', 'Load Ba&ckground Scans', ...
        'accelerator', 'c', ...
        'callback', @(src, evt)uiLoadScanset('background') ...
        );
    gui.fm_load_irradiated = uimenu( ...
        'parent', gui.file_menu, ...
        'tag', 'fm_load_irradiated', ...
        'label', 'Load &Irradiated Scans', ...
        'accelerator', 'i', ...
        'callback', @(src, evt)uiLoadScanset('irradiated') ...
        );
    gui.fm_load_zerolight = uimenu( ...
        'parent', gui.file_menu, ...
        'tag', 'fm_load_zerolight', ...
        'label', 'Load Zero &Light Scans', ...
        'accelerator', 'l', ...
        'callback', @(src, evt)uiLoadScanset('zerolight') ...
        );
    gui.fm_exportto_workspace = uimenu( ...
        'parent', gui.file_menu, ...
        'tag', 'fm_exportto_workspace', ...
        'label', 'Export to &Workspace', ...
        'accelerator', 'w', ...
        'separator', 'on', ...
        'callback', @(src, evt)uiExportTo('workspace') ...
        );
    gui.fm_exportto_file = uimenu( ...
        'parent', gui.file_menu, ...
        'tag', 'fm_exportto_file', ...
        'label', 'Export to Fil&e', ...
        'accelerator', 'e', ...
        'callback', @(src, evt)uiExportTo('file') ...
        );
    gui.fm_quit = uimenu( ...
        'parent', gui.file_menu, ...
        'tag', 'fm_quit', ...
        'label', '&Quit', ...
        'accelerator', 'q', ...
        'separator', 'on', ...
        'callback', @uiQuit ...
        );

    % Create help menu and help menu entries
    gui.help_menu = uimenu( ...
        'parent', gui.main_figure, ...
        'tag', 'help_menu', ...
        'label', '&Help', ...
        'accelerator', 'h' ...
        );
    gui.hm_help = uimenu( ...
        'parent', gui.help_menu, ...
        'tag', 'hm_help', ...
        'label', 'Help on &Application', ...
        'accelerator', 'a', ...
        'enable', 'off', ...
        'callback', @uiAppHelp ...
        );
    gui.hm_about = uimenu( ...
        'parent', gui.help_menu, ...
        'tag', 'hm_about', ...
        'label', 'A&bout', ...
        'accelerator', 'b', ...
        'separator', 'on', ...
        'enable', 'off', ...
        'callback', @uiAppAbout ...
        );

    % Create main panel -------------------------------------------------------
    gui.main_panel = uipanel( ...
        'parent', gui.main_figure, ...
        'tag', 'main_panel', ...
        'bordertype', 'none', ...
        'position', [0, 0, 1, 1] ...
        );

    % % Define dimensions for panel elements with fixed size
    gui.padding = 5;
    gui.control_panel_width = 300;

    % Calculate normalized position of main panel elements
    position = uiMainPanelElementsPosition(gui);

    % Create main panel elements ----------------------------------------------

    % ROI panel
    gui.roi_panel = uipanel( ...
        'parent', gui.main_panel, ...
        'tag', 'roi_panel', ...
        'title', 'ROI Data View', ...
        'position', position(1, :) ...
        );

    % Scans view panel
    gui.scans_panel = uipanel( ...
        'parent', gui.main_panel, ...
        'tag', 'scans_panel', ...
        'title', 'Scan View', ...
        'position', position(2, :) ...
        );

    % Control panel
    gui.control_panel = uipanel( ...
        'parent', gui.main_panel, ...
        'tag', 'control_panel', ...
        'title', 'Control Panel', ...
        'position', position(3, :) ...
        );

    % Create ROI panel elements -----------------------------------------------

    % Divide ROI panel into two panels: one for table view, and other for ROI
    % selection control ('Undo' button)
    gui.roi_control_width = 100;
    position = uiROIPanelElementsPosition(gui);

    % Create ROI data panel
    gui.roi_data_panel = uipanel( ...
        'parent', gui.roi_panel, ...
        'tag', 'roi_data_panel', ...
        'bordertype', 'none', ...
        'position', position(1, :) ...
        );

    % Create ROI control panel
    gui.roi_control_panel = uipanel( ...
        'parent', gui.roi_panel, ...
        'tag', 'roi_control_panel', ...
        'bordertype', 'none', ...
        'position', position(2, :) ...
        );

    % Create ROI data panel elements ------------------------------------------
    gui.roi_data_view = uitable( ...
        'parent', gui.roi_data_panel, ...
        'ColumnName', {'ROI Center [px]', 'ROI Center [mm]', 'Intensity (R, G, B)'}, ...
        'units', 'normalized', ...
        'position', [0, 0, 1, 1] ...
        );

    % Create ROI control panel elements ---------------------------------------
    gui.roi_control_undo_height = 30;
    position = uiROIControlPanelElementsPosition(gui);
    gui.roi_control_undo = uicontrol( ...
        'parent', gui.roi_control_panel, ...
        'style', 'pushbutton', ...
        'tag', 'roi_control_undo', ...
        'string', 'Undo ROI', ...
        'tooltipstring', 'Undo last ROI selection', ...
        'callback', @uiUndoROISelection, ...
        'units', 'normalized', ...
        'position', position(1, :) ...
        );

    % Create scans view elements ----------------------------------------------
    gui.scans_landscape_view = false;
    position = uiScansPanelElementsPosition(gui);

    % Create panels
    gui.scans_background_panel = uipanel( ...
        'parent', gui.scans_panel, ...
        'tag', 'scans_background_panel', ...
        'title', 'Background Signal View', ...
        'position', position(1, :) ...
        );
    gui.scans_irradiated_panel = uipanel( ...
        'parent', gui.scans_panel, ...
        'tag', 'scans_irradiated_panel', ...
        'title', 'Irradiated Signal View', ...
        'position', position(2, :) ...
        );
    gui.scans_zerolight_panel = uipanel( ...
        'parent', gui.scans_panel, ...
        'tag', 'scans_zerolight_panel', ...
        'title', 'Zero Light Signal View', ...
        'position', position(3, :) ...
        );
    gui.scans_deadpixels_panel = uipanel( ...
        'parent', gui.scans_panel, ...
        'tag', 'scans_deadpixels_panel', ...
        'title', 'Dead Pixels View', ...
        'position', position(4, :) ...
        );
    gui.scans_opticaldensity_panel = uipanel( ...
        'parent', gui.scans_panel, ...
        'tag', 'scans_opticaldensity_panel', ...
        'title', 'Optical Density View', ...
        'position', position(5, :) ...
        );

    % Create views
    gui.scans_background_view = axes( ...
        'parent', gui.scans_background_panel, ...
        'tag', 'scans_background_view', ...
        'position', [0 0 1 1] ...
        );
    % cla(gui.scans_background_view);
    text( ...
        'parent', gui.scans_background_view, ...
        0.5, 0.5, ...
        'No data loaded!', ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'middle' ...
        );
    axis(gui.scans_background_view, 'off');
    gui.scans_irradiated_view = axes( ...
        'parent', gui.scans_irradiated_panel, ...
        'tag', 'scans_irradiated_view', ...
        'position', [0 0 1 1] ...
        );
    % cla(gui.scans_irradiated_view);
    text( ...
        'parent', gui.scans_irradiated_view, ...
        0.5, 0.5, ...
        'No data loaded!', ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'middle' ...
        );
    axis(gui.scans_irradiated_view, 'off');
    gui.scans_zerolight_view = axes( ...
        'parent', gui.scans_zerolight_panel, ...
        'tag', 'scans_zerolight_view', ...
        'position', [0 0 1 1] ...
        );
    % cla(gui.scans_izerolight_view);
    text( ...
        'parent', gui.scans_zerolight_view, ...
        0.5, 0.5, ...
        'No data loaded!', ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'middle' ...
        );
    axis(gui.scans_zerolight_view, 'off');
    gui.scans_deadpixels_view = axes( ...
        'parent', gui.scans_deadpixels_panel, ...
        'tag', 'scans_deadpixels_view', ...
        'position', [0 0 1 1] ...
        );
    % cla(gui.scans_deadpixels_view);
    text( ...
        'parent', gui.scans_deadpixels_view, ...
        0.5, 0.5, ...
        'No data loaded!', ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'middle' ...
        );
    axis(gui.scans_deadpixels_view, 'off');
    gui.scans_opticaldensity_view = axes( ...
        'parent', gui.scans_opticaldensity_panel, ...
        'tag', 'scans_opticaldensity_view', ...
        'position', [0 0 1 1] ...
        );
    % cla(gui.scans_opticaldensity_view);
    text( ...
        'parent', gui.scans_opticaldensity_view, ...
        0.5, 0.5, ...
        'No data loaded!', ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'middle' ...
        );
    axis(gui.scans_opticaldensity_view, 'off');

    % Create control panel elements -------------------------------------------

    % Save gui data -----------------------------------------------------------
    app.gui = gui;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'uiCalculateInitialPosition'
%
% -----------------------------------------------------------------------------
function ui_position = uiCalculateInitialPosition(screen_size)

    % Init return value to default
    ui_position = [100 100 400 400];

    % Make app occupy upt to 80% of the available screen size
    ui_width = round(screen_size(3)*0.80);
    ui_height = round(screen_size(4)*0.80);
    ui_x_origin = floor((screen_size(3) - ui_width)*0.5);
    ui_y_origin = floor((screen_size(4) - ui_height)*0.5);

    % Update return value
    ui_position = [ui_x_origin, ui_y_origin, ui_width, ui_height];

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'uiMainPanelElementsPosition'
%
% -----------------------------------------------------------------------------
function position = uiMainPanelElementsPosition(gui_handle)

    % Init return value
    position = [];

    % Calculate elements position
    mainpanel_extents = getpixelposition(gui_handle.main_panel);
    width  = mainpanel_extents(3) - mainpanel_extents(1);
    height = mainpanel_extents(4) - mainpanel_extents(2);
    rel_control_panel_width = gui_handle.control_panel_width/width;
    roi_view = [0, 0, 1 - rel_control_panel_width, 0.25];
    scan_view = [0, roi_view(4), roi_view(3), 1 - roi_view(4)];
    control_view = [roi_view(3), 0, 1 - roi_view(3), 1];

    % Update return variable
    position = [position; roi_view; scan_view; control_view];

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'uiROIPanelElementsPosition'
%
% -----------------------------------------------------------------------------
function position = uiROIPanelElementsPosition(gui_handle)

    % Init return value
    position = [];

    % Calculate elements position
    roi_panel_extents = getpixelposition(gui_handle.roi_panel);
    width  = roi_panel_extents(3) - roi_panel_extents(1);
    height = roi_panel_extents(4) - roi_panel_extents(2);
    rel_hpadding = gui_handle.padding/width;
    rel_vpadding = gui_handle.padding/height;
    data_view = [0, 0, 0.75 - rel_hpadding, 1];
    control_view = [ ...
        data_view(3) + rel_hpadding, ...
        rel_vpadding, ...
        1 - data_view(3) - 2*rel_hpadding, ...
        1 - 2*rel_vpadding ...
        ];

    % Update return variable
    position = [data_view; control_view];

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'uiROIControlPanelElementsPosition'
%
% -----------------------------------------------------------------------------
function position = uiROIControlPanelElementsPosition(gui_handle);

    % Init return value
    position = [];

    % Calculate elements position
    roi_controlpanel_extents = getpixelposition(gui_handle.roi_control_panel);
    width  = roi_controlpanel_extents(3) - roi_controlpanel_extents(1);
    height = roi_controlpanel_extents(4) - roi_controlpanel_extents(2);
    undo_rel_height = gui_handle.roi_control_undo_height/height;
    undo_push = [0, 1 - undo_rel_height, 1, undo_rel_height];

    % Update return variable
    position = [undo_push;];

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'uiScansPanelElementsPosition'
%
% -----------------------------------------------------------------------------
function position = uiScansPanelElementsPosition(gui_handle)

    % Init return value
    position = [];

    % Calculate elements position based on scan orientation
    if(gui_handle.scans_landscape_view)
        background      = [0, 1 - 1*0.2, 1, 0.2];
        irradiated      = [0, 1 - 2*0.2, 1, 0.2];
        zerolight       = [0, 1 - 3*0.2, 1, 0.2];
        deadpixels      = [0, 1 - 4*0.2, 1, 0.2];
        opticaldensity  = [0, 1 - 5*0.2, 1, 0.2];

    else
        background      = [0*0.2, 0, 0.2, 1];
        irradiated      = [1*0.2, 0, 0.2, 1];
        zerolight       = [2*0.2, 0, 0.2, 1];
        deadpixels      = [3*0.2, 0, 0.2, 1];
        opticaldensity  = [4*0.2, 0, 0.2, 1];

    endif;

    % Update return variable
    position = [ ...
        position; ...
        background; ...
        irradiated; ...
        zerolight; ...
        deadpixels; ...
        opticaldensity ...
        ];

endfunction;



% =============================================================================
%
% GUI Callbacks Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Menu Bar Callbacks Section
%
% -----------------------------------------------------------------------------
function uiLoadScanset(scantype)
    % TODO: Add function implementation here
    % utl_gui_file_multiselect();
    % rct_load_scanset(fnames);

endfunction;

function uiExportTo(destination)
    % TODO: Add function implementation here

endfunction;

function uiQuit(src, evt)
    close(gcf());

endfunction;

function uiAppHelp(src, evt)
    % TODO: Add function implementation here

endfunction;

function uiAppAbout(src, evt)
    % TODO: Add function implementation here

endfunction;

% -----------------------------------------------------------------------------
%
% Main Panel Callbacks Section
%
% -----------------------------------------------------------------------------
function uiResize(src, evt)

    % Retrieve handle to app data
    app = guidata(src);

    % Recalculate GUI elements position inside main panel
    position = uiMainPanelElementsPosition(app.gui);
    set(app.gui.roi_panel, 'position', position(1, :));
    set(app.gui.scans_panel, 'position', position(2, :));
    set(app.gui.control_panel, 'position', position(3, :));

    % Recalculate GUI elements position inside ROI panel
    position = uiROIPanelElementsPosition(app.gui);
    set(app.gui.roi_data_panel, 'position', position(1, :));
    set(app.gui.roi_control_panel, 'position', position(2, :));

    % Recalculate GUI elements position inside ROI control panel
    position = uiROIControlPanelElementsPosition(app.gui);
    set(app.gui.roi_control_undo, 'position', position(1, :));

    % Recalculate GUI elements position inside Scans panel
    % position = uiScansPanelElementsPosition(app.gui);
    % set(app.gui.scans_background_panel, 'position', position(1, :));
    % set(app.gui.scans_irradiated_panel, 'position', position(2, :));
    % set(app.gui.scans_zerolight_panel, 'position', position(3, :));
    % set(app.gui.scans_deadpixels_panel, 'position', position(4, :));
    % set(app.gui.scans_opticaldensity_panel, 'position', position(5, :));

endfunction;


% -----------------------------------------------------------------------------
%
% ROI Panel Callbacks Section
%
% -----------------------------------------------------------------------------
function uiUndoROISelection(src, evt)
    % TODO: Add function implementation here

endfunction;


% -----------------------------------------------------------------------------
%
% Scans Panel Callbacks Section
%
% -----------------------------------------------------------------------------
