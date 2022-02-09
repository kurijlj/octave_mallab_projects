% 'rct_filled_stairs_plot' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- rct_filled_stairs_plot (X, Y)
%  -- rct_filled_stairs_plot (X, Y, CLR)
%  -- rct_filled_stairs_plot (HAX, ...)
%  -- H = rct_filled_stairs_plot (...)
%

function H = rct_filled_stairs_plot(HAX=NaN, X=NaN, Y=NaN, CLR=NaN)

    % Initialize return value to error
    H = NaN;

    if(isnan(HAX))
        if(isnan(X))
            error('Error! X');

            return;

        endif;

    else
        if(ishandle(HAX))
            if(isnan(X))
                error('Error! X');

                return;

            endif;

            H = HAX;

        else
            error('Error! HAX');

            return;

        endif;

    endif;


    if(isnan(Y))
        Y = X;
        X = 1:length(X);

    endif;

    if(isnan(CLR))
        CLR = [0 0.4470 0.7410];  % Nice pastel blue color

    endif;

    name = 'RCT Step Plot';
    units = 'points';
    if(isnan(HAX))
        main_figure = figure('name', name, 'units', units);
        HAX = H = axes('parent', main_figure, 'units', units);

    endif;

    % Calulate fill parameters for region below curve
    bottom = min(X);
    x = [X(1), repelem(X(2:end), 2)];
    y = [repelem(Y(1:end - 1), 2), Y(end)];

    % PAint region
    fill_H = fill('parent', H, [x, fliplr(x)], [y, bottom*ones(size(y))], CLR);
    set(fill_H, 'color', CLR);
    % hold on;
    % stairs('parent', HAX, X, Y, 'color', CLR);
    % hold off;

endfunction;
