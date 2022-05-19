% 'rct_gui_read_data_points' is a function from the package: 'Radiochromic Film Toolbox'
%
%  -- rct_gui_read_data_points(I)

function rct_gui_read_data_points(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'rct_gui_read_data_points';

    % Validate nuber of input arguments. We don't allow more than 50 input
    % arguments at the time taking that user will supply at max 20 scans with
    % corresponding scan titles, and that we support only one
    % key-value argument.
    narginchk(1, 50);

    % Parse input arguments to extract exact number of input scans
    [pos, prop] = parseparams(varargin);
    npos = length(pos);
    nprop = length(prop);

    % Allocate storage for user supplied data
    scan = {};
    nscans = 0;
    title = {};
    dpi = 400;

    % Validate input data type. All input data must be a 3D matrices (RGB images)
    idx = 1;
    refsz = [0, 0, 3];
    while(nargin >= idx)
        if(~ischar(varargin{idx}))
            validateattributes( ...
                varargin{idx}, ...
                {'numeric'}, ...
                {'finite', 'nonempty', 'nonnan', '3d'} ...
                );
            if(1 == idx)
                refsz(1) = size(varargin{idx}, 1);
                refsz(2) = size(varargin{idx}, 2);

            endif;

            % All input images must be of the same dimensions
            if(~isequal(refsz, size(varargin{idx})))
                error( ...
                    'varargin(%d): Invalid call to %s: UNCONFORMANT IMAGE SIZE. See help for correct usage.', ...
                    idx, ...
                    fname ...
                    );

            endif;

            % Add scan to scans array
            scan = {scan{:}, varargin{idx}};
            nscans = nscans + 1;

            % Check if user supplied a title for the scan
            if( ...
                    nargin > idx ...
                    && ischar(varargin{idx + 1}) ...
                    && ~isequal('dpi', varargin{idx + 1}) ...
                    )
                % Add argument to title array
                title = {title{:}, varargin{idx + 1}};
                % Move argument index to next unprocessed argument
                idx = idx + 2;

            else
                % Assign default title to a scan
                title = {title{:}, sprintf('Scan #%d', idx)};
                % Move argument index to next unprocessed argument
                idx = idx + 1;

            endif;

        else
            validatestring(varargin{idx}, {'dpi'});
            if(nargin > idx)
                validateattributes( ...
                    varargin{idx + 1}, ...
                    {'float'}, ...
                    {'nonempty', 'nonnan', 'scalar', 'finite', '>', 0} ...
                    );
                % Store user supplied dpi value
                dpi = varargin{idx + 1};
                % Move argument index to next unprocessed argument
                idx = idx + 2;

            else
                % Invalid call to a function
                error('Invalid call to %s: MISSING \"DPI\" VALUE. See help for correct usage.', fname);

            endif;

        endif;

    endwhile;

    % Initialize GUI elements
    graphics_toolkit qt;

    % Spawn main figure
    main_figure = figure( ...
        'name', 'GUI Multi Image Show', ...
        'menubar', 'none' ...
        );

    % Get handle for the main figure
    h = guihandles(main_figure);
    h.main_figure = main_figure;

    % Store dpi and number of passed images
    h.dpi = dpi;
    h.scan = scan;
    h.nscans = nscans;
    h.title = title;

    % Determine how to layout GUI elements. If image width is greater than image
    % height, use vertical layout. Otherwise use horizontal layout.
    h.hlayout = false;
    if(refsz(1) >= refsz(2))
        h.hlayout = true;

    endif;

    % Spawn main panel
    h.main_panel = uipanel( ...
        'parent', main_figure, ...
        'bordertype', 'none' ...
        );

    % Set storage for GUI element handlers
    h.img_pnls = {};
    h.img_viws = {};

    % Calculate image panel extents
    idx = 1;
    while(h.nscans >= idx)
        elpos = [0, 0, 1, 1];
        if(h.hlayout)
            elpos = [(idx - 1)/h.nscans, 0, 1/h.nscans, 1];

        else
            elpos = [0, 1 - idx/h.nscans, 1, 1/h.nscans];

        endif;

        % Spawn image panel
        h.img_pnls = {h.img_pnls{:}, uipanel('parent', h.main_panel, 'position', elpos)};

        % Initialize axes for image display
        h.img_viws{idx} = axes( ...
            'parent', h.img_pnls{idx}, ...
            'position', [0, 0, 1, 1] ...
            );

        % Show image on axes
        himage = image(h.scan{idx}, 'parent', h.img_viws{idx});

        % Turn of axes ticks and set title
        axis(h.img_viws{idx}, 'off');
        text(10, 30, h.title{idx});

        idx = idx + 1;

    endwhile;

    % Save data and GUI handles
    guidata(main_figure, h);

endfunction;
