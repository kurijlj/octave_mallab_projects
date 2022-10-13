% -----------------------------------------------------------------------------
%
% Function 'calculate_multires_support':
%
% Use:
%       -- calculate_multires_support(I, p)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function M = calculate_multires_support(I, p)
    fname = 'calculate_multires_support';
    use_case_a = ' -- calculate_multires_support(I, p)';

    M = zeros(size(I, 1), size(I, 2), p);
    idx = 1;
    while(p >= idx)
        [coef, info] = ufwt(I, 'syn:spline3:7', idx);
        w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));
        nstd = median(abs(w)(:))/0.6745;
        M(:, :, idx) = w >= 3*nstd;

        ++idx;

    endwhile;

endfunction;
