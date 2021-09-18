% =============================================================================
% Linear WL - Linear window level function for on screen display of
%             the DICOM images
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
% 2021-09-16 Ljubomir Kurij <ljubomir_kurij@protonmail.com
%
% * linear_itf.m: created.
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
% function linear_wl(img)
%
% It takes a raw dicom image and applies the linear window level transfer
% function to it for on screen display purposes.
%
% /////////////////////////////////////////////////////////////////////////////

function result = linear_wl (img, level, window)
    img_size = size(img);
    length   = img_size(1);
    width    = img_size(2);

    data_type = class(img);

    result = NaN;

    switch (data_type)
        case "uint8"
            rho_max = power(2,8) - 1;
            tf = uint8(zeros(rho_max + 1, 1));
            half_window = window / 2;
            x1 = level - half_window;
            y1 = 0;
            x2 = level + half_window;
            y2 = rho_max;
            line_params = uint8(line_eq(x1, y1, x2, y2));
            for rho = 1:(rho_max + 1)
                tff = uint8(line_params.a*(rho - 1) + line_params.b);
                if((tff >= 0) & (tff <= rho_max))
                    tf(rho + 1, 1) = uint8(tff);
                elseif(tff < 0)
                    tf(rho + 1, 1) = uint8(0);
                else
                    tf(rho + 1, 1) = uint8(rho_max);
                endif
            endfor;
            result = uint8(zeros(length, width));
            return;

        case "uint16"
            result = uint16(zeros(length, width));
            return;

        case "uint32"
            result = uint32(zeros(length, width));
            return;

        case "int8"
            result = int8(zeros(length, width));
            return;

        case "int16"
            result = int16(zeros(length, width));
            return;

        case "int32"
            result = int32(zeros(length, width));
            return;

        otherwise
            error(
                "linear_itf: Unsupported pixel type",
                "Image pixel data type not supported"
                );

    endswitch;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function line_eq(p1, p2)
%
% It takes two points in a plane (p1 and p2) and calculate parameters of the
% line passing through given points (a and b, a beeing slope and b beeing
% point where line intersects y axis. Points are passed as structure p#.x and
% p#.y. Result is returnd as structure result.a and result.b.
%
% /////////////////////////////////////////////////////////////////////////////

function result = line_eq(x1, y1, x2, y2)
    result.a = (y2 - y1) / (x2 - x1)
    result.b = (x2*y1 - x1*y2) / (x2 - x1)
endfunction
