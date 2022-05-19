% 'rct_gui_corr_scan' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- [corr_scan, corr_scan_title] = rct_gui_corr_scan ()
%
%      Multiple property-value pairs may be specified, but they must appear in
%      pairs. So far supported properties are:
%
%          'title'      - string defining a name of the averaged dataset
%
%          'filter'     - set noise removal filter to be used for data smoothing
%
%          'filter' arguments:
%
%              'none'       - don't use any data smoothing
%              'median'     - use 2D median filter with 7 by 7 wide
%                             neighborhood matrix for data smoothing
%              'wiener'     - use zero-phase wiener filter with 7 by 7
%                             neighborhood matrix for data smoothing
%              'haar'       - not implemented yet. Use 'Haar' wavelet to
%                             reconstruct signal and remove noise.
%
%          'progress'   - set what kind of feedback to use on displaying data
%                         reading process
%
%          'progress' arguments:
%
%              'none'       - don't display any information on data reading
%                             progress
%              'CLI'        - show information on the data reading progress
%                             in the 'Command Window'
%              'GUI'        - use GUI progress bar to display information
%                             on the data reading progress
%
%          'saveresult' - whether or not to save result of calculation as CSV
%                         files. Resulting filename is deduced as string value
%                         supplied to title parameter followed by the
%                         underscore and 'average' or 'std', e.g.:
%
%                             title_average.csv
%
%                         or
%
%                             title_std.csv
%
%      If no string value is supplied for 'title' function uses the default
%      value 'Corrected Scan'.
%
%      See also: rct_read_scanset


function [corr_scan, corr_scan_title] = rct_gui_corr_scan(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'rct_gui_corr_scan';

    % Initialize return variables to default values
    corr_scan = [];
    corr_scan_title = "";

    % Initialize structures for holding property values and initialize them
    % to default values
    keyval = {'Corrected Scan', 1, 1, 0};  % {title, filter, progress, severesult}

    % Check if any argument is passed
    pos = {};
    props = {};
    if(0 ~= nargin)
        % Parse and store imput arguments
        [pos, prop] = parseparams(varargin);

        if(~isempty(pos))
            % We do not support any positional argument
            error('Invalid call to %s. Positional arguments are not supported.', fname);

            return;

        endif;

        % Check if key-value arguments are passed
        if(~isempty(prop))
            % Key-value arguments passed so let's process them
            idx = 1;
            nprops = length(prop);
            while(nprops >= idx)
                switch(prop{idx})
                    case 'title'
                        if(nprops > idx)
                            % There is at least one parameter after call to property.
                            % Assume property value
                            if(~ischar(prop{idx + 1}))
                                % Must be a char array (string)
                                error( ...
                                    '%s: Invalid call to function parameter \"title\". See help for correct usage', ...
                                    fname ...
                                    );

                                return;

                            endif;

                            % Value is a string. Assign it to the propery, and move
                            % pointer idx to next property
                            keyval{1} = prop{idx + 1};
                            idx = idx + 1;

                        endif;

                        % Property called but no value supplied. Use default value

                    case 'filter'
                        if(nprops > idx)
                            switch(prop{idx + 1})
                                case 'none'
                                    keyval{2} = 1;

                                case 'median'
                                    keyval{2} = 2;

                                case 'wiener'
                                    keyval{2} = 3;

                                otherwise
                                    error( ...
                                        '%s: Invalid call to function parameter \"filter\". See help for correct usage', ...
                                        fname ...
                                        );

                                    return;

                            endswitch;

                            idx = idx + 1;

                        endif;

                        % Property called but no value supplied. Use default value

                    case 'progress'
                        if(nprops > idx)
                            switch(prop{idx + 1})
                                case 'none'
                                    keyval{3} = 1;

                                case 'CLI'
                                    keyval{3} = 2;

                                case 'GUI'
                                    keyval{3} = 3;

                                otherwise
                                    error( ...
                                        '%s: Invalid call to function parameter \"progress\". See help for correct usage', ...
                                        fname ...
                                        );

                                    return;

                            endswitch;

                            idx = idx + 1;

                        endif;

                        % Property called but no value supplied. Use default value

                    case 'saveresult'
                        if(nprops > idx)
                            switch(prop{idx + 1})
                                case 'false'
                                    keyval{4} = 0;

                                case 'true'
                                    keyval{4} = 1;

                                otherwise
                                    error( ...
                                        '%s: Invalid call to function parameter \"saveresult\". See help for correct usage', ...
                                        fname ...
                                        );

                                    return;

                            endswitch;

                            idx = idx + 1;

                        endif;

                        % Property called but no value supplied. Use default value

                    otherwise
                        % A call to undefined property
                        error( ...
                            '%s: Parameter \"%s\" not implemented. See help for correct usage', ...
                            fname, ...
                            prop{idx} ...
                            );

                        return;

                endswitch;

                idx = idx + 1;

            endwhile;


        endif;

    endif;

endfunction;
