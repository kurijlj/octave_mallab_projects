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
% function optical_density(image) - image to optical density
%
% Convert 16 bit grayscale image to optical density using formula:
%
%       OD = log10(I0/I)
%
% Input image must be single channel grayscale image of type uint16 (16 bits).
% Otherwise function returns NaN and reports error.
%
% /////////////////////////////////////////////////////////////////////////////

function result = optical_density(image)
    if ("uint16" != class(image))
        error(
            "optical_density: Invalid data type!",
            "Given image data not of type 'uint16'."
        );

    endif;

    if (2 != size(size(image))(2))
        error(
            "optical_density: Not a grayscale image!",
            "Given image has more than one color channel."
        );

    endif;

    width  = size(image)(1);
    height = size(image)(2);

    % Allocate memory for the result
    result = zeros(width, height);

    for i = 1:width
        for j = 1:height
            result(i,j) = log10(65535.0 / double(image(i,j)));

        endfor;

    endfor;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function optical_density_mean(image, fit)
% - calculate average optical density values
%
% Calculate pixelwise average optical density from optical density matrix,
% using given fit algorithm. Currently only median filter is supported.
%
% /////////////////////////////////////////////////////////////////////////////

function result = optical_density_mean(od, fit="median")
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
% function optical_density_std(image, fit)
% - calculate standard deviation of optical density values
%
% Calculate pixelwise standard deviation of optical density values from optical
% density matrix, using given fit algorithm for calculation of pixelwise
% optical density mean. Currently only median filter is supported.
%
% /////////////////////////////////////////////////////////////////////////////

function result = optical_density_std(od, fit="median")
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
    result(1:length(data)/2) = [data(1:2:length(data)) + data(2:2:length(data))] / sqrt(2);
    result(length(data)/2+1:length(data)) = [data(1:2:length(data)) - data(2:2:length(data))] / sqrt(2);
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
