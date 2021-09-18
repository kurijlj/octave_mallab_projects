% DICOM_Square.m - Turn rectangular DICOM images to squared.
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




% Main:
% 
% Application main function. It calls all other functions needed to do resizing.
% 
function Main ()

    % Start with a clean slate
    clear all; % Remove all items from workspace and free system memory
    close all; % Delete all figures whose handles are not hidden
    clc;       % Clear command window

	%# Initialize error logging engine. Mind that one have to release engine
	%# memory at the end of a script.
	WriteLog ('OELF');

	%CWD = pwd;
    CWD = 'C:\Users\Physicist\Documents\MATLAB';
	SourceDir = uigetdir (CWD, 'Source Folder');
	if ~SourceDir
		level = 'MESSAGE: ';
		script = 'DICOM_Square.m - ';
		message = 'Failed to open source directory!';
		WriteLog ([level script message]);
		disp ([level script message]);
		return;
	end
	DestinationDir = uigetdir (CWD, 'Destination Folder');
	if ~DestinationDir
		level = 'MESSAGE: ';
		script = 'DICOM_Square.m - ';
		message = 'Failed to open destination directory!';
		WriteLog ([level script message]);
		disp ([level script message]);
		return;
	end

	RecursiveCopy (SourceDir, DestinationDir);

	% Close error log engine.
	WriteLog ('CELF');

end




% RecursiveCopy:
% @SD: String representing full path to source directory for DICOM images
% @DD: String representing full path to destination directory for DICOM images
% 
% Recursive function that traverses @SD and copies subdirectories and modified
% DICOM images to @DD. To modify DICOM images it calls DicomSquare() function.
% 
% Returns: error on filure to create subdirectory in @DD.
% 
function cpyStatus = RecursiveCopy (SD, DD)

	SDTREE  = dir (SD);              %# Get the data for the current directory
	SDINDEX = [SDTREE.isdir];       %# Find the index for directories
	SFS = {SDTREE(~SDINDEX).name};  %# Get a list of the files

	if ~isempty (SFS)
		SFSFP = SFS;            %# Note really necessary step but makes
	                                %# code more readable. Stores list of
	                                %the files with full pths.
		SFSFP = cellfun (@(x) fullfile (SD, x),...  %# Prepend path to files.
			SFS, 'UniformOutput', false);
		DFSFP = cellfun (@(x) fullfile (DD, x),...  %# Make destination files
			SFS, 'UniformOutput', false);       %# list and prepend path to files.
		for FINDEX = [SFSFP; DFSFP]
			%disp (cell2mat (FINDEX(1)));
			%disp (cell2mat (FINDEX(2)));
			DicomSquare (cell2mat (FINDEX(1)), cell2mat (FINDEX(2)));
		end
	end

	SDSUBDIRS = {SDTREE(SDINDEX).name};              %# Get a list of the subdirectories.
	validIndex = ~ismember (SDSUBDIRS, {'.','..'});  %# Find index of subdirectories.
	                                                 %# that are not '.' or '..'
	for DINDEX = find (validIndex)                   %# Loop over valid subdirectories.
		if ~SDSUBDIRS{DINDEX}
			return;
		end
		SDNEXT = fullfile (SD, SDSUBDIRS{DINDEX});  %# Get the source subdirectory path.
		DDNEXT = fullfile (DD, SDSUBDIRS{DINDEX});  %# Get the destination subdirectory path.
		level = 'MESSAGE: ';
		script = 'DICOM_Square.m - ';
		message =['Creating directory: ' DDNEXT];
		WriteLog ([level script message]);
		ES = mkdir (fullfile (DD, SDSUBDIRS{DINDEX}));
		cpyStatus = ES(1);
		if ~cpyStatus
			scr = 'RecursiveFileCopy.m - ';
			WriteLog ([ES(3) scr ES(2)]);
			disp ([ES(3) scr ES(2)]);
			return;
		end
		RecursiveCopy (SDNEXT, DDNEXT);         %# Recursively call RecursiveCopy.
	end

end




