% 'rct_bin_index' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- index = rct_bin_index (val, min_val, max_val, num_bins)
%      Return bin index for given value, data range and data range segmentation
%      (number of data bins).
%
%      This function is not to be used on its own, but as a part of
%      'rct_fast_hist()' algorithm.

function index = rct_bin_index(val, min_val, max_val, num_bins)
    depth = max_val - min_val;
    bin_size = depth / (num_bins - 1);  % TODO: Find explanation for this
    index = 1;

    while(num_bins >= index)
        lbound = min_val + (index - 1.5)*bin_size;
        ubound = min_val + (index - 0.5)*bin_size;
        if((lbound < val) && (ubound >= val))
            return;

        endif;

        index = index + 1;

    endwhile;

    index = 0;  % The 'val' does not belong to the given data range so return 'false'.

endfunction;
