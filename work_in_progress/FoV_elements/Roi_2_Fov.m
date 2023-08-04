function [p0, q0, w, h] = Roi_2_Fov(x0, y0, W, H, p0, q0, w, h)
    %% -------------------------------------------------------------------------
    %%
    %% Function: Roi_2_Fov(x0, y0, W, H, p0, q0, w, h):
    %%
    %% -------------------------------------------------------------------------
    %
    %% Use:
    %       - [p0, q0, w, h] = Roi_2_Fov(x0, y0, W, H, p0, q0, w, h)
    %
    %% Description:
    %       This function recalculates the coordinates and dimensions of the
    %       given ROI (Region of Interest) so that given ROI fits inside the
    %       given FoV (Field of View).
    %
    %% Function parameters:
    %       - x0, y0: origin of the FoV (in pixels)
    %       - W, H: dimensions (width and height) of the FoV (in pixels)
    %       - p0, q0: origin of the ROI (in pixels)
    %       - w, h: dimensions (width and height) of the ROI (in pixels)
    %
    %% Return:
    %       - p0, q0: new origin (if applicable) of the ROI (in pixels)
    %       - w, h: new dimensions (if applicable) of the ROI (in pixels)
    %
    %% Examples:
    %       - [10, 10, 50, 50] = Roi_2_Fov(0, 0, 100, 100, 10, 10, 50, 50)
    %       - [0, 0, 100, 100] = Roi_2_Fov(0, 0, 100, 100, 0, 0, 100, 100)
    %       - [0, 0, 100, 100] = Roi_2_Fov(0, 0, 100, 100, 0, 0, 200, 200)
    %       - [0, 0, 100, 100] = Roi_2_Fov(0, 0, 100, 100, -100, -100, 200, 100)
    %
    %% (C) Copyright 2023 Ljubomir Kurij
    %
    %% -------------------------------------------------------------------------
    fname = "Roi_2_Fov";
    use_case_a = sprintf( ...
        " -- [p0, q0, w, h] = %s(x0, y0, W, H, q0, p0, w, h)", ...
        fname ...
        );

    % Check input parameters ---------------------------------------------------

    % Check number of input parameters
    if nargin ~= 8
        error( ...
            "Invalid call to %s. Correct usage is:\n%s", ...
            fname, ...
            use_case_a ...
            );

    endif;  % End of if nargin ~= 8

    % Check input parameters' types
    i = 1;
    while (nargin >= i)
        pname = {"x0", "y0", "W", "H", "p0", "q0", "w", "h"};
        validateattributes( ...
            x0, ...
            {"numeric"}, ...
            { ...
                "scalar", ...
                "integer", ...
                "nonnegative" ...
            }, ...
            fname, ...
            pname{i}, ...
            i ...
        );

        i += 1;

    endwhile;  % End of parameter type check

    % Do the computation -------------------------------------------------------

    % Resize ROI if it extents beyond the FoV
    if (w > W)
        w = W;

    endif;  % End of if (w > W)

    if (h > H)
        h = H;

    endif;  % End of if (h > H)

    % Move ROI if it is outside the FoV
    if (0 > p0 - x0)
        p0 = x0;

    endif;  % End of if (0 > p0 - x0)

    if (0 > q0 - y0)
        q0 = y0;

    endif;  % End of if (0 > q0 - y0)

    if (0 > x0 + W - p0 - w)
        p0 = W - w + x0;

    endif;  % End of if (0 > x0 + W - p0 - w)

    if (0 > y0 + H - q0 - h)
        q0 = H - h + y0;

    endif;  % End of if (0 > y0 + H - q0 - h)

endfunction;  % End of Roi_2_Fov

% End of file Roi_2_Fov.m