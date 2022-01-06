% =============================================================================
% Radiobiology Toolbox - Set of tools for radiobiology modeling
%
%  Copyright (C) 2022 Ljubomir Kurij <ljubomir_kurij@protonmail.com>
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
% Description
% ----------------------------------------------------------------------------
%
% A set of functions and classes for modeling radiobiological effects of
% radiotherapy treatments
%
% =============================================================================


% =============================================================================
%
% 2022-01-05 Ljubomir Kurij <ljubomir_kurij@protonmail.com
%
% * radiobiology_toolbox.m: created.
%
% =============================================================================


% =============================================================================
%
% References (this section should be deleted in the release version)
%
%
% =============================================================================


% =============================================================================
%
% Script header
%
% =============================================================================

% We put dummy expression into scripts header to prevent Octave command line
% enivornment to interpret it as a simple function file

kVersionString = "0.1";
printf("Radiobiology Toolbox v%s\n\n", kVersionString);


% =============================================================================
%
% Module load section
%
% =============================================================================


% =============================================================================
%
% Functions declarations
%
% =============================================================================

% /////////////////////////////////////////////////////////////////////////////
%
% function dvh_cuml_to_diff(dvh) - Convert cumulative DVH to differential one
%
% TODO: Put function description here
%
% /////////////////////////////////////////////////////////////////////////////

function result = dvh_cml_to_diff(cml_dvh)
    [nbins, ncols] = size(cml_dvh);

    % The matrix must have a minimum of two rows, and both columns must be of
    % equal length.
    if( 2 ~= ncols)
        error("dvh_cml_to_diff: Invalid number of columns (%d ~= 2).", ncols);
        return;
    endif

    if( 2 > nbins)
        error("dvh_cml_to_diff: Too few data points (< 2).");
        return;
    endif

    % Allocate memory for the resulting data matrix
    result = zeros(nbins-1, ncols);

    for i = 2:nbins
        result(i-1, 1) = cml_dvh(i-1, 1) + (cml_dvh(i, 1) - cml_dvh(i-1, 1))/2;
        if(0 >= (cml_dvh(i, 1) - result(i-1, 1)))
            error("dvh_cml_to_diff: DVH column 1, row %d <= column 1, row %d", ...
                i, i-1);
            return;

        endif;

        result(i-1, 2) = cml_dvh(i-1, 2) - cml_dvh(i, 2);
        if(0 > result(i-1, 2))
            error("dvh_cml_to_diff: DVH column 2, row %d > column 2, row %d", ...
                i, i-1);
            return;

        endif;
    endfor;

endfunction;
