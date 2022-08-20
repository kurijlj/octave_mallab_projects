%'rct_mask_cntr' is a function from the package: 'Radiochromic Film Toolbox'
%
% --              C = rct_mask_cntr (M)
% -- {C1, C2, ... } = rct_mask_cntr (M1, M2, M3, ... )
%     Calculate centroid position of binary image.
%
%     For given binary image(s) calculate centroid of non-zero values.
%
%     See also:

function C = rct_mask_cntr(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'rct_mask_cntr';

    % Initialize return variables to default values
    C = {};

    % Check if any argument is passed
    if(0 == nargin)
        % No arguments passed
        error('Invalid call to %s: NO ARGUMENTS. See help for correct usage.', fname);

        return;

    endif;

    % Parse and store imput arguments
    [pos, prop] = parseparams(varargin);

    % We do not support properties so far
    if(~isempty(prop))
        % No file path supplied
        error('Invalid call to %s: PROPERTIES NOT SUPPORTED. See help for correct usage.', fname);

        return;

    endif;

    % We donn't need pos and prop anymore
    clear pos prop;

    % Calculate centroid(s) position
    idx = 1;
    while(nargin >= idx)
        % Check if input is a binary image
        if( ...
                ~ismatrix(varargin{idx}) ...
                || ~isnumeric(varargin{idx}) ...
                || ~(2 == length(size(varargin{idx}))) ...
                || ~all((varargin{idx}(:) == 0) .+ (varargin{idx}(:) == 1)) 
                )
            % We don't have an binary image
            error( ...
                '%s: varargin{%d} must be a binary image matrix', ...
                fname, ...
                idx ...
                );

        endif;

        R = [1 1];
        M = 0;
        x = 1; y = 1;
        w = size(varargin{idx})(2);
        h = size(varargin{idx})(1);
        while(w >= x)
            while(h >= y)
                if(1 == varargin{idx}(y, x))
                    R(1) = R(1) + y;
                    R(2) = R(2) + x;
                    M = M + 1;

                endif;

                y = y + 1;

            endwhile;

            y = 1;
            x = x + 1;

        endwhile;

        display(R);
        display(M);
        R = round(R / M);
        C = {C{:} R};

        idx = idx + 1;

    endwhile;

endfunction;
