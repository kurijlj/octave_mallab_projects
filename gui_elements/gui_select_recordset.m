% =============================================================================
% Copyright (C) 2022 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% This file is part of GUI Elements.
%
% GUI Elements is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any
% later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
% =============================================================================


% =============================================================================
%
% <Put documentation here>
%
%
% 2022-06-25 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% * gui_select_recordset.m: created.
%
% =============================================================================


% =============================================================================
%
% TODO: 
%
% =============================================================================


% =============================================================================
%
% References (this section should be deleted in the release version)
%
% =============================================================================


% TODO: Remove following line when release is complete
pkg_name = 'GUI Elements'


% =============================================================================
%
% Main Script Body Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% App 'gui_select_recordset_v1':
%
% -- gui_seect_recordset_v1()
%
% -----------------------------------------------------------------------------
function gui_select_recordset_v1()

    % Define common message strings
    fname = 'rct_select_recordset_v1';

    % Initialize GUI toolkit
    graphics_toolkit qt;

    % Initialize structure for keeping app data
    app = newApp('filmdb.csv');
    app.gui = uiNewGui(app);
    guidata(gcf(), app);

    % Update display
    refresh(gcf());

    % Wait for user to close the figure and then continue
    uiwait(app.gui.handles.main_figure);

endfunction;




% =============================================================================
%
% Application Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newApp
%
% Use:
%       -- app = newApp(filmdb)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function app = newApp(filmdb)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newApp';
    use_case = ' -- app = newApp(filmdb)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate filmdb parameter value
    if(~ischar(filmdb) || isempty(filmdb))
        error('%s: filmdb must be a nonempty string', fname);

    endif;

    % Populate 'App' structure ------------------------------------------------
    app = struct();
    app.filmdb = filmdb;
    app.gui = NaN;

endfunction;




% =============================================================================
%
% Film Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newFilm
%
% Use:
%       -- film = newFilm(title, manufacturer, model, lot, custom_cut)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function film = newFilm(title, manufacturer, model, lot, custom_cut)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newFilm';
    use_case_a = ' -- film = newFilm()';
    use_case_b = ' -- film = newFilm(title, manufacturer, model, lot, custom_cut)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(0 ~= nargin && 5 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate user supplied values, if any
    if(5 == nargin)
        parameter = {'title', 'manufacturer', 'model', 'lot', 'custom_cut'};
        value = {title, manufacturer, model, lot, custom_cut};
        idx = 1;
        while(5 >= idx)
            if(~ischar(value{idx}) || isempty(value{idx}))
                error('%s: %s must be a nonempty string', fname, parameter{idx});

            endif;

            idx = idx + 1;

        endwhile;

        % Validate value supplied to custom_cut
        validatestring( ...
            custom_cut, ...
            {'Unknown', 'True', 'False'}, ...
            fname, ...
            'custom_cut' ...
            );

    endif;

    % Populate 'Film' structure -----------------------------------------------
    film = struct();

    if(0 == nargin)
        film.title        = 'Unknown';
        film.manufacturer = 'Unknown';
        film.model        = 'Unknown';
        film.lot          = 'Unknown';
        film.custom_cut   = 'Unknown';

    else
        film.title        = title;
        film.manufacturer = manufacturer;
        film.model        = model;
        film.lot          = lot;
        film.custom_cut   = custom_cut;

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: loadFilmDatabase
%
% Use:
%       -- film_entries = loadFilmDatabase(dbfile)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function film_entries = loadFilmDatabase(dbfile)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'filmDatabaseExists';
    use_case = ' -- result = filmDatabaseExists(dbfile)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate dbfile parameter value
    if(~ischar(dbfile) || isempty(dbfile))
        error('%s: dbfile must be a nonempty string', fname);

    endif;

    % Set film_entries to default value ---------------------------------------
    film_entries = {};

    % Check if given file path poins to actual file ---------------------------
    if(~isfile(dbfile))
        % Database does not exist, print error message and return empty list
        fprintf( ...
            stderr(), ...
            'warning: %s: database file "%s" does not exist\nUsing defaul values\n', ...
            fname, ...
            dbfile ...
            );
        return;

    endif;

    % Given file exist, check if it is actual 'Film'' database file -----------
    % try
    %     checkFilmDatabaseIntegrity(dbfile);

    % catch err
    %     % Database integrity failed. Print error message and return empty list
    %     fprintf(stderr(), '%s: %s\n', fname, err.message);
    %     return;

    % end_try_catch;

    % Load database entries ---------------------------------------------------

    % Load required packages
    pkg load io;  % Required by 'csv2cell'

    % Load database entries as cell array
    film_list = csv2cell(dbfile);

    % Unload loaded packages
    pkg unload io;

    % Popuate film_entries
    idx = 2;  % We skip column headers
    while(size(film_list, 1) >= idx)
        entry = newFilm( ...
            film_list{idx, 1}, ...
            film_list{idx, 2}, ...
            film_list{idx, 3}, ...
            film_list{idx, 4}, ...
            film_list{idx, 5} ...
            );
        film_entries = {film_entries{:}, entry};

        idx = idx + 1;

    endwhile;

endfunction;




