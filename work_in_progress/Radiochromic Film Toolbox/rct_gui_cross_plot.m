% 'rct_gui_cross_plot' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- rct_cross_plot ()
%       img, imgtitle,
%       'dpi', dpi,
%       'inline', 'on'/'off',
%       'crossline', 'on'/'off'
%       'highlight', []

function rct_gui_cross_plot(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'rct_cross_plot';

    % Supported properties
    keys = {'dpi', 'inline', 'crossline', 'highlight'};

    % Initialize structures for keeping data type indexes and values
    imgs = [];
    imgtitles = {};
    keyvalues = {NaN, NaN, NaN, []};

    % Check if any argument is passed
    if(0 == nargin)
        % No arguments passed
        error('Invalid call to %s. See help for correct usage.', fname);

        return;

    endif;

    % Start processing arguments
    i = 1;
    while(nargin >= i)

        if( ...
                ismatrix(varargin{i}) ...
                && isnumeric(varargin{i}) ...
                && 2 == length(size(varargin{i})) ...
                && 1 < min(size(varargin{i})) ...
                )
            % We have an image matrix
            imgs = [imgs i];

            % Check if following argument is image title. First check if next
            % argument exist at all
            if(nargin >= i + 1)
                % There is another function argument following this one. Lets
                % see if it holds an image title. First the only rgument type
                % that can follow image matrix is an image title or an function
                % parameter of which both are chars, so only data type that can
                % follow must be a char
                if(ischar(varargin{i + 1}))
                    if(not(ismember(varargin{i + 1}, keys)))
                        % It is not one of function propertis so we can safely
                        % assume it is an image title
                        imgtitles = {imgtitles{:} varargin(i + 1){:}};

                        % Skip to next unprocessed argument
                        i = i + 1;

                    else
                        % Next argument is call to function parameter, so user
                        % did not pass image title for the current image.
                        % Generate default image title
                        dsi = length(imgs);  % Get image index
                        imgtitles = {imgtitles{:} sprintf('Dataset #%d', dsi)};

                    endif;

                elseif( ...
                        ismatrix(varargin{i}) ...
                        && isnumeric(varargin{i}) ...
                        && 2 == length(size(varargin{i})) ...
                        && 1 < min(size(varargin{i})) ...
                        )
                    % Next argument is an image matrix, so generate default
                    % image title
                    dsi = length(imgs);  % Get image index
                    imgtitles = {imgtitles{:} sprintf('Dataset #%d', dsi)};

                else
                    % An invalid call to function occured
                    error( ...
                        'varargin(%d): Invalid call to %s. See help for correct usage.', ...
                        i + 1,
                        fname ...
                        );

                    return;

                endif;

            else
                % There is no another function argument following this one, so
                % assign default image title to an image with current index
                dsi = length(imgs);  % Get image index
                imgtitles = {imgtitles{:} sprintf('Dataset #%d', dsi)};

            endif;

        elseif(ischar(varargin{i}))
            if(1 == i)
                % First argument to a function call can not be a string
                error( ...
                    'varargin(%d): Invalid call to %s. See help for correct usage.', ...
                    i,
                    fname ...
                    );

                return;

            endif;

            % The only string we should encounter must be a call to a function
            % property. Otherwise invalid call to function occured
            [iskey, keyindex] = ismember(varargin{i}, keys);
            if(iskey)
                % Argument is an call to function property. Lest see if user
                % supplied a value
                if(nargin >= i + 1)
                    % It seems that there is a prameter value, so assign it to
                    % coresponding paramter
                    % conforms to a valid one
                    keyvalues{keyindex} = varargin{i + 1};

                    % Skip to next unprocessed argument
                    i = i + 1;

                else
                    % Thera are no more arguments following a property call, so
                    % we treat it as invalid call to function
                    error( ...
                        'varargin(%d): Invalid call to %s. See help for correct usage.', ...
                        i + 1,
                        fname ...
                        );

                    return;

                endif;

            else  % We have an invalid call to function
                error( ...
                    'varargin(%d): Invalid call to %s. See help for correct usage.', ...
                    i,
                    fname ...
                    );

                return;

            endif;

        else
            % The argument is not an image matrix nor a call to a function
            % property, so we have an invalid call to function
            error( ...
                'varargin(%d): Invalid call to %s. See help for correct usage.', ...
                i,
                fname ...
                );

            return;

        endif;

        i = i + 1;

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

    % Validate highlight parameter values
    if(~isempty(keyvalues{4}))
        % It seems that user supplied arguments for the 'highlight' parameter
        if(~isnan(keyvalues{4}) && isnumeric(keyvalues{4}))
            i = 1;
            while(length(keyvalues{4}) >= i)
                % Traverse array to see if supplied image index values match
                % actual ones
                val = keyvalues{4}(i);
                if(1 > val || length(imgs) < val)
                    % Highlight profile index out of bound
                    error( ...
                        'Highlight index out of bound.' ...
                        );

                endif;

                i = i + 1;

            endwhile;

        else
            % Invalid call to function parameter
            error( ...
                'Invalid call to function parameter \"%s\". See help for correct usage.', ...
                keys{3} ...
                );

            return;

        endif;

    endif;

    % Determine maximum extents of the plot
    height = [];
    width = [];
    minval = [];
    maxval = [];
    i = 1;
    while(length(imgs) >= i)
        height = [height size(varargin{imgs(i)})(1)];
        width = [width size(varargin{imgs(i)})(2)];
        minval = [minval double(min(min(varargin{imgs(i)})))];
        maxval = [maxval double(max(max(varargin{imgs(i)})))];

        i = i + 1;

    endwhile;

    % Determine abscissa units and scale
    rescalef = 1.0;
    unit_str = 'pixels';
    if(not(isnan(keyvalues{1})))
        rescalef = 25.4 / keyvalues{1};
        unit_str = 'mm';

    endif;

    % Initialize GUI elements
    hax = [];
    hfig = figure('name', 'RCT Cross Plot', 'units', 'points');
    if(keyvalues{2} && keyvalues{3})
        hax = [0 0];
        hax(1) = axes( ...
            'parent', hfig, ...
            'position', [0.05, 0.05, 0.9, 0.4] ...
            );
        hax(2) = axes( ...
            'parent', hfig, ...
            'position', [0.05, 0.55, 0.9, 0.4] ...
            );

    else
        hax = [0];
        hax(1) = axes( ...
            'parent', hfig, ...
            'position', [0.05, 0.05, 0.9, 0.9] ...
            );

    endif;

    % Start to plot
    i = 1;
    while(length(imgs) >= i)
        % Calculate plot center position
        in_cntr = round(height(i)/2);
        cross_cntr = round(width(i)/2);

        % Plot inline profile
        if(keyvalues{2})
            phandle = hax(1);

            hold(phandle, 'on');
            if(ismember(i, keyvalues{4}))
                plot( ...
                    'parent', phandle, ...
                    ([1:height(i)] .- in_cntr).*rescalef, ...
                    double(varargin{imgs(i)}(:, cross_cntr)), ...
                    'linewidth', 2.5 ...
                    );

            else
                plot( ...
                    'parent', phandle, ...
                    ([1:height(i)] .- in_cntr).*rescalef, ...
                    double(varargin{imgs(i)}(:, cross_cntr)) ...
                    );

            endif;

            hold(phandle, 'off');

        endif;

        % Plot crossline profile
        if(keyvalues{3})
            phandle = hax(1);
            if(keyvalues{2})
                phandle = hax(2);

            endif;

            hold(phandle, 'on');
            if(ismember(i, keyvalues{4}))
                plot( ...
                    'parent', phandle, ...
                    ([1:width(i)] .- cross_cntr).*rescalef, ...
                    double(varargin{imgs(i)}(in_cntr, :)), ...
                    'linewidth', 2.5 ...
                    );

            else
                plot( ...
                    'parent', phandle, ...
                    ([1:width(i)] .- cross_cntr).*rescalef, ...
                    double(varargin{imgs(i)}(in_cntr, :)) ...
                    );

            endif;

            hold(phandle, 'off');

        endif;

        i = i + 1;

    endwhile;

    % Set plot and axes titles, and legend. First calculate common plot center
    % position
    in_cntr = round(max(height)/2);
    cross_cntr = round(max(width)/2);

    if(keyvalues{2})
        phandle = hax(1);
        hold(phandle, 'on');
        xlim(phandle, [0.0 - in_cntr 0.0 + in_cntr].*rescalef);
        xlabel(phandle, sprintf('Longitudinal position [%s]', unit_str));
        ylim(phandle, [min(minval) max(maxval)]);
        ylabel(phandle, 'Intensity');
        grid(phandle, 'on');
        legend(phandle, imgtitles);
        title(phandle, 'Inline Profile');
        hold(phandle, 'off');

    endif;

    if(keyvalues{3})
        phandle = hax(1);
        if(keyvalues{2})
            phandle = hax(2);

        endif;

        hold(phandle, 'on');
        xlim(phandle, [0.0 - cross_cntr 0.0 + cross_cntr].*rescalef);
        xlabel(phandle, sprintf('Transversal position [%s]', unit_str));
        ylim(phandle, [min(minval) max(maxval)]);
        ylabel(phandle, 'Intensity');
        grid(phandle, 'on');
        legend(phandle, imgtitles);
        title(phandle, 'Crossline Profile');
        hold(phandle, 'off');

    endif;

endfunction;
