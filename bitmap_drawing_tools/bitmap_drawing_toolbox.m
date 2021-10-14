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
    % Initialize return value
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
% function draw_box_from_edges(canvas, x, y, a, b, intensity)
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = draw_box_from_edges(canvas, x=1, y=1, a=1, b=1, intensity=255)
    % Initialize return value
    result = canvas;

    % Get canvas extents
    [max_y, max_x] = size(canvas);

    x_origin = x; y_origin = y;
    x_end = x + a - 1; y_end = y + b - 1;

    % If given negative edge lengths invert origin and end of the box
    if(x_origin > x_end)
        x_origin = x + a - 1;
        x_end = x;
    endif;

    if(y_origin > y_end)
        y_origin = y + b - 1;
        y_end = y;
    endif;

    % If endpoint coordinates are smaller then canavas origin (i.e. < 0) the box
    % is outside the canvas so we can skip drawing it
    if(1 > x_end || 1 > y_end)
        return;
    endif;

    % If origin coordinates are bigger than canvas extents (i.e. > max_x, max_y)
    % the box is outside the canvas so we can skip drawing it.
    if(max_x < x_origin || max_y < y_origin)
        return;
    endif;

    % Calculate the parts of the box outside the canvas, if any, and calculate
    % the clipping of the box
    if(1 > x_origin) x_origin = 1; endif;
    if(1 > y_origin) y_origin = 1; endif;
    if(max_x < x_end) x_end = max_x; endif;
    if(max_y < y_end) y_end = max_y; endif;

    % Finally we can draw the box
    for j = y_origin:y_end
        for i = x_origin:x_end
            canvas(j, i) = intensity;
        endfor;
    endfor;

    result = canvas;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function draw_box_from_center(canvas, x, y, a, b, intensity)
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = draw_box_from_center(canvas, x=1, y=1, a=1, b=1, intensity=255)
    % Initialize return value
    result = canvas;

    % Basic sanity checking
    if(1 > a || 1 > b) return; endif;

    % Get canvas extents
    [max_y, max_x] = size(canvas);

    % Calculate box exetnts
    half_width = floor(a/2); half_height = floor(b/2);
    x_origin = x - half_width; y_origin = y - half_height;
    x_end = x + half_width; y_end = y + half_height;

    % If endpoint coordinates are smaller then canavas origin (i.e. < 0) the box
    % is outside the canvas so we can skip drawing it
    if(1 > x_end || 1 > y_end)
        return;
    endif;

    % If origin coordinates are bigger than canvas extents (i.e. > max_x, max_y)
    % the box is outside the canvas so we can skip drawing it.
    if(max_x < x_origin || max_y < y_origin)
        return;
    endif;

    % Calculate the parts of the box outside the canvas, if any, and calculate
    % the clipping of the box
    if(1 > x_origin) x_origin = 1; endif;
    if(1 > y_origin) y_origin = 1; endif;
    if(max_x < x_end) x_end = max_x; endif;
    if(max_y < y_end) y_end = max_y; endif;

    % Finally we can draw the box
    for j = y_origin:y_end
        for i = x_origin:x_end
            canvas(j, i) = intensity;
        endfor;
    endfor;

    result = canvas;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function draw_circle_from_center(canvas, x, y, r, intensity)
%
%  TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = draw_circle_from_center(canvas, x=1, y=1, r=1, intensity=255)
    % Initialize return value
    result = canvas;

    % Basic sanity checking
    if(1 > r) return; endif;

    % Get canvas extents
    [max_y, max_x] = size(canvas);

    % Calculate bounding box exetnts
    x_origin = x - r; y_origin = y - r;
    x_end = x + r; y_end = y + r;

    % If endpoint coordinates are smaller then canavas origin (i.e. < 0)
    % the bounding box is outside the canvas so we can skip drawing the circle
    if(1 > x_end || 1 > y_end)
        return;
    endif;

    % If origin coordinates are bigger than canvas extents (i.e. > max_x, max_y)
    % the bounding box is outside the canvas so we can skip drawing the circle
    if(max_x < x_origin || max_y < y_origin)
        return;
    endif;

    % Calculate the parts of the bounding box outside the canvas, if any,
    % and calculate the clipping of the box
    if(1 > x_origin) x_origin = 1; endif;
    if(1 > y_origin) y_origin = 1; endif;
    if(max_x < x_end) x_end = max_x; endif;
    if(max_y < y_end) y_end = max_y; endif;

    % Finally we can draw the circle
    for j = y_origin:y_end
        for i = x_origin:x_end
            % Calculate if point (i, j) is within circle
            %dist = sqrt(power(i-x, 2) + power(j-y, 2));
            dist = sqrt(power(i-x-0.5, 2) + power(j-y-0.5, 2));  % Gives best result (-0.5)
            %if(r >= dist)
            %    canvas(j, i) = intensity;
            %endif;
            if(r >= dist)
                canvas(j, i) = intensity;
            elseif(r < dist && r+1.1414 >= dist)
                d = dist - r;
                %k = log(d/(1-d));
                %k = intensity - intensity/(intensity + (intensity - 1)*exp(-d));
                k = 1 - 1/(1 + exp(-3.0*d));  % Gives best result (3.0*)
                canvas(j, i) = floor(k*intensity);
            endif;
        endfor;
    endfor;

    result = canvas;

endfunction;
