function Roi_2_Plot(varargin)
    %% -------------------------------------------------------------------------
    %%
    %% Function: Roi_2_Plot(hax, p0, q0, w, h, varargin)
    %%
    %% -------------------------------------------------------------------------
    %
    %% Use:
    %       - Roi_2_Plot(hax, p0, q0, w, h)
    %       - Roi_2_Plot(hax, p0, q0, w, h, 'color', 'r')
    %
    %% Description:
    %       This function plots the given ROI (Region of Interest) on the
    %       given axes with FoV plotted as the pixmap.
    %
    %% Function parameters:
    %       - hax: handle to the axes where the ROI will be plotted
    %       - p0, q0: origin of the ROI (in pixels)
    %       - w, h: dimensions (width and height) of the ROI (in pixels)
    %       - color: color of the ROI (default: 'g' - green). For more details
    %                on how to specify color parameter see the documentation of
    %                the 'plot' function.
    %
    %% Return:
    %       - none
    %
    %% Examples:
    %       >> hfig = figure();
    %       >> hax = axes('parent', hfig);
    %       >> Roi_2_Plot(hax, 10, 10, 50, 50)
    %       >> Roi_2_Plot(hax, 10, 10, 50, 50, 'color', 'g')
    %
    %% (C) Copyright 2023 Ljubomir Kurij
    %
    %% -------------------------------------------------------------------------
    fname = 'Roi_2_Plot';
    use_case_a = sprintf( ...
                         ' -- %s(hax, p0, q0, w, h)', ...
                         fname ...
                        );
    use_case_b = sprintf( ...
                         ' -- %s(hax, p0, q0, w, h, ''color'', ''r'')', ...
                         fname ...
                        );

    % Check input parameters ---------------------------------------------------

    % Check number of input parameters
    if 5 ~= nargin && 7 ~= nargin
        error( ...
              'Invalid call to %s. Correct usage is:\n%s\n%s', ...
              fname, ...
              use_case_a, ...
              use_case_b ...
             );

    end  % End of if 5 ~= nargin && 7 ~= nargin

    % Check type of input parameters
    if ~ishandle(varargin{1})
        error( ...
              cstrcat( ...
                      'Invalid call to %s. Parameter ''hax'' must ', ...
                      'be a valid handle.' ...
                     ), ...
              fname ...
             );

    end  % End of parameter type check for 'hax'

    i = 2;
    while 5 >= i
        pname = {'p0', 'q0', 'w', 'h'};
        validateattributes( ...
                           varargin{i}, ...
                           {'numeric'}, ...
                           { ...
                            'scalar', ...
                            'integer', ...
                            'nonnegative' ...
                           }, ...
                           fname, ...
                           pname{i - 1}, ...
                           i ...
                          );

        i += 1;

    end  % End of parameter type check for ROI parameters
    clear('i', 'pname');

    % Positional parameters checked. Parse user supplied parameters
    [ ...
        positional, ...
        color ...
        ] = parseparams( ...
                        varargin, ...
                        'color', 'g' ...
                       );

    % Store positional parameters in local variables
    [hax, p0, q0, w, h] = positional{:};
    clear('positional');

    % Check type of named parameters
    if ~ischar(color)
        error( ...
              'Invalid call to %s. Parameter ''color'' must be a string.', ...
              fname ...
             );

    end  % End of parameter type check for 'color'

    % Do the plotting ----------------------------------------------------------

    % Set plot origin. When pltting over an image, the origin of the plot is
    % the upper left corner of the image at position (0.5, 0.5)
    X0 = -0.5;
    Y0 = -0.5;

    % Freeze the axes. We want to plot on top of the existing content
    hold(hax, 'on');
    plot( ...
         hax, ...
         [X0 + p0, X0 + p0 + w, X0 + p0 + w, X0 + p0, X0 + p0], ...
         [Y0 + q0, Y0 + q0, Y0 + q0 + h, Y0 + q0 + h, Y0 + q0], ...
         'color', color, ...
         'linewidth', 1 ...
        );

    % Plot the center of the ROI. We plot it as a crosshair. The crosshair
    % will be centered on the center of the ROI. The crosshair will be
    % plotted with the same color as the ROI, and we want crosshair to be
    % the 10% of the shorter edge of the ROI, or at least 3 pixels long.
    shorter_edge = min(w, h);
    crosshair_size = max(3, floor(shorter_edge / 10));
    plot( ...
         hax, ...
         X0 + p0 + w / 2, ...
         Y0 + q0 + h / 2, ...
         'color', color, ...
         'linewidth', 1, ...
         'marker', '+' ...
        );

    % Unfreeze the axes
    hold(hax, 'off');

end  % End of function Roi_2_Plot

% End of file: Roi_2_Plot.m