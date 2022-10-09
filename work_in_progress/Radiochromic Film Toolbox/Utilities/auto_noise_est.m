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
function [M, sigma] = auto_noise_est(I, p)
    fname = 'auto_noise_est';
    use_case_a = ' -- auto_noise_est(I)';

    n     = 0;
    c     = zeros(size(I, 1), size(I, 2), p);
    w     = zeros(size(I, 1), size(I, 2), p);
    M     = zeros(size(I, 1), size(I, 2), p);
    sigma = [];

    while(p > n)
        [cw, i] = ufwt(I, 'syn:spline2:4', n + 1);
        c(:, :, n + 1) = reshape(cw(:, 1, :), size(I, 1), size(I, 2));
        w(:, :, n + 1) = reshape(cw(:, 2, :), size(I, 1), size(I, 2));
        if(0 == n)
            sigma(end + 1) = std2(w(:, :, 1));

        endif;

        M(:, :, n + 1) = abs(w(:, :, n + 1));
        M(:, :, n + 1) = M(:, :, n + 1) < 3*sigma(n + 1);

        S = I - c(:, :, n + 1);
        idx = 1;
        mask = ones(size(M, 1), size(M, 2));
        while(size(M, 3) >= idx)
            mask = mask & M(:, :, idx);
            ++idx;

        endwhile;

        if(numel(mask) == sum(sum(mask)))
            return;

        endif;

        sigma(n + 2) = std2(S(mask));
        printf( ...
            '%s: %d\n', ...
            fname, ...
            ((sigma(n + 2) - sigma(n + 1))/sigma(n + 2))*100 ...
            );

        ++n;

    endwhile;

endfunction;
