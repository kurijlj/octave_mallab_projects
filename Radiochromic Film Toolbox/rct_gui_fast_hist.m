% 'rct_gui_fast_hist' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- [num_el, bin_centers] = rct_gui_fast_hist (data, num_bins, title, parent)
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
        error("Invalid data type! Parameter 'num_bins' must be of type, not '%s'.", ...
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

    % All is fine, proceed with execution.
    dim = size(size(data))(2);

    min_val = 0;
    max_val = 0;

    if(3 < dim)
        % We do not support matrixes with more than three dimesions.
        error(
            "Invalid data type! Parameter 'data' must be a matrix with up to three dimensions."
        );

        return;

    elseif(1 > dim)
        % Probably an empty matrix.
        error(
            "Invalid data type! Parameter 'data' has no items (empty matrix)."
        );

        return;

    elseif(3 == dim)
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

    bin_size = depth / num_bins;
    bin_centers = zeros(1, num_bins);
    num_el = zeros(1, num_bins);

    % Initialize graphical toolkit
    graphics_toolkit qt;

    % Give feedback on calculation progress
    h_pbar = waitbar( ...
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

        waitbar(i/num_bins, h_pbar);

    endfor;

    delete(h_pbar);

endfunction;
