% 'utl_bbox_intersect' is a function from the package: 'Utility Toolbox'
%
%  -- [x, y, w, h] = utl_bbxo_intersect (x1, y1, w1, h1, x2, y2, w2, h2)
%      Calculate intersection region of two axis-aligned bounding boxes
%      (rectangle areas).
%
%      It takes coordinates of two axis-alinged rectangles (x, y for upper left
%      origin and w, h for width and height) as integer values.
%
%      It returns [0, 0, 0, 0] if there is no intersection.

%      See also: 

function [X, Y, W, H] = utl_bbox_intersect(varargin)
    % Store function name into variable for easier management of error messages
    fname = 'utl_bbox_intersect';

    % Initialize return variables to default values
    X = Y = W = H = 0;

    % Check if right number of arguments is passed
    narginchk(8, 8);

    % Validate user input
    idx = 1;
    while(nargin >= idx)
        mustBeFinite(varargin{idx});
        mustBeInteger(varargin{idx});
        switch(idx)
            case {3, 4, 7, 8}
                mustBeNonnegative(varargin{idx});

        endswitch;

        idx = idx + 1;

    endwhile;

    % Test if boundig boxes overlap at all
    if( ...
            ~(varargin{5} > varargin{1} + varargin{3}) ...
            && ~(varargin{6} > varargin{2} + varargin{4}) ...
            && ~(varargin{1} > varargin{5} + varargin{7}) ...
            && ~(varargin{2} > varargin{6} + varargin{8}) ...
            )

        % The bounding boxes overlap. Calculate coordinates of overlap region
        X = max(varargin{1}, varargin{5});
        Y = max(varargin{2}, varargin{6});
        W = min(varargin{1} + varargin{3}, varargin{5} + varargin{7}) - X;
        H = min(varargin{2} + varargin{4}, varargin{6} + varargin{8}) - Y;

    endif;

endfunction;
