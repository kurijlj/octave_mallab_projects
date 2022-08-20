% 'utl_is_odd' is a function from the package: 'Utility Toolbox'
%
%  -- TF = utl_is_even (N)
%      Return true if N is an odd number and false otherwise.
%
%      If N is a matrix of numbers, TF is a logical matrix of the same size.
%
%      See also: utl_is_even, utl_is_power_of_two

function TF = utl_is_odd(N)
    TF = zeros(size(N));
    TF = (-1).^N;
    TF = TF == -1;

endfunction;
