% 'gui_roi_show' is a function from the package: 'GUI Elements RND'
%
%  -- gui_roi_show()
%       Test concept of displaying selected ROI of an image.

% =============================================================================
%
% Main Script Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function 'gui_roi_show'
%
% -----------------------------------------------------------------------------
function gui_roi_show(img)

    % Initialize GUI toolkit
    graphics_toolkit qt;

    % Initialize structure for keeping app data
    app = struct();
    app.image = img;
    app = build_gui(app);
    guidata(gcf(), app);

    % Update display
    refresh(gcf());

    % Wait for user to close the figure and then continue
    uiwait(app.gui.main_figure);

endfunction;




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
function [app] = build_gui(app)

    % Allocate structure for storing gui elemnents ----------------------------
    gui = struct();

    % Create main figure ------------------------------------------------------
    gui.main_figure = figure( ...
        'name', 'GUI ROI Show', ...
        'tag', 'main_figure', ...
        'menubar', 'none', ...
        'position', uiCalculateInitialPosition(get(0, 'ScreenSize')) ...
        );

    % Create main panel -------------------------------------------------------
    gui.main_panel = uipanel( ...
        'parent', gui.main_figure, ...
        'tag', 'main_panel', ...
        'bordertype', 'none', ...
        'position', [0, 0, 1, 1] ...
        );

    % Calculate normalized position of main panel elements
    position = uiMainPanelElementsPosition(app);

    % Create main panel elements ----------------------------------------------

    % Create panels
    gui.image_view_panel = uipanel( ...
        'parent', gui.main_panel, ...
        'tag', 'image_view_panel', ...
        'title', 'Image', ...
        'position', position(1, :) ...
        );
    gui.roi_view_panel = uipanel( ...
        'parent', gui.main_panel, ...
        'tag', 'roi_view_panel', ...
        'title', 'ROI', ...
        'position', position(2, :) ...
        );

    % Create views
    gui.image_view = axes( ...
        'parent', gui.image_view_panel, ...
        'tag', 'image_view', ...
        'position', [0 0 1 1] ...
        );
    gui.roi_view = axes( ...
        'parent', gui.roi_view_panel, ...
        'tag', 'roi_view', ...
        'position', [0 0 1 1] ...
        );

    % Load images into views
    image(app.image, 'parent', gui.image_view);
    roi = getROIExtents(size(app.image));
    image( ...
        app.image( ...
            roi(2):roi(2) + roi(4), ...
            roi(1):roi(1) + roi(3), ...
            : ...
            ), ...
        'parent', ...
        gui.roi_view ...
        );

    % Draw ROI on the image view
    hold(gui.image_view, 'on');
    plot( ...
        [ ...
            roi(1), ...
            roi(1) + roi(3), ...
            roi(1) + roi(3), ...
            roi(1), ...
            roi(1) ...
            ], ...
        [ ...
            roi(2), ...
            roi(2), ...
            roi(2) + roi(4), ...
            roi(2) + roi(4), ...
            roi(2) ...
            ], ...
        'parent', gui.image_view, ...
        'color', 'r', ...
        'linewidth', 1 ...
        );
    hold(gui.image_view, 'off');

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

    % Calculate app position and extents according to available screen extents
    ui_width = round(screen_size(3)*0.25);
    ui_height = round(screen_size(4)*0.25);
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
function position = uiMainPanelElementsPosition(app_handle)

    % Init return variable
    position = [];

    % Calculate elements position
    if(isLandscape(size(app_handle.image)))
        image_panel = [0, 0, 0.75, 1];
        roi_panel = [image_panel(3), 0, 1 - image_panel(3), 1];

    else
        image_panel = [0, 1 - 0.75, 1, 0.75];
        roi_panel = [0, 0, 1, 1 - image_panel(4)];

    endif;

    % Update return variable
    position = [image_panel; roi_panel];

endfunction;



% =============================================================================
%
% GUI Callbacks Section
%
% =============================================================================



% =============================================================================
%
% Utility functions section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function 'isLandscape'
%
% -----------------------------------------------------------------------------
function result = isLandscape(imsize)
    result = false;

    if(imsize(1) <= imsize(2))
        result = true;

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'isPortrait'
%
% -----------------------------------------------------------------------------
function result = isPortrait(imsize)
    result = ~isLandscape(imsize);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'getROIExtents'
%
% -----------------------------------------------------------------------------
function roi = getROIExtents(imsize)

    % Init return variable
    roi = [];

    % Calculate roi size and position as 10% of size of the given image, at the
    % center of the image
    roi_width  = round(0.1*imsize(2));
    roi_height = round(0.1*imsize(1));
    if(4 > roi_width)
        % Set minimum ROI width
        roi_width = 4;

    endif;
    if(4 > roi_height)
        % Set minimum ROI height
        roi_width = 4;

    endif;
    roi_x_origin = floor((imsize(2) - roi_width)*0.5);
    roi_y_origin = floor((imsize(1) - roi_height)*0.5);

    % Assign results to return variable
    roi = [roi_x_origin, roi_y_origin, roi_width, roi_height];

endfunction;
