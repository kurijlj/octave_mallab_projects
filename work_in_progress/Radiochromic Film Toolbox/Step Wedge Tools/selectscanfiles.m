function cstrfpaths = selectscanfiles(
    FLT={'*.tif', 'Radiochromic Film Scan';},
    DIALOG_NAME=''
    )
%% -----------------------------------------------------------------------------
%%
%% Function 'selectfiles':
%%
%% -----------------------------------------------------------------------------
%
%  Use:
%       -- cstrfpaths = selectscanfiles()
%       -- cstrfpaths = selectscanfiles(FLT)
%       -- cstrfpaths = selectscanfiles(FLT, DIALOG_NAME)
%
%% Description:
%       Return a cell array containig absolute paths to the selected scan files.
%       It invokes 'uigetfile' function to provide interface for multiple files
%       selection. If 'Cancel' is selected, empty cell array is returned.
%
%       It is a convinience function with default filter set for *.tif.
%
%       FLT: two-column cell array of strings, def. {}
%           Two-column cell array containing a list of file extensions and file
%           descriptions pairs. See the help on uigetfile for detail
%           description.
%
%       DIALOG_NAME: string, def. 'Select Files'
%           Can be used to customize the dialog title. If supplied the dialog
%           title is formatted in the following fashion:
%
%               "DIALOG_NAME: Select Files"
%
% -----------------------------------------------------------------------------
    fname = 'selectscanfiles';
    use_case_a = sprintf(' -- cstrfpaths = %s()', fname);
    use_case_b = sprintf(' -- cstrfpaths = %s(FLT)', fname);
    use_case_c = sprintf(' -- cstrfpaths = %s(FLT, DIALOG_NAME)', fname);

    if(2 < nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b, ...
            use_case_c ...
            );

    endif;

    % Initialize return variables to default values
    cstrfpaths = {};

    % Validate value supplied for the file filter
    if(~isempty(FLT))
        if(~iscell(FLT))
            error('%s: FLT must be a cell array', fname);

        endif;

        if(2 > size(FLT, 2))
            error('%s: FLT must be a two column cell array', fname);

        endif;

        idx = 1;
        while(size(FLT, 1) >= idx)
            if(~ischar(FLT{idx, 1}))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: File extension in row %d must be a ', ...
                            'non-empty string' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;

            if(~ischar(FLT{idx, 1}))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: File description in row %d must be a ', ...
                            'non-empty string' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;

            ++idx;

        endwhile;

    endif;  % ~isempty(FLT)

    % Validate value supplied for the dialog name
    if(~ischar(DIALOG_NAME))
        error('%s: Title must be a string', fname);

    endif;

    % Format dialog name
    if(isempty(DIALOG_NAME))
        DIALOG_NAME = 'Select files';

    else
        DIALOG_NAME = sprintf('%s: Select files', DIALOG_NAME);

    endif;

    [strfpaths, dir] = uigetfile( ...
        FLT, ...
        DIALOG_NAME, ...
        'MultiSelect', 'on' ...
        );

    if(~isequal(0, strfpaths) && ~isequal(0, dir))
        % User selected some files. Reconstruct absolute paths

        % Check if user selected more than one file
        if(~iscell(strfpaths))
            % User selected single file
            cstrfpaths{end + 1} = fullfile(dir, strfpaths);

        else
            % User selected more than one file
            idx = 1;
            while(length(strfpaths) >= idx)
                cstrfpaths{end + 1} = fullfile(dir, strfpaths{idx});
                idx = idx + 1;

            endwhile;

        endif;  % ~iscell(strfpaths)

    endif;  % ~isequal(0, strfpaths) && ~isequal(0, dir)

endfunction;  % selectfiles
