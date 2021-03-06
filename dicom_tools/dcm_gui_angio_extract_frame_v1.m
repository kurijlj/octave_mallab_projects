% =============================================================================
% Copyright (C) 2022 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% This file is part of DICOM Toolbox.
%
% DICOM Toolbox is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
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
% 2022-06-14 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% * Renamed to: dcm_gui_angio_extract_frame_v1.m.
%
% 2022-06-10 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% * dcm_gui_angio_extract.m: created.
%
% =============================================================================


% =============================================================================
%
% TODO: 1) Add app help
%       2) Add app about
%       3) Add code docummentation
%
% =============================================================================


% TODO: Remove following line when release is complete
% pkg_name = 'DICOM Toolbox'


% =============================================================================
%
% Main Script Body Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% App 'dcm_gui_angio_extract_v1.m':
%
% -- dcm_gui_angio_extract_v1()
%
% -----------------------------------------------------------------------------
function dcm_gui_angio_extract_frame_v1()

    % Define common message strings
    fname = 'dcm_gui_angio_extract';

    % Initialize GUI toolkit
    graphics_toolkit qt;

    % Initialize structure for keeping app data
    app = newApp();
    app.gui = newGui(app);
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
%       -- app = newApp()
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function app = newApp()

    % Define common message strings
    fname = 'newApp';
    use_case = ' -- app = newApp()';

    % Validate input arguments
    if(0 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    app = struct();
    app.dicom_data = NaN;
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
            && isfield(app_obj, 'dicom_data') ...
            && isfield(app_obj, 'gui') ...
            )
        result = true;

    endif;

endfunction;


% =============================================================================
%
% Dicom Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newDicomData
%
% Use:
%       -- dicom_data = newDicomData()
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function dicom_data = newDicomData(file_path)

    % Define common message strings
    fname = 'newDicomData';
    use_case = ' -- dicom_data = newDicomData(file_path)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~ischar(file_path))
        error('%s: file_path must be a string containing a path to a DICOM file', fname);

    endif;

    pkg load dicom;
    % Validate DICOM data
    if(~isdicom(file_path))
        pkg unload dicom;
        error('%s: File \"%s\" must be a regular DICOM file', fname, file_path);

    endif;

    info = dicominfo(file_path);

    % Validate X-Ray Angiographic Image
    if( ...
            ~isfield(info, 'StudyInstanceUID') ...
            || ~isfield(info, 'SeriesInstanceUID') ...
            || ~isfield(info, 'SOPClassUID') ...
            || ~isfield(info, 'Modality') ...
            )
        pkg unload dicom;
        error('%s: File \"%s\" missing essential header data');

    endif;
    if( ...
            isequal('1.2.840.10008.5.1.4.1.1.12.1', info.SOPClassUID) ...
            && isequal('XA', info.Modality) ...
            )
        % We have an angiography exam so proceed with reading data
        pixel_data = dicomread(file_path);

    else
        % Not an angiography exam stop further loading
        pkg unload dicom;
        error('%s: File \"%s\" must be a an DICOM angiography exam', fname, file_path);

    endif;

    pkg unload dicom;

    dicom_data = struct();
    dicom_data.info = info;
    dicom_data.pixel_data = pixel_data;
    dicom_data.selected_frame = 1;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: isDicomDataStruct
%
% Use:
%       -- result = isDicomDataStruct(dicom_data_obj)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isDicomDataStruct(dicom_data_obj)

    % Define common message strings
    fname = 'isDicomDataStruct';
    use_case = ' -- result = isDicomDataStruct(app_obj)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(dicom_data_obj) ...
            && isfield(dicom_data_obj, 'info') ...
            && isfield(dicom_data_obj, 'pixel_data') ...
            && isfield(dicom_data_obj, 'selected_frame') ...
            )
        result = true;

    endif;


endfunction;

