% -----------------------------------------------------------------------------
%
% Function 'uwt_auto_noise_est':
%
% Use:
%       -- uwt_auto_noise_est(I)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function sigma = uwt_auto_noise_est(I)
    fname = 'uwt_auto_noise_est';
    use_case_a = ' -- uwt_auto_noise_est(I)';

    % Determine significan coeficients
    [coef, info] = ufwt(I, 'syn:spline3:7', 2);
    c = reshape(coef(:, 1, :), size(coef, 1), size(coef, 3));
    w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));
    mask = imdilate(abs(w) >= 3*317.79, [0, 1, 0; 1, 1, 1; 0, 1, 0]);

    % Determine noise variance (i.e. standard deviation)
    [coef, info] = ufwt(I, 'syn:spline3:7', 1);
    c = reshape(coef(:, 1, :), size(coef, 1), size(coef, 3));
    w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));
    sigma = median(abs(w(~mask)(:)))/0.6745;

endfunction;
