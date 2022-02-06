% 'rct_fast_hist'_2D is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- [dist, bin_centers] = rct_cli_fast_hist (data, num_bins)
%      Produce histogram counts for the given 2D dataset.
%
%      See also: rct_gui_fast_hist, rct_gui_hist_plot.

function [dist, bin_centers] = rct_fast_hist_2D(data, num_bins, feedback=0)

    % Initialize return variables
    num_el = NaN;  % Store array od number of elements for each bin (data distribution).
    bin_centers = NaN;  % Store array containg values of bin centers.

    % Do basic sanity checking first. Before anything else we need a matrix
    % to deal with.
    if(not(ismatrix(data)))
        error("Invalid data type!. Not defined for non-matrix objects.");

        return;

    endif;

    % Check if we are dealing with 2D matrix.
    dim = size(size(data))(2);
    if(2 ~= dim)
        error("Invalid data type!. Not defined for non-2D matrices.");

        return;

    endif;

    % Matrix values must be of numerical type ...
    if(not(isnumeric(data)))
        error("Invalid data type!. Not defined for non-numerical matrices.");

        return;

    endif;

    % so must number of bins.
    if(not(isnumeric(num_bins)))
        error("Invalid data type! Not defined for non-numerical number of bins.");

        return;

    endif;

    % All is fine, proceed with execution.
    min_val = 0;
    max_val = 0;
    depth = 0;

    if(isinteger(data))
        % If we are dealing with integer data we span bins range all over the
        % range of all possible integer values for the supported integer classes
        % (int8, uint8, int16, uint16)
        int_class = class(data);
        min_val = double(intmin(int_class));
        max_val = double(intmax(int_class));

        % We are doing following portion of code because expression:
        %
        %   intmax(int_class) - intmin(int_class)
        %
        % yields values that are different from what we expect, for some reason
        switch(int_class)
            case {'int8' 'uint8'}
                depth = double(intmax('uint8'));

            case {'int16' 'uint16'}
                depth = double(intmax('uint16'));

            otherwise
                % We are dealing with unsupported bit depths (i.e. int32,
                % uint32, int64, uint64). Report error and stop execution.
                error("Invalid data type! Not defined for more than 16 bits per sample.");

                return;

        endswitch;

    else
        % We are dealing with floating point values. For floating point values
        % we want to span bins range across the range from the minimum value
        % existing in the dataset to the maximum value existing in the dataset
        min_val = min(min(data));
        max_val = max(max(data));
        depth = max_val - min_val;

        if(0 == depth)
            % We have special case where we are dealing with single value
            % dataset. In that case we are spanning bins range all over a
            % possible range of values for the given floating point class
            min_val = double(intmin('int16'));
            max_val = double(intmax('int16'));
            depth = max_val - min_val;

        endif;

    endif;

    % if(is_function_handle(feedback))
    %     feval(feedback, 0);

    % endif;

    % Calculate bin centers
    bin_size = depth / (num_bins - 1);
    bin_centers = zeros(1, num_bins);
    index = 1;
    while(num_bins >= index)
        bin_centers(index) = min_val + (index - 1)*bin_size;
        index = index + 1;

    endwhile;

    % Calculate distribution
    dist= zeros(1, num_bins);
    binned_data = arrayfun( ...
        @(x) rct_bin_index(x, min_val, max_val, num_bins), ...
        data ...
        );

    index = 1;
    while(num_bins >= index)
        dist(index) = sum(sum(binned_data == index));
        index = index + 1;

    endwhile;

    % [height, width] = size(data);
    % x = 1;
    % y = 1;

    % while(height >= y)
    %     while(width >= x)
    %         index = rct_bin_index(data(y, x), min_val, max_val, num_bins);
    %         dist(index) = dist(index) + 1;
    %         x = x + 1;

    %     endwhile;

    %     if(is_function_handle(feedback))
    %         if(y > height && x <= width)
    %             feval(feedback, (height*x)/(height*width));

    %         elseif(y <= height && x > width)
    %             feval(feedback, (y*width)/(height*width));

    %         elseif(y > height && x > width)
    %             feval(feedback, 1);

    %         else
    %             feval(feedback, (y*x)/(height*width));

    %         endif;

    %     endif;

    %     y = y + 1;
    %     x = 1;  % Reset counter

    % endwhile;

endfunction;
