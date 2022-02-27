% 'rct_read_scanset' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- [pixel_mean, pixel_std] = rct_read_scanset (varargin)
%      F1, F2, F3, ...,
%      'colorchannel', {'fullcolor', 'red', 'green', 'blue'},
%      'filter', {'none', median, 'wiener'},
%      'saveresult', {'true', 'false'},
%      'progress', {'none', 'CLI', 'GUI'}
%
%      TODO: Put function description here

function [pixel_mean, pixel_std] = rct_read_scanset(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'rct_read_scanset';

    % Initialize return variables to default values
    pixel_src = {};
    pixel_mean = [];
    pixel_std = [];

    % Initialize structures for holding property values and initialize them
    % to default
    fpath = {};
    keyval = {0, 3, 0, 1};  % {colorchannel, filter, progress}

    % Check if any argument is passed
    if(0 == nargin)
        % No arguments passed
        error('Invalid call to %s. See help for correct usage.', fname);

        return;

    endif;

    % Parse and store imput arguments
    [pos, prop] = parseparams(varargin);

    % If any positional argument detected we have an invalid call to function
    if(~isempty(fpath))
        % No file path supplied
        error('Invalid call to %s. See help for correct usage.', fname);

        return;

    endif;

    % Process key-value arguments
    index = 1;
    while(length(prop) >= index)
        switch(prop{index})
            case 'colorchannel'
                switch(prop{index + 1})
                    case 'fullcolor'
                        keyval{1} = 0;

                    case 'red'
                        keyval{1} = 1;

                    case 'green'
                        keyval{1} = 2;

                    case 'blue'
                        keyval{1} = 3;

                    otherwise
                        error( ...
                            '%s: Invalid call to function parameter \"colorchannel\". See help for correct usage', ...
                            fname ...
                            );

                        return;

                endswitch;

                index = index + 1;

            case 'filter'
                switch(prop{index + 1})
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

                index = index + 1;

            case 'saveresult'
                switch(prop{index + 1})
                    case 'false'
                        keyval{3} = 0;

                    case 'true'
                        keyval{3} = 1;

                    otherwise
                        error( ...
                            '%s: Invalid call to function parameter \"saveresult\". See help for correct usage', ...
                            fname ...
                            );

                        return;

                endswitch;

                index = index + 1;

            case 'progress'
                switch(prop{index + 1})
                    case 'none'
                        keyval{4} = 1;

                    case 'CLI'
                        keyval{4} = 2;

                    case 'GUI'
                        keyval{4} = 3;

                    otherwise
                        error( ...
                            '%s: Invalid call to function parameter \"progress\". See help for correct usage', ...
                            fname ...
                            );

                        return;

                endswitch;

                index = index + 1;

            otherwise
                % Assume file path
                if(~isfile(prop{index}))
                    error( ...
                        '%s: F%d must be a path to a regular file', ...
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

        image = imread(fpath{index});
        pixel_src = {pixel_src{:} image};

        % Check if image complies with required bits per pixel
        if(~isequal('uint16', class(image)))
            error('%s: Image %s is not a 48 bit image', fname, fpath{index});

            return;

        endif;

        % Check if we have an RGB image
        imsize = size(image);
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
            if(0 == keyval{1})
                % User selected reading of all color channels
                pixel_mean = zeros(imsize);
                pixel_std = zeros(imsize);

            else
                % User selected reading of only one color channel
                pixel_mean = zeros(imsize(1), imsize(2));
                pixel_std = zeros(imsize(1), imsize(2));

            endif;

        elseif(~isequal(ref_size, imsize))
            error( ...
                '%s: Image %s is not of same size as F1', ...
                fname, ...
                fpath{index} ...
                );

            return;

        endif;

        switch(keyval{1})
            case 0
                % User selected reading of all color channels
                pixel_mean = pixel_mean .+ (double(image) ./ nfpath);

            case 1
                % User selected reading of only red color channel
                pixel_mean = pixel_mean .+ (double(image(:, :, 1)) ./ nfpath);

            case 2
                % User selected reading of only green color channel
                pixel_mean = pixel_mean .+ (double(image(:, :, 2)) ./ nfpath);

            otherwise
                % User selected reading of only blue color channel
                pixel_mean = pixel_mean .+ (double(image(:, :, 3)) ./ nfpath);

        endswitch;

        index = index + 1;

    endwhile;

    % Apply noise removal if requested by user
    if(2 == keyval{2})
        % Apply median filter
        pkg load image;
        if(0 == keyval{1})
            pixel_mean(:, :, 1) = medfilt2(pixel_mean(:, :, 1), [7 7]);
            pixel_mean(:, :, 2) = medfilt2(pixel_mean(:, :, 2), [7 7]);
            pixel_mean(:, :, 3) = medfilt2(pixel_mean(:, :, 3), [7 7]);

        else
            pixel_mean = medfilt2(pixel_mean, [7 7]);

        endif;

    elseif(3 == keyval{2})
        % Apply wiener filter
        pkg load image;
        if(0 == keyval{1})
            pixel_mean(:, :, 1) = wiener2(pixel_mean(:, :, 1), [7 7]);
            pixel_mean(:, :, 2) = wiener2(pixel_mean(:, :, 2), [7 7]);
            pixel_mean(:, :, 3) = wiener2(pixel_mean(:, :, 3), [7 7]);

        else
            pixel_mean = wiener2(pixel_mean, [7 7]);

        endif;

    endif;

    % Calculate pixelwise standard deviation
    index = 1;
    while(nfpath >= index)
        switch(keyval{1})
            case 0
                pixel_std = pixel_std .+ (pixel_src{index} .- pixel_mean).^2;

            case 1
                pixel_std = pixel_std .+ (pixel_src{index}(:, :, 1) .- pixel_mean).^2;

            case 2
                pixel_std = pixel_std .+ (pixel_src{index}(:, :, 2) .- pixel_mean).^2;

            otherwise
                pixel_std = pixel_std .+ (pixel_src{index}(:, :, 2) .- pixel_mean).^2;

        endswitch;

        index = index + 1;

    endwhile;

    if(1 < nfpath)
        pixel_std = pixel_std ./ (nfpath - 1);

    endif;

    pixel_std = pixel_std.^0.5;

endfunction;
