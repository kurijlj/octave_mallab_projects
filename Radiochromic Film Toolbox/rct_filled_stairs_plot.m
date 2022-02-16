% 'rct_filled_stairs_plot' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- rct_filled_stairs_plot (Y)
%  -- rct_filled_stairs_plot (X, Y)
%  -- rct_filled_stairs_plot (HAX, ...)
%  -- H = rct_filled_stairs_plot (...)
%

function H = rct_filled_stairs_plot_WIP(varargin)

    % Initialize return value to default value NaN
    H = HAX = NaN;

    % Initialize plot paramters to default values
    dataset = {NaN, NaN};
    fill_color = [0 0.4470 0.7410];  % Nice pastel blue color for graph fill

    % Initialize input validation counters and flags, and validate
    % input arguments
    index = 1;
    index_offset = 0;
    top_index = 2;

    if(0 == nargin)
        % No parameters supplied. Show error message and stop execution
        error('Invalid call to rct_filled_stairs_plot. See help for correct usage.');

        return;

    endif;

    if(isnan(varargin{1}) || ishandle(varargin{1}))
        % User supplied a handle for axes to plot to

        if(1 == nargin || (ishandle(varargin{1}) && not(isaxes(varargin{1}))))
            % Only handle is supplied, so we treat is as invalid call
            % to function
            error('Invalid call to rct_filled_stairs_plot. See help for correct usage.');

            return;

        endif;

        HAX = varargin{1};
        index = 2;
        index_offset = 1;
        top_index = 3;

    endif;

    while(nargin >= index)
        if(top_index < index)
            break;

        elseif(ismatrix(varargin{index}) && isnumeric(varargin{index}))
            dataset{index - index_offset} = varargin{index};

        endif;

        index = index + 1;

    endwhile;

    if(isnan(dataset{1}))
        % First data argument is not supplied, so we take it as invalid call to
        % function
        error('Invalid call to rct_filled_stairs_plot. See help for correct usage.');

        return;

    elseif(isnan(dataset{2}))
        % Only first data argument is supplied
        dataset{2} = dataset{1};
        dataset{1} = [1:length(dataset{2})];

    % Both data arguments provided
    endif;

    % Check data dimensions
    if(2 < length(size(dataset{1})) ...
            || 1 < min(size(dataset{1})) ...
            || 2 < length(size(dataset{2})) ...
            || 1 < min(size(dataset{2})) ...
            )
        error('Inavlid data type. Not defined for multidimensional matrices.');

        return;

    endif;

    patch_argsin = NaN;
    if(nargin > (top_index + 1))
        patch_argsin = {varargin{(top_index + 1):end}};

        % Check if face color is supplied with arguments
        if(not(str_in_args('facecolor', patch_argsin)))
            % Face color is not supplied. Add default face color
            patch_argsin = cell(1, length(patch_argsin) + 2);
            patch_argsin(1:end-2) = {varargin{(top_index + 1):end}};
            patch_argsin(end-1) = 'facecolor';
            patch_argsin(end) = [0 0.4470 0.7410];

        endif;

        % Check if edge color is supplied with arguments
        if(not(str_in_args('edgecolor', patch_argsin)))
            % Edge color is not supplied. Add default edge color
            patch_argsin = cell(1, length(patch_argsin) + 2);
            patch_argsin(1:end-2) = {varargin{(top_index + 1):end}};
            patch_argsin(end-1) = 'edgecolor';
            patch_argsin(end) = [0 0.4470 0.7410];

        endif;

    else
        patch_argsin = { ...
            'facecolor', [0 0.4470 0.7410], ...
            'edgecolor', [0 0.4470 0.7410] ...
            };

    endif;

    name = 'RCT Step Plot';
    units = 'points';
    if(isnan(HAX))
        main_figure = figure('name', name, 'units', units);
        H = axes('parent', main_figure, 'units', units);

    else
        H = HAX;

    endif;

    % Calulate fill parameters for region below curve
    % bottom = min(dataset{2});
    % x = [dataset{1}(1), repelem(dataset{1}(2:end), 2)];
    % y = [repelem(dataset{2}(1:end - 1), 2), dataset{2}(end)];
    x = [(2*dataset{1}(1) - dataset{1}(2)), repelem(dataset{1}(1:end), 2)];
    y = [repelem(dataset{2}(1:end), 2), dataset{2}(end)];

    % Paint region
    % patch( ...
    %     'parent', H, ...
    %     [x, fliplr(x)], ...
    %     [y, bottom*ones(size(y))], ...
    %     patch_argsin{:} ...
    %     );
    patch( ...
        'parent', H, ...
        [x, fliplr(x)], ...
        [y, zeros(size(y))], ...
        patch_argsin{:} ...
        );

endfunction;


function result = str_in_args(str, args)
    result = false;
    index = 1;

    while(length(args) >= index)
        if(ischar(args{index}))
            if(length(args{index}) == length(str))
                if(args{index} == str)
                    result = true;

                    return;

                endif;

            endif;

        endif;

        index = index + 1;

    endwhile;

endfunction;
