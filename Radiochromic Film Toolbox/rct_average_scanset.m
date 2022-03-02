% 'rct_read_scanset' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- [pixel_mean, pixel_std] = rct_read_scanset (varargin)
%      F1, F2, F3, ...,
%      'filter', {'none', median, 'wiener'},
%      'progress', {'none', 'CLI', 'GUI'}
%      'saveresult', {'true', 'false'},
%
%      TODO: Put function description here

function [pixel_mean, pixel_std] = rct_read_scanset(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'rct_read_scanset';

    % Initialize return variables to default values
    pixel_mean = [];
    pixel_std = [];

    % Initialize structures for holding property values and initialize them
    % to default values
    keyval = {1, 1, 0};  % {filter, progress, severesult}

    % Check if any argument is passed
    if(0 == nargin)
        % No arguments passed
        error('Invalid call to %s. See help for correct usage.', fname);

        return;

    endif;

    % Check if we have enough number of samples (images) for good
    % statistical anlysis (N > 5). If not, display warning message
    if(5 > length(img))
        printf('%s: WARNING: Number of scan samples <5\n', fname);

    endif;

    % Parse and store imput arguments
    [img, prop] = parseparams(varargin);

    % If no positional arguments we have an invalid call to function
    if(isempty(img))
        % No file path supplied
        error('Invalid call to %s. See help for correct usage.', fname);

        return;

    endif;

    % Process key-value arguments
    index = 1;
    while(length(prop) >= index)
        switch(prop{index})
            case 'filter'
                switch(prop{index + 1})
                    case 'none'
                        keyval{1} = 1;

                    case 'median'
                        keyval{1} = 2;

                    case 'wiener'
                        keyval{1} = 3;

                    otherwise
                        error( ...
                            '%s: Invalid call to function parameter \"filter\". See help for correct usage', ...
                            fname ...
                            );

                        return;

                endswitch;

                index = index + 1;

            case 'progress'
                switch(prop{index + 1})
                    case 'none'
                        keyval{2} = 1;

                    case 'CLI'
                        keyval{2} = 2;

                    case 'GUI'
                        keyval{2} = 3;

                    otherwise
                        error( ...
                            '%s: Invalid call to function parameter \"progress\". See help for correct usage', ...
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

            otherwise
                % A call to not undefined property
                error( ...
                    '%s: Parameter \"%s\" not implemented. See help for correct usage', ...
                    fname, ...
                    prop{index} ...
                    );

                return;

        endswitch;

        index = index + 1;

    endwhile;

    % Initialize variable for keeping reference image size
    ref_size = [];

    % Validate passed images and calulcate pixelwise average image
    index = 1;
    while(length(img) >= index)
        % Check if image complies with required bits per pixel
        if(~isequal('uint16', class(img{index})))
            error('%s: I%d is not a 48 bit image', fname, index);

            return;

        endif;

        imsize = size(img{index});

        % We support single channel or RGB images
        if(1 ~= imsize(3) && 3 ~= imsize(3))
            error( ...
                '%s: I%d is not a single channel image nor a RGB image', ...
                fname, ...
                index ...
                );

            return;

        endif;

        % Check if all given images have the same size
        if(1 == index)
            ref_size = imsize;
            pixel_mean = zeros(imsize);
            pixel_std = zeros(imsize);

        elseif(~isequal(ref_size, imsize))
            error( ...
                '%s: I%d size does not comply to F1 size', ...
                fname, ...
                index ...
                );

            return;

        endif;

        % Caluclate average pixel value
        pixel_mean = pixel_mean .+ (double(img{index}) ./ length(img));

        index = index + 1;

    endwhile;

    % Apply noise removal if requested by user
    if(3 == keyval{1})
        % Apply median filter
        pkg load image;
        if(3 == ref_size(3))
            pixel_mean(:, :, 1) = medfilt2(pixel_mean(:, :, 1), [7 7]);
            pixel_mean(:, :, 2) = medfilt2(pixel_mean(:, :, 2), [7 7]);
            pixel_mean(:, :, 3) = medfilt2(pixel_mean(:, :, 3), [7 7]);

        else
            pixel_mean = medfilt2(pixel_mean, [7 7]);

        endif;

    elseif(3 == keyval{1})
        % Apply wiener filter
        pkg load image;
        if(3 == ref_size(3))
            pixel_mean(:, :, 1) = wiener2(pixel_mean(:, :, 1), [7 7]);
            pixel_mean(:, :, 2) = wiener2(pixel_mean(:, :, 2), [7 7]);
            pixel_mean(:, :, 3) = wiener2(pixel_mean(:, :, 3), [7 7]);

        else
            pixel_mean = wiener2(pixel_mean, [7 7]);

        endif;

    endif;

    % Calculate pixelwise standard deviation
    index = 1;

    % Calculate sum of squared differences from average pixel value
    while(length(img) >= index)
        pixel_std = pixel_std .+ (pixel_src{index} .- pixel_mean).^2;
        index = index + 1;

    endwhile;

    % If dealing with only one sample (image) don't divede by N - 1
    if(1 < length(img))
        pixel_std = pixel_std ./ (length(img) - 1);

    endif;

    % Calculate square root of squared differences diveded by number of smples
    % minus one
    pixel_std = pixel_std.^0.5;

endfunction;
