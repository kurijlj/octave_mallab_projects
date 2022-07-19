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
    root = uigetdir('.', 'DICOM Toolbox - Anonymize DICOM Folder: Select source');

    % Check if user selected anything
    if(isequal(0, root))
        % Nothing selected
        printf('%s: No source directory selected.\n', fname);

        return;

    endif;

    % Select target folder ----------------------------------------------------
    target = uigetdir(root, 'DICOM Toolbox - Anonymize DICOM Folder: Select destination');

    % Check if user selected anything
    if(isequal(0, target))
        % Nothing selected
        printf('%s: No destination directory selected.\n', fname);

        return;

    endif;

    % Load DICOM package ------------------------------------------------------
    pkg load dicom;

    % Search for DICOM files --------------------------------------------------

    % Start traversing through directory tree
    entries = readdir(root);

    % Remove current and parent directory from the list
    if(isequal('.', entries{1}))
        entries = {entries{2:end}};

    endif;
    if(isequal('..', entries{1}))
        entries = {entries{2:end}};

    endif;

    studies = {};
    series = {};
    flist = {};
    frames = {};

    if(0 ~= numel(entries))
        % We are not dealing with an empty directory. Search for directory
        % entries
        idx = 1;
        while(numel(entries) >= idx)
            path = fullfile(root, entries{idx});
            if(isfolder(path))
                % Search files in the subfolder
                flist = {flist{:} utlRecursiveFilelist(path){:}};

            elseif(isdicom(path))

                % Get header data
                info = dicominfo(path);

                % Check if file has an Study ID
                if(isfield(info, 'StudyInstanceUID'))
                    studies = {studies{:} getfield(info, 'StudyInstanceUID')};

                else
                    % No Study ID, skip file and go to next one
                    printf('FAILED. No Study ID\n');
                    i = i + 1;
                    continue;

                endif;

                % Check if file has an Series ID
                if(isfield(info, 'SeriesInstanceUID'))
                    series = {series{:} getfield(info, 'SeriesInstanceUID')};

                else
                    % No Series ID, skip file and go to next one
                    printf('FAILED. No Series ID\n');
                    i = i + 1;
                    continue;

                endif;

                % We have a valid DICOM image file so add it to the list
                flist = {flist{:} path};
                printf('PASSED\n');

                % Release buffer
                clear('info');

            endif;

            idx = idx + 1;

        endwhile;

    endif;

    % Unload DICOM package ----------------------------------------------------
    pkg unload dicom;

endfunction;
