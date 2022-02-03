% 'utl_ispoweroftwo' is a function from the package: 'Utility Toolbox'
%
%  -- result = utl_ispoweroftwo (X)
%      Return 'true' (1) if X is power of two, i.e. X=2^{n} where n is some
%      integer number, otherwise return 'false' (0).
%
%      See also: 

function result = utl_ispoweroftwo(X)

    % Initialize return variable
    result = 0;  % Set to 'false'

    % Do basic sanity checking first. Given value must be numerical.
    if(not(isnumeric(X)))
        error("Invalid data type!. Parameter 'X' must be a numerical value, not '%s'.", ...
            class(data) ...
            );

        return;

    endif;

    if(isinteger(X))
        for n = uint64(1:intmax('uint64'))
            Y = uint64(pow2(n));

            if(Y == uint64(X))
                % X is power of two! Break execution and return 'true'.
                result = 1;
                return;

            endif;

            if(Y > uint64(X))
                % We exhausted all powers of two that are smaller than X,
                % so X can't be represented as 2^{n}. Break execution and
                % return 'false'.
                return;

            endif;

        endfor;

    else
        % We are dealing with a floating point value
        for n = double(1:flintmax())
            Y = double(pow2(n));

            if(Y == double(X))
                % X is power of two! Break execution and return 'true'.
                result = 1;
                return;

            endif;

            if(Y > double(X))
                % We exhausted all powers of two that are smaller than X,
                % so X can't be represented as 2^{n}. Break execution and
                % return 'false'.
                return;

            endif;

        endfor;

    endif;

endfunction;
