% 'rct_cross_plot' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- rct_cross_plot ()
%       img, imgtitle,
%       'dpi', dpi,
%       'inline', 'on'/'off',
%       'crossline', 'on'/'off'

function rct_cross_plot(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'rct_cross_plot';

    % Supported properties
    keys = {'dpi', 'inline', 'crossline'};

    % Initialize structures for keeping data type indexes and values
    imgs = [];
    imgtitles = {};
    keyvalues = {NaN, NaN, NaN};

    % Check if any argument is passed
    if(0 == nargin)
        % No arguments passed
        error('Invalid call to %s. See help for correct usage.', fname);

        return;

    endif;

    % Start processing arguments
    index = 1;
    while(nargin >= index)

        if( ...
                ismatrix(varargin{index}) ...
                && isnumeric(varargin{index}) ...
                && 2 == length(size(varargin{index})) ...
                && 1 < min(size(varargin{index})) ...
                )
            % We have an image matrix
            imgs = [imgs index];

            % Check if following argument is image title. First check if next
            % argument exist at all
            if(nargin >= index + 1)
                % There is another function argument following this one. Lets
                % see if it holds an image title. First the only rgument type
                % that can follow image matrix is an image title or an function
                % parameter of which both are chars, so only data type that can
                % follow must be a char
                if(ischar(varargin{index + 1}))
                    if(not(ismember(varargin{index + 1}, keys)))
                        % It is not one of function propertis so we can safely
                        % assume it is an image title
                        imgtitles = {imgtitles{:} varargin(index + 1){:}};

                        % Skip to next unprocessed argument
                        index = index + 1;

                    else
                        % Next argument is call to function parameter, so user
                        % did not pass image title for the current image.
                        % Generate default image title
                        i = length(imgs);  % Get image index
                        imgtitles = {imgtitles{:} sprintf("IMG #%d", i)};

                    endif;

                elseif( ...
                        ismatrix(varargin{index}) ...
                        && isnumeric(varargin{index}) ...
                        && 2 == length(size(varargin{index})) ...
                        && 1 < min(size(varargin{index})) ...
                        )
                    % Next argument is an image matrix, so generate default
                    % image title
                    i = length(imgs);  % Get image index
                    imgtitles = {imgtitles{:} sprintf("IMG #%d", i)};

                else
                    % An invalid call to function occured
                    error( ...
                        'varargin(%d): Invalid call to %s. See help for correct usage.', ...
                        index + 1,
                        fname ...
                        );

                    return;

                endif;

            else
                % There is no another function argument following this one, so
                % assign default image title to an image with current index
                i = length(imgs);  % Get image index
                imgtitles = {imgtitles{:} sprintf("IMG #%d", i)};

            endif;

        elseif(ischar(varargin{index}))
            if(1 == index)
                % First argument to a function call can not be a string
                error( ...
                    'varargin(%d): Invalid call to %s. See help for correct usage.', ...
                    index,
                    fname ...
                    );

                return;

            endif;

            % The only string we should encounter must be a call to a function
            % property. Otherwise invalid call to function occured
            [iskey, keyindex] = ismember(varargin{index}, keys);
            if(iskey)
                % Argument is an call to function property. Lest see if user
                % supplied a value
                if(nargin >= index + 1)
                    % It seems that there is a prameter value, so assign it to
                    % coresponding paramter
                    % conforms to a valid one
                    keyvalues{keyindex} = varargin{index + 1};

                    % Skip to next unprocessed argument
                    index = index + 1;

                else
                    % Thera are no more arguments following a property call, so
                    % we treat it as invalid call to function
                    error( ...
                        'varargin(%d): Invalid call to %s. See help for correct usage.', ...
                        index + 1,
                        fname ...
                        );

                    return;

                endif;

            else  % We have an invalid call to function
                error( ...
                    'varargin(%d): Invalid call to %s. See help for correct usage.', ...
                    index,
                    fname ...
                    );

                return;

            endif;

        else
            % The argument is not an image matrix nor a call to a function
            % property, so we have an invalid call to function
            error( ...
                'varargin(%d): Invalid call to %s. See help for correct usage.', ...
                index,
                fname ...
                );

            return;

        endif;

        index = index + 1;

    endwhile;

    % Validate 'dpi' values
    if( ...
            not(isnan(keyvalues{1})) ...
            && not(isscalar(keyvalues{1})) ...
            && not(isnumeric(keyvalues{1})) ...
            )
        % Parameter value must be an numerical value greater or equal to 72
        error( ...
            'Invalid call to function parameter \"%s\". See help for correct usage.', ...
            keys{1} ...
            );

        return;

    endif;

    % Validate 'inline' values
    if(isnan(keyvalues{2}))
        % Parameter not set by user so use a default value
        keyvalues{2} = true;

    else
        switch(keyvalues{2})
            case 'on'
                keyvalues{2} = true;

            case 'off'
                keyvalues{2} = false;

            otherwise
                % Invalid call to function parameter
                error( ...
                    'Invalid call to function parameter \"%s\". See help for correct usage.', ...
                    keys{2} ...
                    );

                return;

        endswitch;

    endif;

    % Validate 'crossline' values
    if(isnan(keyvalues{3}))
        % Parameter not set by user so use a default value
        keyvalues{3} = true;

    else
        switch(keyvalues{3})
            case 'on'
                keyvalues{3} = true;

            case 'off'
                keyvalues{3} = false;

            otherwise
                % Invalid call to function parameter
                error( ...
                    'Invalid call to function parameter \"%s\". See help for correct usage.', ...
                    keys{3} ...
                    );

                return;

        endswitch;

    endif;

    % Determine maximum extents of the plot
    height = [];
    width = [];
    minval = [];
    maxval = [];
    index = 1;
    while(length(imgs) >= index)
        height = [height size(varargin{imgs(index)})(1)];
        width = [width size(varargin{imgs(index)})(2)];
        minval = [minval min(min(varargin{imgs(index)}))];
        maxval = [maxval max(max(varargin{imgs(index)}))];

        index = index + 1;

    endwhile;

    % Calculate center of plot
    in_cntr = round(max(height) / 2);
    cross_cntr = round(max(width) / 2);
    ord_cntr = round(min(minval) + (max(maxval) - min(minval))/2);

    % Initialize GUI elements
    hfig = figure('name', 'RCT Cross Plot', 'units', 'points');
    hax = axes('parent', hfig, 'units', 'points');

    % Start plotting
    index = 1;
    while(length(imgs) >= index)
        % Plot inline profile
        if(keyvalues{2})
            if(keyvalues{3})
                % We also have to plot crossline
                subplot(2, 1, 1);

            endif;

            if(isnan(keyvalues{1}))
                % Plot positions in milimeters
                mm = 25.4 / keyvalues{1};
                plot( ...
                    ([1:max(width)] - cross_cntr) * mm, ...
                    varargin{imgs(index)}(in_cntr, :) ...
                    );
                xlabel("Position [mm]");

            else
                % Plot positions in pixels
                plot( ...
                    ([1:max(width)] - cross_cntr), ...
                    varargsin{imgs(index)}(in_cntr, :) ...
                    );
                xlabel("Position [pixels]");

            endif;

        endif;

        % Plot crossline profile
        if(keyvalues{3})
            if(keyvalues{2})
                % We also have to plot crossline
                subplot(2, 1, 2);

            endif;

            if(isnan(keyvalues{1}))
                % Plot positions in milimeters
                mm = 25.4 / keyvalues{1};
                plot( ...
                    ([1:max(height)] - in_cntr) * mm, ...
                    varargin{imgs(index)}(cross_cntr, :) ...
                    );
                xlabel("Position [mm]");

            else
                % Plot positions in pixels
                plot( ...
                    ([1:max(height)] - in_cntr), ...
                    varargsin{imgs(index)}(cross_cntr, :) ...
                    );
                xlabel("Position [pixels]");

            endif;

        endif;

        index = index + 1;

    endwhile;

endfunction;
