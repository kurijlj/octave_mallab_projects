classdef Scanset
%% -----------------------------------------------------------------------------
%%
%% Class 'Scanset':
%%
%% -----------------------------------------------------------------------------
%
%% Description:
%       Ordered set of data scans (film scans).
%
%       Invoke class constructor with:
%           -- sequence of strings representing paths to equivalent 'TIFF' scans
%              (see help on Scan class for details);
%           -- sequence of a 2D or a 3D matrix representing scan pixel data;
%           -- sequence of equivalent Scan instances;
%           -- other instance of the Scanset class (yield a copy)
%
%       See help on the Scan class for details on minimum required scan size.
%
%       Two Scanset instances are equivalent if their pixel data is the same
%       size.
%
%       The Scanset object are equivalent if their opixel data is of the same
%       size.
%
%       The Scanset object is valid if there was no warnings generated
%       (Scanset.ws = {}) during object initialization. The validity of the
%       Scanset object can be checked calling 'is_valid' method.
%
%       Multiple property-value pairs may be specified for the Scanset object,
%       but they must appear in pairs.
%
%       Properties of 'Scanset' objects:
%
%       title: string, def. 'Signal scanset'
%           A string containing a title describing scanned data.
%
%       DateOfIrradiation: serial date number (see: datenum), def. NaN
%           Serial date number representing the date of irradiation of the
%           scanset, if applicable. The date of irradiation must be no older
%           than 01-Jan-2022.
%
%       DateOfScan: serial date number (see: datenum), def. current date, or
%               scan modification date
%           Serial date number representing the date when the pixel data of the
%           scanset were generated. If pixel data are read from the file, the
%           date of scan is automatically set from the file metadata.
%           Otherwise, it is set as the current date. The date of the scan
%           must be no older than 01-Jan-2022.
%
%       Type: 'Background'|'ZeroLight'|{'Signal'}
%           Defines the type of scan. This property defines how the object will
%           be used for the calculation of the optical density of the
%           measurement.
%
%       PixelDataSmoothing: PixelDataSmotthing, def. PixelDataSmoothing()
%           Data smoothing algorithm and parameters of the smoothing algorithm
%           to be used on each individual scan before averasging pixel data.
%           By default no smoothing is applied to the pixel data. See help on
%           PixelDataSmoothing class for details.
%
%
%% Public methods:
%
%       - Scanset(varargin):
%
%       - disp():
%
%       - str_rep():
%
%       - ascell():
%
%       - isequivalent(other):
%
%       - isequal(other):
%
%       - size():
%
%       - is_valid():
%
%       - pixel_data(pds): 
%
% -----------------------------------------------------------------------------

    properties (SetAccess = private, GetAccess = public)
%% -----------------------------------------------------------------------------
%%
%% Properties section
%%
%% -----------------------------------------------------------------------------
        % Scanset title (unique ID)
        title  = 'Unknown';
        % List of files defining the scanset (if applicable)
        files  = {};
        % Date of irradiation (if applicable)
        dtofir = NaN;
        % Date of scanning (mandatory)
        dtofsc = NaN;
        % Type (mandatory)
        type   = 'Signal';
        % Data smoothing (mandatory)
        pds    = NaN;
        % Pixel data
        pd     = [];
        % Pixelwise standard deviation
        pwsd   = [];
        % List of warnings generated during the initialization of the object
        ws     = {};

    endproperties;


    methods (Access = public)
%% -----------------------------------------------------------------------------
%%
%% Public methods section
%%
%% -----------------------------------------------------------------------------

        function ss = Scanset(varargin)
% -----------------------------------------------------------------------------
%
% Method 'Scanset':
%
% Use:
%       -- ss = Scanset(tif1, tif2, ...)
%       -- ss = Scanset(pd1, pd2, ...)
%       -- ss = Scanset(sc1, sc2, ...)
%       -- ss = Scanset(..., "PROPERTY", VALUE, ...)
%       -- ss = Scanset(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------

        endfunction;  % Scanset(varargin)


        function disp(ss)
% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- ss.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------

        endfunction;  % disp()


        function result = str_rep(ss)
% -----------------------------------------------------------------------------
%
% Method 'str_rep':
%
% Use:
%       -- result = ds.str_rep()
%
% Description:
%          A convenience method that is used to format string representation of
%          the Scanset instance.
%
% -----------------------------------------------------------------------------

        endfunction;  % str_rep()


        function css = cellarray(ss)
% -----------------------------------------------------------------------------
%
% Method 'ascell':
%
% Use:
%       -- css = ss.ascell()
%
% Description:
%          Return film object structure as cell array.
%
% -----------------------------------------------------------------------------

        endfunction;  % ascell()


        function result = isequivalent(ss, other)
% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = ss.isequivalent(other)
%
% Description:
%          Return whether or not two Scanset instances are equivalent. Two
%          instances are equivalent if their pixel data are of the same size.
%          Pixel values must be loaded, otherwise error is thrown.
% -----------------------------------------------------------------------------

        endfunction;  % isequivalent()

        function result = isequal(ss, other)
% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = ss.isequal(other)
%
% Description:
%          Return whether or not two 'Scanset' instances are equal. Two
%          instances are equal if all of their fields have identical values.
%          Pixel values must be loaded, otherwise error is thrown.
%
% -----------------------------------------------------------------------------

        endfunction;  % isequal()

    endmethods;  % Public methods

endclassdef;  % Scanset
