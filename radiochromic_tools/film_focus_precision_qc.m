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
clear all;

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


% =============================================================================
%
% GUI setup section
%
% =============================================================================

% Set screen size to calculate main window extents
ssize = get(0, 'ScreenSize');
x_pos = floor(ssize(3) * 0.2);
y_pos = floor(ssize(4) * 0.2);
width = 3 * floor(ssize(3) * 0.2);
height = 3 * floor(ssize(4) * 0.2);

main_window = figure( ...
    'name', 'Film Focus Precision QC', ...
    'position', [x_pos, y_pos, width, height] ...
    );

% Generate a structure of handles to pass to callbacks, and store it.
handles = guihandles(main_window);

handles.main_window = main_window;

handles.view = axes( ...
    main_window, ...
    'xtick', [], ...
    'ytick', [], ...
    'xlim', [0, 1], ...
    'ylim', [0, 1], ...
    'position', [0.01, 0.20, 0.36, 0.77] ...
    %'callback', @select_point ...
    );

handles.inline_plot = axes( ...
    main_window, ...
    'position', [0.40, 0.20, 0.59, 0.77] ...
    %'callback', @select_point ...
    );

handles.signal_label = uicontrol( ...
    main_window, ...
    'style', 'text', ...
    'units', 'normalized', ...
    'string', 'None', ...
    'horizontalalignment', 'center', ...
    'position', [0.01, 0.08, 0.20, 0.05] ...
    );

handles.signal_select = uicontrol( ...
    main_window, ...
    'style', 'pushbutton', ...
    'units', 'normalized', ...
    'string', 'Select Signal ...', ...
    'position', [0.22, 0.08, 0.15, 0.05] ...
    %"callback", @select_signal ...
    );

handles.ref_label = uicontrol( ...
    main_window, ...
    'style', 'text', ...
    'units', 'normalized', ...
    'string', 'None', ...
    'horizontalalignment', 'center', ...
    'position', [0.01, 0.01, 0.20, 0.05] ...
    );

handles.ref_select = uicontrol( ...
    main_window, ...
    'style', 'pushbutton', ...
    'units', 'normalized', ...
    'string', 'Select Reference ...', ...
    'position', [0.22, 0.01, 0.15, 0.05], ...
    'callback', @select_ref ...
    );

% =============================================================================
%
% GUI state structure initialization section
%
% =============================================================================

handles.current_dir = '.';
handles.ref_fname = '';
handles.ref_R = NaN;
handles.signal_fname = '';
handles.signal_R = NaN;
handles.signal_od = NaN;
handles.current_point = [0, 0];

% End of initialized data
guidata(main_window, handles);


% =============================================================================
%
% GUI Callbacks
%
% =============================================================================

% /////////////////////////////////////////////////////////////////////////////
%
% function select_point - TODO:short function description
%
% TODO: full function description
%
% /////////////////////////////////////////////////////////////////////////////

function select_point(caller_h, event_data)
    handles = guidata(caller_h);
    coordinates = get(handles.view, 'CurrentPoint');

    % Update current point property
    x = coordinates(1, 1);
    y = coordinates(1, 2);
    handles.current_point(1) = x;
    handles.current_point(1) = y;

    % Set axes
    axes(handles.view);

    % Clear previous crosshair
    crosshair = findobj(gca, 'Type', 'line');
    if ~isempty(crosshair)
        delete(crosshair);
    endif;

    % Draw new crosshair
    hold on;
    width = size(handles.ref_R)(2);
    height = size(handles.ref_R)(1);
    plot( ...
        [1, width], [y, y], 'r', ...
        [x, x], [1, height], 'r' ...
    );
    hold off;

endfunction;


% /////////////////////////////////////////////////////////////////////////////
%
% function select_ref - TODO:short function description
%
% TODO: full function description
%
% /////////////////////////////////////////////////////////////////////////////

function select_ref(caller_h, event_data)
    handles = guidata(caller_h);

    [fname, fpath] = uigetfile( ...
        {'*.tif', 'Reference Scan'}, ...
        'Select Reference Scan', ...
        fullfile(handles.current_dir, filesep()) ...
        );

    % If we have valid path and file name we can load the image
    if(0 != fname)
        % Set current dir and reference scan file name
        handles.current_dir = fpath;
        handles.ref_fname = fname;

        % Print status in the command window
        printf( ...
            "Loading image: %s\n", ...
            fullfile(handles.current_dir, handles.ref_fname) ...
            );

        % Load image data
        img = imread(fullfile(handles.current_dir, handles.ref_fname));
        width = size(img)(2);
        height = size(img)(1);
        x_center = round(width / 2);
        y_center = round(height / 2);

        % Update current point property
        handles.current_point(1) = x_center;
        handles.current_point(2) = y_center;

        % Store red channel to state variavle
        handles.ref_R = img(:,:,1);

        % Display image
        axes(handles.view);
        h = imshow(img, []);

        % Draw crosshair pointing currently selected image center
        hold on;
        plot( ...
            [1, width], [y_center, y_center], 'r', ...
            [x_center, x_center], [1, height], 'r' ...
        );
        hold off;

        % Set callbak function for mouse clicks
        set(h, 'ButtonDownFcn', @select_point)
        % axis image off;

        % Display reference scan file name
        set(handles.ref_label, 'string', fname);

        % Save app state
        guidata(caller_h, handles);

    endif;

endfunction;

