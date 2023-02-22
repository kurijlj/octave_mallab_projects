function fp1 = fituj_podatke(ds, sdd, gt='Naslov', yt='Y', n=2, sl=1)
    fp1 = polyfit(ds(:, 1), ds(:, 2), n);
    fp2 = polyfit(sdd(:, 1), sdd(:, 2), n);
    fit1 = [];
    fit2 = [];
    if(1 == n)
        if(1 == sl)
            fit1 = fp1(1)*sort(ds(:, 1)) + fp1(2);
            fit2 = fp2(1)*sort(sdd(:, 1)) + fp2(2);

        else
            fp1 = mean(ds(:, 2));
            fit1 = ones(size(ds, 1), 1).*fp1;
            fp2 = mean(sdd(:, 2));
            fit2 = ones(size(sdd, 1), 1).*fp2;

        endif;

        % fit2 = ones(size(sdd, 1), 1);
        % fit2 = fit2.*mean(sdd(:, 2));
        %fit2 = fp2(1)*sort(sdd(:, 1)) + fp2(2);

    else
        fit1 = fp1(1)*power(sort(ds(:, 1)), 2) + fp1(2)*sort(ds(:, 1));
        fit2 = fp2(1)*power(sort(sdd(:, 1)), 2) + fp2(2)*sort(sdd(:, 1));

    endif;
    uppl = fit1 + 3*fit2;
    lowl = fit1 - 3*fit2;

    figure();
    scatter(ds(:, 1), ds(:, 2));
    hold on;
    plot(sort(ds(:, 1)), fit1, 'color', '#c33838', 'linewidth', 1.0);
    plot(sort(sdd(:, 1)), lowl, 'color', '#c33838', 'linewidth', 1.0, 'linestyle', '--');
    plot(sort(sdd(:, 1)), uppl, 'color', '#c33838', 'linewidth', 1.0, 'linestyle', '--');
    xlabel('Srednje odstupanje od izocentra [mm]', 'fontsize', 17)
    ylabel(sprintf('%s [mm]', yt), 'fontsize', 17);
    title(gt, 'fontsize', 19);
    legend('usrednjeni rezultati merenja', 'fit', '-3sd', '+3sd', 'fontsize', 17);
    hold off;

endfunction;