% DicomSquare:
% @IF: Input file for DICOM data
% @DF: Destination file for modified DICOM data
% 
% For given path to DICOM image @IF it determinates image size and adds pixels
% where needed to make image squared and saves modified image into file
% designated with @DF. In a case of already sqared image it does a simple file
% copy.
% 
function rszStatus = DicomSquare (IF, DF)

	% Try to read DICOIM image
	try
		MD = dicominfo (IF);
	catch ME
		%error (ME.message);
		level = 'ERROR: ';
		script = 'DICOM_Square.m - ';
		message = ['Failed to retrieve DICOM info from file: ' IF ' - "' ME.message '"'];
		WriteLog ([level script message]);
		return;
	end
	try
		I = dicomread (MD);
	catch ME
		%error (ME.message);
		level = 'ERROR: ';
		script = 'DICOM_Square.m - ';
		message = ['Failed to read DICOM image from file: ' IF ' - "' ME.message '"'];
		WriteLog ([level script message]);
		return;
	end

	IE = I;
	dmI = size (I);
	level = 'MESSAGE: ';
	script = 'DICOM_Square.m - ';
	message = sprintf ('Reading DICOM image: %s - size: %dx%d', IF, dmI(1), dmI(2));
	WriteLog ([level script message]);
	disp ([level script message]);

	if dmI(1) > dmI(2)                      % We have to add columns.
		b = dmI(1); s = dmI(2);         % Set dimensions for bigger and smaller
		                                % side.
		nb = 0; ns = 0; db = 0; ds = 0; % Initialize new bigger, new smaller,
		                                % difference of bigger sides,
		                                % difference of smaller sides.

		% If size of bigger side is not dividable by two, assign it's size
		% incremented by one to new bigger side variable. We also have to make
		% bigger side one pixel larger later so we could get squared image, of
		% which we make notion with setting db to one.
		if 0 ~= mod(b, 2)
			nb = b + 1;
			db = 1;
		else
			nb = b;
		end

		% If size of smaller side is not dividable by two, assign it's size
		% incremented by one to new smaller side variable.
		if 0 ~= mod(s, 2)
			ns = s + 1;
		else
			ns = s;
		end

		% Set how much is half difference of sides of rectangular image.
		ds = (nb - ns) / 2;

		% Resize image's bigger side to even number of pixels.
		if 0 ~= db
			IE = wextend ('ar', 'zpd', I, db);
		end

		% Resize image to sqare dimensions (add black pixels).
		IE = wextend ('ac', 'zpd', I, ds);

	elseif dmI(2) > dmI(1)                  % We have to add rows.
		b = dmI(2); s = dmI(1);         % Set dimensions for bigger and smaller
		                                % side.
		nb = 0; ns = 0; db = 0; ds = 0; % Initialize new bigger, new smaller,
		                                % difference of bigger sides,
		                                % difference of smaller sides.


		% If size of bigger side is not dividable by two, assign it's size
		% incremented by one to new bigger side variable. We also have to make
		% bigger side one pixel larger later so we could get squared image, of
		% which we make notion with setting db to one.
		if 0 ~= mod(b, 2)
			nb = b + 1;
			db = 1;
		else
			nb = b;
		end


		% If size of smaller side is not dividable by two, assign it's size
		% incremented by one to new smaller side variable.
		if 0 ~= mod(s, 2)
			ns = s + 1;
		else
			ns = s;
		end

		% Set how much is half difference of sides of rectangular image.
		ds = (nb - ns) / 2;

		% Resize image's bigger side to even number of pixels.
		if 0 ~= db
			IE = wextend ('ac', 'zpd', I, db);
		end

		% Resize image to sqare dimensions (add black pixels).
		IE = wextend ('ar', 'zpd', I, ds);

	end

	dmIE = size (IE);
	level = 'MESSAGE: ';
	script = 'DICOM_Square.m - ';
	message = sprintf ('DICOM image resized: %s - new size: %dx%d', IF, dmIE(1), dmIE(2));
	WriteLog ([level script message]);
	disp ([level script message]);

	%figure, imshow (I, []);
	%figure, imshow (IE, []);
	level = 'MESSAGE: ';
	script = 'DICOM_Square.m - ';
	message = ['Writing DICOM image to file: ' DF];
	WriteLog ([level script message]);
	disp ([level script message]);
	try
		dicomwrite (IE, DF, MD);
	catch ME
		%error (ME.message);
		level = 'ERROR: ';
		script = 'DICOM_Square.m - ';
		message = ['Failed to write DICOM image to file: ' DF ' - "' ME.message '"'];
		WriteLog ([level script message]);
		return;
	end
	
end
