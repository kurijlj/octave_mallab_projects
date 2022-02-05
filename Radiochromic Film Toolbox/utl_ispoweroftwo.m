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
        error("Invalid data type!. Not defined for '%s' objects.", ...
            class(data) ...
            );

        return;

    endif;

    if(isinteger(X))
        n = uint64(0);
        Y = uint64(pow2(n));

        while(Y <= uint64(X))
            if(Y == uint64(X))
                % X is power of two! Break execution and return 'true'.
                result = 1;
                return;

            endif;

            n = n + 1;
            Y = uint64(pow2(n));

        endwhile;

    else
        % We are dealing with a floating point value
        n = double(0);
        Y = double(pow2(n));

        while(Y <= double(X))
            if(Y == double(X))
                % X is power of two! Break execution and return 'true'.
                result = 1;
                return;

            endif;

            n = n + 1;
            Y = double(pow2(n));

        endwhile;

    endif;

endfunction;
