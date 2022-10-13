% -----------------------------------------------------------------------------
%
% Function 'uwtimdenoise':
%
% Use:
%       -- uwtimdenoise(I, lambda, thr_type)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function RI = uwtimdenoise(I, lambda, thr_type)
    fname = 'uwtimdenoise';
    use_case_a = ' -- uwtimdenoise(I, lambda, thr_type)';

    [coef, info] = ufwt(I, 'syn:spline3:7', 1);
    coef = thresh(coef, lambda, thr_type);
    RI = iufwt(coef, info);

endfunction;
