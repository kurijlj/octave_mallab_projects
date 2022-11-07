pkg load image;
pkg load ltfat;

[imn, imo] = make_test_noisy_scan(1024, 'gaussian', 400);

ds = { ...
    PixelDataSmoothing( ...
        'Title', 'Median 3x3', ...
        'Filter', 'Median', ...
        'Window', [3 3] ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'Median 5x5', ...
        'Filter', 'Median', ...
        'Window', [5 5] ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'Wiener 3x3', ...
        'Filter', 'Wiener', ...
        'Window', [3 3] ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'Wiener 5x5', ...
        'Filter', 'Wiener', ...
        'Window', [5 5] ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'UWT ans:spline3:7 #FbIter 1', ...
        'Filter', 'UWT', ...
        'WtFb', 'ana:spline3:7', ...
        'WtFbIter', 1, ...
        'WtFs', 'sqrt', ...
        'WtResRstrc', false ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'UWT ans:spline3:7 #FbIter 2', ...
        'Filter', 'UWT', ...
        'WtFb', 'ana:spline3:7', ...
        'WtFbIter', 2, ...
        'WtFs', 'sqrt', ...
        'WtResRstrc', false ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'UWT ans:spline3:7 #FbIter 3', ...
        'Filter', 'UWT', ...
        'WtFb', 'ana:spline3:7', ...
        'WtFbIter', 3, ...
        'WtFs', 'sqrt', ...
        'WtResRstrc', false ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'UWT ans:spline3:7 #FbIter 4', ...
        'Filter', 'UWT', ...
        'WtFb', 'ana:spline3:7', ...
        'WtFbIter', 4, ...
        'WtFs', 'sqrt', ...
        'WtResRstrc', false ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'UWT ans:spline3:7 #FbIter 5', ...
        'Filter', 'UWT', ...
        'WtFb', 'ana:spline3:7', ...
        'WtFbIter', 5, ...
        'WtFs', 'sqrt', ...
        'WtResRstrc', false ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'UWT ans:spline3:7 #FbIter 1', ...
        'Filter', 'UWT', ...
        'WtFb', 'ana:spline3:7', ...
        'WtFbIter', 1, ...
        'WtFs', 'sqrt', ...
        'WtResRstrc', true ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'UWT ans:spline3:7 #FbIter 2', ...
        'Filter', 'UWT', ...
        'WtFb', 'ana:spline3:7', ...
        'WtFbIter', 2, ...
        'WtFs', 'sqrt', ...
        'WtResRstrc', true ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'UWT ans:spline3:7 #FbIter 3', ...
        'Filter', 'UWT', ...
        'WtFb', 'ana:spline3:7', ...
        'WtFbIter', 3, ...
        'WtFs', 'sqrt', ...
        'WtResRstrc', true ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'UWT ans:spline3:7 #FbIter 4', ...
        'Filter', 'UWT', ...
        'WtFb', 'ana:spline3:7', ...
        'WtFbIter', 4, ...
        'WtFs', 'sqrt', ...
        'WtResRstrc', true ...
        ), ...
    PixelDataSmoothing( ...
        'Title', 'UWT ans:spline3:7 #FbIter 5', ...
        'Filter', 'UWT', ...
        'WtFb', 'ana:spline3:7', ...
        'WtFbIter', 5, ...
        'WtFs', 'sqrt', ...
        'WtResRstrc', true ...
        ), ...
    };

idx = 1;
while(size(ds, 2) >= idx)
    printf('sp: Applying %s ... ', ds{idx}.str_rep());
    rdiff = (ds{idx}.smooth(imn) - imo)./imo;
    printf('Mean diff: %d, stdev: %d\n', mean2(rdiff), std2(rdiff));

    ++idx;

endwhile;
