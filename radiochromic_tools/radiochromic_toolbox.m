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
% function absolute_od(image) - image to optical density
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

function result = absolute_od(image)
    result = NaN;

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
% function relative_od(ref, signal) - image to optical density
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

function result = relative_od(ref, signal)
    result = NaN;

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
% function od_mean(image, fit)
% - calculate average optical density values
%
% Calculate pixelwise average optical density from optical density matrix,
% using given fit algorithm. Currently only median filter is supported.
%
% /////////////////////////////////////////////////////////////////////////////

function result = od_mean(od, fit="median")
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
% function od_stdev(image, fit)
% - calculate standard deviation of optical density values
%
% Calculate pixelwise standard deviation of optical density values from optical
% density matrix, using given fit algorithm for calculation of pixelwise
% optical density mean. Currently only median filter is supported.
%
% /////////////////////////////////////////////////////////////////////////////

function result = od_stdev(od, fit="median")
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

sample_signal = [4, 6, 10, 12, 8, 6, 5, 5];


% /////////////////////////////////////////////////////////////////////////////
%
% function fht(data) - Forward Haar Transform
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = fht_old(data)
    result = zeros(1, length(data));
    result(1:length(data)/2) ...
        = [data(1:2:length(data)) + data(2:2:length(data))] / sqrt(2);
    result(length(data)/2+1:length(data)) ...
        = [data(1:2:length(data)) - data(2:2:length(data))] / sqrt(2);
endfunction;


function [a, d] = fht(signal)
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
% function iht(data) - Inverse Haar Transform
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = iht(trend, fluctuations)
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
% function cross_plot - plot cross profiles for given image
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function cross_plot(img, x_center=-1, y_center=-1)
    width  = size(img)(2);
    height = size(img)(1);

    % If not supplied calculate the center of image
    if(0 > x_center || width < x_center)
        x_center = floor(double(width / 2));

    endif;

    if(0 > y_center || height < y_center)
        y_center = floor(double(height / 2));

    endif;

    subplot(2, 1, 1);
    plot([1:width], img(y_center,:));
    xlabel("Position [pixels]");
    ylabel("OD");
    title("X Profile");
    subplot(2, 1, 2);
    plot([1:height], img(:,x_center));
    xlabel("Position [pixels]");
    ylabel("OD");
    title("Y Profile");

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function cross_plot_compare - plot cross profiles for given image
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function cross_plot_compare(img1, img2, centers=[-1, -1, -1, -1])
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
    plot([1:width1] - centers(1), ...
        img1(centers(2),:), ...
        [1:width2] - centers(3), ...
        img2(centers(4),:), ...
        [0, 0], ...
        [0, max([max(img1(centers(2),:)), max(img2(centers(4),:))])], ...
        color="k" ...
        );
    legend("Profile #1", "Profile #2");
    xlabel("Position [pixels]");
    ylabel("OD");
    title("Cross Profile");

    % Plot inline profiles
    subplot(2, 1, 2);
    plot([1:height1] - centers(2), ...
        img1(:,centers(1)), ...
        [1:height2] - centers(4), ...
        img2(:,centers(3)), ...
        [0, 0], ...
        [0, max([max(img1(:,centers(1))), max(img2(:,centers(3)))])], ...
        color="k" ...
        );
    legend("Profile #1", "Profile #2");
    xlabel("Position [pixels]");
    ylabel("OD");
    title("Inline Profile");

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function cross_plot_compare - plot cross profiles for given image
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function test_dialog()
    MainFrm = figure ( ...
        'position', [100, 100, 250, 350] ...
        );

    TitleFrm = axes ( ...
      'position', [0, 0.8, 1, 0.2], ...
      'color',    [0.9, 0.95, 1], ...
      'xtick',    [], ...
      'ytick',    [], ...
      'xlim',     [0, 1], ...
      'ylim',     [0, 1] ...
      );

    Title = text (0.05, 0.5, 'Preview Image', 'fontsize', 30);

    ImgFrm = axes ( ...
      'position', [0, 0.2, 1, 0.6], ...
      'xtick',    [], ...
      'ytick',    [], ...
      'xlim',     [0, 1], ...
      'ylim',     [0, 1] ...
      );

    ButtonFrm = uicontrol (MainFrm, ...
      'style',    'pushbutton', ...
      'string',   'OPEN THE IMAGE', ...
      'units',    'normalized', ...
      'position', [0, 0, 1, 0.2] ...
      );

endfunction;
