% =============================================================================
% Copyright (C) 2022 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% This file is part of Radiochromic Film Toolbox.
%
% Radiochromic Film Toolbox is free software: you can redistribute it and/or
% modify it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
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
% 2022-05-17 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% * rct_gui_analyze_raw_film.m: created.
%
% =============================================================================


% =============================================================================
%
% TODO: 1) Reformat the error messages to comply wiht format set in the
%          'plotRect' function;
%       2) Add validation of number of input parameters for all functions;
%       3) Add validation of input images by reading tags from TIFF header using
%          'imfinfo' function.
%
% =============================================================================


% =============================================================================
%
% References (this section should be deleted in the release version)
%
% =============================================================================


% TODO: Remove following line when release is complete
pkg_name = 'Radiochromic Toolbox'


% =============================================================================
%
% Main Script Body Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% App 'rct_gui_analyze_raw_film_v1':
%
% -- rct_gui_analyze_raw_film()
%
% -----------------------------------------------------------------------------
function rct_gui_analyze_raw_film_v1()

    % Define common message strings
    fname = 'rct_gui_analyze_raw_film_v1';

    % Initialize GUI toolkit
    graphics_toolkit qt;

    % Initialize structure for keeping app data
    app = newApp('scannerdb.csv', 'filmdb.csv');
    app.gui = uiNewGui(app);
    guidata(gcf(), app);

    % Update display
    refresh(gcf());

    % Wait for user to close the figure and then continue
    uiwait(app.gui.main_figure);

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
%       -- app = newApp(scannerdb, filmdb)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function app = newApp(scannerdb, filmdb)

    % Define common message strings
    fname = 'newApp';
    use_case = ' -- app = newApp(scannerdb, filmdb)';

    % Validate input arguments
    if(2 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~ischar(scannerdb))
        error('%s: scannerdb must be a string', fname);

    endif;

    if(~ischar(filmdb))
        error('%s: filmbd must be a string', fname);

    endif;

    app = struct();
    app.scannerdb = scannerdb;
    app.filmdb = filmdb;
    app.measurement = NaN;
    app.gui = NaN;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isAppDataStruct
%
% Use:
%       -- result = isAppDataStruct(app_obj)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isAppDataStruct(app_obj)

    % Define common message strings
    fname = 'isAppDataStruct';
    use_case = ' -- result = isAppDataStruct(app_obj)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(app_obj) ...
            && isfield(app_obj, 'scannerdb') ...
            && ischar(app_obj.scannerdb) ...
            && isfield(app_obj, 'filmdb') ...
            && ischar(app_obj.filmdb) ...
            && isfield(app_obj, 'measurement') ...
            && isfield(app_obj, 'gui') ...
            )
        result = true;

    endif;

endfunction;



% =============================================================================
%
% Measurement Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newMeasurement
%
% Use:
%       -- measurement = newMeasurement(title=NaN, date=NaN)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function measurement = newMeasurement(title=NaN, date=NaN)

    % Store function name into variable for easier management of error messages
    fname = 'newMeasurement';
    use_case_a = ' -- measurement = newMeasurement()';
    use_case_b = ' -- measurement = newMeasurement(title)';
    use_case_c = ' -- measurement = newMeasurement(title, date)';

    % Validate input arguments
    if(2 < nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b, ...
            use_case_c ...
            );

    endif;

    if(~isnan(title) && ~ischar(title))
        error('%s: title must be NaN or a string', fname);

    endif;

    if(~isnan(date) && ~ischar(date))
        error('%s: date must be NaN or a date string (dd.mm.YYYY)', fname);

    endif;

    measurement = struct();
    if(~isnan(title))
        measurement.title = title;

    else
        measurement.title = 'New Measurement';

    endif;
    if(~isnan(date))
        measurement.date = date;

    else
        measurement.date = strftime('%d.%m.%Y', localtime(time()));

    endif;
    measurement.scanner_device       = NaN;
    measurement.film                 = NaN;
    measurement.field                = NaN;
    measurement.pixel_data_smoothing = NaN;
    measurement.irradiated           = NaN;
    measurement.background           = NaN;
    measurement.zero_light           = NaN;
    measurement.dead_pixels_mask     = NaN;
    measurement.optical_density      = NaN;
    measurement.roi                  = {};

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isMeasurementDataStruct
%
% Use:
%       -- result = isMeasurementDataStruct(msr)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isMeasurementDataStruct(msr)

    % Define common message strings
    fname = 'isMeasurementDataStruct';
    use_case = ' -- result = isMeasurementDataStruct(msr)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(msr) ...
            && isfield(msr, 'title') ...
            && ischar(msr.title) ...
            && isfield(msr, 'date') ...
            && ischar(msr.date) ...
            && isfield(msr, 'scanner_device') ...
            && isfield(msr, 'film') ...
            && isfield(msr, 'field') ...
            && isfield(msr, 'pixel_data_smoothing') ...
            && isfield(msr, 'irradiated') ...
            && isfield(msr, 'background') ...
            && isfield(msr, 'zero_light') ...
            && isfield(msr, 'dead_pixels_mask') ...
            && isfield(msr, 'optical_density') ...
            && isfield(msr, 'roi') ...
            && iscell(msr.roi) ...
            )
        result = true;

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: stripPixelData
%
% Use:
%       -- result = stripPixelData(msr)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = stripPixelData(msr)

    % Define common message strings
    fname = 'stripPixelData';
    use_case = ' -- result = stripPixelData(msr)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isMeasurementDataStruct(msr))
        error('%s: Invalid data or measurement not set.', fname);

    endif;

    result = struct();
    result.title                             = msr.title;
    result.date                              = msr.date;
    result.scanner_device                    = msr.scanner_device;
    result.film                              = msr.film;
    result.field                             = msr.field;
    result.pixel_data_smoothing              = msr.pixel_data_smoothing;

    if(isIrradiatedDataStruct(msr.irradiated))
        result.irradiated                    = struct();
        result.irradiated.irradiation_date   = msr.irradiated.irradiation_date;
        result.irradiated.scan_date          = msr.irradiated.scan_date;
        result.irradiated.file_list          = msr.irradiated.file_list;
        result.irradiated.standard_deviation = msr.irradiated.standard_deviation;

    else
        result.irradiated = NaN;

    endif;

    if(isBackgroundDataStruct(msr.background))
        result.background                    = struct();
        result.background.scan_date          = msr.background.scan_date;
        result.background.file_list          = msr.background.file_list;
        result.background.standard_deviation = msr.background.standard_deviation;
    else
        result.background = NaN;

    endif;

    if(isZeroLightDataStruct(msr.zero_light))
        result.zero_light                    = struct();
        result.zero_light.scan_date          = msr.zero_light.scan_date;
        result.zero_light.file_list          = msr.zero_light.file_list;
        result.zero_light.standard_deviation = msr.zero_light.standard_deviation;
    else
        result.zero_light = NaN;

    endif;

    result.roi                               = msr.roi;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: exportMsrToJson
%
% Use:
%       -- result = exportMsrToJson(msr)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = exportMsrToJson(msr)

    % Define common message strings
    fname = 'exportMsrToJson';
    use_case = ' -- result = exportMsrToJson(msr)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isMeasurementDataStruct(msr))
        error('%s: Invalid data or measurement not set.', fname);

    endif;

    pkg load io;

    result = jsonencode(stripPixelData(msr));

    pkg unload io;

endfunction;



