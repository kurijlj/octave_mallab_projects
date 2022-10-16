function [Ir, nsstd] = guwtimdenoise(I, J)
    wtana = 'syn:spline3:7';
    wtsyn = 'ana:spline3:7';
    fs = 'sqrt';
    % fs = 'noscale';
    % fs = 'scale';
    thr = 'hard';

    [coef, info] = uwfbt(I, {wtana, J, 'full'}, 'sqrt');
    c = reshape(coef(:, 1, :), size(coef, 1), size(coef, 3));
    w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));
    fstest = median(abs(w)(:))/0.6745;
    mask = imdilate( ...
        abs(w) >= fstest*sqrt(2*log(numel(w))), ...
        [0, 1, 0; 1, 1, 1; 0, 1, 0;] ...
        );
    nsstd = median(abs(w(~mask))(:))/0.6745;
    lambda = nsstd*sqrt(2*log(sum(sum(~mask))));
    ns = I - c;
    [coef, info] = uwfbt(ns, {wtana, 1, 'full'}, 'sqrt');
    coef = thresh(coef, lambda, thr);
    Ir = c + iuwfbt(coef, {wtsyn, 1, 'full'}, 'sqrt');

endfunction;
