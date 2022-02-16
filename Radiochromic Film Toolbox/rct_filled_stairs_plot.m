% 'rct_filled_stairs_plot' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- rct_filled_stairs_plot (Y)
%  -- rct_filled_stairs_plot (X, Y)
%  -- rct_filled_stairs_plot (HAX, ...)
%  -- H = rct_filled_stairs_plot (...)
%

function H = rct_filled_stairs_plot(varargin)

    % Initialize return value to default value NaN
    H = HAX = NaN;

    % Iitialize data arrays to default values
    X = [];
    Y = [];

    % Parse and store imput arguments
    [pstnl, props] = parseparams (varargin);

    % Check if eny of positional arguments is passed
    if(isempty(pstnl))
        % No positional arguments passed
        error('Invalid call to rct_filled_stairs_plot. See help for correct usage.');

        return;

    endif;

    % Get number of passed positional arguments
    npstnl = length(pstnl);

    % Function takes up to three positional arguments (i.e. HAX, X, Y). Check if
    % we are deling with correct number of positional arguments
    if(3 < npstnl)
        % Too many positional arguments. Invalid call to function
        error('Invalid call to rct_filled_stairs_plot. See help for correct usage.');

        return;

    elseif(3 == npstnl)
        % Three positional arguments passed. Supposedly we have handle to
        % drawing axes, vector of abscissa values and vector of ordinate values
        HAX = pstnl{1};
        X = pstnl{2};
        Y = pstnl{3};

    elseif(2 == npstnl)
        % Two positional arguments passed. Two cases are possible. Supposedly we
        % have handle to drawing axes, and vector of ordinate values. Or,we have
        % vector of abscissa values and vector of ordinate values
        if(isaxes(pstnl{1}))
            % We have the first case
            HAX = pstnl{1};
            X = pstnl{2};

        else
            % We have the second case
            X = pstnl{1};
            Y = pstnl{2};

        endif;

    else
        % Only one positional argument passed so we guess it is a vector of
        % ordinate values
        X = pstnl{1};

    endif;

    % Check if HAX actually stores an handle to drawing axes
    if(not(isnan(HAX) || isaxes(HAX)))
        % Passed value is not handle to drawing axes
        error('Invalid call to rct_filled_stairs_plot. See help for correct usage.');

        return;

    endif;

    % Check if first data vector is a one dimensional numerical matrix
    if(not(is_1d_num_matrix(X)))
        error('Invalid call to rct_filled_stairs_plot. See help for correct usage.');

        return;

    endif;

    % Check if second data vector is not NaN and is a matrix, because we allow
    % for second vector to be empty vector
    if(isnan(Y) || not(ismatrix(Y)))
        error('Invalid call to rct_filled_stairs_plot. See help for correct usage.');

        return;

    endif;

    % Check if second vector is empty vector. If empty, user supplied only
    % ordinate values so generate abscissa values from inedx values of ordinate
    % values
    if(not(isempty(Y)))
        % Second vector is not empty so do a full check if we have a one
        % dimensional numerical matrix
        if(not(is_1d_num_matrix(X)) || length(X) ~= length(Y))
            error('Invalid call to rct_filled_stairs_plot. See help for correct usage.');

            return;

        endif;

    else
        % Do reordering and generate abscissa values
        Y = X;
        X = [1:length(Y)];

    endif;

    % If passed, pop plot limits properties and values
    [props, xlim] = pop_param('xlim', [min(X) max(X)], props);
    [props, ylim] = pop_param('ylim', [min(Y) max(Y)], props);
    [props, name] = pop_param('name', 'RCT Step Plot', props);
    [props, units] = pop_param('units', 'points', props);

    % Check if face color is supplied with arguments
    if(not(prop_in_args('facecolor', props)))
        % Face color is not supplied. Add default face color
        props = {props{:}, 'facecolor', [0 0.4470 0.7410]};

    endif;

    % Check if edge color is supplied with arguments
    if(not(prop_in_args('edgecolor', props)))
        % Edge color is not supplied. Add default edge color
        props = {props{:}, 'edgecolor', [0 0.4470 0.7410]};

    endif;

    % Initialize drawing axes if not sup[plied
    if(isnan(HAX))
        % Drawing axes not supplied. Spawn new figure and initialize axes
        main_figure = figure('name', name, 'units', units);
        H = axes('parent', main_figure, 'units', units);

    else
        % Return handle to axes passed as argument
        H = HAX;

    endif;

    % Plot graph. First we need to calculate fill parameters for region below
    % graph curve
    % NOTE: The original algorithm for calculating fill area is:
    %
    %       x = [dataset{1}(1), repelem(dataset{1}(2:end), 2)];
    %       y = [repelem(dataset{2}(1:end - 1), 2), dataset{2}(end)];
    %
    % however, this algorithm does not plot last interval in the dataset (i.e.
    % last data point). So we are using algortihm that linearly extrapolates
    % dataset for one point to be able to plot the complete dataset. This is
    % definitely the point for future improvements
    addX = interp1([1:length(X)], X, 0, 'extrap', 'linear');
    endX = interp1([1:length(X)], X, length(X) + 1, 'extrap', 'linear');
    addY = interp1(X, Y, endX, 'extrap', 'linear');
    % X = [X, interp1([1:length(X)], X, length(X) + 1, 'extrap', 'linear')];
    % Y = [Y, interp1(X(1:end - 1), Y, X(end), 'extrap', 'linear')];
    % x = [addX, repelem(X(2:end), 2)];
    % y = [repelem(Y(1:end - 1), 2), Y(end)];
    x = [addX, repelem(X, 2)];
    y = [repelem(Y, 2), addY];
    bottom = ones(size(y)).*xlim(1);

    % Paint region
    patch( ...
        'parent', H, ...
        [x, fliplr(x)], ...
        [y, bottom], ...
        props{:} ...
        );

    % Set plot limits
    set(H, 'xlim', xlim);
    set(H, 'ylim', ylim);

endfunction;


function result = prop_in_args(pname, args)
    result = false;
    index = 1;

    while(length(args) >= index)
        if(ischar(args{index}))
            if(length(args{index}) == length(pname))
                if(args{index} == pname)
                    result = true;

                    return;

                endif;

            endif;

        endif;

        index = index + 1;

    endwhile;

endfunction;


function result = is_1d_num_matrix(A)
    result = false;

    if(ismatrix(A))
        if(not(isnan(A)) && not(isnull(A)) && not(isempty(A)))
            if( ...
                    2 == length(size(A)) ...
                    && 1 == min(size(A)) ...
                    )
                if(isnumeric(A))
                    result = true;

                endif;

            endif;

        endif;

    endif;

endfunction;


function [rlist, pval] = pop_param(pname, def_val, params)
    rlist = NaN;
    pval = def_val;

    if(not(ischar(pname)) || isnull(pname))
        error('Invalid call to pop_param. See help for correct usage.');

        return;

    endif;

    if(not(iscell(params)))
        error('Invalid call to pop_param. See help for correct usage.');

        return;

    endif;

    if(not(isempty(params)))
        plen = length(params);
        index = 1;

        mask = repelem(true, plen);

        while(plen >= index)
            if(ischar(params{index}))
                if( ...
                        length(pname) == length(params{index}) ...
                        && pname == params{index} ...
                        )
                    mask(index) = false;
                    if(plen > index)
                        mask(index + 1) = false;
                        pval = params{index + 1};

                        index = index + 1;

                    endif;

                endif;

            endif;

            index = index + 1;

        endwhile;

        rlist = params(mask);

    else
        rlist = {};

    endif;

endfunction;
