function eval_auto_noise_est(imsize=1024)
    sigma = [10, 30, 50, 100, 300, 500, 1000, 3000, 5000];
    idx = 1;

    while(numel(sigma) >= idx)
        im = make_test_img(imsize, 'gaussian', 32000, sigma(idx)*sigma(idx));
        se = uwt_auto_noise_est(im);

        printf( ...
            'variance(std): %3.2f, estimate: %3.2f, error(%%): %3.2f\n', ...
            sigma(idx), ...
            se, ...
            ((se - sigma(idx))/sigma(idx))*100 ...
            );

        ++idx;

    endwhile;

endfunction;
