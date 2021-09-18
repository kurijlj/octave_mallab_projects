% =============================================================================
% Image Histogram - Simple histogram calculation algorithm for DICOM images.
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
% 2021-09-18 Ljubomir Kurij <ljubomir_kurij@protonmail.com
%
% * imhist.m: created.
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
% function imhist(img, bins)
%
% It takes a raw dicom image and applies the linear window level transfer
% function to it for on screen display purposes.
%
% /////////////////////////////////////////////////////////////////////////////

function result = imhist (img)
    height      = size(img)(1);
    width       = size(img)(2);
    bins        = NaN;
    range       = NaN;
    depth   = class(img);

    if(isequal("uint8", depth) || isequal("int8", depth))
        bins  = 16;
        range = power(2,8);

    elseif(isequal("uint16", depth) || isequal("int16", depth))
        bins  = 32;
        range = power(2,16);

    else
        error(
            "imhist: Unsuported bit depth",
            "Pixel bit depth unsupported"
            );

    endif;

    result = zeros(bins,1);
    for j = 1:height
        for i = 1:width
            rho = img(j,i);
            bin = floor(rho*(bins + 1)/range) + 1;
            result(bin,1) = result(bin,1) + 1;

        end;

    end;

endfunction;
