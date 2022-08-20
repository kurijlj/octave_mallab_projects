% WriteLog.m - Error logging facility for DICOM Sqare application.
% 
% Copyright (C) 2016 Ljubomir Kurij <kurijlj@gmail.com>
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

% Error logging facility for DICOM_Square application. To make it work properly
% one have to initialize error logging engine by calling WriteLog ('OELF')
% before first actual WriteLog(...) call. To release error logging engine call
% WriteLOG ('CELF').
%

function WriteLog (Data)

  persistent logdir;
  persistent logfile;
  persistent FID;

  % Open the file
  if strcmp (Data, 'OELF')

    logdir = '';
    logfile = 'DICOMSquareErrorLog.txt';

    FID = fopen (fullfile(logdir, logfile), 'at');

    if FID < 0
       error (strcat (['WriteLog: Cannot open log file "', logdir, '\', logfile, '".']));
    end
    return;

  elseif strcmp (Data, 'CELF')

    fclose (FID);
    FID = -1;
    return;

  end

  when = datestr (now, 'yyyy-mm-dd HH:MM:SS');
  fprintf (FID, '%s %s\n', when, Data);

end
