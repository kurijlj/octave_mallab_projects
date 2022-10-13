function evaluate_imnoise_estimator(imsize=1024)
    sigma = [10, 30, 50, 100, 300, 500, 600, 700, 800, 900, 1000, 3000, 5000];
    idx = 1;

    while(numel(sigma) >= idx)
        im = make_test_noisy_img(imsize, 'gaussian', sigma(idx));
        se = uwtimnoise(im);

        printf( ...
            'variance(std): %3.2f, estimate: %3.2f, error(%%): %3.2f\n', ...
            sigma(idx), ...
            se, ...
            ((se - sigma(idx))/sigma(idx))*100 ...
            );

        ++idx;

    endwhile;

endfunction;
