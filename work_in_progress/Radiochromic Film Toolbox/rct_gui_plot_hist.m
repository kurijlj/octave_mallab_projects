% 'rct_gui_plot_hist' is a GUI tool from the package: 'Radiochromic Film Toolbox'
%
%  -- rct_gui_plot_hist (data, title, num_bins)
%      Plot histogram for the given dataset.
%
%      It utilitizes rct_fast_hist_2D() function to calculate data distribution.
%
%      See also: rct_fast_hist_2D.

function rct_gui_plot_hist(data, data_title='Unknown', num_bins=1024)

    % Do basic sanity checking first
    if(not(ismatrix(data)))
        error('Invalid data type!. Not defined for non-matrix objects.');

        return;

    endif;

    % Check if we are dealing with 2D matrix.
    dim = size(size(data))(2);
    if(2 ~= dim)
        error('Invalid data type!. Not defined for matrices with more than 2 dimensions.');

        return;

    endif;

    % Matrix values must be of numerical type ...
    if(not(isnumeric(data)))
        error('Invalid data type!. Not defined for non-numerical matrices.');

        return;

    endif;

    % so must number of bins.
    if(not(isnumeric(num_bins)))
        error('Invalid data type! Number of bins must be a numerical value.');

        return;

    endif;

    % Data title must be a character string.
    if(not(ischar(data_title)))
        error('Invalid data type! Data title must be a character string.');

        return;

    endif;

    % If integer data check if we are dealing with supported bit depths (i.e.
    % int8, uint8, int16, uint16.
    if(isinteger(data))
        int_class = class(data);
        switch(int_class)
            case {'int32' 'uint32' 'int64' 'uint64'}
                % We are dealing with unsupported bit depths.
                error('Invalid data type! Not defined for more than 16 bits per sample.');

                return;

        endswitch;

    endif;

    % All is fine, proceed with execution. Calculate and normalize
    % data histogram
    [data_hist, data_hist_bins] ...
        = rct_fast_hist_2D(data, num_bins, 'GUI');
    data_hist = data_hist / max(data_hist);
    x_min = min(data_hist_bins);
    x_max = max(data_hist_bins);

    % Load graphics toolkit
    graphics_toolkit qt;

    % Construct GUI elements
    main_figure = figure( ...
        'name', 'RCT - Histogram Plot' ...
        );
    hist_view = axes( ...
        'parent', main_figure, ...
        'box', 'on', ...
        'position', [ ...
            0.1 ...
            0.1 ...
            0.8 ...
            0.8 ...
            ] ...
        );
    % bar( ...
    %     'parent', hist_view, ...
    %     % [1:num_bins] * ((x_max - x_min)/num_bins), ...
    %     % [1:num_bins], ...
    %     data_hist_bins, ...
    %     data_hist ...
    %     );
    rct_hist_plot( ...
        hist_view,
        data_hist_bins, ...
        data_hist, ...
        'title', data_title ...
        );
    % set(hist_view, 'xlim', [x_min x_max]);
    % set(hist_view, 'xlabel', 'Bin centers');
    % set(hist_view, 'ylim', [0 1]);
    % set(hist_view, 'ylabel', 'Distribution');
    % set(hist_view, 'title', sprintf("Histogram for: %s", data_title));

endfunction;
