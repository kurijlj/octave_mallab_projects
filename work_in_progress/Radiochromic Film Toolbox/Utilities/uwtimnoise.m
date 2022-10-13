% -----------------------------------------------------------------------------
%
% Function 'uwtimnoise':
%
% Use:
%       -- uwtimnoise(I)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function sigma = uwtimnoise(I)
    fname = 'uwtimnoise';
    use_case_a = ' -- uwtimnoise(I)';

    % Determine significan coeficients
    [coef, info] = ufwt(I, 'syn:spline3:7', 1);
    c = reshape(coef(:, 1, :), size(coef, 1), size(coef, 3));
    w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));
    % mask = imdilate(abs(w) >= 3*317.79, [0, 1, 0; 1, 1, 1; 0, 1, 0]);
    mask = imdilate( ...
        abs(w) >= 3*(median(abs(w)(:))/0.6745), ...
        [0, 1, 0; 1, 1, 1; 0, 1, 0] ...
        );

    % Determine noise variance (i.e. standard deviation)
    [coef, info] = ufwt(I, 'syn:spline3:7', 1);
    c = reshape(coef(:, 1, :), size(coef, 1), size(coef, 3));
    w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));
    sigma = median(abs(w(~mask)(:)))/0.6745;

endfunction;
