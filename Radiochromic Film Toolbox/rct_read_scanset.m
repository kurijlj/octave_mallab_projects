% 'rct_read_scanset' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- [scanset, sctitle] = rct_read_scanset (FP)
%  -- [scanset, sctitle] = rct_read_scanset (FP1, FP2, FP3, ...)
%  -- [scanset, sctitle] = rct_read_scanset (..., PROPERTY, VALUE, ...)
%
%      Take a full path to radiochromic film scan/scanset and load image data
%      into the memory. It support only 16 bits per sample RGB images.
%
%      Many different combinations of arguments are possible. The simplest form
%      is:
%          scanset = rct_read_scanset(FP)
%
%      where the argument is taken as the fullpath to a image of the scanned
%      radiochromic film.
%
%      If more than one argument is given, they are interpreted as:
%          [scanset, sctitle] = plot (FP, PROPERTY, VALUE, ...)
%
%      or
%          [scanset, sctitle] = plot (FP1, FP2, FP3, ..., PROPERTY, VALUE, ...)
%
%     and so on. Any number of argument sets may appear.
%
%     Multiple property-value pairs may be specified, but they must appear in
%     pairs. So far supported properties are:
%
%     'title' - string defining a common scanset name.
%
%     'colorchannel' - set which color channel to read from image data.
%
%     'colorchannel' arguments:
%
%          'fullcolor' - read all three color channels (RGB)
%          'red'       - read only red color channel
%          'green'     - read only green color channel
%          'blue'      - read only blue color channel
%
%     'progress' - set what kind of feedback to use on displaying
%                  data reading process
%
%     'progress' arguments:
%
%          'none' - don't display any information on data reading process
%          'CLI'  - show information on the data reading progress in
%                   the 'Command Window'
%          'GUI'  - use GUI progress bar to display information on the
%                   data reading progress
%
%     See also: rct_average_scanset


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
