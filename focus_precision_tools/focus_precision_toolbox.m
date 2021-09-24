% =============================================================================
% Focus Precision Toolbox - Focus precision log data anlysis tools
%
%  Copyright (C) 2021 Ljubomir Kurij <ljubomir_kurij@protonmail.com>
%
% This program is free software: you can redistribute it and/or modify
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
% Description
% ----------------------------------------------------------------------------
%
% A set of functions and classes for analyzing and displaying of focus
% precision measurements from focus precision QA log files.
%
% =============================================================================


% =============================================================================
%
% 2021-09-24 Ljubomir Kurij <ljubomir_kurij@protonmail.com
%
% * focus_precision_toolbox.m: created.
%
% =============================================================================


% =============================================================================
%
% References (this section should be deleted in the release version)
%
% * Applied Medical Image Processing 2nd Ed, CRC Press
% * DICOM is Easy <https://dicomiseasy.blogspot.com/>
%
% =============================================================================


% =============================================================================
%
% Script header
%
% =============================================================================

% We put dummy expression into scripts header to prevent Octave command line
% enivornment to interpret it as a simple function file
kVersionString = "0.1";
printf("Focus Precision Toolbox v%s\n\n", kVersionString);


% =============================================================================
%
% Functions declarations
%
% =============================================================================


% /////////////////////////////////////////////////////////////////////////////
%
% function load_axis_data()
%
% TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function load_axis_data(file1, file2)
    % Do some basic sanity checks
    match_pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}_[XYZ]_#[12]\.dat";

    if(~regexp(file1, match_pattern))
        error(
            "load_axis_data: Invalid data file",
            "File '%s' is not valid focus precision data file",
            file1
            );

    endif;

    if(~regexp(file2, match_pattern))
        error(
            "load_axis_data: Invalid data file",
            "File '%s' is not valid focus precision data file",
            file1
            );

    endif;

    if(~isfile(file1))
        error(
            "load_axis_data: File does not exist",
            "File '%s' does not exist or not a regular file",
            file1
            );

    endif;

    if(~isfile(file2))
        error(
            "load_axis_data: File does not exist",
            "File '%s' does not exist or not a regular file",
            file2
            );

    endif;

    printf("%s\n%s\n\n", file1, file2);

endfunction;
