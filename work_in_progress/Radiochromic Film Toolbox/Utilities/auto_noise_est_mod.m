% -----------------------------------------------------------------------------
%
% Function 'auto_noise_est_mod':
%
% Use:
%       -- auto_noise_est_mod(I, p)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function [M, sigma] = auto_noise_est_mod(I, p)
    fname = 'auto_noise_est_mod';
    use_case_a = ' -- auto_noise_est(I, p)';

    n     = 1;
    M     = [];
    sigma = [];

    while(p >= n)
        [coef, info] = ufwt(I, 'syn:spline3:3', n);
        c = reshape(coef(:, 1, :), size(coef, 1), size(coef, 3));
        w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));

        if(1 == n)
            sigma(n) = median(abs(w(:)))/0.6745;
            M = [abs(w);];
            M(:, :, n) = M(:, :, n) < 3*sigma(n);

        endif;


        idx = 1;
        mask = ones(size(M, 1), size(M, 2));
        while(size(M, 3) >= idx)
            mask = mask & M(:, :, idx);
            ++idx;

        endwhile;

        if(numel(mask) == sum(sum(mask)) || 0 == sum(sum(mask)))
            return;

        endif;

        sigma(n) = median(abs(w(mask)(:)))/0.6745;
        M(:, :, n) = [abs(w);];
        M(:, :, n) = M(:, :, n) >= 3*sigma(n);

        ++n;

    endwhile;

endfunction;
