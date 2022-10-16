% 'utl_gui_file_multiselect' is a function from the package: 'Utility Toolbox'
%
%  -- fpath = utl_gui_file_multiselect ()
%
%       Utility function that calls 'uigetfile' with enabled 'MultiSeect'
%       option. It returns empty cell array if user hits 'Cancel'. Otherwise it
%       returns cell array of strings, containing absolute paths to selected
%       files.
%


% =============================================================================
% Copyright (C) 2022 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% This file is part of Utility Toolbox.
%
% Utility Toolbox is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the Free
% Software Foundation, either version 3 of the License, or (at your option) any
% later version.
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
% <Put documentation here>
%
% 2022-05-17 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% * utl_gui_file_multiselect.m: created.
%
% =============================================================================


% =============================================================================
%
% TODO: 1) Add support for deifning supported file types.
%
% =============================================================================


function fpath = utl_gui_file_multiselect()

    % Initialize return variables to default values
    fpath = {};

    [file, dir] = uigetfile( ...
        'title', 'UTbox File Multiselect', ...
        'MultiSelect', 'on' ...
        );

    if(~isequal(0, file) && ~isequal(0, dir))
        % User selected some files. Reconstruct absolute paths

        % Check if user selected more than one file
        if(~iscell(file))
            % User selected single file
            fpath = {fpath{:} fullfile(dir, file)};

        else
            % User selected more than one file
            idx = 1;
            while(length(file) >= idx)
                fpath = {fpath{:} fullfile(dir, file{idx})};
                idx = idx + 1;

            endwhile;

        endif;  % if(~iscell(file))

    endif;  % if(~isequal(0, file) && ~isequal(0, dir))

endfunction;