% -----------------------------------------------------------------------------
%
% Function: isAngiography
%
% Use:
%       -- result = isAngiography(dicom_data_obj)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function result = isAngiography(dicom_data_obj)

    % Define common message strings
    fname = 'isAngiography';
    use_case = ' -- result = isAngiography(app_obj)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isDicomDataStruct(dicom_data_obj))
        error('%s: dicom_data_obj must be a DICOM data object', fname);

    endif;

    result = false;
    if( ...
            '1.2.840.10008.5.1.4.1.1.12.1' == dicom_data_obj.info.SOPClassUID ...
            && 'XA' == dicom_data_obj.info.Modality ...
            )
        result = true;

    endif;


endfunction;

% -----------------------------------------------------------------------------
%
% Function: extractFrame
%
% Use:
%       -- extractFrame( ...
%               dicom_data_obj, ...
%               patient_name, ...
%               patient_id, ...
%               study_desc, ...
%               frame_index, ....
%               file_path ...
%               )
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function extractFrame( ...
        dicom_data_obj, ...
        patient_name, ...
        patient_id, ...
        study_desc, ...
        frame_index, ...
        file_path ...
        )

    % Define common message strings
    fname = 'extractFrame';
    use_case = ' -- extractFrame(dicom_data_obj, patient_name, patient_id, study_desc, frame_index, file_path)';

    % Validate input arguments
    if(6 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isDicomDataStruct(dicom_data_obj))
        error('%s: dicom_data_obj must be a DICOM data object', fname);

    endif;

    if(~ischar(patient_name))
        error('%s: patient_name must be a string containing a patient name', fname);

    endif;

    if(~ischar(patient_id))
        error('%s: patient_id must be a string containing a patient id', fname);

    endif;

    if(~ischar(study_desc))
        error('%s: patient_id must be a string containing a patient id', fname);

    endif;

    validateattributes( ...
        frame_index, ...
        {'numeric'}, ...
        { ...
            'scalar', ...
            'nonempty', ...
            'nonnan', ...
            'integer', ...
            'finite', ...
            '>=', 0, ...
            '<=', size(dicom_data_obj.pixel_data, 3) ...
            }, ...
        fname, ...
        'frame_index' ...
        );

    if(~ischar(file_path))
        error('%s: patient_id must be a string containing a path to a destination DICOM file', fname);

    endif;

    % Initialize DICOM info structure
    pkg load dicom;
    dcm_info                            = struct();
    dcm_info.PatientName                = patient_name;
    dcm_info.PatientID                  = patient_id;
    dcm_info.StudyInstanceUID           = dicomuid();
    dcm_info.SeriesInstanceUID          = dicomuid();
    dcm_info.MediaStorageSOPInstanceUID = dicomuid();
    dcm_info.StudyDescription           = study_desc;

    dcm_info.PatientSex                 = dicom_data_obj.info.PatientSex;
    dcm_info.StudyID                    = dicom_data_obj.info.StudyID;
    dcm_info.StudyDate                  = dicom_data_obj.info.StudyDate;
    dcm_info.StudyTime                  = dicom_data_obj.info.StudyTime;
    dcm_info.SeriesNumber               = dicom_data_obj.info.SeriesNumber;
    dcm_info.MediaStorageSOPClassUID    = dicom_data_obj.info.MediaStorageSOPClassUID;
    dcm_info.TransferSyntaxUID          = dicom_data_obj.info.TransferSyntaxUID;
    dcm_info.SOPClassUID                = dicom_data_obj.info.SOPClassUID;
    dcm_info.Modality                   = dicom_data_obj.info.Modality;
    dcm_info.BitsStored                 = dicom_data_obj.info.BitsStored;
    dcm_info.BitsAllocated              = dicom_data_obj.info.BitsAllocated;
    dcm_info.HighBit                    = dicom_data_obj.info.HighBit;
    dcm_info.SamplesPerPixel            = dicom_data_obj.info.SamplesPerPixel;
    dcm_info.Rows                       = dicom_data_obj.info.Rows;
    dcm_info.Columns                    = dicom_data_obj.info.Columns;
    dcm_info.InstanceNumber             = dicom_data_obj.info.InstanceNumber;
    dcm_info.ImageType                  = dicom_data_obj.info.ImageType;
    dcm_info.PhotometricInterpretation  = dicom_data_obj.info.PhotometricInterpretation;
    dcm_info.PixelRepresentation        = dicom_data_obj.info.PixelRepresentation;
    if(isfield(dicom_data_obj.info, 'WindowCenter'))
        dcm_info.WindowCenter           = dicom_data_obj.info.WindowCenter;

    endif;
    if(isfield(dicom_data_obj.info, 'WindowWidth'))
        dcm_info.WindowWidth            = dicom_data_obj.info.WindowWidth;

    endif;
    if(isfield(dicom_data_obj.info, 'PatientOrientation'))
        dcm_info.PatientOrientation     = dicom_data_obj.info.PatientOrientation;

    endif;
    if(isfield(dicom_data_obj.info, 'PatientPosition'))
        dcm_info.PatientPosition        = dicom_data_obj.info.PatientPosition;

    endif;

    dicomwrite(dicom_data_obj.pixel_data(:, :, frame_index), file_path, dcm_info);
    pkg unload dicom;

