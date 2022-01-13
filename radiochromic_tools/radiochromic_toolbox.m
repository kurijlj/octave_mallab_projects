% =============================================================================
% Radiochromic Toolbox - Set of tools for radiochromic film scans analysis
%
%  Copyright (C) 2021 Ljubomir Kurij <ljubomir_kurij@protonmail.com>
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.
%
% =============================================================================


% =============================================================================
%
% Description
% ----------------------------------------------------------------------------
%
% A set of functions and classes for equipment commisionig and data analysis
% for radiochromic films
%
% =============================================================================


% =============================================================================
%
% 2021-11-17 Ljubomir Kurij <ljubomir_kurij@protonmail.com
%
% * radiochromic_toolbox.m: created.
%
% =============================================================================


% =============================================================================
%
% References (this section should be deleted in the release version)
%
% * Applied Medical Image Processing 2nd Ed, CRC Press
% * 1-D Haar Wavelets <https://www.numerical-tours.com/matlab/wavelet_1_haar1d/>
%
% =============================================================================


% =============================================================================
%
% Script header
%
% =============================================================================

% We put dummy expression into scripts header to prevent Octave command line
% enivornment to interpret it as a simple function file

kVersionString = "0.1";
printf("Radiochromic Toolbox v%s\n\n", kVersionString);


% =============================================================================
%
% Module load section
%
% =============================================================================

pkg load image;


% =============================================================================
%
% Functions declarations
%
% =============================================================================

% /////////////////////////////////////////////////////////////////////////////
%
% function rct_absolute_od(image) - image to optical density
%
% Convert 16 bit grayscale image to optical density using formula:
%
%       OD = log10(I0/I)
%
% where I0 equals to maximum pixel intensity of 2^16-1 = 65535. Input image
% must be single channel grayscale image of type uint16 (16 bits). Otherwise
% function returns NaN and reports error.
%
% /////////////////////////////////////////////////////////////////////////////

function result = rct_absolute_od(image)

    % Initialize return variables.
    result = NaN;

    % Do basic sanity checking. First verify if given parameter is
    % matrix at all.
    if(not(ismatrix(image)))
        error("Invalid data type. Parameter 'image' must be an matrix of pixel values.");

        return;

    endif;

    % Verify data class for 'image' paramter.
    if (not(isequal("uint16", class(image))))
        error("Invalid data type. Parameter 'image' must be of type 'uint16' not '%s'.", ...
            class(image) ...
            );

        return;

    endif;

    % Verify if 'image' is monochrome (i.e. a 2D matrx).
    if (2 ~= size(size(od))(2))
        error("Invalid data type. Parameter 'image' must be a monochrome image.");

        return;

    endif;

    width  = size(image)(1);
    height = size(image)(2);

    % Allocate memory for the result
    result = zeros(width, height);

    printf("processing:     ");

    for i = 1:width
        for j = 1:height
            result(i,j) = log10(65535.0 / double(image(i,j)));

        endfor;

        printf("\b\b\b\b\b%4d%%", uint32((i / width) * 100))

    endfor;

    printf("\b\b\b\b\b Completed!\n");

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_relative_od(ref, signal) - image to optical density
%
% Convert 16 bit grayscale image to optical density using using reference, and
% image containing signal and formula:
%
%       OD = log10(I0/I)
%
% where I0 represents reference image and I represents image with signal.
% Reference and input images must be single channel grayscale images of type
% uint16 (16 bits) and both images must be with same dimensions (equal width and
% height). Otherwise function returns NaN and reports error.
%
% /////////////////////////////////////////////////////////////////////////////

