% =============================================================================
% Linear Window - Linear intensity transform function for windowing DICOM images
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
% 2021-09-17 Ljubomir Kurij <ljubomir_kurij@protonmail.com
%
% * linear_window.m: created.
%
% =============================================================================


% =============================================================================
%
% References (this section should be deleted in the release version)
%
% * Applied Medical Image Processing 2nd Ed, CRC Press
% * DICOM is Easy <https://dicomiseasy.blogspot.com/>
%
% =============================================================================


% /////////////////////////////////////////////////////////////////////////////
%
% function linear_window(img)
%
% It takes a raw dicom image and applies the linear window level transfer
% function to it for on screen display purposes.
%
% /////////////////////////////////////////////////////////////////////////////

function result = linear_window (img, window, level)
    img_size = size(img);
    length   = img_size(1);
    width    = img_size(2);

    data_type = class(img);

    result = NaN;

    switch (data_type)
        case "uint8"
            result = uint8(zeros(length, width));
            tf = linear_window_tf("uint8", window, level);
            rho_min = 0;
            for j = 1:length
                for i = 1:width
                    result(j,i) = tf(img(j,i) - rho_min + 1, 1);
                endfor;
            endfor;
            return;

        case "uint16"
            result = uint8(zeros(length, width));
            tf = linear_window_tf("uint16", window, level);
            rho_min = 0;
            for j = 1:length
                for i = 1:width
                    result(j,i) = tf(img(j,i) - rho_min + 1, 1);
                endfor;
            endfor;
            return;

        case "int8"
            result = uint8(zeros(length, width));
            tf = linear_window_tf("int8", window, level);
            rho_min = -(power(2,8) / 2);
            for j = 1:length
                for i = 1:width
                    result(j,i) = tf(img(j,i) - rho_min + 1, 1);
                endfor;
            endfor;
            return;

        case "int16"
            result = uint8(zeros(length, width));
            tf = linear_window_tf("int16", window, level);
            rho_min = -(power(2,16) / 2);
            for j = 1:length
                for i = 1:width
                    result(j,i) = tf(img(j,i) - rho_min + 1, 1);
                endfor;
            endfor;
            return;

        otherwise
            error(
                "linear_window: Unsupported pixel type",
                "Image pixel data type not supported"
                );

    endswitch;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function linear_window_tf(bit_depth, window, level)
%
% TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = linear_window_tf (bit_depth, window, level)
    switch (bit_depth)
        case "uint8"
            rho_min = 0;
            rho_max = power(2, 8) - 1;

        case "uint16"
            rho_min = 0;
            rho_max = power(2, 16) - 1;

        case "int8"
            rho_min = -(power(2, 8) / 2);
            rho_max = (power(2, 8) / 2) - 1;

        case "int16"
            rho_min = -(power(2, 16) / 2);
            rho_max = (power(2, 16) / 2) - 1;

        otherwise
            error(
                "linear_window_tf: Unsupported pixel type",
                "Image pixel data type not supported"
                );

    endswitch;

    min_pixel_val = 0;
    max_pixel_val = 255;
    range        = rho_max - rho_min + 1;
    window_lower = level - window / 2 - rho_min;
    window_upper = level + window / 2 - rho_min;

    if((rho_min > (level - window / 2))
        || (rho_max < (level + window / 2)))
        % printf(
        %     "rho_min: %d\nrho_max: %d\nwindow_lower: %d\nwindow_upper: %d\n",
        %     rho_min, rho_max, (level - window / 2), window_upper
        %     );
        error(
            "linear_window_tf: W/L out of range",
            "Window / Level is out of range"
            );
    endif;

    % Because it holds pixel values "result" must be of type "uint8"
    result = uint8(zeros((rho_max - rho_min) + 1, 1));

    for i = 1:range
        if(i <= window_lower)
            result(i,1) = min_pixel_val;
        elseif(i >= window_upper)
            result(i,1) = max_pixel_val;
        else
            result(i,1) = uint8(
                (max_pixel_val / window) * (i - window_lower)
                );
        endif;
    endfor;

endfunction;

