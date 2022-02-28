% 'rct_read_scanset' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- [pixel_mean, pixel_std] = rct_read_scanset (varargin)
%      F1, F2, F3, ...,
%      'title', 'string describing scanset'
%      'colorchannel', {'fullcolor', 'red', 'green', 'blue'},
%      'progress', {'none', 'CLI', 'GUI'}
%
%      TODO: Put function description here

function [scanset, sctitle] = rct_read_scanset(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'rct_read_scanset';

    % Initialize return variables to default values
    scanset = {};
    sctitle = {};

    % Initialize structures for holding property values and initialize them
    % to default
    fpath = {};
    keyval = {'Unknown Scanset', 0, 1};  % {title, colorchannel, progress}

    % Check if any argument is passed
    if(0 == nargin)
        % No arguments passed
        error('Invalid call to %s. See help for correct usage.', fname);

        return;

    endif;

    % Parse and store imput arguments
    [pos, prop] = parseparams(varargin);

    % If any positional argument detected we have an invalid call to function
    if(~isempty(pos))
        % No file path supplied
        error('Invalid call to %s. See help for correct usage.', fname);

        return;

    endif;

    % Process key-value arguments
    index = 1;
    nprop = length(prop);
    while(nprop >= index)
        switch(prop{index})
            case 'title'
                if(nprop > index)
                    % There is at least one parameter after call to property.
                    % Assume property value
                    if(~ischar(prop{index + 1}))
                        % Must be a char array (string)
                        error( ...
                            '%s: Invalid call to function parameter \"title\". See help for correct usage', ...
                            fname ...
                            );

                        return;

                    endif;

                    % Value is a string. Assign it to the propery, and move
                    % pointer index to next property
                    keyval{1} = prop{index + 1};
                    index = index + 1;

                endif;

                % Property called but no value supplied. Use default value

            case 'colorchannel'
                if(nprop > index)
                    % There is at least one parameter after call to property.
                    % Assume property value
                    switch(prop{index + 1})
                        case 'fullcolor'
                            keyval{2} = 0;

                        case 'red'
                            keyval{2} = 1;

                        case 'green'
                            keyval{2} = 2;

                        case 'blue'
                            keyval{2} = 3;

                        otherwise
                            % Given value does not match set of
                            % acceptable values
                            error( ...
                                '%s: Invalid call to function parameter \"colorchannel\". See help for correct usage', ...
                                fname ...
                                );

                            return;

                    endswitch;

                    % Mkove pointer index to next property
                    index = index + 1;

                endif;

                % Property called but no value supplied. Use default value

            case 'progress'
                if(nprop > index)
                    % There is at least one parameter after call to property.
                    % Assume property value
                    switch(prop{index + 1})
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

                    % Mkove pointer index to next property
                    index = index + 1;

                endif;

                % Property called but no value supplied. Use default value

            otherwise
                % Assume file path
                if(~isfile(prop{index}))
                    error( ...
                        '%s: varargin{%d} must be a path to a regular file', ...
                        fname, ...
                        index ...
                        );

                endif;

                % It is a valide file path
                fpath = {fpath{:} prop{index}};

        endswitch;

        index = index + 1;

    endwhile;

    % Start reading images

    % Initialize variables for keeping reference image size
    ref_size = [];

    index = 1;
    nfpath = length(fpath);
    while(nfpath >= index)
        if(isequal('CLI', keyval{3}))
            printf('%s: Reading image: %s\n', fname, fpath{index});

        elseif(isequal('GUI', keyval{3}))
            error('%s: GUI progress feedback not yet implemented', fname);

            return;

        endif;

        % Read image data
        image = imread(fpath{index});
        imsize = size(image);

        % Check if image complies with required bits per pixel
        if(~isequal('uint16', class(image)))
            error('%s: Image %s is not a 48 bit image', fname, fpath{index});

            return;

        endif;

        % Check if we have an RGB image
        if(3 ~= imsize(3))
            error( ...
                '%s: Image %s is not an RGB image', ...
                fname, ...
                fpath{index} ...
                );

            return;

        endif;

        % Check if all given images have the same size
        if(1 == index)
            ref_size = imsize;

        elseif(~isequal(ref_size, imsize))
            error( ...
                '%s: Image %s is not of same size as F1', ...
                fname, ...
                fpath{index} ...
                );

            return;

        endif;

        % Add image to scanset
        switch(keyval{2})
            case 0
                % User selected reading of all color channels
                scanset = {scanset{:} image};

            case 1
                % User selected reading of only red color channel
                scanset = {scanset{:} image(:, :, 1)};

            case 2
                % User selected reading of only green color channel
                scanset = {scanset{:} image(:, :, 2)};

            otherwise
                % User selected reading of only blue color channel
                scanset = {scanset{:} image(:, :, 3)};

        endswitch;

        % Format scan title and add it to scanset titles
        sctitle = {sctitle{:} sprintf('%s - Scan #%d', keyval{1}, index)};

        index = index + 1;

    endwhile;

endfunction;
