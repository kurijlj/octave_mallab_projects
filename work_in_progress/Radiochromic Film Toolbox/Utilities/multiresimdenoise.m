% -----------------------------------------------------------------------------
%
% Function 'multiresimdenoise':
%
% Use:
%       -- multiresimdenoise(I, p, l)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function imdn = multiresimdenoise(I, p, l)
    fname = 'multiresimdenoise';
    use_case_a = ' -- multiresimdenoise(I, p, l)';

    [coef, info] = ufwt(I, 'syn:spline3:7', p);
    c = reshape(coef(:, 1, :), size(coef, 1), size(coef, 3));
    w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));

    [coef, info] = ufwt(I - c, 'syn:spline3:7', p);
    coef = thresh(coef, 3*l, 'soft');
    E = iufwt(coef, info);

    imdn = c + E;

endfunction;
