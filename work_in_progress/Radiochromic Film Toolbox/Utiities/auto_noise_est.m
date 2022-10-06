% -----------------------------------------------------------------------------
%
% Function 'auto_noise_est':
%
% Use:
%       -- auto_noise_est(I)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function [c, w, sigma] = auto_noise_est(I, p)
    fname = 'auto_noise_est';
    use_case_a = ' -- auto_noise_est(I)';

    n     = 0;
    c     = [];
    w     = [];
    sigma = [std2(I)];

    while(p > n)
        [cw, i] = ufwt(I, 'syn:spline2:2', n + 1);
        if(0 == n)
            c = reshape(cw(:, 1, :), size(I, 1), size(I, 2));
            w = [reshape(cw(:, 2, :), size(I, 1), size(I, 2));];

        else
            c(:, :, end + 1) = reshape(cw(:, 1, :), size(I, 1), size(I, 2));
            w(:, :, end + 1) = reshape(cw(:, 2, :), size(I, 1), size(I, 2));

        endif;

        ++n;

    endwhile;

    n = 0;

    while(p > n)
        M = abs(w(n + 1));
        M = M < 3*sigma(n + 1);
        S = I - c(n + 1);
        sigma(end + 1) = std2(S(M));

        printf('%s: %d\n', (sigma(n + 2) - sigma(n + 1))/sigma(n + 2));

        ++n;

    endwhile;

endfunction;