function result = rct_relative_od(ref, signal)

    % Initialize return variables.
    result = NaN;

    % Do basic sanity checking. First verify if given parameters are
    % matrices at all.
    if(not(ismatrix(ref)))
        error("Invalid data type. Parameter 'ref' must be an matrix of pixel values.");

        return;

    endif;

    if(not(ismatrix(signal)))
        error("Invalid data type. Parameter 'signal' must be an matrix of pixel values.");

        return;

    endif;

    % Verify data class for given parameters.
    if (not(isequal("uint16", class(ref))))
        error("Invalid data type. Parameter 'ref' must be of type 'uint16' not '%s'.", ...
            class(ref) ...
            );

        return;

    endif;

    if (not(isequal("uint16", class(signal))))
        error("Invalid data type. Parameter 'signal' must be of type 'uint16' not '%s'.", ...
            class(signal) ...
            );

        return;

    endif;

    % Verify if both parameters are monochrome (ie. 2D) images.
    if (2 ~= size(size(ref))(2))
        error("Invalid data type. Parameter 'ref' must be a monochrome image.");

        return;

    endif;

    if (2 ~= size(size(signal))(2))
        error("Invalid data type. Parameter 'signal' must be a monochrome image.");

        return;

    endif;

    % Verify if both matrices are of equal sizes.
    if (not(size_equal(ref, signal)))
        error(
            "Size mismatch. Reference and signal images are not of equal sizes."
        );

        return;

    endif;

    width  = size(ref)(1);
    height = size(ref)(2);

    % Allocate memory for the result
    result = zeros(width, height);

    printf("processing:     ");

    for i = 1:width
        for j = 1:height
            result(i,j) = log10(double(ref(i,j)) / double(signal(i,j)));

        endfor;

        printf("\b\b\b\b\b%4d%%", uint32((i / width) * 100))

    endfor;

    printf("\b\b\b\b\b Completed!\n");

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_hist(data, nbins) - calculate data frequency distribution
%
% Calculate data frequency distribution for given dataser. This function is only
% to be used for teaching and demonstration purposes.
%
% /////////////////////////////////////////////////////////////////////////////
function [bins, x_bins] = rct_hist(data, nbins)
    x_bins = 0;
    bins = 0;
    min_val = 0;
    max_val = 0;
    depth = 0;
    dim = 0;
    bin_size = 0;

    if(ismatrix(data))
        dim = size(size(data))(2);

        if(3 < dim)
            % We do not support matrixes with more than three dimesions.
            error(
                "rct_hist_rev: Invalid data type!",
                "Given data matrix has more than three dimensions."
            );

            return;

        elseif(1 > dim)
            % Probably an empty matrix.
            error(
                "rct_hist_rev: Invalid data type!",
                "Given data matrix has no items."
            );

            return;

        elseif(3 == dim)
            min_val = min(min(min(data)));
            max_val = max(max(max(data)));

        elseif(2 == dim)
            min_val = min(min(data));
            max_val = max(max(data));

        else
            % We have one dimensional matrix (array)
            min_val = min(data);
            max_val = max(data);

        endif;

        depth = max_val - min_val;

    else
        % We are not dealing with a matrix
        error(
            "rct_hist_rev: Invalid data type!",
            "Given data is not a matrix."
        );

        return;

    endif;

    bin_size = depth / nbins;
    x_bins = zeros(1, nbins);
    bins = zeros(1, nbins);

    printf("processing:   0%%");

    for i = 1:nbins
        x_bins(i) = min_val + bin_size*(i - 0.5);

    endfor;

    if(3 == dim)
        height = size(data)(1);
        width = size(data)(2);
        depth = size(data)(3);

        for y = 1:height
            for x = 1:width
                for z = 1:depth
                    for i = 1:nbins
                        bin_top = min_val + bin_size*i;
                        bin_bot = min_val + bin_size*(i - 1);

                        if((bin_top > data(y, x, z)) ...
                                && (bin_bot <= data(y, x, z)))
                            bins(i) = bins(i) + 1;

                            % We found our bin so stop traversing histogram.
                            break;

                        endif;

                    endfor;

                endfor;

                complete = (z - 1)*width*height + (y - 1)*width + x;
                all = height*width*epth;
                percent_complete = uint32(round((complete / all) * 100));
                printf("\b\b\b\b\b%4d%%", percent_complete);

            endfor;

        endfor;

    elseif(2 == dim)
        height = size(data)(1);
        width = size(data)(2);

        for y = 1:height
            for x = 1:width
                for i = 1:nbins
                    bin_top = min_val + bin_size*i;
                    bin_bot = min_val + bin_size*(i - 1);

                    if((bin_top > data(y, x)) ...
                            && (bin_bot <= data(y, x)))
                        bins(i) = bins(i) + 1;

                        % We found our bin so stop traversing histogram.
                        break;

                    endif;

                endfor;

                complete = (y - 1)*width + x;
                all = width*depth;
                percent_complete = uint32(round((complete / all) * 100));
                printf("\b\b\b\b\b%4d%%", percent_complete);

            endfor;

        endfor;

    else
        len = length(data);

        for x = 1:len
            for i = 1:nbins
                bin_top = min_val + bin_size*i;
                bin_bot = min_val + bin_size*(i - 1);

                if((bin_top > data(1, x)) ...
                        && (bin_bot <= data(1, x)))
                    bins(i) = bins(i) + 1;

                    % We found our bin so stop traversing histogram.
                    break;

                endif;

                percent_complete = uint32(round((x / len) * 100));
                printf("\b\b\b\b\b%4d%%", percent_complete);

            endfor;

        endfor;

    endif;

    printf("\b\b\b\b\b Completed!\n");

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_fast_hist(data, nbins) - calculate data frequency distribution
%
% Fast algorithm for calculating data frequency distribution for given dataset
% and given number of bins. Algorithm is mainly tested on the 2D data but it
% should be able to handle n-dimensional data.
%
% /////////////////////////////////////////////////////////////////////////////

