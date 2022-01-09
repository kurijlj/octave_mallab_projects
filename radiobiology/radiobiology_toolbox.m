% =============================================================================
% Radiobiology Toolbox - Set of tools for radiobiology modeling
%
%  Copyright (C) 2022 Ljubomir Kurij <ljubomir_kurij@protonmail.com>
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
% A set of functions and classes for modeling radiobiological effects of
% radiotherapy treatments
%
% =============================================================================


% =============================================================================
%
% 2022-01-05 Ljubomir Kurij <ljubomir_kurij@protonmail.com
%
% * radiobiology_toolbox.m: created.
%
% =============================================================================


% =============================================================================
%
% References (this section should be deleted in the release version)
%
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
printf("Radiobiology Toolbox v%s\n\n", kVersionString);


% =============================================================================
%
% Module load section
%
% =============================================================================


% =============================================================================
%
% Functions declarations
%
% =============================================================================

% /////////////////////////////////////////////////////////////////////////////
%
% function dvh_cuml_to_diff(dvh) - Convert cumulative DVH to differential one
%
% TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = dvh_cml_to_diff(cml_dvh)
    [nbins, ncols] = size(cml_dvh);

    % The matrix must have a minimum of two rows, and both columns must be of
    % equal length.
    if( 2 ~= ncols)
        error("dvh_cml_to_diff: Invalid number of columns (%d ~= 2).", ncols);
        return;
    endif

    if( 2 > nbins)
        error("dvh_cml_to_diff: Too few data points (< 2).");
        return;
    endif

    % Allocate memory for the resulting data matrix
    result = zeros(nbins-1, ncols);

    for i = 2:nbins
        result(i-1, 1) = cml_dvh(i-1, 1) + (cml_dvh(i, 1) - cml_dvh(i-1, 1))/2;
        if(0 >= (cml_dvh(i, 1) - result(i-1, 1)))
            error("dvh_cml_to_diff: DVH column 1, row %d <= column 1, row %d", ...
                i, i-1);
            return;

        endif;

        result(i-1, 2) = cml_dvh(i-1, 2) - cml_dvh(i, 2);
        if(0 > result(i-1, 2))
            error("dvh_cml_to_diff: DVH column 2, row %d > column 2, row %d", ...
                i, i-1);
            return;

        endif;
    endfor;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function dvh_read_from_gamma_plan(fname) - Read DVH data from GammaPlan file
