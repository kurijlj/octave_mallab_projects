% -----------------------------------------------------------------------------
%
% Function 'multiresimnoise':
%
% Use:
%       -- multiresimnoise(I)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function sigma = multiresimnoise(I)
    fname = 'multiresimnoise';
    use_case_a = ' -- multiresimnoise(I)';

    M = [zeros(size(I, 1), size(I, 2));];
    sigma = [];
    idx = 1;
    while(true)
        [coef, info] = ufwt(I, 'syn:spline3:7', idx);
        c = reshape(coef(:, 1, :), size(coef, 1), size(coef, 3));
        w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));
        M(:, :, idx) = imdilate( ...
            abs(w) >= 3*(median(abs(w)(:))/0.6745), ...
            [0, 1, 0; 1, 1, 1; 0, 1, 0] ...
        );
        mask = multiresmask(M);
        s = median(abs(w(~mask))(:))/0.6745;

        if(1 < idx)
            r = (sigma(idx - 1) - s)*100/sigma(idx - 1);
            if(0 >= r)
                break;

            endif;

        endif;

        sigma(idx) = s;

        ++idx;

    endwhile;

endfunction;