function [values_count, values_range] = rct_fast_hist(data, nbins)
    if(not(ismatrix(data)))
        % We are not dealing with a matrix
        error(
            "rct_hist_rev_fast: Invalid data type!",
            "Given data is not a matrix."
        );

        return;

    endif;

    min_val = 0;
    max_val = 0;

    dim = size(size(data))(2);

    if(3 < dim)
        % We do not support matrixes with more than three dimesions.
        error(
            "rct_hist_rev: Invalid data type!",
            "Given data matrix has more than three dimensions."
        );

        return;

    elseif(1 > dim)
        % Probably an empty matrix.
        error(
            "rct_hist_rev: Invalid data type!",
            "Given data matrix has no items."
        );

        return;

    elseif(3 == dim)
        min_val = min(min(min(data)));
        max_val = max(max(max(data)));

    elseif(2 == dim)
        min_val = min(min(data));
        max_val = max(max(data));

    else
        % We have one dimensional matrix (array)
        min_val = min(data);
        max_val = max(data);

    endif;

    depth = max_val - min_val;

    bin_size = depth / nbins;
    values_range = zeros(1, nbins);
    values_count = zeros(1, nbins);

    % Give some feedback on calculation progress
    printf("processing:   0%%");

    for i = 1:nbins
        values_range(i) = min_val + bin_size*(i - 0.5);
        bin_bot = min_val + bin_size*(i - 1);
        bin_top = min_val + bin_size*i;

        if(1 == i)
            mask = data >= bin_bot;
        else
            mask = data > bin_bot;
        endif;
        in_bin = data.*mask;
        mask = data <= bin_top;
        in_bin = in_bin.*mask;

        values_count(i) = nnz(in_bin);

        percent_complete = uint32(round((i / nbins) * 100));
        printf("\b\b\b\b\b%4d%%", percent_complete);

    endfor;

    printf("\b\b\b\b\b Completed!\n");

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_hist_plot(od, nbins)
% - calculate and plot histogram for given optical density and number of bins
%
% /////////////////////////////////////////////////////////////////////////////

function rct_hist_plot(od, dataset_name="Unknown", nbins=1000)
    % Do basic sanity checking
    if (not(isequal("uint16", class(od))))
        error("Invalid data type. Parameter 'od' must be of type 'uint16' not '%s'.", ...
            class(od) ...
            );

        return;

    endif;

    if (2 ~= size(size(od))(2))
        error("Invalid data type. Not a grayscale image.");

        return;

    endif;

    if(not(isequal("char", class(dataset_name))))
        error("Invalid data type. Parameter 'dataset_name' must be of type 'char' not '%s'.", ...
            class(dataset_name) ...
            );

        return;

    endif;

    h = rct_fast_hist(od, nbins);
    h = h / max(h);  % Normalize histogram for plotting

    % Display intensity distribution in the upper half of the figure.
    figure();  % Spawn new figure.

    subplot(2, 1, 1);
    hold on;
    bar([1:nbins] * (65535/nbins), h);
    xlim([0 65535]);
    ylim([0 1]);
    xlabel("Intensities");
    ylabel("Distribution");
    title(sprintf("Histogram for: %s", dataset_name));
    box on;
    hold off;

    % Display intensity gradient in the lower part of the figure.
    subplot(2, 1, 2);
    hold on;
    gradient = uint16(zeros(50, nbins));
    for i = 1:nbins
        gradient(:, i) = (i * 65535)/nbins;
    endfor;
    imshow(gradient);
    axis on;
    xlabel("Intensities");
    set(gca, "xtick", [0:13107:65535]);
    set(gca, "xticklabel", {});
    set(gca, "ytick", [0 1]);
    set(gca, "yticklabel", {});
    box on;
    hold off;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_od_mean(image, fit)