% =============================================================================
%
% Scanner Device Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newScannerDevice
%
% Use:
%       -- device = newScannerDevice(scannerdb=NaN, item=1)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function device = newScannerDevice(scannerdb=NaN, item=1)

    % Store function name into variable for easier management of error messages
    fname = 'newScannerDevice';
    use_case_a = ' -- device = newScannerDevice()';
    use_case_b = ' -- device = newScannerDevice(scannerdb)';
    use_case_c = ' -- device = newScannerDevice(scannerdb, item)';

    % Validate input arguments
    if(2 < nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b, ...
            use_case_c ...
            );

    endif;

    if(~isnan(scannerdb) && ~ischar(scannerdb))
        error('%s: scannerdb must be NaN or a string', fname);

    endif;

    validateattributes( ...
        item, ...
        {'numeric'}, ...
        { ...
            'scalar', ...
            'nonempty', ...
            'nonnan', ...
            'integer', ...
            'finite', ...
            '>=', 0 ...
            }, ...
        fname, ...
        'item' ...
        );

    % Load device list first
    device_list = loadScannerDatabase(scannerdb);

    % Validate if 'device_list' can be indexed with supplied item number 'item'
    if(~isindex(item + 1, size(device_list, 1)))
        error( ...
            '%s: Index (%d) out of bounds [1, %d].', ...
            fname, ...
            item, ...
            size(device_list, 1) - 1 ...
            );

    endif;

    % Create structure and assign data
    device                     = struct();
    device.manufacturer        = device_list{item + 1, 1};
    device.model               = device_list{item + 1, 2};
    device.serial_number       = device_list{item + 1, 3};
    device.native_resolution   = device_list{item + 1, 4};
    device.resolution_unit     = device_list{item + 1, 5};
    device.scanning_mode       = device_list{item + 1, 6};
    device.scanning_resolution = device_list{item + 1, 7};
    device.film_fixation       = device_list{item + 1, 8};

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isScannerDeviceStruct
%
% Use:
%       -- result = isScannerDeviceStruct(sd)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isScannerDeviceStruct(sd)

    % Define common message strings
    fname = 'isScannerDeviceStruct';
    use_case = ' -- result = isScannerDeviceStruct(sd)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(sd) ...
            && isfield(sd, 'manufacturer') ...
            && ischar(sd.manufacturer) ...
            && isfield(sd, 'model') ...
            && ischar(sd.model) ...
            && isfield(sd, 'serial_number') ...
            && ischar(sd.serial_number) ...
            && isfield(sd, 'native_resolution') ...
            && ischar(sd.native_resolution) ...
            && isfield(sd, 'resolution_unit') ...
            && ischar(sd.resolution_unit) ...
            && isfield(sd, 'scanning_mode') ...
            && ischar(sd.scanning_mode) ...
            && isfield(sd, 'scanning_resolution') ...
            && ischar(sd.scanning_resolution) ...
            && isfield(sd, 'film_fixation') ...
            && ischar(sd.film_fixation) ...
            )
        result = true;

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: loadScannerDatabase
%
% Use:
%       -- device_list = loadScannerDatabase(dbfile=NaN)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function device_list = loadScannerDatabase(dbfile=NaN)

    % Define common window and message strings
    fname = 'loadScannerDatabase';
    window_title = 'RCT Analyze Raw Film: Load Scanner Database';
    use_case = ' -- device_list = loadScannerDatabase(dbfile)';

    % Validate input arguments
    if(1 < nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    % Initialize to default values
    device_list = { ...
        'Manufacturer', ...
        'Model', ...
        'Serial Number', ...
        'Native Resolution', ...
        'Resolution Unit', ...
        'Scanning Mode', ...
        'Scanning Resolution',
        'Film Fixation'; ...
        'Unknown', ...
        'Unknown', ...
        'Unknown', ...
        'Unknown', ...
        'Unknown', ...
        'Unknown', ...
        'Unknown', ...
        'Unknown' ...
        };

    if(~isnan(dbfile) && ~scannerDatabaseExists(dbfile))
        % Show error dialog
        msgbox( ...
            sprintf( ...
                strjoin({ ...
                    'Scanner database \"%s\" is missing.' ...
                    'Using default values ...' ...
                    }), ...
                dbfile ...
                ), ...
            window_title, ...
            'warn' ...
            );

        % also send message to the workspace
        fprintf( ...
            stderr(), ...
            strjoin({ ...
                '%s: Scanner database \"%s\" is missing.' ...
                'Using default values ...\n' ...
                }), ...
            fname, ...
            dbfile ...
            );

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

    if(~isnan(dbfile))
        % Load required packages
        pkg load io;  % Required by 'csv2cell'

        % Load all known scanners
        device_list = csv2cell(dbfile);

        % Unload loaded packages
        pkg unload io;

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: scannerDatabaseExists
%
% Use:
%       -- result = scannerDatabaseExists(dbfile=NaN)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = scannerDatabaseExists(dbfile=NaN)

    % Store function name into variable for easier management of error messages
    fname = 'scannerDatabaseExists';
    use_case = ' -- result = scannerDatabaseExists(dbfile)';

    % Validate input arguments
    if(1 < nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isnan(dbfile) && ~ischar(dbfile))
        error('%s: dbfile must be NaN or a string', fname);

    endif;

    result = isfile(dbfile);

endfunction;

% -----------------------------------------------------------------------------
%
% Function: scannerDatabaseIntegrityOk
%
% Use:
%       -- result = scannerDatabaseIntegrityOk(path_to_file)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = scannerDatabaseIntegrityOk(path_to_file=NaN)
    % TODO: Add function implementation here

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
%       -- film = newFilm(filmdb=NaN, item=1)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function film = newFilm(filmdb=NaN, item=1)

    % Store function name into variable for easier management of error messages
    fname = 'newFilm';
    use_case_a = ' -- film = newFilm()';
    use_case_b = ' -- film = newFilm(filmdb)';
    use_case_c = ' -- film = newFilm(filmdb, item)';

    % Validate input arguments
    if(2 < nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b, ...
            use_case_c ...
            );

    endif;

    if(~isnan(filmdb) && ~ischar(filmdb))
        error('%s: filmdb must be NaN or a string', fname);

    endif;

    validateattributes( ...
        item, ...
        {'numeric'}, ...
        { ...
            'scalar', ...
            'nonempty', ...
            'nonnan', ...
            'integer', ...
            'finite', ...
            '>=', 0 ...
            }, ...
        fname, ...
        'item' ...
        );


    % Load film list
    film_list = loadFilmDatabase(filmdb);

    % Validate if 'film_list' can be indexed with supplied item number 'item'
    if(~isindex(item + 1, size(film_list, 1)))
        error( ...
            '%s: Index (%d) out of bounds [1, %d].', ...
            fname, ...
            item, ...
            size(film_list, 1) - 1 ...
            );

    endif;

    film              = struct();
    film.manufacturer = film_list{item + 1, 1};
    film.model        = film_list{item + 1, 2};
    film.custom_cut   = film_list{item + 1, 3};

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isFilmStruct
%
% Use:
%       -- result = isFilmStruct(film)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isFilmStruct(film)

    % Define common message strings
    fname = 'isFilmStruct';
    use_case = ' -- result = isFilmStruct(film)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(film) ...
            && isfield(film, 'manufacturer') ...
            && ischar(film.manufacturer) ...
            && isfield(film, 'model') ...
            && ischar(film.model) ...
            && isfield(film, 'custom_cut') ...
            && ischar(film.custom_cut) ...
            )
        result = true;

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: loadFilmDatabase
%
% Use:
%       -- film_list = loadFilmDatabase(dbfile=NaN)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function film_list = loadFilmDatabase(dbfile=NaN)

    % Define common window and message strings
    fname = 'loadFilmDatabase';
    window_title = 'RCT Analyze Raw Film: Load Film Database';
    use_case = ' -- film_list = loadFilmDatabase(dbfile)';

    % Validate input arguments
    if(1 < nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;


    % Initialize to default values
    film_list = { ...
        'Manufacturer', ...
        'Model', ...
        'Custom Cut'; ...
        'Unknown', ...
        'Unknown', ...
        'Unknown' ...
        };

    if(~isnan(dbfile) && ~filmDatabaseExists(dbfile))
        % Show error dialog
        msgbox( ...
            sprintf( ...
                strjoin({ ...
                    'Film database \"%s\" is missing.' ...
                    'Using default values ...' ...
                    }), ...
                dbfile ...
                ), ...
            window_title, ...
            'warn' ...
            );

        % also send message to the workspace
        fprintf( ...
            stderr(), ...
            strjoin({ ...
                '%s: Film database \"%s\" is missing.' ...
                'Using default values ...\n' ...
                }), ...
            fname, ...
            dbfile ...
            );

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

    if(~isnan(dbfile))
        % Load required packages
        pkg load io;  % Required by 'csv2cell'

        % Load all known scanners
        film_list = csv2cell(dbfile);

        % Unload loaded packages
        pkg unload io;

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: filmDatabaseExists
%
% Use:
%       -- result = filmDatabaseExists(dbfile=NaN)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = filmDatabaseExists(dbfile=NaN)

    % Store function name into variable for easier management of error messages
    fname = 'filmDatabaseExists';
    use_case = ' -- result = filmDatabaseExists(dbfile)';

    % Validate input arguments
    if(1 < nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isnan(dbfile) && ~ischar(dbfile))
        error('%s: dbfile must be NaN or a string', fname);

    endif;

    result = isfile(dbfile);

endfunction;

% -----------------------------------------------------------------------------
%
% Function: filmDatabaseIntegrityOk
%
% Use:
%       -- result = filmDatabaseIntegrityOk(path_to_file)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = filmDatabaseIntegrityOk(path_to_file)
    % TODO: Add function implementation here

endfunction;



% =============================================================================
%
% Field Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newField
%
% Use:
%       -- field = newField( ...
%               beam_type='Unknown', ...
%               beam_energy='Unknown', ...
%               field_shape='Unknown', ...
%               field_size='Unknown' ...
%               )
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function field = newField( ...
        beam_type='Unknown', ...
        beam_energy='Unknown', ...
        field_shape='Unknown', ...
        field_size='Unknown' ...
        )

    % Store function name into variable for easier management of error messages
    fname = 'newField';
    use_case = ' -- field = newField(beam_type, beam_energy, field_shape, field_size)';

    % Validate input arguments
    if(~ischar(beam_type))
        error('%s: beam_type must be a string', fname);

    endif;
    validatestring( ...
        beam_type, ...
        {'Unknown', 'Photon', 'Electron', 'Proton'}, ...
        fname, ...
        'beam_type' ...
        );

    if(~ischar(beam_energy))
        error('%s: beam_energy must be a string', fname);

    endif;

    if(~ischar(field_shape))
        error('%s: field_shape must be a string', fname);

    endif;
    validatestring( ...
        field_shape, ...
        {'Unknown', 'Circular', 'Rectangular', 'Square', 'Irregular'}, ...
        fname, ...
        'field_shape' ...
        );

    if(~ischar(field_size))
        error('%s: field_size must be a string', fname);

    endif;

    field             = struct();
    field.beam_type   = beam_type;
    field.beam_energy = beam_energy;
    field.field_shape = field_shape;
    field.field_size  = field_size;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isFieldStruct
%
% Use:
%       -- result = isFieldStruct(field)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isFieldStruct(field)

    % Define common message strings
    fname = 'isFilmStruct';
    use_case = ' -- result = isFieldStruct(field)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(field) ...
            && isfield(field, 'beam_type') ...
            && ischar(field.beam_type) ...
            && isfield(field, 'beam_energy') ...
            && ischar(field.beam_energy) ...
            && isfield(field, 'field_shape') ...
            && ischar(field.field_shape) ...
            && isfield(field, 'field_size') ...
            && ischar(field.field_size) ...
            )
        result = true;

    endif;

endfunction;



% =============================================================================
%
% Pixel Data Smoothing Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newPixelDataSmoothing
%
% Use:
%       -- smoothing = newPixelDataSmoothing(method='none', window=[])
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function smoothing = newPixelDataSmoothing(method='none', window=[])

    % Store function name into variable for easier management of error messages
    fname = 'newPixelDataSmoothing';
    use_case_a = ' -- smoothing = newPixelDataSmoothing()';
    use_case_b = ' -- smoothing = newPixelDataSmoothing(method, window)';

    % Validate input arguments
    if(0 ~= nargin && 2 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_a ...
            );

    endif;

    if(~ischar(method))
        error('%s: method must be a string', fname);

    endif;
    validatestring( ...
        method, ...
        {'none', 'median', 'wiener', 'wavelet_db8'}, ...
        fname, ...
        'method' ...
        );

    if(~isequal('none', method) && ~isequal('wavelet_db8', method))
        validateattributes( ...
            window, ...
            {'numeric'}, ...
            { ...
                'vector', ...
                'numel', 2, ...
                'integer', ...
                '>=', 1 ...
                }, ...
            fname, ...
            'window' ...
            );

    endif;

    smoothing        = struct();
    smoothing.method = method;
    smoothing.window = window;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isPixelDataSmoothingStruct
%
% Use:
%       -- result = isPixelDataSmoothingStruct(smt)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isPixelDataSmoothingStruct(smt)

    % Define common message strings
    fname = 'isPixelDataSmoothingStruct';
    use_case = ' -- result = isPixelDataSmoothingStruct(smt)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(smt) ...
            && isfield(smt, 'method') ...
            && ischar(smt.method) ...
            && isfield(smt, 'window') ...
            && ismatrix(smt.window) ...
            )
        result = true;

    endif;

endfunction;



