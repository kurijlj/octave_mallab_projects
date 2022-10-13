% -----------------------------------------------------------------------------
%
% Function 'multiresshow':
%
% Use:
%       -- multiresshow(M)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function multiresshow(M)
    fname = 'multiresshow';
    use_case_a = ' -- multiresshow(M)';

    S = zeros(size(M, 1), size(M, 2));
    idx = 1;
    while(size(M, 3) >= idx)
        S = S + power(2, idx).*M(:, :, idx);

        ++idx;

    endwhile;

    matshow(S);

endfunction;