% =============================================================================
%
% GUI Creation Routines Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: uiNewGui
%
% Use:
%       -- gui = uiNewGui(app_obj)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function gui = uiNewGui(app_obj)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'uiNewGui';
    use_case = ' -- result = uiNewGui(app_obj)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate app_obj parameter value
    % if(~isAppStruct)
    %     error('%s: app_obj must be an instance of App structure', fname);

    % endif;

    % Define structures for keeping GUI static parameter values,
    % elemnent handles, and user data options ---------------------------------
    data       = struct();
    handles    = struct();
    parameters = struct();

    % Define static UI parameters
    parameters.header_height_px = 72;
    parameters.padding_px = 6;
    parameters.row_height_px = 24;
    parameters.btn_width_px = 128;

    % Create main figure ------------------------------------------------------
    handles.main_figure = figure( ...
        'name', 'GUI Elements: Select Recordset', ...
        'tag', 'main_figure', ...
        'menubar', 'none' ...
        );

    % Create main panel -------------------------------------------------------
    handles.main_panel = uipanel( ...
        'parent', handles.main_figure, ...
        'tag', 'main_panel', ...
        'title', 'Select Film', ...
        'position', [0, 0, 1, 1] ...
        );

    % Load film data from the database ----------------------------------------

    % Try to read data from database
    data.film_entries = loadFilmDatabase(app_obj.filmdb);

    % Check if we have an empty list
    if(isempty(data.film_entries))
        % List is empty. Invalid database or database does not exist
        data.film_entries = {newFilm()};

    endif;

    % Create a popup menu list of values
    selection = {};
    idx = 1;
    while(length(data.film_entries) >= idx)
        selection = {selection{:}, data.film_entries{idx}.title};

        idx = idx + 1;

    endwhile;

    % Create 'Film' panel controls --------------------------------------------
    handles.select_film_btn = uicontrol( ...
        'parent', handles.main_panel, ...
        'style', 'pushbutton', ...
        'tag', 'select_film_btn', ...
        'string', 'Select', ...
        % 'callback', @uiSelectFilm, ...
        'units', 'normalized', ...
        'position', [0.00, 0.00, 1.00, 1 - 5*0.17] ...
        );
    handles.view_custom_cut = uicontrol( ...
        'parent', handles.main_panel, ...
        'style', 'text', ...
        'tag', 'view_custom_cut', ...
        'string', data.film_entries{1}.custom_cut, ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', [0.00, 1 - 5*0.17, 1.00, 0.17] ...
        );
    handles.view_lot = uicontrol( ...
        'parent', handles.main_panel, ...
        'style', 'text', ...
        'tag', 'view_lot', ...
        'string', data.film_entries{1}.lot, ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', [0.00, 1 - 4*0.17, 1.00, 0.17] ...
        );
    handles.view_film_model = uicontrol( ...
        'parent', handles.main_panel, ...
        'style', 'text', ...
        'tag', 'view_film_model', ...
        'string', data.film_entries{1}.model, ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', [0.00, 1 - 3*0.17, 1.00, 0.17] ...
        );
    handles.view_manufacturer = uicontrol( ...
        'parent', handles.main_panel, ...
        'style', 'text', ...
        'tag', 'view_manufacturer', ...
        'string', data.film_entries{1}.manufacturer, ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', [0.00, 1 - 2*0.17, 1.00, 0.17] ...
        );
    handles.select_film_title = uicontrol( ...
        'parent', handles.main_panel, ...
        'style', 'popupmenu', ...
        'tag', 'select_film_title', ...
        'string', selection, ...
        'tooltipstring', 'Select film', ...
        'horizontalalignment', 'left', ...
        'callback', @uiUpdateFilmView, ...
        'units', 'normalized', ...
        'position', [0.00, 1 - 1*0.17, 1.00, 0.17] ...
        );

    % Define structure for keeping GUI data -----------------------------------
    gui = struct();
    gui.data = data;
    gui.handles = handles;
    gui.parameters = parameters;
    % guidata(handles.main_figure, gui);

endfunction;




% =============================================================================
%
% GUI Callbacks Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Main Panel Callbacks Section
%
% -----------------------------------------------------------------------------
function uiUpdateFilmView(src, evt)

    % Retrieve handle to app data ---------------------------------------------
    app_obj = guidata(src);
    data = app_obj.gui.data;
    handles = app_obj.gui.handles;

    % Retrieve index of selected item -----------------------------------------
    sl = get(handles.select_film_title, 'value');

    % Update data view --------------------------------------------------------
    set(handles.view_manufacturer, 'string', data.film_entries{sl}.manufacturer);
    set(handles.view_film_model, 'string', data.film_entries{sl}.model);
    set(handles.view_lot, 'string', data.film_entries{sl}.lot);
    set(handles.view_custom_cut, 'string', data.film_entries{sl}.custom_cut);

endfunction;

function uiOnFilmSelect(src, evt)

    % Retrieve handle to app data ---------------------------------------------
    app_obj = guidata(src);
    data = app_obj.gui.data;
    handles = app_obj.gui.handles;

    % Retrieve index of selected item -----------------------------------------
    sl = get(handles.select_film_title, 'value');

    % Save structure in the workspace -----------------------------------------
    assignin('base', 'film_entry', data.film_entries{sl});

endfunction;
