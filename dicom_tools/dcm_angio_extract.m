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
% 2022-06-10 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% * dcm_gui_angio_extract.m: created.
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
pkg_name = 'DICOM Toolbox'


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
% TODO: Rename script and function to the 'dcm_gui_angio_extract_v1' on release
function dcm_gui_angio_extract()

    % Define common message strings
    fname = 'dcm_gui_angio_extract';

    % Initialize GUI toolkit
    graphics_toolkit qt;

    % Initialize structure for keeping app data
    app = newApp();
    app.gui = newGui();
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
%       -- result = isAppDataStruct()
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
        error('%s: File \"%s\" must be a regular DICOM file', fname, file_path);

    endif;

    info = dicominfo(file_path);

    % Validate X-Ray Angiographic Image
    if( ...
            ~ismember('StudyInstanceUID', fieldnames(info)) ...
            || ~ismember('SeriesInstanceUID', fieldnames(info)) ...
            || ~ismember('SOPClassUID', fieldnames(info)) ...
            || ~ismember('Modality', fieldnames(info)) ...
            )
        error('%s: File \"%s\" missing essential header data');

    endif;
    if( ...
            '1.2.840.10008.5.1.4.1.1.12.1' == info.SOPClassUID ...
            && 'XA' == info.Modality ...
            )
        % We have an angiography exam so proceed with reading data
        pixel_data = dicomread(file_path);

    else
        % Not an angiography exam stop further loading
        pixel_data = NaN;

    endif;

    pkg unload dicom;

    dicom_data = struct();
    dicom_data.info = info;
    dicom_data.pixel_data = pixel_data;

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
%       -- extractFrame(dicom_data_obj, file_path, frame_index)
%
% Description: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function extractFrame(dicom_data_obj, patient_name, patient_id, file_path, frame_index)

    % Define common message strings
    fname = 'extractFrame';
    use_case = ' -- extractFrame(dicom_data_obj, file_path, frame_index)';

    % Validate input arguments
    if(5 ~= nargin)
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

    if(~ischar(file_path))
        error('%s: patient_id must be a string containing a path to a destination DICOM file', fname);

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

    % Initialize DICOM info structure
    pkg load dicom;
    dcm_info                            = struct();
    dcm_info.PatientName                = patient_name;
    dcm_info.PatientID                  = patient_id;
    dcm_info.StudyInstanceUID           = dicomuid();
    dcm_info.SeriesInstanceUID          = dicomuid();
    dcm_info.MediaStorageSOPInstanceUID = dicomuid();

    dcm_info.PatientSex                = dicom_data_obj.info.PatientSex;
    dcm_info.StudyID                   = dicom_data_obj.info.StudyID;
    dcm_info.StudyDate                 = dicom_data_obj.info.StudyDate;
    dcm_info.StudyTime                 = dicom_data_obj.info.StudyTime;
    dcm_info.SeriesNumber              = dicom_data_obj.info.SeriesNumber;
    dcm_info.MediaStorageSOPClassUID   = dicom_data_obj.info.MediaStorageSOPClassUID;
    dcm_info.TransferSyntaxUID         = dicom_data_obj.info.TransferSyntaxUID;
    dcm_info.SOPClassUID               = dicom_data_obj.info.SOPClassUID;
    dcm_info.Modality                  = dicom_data_obj.info.Modality;
    dcm_info.BitsStored                = dicom_data_obj.info.BitsStored;
    dcm_info.BitsAllocated             = dicom_data_obj.info.BitsAllocated;
    dcm_info.HighBit                   = dicom_data_obj.info.HighBit;
    dcm_info.SamplesPerPixel           = dicom_data_obj.info.SamplesPerPixel;
    dcm_info.Rows                      = dicom_data_obj.info.Rows;
    dcm_info.Columns                   = dicom_data_obj.info.Columns;
    dcm_info.InstanceNumber            = dicom_data_obj.info.InstanceNumber;
    dcm_info.ImageType                 = dicom_data_obj.info.ImageType;
    dcm_info.PhotometricInterpretation = dicom_data_obj.info.PhotometricInterpretation;
    dcm_info.PixelRepresentation       = dicom_data_obj.info.PixelRepresentation;
    dcm_info.WindowCenter              = dicom_data_obj.info.WindowCenter;
    dcm_info.WindowWidth               = dicom_data_obj.info.WindowWidth;

    dicomwrite(dicom_data_obj.pixel_data(:, :, frame_index), file_path, dcm_info);
    pkg unload dicom;

endfunction;



% =============================================================================
%
% GUI Data Structure Section
%
% =============================================================================