%
% TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function [dvh_data, ...
        how_many_lines, ...
        struct_name, ...
        dvh_type, ...
        dose_algorithm ...
        ] = dvh_read_from_gamma_plan(file_path)
    dvh_data = NaN;

    func_name = "dvh_read_from_gamma_plan";
    error_flag = false;
    expected_many_data_rows = 0;

    % Open file for reading.
    file_id = fopen(file_path, "r");

    % Read how many lines file contains
    how_many_lines = fskipl(file_id, Inf);
    fseek(file_id, 0);

    fprintf(stdout, "%s: Validate file integrity for file: %s\n", ...
        func_name, ...
        file_path ...
        );

    % GammaPlan DVH files contain 8 lines long header and one trailing line at
    % the end of the file. For the DVH data to have any sense we need at least
    % two rows of data. So overall file containg DVH data at least, have to be
    % eleven lines long. If file contains less lines than that we take the given
    % file as corrupted.
    if(11 > how_many_lines)
        % File integrity failed, print error message to stderr and bail out.
        fclose(file_id);
        error_flag = true;
        error("To few data lines. Detected %d lines, required at least 11 lines.", ...
            how_many_lines ...
            );
        return;

    endif;

    fprintf(stdout, "%s: Validate file header integrity for file: %s\n", ...
        func_name, ...
        file_path ...
        );

    % Try to read number of data bins. Field containg number of data bins sits
    % on line four of the file header.
    fskipl(file_id, 3);
    line = fgetl(file_id);
    fseek(file_id, 0);

    % Check if we have correct data field.
    field_name= "number of bins";
    if(length(field_name) > length(line))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Missing 'Number of bins' field on line: 4.", ...
            func_name ...
            );

    else
        field_match = strncmpi(field_name, ...
            line(1, 1:length(field_name)), ...
            length(field_name) ...
            );

        if(not(field_match))
            fprintf(stderr, ...
                "%s: ERROR: Missing 'Number of bins' field on line: 4.", ...
                func_name ...
                );

        else
            % 
            expected_many_data_rows = str2num(line(1, ...
                (length(field_name) + 4):length(line) ...
                ));

        endif;

    endif;

    % Check if 'Number of bins' matches actual number of data rows.
    how_many_data_rows = how_many_lines - 9;
    if(how_many_data_rows ~= expected_many_data_rows)
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Actual data rows count does not match value stored in 'Number of bins' field (detected %d data rows, expected %d).", ...
            func_name, ...
            how_many_data_rows, ...
            expected_many_data_rows ...
            );

    endif;

    % Try to read structure name. Field containg structure name sits on line
    % one of the file header.
    line = fgetl(file_id);
    fseek(file_id, 0);

    % Check if we have correct data field.
    field_name= "name";
    field_match = strncmpi(field_name, ...
        line(1, 1:length(field_name)), ...
        length(field_name) ...
        );
    if(not(field_match) || (length(field_name) > length(line)))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Missing 'Name' field on line: 1.", ...
            func_name ...
            );

    endif;

    struct_name = line(1, (length(field_name) + 4):length(line));

    % Try to read DVH type. Field containg DVH type sits on line two of the
    % file header.
    fskipl(file_id, 1);
    line = fgetl(file_id);
    fseek(file_id, 0);

    % Check if we have correct data field.
    field_name= "type";
    field_match = strncmpi(field_name, ...
        line(1, 1:length(field_name)), ...
        length(field_name) ...
        );
    if(not(field_match) || (length(field_name) > length(line)))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Missing 'Tyie' field on line: 2.", ...
            func_name ...
            );

    endif;

    dvh_type = line(1, (length(field_name) + 4):length(line));

    % Try to read dose algorithm. Field containg dose algorithm sits on line
    % three of the file header.
    fskipl(file_id, 2);
    line = fgetl(file_id);
    fseek(file_id, 0);

    % Check if we have correct data field.
    field_name= "dose algorithm";
    field_match = strncmpi(field_name, ...
        line(1, 1:length(field_name)), ...
        length(field_name) ...
        );
    if(not(field_match) || (length(field_name) > length(line)))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Missing 'Dose algorithm' field on line: 3.", ...
            func_name ...
            );

    endif;

    dose_algorithm = line(1, (length(field_name) + 3):length(line));

    % Verify integrity of remaining header fields.
    fskipl(file_id, 4);
    line = fgetl(file_id);
    fseek(file_id, 0);

    field_name= "bin size";
    field_match = strncmpi(field_name, ...
        line(1, 1:length(field_name)), ...
        length(field_name) ...
        );
    if(not(field_match) || (length(field_name) > length(line)))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Missing 'Bin size' field on line: 5.", ...
            func_name ...
            );

    endif;

    fskipl(file_id, 5);
    line = fgetl(file_id);
    fseek(file_id, 0);

    field_name= "bin range";
    field_match = strncmpi(field_name, ...
        line(1, 1:length(field_name)), ...
        length(field_name) ...
        );
    if(not(field_match) || (length(field_name) > length(line)))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Missing 'Bin range' field on line: 6.", ...
            func_name ...
            );

    endif;

    fskipl(file_id, 7);
    line = fgetl(file_id);
    h1 = "bin center";
    h2 = "volume";

    field_match = strncmpi(h1, ...
        line(1, 1:length(h1)), ...
        length(h1) ...
        );
    if(not(field_match) || ((length(h1) + 4) > length(line)))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Missing 'Bin center' data column on line: 8.", ...
            func_name ...
            );

    endif;

    field_match = strncmpi(h2, ...
        line(1, (length(h1) + 6):(length(h1) + 6 + length(h2))), ...
        length(h2) ...
        );
    if(not(field_match) || ((length(h2) + 4) > length(line)))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Missing 'Volume' data column on line: 8.", ...
            func_name ...
            );

    endif;

    if(error_flag)
        fclose(file_id);
        error("File '%s' is corrupted!");
        return;

    endif;

    fclose(file_id);
endfunction;