endfunction;



% =============================================================================
%
% GUI Data Structure Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: newGui
%
% Use:
%       -- app_gui = newGui(app_obj)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function app_gui = newGui(app_obj)

    % Define common message strings
    fname = 'newGui';
    use_case = ' -- app_gui = newGui(app_obj)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n\n%s', fname, use_case);

    endif;

    if(~isAppDataStruct(app_obj))
        error('%s: app_obj must be an App object', fname);

    endif;

    app_gui = struct();

    % Create main figure ------------------------------------------------------
    app_gui.main_figure = figure( ...
        'name', 'DICOM Angio Extract', ...
        'tag', 'main_figure', ...
        'menubar', 'none', ...
        'sizechangedfcn', @uiUpdate, ...
        'position', uiCalculateInitialPosition(get(0, 'ScreenSize')) ...
        );

    % Create custom menu bar --------------------------------------------------

    % Create file menu and file menu entries
    app_gui.file_menu = uimenu( ...
        'parent', app_gui.main_figure, ...
        'tag', 'file_menu', ...
        'label', '&File', ...
        'accelerator', 'f' ...
        );
    app_gui.fm_load_angio = uimenu( ...
        'parent', app_gui.file_menu, ...
        'tag', 'fm_load_angio', ...
        'label', '&Load New Angiography Exam', ...
        'accelerator', 'l', ...
        'callback', @uiLoadExam ...
        );
    app_gui.fm_quit = uimenu( ...
        'parent', app_gui.file_menu, ...
        'tag', 'fm_quit', ...
        'label', '&Quit', ...
        'accelerator', 'q', ...
        'separator', 'on', ...
        'callback', @uiQuit ...
        );

    % Create help menu and help menu entries
    app_gui.help_menu = uimenu( ...
        'parent', app_gui.main_figure, ...
        'tag', 'help_menu', ...
        'label', '&Help', ...
        'accelerator', 'h' ...
        );
    app_gui.hm_help = uimenu( ...
        'parent', app_gui.help_menu, ...
        'tag', 'hm_help', ...
        'label', 'Help on &Application', ...
        'accelerator', 'a', ...
        'enable', 'off', ...
        'callback', @uiAppHelp ...
        );
    app_gui.hm_about = uimenu( ...
        'parent', app_gui.help_menu, ...
        'tag', 'hm_about', ...
        'label', 'A&bout', ...
        'accelerator', 'b', ...
        'separator', 'on', ...
        'enable', 'off', ...
        'callback', @uiAppAbout ...
        );

    % Create main panel -------------------------------------------------------
    app_gui.main_panel = uipanel( ...
        'parent', app_gui.main_figure, ...
        'tag', 'main_panel', ...
        'bordertype', 'none', ...
        'position', [0, 0, 1, 1] ...
        );

    % % Define dimensions for panel elements with fixed size
    app_gui.padding = 10;
    app_gui.row_height = 24;

    % Calculate normalized position of main panel elements
    position = uiMainPanelElementsPosition();

    % Create main panel elements ----------------------------------------------

    % View panel
    app_gui.frame_view_panel = uipanel( ...
        'parent', app_gui.main_panel, ...
        'tag', 'frame_view_panel', ...
        'title', 'Frame Preview', ...
        'position', position(1, :) ...
        );

    % Frame extract panel
    app_gui.frame_extract_panel = uipanel( ...
        'parent', app_gui.main_panel, ...
        'tag', 'frame_extract_panel', ...
        'title', 'Frame Extract', ...
        'position', position(2, :) ...
        );

    % Create frame view panel elements ----------------------------------------
    position = uiFrameViewPanelElementsPosition();

    % Create panels
    app_gui.frame_select_panel = uipanel( ...
        'parent', app_gui.frame_view_panel, ...
        'tag', 'frame_select_panel', ...
        'title', 'Select frame', ...
        'position', position(1, :) ...
        );
    app_gui.frame_axes_panel = uipanel( ...
        'parent', app_gui.frame_view_panel, ...
        'tag', 'frame_axes_panel', ...
        'bordertype', 'none', ...
        'position', position(2, :) ...
        );

    % Create controls
    position = uiFrameSelectPanelElementsPosition(app_gui);
    app_gui.frame_select = uicontrol( ...
        'parent', app_gui.frame_select_panel, ...
        'style', 'slider', ...
        'tag', 'frame_select', ...
        'tooltipstring', 'Select frame', ...
        'callback', @uiFrameSelect, ...
        'min', 1, 'max', 1, ...
        'value', 1, ...
        'enable', 'off', ...
        'units', 'normalized', ...
        'position', position ...
        );

    % Create views
    app_gui.frame_axes = axes( ...
        'parent', app_gui.frame_axes_panel, ...
        'tag', 'frame_axes', ...
        'position', [0 0 1 1] ...
        );
    text( ...
        'parent', app_gui.frame_axes, ...
        0.5, 0.5, ...
        'No exam loaded!', ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'middle' ...
        );

    % Create frame extract panel elements ----------------------------------------
    position = uiFrameExtractPanelElementsPosition(app_gui);

    % Create panels
    app_gui.edit_study_panel = uipanel( ...
        'parent', app_gui.frame_extract_panel, ...
        'tag', 'edit_study_panel', ...
        'bordertype', 'none', ...
        'position', position(2, :) ...
        );
    app_gui.extract_button_panel = uipanel( ...
        'parent', app_gui.frame_extract_panel, ...
        'tag', 'extract_button_panel', ...
        'bordertype', 'none', ...
        'position', position(1, :) ...
        );
    app_gui.edit_id_panel = uipanel( ...
        'parent', app_gui.frame_extract_panel, ...
        'tag', 'edit_id_panel', ...
        'bordertype', 'none', ...
        'position', position(3, :) ...
        );
    app_gui.edit_name_panel = uipanel( ...
        'parent', app_gui.frame_extract_panel, ...
        'tag', 'edit_name_panel', ...
        'bordertype', 'none', ...
        'position', position(4, :) ...
        );

    % Create input controls
    app_gui.name_label = uicontrol( ...
        'parent', app_gui.edit_name_panel, ...
        'style', 'text', ...
        'tag', 'name_label', ...
        'string', 'Patient Name: ', ...
        'horizontalalignment', 'right', ...
        'units', 'normalized', ...
        'position', [0.00, 0.00, 0.30, 1.00] ...
        );
    app_gui.name_view = uicontrol( ...
        'parent', app_gui.edit_name_panel, ...
        'style', 'edit', ...
        'tag', 'name_view', ...
        'string', '', ...
        'tooltipstring', 'Patient name', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', [0.30, 0.00, 0.70, 1.00] ...
        );
    app_gui.id_label = uicontrol( ...
        'parent', app_gui.edit_id_panel, ...
        'style', 'text', ...
        'tag', 'id_label', ...
        'string', 'Patient ID: ', ...
        'horizontalalignment', 'right', ...
        'units', 'normalized', ...
        'position', [0.00, 0.00, 0.30, 1.00] ...
        );
    app_gui.id_view = uicontrol( ...
        'parent', app_gui.edit_id_panel, ...
        'style', 'edit', ...
        'tag', 'id_view', ...
        'string', '', ...
        'tooltipstring', 'Patient ID', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', [0.30, 0.00, 0.70, 1.00] ...
        );
    app_gui.study_label = uicontrol( ...
        'parent', app_gui.edit_study_panel, ...
        'style', 'text', ...
        'tag', 'study_label', ...
        'string', 'Study Description: ', ...
        'horizontalalignment', 'right', ...
        'units', 'normalized', ...
        'position', [0.00, 0.00, 0.30, 1.00] ...
        );
    app_gui.study_view = uicontrol( ...
        'parent', app_gui.edit_study_panel, ...
        'style', 'edit', ...
        'tag', 'study_view', ...
        'string', '', ...
        'tooltipstring', 'Study description', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', [0.30, 0.00, 0.70, 1.00] ...
        );
    app_gui.extract_button = uicontrol( ...
        'parent', app_gui.extract_button_panel, ...
        'style', 'pushbutton', ...
        'tag', 'extract_button', ...
        'string', 'Extract Frame', ...
        'tooltipstring', 'Extract Frame', ...
        'callback', @uiExtractFrame, ...
        'units', 'normalized', ...
        'position', [0.00, 0.00, 1.00, 1.00] ...
        );

