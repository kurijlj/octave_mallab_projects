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
    line_index = 0;

    % Verify if file for given path exists at all.
    if(not(isfile(file_path)))
        error("File '%s' does not exist, or not a regular file.", file_path);
        return;

    endif;

    % Open file for reading.
    file_id = fopen(file_path, "r");

    % Read how many lines file contains
    how_many_lines = fskipl(file_id, Inf);
    fseek(file_id, 0);

    fprintf(stdout, "%s: Verify file integrity for '%s' ...\n", ...
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
        fprintf(stderr, ...
            "%s: ERROR: To few lines detected. Expecting at least: 11 lines, detected: %d.\n", ...
            func_name, ...
            how_many_lines ...
            );
        error("File integrity for '%s': FAILED!", file_path);
        return;

    endif;

    fprintf(stdout, "%s: File integrity for '%s': PASSED.\n", ...
        func_name, ...
        file_path ...
        );

    % File integrity check complete. Proceed with file header integrity check.
    fprintf(stdout, "%s: Verify file header integrity for: %s ...\n", ...
        func_name, ...
        file_path ...
        );

    % Try to read structure name. Field containg structure name sits on the
    % first line of file header. First seven characters of the line containing
    % structure name are reserved for the field name and equality sign
    % separated from the words by spaces, e.g.:
    %
    %   Name = structure_namehttps://doi.org/10.1148/rg.293075172
    %
    % For the line with structure name to have any sense line must be at least
    % eight characters long.
    field_name = "Name";
    min_line_length = 8;
    line = fgetl(file_id);
    line_index = line_index + 1;

    % Check if line length conforms to minimum required line length.
    if(min_line_length > length(line))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Data length missmatch. Expecting at least 8 characters on line: %d, detected: %d.\n", ...
            func_name, ...
            line_index, ...
            length(line) ...
            );

    else
        % Check if we have correct field name.
        field_match = strncmp(field_name, ...
            line(1, 1:length(field_name)), ...
            length(field_name) ...
            );
        if(not(field_match))
            error_flag = true;
            fprintf(stderr, ...
                "%s: ERROR: field name missmatch. Expecting field:'%s' on line: %d, detected field: '%s'.\n", ...
                func_name, ...
                field_name, ...
                line_index, ...
                line(1, 1:length(field_name)) ...
                );

        else
            % Store structure name in the result variable.
            struct_name = line(1, (length(field_name) + 4):length(line));

        endif;

    endif;

    % Try to read DVH type. Field containg DVH type sits on the second line of
    % file header. First seven characters of the line containing DVH type
    % are reserved for the field name and equality sign separated from the
    % words by spaces, e.g.:
    %
    %   Type = Cumulative
    %
    % or
    %
    %   Type = Differential
    %
    % DVH type field value can only be one of 'Cumulative', or'Differential'.
    field_name = "Type";
    valid_input = {"Cumulative", "Differential"};
    line = fgetl(file_id);
    line_index = line_index + 1;

    % Check if line length conforms to minimum required line length, i.e. when
    % DVH type is 'Cumulative'.
    if((length(field_name) + 3 + length(valid_input{1, 1})) > length(line))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Data length missmatch. Expecting at least 17 characters on line: %d, detected: %d.\n", ...
            func_name, ...
            line_index, ...
            length(line) ...
            );

    else
        % Check if we have correct field name.
        field_match = strncmp(field_name, ...
            line(1, 1:length(field_name)), ...
            length(field_name) ...
            );
        if(not(field_match))
            error_flag = true;
            fprintf(stderr, ...
                "%s: ERROR: field name missmatch. Expecting field:'%s' on line: %d, detected field: '%s'.\n", ...
                func_name, ...
                field_name, ...
                line_index, ...
                line(1, 1:length(field_name)) ...
                );

        endif;

        % Store DVH type in the result variable.
        dvh_type = line(1, (length(field_name) + 4):length(line));

        % Check of we have correct field value (i.e. 'Cumulative' or
        % 'Differential')
        if(length(valid_input{1, 1}) == length(dvh_type))
            % String length matches 'Cumulative'. Let's check if we really have
            % the right string.
            value_match = strncmp(valid_input{1, 1}, ...
                dvh_type, ...
                length(valid_input{1, 1}) ...
                );

            if(not(value_match))
                error_flag = true;
                fprintf(stderr, ...
                    "%s: ERROR: Invalid input. Expecting value:'%s' on line: %d, detected value: '%s'.\n", ...
                    func_name, ...
                    valid_input{1, 1}, ...
                    line_index, ...
                    dvh_type ...
                    );

            endif;

        else
            % It must be 'Differential' then.  Let's check if we really have
            % the right string.
            value_match = strncmp(valid_input{1, 2}, ...
                dvh_type, ...
                length(valid_input{1, 2}) ...
                );

            if(not(value_match))
                error_flag = true;
                fprintf(stderr, ...
                    "%s: ERROR: Invalid input. Expecting value:'%s' on line: %d, detected value: '%s'.\n", ...
                    func_name, ...
                    valid_input{1, 2}, ...
                    line_index, ...
                    dvh_type ...
                    );

            endif;

        endif;

    endif;

    % Try to read dose algorithm. Field containg dose algorithm sits on the
    % third line of file header. First sixteen characters of the line
    % containing dose algorithm are reserved for the field name and column (:)
    % separated from the value by space, e.g.:
    %
    %   Dose algorithm: TMR Classic
    %
    % or
    %
    %   Dose algorithm: TMR 10
    %
    % Dose algorithm field value can only be one of 'TMR Classic', or 'TMR 10'.
    field_name = "Dose algorithm";
    valid_input = {"TMR Classic", "TMR 10"};
    line = fgetl(file_id);
    line_index = line_index + 1;

    % Check if line length conforms to minimum required line length, i.e. when
    % dose algorithm is 'TMR 10'.
    if((length(field_name) + 2 + length(valid_input{1, 2})) > length(line))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Data length missmatch. Expecting at least 22 characters on line: %d, detected: %d.\n", ...
            func_name, ...
            line_index, ...
            length(line) ...
            );

    else
        % Check if we have correct field name.
        field_match = strncmp(field_name, ...
            line(1, 1:length(field_name)), ...
            length(field_name) ...
            );
        if(not(field_match))
            error_flag = true;
            fprintf(stderr, ...
                "%s: ERROR: field name missmatch. Expecting field:'%s' on line: %d, detected field: '%s'.\n", ...
                func_name, ...
                field_name, ...
                line_index, ...
                line(1, 1:length(field_name)) ...
                );

        endif;

        % Store dose algorithm in the result variable.
        dose_algorithm = line(1, (length(field_name) + 3):length(line));

        % Check of we have correct field value (i.e. 'TMR Classic' or
        % 'TMR 10')
        if(length(valid_input{1, 1}) == length(dose_algorithm))
            % String length matches 'TMR Classic'. Let's check if we really have
            % the right string.
            value_match = strncmp(valid_input{1, 1}, ...
                dose_algorithm, ...
                length(valid_input{1, 1}) ...
                );

            if(not(value_match))
                error_flag = true;
                fprintf(stderr, ...
                    "%s: ERROR: Invalid input. Expecting value:'%s' on line: %d, detected value: '%s'.\n", ...
                    func_name, ...
                    valid_input{1, 1}, ...
                    line_index, ...
                    dvh_type ...
                    );

            endif;

        else
            % It must be 'TMR 10' then.  Let's check if we really have
            % the right string.
            value_match = strncmp(valid_input{1, 2}, ...
                dose_algorithm, ...
                length(valid_input{1, 2}) ...
                );

            if(not(value_match))
                error_flag = true;
                fprintf(stderr, ...
                    "%s: ERROR: Invalid input. Expecting value:'%s' on line: %d, detected value: '%s'.\n", ...
                    func_name, ...
                    valid_input{1, 2}, ...
                    line_index, ...
                    dvh_type ...
                    );

            endif;

        endif;

    endif;

    % Try to read number of data bins. Field containg number of data bins sits
    % on the fourth line of file header. First seventeen characters of the line
    % containing number of data bins are reserved for the field name and
    % equality sign separated from the words by spaces, e.g.:
    %
    %   Number of bins = number_of_bins
    %
    % For the line with number of bins to have any sense line must be at least
    % eighteen characters long.
    field_name = "Number of bins";
    min_line_length = 18;
    line = fgetl(file_id);
    line_index = line_index + 1;


    % Check if line length conforms to minimum required line length.
    if(min_line_length > length(line))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Data length missmatch. Expecting at least 18 characters on line: %d, detected: %d.\n", ...
            func_name, ...
            line_index, ...
            length(line) ...
            );

    else
        % Check if we have correct field name.
        field_match = strncmp(field_name, ...
            line(1, 1:length(field_name)), ...
            length(field_name) ...
            );
        if(not(field_match))
            error_flag = true;
            fprintf(stderr, ...
                "%s: ERROR: field name missmatch. Expecting field:'%s' on line: %d, detected field: '%s'.\n", ...
                func_name, ...
                field_name, ...
                line_index, ...
                line(1, 1:length(field_name)) ...
                );

        else
            % Store number of bins in the result variable.
            expected_many_data_rows = str2double(line(1, ...
                (length(field_name) + 4):length(line) ...
                ));
            if(isnan(expected_many_data_rows))
                error_flag = true;
                fprintf(stderr, ...
                    "%s: ERROR: Invalid value. Expecting a number value for field:'%s' on line: %d, detected: '%s'.\n", ...
                    func_name, ...
                    field_name, ...
                    line_index, ...
                    line(1, (length(field_name) + 4):length(line)) ...
                    );

            endif;

        endif;

    endif;

    % Verify integrity of the 'Bin size' field. Field containg bin size sits on
    % the fifth line of file header. Since we are not using value of this field
    % for now, we only check for the existence of the correct field name. First
    % eleven characters of the bins size line are reserved for the field name
    % and equality sign separated from the words by spaces, e.g.:
    %
    %   Bin size = floating_point_value Gy
    %
    % For the line with bin size to have any sense, it must be at least
    % fifteen characters long.
    field_name = "Bin size";
    min_line_length = 15;
    line = fgetl(file_id);
    line_index = line_index + 1;

    % Check if line length conforms to minimum required line length.
    if(min_line_length > length(line))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Data length missmatch. Expecting at least 15 characters on line: %d, detected: %d.\n", ...
            func_name, ...
            line_index, ...
            length(line) ...
            );

    else
        % Check if we have correct field name.
        field_match = strncmp(field_name, ...
            line(1, 1:length(field_name)), ...
            length(field_name) ...
            );
        if(not(field_match))
            error_flag = true;
            fprintf(stderr, ...
                "%s: ERROR: field name missmatch. Expecting field:'%s' on line: %d, detected field: '%s'.\n", ...
                func_name, ...
                field_name, ...
                line_index, ...
                line(1, 1:length(field_name)) ...
                );

        endif;

    endif;

    % Verify integrity of the 'Bin range' field. Field containg bin range sits
    % on the sixth line of file header. Since we are not using value of this
    % field for now, we only check for the existence of the correct field name.
    % First twelve characters of the bins range line are reserved for the field
    % name and equality sign separated from the words by spaces, e.g.:
    %
    %   Bin range = floating_point_value -> loating_point_value Gy
    %
    % For the line with bin range to have any sense, it must be at least
    % twentyone characters long.
    field_name = "Bin range";
    min_line_length = 21;
    line = fgetl(file_id);
    line_index = line_index + 1;

    % Check if line length conforms to minimum required line length.
    if(min_line_length > length(line))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Data length missmatch. Expecting at least 21 characters on line: %d, detected: %d.\n", ...
            func_name, ...
            line_index, ...
            length(line) ...
            );

    else
        % Check if we have correct field name.
        field_match = strncmp(field_name, ...
            line(1, 1:length(field_name)), ...
            length(field_name) ...
            );
        if(not(field_match))
            error_flag = true;
            fprintf(stderr, ...
                "%s: ERROR: field name missmatch. Expecting field:'%s' on line: %d, detected field: '%s'.\n", ...
                func_name, ...
                field_name, ...
                line_index, ...
                line(1, 1:length(field_name)) ...
                );

        endif;

    endif;

    % Verify integrity of the data header. Data header sits on the eight line of
    % file header and it consists of two column titles for every GammaPlan DVH
    % file: 'Bin center(Gy)' and 'Volume(mm3)', separated by a space.
    column_title = {"Bin center(Gy)", "Volume(mm3)"};
    valid_line_length = 26;
    fskipl(file_id, 1);
    line = fgetl(file_id);
    line_index = line_index + 2;

    % Check if line length conforms to minimum required line length.
    if(valid_line_length ~= length(line))
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Data length missmatch. Expecting %d characters on line: %d, detected: %d.\n", ...
            func_name, ...
            valid_line_length, ...
            line_index, ...
            length(line) ...
            );

    else
        % Check if we have correct column titles.
        title_match = strncmp(column_title{1, 1}, ...
            line(1, 1:length(column_title{1, 1})), ...
            length(column_title(1, 1)) ...
            );
        if(not(title_match))
            error_flag = true;
            fprintf(stderr, ...
                "%s: ERROR: column title missmatch. Expecting column:'%s' on line: %d, detected: '%s'.\n", ...
                func_name, ...
                column_title{1, 1}, ...
                line_index, ...
                line(1, 1:length(column_title{1, 1})) ...
                );

        endif;

        title_match = strncmp(column_title{1, 2}, ...
            line(1, (length(column_title{1, 1}) + 2):length(line)), ...
            length(column_title{1, 2}) ...
            );
        if(not(title_match))
            error_flag = true;
            fprintf(stderr, ...
                "%s: ERROR: column title missmatch. Expecting column:'%s' on line: %d, detected: '%s'.\n", ...
                func_name, ...
                column_title{1, 2}, ...
                line_index, ...
                line(1, (length(column_title{1, 1}) + 1):length(line)) ...
                );

        endif;

    endif;

    if(error_flag)
        fclose(file_id);
        error("File header integrity for '%s': FAILED!", file_path);
        return;

    endif;

    fprintf(stdout, "%s: File header integrity for '%s': PASSED.\n", ...
        func_name, ...
        file_path ...
        );

    % File header integrity check complete. Proceed with data integrity check.
    fprintf(stdout, "%s: Verify data integrity for: %s ...\n", ...
        func_name, ...
        file_path ...
        );

    % Check if 'Number of bins' matches actual number of data rows.
    how_many_data_rows = how_many_lines - 9;
    if(how_many_data_rows ~= expected_many_data_rows)
        error_flag = true;
        fprintf(stderr, ...
            "%s: ERROR: Actual data rows count does not match value stored in 'Number of bins' field (detected %d data rows, expected %d).\n", ...
            func_name, ...
            how_many_data_rows, ...
            expected_many_data_rows ...
            );

    endif;

    % If number of data rows is incosistent with number stored in file header,
    % the data must be corupt. Print error message and abort code execution.
    if(error_flag)
        fclose(file_id);
        error("Data integrity for '%s': FAILED!", file_path);
        return;

    endif;

    % Else, reserve memory for the data, ...
    dvh_data = zeros(expected_many_data_rows, 2);

    % and start reading data rows ...
    line = fgetl(file_id);
    line_index = line_index + 1;
    while(-1 ~= line)
        result = strsplit(line);

        % Verify data integrity ...
        if(2 ~= length(result))
            error_flag = true;
            fprintf(stderr, ...
                "%s: ERROR: Invalid data length on line: %d.\n", ...
                func_name, ...
                line_index ...
                );

        else
            % Try to convert field values to numbers.
            bin = str2double(result{1, 1});
            volume = str2double(result{1, 2});
            if(isnan(bin))
                error_flag = true;
                fprintf(stderr, ...
                    "%s: ERROR: Can not convert value 1 to number on line: %d.\n", ...
                    func_name, ...
                    line_index ...
                    );

            else
                dvh_data(line_index-8, 1) = bin;

            endif;
            if(isnan(volume))
                error_flag = true;
                fprintf(stderr, ...
                    "%s: ERROR: Can not convert value 2 to number on line: %d.\n", ...
                    func_name, ...
                    line_index ...
                    );

            else
                dvh_data(line_index-8, 2) = volume;

            endif;

            line = fgetl(file_id);
            line_index = line_index + 1;

        endif;

    endwhile;

    if(error_flag)
        fclose(file_id);
        error("Data integrity for '%s': FAILED!", file_path);
        return;

    endif;

    fprintf(stdout, "%s: Data integrity for '%s': PASSED.\n", ...
        func_name, ...
        file_path ...
        );

    fclose(file_id);

endfunction;
