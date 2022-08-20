% =============================================================================
% Image Histogram - Simple histogram calculation algorithm for 8 bit depth and
%                   16 bit depth images.
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
% function imhist(img)
%
% It takes a raw dicom image and applies the linear window level transfer
% function to it for on screen display purposes.
%
% /////////////////////////////////////////////////////////////////////////////

function result = imhist (img)
    height      = size(img)(1);
    width       = size(img)(2);
    samples     = 1;
    bins        = NaN;
    depth       = class(img);

    if(2 < size(size(img))(2))
        samples = size(img)(3);
    endif;

    switch(depth)
        case "uint8"
            bins = 16;

        case "uint16"
            bins = 32;

        otherwise
            error(
                "imhsit: Unsupported depth",
                "Pixel depth unsupported"
                );

    endswitch;

    result = zeros(bins,samples);

    for j = 1:height
        for i = 1:width
            if(1 < samples)
                for k = 1:samples
                    rho = img(j,i,k);
                    bin = floor(rho/(bins + 1)) + 1;
                    result(bin,k) = result(bin,k) + 1;
                endfor;
            else
                rho = img(j,i);
                bin = floor(rho/(bins + 1)) + 1;
                result(bin,1) = result(bin,1) + 1;

            endif;

        end;

    end;

endfunction;
