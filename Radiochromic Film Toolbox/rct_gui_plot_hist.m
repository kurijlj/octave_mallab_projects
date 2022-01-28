% 'rct_gui_plot_hist' is a GUI tool from the package: 'Radiochromic Film Toolbox'
%
%  -- rct_gui_plot_hist (data, title="Unknown", num_bins=1000)
%      Plot histogram for the given dataset.
%
%      Interface uses rct_gui_fast_hist() to calculate data distribution.
%
%      See also: rct_cli_fast_hist, rct_gui_fast_hist.

function rct_gui_plot_hist(data, data_title="Unknown", num_bins=1000)

    % Do basic sanity checking first
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

    if(not(ischar(data_title)))
        error("Invalid data type! Parameter 'data_title' must be of type 'char', not '%s'.", ...
            class(data_title) ...
            );

        return;

    endif;

    if(not(isnumeric(num_bins)))
        error("Invalid data type! Parameter 'num_bins' must be of numeric type, not '%s'.", ...
            class(num_bins) ...
            );

        return;

    endif;

    % All is fine, proceed with execution. Calculate and normalize
    % data histogram
    [data_hist, data_hist_bins] ...
        = rct_gui_fast_hist(data, num_bins, 'RCT Histogram Plot');
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
    bar( ...
        'parent', hist_view, ...
        % [1:num_bins] * ((x_max - x_min)/num_bins), ...
        % [1:num_bins], ...
        data_hist_bins, ...
        data_hist ...
        );
    set(hist_view, 'xlim', [x_min x_max]);
    set(hist_view, 'xlabel', 'Bins centers');
    set(hist_view, 'ylim', [0 1]);
    set(hist_view, 'ylabel', 'Distribution');
    set(hist_view, 'title', sprintf("Histogram for: %s", data_title));

endfunction;
