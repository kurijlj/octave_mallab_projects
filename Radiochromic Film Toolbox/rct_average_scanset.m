% 'rct_average_scanset' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- [pixel_mean, pixel_std, dstitle] = rct_average_scanset (I1, I2, I3, ...)
%  -- [pixel_mean, pixel_std, dstitle] = rct_average_scanset (..., PROPERTY, VALUE, ...)
%
%      Take a set of scanned radiochromic film images and perform pixelwise
%      average and standard deviation calculation and user selected noise
%      removal.
%
%      Many different combinations of arguments are possible. The simplest form
%      is:
%          pixel_mean = rct_average_scanset (I1, I2, I3, ...)
%
%      where the arguments are taken as the matrices containing pixel data.
%
%      If more than one argument is given, they are interpreted as:
%          [pixel_mean, pixel_std, dstitle] = rct_average_scanset (I1, I2, I3, PROPERTY, VALUE, ...)
%
%     and so on. Any number of argument sets may appear.
%
%     Multiple property-value pairs may be specified, but they must appear in
%     pairs. So far supported properties are:
%
%     'title' - string defining a name of the averaged dataset.
%
%     'filter' - set noise removal filter to be used for data smoothing 
%
%     'filter' arguments:
%
%          'none'   - don't use any data smoothing
%          'median' - use 2D median filter with 7 by 7 wide neighborhood matrix
%                     for data smoothing
%          'wiener' - use zero-phase wiener filter with 7 by 7 neighborhood
%                     matrix for data smoothing
%          'haar'   - not implemented yet. Use 'Haar' wavelet to reconstruct
%                     signal and remove noise.
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
%     'saveresult' - whether or not to save result of calculation as CSV files.
%                    Resulting filename is deduced as string value supplied to
%                    title parameter followed by underscore and 'average' or
%                    'std', e.g.:
%                        title_average.csv
%                    or
%                        title_std.csv
%
%                    If no string value is supplied for 'title' function uses
%                    default value 'Dataset'.
%
%     See also: rct_read_scanset


function [pixel_mean, pixel_std, dstitle] = rct_average_scanset(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'rct_read_scanset';

    % Initialize return variables to default values
    pixel_mean = [];
    pixel_std = [];

    % Initialize structures for holding property values and initialize them
    % to default values
    keyval = {'Dataset', 1, 1, 0};  % {filter, progress, severesult}

    % Check if any argument is passed
    if(0 == nargin)
        % No arguments passed
        error('Invalid call to %s. See help for correct usage.', fname);

        return;

    endif;

    % Parse and store imput arguments
    [img, prop] = parseparams(varargin);

    % If no positional arguments we have an invalid call to function
    if(isempty(img))
        % No file path supplied
        error('Invalid call to %s. See help for correct usage.', fname);

        return;

    endif;

    % Check if we have enough number of samples (images) for good
    % statistical anlysis (N > 5). If not, display warning message
    if(5 > length(img))
        printf('%s: WARNING: Number of scan samples <5\n', fname);

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

            case 'filter'
                if(nprop > index)
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

                endif;

                % Property called but no value supplied. Use default value

            case 'progress'
                if(nprop > index)
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

                    index = index + 1;

                endif;

                % Property called but no value supplied. Use default value

            case 'saveresult'
                if(nprop > index)
                    switch(prop{index + 1})
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

                    index = index + 1;

                endif;

                % Property called but no value supplied. Use default value

            otherwise
                % A call to undefined property
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

    % If requested, start initialize progress feedback engine
    if(isequal('CLI', keyval{3}))
        utl_cli_progress_indicator(0);

    elseif(isequal('GUI', keyval{3}))
        printf('%s: GUI progress feedback not yet implemented.\n', fname);

        return;

    endif;

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

        % Update progress indicator
        if(isequal('CLI', keyval{3}))
            utl_cli_progress_indicator(index/length(img));

        elseif(isequal('GUI', keyval{3}))
            printf('%s: GUI progress feedback not yet implemented.\n', fname);

            return;

        endif;

        index = index + 1;

    endwhile;

    % Apply noise removal if requested by user
    if(3 == keyval{2})
        % Apply median filter
        pkg load image;
        if(3 == ref_size(3))
            pixel_mean(:, :, 1) = medfilt2(pixel_mean(:, :, 1), [7 7]);
            pixel_mean(:, :, 2) = medfilt2(pixel_mean(:, :, 2), [7 7]);
            pixel_mean(:, :, 3) = medfilt2(pixel_mean(:, :, 3), [7 7]);

        else
            pixel_mean = medfilt2(pixel_mean, [7 7]);

        endif;

    elseif(3 == keyval{2})
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
        pixel_std = pixel_std .+ (double(img{index}) .- pixel_mean).^2;
        index = index + 1;

    endwhile;

    % If dealing with only one sample (image) don't divede by N - 1
    if(1 < length(img))
        pixel_std = pixel_std ./ (length(img) - 1);

    endif;

    % Calculate square root of squared differences diveded by number of smples
    % minus one
    pixel_std = pixel_std.^0.5;

    % Format title for the averaged data matrix
    dstitle = { ...
        sprintf('%s - Averaged pixels', keyval{1}), ...
        sprintf('%s - Pixelwise stdev', keyval{1}), ...
        };

endfunction;
