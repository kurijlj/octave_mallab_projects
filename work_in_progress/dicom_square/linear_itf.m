% =============================================================================
% Linear ITF - Linear intensity transfer function for converting DICOM images.
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
% function linear_itf(img)
%
% It takes a raw dicom image and applies the linear intensity transfer function
% to it for on screen display purposes.
%
% /////////////////////////////////////////////////////////////////////////////

function result = linear_itf (img, omega)
    img_size = size(img);
    length   = img_size(1);
    width    = img_size(2);

    data_type = class(img);

    result = NaN;

    switch (data_type)
        case "uint8"
            rhomin = uint8(min(min(img)));
            rhomax = uint8(max(max(img)));
            omega  = uint8(omega);
            result = uint8(zeros(length, width));
            result = uint8((img(:,:) - rhomin) * omega / (rhomax - rhomin));
            return;

        case "uint16"
            rhomin = uint16(min(min(img)));
            rhomax = uint16(max(max(img)));
            omega  = uint16(omega);
            result = uint16(zeros(length, width));
            result = uint16((img(:,:) - rhomin) * omega / (rhomax - rhomin));
            return;

        case "uint32"
            rhomin = uint32(min(min(img)));
            rhomax = uint32(max(max(img)));
            omega  = uint32(omega);
            result = uint32(zeros(length, width));
            result = uint32((img(:,:) - rhomin) * omega / (rhomax - rhomin));
            return;

        case "int8"
            rhomin = int8(min(min(img)));
            rhomax = int8(max(max(img)));
            omega  = int8(omega);
            result = int8(zeros(length, width));
            result = int8((img(:,:) - rhomin) * omega / (rhomax - rhomin));
            return;

        case "int16"
            rhomin = int16(min(min(img)));
            rhomax = int16(max(max(img)));
            omega  = int16(omega);
            result = int16(zeros(length, width));
            result = int16((img(:,:) - rhomin) * omega / (rhomax - rhomin));
            return;

        case "int32"
            rhomin = int32(min(min(img)));
            rhomax = int32(max(max(img)));
            omega  = int32(omega);
            result = int32(zeros(length, width));
            result = int32((img(:,:) - rhomin) * omega / (rhomax - rhomin));
            return;

        otherwise
            error(
                "linear_itf: Unsupported pixel type",
                "Image pixel data type not supported"
                );

    endswitch;

endfunction;
