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
% * 1-D Haar Wavelets <https://www.numerical-tours.com/matlab/wavelet_1_haar1d/>
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
% function load_axis_data(file1, file2)
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = load_axis_data(file1, file2)
    % Initialize return variable
    result.raw_1 = NaN;
    result.raw_2 = NaN;

    % Do some basic sanity checks

    % First check if both arguments are supplied
    if(~file1)
        error(
            "load_axis_data: Missing argument",
            "Argument 'file1' is missing"
            );

    endif;

    if(~file2)
        error(
            "load_axis_data: Missing argument",
            "Argument 'file2' is missing"
            );

    endif;

    % Then check if we are dealing with existing regular files
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

    % Then check if files have regular file names
    match_name = "[0-9]{4}-[0-9]{2}-[0-9]{2}_[XYZ]_#[12]";
    match_ext  = ".dat";

    [dir, filename, extension] = fileparts(file1);

    if(~strcmp(match_ext, extension) || ~regexp(filename, match_name))
        error(
            "load_axis_data: Invalid data file",
            "File '%s' is not valid focus precision data file",
            file1
            );

    endif;

    [dir, filename, extension] = fileparts(file2);

    if(~strcmp(match_ext, extension) || ~regexp(filename, match_name))
        error(
            "load_axis_data: Invalid data file",
            "File '%s' is not valid focus precision data file",
            file2
            );

    endif;

    % Load data from file1
    fid = fopen(file1, 'r');

    % First let's count how many data rows we have
    rows = 1;
    while (~feof(fid))
        line = fgetl(fid);
        rows = rows + 1;
    endwhile;

    if(190 >= rows)
        error(
            "load_axis_data: Too few data points",
            "File '%s' has incomplete data set",
            file1, rows
            );

    endif;

    % Reset file position to beginning of the file
    fseek(fid, 0);

    % Allocate storage for data points
    result.raw_1 = zeros(rows - 1, 2);

    % Read and store data
    row = 1;
    while (~feof(fid))
        line = fgetl(fid);
        fields = strsplit(line);

        % Data in file must be arranged in exactly two columns
        if(2 ~= size(fields)(2))
        error(
            "load_axis_data: Invalid number of data fields",
            "File '%s' data integrity failed in row %s",
            file1, rows
            );

        endif;

        % Try to convert data strings to double
        x = str2double(fields(1));
        y = str2double(fields(2));

        % Check if conversion was successful
        if(NaN == x || NaN == y)
        error(
            "load_axis_data: Invalid data type",
            "File '%s' data integrity failed in row %s",
            file1, rows
            );

        endif;

        % Data integrity is a pass. Save the data
        result.raw_1(row, 1) = x / 1000;  % Divide by 1000 to get mm
        result.raw_1(row, 2) = y;

        row = row + 1;

    endwhile;

    fclose(fid);

    % Load data from file2
    fid = fopen(file2, 'r');

    % Reset row counter
    rows = 1;

    % Count number of rows
    while (~feof(fid))
        line = fgetl(fid);
        rows = rows + 1;
    endwhile;

    if(190 >= rows)
        error(
            "load_axis_data: Too few data points",
            "File '%s' has incomplete data set",
            file2, rows
            );

    endif;

    % Reset file position to beginning of the file
    fseek(fid, 0);

    % Allocate storage for data points
    result.raw_2 = zeros(rows - 1, 2);

    % Read and store data
    row = 1;
    while (~feof(fid))
        line = fgetl(fid);
        fields = strsplit(line);

        % Data in file must be arranged in exactly two columns
        if(2 ~= size(fields)(2))
        error(
            "load_axis_data: Invalid number of data fields",
            "File '%s' data integrity failed in row %s",
            file2, rows
            );

        endif;

        % Try to convert data strings to double
        x = str2double(fields(1));
        y = str2double(fields(2));

        % Check if conversion was successful
        if(NaN == x || NaN == y)
        error(
            "load_axis_data: Invalid data type",
            "File '%s' data integrity failed in row %s",
            file2, rows
            );

        endif;

        % Data integrity is a pass. Save the data
        result.raw_2(rows - row, 1) = x / 1000;  % Divide by 1000 to get mm
        result.raw_2(rows - row, 2) = y;

        row = row + 1;

    endwhile;

    fclose(fid);

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function load_profile_from_csv(file1)
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = load_profile_from_csv(file_name, dpi=400, delimiter=",")
    % Initialize return variable
    result = NaN;

    % Do some basic sanity checks

    % First check if both arguments are supplied
    if(~file_name)
        error(
            "load_profile_from_csv: Missing argument",
            "Argument 'file_name' is missing"
            );

    endif;

    % Then check if we are dealing with existing regular files
    if(~isfile(file_name))
        error(
            "load_profile_from_csv: File does not exist",
            "File '%s' does not exist or not a regular file",
            file_name
            );

    endif;

    % Calculate factor for converting pixels to milimeters according to
    % user supplied dpi
    pix_to_mm = 25.4 / dpi;

    % Load data from file

    % Load data from file
    fid = fopen(file_name, 'r');

    % Set row counter
    rows = 1;

    % Count number of rows so we can allocate data storage structure
    while (~feof(fid))
        line = fgetl(fid);
        rows = rows + 1;
    endwhile;

    % We hit 'feof' one iteration before conditional expression evaluation, so
    % we have to subtract one from row count. Also 'csv' files created by ImageJ
    % contain headers, and we don't need them.
    rows = rows - 2;

    % Reset file position to beginning of the file
    fseek(fid, 0);

    % Allocate storage for data points. We assume only two data columns
    result = zeros(rows, 2);

    % Read and store data

    % Set row counter so we can index row position in the data storage structure
    row = 1;

    % Read header line to put file pointer at the data rows beginning
    fgetl(fid);

    while (~feof(fid))
        line = fgetl(fid);
        fields = strsplit(line, delimiter);

        % Data in file must be arranged in exactly two columns
        if(2 ~= size(fields)(2))
        error(
            "load_profile_from_csv: Invalid number of data fields",
            "File '%s' data integrity failed in row %s",
            file1, rows
            );

        endif;

        % Try to convert data strings to double
        x = str2double(fields(1));
        y = str2double(fields(2));

        % Check if conversion was successful
        if(NaN == x || NaN == y)
        error(
            "load_profile_from_csv: Invalid data type",
            "File '%s' data integrity failed in row %s",
            file1, rows
            );

        endif;

        % Data integrity is a pass. Save the data
        result(row, 1) = x * pix_to_mm;  % Convert position to mm
        result(row, 2) = y;

        row = row + 1;

    endwhile;


    % We have finished loading
    fclose(fid);

endfunction;


% =============================================================================
%
% Haar Wavelet transform section
%
% =============================================================================

sample_signal = [4, 6, 10, 12, 8, 6, 5, 5];


% /////////////////////////////////////////////////////////////////////////////
%
% function fht(data) - Forward Haar Transform
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = fht(data)
    result = zeros(1, length(data));
    result(1:length(data)/2) = [data(1:2:length(data)) + data(2:2:length(data))] / sqrt(2);
    result(length(data)/2+1:length(data)) = [data(1:2:length(data)) - data(2:2:length(data))] / sqrt(2);
endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function iht(data) - Inverse Haar Transform
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = iht(data, diffs)
    dim = 2*length(data);
    result = zeros(1, dim);
    result(1:2:dim) = [data + diffs]/sqrt(2);
    result(2:2:dim) = [data - diffs]/sqrt(2);
endfunction;
