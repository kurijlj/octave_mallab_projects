% -----------------------------------------------------------------------------
%
% Function 'dcm_reset':
%
% Use:
%       -- dcm_reset ()
%       -- dcm_reset (..., "PROPERTY", VALUE, ...)
%
% Description:
% Anonymize DICOM images.
%
% DICOM tags that can be set by the user as using property-values:
%       PatientName
%       PatientID
%       PatientSex
%
% -----------------------------------------------------------------------------
function dcm_reset(varargin)
    % Store function name into variable for easier lgo reporting and user
    % feedback management
    fname = 'dcm_reset';

    % Load DICOM package
    graphics_toolkit qt;
    pkg load dicom;

    % Initialize function variables to default values
    fplist = {};
    destdir = '';
    userparams = {'PatientName', 'PatientID', 'PatientSex'};
    useroptions = {NaN, NaN, NaN};  % {PatientName, PatientID, PatientSex}

    % Parse and store imput arguments
    [pstnl, props] = parseparams (varargin);

    % Check if any of positional arguments is passed
    if(~isempty(pstnl))
        % No positional arguments passed
        error('Invalid call to function %s. See help for correct usage', fname);

        return;

    endif;

    % Process property arguments
    if(~isempty(props))
        nprops = length(props);
        i = 1;
        while(nprops >= i)
            switch(props{1})
            case 'PatientName'
                if(nprops > i)
                    % Most probably a string containing patient name
                    useroptions{1} = props{i + 1};

                endif;

            case 'PatientID'
                if(nprops > i)
                    % Most probably a string containing patient ID
                    useroptions{2} = props{i + 1};

                endif;

            case 'PatientSex'
                if(nprops > i)
                    % Most probably a string containing patient sex
                    useroptions{3} = props{i + 1};

                endif;

            otherwise
                error('Invalid call to function %s. See help for correct usage', fname);

                return;

            endswitch;

            i = i + 1;

        endwhile;

    endif;

    % Validate user supplied properties
    i = 1;
    while(length(useroptions) >= i)
        if(~isnan(useroptions{i}) && ~ischar(useroptions{i}))
            error('Invalid call to function parameter %s. See help for correct usage', userparams{i});

            return;

        endif;

        i = i + 1;

    endwhile;

    % Get input files
    [file, srcdir] = uigetfile( ...
        {"*;*.dcm;*.DCM", "DICOM File"}, ...
        'DICOM Toolbox - Reset Series: Select DICOM files', ...
        'MultiSelect', 'on' ...
        );

    if(~isequal(0, file) && ~isequal(0, srcdir))
        if(iscell(file))
            i = 1;
            while(length(file) >= i)
                fplist = {fplist{:} fullfile(srcdir, file{i})};
                i = i + 1;

            endwhile;

        else
            fplist = {fullfile(srcdir, file)};

        endif;

    else
        % Nothing selected
        printf('%s: No file selected.\n', fname);

        return;

    endif;

    destdir = uigetdir( ...
        srcdir, ...
        'DICOM Toolbox - Reset Series: Select destination directory' ...
        );

    % Check of user selected a destination dir
    if(isequal(0, destdir))
        % Use source dir as destination
        destdir = srcdir;

    endif;

    % printf('%s: Source directory: %s\n', fname, srcdir);
    % printf('%s: Destination directory: %s\n', fname, destdir);
    % i = 1;
    % while(length(fplist) >= i)
    %     printf('%s: File #%d: %s\n', fname, i, fplist{i});

    %     i = i + 1;

    % endwhile;

    % Initialize dicom data structures
    dcminfo = dcm_init_info();
    dcmfplist = {};
    dcmoldstudies = {};
    dcmnewstudies = {};
    dcmoldseries = {};
    dcmnewseries = {};
    dcmnewfor = {};
    dcmnewinst = {};

    % Validate DICOM files and collect series and studies info
    printf('%s: Validating selected files:\n', fname);
    i = 1;
    while(length(fplist) >= i)
        printf('\"%s\": ', fplist{i});

        if(isdicom(fplist{i}))
            info = dicominfo(fplist{i});

            % Check if file has an Study ID
            if(isfield(info, 'StudyInstanceUID'))
                dcmoldstudies = {dcmoldstudies{:} getfield(info, 'StudyInstanceUID')};

            else
                % No Study ID, skip file and go to next one
                printf('FAILED. No Study ID\n');
                i = i + 1;
                continue;

            endif;

            % Check if file has an Series ID
            if(isfield(info, 'SeriesInstanceUID'))
                dcmoldseries = {dcmoldseries{:} getfield(info, 'SeriesInstanceUID')};

            else
                % No Series ID, skip file and go to next one
                printf('FAILED. No Series ID\n');
                i = i + 1;
                continue;

            endif;

            % We have a valid DICOM image file so add it to the list
            dcmfplist = {dcmfplist{:} fplist{i}};
                printf('PASSED\n');

        else
            % Not a DICOM file
            printf('FAILED. Not a DICOM file\n', fname, fplist{i});

        endif;

        % Release buffer
        clear('info');

        i = i + 1;

    endwhile;

    % Keep only unique values
    dcmoldstudies = unique(dcmoldstudies);
    dcmoldseries = unique(dcmoldseries);

    % Generate new study, series and instance IDs
    i = 1;
    while(length(dcmoldstudies) >= i)
        dcmnewstudies = {dcmnewstudies{:} dicomuid()};
        dcmnewfor = {dcmnewfor{:} dicomuid()};

        i = i + 1;

    endwhile;

    i = 1;
    while(length(dcmoldseries) >= i)
        dcmnewseries = {dcmnewseries{:} dicomuid()};
        dcmnewinst = {dcmnewinst{:} dicomuid()};

        i = i + 1;

    endwhile;

    if(~isempty(dcmfplist))
        printf('%s: Writting data ...\n', fname);
        % Format filename base
        fnbase = strftime('IMG%Y%m%d%H%M%S', localtime(time()));
        instindex = ones(length(dcmnewinst), 1);  % Keeps track of series instance index
        i = 1;
        while(length(dcmfplist) >= i)
            info = dicominfo(dcmfplist{i});
            img = dicomread(dcmfplist{i});

            % Copy DICOM header data
            instinfo = dcminfo;

            % Get Study ID index, and set new Study ID and Frame of Reference ID
            [tf, sdix] = ismember(info.StudyInstanceUID, dcmoldstudies);
            instinfo.StudyInstanceUID = dcmnewstudies{sdix};
            instinfo.StudyID = sprintf(' %04d', sdix);
            instinfo.StudyDescription = sprintf('Study #%04d', sdix);
            instinfo.FrameOfReferenceUID = dcmnewfor{sdix};
            % Add study index to destination filename
            destfn = sprintf('%s%02d', fnbase, sdix);

            % Get Series ID index, and set new Series ID and Instance ID
            [tf, sdix] = ismember(info.SeriesInstanceUID, dcmoldseries);
            instinfo.SeriesInstanceUID = dcmnewseries{sdix};
            instinfo.SeriesNumber = sdix;
            % Add series index to destination filename
            destfn = sprintf('%s%04d', destfn, sdix);  % Destination file name

            if(1 ~= instindex(sdix))
                instid = dcmnewinst{sdix};
                instidpref = instid(1:end - 4);
                instidsuf = str2double(instid(end - 3:end));
                instidsuf = instidsuf + 1;
                dcmnewinst{sdix} = sprintf('%s%04d', instidpref, instidsuf);

            endif;
            instinfo.MediaStorageSOPInstanceUID = dcmnewinst{sdix};
            % Add instance index to destination filename
            destfn = sprintf('%s%04d.dcm', destfn, instindex(sdix));  % Destination file name
            instindex(sdix) = instindex(sdix) + 1;

            if(~isnan(useroptions{1}))
                % Use user supplied patient name
                instinfo.PatientName = useroptions{1};

            endif;

            if(~isnan(useroptions{2}))
                % Use user supplied patient ID
                instinfo.PatientID = useroptions{2};

            endif;

            if(~isnan(useroptions{3}))
                % Use user supplied patient sex
                instinfo.PatientSex = useroptions{2};

            elseif(isfield(info, 'PatientSex'))
                % or copy field value from original data
                instinfo.PatientSex = info.PatientSex;
                if(isequal('F', strtrim(info.PatientSex)) && isnan(useroptions{1}))
                    % If female patient assaign a generic female name
                    instinfo.PatientName = 'Doe^Jane';

                endif;

            endif;

            if(isfield(info, 'MediaStorageSOPClassUID'))
                instinfo.MediaStorageSOPClassUID = info.MediaStorageSOPClassUID;

            endif;

            if(isfield(info, 'TransferSyntaxUID'))
                instinfo.TransferSyntaxUID = info.TransferSyntaxUID;

            endif;

            if(isfield(info, 'SOPClassUID'))
                instinfo.SOPClassUID = info.SOPClassUID;

            endif;

            if(isfield(info, 'Modality'))
                instinfo.Modality = info.Modality;

            endif;

            if(isfield(info, 'BitsStored'))
                instinfo.BitsStored = info.BitsStored;

            endif;

            if(isfield(info, 'BitsAllocated'))
                instinfo.BitsAllocated = info.BitsAllocated;

            endif;

            if(isfield(info, 'HighBit'))
                instinfo.HighBit = info.HighBit;

            endif;

            if(isfield(info, 'SamplesPerPixel'))
                instinfo.SamplesPerPixel = info.SamplesPerPixel;

            endif;

            if(isfield(info, 'Rows'))
                instinfo.Rows = info.Rows;

            else
                instinfo.Rows = size(img)(1);

            endif;

            if(isfield(info, 'Columns'))
                instinfo.Columns = info.Columns;

            else
                instinfo.Rows = size(img)(2);

            endif;

            if(isfield(info, 'InstanceNumber'))
                instinfo.InstanceNumber = info.InstanceNumber;

            endif;

            if(isfield(info, 'ImagePositionPatient'))
                instinfo.ImagePositionPatient = info.ImagePositionPatient;

            endif;

            if(isfield(info, 'ImageOrientationPatient'))
                instinfo.ImageOrientationPatient = info.ImageOrientationPatient;

            endif;

            if(isfield(info, 'ImageType'))
                instinfo.ImageType = info.ImageType;

            endif;

            if(isfield(info, 'PixelSpacing'))
                instinfo.PixelSpacing = info.PixelSpacing;

            endif;

            if(isfield(info, 'PhotometricInterpretation'))
                instinfo.PhotometricInterpretation = info.PhotometricInterpretation;

            else
                instinfo.PhotometricInterpretation = 'MONOCHROME2';

            endif;

            if(isfield(info, 'PixelRepresentation'))
                instinfo.PixelRepresentation = info.PixelRepresentation;

            endif;

            if(isfield(info, 'WindowCenter'))
                instinfo.WindowCenter = info.WindowCenter;

            endif;

            if(isfield(info, 'WindowWidth'))
                instinfo.WindowWidth = info.WindowWidth;

            endif;

            if(isfield(info, 'RescaleType'))
                instinfo.RescaleType = info.RescaleType;

            endif;

            if(isfield(info, 'RescaleIntercept'))
                instinfo.RescaleIntercept = info.RescaleIntercept;

            endif;

            if(isfield(info, 'RescaleSlope'))
                instinfo.RescaleSlope = info.RescaleSlope;

            endif;

            % Write data to the file
            destpath = fullfile(destdir, destfn);
            printf('Writting to file: %s\n', destpath);
            dicomwrite(img, destpath, instinfo);

            % Release buffer
            clear('instinfo', 'info', 'img');

            i = i + 1;

        endwhile;

    else
        printf('%s: No DICOM files detected. Nothing to process\n');

    endif;

endfunction;
