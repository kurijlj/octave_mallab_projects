% 'rct_num_bins_max' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- result = rct_num_bins_max ()
%  -- result = rct_num_bins_max ("TYPE")
%  -- result = rct_num_bins_max (VAR)
%      Return the largest possible, achievable count of histogram bins supported
%      by the toolbox algorithms.
%
%      Maximum supported data bit depth by the 'Radiochromic Film Toolbox' is
%      16 bits (i.e. 2^{16}), so maximum supported value range is from 0 to
%      65535 for unsigned integer data, from -32768 to 32767 for signed integer
%      data, and from -65536 to 65535 for floating point values ('single'
%      precision data are automatically converted to 'double' precision).
%
%      The input is either a string "TYPE" specifying an numerical type, or
%      it is an existing numerical variable VAR.
%
%      Possible values for TYPE, and coressponding maximum number of bins are:
%
%           "int8"
%                signed 8-bit integer, NUM_BINS_MAX = 256.
%
%           "int16"
%                signed 16-bit integer, NUM_BINS_MAX = 65536.
%
%           "int32"
%                signed 32-bit integer, NUM_BINS_MAX = 0 (NOT SUPPORTED).
%
%           "int64"
%                signed 64-bit integer, NUM_BINS_MAX = 0 (NOT SUPPORTED).
%
%           "uint8"
%                unsigned 8-bit integer, NUM_BINS_MAX = 256.
%
%           "uint16"
%                unsigned 16-bit integer, NUM_BINS_MAX = 65536.
%
%           "uint32"
%                unsigned 32-bit integer, NUM_BINS_MAX = 0 (NOT SUPPORTED).
%
%           "uint64"
%                unsigned 64-bit integer, NUM_BINS_MAX = 0 (NOT SUPPORTED).
%
%           "single"
%                single precision floating point, NUM_BINS_MAX = 131072.
%
%           "double"
%                double precision floating point, NUM_BINS_MAX = 131072.
%
%           The default for TYPE is "double".
%
%      See also: 

function result = rct_num_bins_max(VAR="double")

    % Initialize return variable
    result = 0;  % Set to 'NOT SUPPORTED' return value.
    var_type = class(VAR);  % Set to default value.

    % Do basic sanity checking first. Given value must be numerical.
    if(ischar(VAR))
        % Type string passed, reinitialize type string.
        var_type = strcat(VAR);

    endif;

    switch(var_type)
        case {"uint8" "int8"}
            result = uint32(intmax("uint8")) + 1;

        case {"uint16" "int16"}
            result = uint32(intmax("uint16")) + 1;

        case {"uint32" "int32"}
            return;

        case {"uint64" "int64"}
            return;

        case {"single" "double"}
            result = (double(intmax("uint16")) + 1)*2;
            return;

        otherwise
            if(ischar(VAR))
                error("Invalid data type!. Not defined for '%s' objects.", ...
                    VAR ...
                    );

            else
                error("Invalid data type!. Not defined for '%s' objects.", ...
                    typeinfo(VAR) ...
                    );

            endif;

            return;

    endswitch;

endfunction;
