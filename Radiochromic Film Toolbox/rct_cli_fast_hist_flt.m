% 'rct_cli_fast_hist_flt' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- [num_el, bin_centers] = rct_cli_fast_hist_flt (data, num_bins)
%      Produce histogram counts for the given dataset of floating point values.
%
%      Algorithm is mainly tested on the 2D data but it should be able to handle
%      1-dimensional, as well as 3-dimensional data.
%
%      Calculation progress is displayed to 'stdout'.
%
%      See also: rct_cli_fast_hist_int, rct_gui_fast_hist, rct_gui_hist_plot.

function [num_el, bin_centers] = rct_cli_fast_hist_flt(data, num_bins)

    % Initialize return variables
    num_el = NaN;  % Store array of number of elements for each bin (data distribution)
    bin_centers = NaN;  % Store array containg values of bin centers

    % Do basic sanity checking first. Before anything else we need a matrix
    % to deal with
    if(not(ismatrix(data)))
        error("Invalid data type!. Parameter 'data' must be a matrix.");

        return;

    endif;

    % Matrix values must be of floating point type
    if(not(isfloat(data)))
        error("Invalid data type!. Parameter 'data' must be a floating point value, not '%s'.", ...
            class(data) ...
            );

        return;

    endif;

    if(not(isfloat(num_bins)))
        error("Invalid data type! Parameter 'num_bins' must be a floating point value, not '%s'.", ...
            class(num_bins) ...
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

    % For floating point values we want to span bins range across the range
    % from the minimum value existing in the dataset to the maximum value
    % existing in the dataset
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
        % We have special case when we are dealing with a single value
        % dataset. In that case we are spanning bins range all over a
        % possible range of values for the given floating point class
        fp_class = class(data);
        min_val = (-1)*flintmax(fp_class);
        max_val = flintmax(fp_class);
        depth = max_val - min_val;

    endif;

    bin_size = depth / num_bins;
    bin_centers = zeros(1, num_bins);
    num_el = zeros(1, num_bins);

    % Give feedback on calculation progress to 'stdout'
    printf("processing:   0%%");

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

        percent_complete = uint32(round((i / num_bins) * 100));
        printf("\b\b\b\b\b%4d%%", percent_complete);

    endfor;

    printf("\b\b\b\b\b Completed!\n");

endfunction;
