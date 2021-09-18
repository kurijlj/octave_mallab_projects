
% =============================================================================
% Simple Linear ITF - Simple Linear intensity transfer function for
%                     processing DICOM images.
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
% * simple_linear_itf.m: created.
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
% function simple_linear_itf(img)
%
% It takes a raw dicom image and applies the linear intensity transfer function
% to it for on screen display purposes.
%
% /////////////////////////////////////////////////////////////////////////////

function result = simple_linear_itf (img, omega)
    img_size = size(img);
    length   = img_size(1);
    width    = img_size(2);
    rhomin   = min(min(img));
    rhomax   = max(max(img));
    result   = uint8(zeros(length, width));
    result   = uint8((img(:,:) - rhomin) * omega / (rhomax - rhomin));

endfunction;