% =============================================================================
%
% Irradiated Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newIrradiatedDataset
%
% Use:
%       -- irradiated = newIrradiatedDataset(msr, irr_date, sc_date, sc_path1, sc_path2, ...)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function irradiated = newIrradiatedDataset(msr, irr_date, sc_date, varargin)

    % Define common window and message strings
    fname = 'newIrradiatedDataset';
    window_title = 'RCT Analyze Raw Film: New Irradiated Dataset';
    progress_tracker_title = 'New Irradiated Dataset';
    use_case = ' -- irradiated = newIrradiatedDataset(msr, irr_date, sc_date, scan_1, scan_2, ...)';

    % Validate input arguments
    if(4 > nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isMeasurementDataStruct(msr))
        error('%s: Invalid data or measurement not set.', fname);

    endif;

    if(~isPixelDataSmoothingStruct(msr.pixel_data_smoothing))
        error('%s: Invalid data or pixel data smoothing not set.', fname);

    endif;

    if(~ischar(irr_date))
        error('%s: irr_date must be a date string (dd.mm.YYYY)', fname);

    endif;

    if(~ischar(sc_date))
        error('%s: sc_date must be a date string (dd.mm.YYYY)', fname);

    endif;

    % Initialize data structures for keeping computation results
    irradiated = NaN;
    pwmean     = [];
    pwstd      = [];

    % Initialize loop counter
    idx = 1;

    % Display information on the loading process progress
    progress_tracker = waitbar( ...
        0.0, ...
        'Loading scanset ...', ...
        'name', progress_tracker_title ...
        );

    % Validate input files , check dimensions integrity of the given images,
    % calculate mean pixel value, pxelwise standard deviation, and pixelwise
    % stdev RMS
    while(nargin - 3 >= idx)
        img = [];

        % Validate input arguments
        if(~ischar(varargin{idx}))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Display error and abort execution
            error( ...
                '%s: varargin{%d} must be a string containing a path to a file', ...
                fname, ...
                idx ...
                );

        endif;

        try
            img = imread(varargin{idx});

        catch err
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = strrep(err.message, '\', '\\');  % Escape backslashes

            % Show error dialog
            msgbox( ...
                { ...
                    sprintf('Error loading input scan: %d. Check log for details', idx), ...
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                '%s: %s. Aborting loading operation ...\n', ...
                fname, ...
                err.message ...
                );

            % Abort loading the scanset
            return;

        end_try_catch;

        % Check if we are dealing with an 48 bit image
        if(~isequal('uint16', class(img)))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = sprintf( ...
                'Not an 48 bit image (%s).', ...
                strrep(varargin{idx}, '\', '\\') ...  % Escape backslashes
                );

            % Show error dialog
            msgbox( ...
                { ...
                    strrep(errmsg, '_', '\_'), ...  % Escape underscores
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                sprintf( ...
                    '%s: %s Aborting loading operation ...\n', ...
                    fname, ...
                    errmsg ...
                    ) ...
                );

            % Abort loading the scanset
            return;

        endif;

        % Load required package
        pkg load image;  % Required for 'isrgb'

        % Check if we have an RGB image
        if(~isrgb(img))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = sprintf( ...
                'Not an RGB image (%s).', ...
                strrep(varargin{idx}, '\', '\\') ...  % Escape backslashes
                );

            % Image does not have three color channels
            msgbox( ...
                { ...
                    strrep(errmsg, '_', '\_'), ...  % Escape underscores
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                sprintf( ...
                    '%s: %s Aborting loading operation ...\n', ...
                    fname, ...
                    errmsg ...
                    ) ...
                );

            % Unload loaded package
            pkg unload image;

            % Abort loading the scanset
            return;

        endif;

        % Unload loaded packages
        pkg unload image;

        % Check if all given images have the same size
        if(1 == idx)
            % If this is the first image read, allocate space for the
            % mean pixel values and pixelwise standard deviation
            pwstd = pwmean = zeros(size(img));

        elseif(~isequal(size(img), size(pwmean)))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = sprintf( ...
                'Image size does not conform to the size of other images (%s).', ...
                strrep(varargin{idx}, '\', '\\') ...  % Escape backslashes
                );

            % Image size does not conform to the size of other images
            msgbox( ...
                { ...
                    strrep(errmsg, '_', '\_'), ...  % Escape underscores
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                sprintf( ...
                    '%s: %s Aborting loading operation ...\n', ...
                    fname, ...
                    errmsg ...
                    ) ...
                );

            % Clean up GUI
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Abort loading the scanset
            return;

        endif;

        % Smooth out pixel data if required
        smoothed = zeros(size(img));
        if(isequal('median', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using median filter
            smoothed(:, :, 1) = medfilt2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = medfilt2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = medfilt2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wiener', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using wiener filter
            smoothed(:, :, 1) = wiener2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = wiener2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = wiener2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wavelet_db8', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load ltfat;

            % Smooth data using Daubechies wavelet of 8th order and threshoding
            R_c = fwt2(double(img(:, :, 1)), 'db8', 3);
            G_c = fwt2(double(img(:, :, 2)), 'db8', 3);
            B_c = fwt2(double(img(:, :, 3)), 'db8', 3);
            R_c = thresh(R_c, 2000);
            G_c = thresh(G_c, 2000);
            B_c = thresh(B_c, 2000);
            smoothed(:, :, 1) = ifwt2( ...
                R_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 2) = ifwt2( ...
                G_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 3) = ifwt2( ...
                B_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );

            % Unload loaded package
            pkg unload ltfat;

        else
            smoothed = img;

        endif;

        % Accumulate mean pixel value
        pwmean = pwmean + (double(smoothed) ./ (nargin - 3));

        waitbar(idx/(nargin - 3), progress_tracker);

        idx = idx + 1;

    endwhile;

    % Kill image reading progress tracker
    if(ishandle(progress_tracker))
        delete(progress_tracker);

    endif;

    % Reset counter
    idx = 1;

    % Display progress information on calculation of standard deviation
    progress_tracker = waitbar( ...
        0.0, ...
        'Calculating standard deviation ...', ...
        'name', progress_tracker_title ...
        );

    % Calculate sum of squared differences from mean pixel value
    while(nargin - 3 >= idx)
        % Read image again
        img = imread(varargin{idx});

        % Smooth out pixel data again if required
        smoothed = zeros(size(img));
        if(isequal('median', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using median filter
            smoothed(:, :, 1) = medfilt2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = medfilt2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = medfilt2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wiener', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using wiener filter
            smoothed(:, :, 1) = wiener2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = wiener2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = wiener2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wavelet_db8', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load ltfat;

            % Smooth data using Daubechies wavelet of 8th order and threshoding
            R_c = fwt2(double(img(:, :, 1)), 'db8', 3);
            G_c = fwt2(double(img(:, :, 2)), 'db8', 3);
            B_c = fwt2(double(img(:, :, 3)), 'db8', 3);
            R_c = thresh(R_c, 2000);
            G_c = thresh(G_c, 2000);
            B_c = thresh(B_c, 2000);
            smoothed(:, :, 1) = ifwt2( ...
                R_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 2) = ifwt2( ...
                G_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 3) = ifwt2( ...
                B_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );

            % Unload loaded package
            pkg unload ltfat;

        else
            smoothed = img;

        endif;

        % Accumulate the sum of squared differences
        pwstd = pwstd + (double(smoothed) - pwmean).^2;

        % Update progress tracker
        waitbar(idx/(nargin - 3), progress_tracker);

        idx = idx + 1;

    endwhile;

    % Kill stdev progress tracker
    if(ishandle(progress_tracker))
        delete(progress_tracker);

    endif;

    % Only divide by N - 1 if we are dealing with more than one image (scan)
    if(1 < nargin - 3)
        pwstd = pwstd ./ ((nargin - 3) - 1);

    endif;
    pwstd = pwstd.^0.5;

    % Calculate overall standard deviation as RMS of pixelwise standard
    % deviation
    standard_deviation = rms(pwstd);

    % Fill the return structure with calculated data
    irradiated                    = struct();
    irradiated.irradiation_date   = irr_date;
    irradiated.scan_date          = sc_date;
    irradiated.file_list          = varargin;
    irradiated.pixel_data         = pwmean;
    irradiated.standard_deviation = standard_deviation;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isIrradiatedDataStruct
%
% Use:
%       -- result = isIrradiatedDataStruct(irr)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isIrradiatedDataStruct(irr)

    % Define common message strings
    fname = 'isIrradiatedDataStruct';
    use_case = ' -- result = isIrradiatedDataStruct(irr)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(irr) ...
            && isfield(irr, 'irradiation_date') ...
            && isfield(irr, 'scan_date') ...
            && isfield(irr, 'file_list') ...
            && isfield(irr, 'pixel_data') ...
            && isfield(irr, 'standard_deviation') ...
            && ischar(irr.irradiation_date) ...
            && ischar(irr.scan_date) ...
            && iscell(irr.file_list) ...
            && ~isempty(irr.pixel_data) ...
            && (3 == size(irr.pixel_data, 3)) ...
            && ismatrix(irr.pixel_data(:, :, 1)) ...
            && ismatrix(irr.pixel_data(:, :, 2)) ...
            && ismatrix(irr.pixel_data(:, :, 3)) ...
            && isvector(irr.standard_deviation) ...
            && (3 == size(irr.standard_deviation, 1)) ...
            && isfloat(irr.standard_deviation) ...
            )
        result = true;

    endif;

endfunction;



% =============================================================================
%
% Background Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newBackgroundDataset
%
% Use:
%       -- background = newBackgroundDataset(msr, sc_date, sc_path1, sc_path2, ...)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function background = newBackgroundDataset(msr, sc_date, varargin)

    % Define common window and message strings
    fname = 'newBackgroundDataset';
    window_title = 'RCT Analyze Raw Film: New Background Dataset';
    progress_tracker_title = 'New Background Dataset';
    use_case = ' -- background = newBackgroundDataset(msr, sc_date, scan_1, scan_2, ...)';

    % Validate input arguments
    if(3 > nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isMeasurementDataStruct(msr))
        error('%s: Invalid data or measurement not set.', fname);

    endif;

    if(~isIrradiatedDataStruct(msr.irradiated))
        error('%s: Invalid data or irradiated data set not set.', fname);

    endif;

    if(~ischar(sc_date))
        error('%s: sc_date must be a date string (dd.mm.YYYY)', fname);

    endif;

    % Initialize return value to default
    background = NaN;

    % Check for number of scans in the reference dataset
    if(numel(msr.irradiated.file_list) ~= nargin - 2)
        % Number of images in the dataset does not match number of images in the
        % reference dataset. Display error mesages and abort loading
        msgbox( ...
            { ...
                'Number of images in the dataset', ...
                'does not match number of images', ...
                'in the reference (irradiated) dataset.', ...
                'Aborting loading operation ...' ...
                }, ...
            window_title, ...
            'error' ...
            );

        % also send message to the workspace
        fprintf( ...
            stderr(), ...
            strjoin( ...
                { ...
                    '%s: Number of images in the dataset does not match ', ...
                    'number of images in the reference (irradiated) ', ...
                    'dataset. Aborting loading operation ...\n' ...
                    } ...
                ), ...
            fname ...
            );

        % Abort loading the scanset
        return;

    endif;

    % Display information on the loading process progress
    progress_tracker = waitbar( ...
        0.0, ...
        'Loading scanset ...', ...
        'name', progress_tracker_title ...
        );

    % Initialize data structures for keeping computation results
    pwmean     = [];
    pwstd      = [];

    % Initialize loop counter
    idx = 1;

    % Validate input files , check dimensions integrity of the given images,
    % calculate mean pixel value, pxelwise standard deviation, and pixelwise
    % stdev RMS
    while(nargin - 2 >= idx)
        img = [];

        % Validate input arguments
        if(~ischar(varargin{idx}))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Display error and abort execution
            error( ...
                '%s: varargin{%d} must be a string containing a path to a file', ...
                fname, ...
                idx ...
                );

        endif;

        try
            img = imread(varargin{idx});

        catch err
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = strrep(err.message, '\', '\\');  % Escape backslashes

            % Show error dialog
            msgbox( ...
                { ...
                    sprintf('Error loading input scan: %d. Check log for details', idx), ...
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                '%s: %s. Aborting loading operation ...\n', ...
                fname, ...
                err.message ...
                );

            % Abort loading the scanset
            return;

        end_try_catch;

        % Check if we are dealing with an 48 bit image
        if(~isequal('uint16', class(img)))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = sprintf( ...
                'Not an 48 bit image (%s).', ...
                strrep(varargin{idx}, '\', '\\') ...  % Escape backslashes
                );

            % Show error dialog
            msgbox( ...
                { ...
                    strrep(errmsg, '_', '\_'), ...  % Escape underscores
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                sprintf( ...
                    '%s: %s Aborting loading operation ...\n', ...
                    fname, ...
                    errmsg ...
                    ) ...
                );

            % Abort loading the scanset
            return;

        endif;

        % Load required packages
        pkg load image;  % Required for 'isrgb'

        % Check if we have an RGB image
        if(~isrgb(img))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = sprintf( ...
                'Not an RGB image (%s).', ...
                strrep(varargin{idx}, '\', '\\') ...  % Escape backslashes
                );

            % Image does not have three color channels
            msgbox( ...
                { ...
                    strrep(errmsg, '_', '\_'), ...  % Escape underscores
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                sprintf( ...
                    '%s: %s Aborting loading operation ...\n', ...
                    fname, ...
                    errmsg ...
                    ) ...
                );

            % Unload loaded packages
            pkg unload image;

            % Abort loading the scanset
            return;

        endif;

        % Unload loaded packages
        pkg unload image;

        % Check if all given images have the same size as refernce dataset
        if(~isequal(size(img), size(msr.irradiated.pixel_data)))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = sprintf( ...
                'Image size does not conform to the size of the reference image (%s).', ...
                strrep(varargin{idx}, '\', '\\') ...  % Escape backslashes
                );

            % Image size does not conform to the size of other images
            msgbox( ...
                { ...
                    strrep(errmsg, '_', '\_'), ...  % Escape underscores
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                sprintf( ...
                    '%s: %s Aborting loading operation ...\n', ...
                    fname, ...
                    errmsg ...
                    ) ...
                );

            % Clean up GUI
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Abort loading the scanset
            return;

        endif;

        if(1 == idx)
            % If this is the first image read, allocate space for the
            % mean pixel values and pixelwise standard deviation
            pwstd = pwmean = zeros(size(img));

        endif;

        % Smooth out pixel data if required
        smoothed = zeros(size(img));
        if(isequal('median', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using median filter
            smoothed(:, :, 1) = medfilt2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = medfilt2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = medfilt2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wiener', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using wiener filter
            smoothed(:, :, 1) = wiener2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = wiener2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = wiener2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wavelet_db8', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load ltfat;

            % Smooth data using Daubechies wavelet of 8th order and threshoding
            R_c = fwt2(double(img(:, :, 1)), 'db8', 3);
            G_c = fwt2(double(img(:, :, 2)), 'db8', 3);
            B_c = fwt2(double(img(:, :, 3)), 'db8', 3);
            R_c = thresh(R_c, 2000);
            G_c = thresh(G_c, 2000);
            B_c = thresh(B_c, 2000);
            smoothed(:, :, 1) = ifwt2( ...
                R_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 2) = ifwt2( ...
                G_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 3) = ifwt2( ...
                B_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );

            % Unload loaded package
            pkg unload ltfat;

        else
            smoothed = img;

        endif;

        % Accumulate mean pixel value
        pwmean = pwmean + (double(smoothed) ./ (nargin - 2));

        waitbar(idx/(nargin - 2), progress_tracker);

        idx = idx + 1;

    endwhile;

    % Kill image reading progress tracker
    if(ishandle(progress_tracker))
        delete(progress_tracker);

    endif;

    % Reset counter
    idx = 1;

    % Display progress information on calculation of standard deviation
    progress_tracker = waitbar( ...
        0.0, ...
        'Calculating standard deviation ...', ...
        'name', progress_tracker_title ...
        );

    % Calculate sum of squared differences from mean pixel value
    while(nargin - 2 >= idx)
        % Read image again
        img = imread(varargin{idx});

        % Smooth out pixel data if required
        smoothed = zeros(size(img));
        if(isequal('median', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using median filter
            smoothed(:, :, 1) = medfilt2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = medfilt2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = medfilt2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wiener', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using wiener filter
            smoothed(:, :, 1) = wiener2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = wiener2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = wiener2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wavelet_db8', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load ltfat;

            % Smooth data using Daubechies wavelet of 8th order and threshoding
            R_c = fwt2(double(img(:, :, 1)), 'db8', 3);
            G_c = fwt2(double(img(:, :, 2)), 'db8', 3);
            B_c = fwt2(double(img(:, :, 3)), 'db8', 3);
            R_c = thresh(R_c, 2000);
            G_c = thresh(G_c, 2000);
            B_c = thresh(B_c, 2000);
            smoothed(:, :, 1) = ifwt2( ...
                R_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 2) = ifwt2( ...
                G_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 3) = ifwt2( ...
                B_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );

            % Unload loaded package
            pkg unload ltfat;

        else
            smoothed = img;

        endif;

        % Accumulate the sum of squared differences
        pwstd = pwstd + (double(smoothed) - pwmean).^2;

        % Update progress tracker
        waitbar(idx/(nargin - 2), progress_tracker);

        idx = idx + 1;

    endwhile;

    % Kill stdev progress tracker
    if(ishandle(progress_tracker))
        delete(progress_tracker);

    endif;

    % Only divide by N - 1 if we are dealing with more than one image (scan)
    if(1 < nargin - 2)
        pwstd = pwstd ./ ((nargin - 2) - 1);

    endif;
    pwstd = pwstd.^0.5;

    % Calculate overall standard deviation as RMS of pixelwise standard
    % deviation
    standard_deviation = rms(pwstd);

    % Fill the return structure with calculated data
    background                    = struct();
    background.scan_date          = sc_date;
    background.file_list          = varargin;
    background.pixel_data         = pwmean;
    background.standard_deviation = standard_deviation;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isBackgroundDataStruct
%
% Use:
%       -- result = isBackgroundDataStruct(bkg)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isBackgroundDataStruct(bkg)

    % Define common message strings
    fname = 'isBackgroundDataStruct';
    use_case = ' -- result = isBackgroundDataStruct(bkg)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(bkg) ...
            && isfield(bkg, 'scan_date') ...
            && isfield(bkg, 'file_list') ...
            && isfield(bkg, 'pixel_data') ...
            && isfield(bkg, 'standard_deviation') ...
            && ischar(bkg.scan_date) ...
            && iscell(bkg.file_list) ...
            && ~isempty(bkg.pixel_data) ...
            && (3 == size(bkg.pixel_data, 3)) ...
            && ismatrix(bkg.pixel_data(:, :, 1)) ...
            && ismatrix(bkg.pixel_data(:, :, 2)) ...
            && ismatrix(bkg.pixel_data(:, :, 3)) ...
            && isvector(bkg.standard_deviation) ...
            && (3 == size(bkg.standard_deviation, 1)) ...
            && isfloat(bkg.standard_deviation) ...
            )
        result = true;

    endif;

endfunction;



% =============================================================================
%
% Zero Light Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newZeroLightDataset
%
% Use:
%       -- zero_ight = newZeroLightDataset(msr, sc_date, sc_path1, sc_path2, ...)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function zero_light = newZeroLightDataset(msr, sc_date, varargin)

    % Define common window and message strings
    fname = 'newZeroLightDataset';
    window_title = 'RCT Analyze Raw Film: New Zero-Light Dataset';
    progress_tracker_title = 'New Zero-Light Dataset';
    use_case = ' -- zero_light = newZeroLightDataset(msr, sc_date, scan_1, scan_2, ...)';

    % Validate input arguments
    if(3 > nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isMeasurementDataStruct(msr))
        error('%s: Invalid data or measurement not set.', fname);

    endif;

    if(~isIrradiatedDataStruct(msr.irradiated))
        error('%s: Invalid data or irradiated data set not set.', fname);

    endif;

    if(~ischar(sc_date))
        error('%s: sc_date must be a date string (dd.mm.YYYY)', fname);

    endif;

    % Initialize return value to default
    zero_light = NaN;

    % Check for number of scans in the reference dataset
    if(numel(msr.irradiated.file_list) ~= nargin - 2)
        % Number of images in the dataset does not match number of images in the
        % reference dataset. Display error mesages and abort loading
        msgbox( ...
            { ...
                'Number of images in the dataset', ...
                'does not match number of images', ...
                'in the reference (irradiated) dataset.', ...
                'Aborting loading operation ...' ...
                }, ...
            window_title, ...
            'error' ...
            );

        % also send message to the workspace
        fprintf( ...
            stderr(), ...
            strjoin( ...
                { ...
                    '%s: Number of images in the dataset does not match ', ...
                    'number of images in the reference (irradiated) ', ...
                    'dataset. Aborting loading operation ...\n' ...
                    } ...
                ), ...
            fname ...
            );

        % Abort loading the scanset
        return;

    endif;

    % Display information on the loading process progress
    progress_tracker = waitbar( ...
        0.0, ...
        'Loading scanset ...', ...
        'name', progress_tracker_title ...
        );

    % Initialize data structures for keeping computation results
    pwmean = [];
    pwstd  = [];

    % Initialize loop counter
    idx = 1;

    % Validate input files , check dimensions integrity of the given images,
    % calculate mean pixel value, pxelwise standard deviation, and pixelwise
    % stdev RMS
    while(nargin - 2 >= idx)
        img = [];

        % Validate input arguments
        if(~ischar(varargin{idx}))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Display error and abort execution
            error( ...
                '%s: varargin{%d} must be a string containing a path to a file', ...
                fname, ...
                idx ...
                );

        endif;

        try
            img = imread(varargin{idx});

        catch err
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = strrep(err.message, '\', '\\');  % Escape backslashes

            % Show error dialog
            msgbox( ...
                { ...
                    sprintf('Error loading input scan: %d. Check log for details', idx), ...
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                '%s: %s. Aborting loading operation ...\n', ...
                fname, ...
                err.message ...
                );

            % Abort loading the scanset
            return;

        end_try_catch;

        % Check if we are dealing with an 48 bit image
        if(~isequal('uint16', class(img)))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = sprintf( ...
                'Not an 48 bit image (%s).', ...
                strrep(varargin{idx}, '\', '\\') ...  % Escape backslashes
                );

            % Show error dialog
            msgbox( ...
                { ...
                    strrep(errmsg, '_', '\_'), ...  % Escape underscores
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                sprintf( ...
                    '%s: %s Aborting loading operation ...\n', ...
                    fname, ...
                    errmsg ...
                    ) ...
                );

            % Abort loading the scanset
            return;

        endif;

        % Load required packages
        pkg load image;  % Required for 'isrgb'

        % Check if we have an RGB image
        if(~isrgb(img))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = sprintf( ...
                'Not an RGB image (%s).', ...
                strrep(varargin{idx}, '\', '\\') ...  % Escape backslashes
                );

            % Image does not have three color channels
            msgbox( ...
                { ...
                    strrep(errmsg, '_', '\_'), ...  % Escape underscores
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                sprintf( ...
                    '%s: %s Aborting loading operation ...\n', ...
                    fname, ...
                    errmsg ...
                    ) ...
                );

            % Unload loaded packages
            pkg unload image;

            % Abort loading the scanset
            return;

        endif;

        % Unload loaded packages
        pkg unload image;

        % Check if all given images have the same size as the reference dataset
        if(~isequal(size(img), size(msr.irradiated.pixel_data)))
            % Kill image reading progress tracker
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Format error message string for display to screen
            errmsg = sprintf( ...
                'Image size does not conform to the size of the reference image (%s).', ...
                strrep(varargin{idx}, '\', '\\') ...  % Escape backslashes
                );

            % Image size does not conform to the size of other images
            msgbox( ...
                { ...
                    strrep(errmsg, '_', '\_'), ...  % Escape underscores
                    'Aborting loading operation ...' ...
                    }, ...
                window_title, ...
                'error' ...
                );

            % also send message to the workspace
            fprintf( ...
                stderr(), ...
                sprintf( ...
                    '%s: %s Aborting loading operation ...\n', ...
                    fname, ...
                    errmsg ...
                    ) ...
                );

            % Clean up GUI
            if(ishandle(progress_tracker))
                delete(progress_tracker);

            endif;

            % Abort loading the scanset
            return;

        endif;

        if(1 == idx)
            % If this is the first image read, allocate space for the
            % mean pixel values and pixelwise standard deviation
            pwstd = pwmean = zeros(size(img));

        endif;

        % Smooth out pixel data if required
        smoothed = zeros(size(img));
        if(isequal('median', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using median filter
            smoothed(:, :, 1) = medfilt2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = medfilt2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = medfilt2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wiener', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using wiener filter
            smoothed(:, :, 1) = wiener2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = wiener2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = wiener2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wavelet_db8', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load ltfat;

            % Smooth data using Daubechies wavelet of 8th order and threshoding
            R_c = fwt2(double(img(:, :, 1)), 'db8', 3);
            G_c = fwt2(double(img(:, :, 2)), 'db8', 3);
            B_c = fwt2(double(img(:, :, 3)), 'db8', 3);
            R_c = thresh(R_c, 2000);
            G_c = thresh(G_c, 2000);
            B_c = thresh(B_c, 2000);
            smoothed(:, :, 1) = ifwt2( ...
                R_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 2) = ifwt2( ...
                G_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 3) = ifwt2( ...
                B_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );

            % Unload loaded package
            pkg unload ltfat;

        else
            smoothed = img;

        endif;

        % Accumulate mean pixel value
        pwmean = pwmean + (double(smoothed) ./ (nargin - 2));

        waitbar(idx/(nargin - 2), progress_tracker);

        idx = idx + 1;

    endwhile;

    % Kill image reading progress tracker
    if(ishandle(progress_tracker))
        delete(progress_tracker);

    endif;

    % Reset counter
    idx = 1;

    % Display progress information on calculation of standard deviation
    progress_tracker = waitbar( ...
        0.0, ...
        'Calculating standard deviation ...', ...
        'name', progress_tracker_title ...
        );

    % Calculate sum of squared differences from mean pixel value
    while(nargin - 2 >= idx)
        % Read image again
        img = imread(varargin{idx});

        % Smooth out pixel data if required
        smoothed = zeros(size(img));
        if(isequal('median', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using median filter
            smoothed(:, :, 1) = medfilt2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = medfilt2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = medfilt2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wiener', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using wiener filter
            smoothed(:, :, 1) = wiener2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = wiener2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = wiener2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wavelet_db8', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load ltfat;

            % Smooth data using Daubechies wavelet of 8th order and threshoding
            R_c = fwt2(double(img(:, :, 1)), 'db8', 3);
            G_c = fwt2(double(img(:, :, 2)), 'db8', 3);
            B_c = fwt2(double(img(:, :, 3)), 'db8', 3);
            R_c = thresh(R_c, 2000);
            G_c = thresh(G_c, 2000);
            B_c = thresh(B_c, 2000);
            smoothed(:, :, 1) = ifwt2( ...
                R_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 2) = ifwt2( ...
                G_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 3) = ifwt2( ...
                B_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );

            % Unload loaded package
            pkg unload ltfat;

        else
            smoothed = img;

        endif;

        % Accumulate the sum of squared differences
        pwstd = pwstd + (double(smoothed) - pwmean).^2;

        % Update progress tracker
        waitbar(idx/(nargin - 2), progress_tracker);

        idx = idx + 1;

    endwhile;

    % Kill stdev progress tracker
    if(ishandle(progress_tracker))
        delete(progress_tracker);

    endif;

    % Only divide by N - 1 if we are dealing with more than one image (scan)
    if(1 < nargin - 2)
        pwstd = pwstd ./ ((nargin - 2) - 1);

    endif;
    pwstd = pwstd.^0.5;

    % Calculate overall standard deviation as RMS of pixelwise standard
    % deviation
    standard_deviation = rms(pwstd);

    % Fill the return structure with calculated data
    zero_light                    = struct();
    zero_light.scan_date          = sc_date;
    zero_light.file_list          = varargin;
    zero_light.pixel_data         = pwmean;
    zero_light.standard_deviation = standard_deviation;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isZeroLightDataStruct
%
% Use:
%       -- result = isZeroLightDataStruct(zrl)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isZeroLightDataStruct(zrl)

    % Define common message strings
    fname = 'isZeroLightDataStruct';
    use_case = ' -- result = isZeroLightDataStruct(zrl)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(zrl) ...
            && isfield(zrl, 'scan_date') ...
            && isfield(zrl, 'file_list') ...
            && isfield(zrl, 'pixel_data') ...
            && isfield(zrl, 'standard_deviation') ...
            && ischar(zrl.scan_date) ...
            && iscell(zrl.file_list) ...
            && ~isempty(zrl.pixel_data) ...
            && (3 == size(zrl.pixel_data, 3)) ...
            && ismatrix(zrl.pixel_data(:, :, 1)) ...
            && ismatrix(zrl.pixel_data(:, :, 2)) ...
            && ismatrix(zrl.pixel_data(:, :, 3)) ...
            && isvector(zrl.standard_deviation) ...
            && (3 == size(zrl.standard_deviation, 1)) ...
            && isfloat(zrl.standard_deviation) ...
            )
        result = true;

    endif;

endfunction;



% =============================================================================
%
% Dead Pixels Mask Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newDeadPixelsMask
%
% Use:
%       -- dead_pixels_mask = newDeadPixelsMask(msr, threshod)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function dead_pixels_mask = newDeadPixelsMask(msr, threshold)

    % Define common window and message strings
    fname = 'newDeadPixelsMask';
    progress_tracker_title = 'New Dead Pixels Mask';
    use_case = ' -- dead_pixels_mask = newDeadPixelsMask(msr, threshold)';

    % Validate input arguments
    if(2 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isMeasurementDataStruct(msr))
        error('%s: Invalid data or measurement not set.', fname);

    endif;

    if(~isBackgroundDataStruct(msr.background))
        error('%s: Invalid data or background data set not set.', fname);

    endif;

    validateattributes( ...
        threshold, ...
        {'float'}, ...
        {'scalar', '>=', 0, '<=', 1}, ...
        fname, ...
        'threshold' ...
        );

    % Display information on the calculation progress
    progress_tracker = waitbar( ...
        0.0, ...
        'Calculating ...', ...
        'name', progress_tracker_title ...
        );

    % Initialize loop counter
    idx = 1;

    % Allocate memory for storing mask pixels
    pixel_data = ones(size(msr.background.pixel_data));

    % Accumulate dead pixels
    while(numel(msr.background.file_list) >= idx)
        img = imread(msr.background.file_list{idx});

        % Smooth out pixel data if required
        smoothed = zeros(size(img));
        if(isequal('median', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using median filter
            smoothed(:, :, 1) = medfilt2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = medfilt2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = medfilt2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wiener', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load image;

            % Smooth data using wiener filter
            smoothed(:, :, 1) = wiener2( ...
                img(:, :, 1), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 2) = wiener2( ...
                img(:, :, 2), ...
                msr.pixel_data_smoothing.window ...
                );
            smoothed(:, :, 3) = wiener2( ...
                img(:, :, 3), ...
                msr.pixel_data_smoothing.window ...
                );

            % Unload loaded package
            pkg unload image;

        elseif(isequal('wavelet_db8', msr.pixel_data_smoothing.method))
            % Load required package
            pkg load ltfat;

            % Smooth data using Daubechies wavelet of 8th order and threshoding
            R_c = fwt2(double(img(:, :, 1)), 'db8', 3);
            G_c = fwt2(double(img(:, :, 2)), 'db8', 3);
            B_c = fwt2(double(img(:, :, 3)), 'db8', 3);
            R_c = thresh(R_c, 2000);
            G_c = thresh(G_c, 2000);
            B_c = thresh(B_c, 2000);
            smoothed(:, :, 1) = ifwt2( ...
                R_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 2) = ifwt2( ...
                G_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );
            smoothed(:, :, 3) = ifwt2( ...
                B_c, ...
                'db8', ...
                3, ...
                [size(smoothed, 1), size(smoothed, 2)] ...
                );

            % Unload loaded package
            pkg unload ltfat;

        else
            smoothed = img;

        endif;

        red_mask   = smoothed(:, :, 1) > ((1 - threshold)*(intmax('uint16') - 1));
        green_mask = smoothed(:, :, 2) > ((1 - threshold)*(intmax('uint16') - 1));
        blue_mask  = smoothed(:, :, 3) > ((1 - threshold)*(intmax('uint16') - 1));
        pixel_data(:, :, 1) = pixel_data(:, :, 1).*red_mask;
        pixel_data(:, :, 2) = pixel_data(:, :, 2).*green_mask;
        pixel_data(:, :, 3) = pixel_data(:, :, 3).*blue_mask;

        waitbar( ...
            idx/numel(msr.background.file_list), ...
            progress_tracker ...
            );

        idx = idx + 1;

    endwhile;

    % Kill calculation progress tracker
    if(ishandle(progress_tracker))
        delete(progress_tracker);

    endif;

    % Fill the return structure with calculated data
    dead_pixels_mask            = struct();
    dead_pixels_mask.threshold  = threshold;
    dead_pixels_mask.pixel_data = pixel_data;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isDeadPixelsMaskStruct
%
% Use:
%       -- result = isDeadPixelsMaskStruct(dpm)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isDeadPixelsMaskStruct(dpm)

    % Define common message strings
    fname = 'isDeadPixelsMaskStruct';
    use_case = ' -- result = isDeadPixelsMaskStruct(dpm)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(dpm) ...
            && isfield(dpm, 'threshold') ...
            && isfield(dpm, 'pixel_data') ...
            && isscalar(dpm.threshold) ...
            && isfloat(dpm.threshold) ...
            && ~isempty(dpm.pixel_data) ...
            && (3 == size(dpm.pixel_data, 3)) ...
            && ismatrix(dpm.pixel_data(:, :, 1)) ...
            && ismatrix(dpm.pixel_data(:, :, 2)) ...
            && ismatrix(dpm.pixel_data(:, :, 3)) ...
            )
        result = true;

    endif;

endfunction;



% =============================================================================
%
% Optical Density Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newOpticalDensity
%
% Use:
%       -- optical_density = newOpticalDensity(msr)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function optical_density = newOpticalDensity(msr)

    % Define common message strings
    fname = 'newOpticalDensity';
    use_case = ' -- optical_density = newOpticalDensity(msr)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isMeasurementDataStruct(msr))
        error('%s: Invalid data or measurement not set.', fname);

    endif;

    if(~isIrradiatedDataStruct(msr.irradiated))
        error('%s: Invalid data or irradiated data set not set.', fname);

    endif;

    if(~isBackgroundDataStruct(msr.background))
        error('%s: Invalid data or background data set not set.', fname);

    endif;

    % Initialize data structures for keeping computation results
    optical_density = struct();
    pixel_data = [];

    % Allocate memory for optical density values
    pixel_data = zeros(size(msr.irradiated.pixel_data));

    if(isZeroLightDataStruct(msr.zero_light))
        I0 = ...
            msr.background.pixel_data ...
            - msr.zero_light.pixel_data;
        It = ...
            msr.irradiated.pixel_data ...
            - msr.zero_light.pixel_data;

    else
        I0 = msr.background.pixel_data;
        It = msr.irradiated.pixel_data;

    endif;

    % Calculate optical density
    pixel_data = log10(I0./It);

    % Fill the return structure with calculated data
    optical_density.pixel_data = pixel_data;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isOpticalDensityStruct
%
% Use:
%       -- result = isOpticalDensityStruct(od)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isOpticalDensityStruct(od)

    % Define common message strings
    fname = 'isOpticalDensityStruct';
    use_case = ' -- result = isOpticalDensityStruct(od)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(od) ...
            && isfield(od, 'pixel_data') ...
            && ~isempty(od.pixel_data) ...
            && (3 == size(od.pixel_data, 3)) ...
            && ismatrix(od.pixel_data(:, :, 1)) ...
            && ismatrix(od.pixel_data(:, :, 2)) ...
            && ismatrix(od.pixel_data(:, :, 3)) ...
            )
        result = true;

    endif;

endfunction;



% =============================================================================
%
% ROI Density Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newRoi
%
% Use:
%       -- roi = newRoi(msr, roi_window)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function roi = newRoi(msr, roi_window)

    % Define common message strings
    fname = 'newRoi';
    use_case = ' -- roi = newOpticalDensity(msr, roi_window)';

    % Validate input arguments
    if(2 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isMeasurementDataStruct(msr))
        error('%s: msr must be a Measurement object', fname);

    endif;

    if(~isRoiWindow(roi_window))
        error('%s: roi_window must be a ROI Window object', fname);

    endif;

    % Fit roi_window to image space if needed
    roi_window = fitRoiToImageSpace( ...
        [ ...
            size(msr.optical_density.pixel_data, 2), ...
            size(msr.optical_density.pixel_data, 1) ...
            ], ...
        roi_window ...
        );

    roi_msk = roiDeadPixelsMask(msr.dead_pixels_mask, roi_window);
    dp_count = [0, 0, 0];
    dp_count(1) = sum(~roi_msk(:, :, 1)(:));
    dp_count(2) = sum(~roi_msk(:, :, 2)(:));
    dp_count(3) = sum(~roi_msk(:, :, 3)(:));
    rel_dp_count = [0, 0, 0];
    rel_dp_count(1) = dp_count(1)*100/numel(roi_msk(:, :, 1));
    rel_dp_count(2) = dp_count(2)*100/numel(roi_msk(:, :, 2));
    rel_dp_count(3) = dp_count(3)*100/numel(roi_msk(:, :, 3));
    clear('roi_msk');
    roi_od_mean = roiOpticalDensityMean( ...
        msr.optical_density, ...
        msr.dead_pixels_mask, ...
        roi_window ...
        );
    roi_od_stdev = roiOpticalDensityStd( ...
        msr.optical_density, ...
        msr.dead_pixels_mask, ...
        roi_window ...
        );
    roi_od_hist = roiOpticalDensityHist(
        msr.optical_density, ...
        msr.dead_pixels_mask, ...
        roi_window, ...
        64 ...
        );
    roi_snr = roiSnr( ...
        msr.irradiated, ...
        msr.background, ...
        msr.zero_light, ...
        msr.dead_pixels_mask, ...
        roi_window ...
        );

    roi = struct();

    roi.extents_px = roiExtents(roi_window);
    roi.extents_mm = [];  % Set roi extents in milimiters to default value
    % If scanning resolution and resolution units are set calculate ROI extents
    % in milimeters
    if( ...
            isequal('Inch', msr.scanner_device.resolution_unit) ...
            && ~isequal('Unknown', msr.scanner_device.scanning_resolution) ...
            )
        dpi = str2double(msr.scanner_device.scanning_resolution);
        roi.extents_mm = [0, 0, 0, 0];
        roi.extents_mm(1) = pixelsToMilimeters(dpi, roi.extents_px(1));
        roi.extents_mm(2) = pixelsToMilimeters(dpi, roi.extents_px(2));
        roi.extents_mm(3) = pixelsToMilimeters(dpi, roi.extents_px(3));
        roi.extents_mm(4) = pixelsToMilimeters(dpi, roi.extents_px(4));

    endif;

    roi.od = roi_od_mean;
    roi.od_stdev = roi_od_stdev;
    roi.od_hist = roi_od_hist;
    roi.snr = roi_snr;
    roi.dead_pixels_count = dp_count;
    roi.relative_dead_pixels_count = rel_dp_count;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: newRoiWindow
%
% Use:
%       -- roi_window = newRoiWindow(x, y, rsize)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function roi_window = newRoiWindow(x, y, rsize)

    % Define common window and message strings
    fname = 'newRoiWindow';
    use_case = ' -- roi_window = newRoiWindow(x, y, rsize)';

    % Validate input arguments
    if(3 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    validateattributes( ...
        x, ...
        {'numeric'}, ...
        { ...
            '>=', 0, ...
            'finite', ...
            'integer', ...
            'nonempty', ...
            'nonnan', ...
            'scalar' ...
            }, ...
        fname, ...
        'x' ...
        );
    validateattributes( ...
        y, ...
        {'numeric'}, ...
        { ...
            '>=', 0, ...
            'finite', ...
            'integer', ...
            'nonempty', ...
            'nonnan', ...
            'scalar' ...
            }, ...
        fname, ...
        'y' ...
        );
    validateattributes( ...
        rsize, ...
        {'numeric'}, ...
        { ...
            '>=', 0, ...
            'finite', ...
            'integer', ...
            'nonempty', ...
            'nonnan', ...
            'scalar' ...
            }, ...
        fname, ...
        'rsize' ...
        );

    roi_window = [x, y, rsize];

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isRoiWindow
%
% Use:
%       -- result = isRoiWindow(roi_window)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isRoiWindow(roi_window)

    % Define common message strings
    fname = 'isRoiWindow';
    use_case = ' -- result = isRoiWindow(roi_window)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = true;

    try
        validateattributes( ...
            roi_window, ...
            {'numeric'}, ...
            { ...
                'nonempty', ...
                'nonnan', ...
                'row', ...
                '2d', ...
                'ncols', 3, ...
                'nrows', 1, ...
                'numel', 3, ...
                'integer', ...
                '>=', 0, ...
                'finite' ...
                } ...
            );

    catch err
        result = false;

    end_try_catch;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: roiExtents
%
% Use:
%       -- roi_extents = roiExtents(roi_window)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function roi_extents = roiExtents(roi_window)

    % Define common message strings
    fname = 'roiExtents';
    use_case = ' -- roi_extents = roiExtents(roi_window)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isRoiWindow(roi_window))
        error('%s: roi_window must be a ROI Window object', fname);

    endif;

    roi_extents = [0, 0, 0, 0];
    roi_extents(1) = roi_window(1) - round(roi_window(3)/2);
    roi_extents(2) = roi_window(2) - round(roi_window(3)/2);
    roi_extents(3) = roi_window(1) + round(roi_window(3)/2);
    roi_extents(4) = roi_window(2) + round(roi_window(3)/2);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'fitRoiToImageSpace':
%
% -- fit_roi = itRoiToImageSpace(image_size, roi_window)
%
%     For image size given as two elements vector [image_width, image_height]
%     and for given ROI window as three elements vector [roi_center_x,
%     roi_center_y, roi_size] recalculate the new ROI window such that center
%     of new ROI fits into image space (image extents) and return new ROI
%     window. If center and size of ROI are already such that ROI fits into the
%     image return the copy of original ROI window.
%
% -----------------------------------------------------------------------------
function fit_roi = fitRoiToImageSpace(image_size, roi_window)

    % Define common message strings
    fname = 'roiExtents';
    use_case = ' -- fit_roi = itRoiToImageSpace(image_size, roi_window)';

    % Validate input arguments
    if(2 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    validateattributes( ...
        image_size, ...
        {'numeric'}, ...
        { ...
            'nonempty', ...
            'nonnan', ...
            'row', ...
            '2d', ...
            'numel', 2, ...
            'integer', ...
            '>=', 0, ...
            'finite' ...
            }, ...
        fname, ...
        'image_size' ...
        );

    if(~isRoiWindow(roi_window))
        error('%s: roi_window must be a ROI Window object', fname);

    endif;

    fit_roi = roi_window;

    % Check if ROI is larger than image extents. Clip image space few pixels so
    % we can counteract rounding errors in ROI extents recalculation for ROIs
    % just few pixels smaller than image space (this is highly unlikely
    % scenario but ...)
    if(min(image_size(1) - 2, image_size(2) - 2) <= roi_window(3))
        % This the case when ROI is larger than image extents. Set roi window
        % size to size of the shorter image border and put ROI in the center of
        % the image
        fit_roi(1) = round(image_size(1)/2);
        fit_roi(2) = round(image_size(2)/2);
        fit_roi(3) = 2*min( ...
            min(image_size(1) - fit_roi(1), fit_roi(1)), ...
            min(image_size(2) - fit_roi(2), fit_roi(2)) ...
            );

        return;

    endif;

    % ROI is smaller than image extents. Calculate ROI extents
    roi_extents = roiExtents(roi_window);

    % We can have folowing cases of ROI position regarding image space:
    %
    %     i) right  <= 0           => ROI is outside the image space;
    %    ii) bottom <= 0           => ROI is outside the image space;
    %   iii) left   >= img_width   => ROI is outside the image space;
    %    iv) top    >= img_height  => ROI is outside the image space;
    %     v) left   <  0           => ROI is partialy outside the image space;
    %    vi) top    <  0           => ROI is partialy outside the image space;
    %   vii) right  > image_width  => ROI is partialy outside the image space;
    %  viii) bottom > image_height => ROI is partialy outside the image space;
    %
    % Required actions in these cases are as follows:
    %
    %     i) set left = 0, recalculate roix;
    %    ii) set top = 0, recalculate roiy;
    %   iii) set right = img_width, recalculate roix;
    %    iv) set bottom = img_height, recalculate roiy;
    %     v) set left = 0, recalculate roix
    %    vi) set top = 0, recalculate roiy;
    %   vii) set right = img_width, recalculate roix;
    %  viii) set bottom = img_height, recalculate roiy;
    %
    if(0 >= roi_extents(3) || 0 > roi_extents(1))
        fit_roi(1) = roi_window(1) + (0 - roi_extents(1));

    endif;

    if(0 >= roi_extents(4) || 0 > roi_extents(2))
        fit_roi(2) = roi_window(2) + (0 - roi_extents(2));

    endif;

    if(image_size(1) <= roi_extents(1) || image_size(1) < roi_extents(3))
        fit_roi(1) = roi_window(1) + (image_size(1) - roi_extents(3));

    endif;

    if(image_size(2) <= roi_extents(2) || image_size(2) < roi_extents(4))
        fit_roi(2) = roi_window(2) + (image_size(2) - roi_extents(4));

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: roiDeadPixelsMask
%
% Use:
%       -- roi_msk = roiDeadPixelsMask(dp_mask, roi_window)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function roi_msk = roiDeadPixelsMask(dp_mask, roi_window)

    % Define common message strings
    fname = 'roiOpticalDensityMean';
    use_case = ' -- od_mean = roiOpticalDensityMean(dp_mask, roi_window)';

    % Validate input arguments
    if(2 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isDeadPixelsMaskStruct(dp_mask))
        error('%s: Invalid data or dead pixels mask not set.', fname);

    endif;

    if(~isRoiWindow(roi_window))
        error('%s: roi_window must be a ROI Window object', fname);

    endif;

    roi_msk = [];
    roi_extents = roiExtents(roi_window);
    roi_msk = dp_mask.pixel_data( ...
        roi_extents(2):roi_extents(4), ...
        roi_extents(1):roi_extents(3), ...
        : ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function: roiOpticalDensityMean
%
% Use:
%       -- od_mean = roiOpticalDensityMean(od_obj, dp_mask, roi_window)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function od_mean = roiOpticalDensityMean(od_obj, dp_mask, roi_window)

    % Define common message strings
    fname = 'roiOpticalDensityMean';
    use_case = ' -- od_mean = roiOpticalDensityMean(od_obj, dp_mask, roi_window)';

    % Validate input arguments
    if(3 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isOpticalDensityStruct(od_obj))
        error('%s: Invalid data or optical density data set not set.', fname);

    endif;

    if(~isDeadPixelsMaskStruct(dp_mask))
        error('%s: Invalid data or dead pixels mask not set.', fname);

    endif;

    if(~isRoiWindow(roi_window))
        error('%s: roi_window must be a ROI Window object', fname);

    endif;

    od_mean = [];
    roi_extents = roiExtents(roi_window);
    roi_msk = roiDeadPixelsMask(dp_mask, roi_window);
    roi_pixel_data = od_obj.pixel_data( ...
        roi_extents(2):roi_extents(4), ...
        roi_extents(1):roi_extents(3), ...
        : ...
        );
    od_mean = [od_mean, mean(roi_pixel_data(:, :, 1)(logical(roi_msk(:, :, 1))))];
    od_mean = [od_mean, mean(roi_pixel_data(:, :, 2)(logical(roi_msk(:, :, 2))))];
    od_mean = [od_mean, mean(roi_pixel_data(:, :, 3)(logical(roi_msk(:, :, 3))))];

endfunction;

% -----------------------------------------------------------------------------
%
% Function: roiOpticalDensityStd
%
% Use:
%       -- od_std = roiOpticalDensityStd(od_obj, dp_mask, roi_window)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function od_std = roiOpticalDensityStd(od_obj, dp_mask, roi_window)

    % Define common message strings
    fname = 'roiOpticalDensityStd';
    use_case = ' -- od_std = roiOpticalDensityStd(od_obj, dp_mask, roi_window)';

    % Validate input arguments
    if(3 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isOpticalDensityStruct(od_obj))
        error('%s: Invalid data or optical density data set not set.', fname);

    endif;

    if(~isDeadPixelsMaskStruct(dp_mask))
        error('%s: Invalid data or dead pixels mask not set.', fname);

    endif;

    if(~isRoiWindow(roi_window))
        error('%s: roi_window must be a ROI Window object', fname);

    endif;

    od_std = [];
    roi_extents = roiExtents(roi_window);
    roi_msk = roiDeadPixelsMask(dp_mask, roi_window);
    roi_pixel_data = od_obj.pixel_data( ...
        roi_extents(2):roi_extents(4), ...
        roi_extents(1):roi_extents(3), ...
        : ...
        );
    od_std = [od_std, std(roi_pixel_data(:, :, 1)(logical(roi_msk(:, :, 1))))];
    od_std = [od_std, std(roi_pixel_data(:, :, 2)(logical(roi_msk(:, :, 2))))];
    od_std = [od_std, std(roi_pixel_data(:, :, 3)(logical(roi_msk(:, :, 3))))];

endfunction;

% -----------------------------------------------------------------------------
%
% Function: roiOpticalDensityHist
%
% Use:
%       -- od_hist = roiOpticalDensityHist(od_obj, dp_mask, roi_window, nbins)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function od_hist = roiOpticalDensityHist(od_obj, dp_mask, roi_window, nbins)

    % Define common message strings
    fname = 'roiOpticalDensityHist';
    use_case = ' -- od_hist = roiOpticalDensityHist(od_obj, dp_mask, roi_window, nbins)';

    % Validate input arguments
    if(4 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isOpticalDensityStruct(od_obj))
        error('%s: Invalid data or optical density data set not set.', fname);

    endif;

    if(~isDeadPixelsMaskStruct(dp_mask))
        error('%s: Invalid data or dead pixels mask not set.', fname);

    endif;

    if(~isRoiWindow(roi_window))
        error('%s: roi_window must be a ROI Window object', fname);

    endif;

    validateattributes( ...
        nbins, ...
        {'numeric'}, ...
        { ...
            'scalar', ...
            'nonempty', ...
            'nonnan', ...
            'integer', ...
            'finite', ...
            '>=', 2 ...
            }, ...
        fname, ...
        'item' ...
        );

    roi_extents = roiExtents(roi_window);
    roi_msk = roiDeadPixelsMask(dp_mask, roi_window);
    roi_pixel_data = od_obj.pixel_data( ...
        roi_extents(2):roi_extents(4), ...
        roi_extents(1):roi_extents(3), ...
        : ...
        );
    od_min = [ ...
        min(roi_pixel_data(:, :, 1)(logical(roi_msk(:, :, 1)))), ...
        min(roi_pixel_data(:, :, 2)(logical(roi_msk(:, :, 2)))), ...
        min(roi_pixel_data(:, :, 3)(logical(roi_msk(:, :, 3)))) ...
        ];
    od_max = [ ...
        max(roi_pixel_data(:, :, 1)(logical(roi_msk(:, :, 1)))), ...
        max(roi_pixel_data(:, :, 2)(logical(roi_msk(:, :, 2)))), ...
        max(roi_pixel_data(:, :, 3)(logical(roi_msk(:, :, 3)))) ...
        ];
    od_depth = od_max - od_min;
    binsz = od_depth./(nbins - 1);
    centers = zeros(nbins, 3);
    dist = zeros(nbins, 3);

    idx = 1;
    while(nbins >= idx)
        centers(idx, 1) = od_min(1) + (idx - 1)*binsz(1);
        centers(idx, 2) = od_min(2) + (idx - 1)*binsz(2);
        centers(idx, 3) = od_min(3) + (idx - 1)*binsz(3);

        lbound = [ ...
            od_min(1) + (idx - 1.5)*binsz(1), ...
            od_min(2) + (idx - 1.5)*binsz(2), ...
            od_min(3) + (idx - 1.5)*binsz(3) ...
            ];
        lmask = zeros(size(roi_pixel_data));
        lmask(:, :, 1) = roi_pixel_data(:, :, 1) > lbound(1);
        lmask(:, :, 2) = roi_pixel_data(:, :, 2) > lbound(2);
        lmask(:, :, 3) = roi_pixel_data(:, :, 3) > lbound(3);

        ubound = [ ...
            od_min(1) + (idx - 0.5)*binsz(1), ...
            od_min(2) + (idx - 0.5)*binsz(2), ...
            od_min(3) + (idx - 0.5)*binsz(3) ...
            ];
        umask = zeros(size(roi_pixel_data));
        umask(:, :, 1) = roi_pixel_data(:, :, 1) <= ubound(1);
        umask(:, :, 2) = roi_pixel_data(:, :, 2) <= ubound(2);
        umask(:, :, 3) = roi_pixel_data(:, :, 3) <= ubound(3);

        dist(idx, 1) = sum((lmask(:, :, 1).*umask(:, :, 1))(:));
        dist(idx, 2) = sum((lmask(:, :, 2).*umask(:, :, 2))(:));
        dist(idx, 3) = sum((lmask(:, :, 3).*umask(:, :, 3))(:));

        idx = idx + 1;

    endwhile;

    od_hist = struct();
    od_hist.bins = centers;
    od_hist.dist = dist;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: roiSnr
%
% Use:
%       -- roi_snr = roiSnr(irr, bkg, zrl, dp_mask, roi_window)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function roi_snr = roiSnr(irr, bkg, zrl, dp_mask, roi_window)

    % Define common message strings
    fname = 'roiSnr';
    use_case = ' -- roi_snr = roiSnr(irr, bkg, zrl, dp_mask, roi_window)';

    % Validate input arguments
    if(5 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isIrradiatedDataStruct(irr))
        error('%s: Invalid data or irradiated data set not set.', fname);

    endif;

    if(~isBackgroundDataStruct(bkg))
        error('%s: Invalid data or background data set not set.', fname);

    endif;

    if(~isZeroLightDataStruct(zrl) && ~isnan(zrl))
        error('%s: zrl must be NaN or a ZeroLight object.', fname);

    endif;

    if(~isDeadPixelsMaskStruct(dp_mask))
        error('%s: Invalid data or dead pixels mask not set.', fname);

    endif;

    if(~isRoiWindow(roi_window))
        error('%s: roi_window must be a ROI Window object', fname);

    endif;

    roi_extents = roiExtents(roi_window);
    roi_msk = logical(roiDeadPixelsMask(dp_mask, roi_window));
    irr_roi = irr.pixel_data( ...
        roi_extents(2):roi_extents(4), ...
        roi_extents(1):roi_extents(3), ...
        : ...
        );
    bkg_roi = bkg.pixel_data( ...
        roi_extents(2):roi_extents(4), ...
        roi_extents(1):roi_extents(3), ...
        : ...
        );
    zrl_roi = NaN;
    if(isZeroLightDataStruct(zrl))
        zrl_roi = zrl.pixel_data( ...
            roi_extents(2):roi_extents(4), ...
            roi_extents(1):roi_extents(3), ...
            : ...
            );
    endif;

    irr_mean = [0, 0, 0];
    bkg_std = [0, 0, 0];
    if(isnan(zrl_roi))
        irr_mean(1) = mean(irr_roi(:, :, 1)(roi_msk(:, :, 1)));
        irr_mean(2) = mean(irr_roi(:, :, 2)(roi_msk(:, :, 2)));
        irr_mean(3) = mean(irr_roi(:, :, 3)(roi_msk(:, :, 3)));
        bkg_std(1) = std(bkg_roi(:, :, 1)(roi_msk(:, :, 1)));
        bkg_std(2) = std(bkg_roi(:, :, 2)(roi_msk(:, :, 2)));
        bkg_std(3) = std(bkg_roi(:, :, 3)(roi_msk(:, :, 3)));

    else
        irr_mean(1) = mean((irr_roi(:, :, 1) - zrl_roi(:, :, 1))(roi_msk(:, :, 1)));
        irr_mean(2) = mean((irr_roi(:, :, 2) - zrl_roi(:, :, 2))(roi_msk(:, :, 2)));
        irr_mean(3) = mean((irr_roi(:, :, 3) - zrl_roi(:, :, 3))(roi_msk(:, :, 3)));
        bkg_std(1) = std((bkg_roi(:, :, 1) - zrl_roi(:, :, 1))(roi_msk(:, :, 1)));
        bkg_std(2) = std((bkg_roi(:, :, 2) - zrl_roi(:, :, 2))(roi_msk(:, :, 2)));
        bkg_std(3) = std((bkg_roi(:, :, 3) - zrl_roi(:, :, 3))(roi_msk(:, :, 3)));

    endif;

    % Invert signal to get valid value
    irr_mean = intmax('uint16') - irr_mean;

    roi_snr = irr_mean./bkg_std;

endfunction;



% =============================================================================
%
% Auxiliary Data Processing Routines Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: rms
%
% Use:
%       -- result = rms(X)
%
% Description: calculate a RMS value for the given array of numbers
%
% -----------------------------------------------------------------------------
function result = rms(X)

    % TODO: Put input validation here

    result = [0; 0; 0];
    result(1) = sqrt(sum(sum(X(:, :, 1).*X(:, :, 1)))/numel(X(:, :, 1)));
    result(2) = sqrt(sum(sum(X(:, :, 2).*X(:, :, 2)))/numel(X(:, :, 2)));
    result(3) = sqrt(sum(sum(X(:, :, 3).*X(:, :, 1)))/numel(X(:, :, 3)));

endfunction;

% -----------------------------------------------------------------------------
%
% Function: renderImageFrom2DMatrix
%
% Use:
%       -- I = renderImageFrom2DMatrix(M)
%
% Description: render 2D matrix data as an monochrome image
%
% -----------------------------------------------------------------------------
function I = renderImageFrom2DMatrix(M)

    % TODO: Put input validation here

    % Load required packages
    pkg load image;

    I = mat2gray(M);

    % Unload loaded packages
    pkg unload image;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: renderImageFrom3DMatrix
%
% Use:
%       -- I = renderImageFrom3DMatrix(M)
%
% Description: render 3D matrix data as an RGB image
%
% -----------------------------------------------------------------------------
function I = renderImageFrom3DMatrix(M)

    % TODO: Put input validation here

    % Load required packages
    pkg load image;

    I = cat( ...
        3, ...
        mat2gray(M(:, :, 1)), ...
        mat2gray(M(:, :, 2)), ...
        mat2gray(M(:, :, 3)) ...
        );

    % Unload loaded packages
    pkg unload image;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: milimetersToPixels
%
% Use:
%       -- len_px = milimetersToPixels(dpi, len_mm)
%
% Description: for given length in milimeters and given dpi calculate the
%              corresponding length in pixels
%
% -----------------------------------------------------------------------------
function len_px = milimetersToPixels(dpi, len_mm)

    % TODO: Put input validation here

    len_px = round((dpi/25.4)*len_mm);

endfunction;

% -----------------------------------------------------------------------------
%
% Function: pixelsToMilimeters
%
% Use:
%       -- len_mm = pixelsToMilimeters(dpi, len_px)
%
% Description: for given length in pixels and given dpi calculate the
%              coressponding length in milimeters
%
% -----------------------------------------------------------------------------
function len_mm = pixelsToMilimeters(dpi, len_px)

    % TODO: Put input validation here

    len_mm = (25.4/dpi)*len_px;

endfunction;




% =============================================================================
%
% GUI Routines Section
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

    % Allocate structure for storing gui elemnents ----------------------------
    gui = struct();

    % Create main figure ------------------------------------------------------
    gui.main_figure = figure( ...
        'name', 'RCT Analyze Film', ...
        'tag', 'main_figure', ...
        'menubar', 'none', ...
        % 'sizechangedfcn', @uiResize, ... %TODO: remove comment when all GUI elemts implemented
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
    gui.fm_new_measurement = uimenu( ...
        'parent', gui.file_menu, ...
        'tag', 'fm_new_measurement', ...
        'label', 'New &Measurement', ...
        'accelerator', 'm', ...
        'callback', @(src, evt)uiNewMeasurement(app_obj) ...
        );
    gui.fm_export_to_workspace = uimenu( ...
        'parent', gui.file_menu, ...
        'tag', 'fm_export_to_workspace', ...
        'label', 'Export Measurement to &Workspace', ...
        'accelerator', 'w', ...
        'separator', 'on', ...
        'callback', @(src, evt)uiExportTo('workspace') ...
        );
    gui.fm_export_to_json = uimenu( ...
        'parent', gui.file_menu, ...
        'tag', 'fm_export_to_json', ...
        'label', 'Export Measurement to &JSON File', ...
        'accelerator', 'j', ...
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

endfunction;

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
function uiNewMeasurement(app_obj)

    app_obj.measurement = newMeasurement();
    app_obj.measurement.field = newField();
    app_obj.measurement.film = newFilm(app_obj.filmdb, 1);

    parameters = struct();
    handles    = struct();

    % Define static UI parameters
    parameters.header_height_px = 72;
    parameters.padding_px = 6;
    parameters.row_height_px = 24;
    parameters.btn_width_px = 128;

    % Create 'New Measurement' figure -----------------------------------------
    handles.new_msr_figure = figure( ...
        % 'parent', app_obj.gui.main_figure, ...
        'name', 'RCT Analyze Film: Setup New Measuremnt', ...
        'tag', 'new_msr_figure', ...
        'menubar', 'none', ...
        'sizechangedfcn', @uiNewMeasurementResize ...
        % 'position', uiCalculateInitialPosition(get(0, 'ScreenSize')) ...
        );

    % Split figure space into three horizontal sections: 'Header', 'Form' and
    % 'Control' ('Footer') ----------------------------------------------------
    position = uiNewMeasurementElementsPosition( ...
        handles.new_msr_figure, ...
        parameters ...
        );
    handles.control_panel = uipanel( ...
        'parent', handles.new_msr_figure, ...
        'tag', 'control_panel', ...
        'bordertype', 'none', ...
        'position', position(1, :) ...
        );
    handles.form_panel = uipanel( ...
        'parent', handles.new_msr_figure, ...
        'tag', 'form_panel', ...
        'bordertype', 'none', ...
        'position', position(2, :) ...
        );
    handles.header_panel = uipanel( ...
        'parent', handles.new_msr_figure, ...
        'tag', 'header_panel', ...
        'bordertype', 'none', ...
        'position', position(3, :) ...
        );

    % Create 'Control' panel controls -----------------------------------------
    position = uiControlPanelElementsPostion( ...
        handles.control_panel, ...
        parameters ...
        );
    handles.cancel_button = uicontrol( ...
        'parent', handles.control_panel, ...
        'style', 'pushbutton', ...
        'tag', 'cancel_button', ...
        'string', 'Cancel', ...
        'callback', @uiCancelNewMeasurement, ...
        'units', 'normalized', ...
        'position', position(1, :) ...
        );
    handles.create_button = uicontrol( ...
        'parent', handles.control_panel, ...
        'style', 'pushbutton', ...
        'tag', 'create_button', ...
        'string', 'Create', ...
        'callback', @uiCreateNewMeasurement, ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );

    % Split 'Form' panel into five even vertical sections ---------------------
    position = uiFormPanelElementsPosition( ...
        handles.form_panel, ...
        parameters ...
        );
    idx = 1;
    while(length(position) >= idx)
        uipanel( ...
            'parent', handles.form_panel, ...
            'tag', sprintf('vpanel_%d', idx), ...
            'bordertype', 'none', ...
            'position', position(idx, :) ...
            );

        idx = idx + 1;

    endwhile;

    % Create 'Title & Date', 'Field' and 'Film' panels ------------------------
    position = uiVerticalPanelElementsPosition('vpanel_1', handles, parameters);
    handles.film_panel = uipanel( ...
        'parent', uiGetChildByTag(handles.form_panel, 'vpanel_1'), ...
        'tag', 'film_panel', ...
        'title', 'Film', ...
        'position', position(1, :) ...
        );
    handles.field_panel = uipanel( ...
        'parent', uiGetChildByTag(handles.form_panel, 'vpanel_1'), ...
        'tag', 'field_panel', ...
        'title', 'Radiation Field', ...
        'position', position(2, :) ...
        );
    handles.title_and_date_panel = uipanel( ...
        'parent', uiGetChildByTag(handles.form_panel, 'vpanel_1'), ...
        'tag', 'title_and_date_panel', ...
        'title', 'Title & Date', ...
        'position', position(3, :) ...
        );

    % Create 'Title & Date' panel controls ------------------------------------
    position = uiInputElementsPostion( ...
        handles.title_and_date_panel, ...
        parameters, ...
        2 ...
        );
    handles.edit_date = uicontrol( ...
        'parent', handles.title_and_date_panel, ...
        'style', 'edit', ...
        'tag', 'edit_measurement_date', ...
        'string', app_obj.measurement.date, ...
        'tooltipstring', 'Input measurement date', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(1, :) ...
        );
    handles.label_date = uicontrol( ...
        'parent', handles.title_and_date_panel, ...
        'style', 'text', ...
        'tag', 'label_measurement_date', ...
        'string', 'Date: ', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );
    handles.edit_title = uicontrol( ...
        'parent', handles.title_and_date_panel, ...
        'style', 'edit', ...
        'tag', 'edit_measurement_title', ...
        'string', app_obj.measurement.title, ...
        'tooltipstring', 'Input measurement title', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(3, :) ...
        );
    handles.label_title = uicontrol( ...
        'parent', handles.title_and_date_panel, ...
        'style', 'text', ...
        'tag', 'label_measurement_title', ...
        'string', 'Title: ', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(4, :) ...
        );

    % Create 'Field' panel controls ------------------------------------
    position = uiInputElementsPostion( ...
        handles.field_panel, ...
        parameters, ...
        4 ...
        );
    handles.edit_field_size = uicontrol( ...
        'parent', handles.field_panel, ...
        'style', 'edit', ...
        'tag', 'edit_field_size', ...
        'string', app_obj.measurement.field.field_size, ...
        'tooltipstring', 'Input field size', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(1, :) ...
        );
    handles.label_field_size = uicontrol( ...
        'parent', handles.field_panel, ...
        'style', 'text', ...
        'tag', 'label_measurement_date', ...
        'string', 'Field size: ', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );
    handles.edit_field_shape = uicontrol( ...
        'parent', handles.field_panel, ...
        'style', 'popupmenu', ...
        'tag', 'edit_field_shape', ...
        'string', { ...
            'Unknown', ...
            'Circular', ...
            'Rectangular', ...
            'Square', ...
            'Irregular' ...
            }, ...
        % 'value', app_obj.measurement.field.field_shape,
        'tooltipstring', 'Select field shape', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(3, :) ...
        );
    handles.label_field_shape = uicontrol( ...
        'parent', handles.field_panel, ...
        'style', 'text', ...
        'tag', 'label_field_shape', ...
        'string', 'Field shape: ', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(4, :) ...
        );
    handles.edit_beam_energy = uicontrol( ...
        'parent', handles.field_panel, ...
        'style', 'edit', ...
        'tag', 'edit_beam_energy', ...
        'string', app_obj.measurement.field.beam_energy, ...
        'tooltipstring', 'Input beam energy', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(5, :) ...
        );
    handles.label_beam_energy = uicontrol( ...
        'parent', handles.field_panel, ...
        'style', 'text', ...
        'tag', 'label_beam_energy', ...
        'string', 'Beam energy: ', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(6, :) ...
        );
    handles.edit_beam_type = uicontrol( ...
        'parent', handles.field_panel, ...
        'style', 'popupmenu', ...
        'tag', 'edit_beam_type', ...
        'string', {'Unknown', 'Photon', 'Electron', 'Proton'}, ...
        % 'value', app_obj.measurement.field.beam_type, ...
        'tooltipstring', 'Select beam type', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(7, :) ...
        );
    handles.label_beam_type = uicontrol( ...
        'parent', handles.field_panel, ...
        'style', 'text', ...
        'tag', 'label_beam_type', ...
        'string', 'Beam type: ', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(8, :) ...
        );

    % Create 'Film' panel controls ------------------------------------
    position = uiInputElementsPostion( ...
        handles.film_panel, ...
        parameters, ...
        3 ...
        );
    handles.edit_film_custom_cut = uicontrol( ...
        'parent', handles.film_panel, ...
        'style', 'popupmenu', ...
        'tag', 'edit_film_custom_cut', ...
        'string', {'Unknown', 'True', 'False'}, ...
        'tooltipstring', 'Choose if film piece is custom cut', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(1, :) ...
        );
    handles.label_film_custom_cut = uicontrol( ...
        'parent', handles.film_panel, ...
        'style', 'text', ...
        'tag', 'label_film_custom_cut', ...
        'string', 'Custom cut: ', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );
    handles.edit_film_model = uicontrol( ...
        'parent', handles.film_panel, ...
        'style', 'edit', ...
        'tag', 'edit_film_model', ...
        'string', app_obj.measurement.film.model, ...
        'tooltipstring', 'Input film model', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(3, :) ...
        );
    handles.label_film_model = uicontrol( ...
        'parent', handles.film_panel, ...
        'style', 'text', ...
        'tag', 'label_film_model', ...
        'string', 'Film model: ', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(4, :) ...
        );
    handles.edit_film_manufacturer = uicontrol( ...
        'parent', handles.film_panel, ...
        'style', 'edit', ...
        'tag', 'edit_film_manufacturer', ...
        'string', app_obj.measurement.film.manufacturer, ...
        'tooltipstring', 'Input film manufacturer', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(5, :) ...
        );
    handles.label_film_manufacturer = uicontrol( ...
        'parent', handles.film_panel, ...
        'style', 'text', ...
        'tag', 'label_film_manufacturer', ...
        'string', 'Film manufacturer: ', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(6, :) ...
        );

    % Create 'Scanner Device' and 'Pixel Data Smoothing' panels ---------------
    position = uiVerticalPanelElementsPosition( ...
        'vpanel_2', ...
        handles, ...
        parameters ...
        );
    handles.smoothing_panel = uipanel( ...
        'parent', uiGetChildByTag(handles.form_panel, 'vpanel_2'), ...
        'tag', 'smoothing_panel', ...
        'title', 'Pixel Data Smoothing', ...
        'position', position(1, :) ...
        );
    handles.scanner_panel = uipanel( ...
        'parent', uiGetChildByTag(handles.form_panel, 'vpanel_2'), ...
        'tag', 'scanner_panel', ...
        'title', 'Scanner', ...
        'position', position(2, :) ...
        );

    gui = struct();
    gui.parameters = parameters;
    gui.handles = handles;
    guidata(handles.new_msr_figure, gui);

endfunction;

function uiCancelNewMeasurement(src, evt)
    % TODO: Add function implementation here

endfunction;

function uiCreateNewMeasurement(src, evt)
    % TODO: Add function implementation here

endfunction;

function position = uiNewMeasurementElementsPosition(hparent, parameters)

    % Calculate relative extents of GUI parameters ----------------------------
    pextents = getpixelposition(hparent);
    header_height_abs = parameters.header_height_px / pextents(4);
    ver_padding_abs = parameters.padding_px / pextents(4);
    row_height_abs = parameters.row_height_px / pextents(4);

    % Calculate elements position ---------------------------------------------
    position = [...
        0.00, ...
        0.00, ...
        1.00, ...
        row_height_abs + 2*ver_padding_abs; ...
        0.00, ...
        row_height_abs + 2*ver_padding_abs, ...
        1.00, ...
        1.00 - row_height_abs - 2*ver_padding_abs - header_height_abs; ...
        0.00, ...
        1.00 - header_height_abs, ...
        1.00, ...
        header_height_abs ...
        ];

endfunction;

function position = uiControlPanelElementsPostion(hparent, parameters)

    % Calculate relative extents of GUI parameters ----------------------------
    pextents = getpixelposition(hparent);
    hor_padding_abs = parameters.padding_px / pextents(3);
    ver_padding_abs = parameters.padding_px / pextents(4);
    btn_width_abs = parameters.btn_width_px / pextents(3);
    row_height_abs = parameters.row_height_px / pextents(4);

    % Calculate elements position ---------------------------------------------
    position = [...
        hor_padding_abs, ...
        ver_padding_abs, ...
        btn_width_abs, ...
        row_height_abs; ...
        1.00 - btn_width_abs - 2*hor_padding_abs, ...
        ver_padding_abs, ...
        btn_width_abs, ...
        row_height_abs ...
        ];

endfunction;

function position = uiFormPanelElementsPosition(hparent, parameters)

    % Calculate elements position ---------------------------------------------
    position = [...
        0.00, 0.00, 0.20, 1.00; ...
        0.20, 0.00, 0.20, 1.00; ...
        0.40, 0.00, 0.20, 1.00; ...
        0.60, 0.00, 0.20, 1.00; ...
        0.80, 0.00, 0.20, 1.00 ...
        ];

endfunction;

function position = uiVerticalPanelElementsPosition( ...
        panel_tag, ...
        handles, ...
        parameters ...
        )

    % Get handle to the parent container by the tag ---------------------------
    hparent = uiGetChildByTag(handles.form_panel, panel_tag);

    % Calculate relative extents of GUI parameters ----------------------------
    pextents = getpixelposition(hparent);
    ver_padding_abs = parameters.padding_px / pextents(4);

    % Calculate elements position ---------------------------------------------
    position = [];
    if(isequal('vpanel_1', panel_tag))
        base_height = 1.00 - 2*ver_padding_abs;
        position = [...
            0.00, 0.00, 1.00, 1.0 - 0.66*base_height - 2*ver_padding_abs;
            0.00, 1.0 - 0.66*base_height - 1*ver_padding_abs, 1.00, 0.44*base_height;
            0.00, 1.0 - 0.22*base_height, 1.00, 0.22*base_height;
            ];

    elseif(isequal('vpanel_2', panel_tag))
        base_height = 1.00 - ver_padding_abs;
        position = [...
            0.00, 0.00, 1.00, 1.0 - 0.5*base_height - 1*ver_padding_abs;
            0.00, 1.0 - 0.5*base_height, 1.00, 0.5*base_height;
            ];

    endif;

endfunction;

function position = uiInputElementsPostion(hparent, parameters, n)

    % Calculate relative extents of GUI parameters ----------------------------
    pextents = getpixelposition(hparent);
    hor_padding_abs = parameters.padding_px / pextents(3);
    ver_padding_abs = parameters.padding_px / pextents(4);
    btn_width_abs = parameters.btn_width_px / pextents(3);
    row_height_abs = parameters.row_height_px / pextents(4);

    position = [];
    idx = n;
    while(1 <= idx)
        position = [ ...
            position; ...
            hor_padding_abs, ...
            1.00 - idx*ver_padding_abs - (2*idx)*row_height_abs, ...
            1.00 - 2*hor_padding_abs, ...
            row_height_abs; ...
            hor_padding_abs, ...
            1.00 - idx*ver_padding_abs - (2*idx - 1)*row_height_abs, ...
            1.00 - 2*hor_padding_abs, ...
            row_height_abs; ...
            ];

        idx = idx - 1;

    endwhile;

endfunction;

function uiNewMeasurementResize(src, evt)

    % Retrieve handle to app data ---------------------------------------------
    gui = guidata(src);

    % Recalculate main figure elements position -------------------------------
    position = uiNewMeasurementElementsPosition( ...
        gui.handles.new_msr_figure, ...
        gui.parameters ...
        );
    set(gui.handles.control_panel, 'position', position(1, :));
    set(gui.handles.form_panel, 'position', position(2, :));
    set(gui.handles.header_panel, 'position', position(3, :));

    % Recalculate "Control" panel elements position ---------------------------
    position = uiControlPanelElementsPostion( ...
        gui.handles.control_panel, ...
        gui.parameters ...
        );
    set(gui.handles.cancel_button, 'position', position(1, :));
    set(gui.handles.create_button, 'position', position(2, :));

    % Recalculate "Date and Time" panel elements position ---------------------
    position = uiInputElementsPostion( ...
        gui.handles.title_and_date_panel, ...
        gui.parameters, ...
        2 ...
        );
    set(gui.handles.edit_date, 'position', position(1, :));
    set(gui.handles.label_date, 'position', position(2, :));
    set(gui.handles.edit_title, 'position', position(3, :));
    set(gui.handles.label_title, 'position', position(4, :));

    % Recalculate "Field" panel elements position -----------------------------
    position = uiInputElementsPostion( ...
        gui.handles.field_panel, ...
        gui.parameters, ...
        4 ...
        );
    set(gui.handles.edit_field_size, 'position', position(1, :));
    set(gui.handles.label_field_size, 'position', position(2, :));
    set(gui.handles.edit_field_shape, 'position', position(3, :));
    set(gui.handles.label_field_shape, 'position', position(4, :));
    set(gui.handles.edit_beam_energy, 'position', position(5, :));
    set(gui.handles.label_beam_energy, 'position', position(6, :));
    set(gui.handles.edit_beam_type, 'position', position(7, :));
    set(gui.handles.label_beam_type, 'position', position(8, :));

    % Recalculate "Film" panel elements position ------------------------------
    position = uiInputElementsPostion( ...
        gui.handles.film_panel, ...
        gui.parameters, ...
        3 ...
        );
    set(gui.handles.edit_film_custom_cut, 'position', position(1, :));
    set(gui.handles.label_film_custom_cut, 'position', position(2, :));
    set(gui.handles.edit_film_model, 'position', position(3, :));
    set(gui.handles.label_film_model, 'position', position(4, :));
    set(gui.handles.edit_film_manufacturer, 'position', position(5, :));
    set(gui.handles.label_film_manufacturer, 'position', position(6, :));

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



% =============================================================================
%
% GUI Utility Functions Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function 'uiGetChildByTag':
%
% -- hchild = uiGetChildByTag(hparent, tag)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function hchild = uiGetChildByTag(hparent, tag)

    hchild = NaN;
    hchildren = get(hparent, 'children');

    idx = 1;
    while(length(hchildren) >= idx)
        if(isequal(tag, get(hchildren(idx), 'tag')))
            hchild = hchildren(idx);

        endif;

        idx = idx + 1;

    endwhile;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'plotRect':
%
% -- plotRect(rect)
% -- plotRect(hax, rect)
%
%     Taking that 'rect' are coordinates of the rectangle given in the format
%     [x_left, y_bottom, x_right, y_top] plot the rectangle on the given axes
%     object or on the current axes.
%
% -----------------------------------------------------------------------------
function plotRect(hax, rect)

    % Store function name into variable for easier management of error messages
    fname = 'plotRect';
    use_case_a = ' -- plotRect(rect)';
    use_case_b = ' -- plotRect(hax, rect)';

    % Validate input arguments
    if(2 < nargin || 0 == nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    elseif(2 == nargin && ~ishandle(hax))
        error( ...
            '%s: hax Must be a handle to an axes object', ...
            fname ...
            );

    elseif(1 == nargin)
        rect = hax;
        hax = gca();

    endif;

    validateattributes( ...
        rect, ...
        {'numeric'}, ...
        { ...
            'nonempty', ...
            'nonnan', ...
            'finite', ...
            '2d', ...
            'numel' 4 ...
            }, ...
        fname, ...
        'rect' ...
        );

    plot( ...
        hax, ...
        [rect(1), rect(3), rect(3), rect(1), rect(1)], ...
        [rect(2), rect(2), rect(4), rect(4), rect(2)] ...
        );

endfunction;
