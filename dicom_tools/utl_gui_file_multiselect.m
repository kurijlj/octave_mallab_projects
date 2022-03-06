% 'utl_gui_file_multiselect' is a function from the package: 'Utility Toolbox'
%
%  -- fpath = rct_read_scanset ()
%      TODO: Put function description here

function fpath = utl_gui_file_multiselect()

    % Store function name into variable for easier management of error messages
    fn_name = 'utl_file_multiselect';

    % Initialize return variables to default values
    fpath = {};

    [file, dir] = uigetfile( ...
        'title', 'UTbox File Multiselect', ...
        'MultiSelect', 'on' ...
        );

    if(~isequal(0, file) && ~isequal(0, dir))
        index = 1;
        while(length(file) >= index)
            fpath = {fpath{:} fullfile(dir, file{index})};
            index = index + 1;

        endwhile;

    endif;

endfunction;
