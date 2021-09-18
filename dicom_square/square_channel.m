% DICOM_Square.m - Turn rectangular DICOM images to squared.
% 
% Copyright (C) 2016, 2021 Ljubomir Kurij <ljubomir_kurij@protonmail.com>
% 
% This file is part of  DICOM Square application.
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

function result = square_channel (channel)
  offset = [uint16(size(channel)(1)), uint16(size(channel)(2))];
  max_dim = uint16(max(offset));
  offset(1) = uint16((max_dim - offset(1))/2);
  offset(2) = uint16((max_dim - offset(2))/2);
  result = zeros(max_dim, max_dim);

  for y = 1:uint16(size(channel)(1))
    for x = 1:uint16(size(channel)(2))
      if (0 != offset(1))
        result(y+offset(1),x)=channel(y,x);
      elseif (0 != offset(2))
        result(y,x+offset(2))=channel(y,x);
      else
        result = channel(:,:);
      endif
    endfor
  endfor
endfunction
