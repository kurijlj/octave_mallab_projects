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
% 2022-07-17 Ljubomir Kurij <ljubomir_kurij@proton.me>
%
% * utl_dir_tree.m: created.
%
% =============================================================================


% =============================================================================
%
% TODO:
%
% =============================================================================


% -----------------------------------------------------------------------------
%
% Script version info
%
% -----------------------------------------------------------------------------
utl_dir_tree_version = '1.0';


% -----------------------------------------------------------------------------
%
% Function: utlDirTree
%
% Usage:
%       -- tree = utlDirTree()
%       -- tree = utlDirTree(root)
%
% Descritpion: TODO: Put function description here
%
% -----------------------------------------------------------------------------
function tree = utlDirTree(root)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'utlDirTree';
    use_case_a = ' -- tree = utlDirTree()';
    use_case_b = ' -- tree = utlDirTree(root)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(0 ~= nargin && 1 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Check if user supplied any argument at all
    if(0 == nargin)
        % No argument supplied, use default value for the root
        root = '.';

    endif;

    % Check if user supplied a string
    if(~ischar(root))
        error('%s: root must be a string', fname);

    endif;

    % Check if root is a valid folder
    if(~isfolder(root))
        error('%s: root must be a valid local folder', fname);

    endif;

    % Start traversing through directory tree
    entries = readdir(root);

    % Remove current and parent directory from the list
    if(isequal('.', entries{1}))
        entries = {entries{2:end}};

    endif;
    if(isequal('..', entries{1}))
        entries = {entries{2:end}};

    endif;

    tree = {};
    if(0 ~= numel(entries))
        % We are not dealing with an empty directory. Search for directory
        % entries
        idx = 1;
        while(numel(entries) >= idx)
            path = fullfile(root, entries{idx});
            if(isfolder(path))
                % Add path to tree
                tree = {tree{:} path};

                % Traverse subdirectory
                tree = {tree{:} utlDirTree(path){:}};

            endif;

            idx = idx + 1;

        endwhile;

    endif;

endfunction;
