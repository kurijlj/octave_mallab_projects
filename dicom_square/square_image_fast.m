% =============================================================================
% Square Image Fast - Turn rectangular images into square ones.
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
% 2021-09-15 Ljubomir Kurij <ljubomir_kurij@protonmail.com
%
% * square_image_fast.m: created.
%
% =============================================================================


% =============================================================================
%
% References (this section should be deleted in the release version)
%
% * DICOM is Easy <https://dicomiseasy.blogspot.com/>
%
% =============================================================================


% /////////////////////////////////////////////////////////////////////////////
%
% function square_image_fast(img)
%
% It takes rectangular image (e.g. 128 pixels wide and 256 pixels high) and
% returns a new squred image (256 x 256 pixels) by adding black pixels from
% both sides of the shorter image dimension to match longer image dimension.
%
% /////////////////////////////////////////////////////////////////////////////

function result = square_image_fast (img)
    % First we have to determine data type of the original image, and how many
    % pixels to add to the sides of resulting imageand to wich axis (height or
    % width)
    img_size = size(img);
    length   = uint16(img_size(1));
    width    = uint16(img_size(2));
    if(3 > size(img_size))
        % We have image with only one color channel
        colordim = uint16(0);

    else
        % We have image with more than one color channel
        colordim = uint16(img_size(3));

    endif

    % If width and length are equal we already have a squred image, so we just
    % return a copy of it
    if (length == width)
        result = img(:,:,:);
        return
    endif

    % Set loner axis and calculate offset position of the shorter axis on new
    % image
    offset    = uint16([length, width]);
    max_dim   = uint16(max(offset));
    offset(1) = uint16((max_dim - length)/2);
    offset(2) = uint16((max_dim - width)/2);

    % Allocate memory for new squared image and fill it with black pixels
    data_type = class(img);
    result = make_canvas(max_dim, max_dim, colordim, data_type);
    % result = uint8(zeros(max_dim, max_dim, 3));

    % for y = 1:length
    %     for x = 1:width
    %         if (0 != offset(1))
    %             for i = 1:colordim
    %                 result(y+offset(1),x,i)=img(y,x,i);

    %             endfor;

    %         elseif (0 != offset(2))
    %             for i = 1:colordim
    %                 result(y,x+offset(1),i)=img(y,x,i);

    %             endfor;

    %         else
    %             error(
    %                 "square_image: Image already squared",
    %                 "Trying to make squared image of an already squared image"
    %                 );

    %         endif;

    %     endfor;

    % endfor;

    if (0 != offset(1))
        for y = 1:length
            if(0 < colordim)
                % More than one color channel
                for i = 1:colordim
                    result(y+offset(1),:,i) = img(y,:,i);

                endfor

            else
                % Only one color channel
                result(y+offset(1),:) = img(y,:);

            endif

        endfor

    elseif (0 != offset(2))
        for x = 1:width
            if(0 < colordim)
                % More than one color channel
                for i = 1:colordim
                    result(:,x+offset(2),i) = img(:,x,i);

                endfor

            else
                % Only one color channel
                result(:,x+offset(2)) = img(:,x);

            endif

        endfor

    else
        error(
            "square_image_fast: Image already squared",
            "Trying to make squared image of an already squared image"
            );

    endif

endfunction;


function result = make_canvas(length, width, colordim, data_type)
    % Do some baseic sanity checking first
    if((length >= 1) & (width >= 1))
        switch (data_type)
            case "uint8"
                if(0 < colordim)
                    result = uint8(zeros(length, width, colordim));

                else
                    result = uint8(zeros(length, width));

                endif

                return

            case "uint16"
                if(0 < colordim)
                    result = uint16(zeros(length, width, colordim));

                else
                    result = uint16(zeros(length, width));

                endif

                return

            case "uint32"
                if(0 < colordim)
                    result = uint32(zeros(length, width, colordim));

                else
                    result = uint32(zeros(length, width));

                endif

                return

            case "int8"
                if(0 < colordim)
                    result = int8(zeros(length, width, colordim));

                else
                    result = int8(zeros(length, width));

                endif

                return

            case "int16"
                if(0 < colordim)
                    result = int16(zeros(length, width, colordim));

                else
                    result = int16(zeros(length, width));

                endif

                return

            case "int32"
                if(0 < colordim)
                    result = int32(zeros(length, width, colordim));

                else
                    result = int32(zeros(length, width));

                endif

                return

            otherwise
                error(
                    "make_canvas: Unsupported pixel type",
                    "Image pixel data type not supported"
                    );

        endswitch;

    else
        error(
            "make_canvas: Canvas too small",
            "Requested cnavs size is too small. Cnvas must be at least 1x1x1."
            );
    endif;

endfunction;