% - calculate average optical density values
%
% Calculate pixelwise average optical density from optical density matrix,
% using given fit algorithm. Currently only median filter is supported.
%
% /////////////////////////////////////////////////////////////////////////////

function result = rct_od_mean(od, fit="median")
    if("median" == fit)
        result = medfilt2(od, [10 10]);

    else
        error(
            "optical_density_mean: Not implemented!",
            "Given fit algorithm not implemented."
        );

    endif;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_od_stdev(image, fit)
% - calculate standard deviation of optical density values
%
% Calculate pixelwise standard deviation of optical density values from optical
% density matrix, using given fit algorithm for calculation of pixelwise
% optical density mean. Currently only median filter is supported.
%
% /////////////////////////////////////////////////////////////////////////////

function result = rct_od_stdev(od, fit="median")
    if("median" == fit)
        odm = medfilt2(od, [10 10]);

        width  = size(od)(1);
        height = size(od)(2);
        dp = width * height;

        midsum = sum(sum(power(odm - od, 2)));
        result = sqrt(midsum/(dp - 1));

    else
        error(
            "optical_density_mean: Not implemented!",
            "Given fit algorithm not implemented."
        );

    endif;

endfunction;




% =============================================================================
%
% Haar Wavelet transform section
%
% =============================================================================

rctSampleSignal = [4, 6, 10, 12, 8, 6, 5, 5];


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_fht(data) - Forward Haar Transform
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = rct_fht_old(data)
    result = zeros(1, length(data));
    result(1:length(data)/2) ...
        = [data(1:2:length(data)) + data(2:2:length(data))] / sqrt(2);
    result(length(data)/2+1:length(data)) ...
        = [data(1:2:length(data)) - data(2:2:length(data))] / sqrt(2);
endfunction;


function [a, d] = rct_fht(signal)
    even_signal = NaN;   % Keeps input signal data
    a = NaN;             % Keeps trend signal data
    d = NaN;             % Keeps signal fluctuations data
    l = length(signal);  % Keeps length of the input signal
    h = floor(l / 2);    % Keeps calculated length of the trend
                         % and fluctuations arrays

    % Check if signal have even number of samples
    if (l / 2 ~= h)
        % We are dealing with a signal with odd number of samples. To deal with
        % this we will extend signal by one by copying the last sample.
        even_signal = zeros(1, l + 1);   % Allocate memory for the extended signal
        even_signal(1:l) = signal(:);    % Copy input signal to new storage
        even_signal(l + 1) = signal(l);  % Copy the last sample at the end
        l = length(even_signal);         % Set new input signal length
        h = floor(l / 2);                % Set new length for the resulting arrays

    else
        % Signal is of even number of samples
        even_signal = signal;

    endif;

    % Check if we are dealing with signal with at least 2 samples
    if(2 > l)
        error(
            "fhtv2: Too few data samples",
            "Signal does not contain enough data samples to apply transform"
            );

        % Return empty structures and bail out
        return;

    endif;

    % Allocate memory for the trend and fluctuations arrays
    a = zeros(1, h);
    d = zeros(1, h);
    a(:) = [even_signal(1:2:(l-1)) + even_signal(2:2:l)] / sqrt(2);
    d(:) = [even_signal(1:2:(l-1)) - even_signal(2:2:l)] / sqrt(2);

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_iht(data) - Inverse Haar Transform
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = rct_iht(trend, fluctuations)
    dim = 2*length(trend);
    result = zeros(1, dim);
    result(1:2:dim) = [trend + fluctuations]/sqrt(2);
    result(2:2:dim) = [trend - fluctuations]/sqrt(2);

endfunction;




% =============================================================================
%
% Segmentation tools section
%
% =============================================================================

% /////////////////////////////////////////////////////////////////////////////
%
% function rct_rg_segment - do OD segmentation by using region grow
%
% Segment an optical density image using region grow algorithm for a given seed
% and threshold.
%
% /////////////////////////////////////////////////////////////////////////////

