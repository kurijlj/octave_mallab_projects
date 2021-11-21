% =============================================================================
% Film Focus Precision QC - GUI app for radiation field focus precision QC
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
% Description
% ----------------------------------------------------------------------------
%
% GUI app for quality control of radiation field focus precision using
% radiochromic films
%
% =============================================================================


% =============================================================================
%
% 2021-11-20 Ljubomir Kurij <ljubomir_kurij@protonmail.com
%
% * film_focus_precision_qc.m: created.
%
% =============================================================================


% =============================================================================
%
% References (this section should be deleted in the release version)
%
% * Applied Medical Image Processing 2nd Ed, CRC Press
% * GNU Octave Uicontrols
%   <https://wiki.octave.org/Uicontrols>
%
% =============================================================================


% =============================================================================
%
% Script header
%
% =============================================================================

% We put dummy expression into scripts header to prevent Octave command line
% enivornment to interpret it as a simple function file
close all;
clear app;

kVersionString = "0.1";
printf("Film Focus Precision QC v%s\n\n", kVersionString);


% =============================================================================
%
% Module load section
%
% =============================================================================

pkg load image;


% =============================================================================
%
% Graphics toolkit load section
%
% =============================================================================

graphics_toolkit qt;

app.figure = figure ("name", "Film Focus Precision QC", ...
    "position", [250, 300, 640, 480] ...
    );

app.view = axes ( ...
    "xtick", [], ...
    "ytick", [], ...
    "xlim", [0, 1], ...
    "ylim", [0, 1], ...
    "position", [0.01, 0.17, 0.4, 0.5] ...
    );

app.ref_label = uicontrol ( ...
    "style", "text", ...
    "units", "normalized", ...
    "string", "None", ...
    "horizontalalignment", "center", ...
    "position", [0.01, 0.07, 0.4, 0.05] ...
    );

app.ref_select = uicontrol ( ...
    app.figure, ...
    "style", "pushbutton", ...
    "units", "normalized", ...
    "string", "Select Reference", ...
    "position", [0.01, 0.01, 0.4, 0.05], ...
    "callback", { @select_ref, app } ...
    );

setappdata(app, "current_dir", ".");
setappdata(app, "ref_fname", "");
setappdata(app, "ref_R", NaN);
setappdata(app, "signal_fname", "");
setappdata(app, "signal_R", NaN);
setappdata(app, "signal_od", NaN);


function select_ref (calling_obj_handle, eventdata, app)
    [fname, fpath] = uigetfile( ...
        {"*.tif", "Supported Scan Formats"}, ...
        "Reference Scan", ...
        fullfile(getappdata(app, "current_dir"), filesep()) ...
        );
    setappdata(app, "current_dir", fpath);
    setappdata(app, "ref_fname", fname);
    printf( ...
        "Loading image: %s\n", ...
        fullfile( ...
            getappdata(app, "current_dir"), ...
            getappdata(app, "ref_fname") ...
            ) ...
        );
    img = imread(fullfile( ...
        getappdata("current_dir"), ...
        getappdata("ref_fname") ...
        ));
    steappdata("ref_R", img(:,:,1));
    axes(app.view);
    imshow(img, []);
    % axis image off;
    set(app.ref_label, "string", fname);

endfunction;


% =============================================================================
%
% Functions declarations
%
% =============================================================================

% /////////////////////////////////////////////////////////////////////////////
%
% function <function_name> - TODO:short function description
%
% TODO: full function description
%
% /////////////////////////////////////////////////////////////////////////////