endfunction;



% =============================================================================
%
% GUI Elements Positioning Section
%
% =============================================================================

% -----------------------------------------------------------------------------
%
% Function: uiCalculateInitialPosition
%
% Use:
%       -- position = uiCalculateInitialPosition(screen_size)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function position = uiCalculateInitialPosition(screen_size)

    % Init return value to default
    position = [100 100 400 400];

    % Make app occupy up to 80% of the available screen size
    ui_width = round(screen_size(3)*0.80);
    ui_height = round(screen_size(4)*0.80);
    ui_x_origin = floor((screen_size(3) - ui_width)*0.5);
    ui_y_origin = floor((screen_size(4) - ui_height)*0.5);

    % Update return value
    position = [ui_x_origin, ui_y_origin, ui_width, ui_height];

endfunction;

% -----------------------------------------------------------------------------
%
% Function: uiMainPanelElementsPosition
%
% Use:
%       -- position = uiMainPanelElementsPosition()
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function position = uiMainPanelElementsPosition()

    % Init return value
    position = [];

    % Calculate elements position
    frame_view = [0.00, 0.00, 0.70, 1.00];
    frame_extract = [0.70, 0.00, 0.30, 1.00];

    % Update return variable
    position = [position; frame_view; frame_extract];

endfunction;