function mask = rct_rg_segment(od, thrsh=0.05, seed=[-1, -1])
    % Initialize result to error value
    mask = NaN;

    % Initialize OD image size.
    width  = size(od)(2);
    height = size(od)(1);

    % Do basic sanity checking. Check if we got cell array (file list) at all.
    if((1 > width) && (1 > height))
        error(
            "rct_rg_segment: Invalid dimensions!",
            "Given optical density image has invalid dimensions (< 1 pixel)."
        );

        return;

    endif;

    if("double" ~= class(od))
        error(
            "rct_rg_segment: Invalid data type!",
            "Given argument is not of double type."
        );

        return;

    endif;

    if(2 ~= size(seed)(2))
        error(
            "rct_rg_segment: Invalid seed!",
            "Seed positional coordinates incomplete (~= 2)."
        );

        return;

    endif;

    if(~(0.0 < thrsh))
        error(
            "rct_rg_segment: Invalid data value!",
            "Threshold argument must have positive value greater than zero."
        );

        return;

    endif;

    % If seed is not specified use point in the center of an OD image as seed.
    if(0 > seed(2) || width < seed(2))
        seed(2) = floor(double(width / 2));

    endif;

    if(0 > seed(1) || height < seed(1))
        seed(1) = floor(double(height / 2));

    endif;

    % Initialize seed mask.
    mask = uint8(zeros(height, width));
    mask(seed(1), seed(2)) = 255;

    % Define value range selection criteria.
    seed_int = od(seed(1), seed(2));
    seed_rng_bot = seed_int - thrsh;
    seed_rng_top = seed_int + thrsh;

    olds = 1;  % Old seeds count
    news = 0;  % New seeds count

    while news ~= olds
        olds = news;
        news = 0;

        for j = 2:(height - 1)
            for i = 2:(width - 1)
                if(0 < mask(j, i))
                    int = od((j-1), i);
                    if((int >= seed_rng_bot) && (int <= seed_rng_top))
                        news = news + 1;
                        mask((j-1), i) = 255;

                    endif;

                    int = od((j+1), i);
                    if((int >= seed_rng_bot) && (int <= seed_rng_top))
                        news = news + 1;
                        mask((j+1), i) = 255;

                    endif;

                    int = od(j, (i-1));
                    if((int >= seed_rng_bot) && (int <= seed_rng_top))
                        news = news + 1;
                        mask(j, (i-1)) = 255;

                    endif;

                    int = od(j, (i+1));
                    if((int >= seed_rng_bot) && (int <= seed_rng_top))
                        news = news + 1;
                        mask(j, (i+1)) = 255;

                    endif;

                endif;

            endfor;

        endfor;

    endwhile;

endfunction;




% =============================================================================
%
% GUI section
%
% =============================================================================

% /////////////////////////////////////////////////////////////////////////////
%
% function rct_read_scanset - read images containing film scan set
%
% Read data from image filenames list, extract red channel and calculate and
% return mean pixel value of the red channel. It is assumed that user supplied 
% scans of the same film cut. All images must bu 48 bit RGB images with
% identical dimensions (height and width), otherwise function returns error.
% First image in the list is used as reference image for dimensions.
%
% /////////////////////////////////////////////////////////////////////////////

