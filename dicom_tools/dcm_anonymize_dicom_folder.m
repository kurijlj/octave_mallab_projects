% =============================================================================
% Copyright (C) 2022 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% This file is part of Utility Toolbox.
%
% Utility Toolbox is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the Free
% Software Foundation, either version 3 of the License, or (at your option) any
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
% 2022-07-19 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% * dcm_anonymize_folder.m: created.
%
% =============================================================================


% =============================================================================
%
% TODO:
%
% =============================================================================


% -----------------------------------------------------------------------------
%
% Script version info
%
% -----------------------------------------------------------------------------
dcm_anonymize_folder_version = '1.0';


% -----------------------------------------------------------------------------
%
% Load required packages
%
% -----------------------------------------------------------------------------
pkg load dicom;


% -----------------------------------------------------------------------------
%
% Function: dcmAnonymizeFolder
%
% Usage:
%       -- dcm_anonymize_folder()
%
% Descritpion: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function dcmAnonymizeFolder()

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'dcmAnonymizeFolder';
    use_case = ' -- dcmAnonymizeFolder()';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(0 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Select root folder ------------------------------------------------------
    root = uigetdir('', 'DICOM Toolbox: Anonymize DICOM Folder - Select source');

    % Check if user selected anything
    if(isequal(0, root))
        % Nothing selected
        printf('%s: No source directory selected.\n', fname);

        return;

    endif;

    % Select target folder ----------------------------------------------------
    target = uigetdir(root, 'DICOM Toolbox: Anonymize DICOM Folder - Select destination');

    % Check if user selected anything
    if(isequal(0, target))
        % Nothing selected
        printf('%s: No destination directory selected.\n', fname);

        return;

    endif;

    % Search for DICOM files --------------------------------------------------
    flist = dcmRecursiveFilelist(root);

    if(isempty(flist))
        printf('%s: No DICOM files were found in %s.\n', fname, root);

        return;

    endif;

    % Process files -----------------------------------------------------------
    printf('%s: %d DICOM file(s) found.\n', fname, numel(flist));
    printf('%s: Anonymizing:\n', fname);

    studies = {};
    series = {};
    new_study_uids = {};
    new_series_uids = {};
    new_frame_uids = {};
    new_instance_uids = {};
    instance_idx = [];
    basefn = strftime('IMG%Y%m%d%H%M%S', localtime(time()));
    datestr = basefn(4:11);
    timestr = strcat(basefn(12:end), '.000000');

    idx = 1;
    while(numel(flist) >= idx)

        info = dicominfo(flist{idx});

        % Check if we already have encountered this study
        if(~ismember(info.StudyInstanceUID, studies))
            % It's a study we have not encountered previously. Generate new
            % study and frame of reference UIDs
            studies = {studies{:}, info.StudyInstanceUID};
            new_study_uids = {new_study_uids{:}, dicomuid()};
            new_frame_uids = {new_frame_uids{:}, dicomuid()};

        endif

        % Check if we already have encountered this serie
        if(~ismember(info.SeriesInstanceUID, series))
            % It's a serie we have not encountered previously. Generate new
            % serie and instance UIDs
            series = {series{:}, info.SeriesInstanceUID};
            new_series_uids = {new_series_uids{:}, dicomuid()};
            new_instance_uids = {new_instance_uids{:}, dicomuid()};
            instance_idx = [instance_idx(:), 1];

        endif

        [tf, sdix] = ismember(info.StudyInstanceUID, studies);
        info.StudyInstanceUID = new_study_uids{sdix};
        info.FrameOfReferenceUID = new_frame_uids{sdix};
        targetfn = sprintf('%s%02d', basefn, sdix);

        [tf, sdix] = ismember(info.SeriesInstanceUID, series);
        info.SeriesInstanceUID = new_series_uids{sdix};
        info.SeriesNumber = sdix;
        % Add series index to destination filename
        targetfn = sprintf('%s%04d', targetfn, sdix);

        if(1 ~= instance_idx(sdix))
            instid = new_instance_uids{sdix};
            instidpref = instid(1:end - 4);
            instidsuf = str2double(instid(end - 3:end));
            instidsuf = instidsuf + 1;
            new_instance_uids{sdix} = sprintf('%s%04d', instidpref, instidsuf);

        endif;
        info.MediaStorageSOPInstanceUID = new_instance_uids{sdix};
        % Add instance index to destination filename
        targetfn = sprintf('%s%04d.dcm', targetfn, instance_idx(sdix));
        instance_idx(sdix) = instance_idx(sdix) + 1;

        info.StudyDate = datestr;
        info.SeriesDate = datestr;
        info.AcquisitionDate = datestr;
        info.ContentDate = datestr;
        info.AcquisitionDateTime = strcat(datestr, timestr);
        info.StudyTime = timestr;
        info.SeriesTime = timestr;
        info.AcquisitionTime = timestr;
        info.ContentTime = timestr;

        if(~isfield(info, 'PatientSex'))
            info.PatientSex = 'M';

        endif;

        info.PatientID = basefn(4:end);

        if(isequal('F', strtrim(info.PatientSex)))
            info.PatientName = 'Doe^Jane';

        else
            info.PatientName = 'Doe^John';

        endif;

        if(isfield(info, 'AccessionNumber'))
            info.AccessionNumber = '';

        endif;

        if(isfield(info, 'InstitutionName'))
            info.InstitutionName = '';

        endif;

        if(isfield(info, 'InstitutionAddress'))
            info.InstitutionAddress = '';

        endif;

        if(isfield(info, 'ReferringPhysicianName'))
            info.ReferringPhysicianName = '';

        endif;

        if(isfield(info, 'StationName'))
            info.StationName = '';

        endif;

        if(isfield(info, 'InstitutionalDepartmentName'))
            info.InstitutionalDepartmentName = '';

        endif;

        if(isfield(info, 'PatientBirthDate'))
            info.PatientBirthDate = '19000101';

        endif;

        if(isfield(info, 'PatientAge'))
            info.PatientAge = '';

        endif;

        % Read pixels and write data to the file
        img = dicomread(flist{idx});
        targetpt = fullfile(target, targetfn);
        dicomwrite(img, targetpt, info);

        % Release buffer
        clear('info', 'img');

        idx = idx + 1;

    endwhile;

endfunction;


% -----------------------------------------------------------------------------
%
% Function: dcmRecursiveFileList
%
% Usage:
%       -- flist = dcmRecursiveFileList()
%       -- flist = dcmRecursiveFileList(root)
%
% Descritpion: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function flist = dcmRecursiveFilelist(root)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'dcmRecursiveFileList';
    use_case_a = ' -- flist = dcmRecursiveFileList()';
    use_case_b = ' -- flist = dcmRecursiveFileList(root)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(0 ~= nargin && 1 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Check if user supplied any argument at all
    if(0 == nargin)
        % No argument supplied, use default value for the root
        root = '.';

    endif;

    % Check if user supplied a string
    if(~ischar(root))
        error('%s: root must be a string', fname);

    endif;

    % Check if root is a valid folder
    if(~isfolder(root))
        error('%s: root must be a valid local folder', fname);

    endif;

    % Start traversing through directory tree
    entries = readdir(root);

    % Remove current and parent directory from the list
    if(isequal('.', entries{1}))
        entries = {entries{2:end}};

    endif;
    if(isequal('..', entries{1}))
        entries = {entries{2:end}};

    endif;

    flist = {};
    if(0 ~= numel(entries))
        % We are not dealing with an empty directory. Search for directory
        % entries
        idx = 1;
        while(numel(entries) >= idx)
            path = fullfile(root, entries{idx});
            if(isfolder(path))
                % Search files in the subfolder
                flist = {flist{:} dcmRecursiveFilelist(path){:}};

            elseif(isdicom(path))
                % Add file to the file list
                flist = {flist{:} path};

            endif;

            idx = idx + 1;

        endwhile;

    endif;

endfunction;
