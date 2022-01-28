% 'rct_gui_fast_hist' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- [num_el, bin_centers] = rct_cli_fast_hist (data, num_bins, title, parent)
%      Produce histogram counts for the given dataset.
%
%      Algorithm is mainly tested on the 2D data but it should be able to
%      1-dimensional, as well 3-dimensional data too. It is also designed to
%      handle any type of numerical data (e.g. integer, floating point).
%
%      The function also displays information on calculation progrees as GUI
%      progress bar.
%
%      See also: rct_cli_fast_hist, rct_gui_hist_plot.

function [num_el, bin_centers] = rct_gui_fast_hist( ...
        data, ...
        num_bins, ...
        title='RCT Fast Histogram', ...
        parent=0 ...
        )

    % Initialize return variables
    num_el = NaN;  % Store array od number of elements for each bin (data distribution)
    bin_centers = NaN;  % Store array containg values of bin centers

    % Do basic sanity checking first. Before anything else we need a matrix
    % to deal with
    if(not(ismatrix(data)))
        error("Invalid data type!. Parameter 'data' must be a matrix.");

        return;

    endif;

    % Matrix values must be of numerical type
    if(not(isnumeric(data)))
        error("Invalid data type!. Parameter 'data' must be a numerical matrix, not '%s'.", ...
            class(data) ...
            );

        return;

    endif;

    if(not(isnumeric(num_bins)))
        error("Invalid data type! Parameter 'num_bins' must be of numeric type, not '%s'.", ...
            class(num_bins) ...
            );

        return;

    endif;

    if(not(ischar(title)))
        error("Invalid data type! Parameter 'title' must be of type 'char', not '%s'.", ...
            class(title) ...
            );

        return;

    endif;

    if(not(ishandle(parent)))
        error("Invalid data type! Parameter 'parent' must be a handle to a GUI object, not '%s'.", ...
            class(title) ...
            );

        return;

    endif;

    % Check if we are dealing with matrix dimensions we can not support, or we
    % are dealing with an empty matrix
    dim = size(size(data))(2);

    if(3 < dim)
        % We do not support matrixes with more than three dimesions
        error(
            "Invalid data type! Parameter 'data' must be a matrix with up to three dimensions."
        );

        return;

    endif;

    if(1 > dim)
        % Probably an empty matrix
        error(
            "Invalid data type! Parameter 'data' has no items (empty matrix)."
        );

        return;

    endif;

    % All is fine, proceed with execution.
    min_val = 0;
    max_val = 0;
    depth = 0;

    if(isinteger(data))
        % If we are dealing with integer data we span bins range all over the
        % range of all possible integer values for the given integer class
        % (uint8, int8, uint16, int16, uint 32, int32, uint64, int64)
        int_class = class(data);
        min_val = intmin(int_class);
        max_val = intmax(int_class);

        % We are doing following portion of code because expression:
        %
        %   intmax(int_class) - intmin(int_class)
        %
        % yields values that are different from what we expect, for some reason
        switch(int_class)
            case {'uint8' 'int8'}
                depth = intmax('uint8');

            case {'uint16' 'int16'}
                depth = intmax('uint16');

            case {'uint32' 'int32'}
                depth = intmax('uint32');

            otherwise
                % We are dealing with 64-bits wide values (uint64, int64)
                depth = intmax('uint64');

        endswitch;

    else
        % We are dealing with floating point values. For floating point values
        % we want to span bins range across the range from the minimum value
        % existing in the dataset to the maximum value existing in the dataset
        if(3 == dim)
            min_val = min(min(min(data)));
            max_val = max(max(max(data)));

        elseif(2 == dim)
            min_val = min(min(data));
            max_val = max(max(data));

        else
            % We have one dimensional matrix (array)
            min_val = min(data);
            max_val = max(data);

        endif;

        depth = max_val - min_val;

        if(0 == depth)
            % We have special case where we are dealing with single value
            % dataset. In that case we are spanning bins range all over a
            % possible range of values for the given floating point class
            fp_class = class(data);
            min_val = (-1)*flintmax(fp_class);
            max_val = flintmax(fp_class);
            depth = max_val - min_val;

        endif;

    endif;

    bin_size = depth / num_bins;
    bin_centers = zeros(1, num_bins);
    num_el = zeros(1, num_bins);

    % Give feedback on calculation progress to 'stdout'
    progress_info = waitbar( ...
        0.0, ...
        'Calculating histogram ...', ...
        'parent', parent, ...
        'name', title ...
        );


    for i = 1:num_bins
        bin_centers(i) = min_val + bin_size*(i - 0.5);
        bin_bot = min_val + bin_size*(i - 1);
        bin_top = min_val + bin_size*i;

        if(1 == i)
            mask = data >= bin_bot;
        else
            mask = data > bin_bot;
        endif;
        in_bin = data.*mask;
        mask = data <= bin_top;
        in_bin = in_bin.*mask;

        num_el(i) = nnz(in_bin);

        waitbar(i/num_bins, progress_info);

    endfor;

    delete(progress_info);

endfunction;
