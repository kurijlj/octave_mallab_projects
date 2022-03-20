%'rct_wl2thrs' is a function from the package: 'Radiochromic Film Toolbox'
%
% --                THR = rct_wl2thrs (W, L)
% -- {THR1, THR2, ... } = rct_wl2thrs (W1, L1, W2, L2, ... )
%     Calucalte threshold values for given window-level.
%
%     For given set of window and level values calculate threshold (cut-off)
%     values.
%
%     See also:

function THR = rct_wl2thrs(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'rct_wl2thrs';

    % Initialize return variables to default values
    THR = {};

    % Check if any argument is passed
    if(0 == nargin)
        % No arguments passed
        error('Invalid call to %s: NO ARGUMENTS. See help for correct usage.', fname);

        return;

    endif;

    % For rct_wl2thrs to work there must be an even number of arguments
    if(-1 == (-1)^nargin)
        % Odd number of arguments
        error('Invalid call to %s: ODD NUMBER OF ARGUMENTS. See help for correct usage.', fname);

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

    idx = 1;
    a = [0 0];
    while(nargin/2 >= idx)
        % Validate input values
        if(~isfloat(pos{idx}) || ~isscalar(pos{idx}))
            error( ...
                '%s: varargin{%d} must be a floating point value', ...
                fname, ...
                idx ...
                );

        endif;

        if(~isfloat(pos{idx + 1}) || ~isscalar(pos{idx + 1}))
            error( ...
                '%s: varargin{%d} must be a floating point value', ...
                fname, ...
                idx + 1 ...
                );

        endif;

        % Calculate threshold window
        a(1) = pos{idx} - pos{idx + 1}/2;
        a(2) = pos{idx} + pos{idx + 1}/2;
        THR = {THR{:} a};

        idx = idx + 1;

    endwhile;

endfunction;
