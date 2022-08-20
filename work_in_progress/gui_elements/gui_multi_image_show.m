% 'gui_multi_image_show' is a function from the package: 'GUI Elements RND'
%
%  -- gui_multi_image_show(I)
%       Small GuI app that creates a new figure to show passed image

function gui_multi_image_show(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'gui_multi_image_show';

    % TODO: Complete input data validation lines here

    % Validate nuber of input arguments.
    narginchk(1, 20);

    % Validate input data type. All input data must be either 3D or 2D matrices
    % (RGB or monochrome)
    idx = 1;
    refsz = [0, 0, 3];
    while(nargin >= idx)
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

        idx = idx + 1;

    endwhile;

    display(refsz);

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

    % Store number of passed images
    h.nimgs = nargin;

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
    while(h.nimgs >= idx)
        elpos = [0, 0, 1, 1];
        if(h.hlayout)
            elpos = [(idx - 1)/nargin, 0, 1/nargin, 1];

        else
            elpos = [0, 1 - idx/nargin, 1, 1/nargin];

        endif;

        % Spawn image panel
        h.img_pnls = {h.img_pnls{:}, uipanel('parent', h.main_panel, 'position', elpos)};

        % Initialize axes for image display
        h.img_viws{idx} = axes( ...
            'parent', h.img_pnls{idx}, ...
            'position', [0, 0, 1, 1] ...
            );

        % Show image on axes
        himage = image(varargin{idx}, 'parent', h.img_viws{idx});

        % Turn of axes ticks and set title
        axis(h.img_viws{idx}, 'off');
        text(10, 30, sprintf('Image #%d', idx));

        idx = idx + 1;

    endwhile;

    % Save data and GUI handles
    guidata(main_figure, h);

endfunction;
