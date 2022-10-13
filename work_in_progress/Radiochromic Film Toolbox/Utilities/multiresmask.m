% -----------------------------------------------------------------------------
%
% Function 'multiresmask':
%
% Use:
%       -- multiresmask(M)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function S = multiresmask(M)
    fname = 'multiresmask';
    use_case_a = ' -- multiresmask(M)';

    S = ones(size(M, 1), size(M, 2));
    idx = 1;
    while(size(M, 3) >= idx)
        S = S & M(:, :, idx);

        ++idx;

    endwhile;

endfunction;
