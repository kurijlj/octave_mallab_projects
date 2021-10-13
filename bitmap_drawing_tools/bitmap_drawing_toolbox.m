% =============================================================================
% Bitmap Drawing Toolbox - Various set of tools for drawing objects on a bitmap
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
% A set of functions and classes for drawing various objects (dots, circles,
% ellipses, lines, boxes, etc.) on a bitmap.
%
% =============================================================================


% =============================================================================
%
% 2021-10-12 Ljubomir Kurij <ljubomir_kurij@protonmail.com
%
% * bitmap_drawing_toolbox.m: created.
%
% =============================================================================


% =============================================================================
%
% References (this section should be deleted in the release version)
%
% * Applied Medical Image Processing 2nd Ed, CRC Press
% * DICOM is Easy <https://dicomiseasy.blogspot.com/>
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
printf("Bitmap Drawing Toolbox v%s\n\n", kVersionString);


% =============================================================================
%
% Functions declarations
%
% =============================================================================


% /////////////////////////////////////////////////////////////////////////////
%
% function draw_point(canvas, x, y, intensity)
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = draw_point(canvas, x=0, y=0, intensity=255)
    result = canvas;
    % Get canvas extents
    [max_y, max_x] = size(canvas);

    if(x < 0 || x > max_x)
        return;
    endif;

    if(y < 0 || y > max_y)
        return;
    endif;

    canvas(y+1, x+1) = intensity;
    result = canvas;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function draw_box(canvas, x, y, a, b, intensity)
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = draw_box(canvas, x=0, y=0, a=1, b=1, intensity=255)
    result = canvas;
    % Get canvas extents
    [max_y, max_x] = size(canvas);

    x_begin = x; y_begin = y;
    x_end = x + a - 1; y_end = y + b - 1;

    % If given negative edge lengths invert origin and end o fthe box
    if(x_begin > x_end)
        x_begin = x + a - 1;
        x_end = x;
    endif;

    if(y_begin > y_end)
        y_begin = y + b - 1;
        y_end = y;
    endif;

    % If endpoint coordinates are smaller then canavas origin (i.e. < 0) the box
    % is outside the canvas so we can skip drawing it
    if(0 > x_end || 0 > y_end)
        return;
    endif;

    % If origin coordinates are bigger than canvas extents (i.e. > max_x, max_y)
    % the box is outside the canvas so we can skip drawing it.
    if(max_x < x_end || max_y < y_end)
        return;
    endif;

    % Calculate the parts of the box outside the canvas, if any, and calculate
    % the clipping of the box
    if(0 > x_begin) x_begin = 0; endif;
    if(0 > y_begin) y_begin = 0; endif;
    if(max_x < x_end) x_end = max_x; endif;
    if(max_y < y_end) y_end = max_y; endif;

    % Finally we can draw the box
    for j = y_begin:y_end
        for i = x_begin:x_end
            canvas(j+1, i+1) = intensity;
        endfor;
    endfor;

    result = canvas;

endfunction;