function [pixel_mean, pixel_std] = rct_read_scanset(flist)
    % Initialize result to error value
    pixel_mean = NaN;
    pixel_std = NaN;

    % Do basic sanity checking. Check if we got cell array (file list) at all.
    if("cell" != class(flist))
        error(
            "rct_read_ref: Invalid data type!",
            "Given argument is not a cell array."
        );

        return;

    endif;

    % Check if file list contain any item.
    nitems = length(flist);

    if(0 == nitems)
        error(
            "rct_read_ref: Empty file list!",
            "Given cell array contain no items"
        );

        return;

    endif;

    % Start reading images. Initialize variables for storing reference
    % dimensions, as well for storing extracted red channels.
    r_width = 0;
    r_height = 0;
    r_samples = 0;
    reds = cell(nitems);

    for i = 1:nitems
        printf("Reading image: %s\n", flist{i});
        image = imread(flist{i});

        % Check image data type
        if (0 == strcmp("uint16", class(image)))
            error(
                "rct_read_ref: Invalid data type!",
                "Image '%s' data not of type 'uint16'.",
                flist{i}
            );

            return;

        endif;

        [height, width, samples] = size(image);

        % If first red image set reference dimensions
        if(0 == r_width)
            r_height = height;
            r_width = width;
            r_samples = samples;

        % Check if image dimensions match dimensions of the first image
        elseif(r_height ~= height ...
                    || r_width ~= width ...
                    || r_samples ~= samples
                )
            error(
                "rct_read_ref: Dimensions mismatch!",
                "Image: %s dimensions do not match dimensions of the reference image.",
                flist{i}
            );

            return;

        endif;

        % Check if we are dealing with RGB image (samples = 3)
        if(3 ~= samples)
            error(
                "rct_read_ref: Invalid number of color samples!",
                "Image '%s' is not an RGB image.",
                flist{i}
            );

            return;

        endif;

        reds{i} = image(:,:,1);

    endfor;

    printf("Reading complete!\n");

    printf("Calculating mean pixel value:     ");
    pixel_mean = zeros(height, width);
    pixel_std = zeros(height, width);

    for j = 1:r_height
        for i = 1:r_width
            pixels = zeros(nitems, 1);
            for k = 1:nitems
                pixels(k) = reds{k}(j, i);
            endfor;

            pixel_mean(j, i) = mean(pixels);
            pixel_std(j, i) = std(pixels);

        endfor;

        printf("\b\b\b\b\b%4d%%", uint32((j / r_height) * 100))

    endfor;

    printf("\b\b\b\b\b Complete!\n");

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_read_scanset_gui - read images containing film scan set using GUI
%
% Read data from image filenames list, extract red channel and calculate and
% return mean pixel value of the red channel. It is assumed that user supplied 
% scans of the same film cut. All images must bu 48 bit RGB images with
% identical dimensions (height and width), otherwise function returns error.
% First image in the list is used as reference image for dimensions.
%
% /////////////////////////////////////////////////////////////////////////////

