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

rctCurrentDir = "";  % Keeps track of the last directory accessd via rct_read routines
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
    result = NaN;

    % Do basic sanity checking
    if ("uint16" != class(image))
        error(
            "absolute_od: Invalid data type!",
            "Given image data not of type 'uint16'."
        );

        return;

    endif;

    if (2 != size(size(image))(2))
        error(
            "absolute_od: Not a grayscale image!",
            "Given image has more than one color channel."
        );

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
    result = NaN;

    % Do basic sanity checking
    if (("uint16" != class(ref)) || ("uint16" != class(signal)))
        error(
            "relative_od: Invalid data type!",
            "Given image data not of type 'uint16'."
        );

        return;

    endif;

    if ((2 != size(size(ref))(2)) || (2 != size(size(signal))(2)))
        error(
            "realtive_od: Not a grayscale image!",
            "Given image has more than one color channel."
        );

        return;

    endif;

    if ((size(ref)(1) != size(signal)(1)) || (size(ref)(2) != size(signal)(2)))
        error(
            "relative_od: Dimensions mismatch!",
            "Reference and signal images are not of the equal dimensions."
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
% function rct_hist(image, nbins)
% - calculate histogram for given optical density and number of bins
%
% /////////////////////////////////////////////////////////////////////////////

function result = rct_hist(od, nbins=1000)
    result = NaN;

    % Do basic sanity checking
    if ("uint16" != class(od))
        error(
            "rc_hist: Invalid data type!",
            "Given image data not of type 'uint16'."
        );

        return;

    endif;

    if (2 != size(size(od))(2))
        error(
            "rc_hist: Not a grayscale image!",
            "Given image has more than one color channel."
        );

        return;

    endif;

    width  = size(od)(1);
    height = size(od)(2);
    depth = 65535;          % Range of pixel values
    %depth = max(max(od)) - min(min(od));
    bin_width = floor(depth / nbins);

    % Allocate memory for the result
    result = zeros(nbins, 1);

    printf("processing:     ");

    for i = 1:width
        for j = 1:height
            bin = floor(od(i, j)/(bin_width + 1)) + 1;
            result(bin, 1) = result(bin, 1) + 1;

        endfor;

        printf("\b\b\b\b\b%4d%%", uint32((i / width) * 100))

    endfor;

    printf("\b\b\b\b\b Completed!\n");

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function rct_hist_plot(od, nbins)
% - calculate and plot histogram for given optical density and number of bins
%
% /////////////////////////////////////////////////////////////////////////////

function rct_hist_plot(od, nbins=1000)
    % Do basic sanity checking
    if ("uint16" != class(od))
        error(
            "rc_hist: Invalid data type!",
            "Given image data not of type 'uint16'."
        );

        return;

    endif;

    if (2 != size(size(od))(2))
        error(
            "rc_hist: Not a grayscale image!",
            "Given image has more than one color channel."
        );

        return;

    endif;

    h = rc_hist(od, nbins);
    h = h / max(h);  % Normalize histogram for plotting
    bar([1:nbins] * (65535/nbins), h);

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

    printf("\b\b\b\b\b Completed!\n");

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