% -----------------------------------------------------------------------------
%
% Function: uiFrameViewPanelElementsPosition
%
% Use:
%       -- position = uiFrameViewPanelElementsPosition()
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function position = uiFrameViewPanelElementsPosition()

    % Init return value
    position = [];

    % Calculate elements position
    frame_select = [0.00, 0.00, 1.00, 0.10];
    frame_axes = [0.00, 0.10, 1.00, 0.90];

    % Update return variable
    position = [position; frame_select; frame_axes];

endfunction;

function position = uiFrameSelectPanelElementsPosition(gui_handle)

    % Init return value
    position = [];

    % Calculate elements position
    parent_extents = getpixelposition(gui_handle.frame_select_panel);
    height = parent_extents(4) - parent_extents(2);
    width = parent_extents(3) - parent_extents(1);
    rel_row_height = gui_handle.row_height/height;
    rel_hpadding = gui_handle.padding/width;
    spacer = (1.00 - rel_row_height)/2;
    selector = [rel_hpadding, spacer, 1.00 - 2*rel_hpadding, rel_row_height];

    % Update return variable
    position = selector;

endfunction;

% -----------------------------------------------------------------------------
%
% Function: uiFrameExtractPanelElementsPosition
%
% Use:
%       -- position = uiFrameExtractPanelElementsPosition(gui_handle)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function position = uiFrameExtractPanelElementsPosition(gui_handle)

    % Init return value
    position = [];

    % Calculate elements position
    parent_extents = getpixelposition(gui_handle.frame_extract_panel);
    height = abs(parent_extents(4) - parent_extents(2));
    width = abs(parent_extents(3) - parent_extents(1));
    rel_row_height = gui_handle.row_height/height;
    rel_vpadding = gui_handle.padding/height;
    rel_hpadding = gui_handle.padding/width;
    vspacer = 1.00 - 5*rel_row_height - 4*rel_vpadding;
    extract_button_panel = [ ...
        rel_hpadding, ...
        rel_vpadding, ...
        1.00 - 2*rel_hpadding, ...
        2*rel_row_height ...
        ];
    study_panel = [ ...
        rel_hpadding, ...
        rel_vpadding + 2*rel_row_height + vspacer, ...
        1.00 - 2*rel_hpadding, ...
        rel_row_height ...
        ];
    id_panel = [ ...
        rel_hpadding, ...
        2*rel_vpadding + 3*rel_row_height + vspacer, ...
        1.00 - 2*rel_hpadding, ...
        rel_row_height ...
        ];
    name_panel = [ ...
        rel_hpadding, ...
        3*rel_vpadding + 4*rel_row_height + vspacer, ...
        1.00 - 2*rel_hpadding, ...
        rel_row_height ...
        ];

    % Update return variable
    position = [position; extract_button_panel; study_panel; id_panel; name_panel];

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
function uiLoadExam(src, evt)

    [file, dir] = uigetfile( ...
        'title', 'DICOM Angio Extract' ...
        );

    fpath = '';
    if(isequal(0, file) || isequal(0, dir))
        % User hit the 'Cancel' button. Abort loading
        return;

    else
        % User selected a file. Reconstruct absolute paths
        fpath = fullfile(dir, file);

    endif;  % if(~isequal(0, file) && ~isequal(0, dir))

    try
        dicom_data = newDicomData(fpath);

    catch err
        % Format error message string for display to screen
        errmsg = strrep(err.message, '\', '\\');  % Escape backslashes

        % Show error dialog
        msgbox( ...
            { ...
                sprintf('%s', errmsg), ...
                'Aborting loading operation ...' ...
                }, ...
            'DICOM Angio Extract: Loading Exam', ...
            'error' ...
            );

        % also send message to the workspace
        fprintf( ...
            stderr(), ...
            'uiLoadExam: %s. Aborting loading operation ...\n', ...
            err.message ...
            );

        % Abort loading the scanset
        return;

    end_try_catch;

    % Retrieve handle to app data
    app = guidata(src);
    app.dicom_data = dicom_data;

    % Update view and selector
    imshow( ...
        dicom_data.pixel_data(:, :, dicom_data.selected_frame), ...
        [ ], ...
        'parent', ...
        app.gui.frame_axes ...
        );
    text( ...
        'parent', app.gui.frame_axes, ...
        70, 30, ...
        sprintf('Frame: %d', dicom_data.selected_frame), ...
        'color', [1 1 0], ...
        'fontsize', 24, ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'middle' ...
        );

    set(app.gui.frame_select, 'min', 1);
    set(app.gui.frame_select, 'max', size(app.dicom_data.pixel_data, 3));
    set( ...
        app.gui.frame_select, ...
        'sliderstep', ...
        [ ...
            1/(size(app.dicom_data.pixel_data, 3) - 1), ...
            1/(size(app.dicom_data.pixel_data, 3) - 1) ...
            ] ...
        );
    set(app.gui.frame_select, 'value', app.dicom_data.selected_frame);
    set(app.gui.frame_select, 'enable', 'on');

    % Update patient and study data info
    if(isfield(app.dicom_data.info, 'PatientName'))
        set(app.gui.name_view, 'string', app.dicom_data.info.PatientName);

    else
        set(app.gui.name_view, 'string', 'N/A');

    endif;
    if(isfield(app.dicom_data.info, 'PatientID'))
        set(app.gui.id_view, 'string', app.dicom_data.info.PatientID);

    else
        set(app.gui.id_view, 'string', 'N/A');

    endif;
    if(isfield(app.dicom_data.info, 'StudyDescription'))
        set(app.gui.study_view, 'string', app.dicom_data.info.StudyDescription);

    else
        set(app.gui.study_view, 'string', 'N/A');

    endif;

    % Save new data to app handle
    guidata(gcf(), app);

    refresh(gcf());

endfunction;

function uiQuit(src, evt)
    close(gcf());

endfunction;

function uiAppHelp(src, evt)
endfunction;

function uiAppAbout(src, evt)
endfunction;

% -----------------------------------------------------------------------------
%
% Main Panel Callbacks Section
%
% -----------------------------------------------------------------------------
function uiUpdate(src, evt)

    % Retrieve handle to app data
    app = guidata(src);

    % Recalculate GUI elements position inside frame select panel
    position = uiFrameSelectPanelElementsPosition(app.gui);
    set(app.gui.frame_select, 'position', position);

    % Recalculate GUI elements position inside frame extract panel
    position = uiFrameExtractPanelElementsPosition(app.gui);
    set(app.gui.extract_button_panel, 'position', position(1, :));
    set(app.gui.edit_study_panel, 'position', position(2, :));
    set(app.gui.edit_id_panel, 'position', position(3, :));
    set(app.gui.edit_name_panel, 'position', position(4, :));

endfunction;

function uiFrameSelect(src, evt)

    % Retrieve handle to app data
    app = guidata(src);

    % Update selected frame field
    app.dicom_data.selected_frame = round(get(app.gui.frame_select, 'value'));

    % Update view
    imshow( ...
        app.dicom_data.pixel_data(:, :, app.dicom_data.selected_frame), ...
        [ ], ...
        'parent', ...
        app.gui.frame_axes ...
        );
    text( ...
        'parent', app.gui.frame_axes, ...
        50, 30, ...
        sprintf('Frame: %d', app.dicom_data.selected_frame), ...
        'color', [1 1 0], ...
        'fontsize', 24, ...
        'horizontalalignment', 'center', ...
        'verticalalignment', 'middle' ...
        );

    % Save new data to app handle
    guidata(gcf(), app);

    refresh(gcf());

endfunction;

function uiExtractFrame(src, evt)

    % Retrieve handle to app data
    app = guidata(src);

    % Update patient data
    app.info.PatientName = get(app.gui.name_view, 'string');
    app.info.PatientID = get(app.gui.id_view, 'string');
    app.info.StudyDescription = get(app.gui.study_view, 'string');

    % Let the user select output file
    [file, dir] = uiputfile( ...
        {'*.DCM', 'DICOM Angiography Exam'}, ...
        'DICOM Angio Extract: Save Frame', ...
        strftime('IMG%Y%m%d%H%M%S', localtime(time())) ...
        );

    fpath = '';
    if(isequal(0, file) || isequal(0, dir))
        % User hit the 'Cancel' button. Abort loading
        return;

    else
        % User selected a file. Reconstruct absolute paths
        fpath = fullfile(dir, file);

    endif;  % if(~isequal(0, file) && ~isequal(0, dir))

    extractFrame( ...
        app.dicom_data, ...
        get(app.gui.name_view, 'string'), ...
        get(app.gui.id_view, 'string'), ...
        get(app.gui.study_view, 'string'), ...
        app.dicom_data.selected_frame, ...
        fpath ...
        );

endfunction;