function [pixel_mean, pixel_std] = rct_read_scanset_gui(save_result=false)
    persistent rctCurrentDir = pwd();  % Keeps track of the last directory
                                     % accessd via rct_read routines
    paths = NaN;
    pixel_mean = NaN;
    pixel_std = NaN;

    [fnames, fpath] = uigetfile( ...
        {'*.tif', 'Radiochromic Film Scanset'}, ...
        'Select Scanset', ...
        fullfile(rctCurrentDir, filesep()),
       "MultiSelect", "on" ...
        );

    % If we have valid path and file name we can load the image
    if("cell" == class(fnames))
        % Set current dir and reference scan file name
        rctCurrentDir = fpath;

        % Initialize 'paths' as cell array
        paths = cell(length(fnames),1);

        for i = 1:length(fnames)
            paths{i} = fullfile(fpath, fnames{i});

        endfor;

        [pixel_mean, pixel_std] = rct_read_scanset(paths);

    endif;

    if(save_result)
        % Save data to CSV files. Construct file name using name of first file
        % assuming that scanset filenames use format:
        %     Procedure_MchineID_CoverPlateType_Field_#FilmNo_Date_ScanNo.tif
        % e.g.:
        %     Calibration_GK_plexi_16mm_#1_20200101_001.tif
        %
        [dir, name, ext] = fileparts(fnames{1});
        name = strtrunc(name, length(name) - 3);
        mean_name = strcat(name, "R_mean");
        std_name = strcat(name, "R_std");
        mean_csv_name = fullfile( ...
            rctCurrentDir, ...
            strcat(mean_name, ".csv") ...
            );
        std_csv_name = fullfile( ...
            rctCurrentDir, ...
            strcat(std_name, ".csv") ...
            );
        mean_tif_name = fullfile( ...
            rctCurrentDir, ...
            strcat(mean_name, ".tif") ...
            );
        std_tif_name = fullfile( ...
            rctCurrentDir, ...
            strcat(std_name, ".tif") ...
            );

        printf("Saving data to file: \"%s\"\n", mean_csv_name);
        csvwrite(mean_csv_name, pixel_mean);
        printf("Saving data to file: \"%s\"\n", mean_tif_name);
        imwrite(uint16(round(pixel_mean)), mean_tif_name, "TIF");

        printf("Saving data to file: \"%s\"\n", std_csv_name);
        csvwrite(std_csv_name, pixel_std);
        printf("Saving data to file: \"%s\"\n", std_tif_name);
        imwrite(uint16(round(pixel_std)), std_tif_name, "TIF");

        printf("Saving data complete!\n");

    endif;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_cross_plot - plot cross profiles for given image
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function rct_cross_plot(img, dpi=0, x_center=-1, y_center=-1)
    width  = size(img)(2);
    height = size(img)(1);

    % If not supplied calculate the center of image
    if(0 > x_center || width < x_center)
        x_center = floor(double(width / 2));

    endif;

    if(0 > y_center || height < y_center)
        y_center = floor(double(height / 2));

    endif;

    % Plot cross profile
    subplot(2, 1, 1);
    if(0 < dpi)
        % Plot positions in milimeters
        mm = 25.4 / dpi;
        plot([1:width] * mm, img(y_center,:));
        xlabel("Position [mm]");
    else
        plot([1:width], img(y_center,:));
        xlabel("Position [pixels]");
    endif;
    ylabel("OD");
    title("X Profile");

    % Plot inline profile
    subplot(2, 1, 2);
    if(0 < dpi)
        % Plot positions in milimeters
        mm = 25.4 / dpi;
        plot([1:height] * mm, img(:,x_center));
        xlabel("Position [mm]");
    else
        plot([1:height], img(:,x_center));
        xlabel("Position [pixels]");
    endif;
    ylabel("OD");
    title("Y Profile");

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_cross_plot_compare - plot cross profiles for given image
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function rct_cross_plot_compare(img1, img2, dpi=0, centers=[-1, -1, -1, -1])
    width1  = size(img1)(2);
    height1 = size(img1)(1);
    width2  = size(img2)(2);
    height2 = size(img2)(1);

    % If not supplied calculate the centers of images
    if(0 > centers(1) || width1 < centers(1))
        centers(1) = floor(double(width1 / 2));

    endif;

    if(0 > centers(2) || height1 < centers(2))
        centers(2) = floor(double(height1 / 2));

    endif;

    if(0 > centers(3) || width2 < centers(3))
        centers(3) = floor(double(width2 / 2));

    endif;

    if(0 > centers(4) || height2 < centers(4))
        centers(4) = floor(double(height2 / 2));

    endif;

    % Plot cross profiles
    subplot(2, 1, 1);
    if(0 < dpi)
        % Plot positions in milimeters
        mm = 25.4 / dpi;
        plot(([1:width1] - centers(1)) * mm, ...
            img1(centers(2),:), ...
            ([1:width2] - centers(3)) * mm, ...
            img2(centers(4),:), ...
            [0, 0], ...
            [0, max([max(img1(centers(2),:)), max(img2(centers(4),:))])], ...
            color="k" ...
            );
        xlabel("Position [mm]");
    else
        plot([1:width1] - centers(1), ...
            img1(centers(2),:), ...
            [1:width2] - centers(3), ...
            img2(centers(4),:), ...
            [0, 0], ...
            [0, max([max(img1(centers(2),:)), max(img2(centers(4),:))])], ...
            color="k" ...
            );
        xlabel("Position [pixels]");
    endif;
    ylabel("OD");
    legend("Profile #1", "Profile #2");
    title("Cross Profile");

    % Plot inline profiles
    subplot(2, 1, 2);
    if(0 < dpi)
        % Plot positions in milimeters
        mm = 25.4 / dpi;
        plot(([1:height1] - centers(2)) * mm, ...
            img1(:,centers(1)), ...
            ([1:height2] - centers(4)) * mm, ...
            img2(:,centers(3)), ...
            [0, 0], ...
            [0, max([max(img1(:,centers(1))), max(img2(:,centers(3)))])], ...
            color="k" ...
            );
        xlabel("Position [mm]");
    else
        plot([1:height1] - centers(2), ...
            img1(:,centers(1)), ...
            [1:height2] - centers(4), ...
            img2(:,centers(3)), ...
            [0, 0], ...
            [0, max([max(img1(:,centers(1))), max(img2(:,centers(3)))])], ...
            color="k" ...
            );
        xlabel("Position [pixels]");
    endif;
    ylabel("OD");
    legend("Profile #1", "Profile #2");
    title("Inline Profile");

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_multi_cross_plot- plot cross profiles for given monochrome images
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function rct_multi_cross_plot(images, dpi=0)
    % Do basic sanity checking
    if("cell" != class(images))
        error(
            "rct_multi_cross_plot: Invalid data type!",
            "Given argument is not a cell array."
        );

        return;

    endif;

    nitems = length(images);

    if(0 == nitems)
        error(
            "rct_multi_cross_plot: Empty file list!",
            "Given cell array contain no items"
        );

        return;

    endif;

    % Initiialize variables for keeping reference dimensions of the plot. We use
    % the largest dimensions of all supplied images as reference dimensions.
    r_height = 0;
    r_width = 0;

    % Determine maximum extents of plot.
    for i = 1:nitems
        [height, width, samples] = size(images{i});

        % Check if we are dealing with more than one sample per pixel.
        if(1 < samples)
            % We have more than one sample per pixel (not a monochrome image)
            % so print error message and bail out.
            error(
                "rct_read_ref: Invalid number of color samples!",
                "Image '%s' is not an monochrome image.",
                flist{i}
            );

            return;

        endif;

        % If image height is bigger than reference height set refernce height to
        % image height.
        if(r_height < height)
            r_height = height;

        endif;

        % If image width is bigger than reference width set refernce width to
        % image width.
        if(r_width < width)
            r_width = width;

        endif;

    endfor;

    % Initialize variable for keeping reference maximal optical density value
    % for drawing OD axis.
    od_max = 0;

    % Initialize variable for storing legend items.
    legend_entries{1} = [];

    % Start plotting the profiles.
    % Determine scale of plot abscissas (i.e. pixel position along profiles).
    for i = 1:nitems
        % Determine the center of image
        height = size(images{i})(1);
        width = size(images{i})(2);

        in_c = floor(double(height / 2));
        cross_c = floor(double(width / 2));

        % Determine maximal optical density value along cross plots
        od_max_l = max(max(images{i}(in_c,:)), max(images{i}(:,cross_c)));

        % If maximum OD value is bigger than reference OD value set it as a
        % reference one
        if(od_max < od_max_l)
            od_max = od_max_l;
        endif;

        % Plot cross profile.
        subplot(2, 1, 1);
        hold on;
        if(0 < dpi)
            % Plot positions in milimeters
            mm = 25.4 / dpi;
            plot(([1:width] - cross_c) * mm, images{i}(in_c,:));
            xlabel("Position [mm]");
        else
            plot([1:width] - cross_c, images{i}(in_c,:));
            xlabel("Position [pixels]");
        endif;
        hold off;

        % Plot inline profiles
        subplot(2, 1, 2);
        hold on;
        if(0 < dpi)
            % Plot positions in milimeters
            mm = 25.4 / dpi;
            plot(([1:height] - in_c) * mm, images{i}(:,cross_c));
            xlabel("Position [mm]");
        else
            plot([1:height] - in_c, images{i}(:,cross_c));
            xlabel("Position [pixels]");
        endif;
        hold off;

        % Format legend entry
        legend_entries{i} = sprintf('Profile #%d', i);

    endfor;

    subplot(2, 1, 1);
    hold on;
    plot([0, 0], [0, od_max], color="k");
    ylabel("OD");
    legend(legend_entries);
    title("Cross Profile");
    hold off;

    subplot(2, 1, 2);
    hold on;
    plot([0, 0], [0, od_max], color="k");
    ylabel("OD");
    legend(legend_entries);
    title("Inline Profile");
    hold off;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_gui_test - Function for testing various GUI controls
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function rct_gui_test()

    graphics_toolkit qt;

    % Get available screen size to calculate main window extents
    scr_size = get(0, 'ScreenSize');
    origin_x = floor(scr_size(3) * 0.2);
    origin_y = floor(scr_size(4) * 0.2);
    width = 3 * floor(scr_size(3) * 0.2);
    height = 3 * floor(scr_size(4) * 0.2);

    main_window = figure( ...
        'name', 'RCT GUI Controls Test', ...
        'position', [origin_x, origin_y, width, height] ...
        );

    % Generate a structure of handles to pass to callbacks, and store it.
    handles = guihandles(main_window);

    handles.main_window = main_window;

    handles.level_selector = uicontrol( ...
        main_window, ...
        'style', 'slider', ...
        'units', 'normalized', ...
        'string', 'level', ...
        % 'callback', @callback_func_1, ...
        'value', 0.5, ...
        'position', [0.04 0.04 0.92 0.44] ...
        );

    handles.window_selector = uicontrol( ...
        main_window, ...
        'style', 'slider', ...
        'units', 'normalized', ...
        'string', 'window', ...
        % 'callback', @callback_func_1, ...
        'value', 0.5, ...
        'position', [0.04 0.52 0.92 0.44] ...
        );

endfunction;
