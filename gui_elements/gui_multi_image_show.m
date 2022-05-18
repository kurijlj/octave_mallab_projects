% 'gui_multi_image_show' is a function from the package: 'GUI Elements RND'
%
%  -- gui_multi_image_show(I)
%       Small GuI app that creates a new figure to show passed image

function gui_multi_image_show(varargin)

    % Store function name into variable for easier management of error messages
    fname = 'gui_multi_image_show';

    % TODO: Complete input data validation lines here

    % Validate nuber of input arguments.
    narginchk(1, Inf);

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
        if(refsz ~= size(varargin{idx}))
            error( ...
                'varargin(%d): Invalid call to %s: UNCONFORMANT IMAGE SIZE. See help for correct usage.', ...
                idx, ...
                fname ...
                );

        endif;

        idx = idx + 1;

    endwhile;

    % Determine how to layout GUI elements. If image width is greater than image
    % height, use vertical layout. Otherwise use horizontal layout.
    hlayout = false;
    if(refsz(1) > refsz(2))
        hlayout = true;

    endif;

    % Initialize GUI elements
    graphics_toolkit qt;

    % Define general padding value for GUI elements in pixels
   pix_pad = 6;

    % Spawn GUI elements
    main_figure = figure( ...
        'name', 'GUI Multi Image Show', ...
        'sizechangedfcn', @update_main_figure ...
        );

    main_panel = uipanel( ...
        'parent', main_figure ...
        );

    % Get main panel draw area extents in pixels
    mps = getpixelposition(main_panel);

    % Calculate image panel extents
    img_pnls = {};
    elpos = [0, 0, 1, 1];
    if(hlayout)
        elpos = [0, 0, 1/nargin, 1];

    else
        elpos = [0, 0, 1, 1/nargin];

    endif;

    img_pnls = {img_pnls{:}, uipanel('parent', main_panel, 'position', elpos)};
    mps = getpixelposition(img_pnls{1});

    % Calculate axes extents
    rel_hpad = pix_pad/(mps(3) - mps(1));
    rel_vpad = pix_pad/(mps(4) - mps(2));

    % Calculate postion for the left panel within main panel
    elpos = [ ...
        rel_hpad, ...
        rel_vpad, ...
        1 - 2*rel_hpad, ...
        1 - 2*rel_vpad ...
        ];

    % Initialize axes for image display
    image_view = axes( ...
        'parent', img_pnls{1}, ...
        'position', elpos ...
        );
    image(varargin{1}, 'parent', image_view);

    % Generate structure to store and pass to callbacks user data and GUI
    % elements handles
    h = guihandles(main_figure);
    h.pix_pad = pix_pad;
    h.hlayout = hlayout;
    h.main_figure = main_figure;
    h.main_panel = main_panel;
    h.image_view = image_view;

    % Save data and GUI handles
    guidata(main_figure, h);

endfunction;


function update_main_figure(hsrc, evt)
    if(hsrc == gcbf())
        h = guidata(hsrc);
        switch(gcbo())
            case {h.main_figure}

                % Get main panel draw area extents in pixels
                mps = getpixelposition(h.main_panel);

                % Calculate left and right panel extents
                rel_hpad = h.pix_pad/(mps(3) - mps(1));
                rel_vpad = h.pix_pad/(mps(4) - mps(2));

                % Calculate and set new position for the display axes
                elpos = [ ...
                    rel_hpad, ...
                    rel_vpad, ...
                    1 - 2*rel_hpad, ...
                    1 - 2*rel_vpad ...
                    ];
                set(h.image_view, 'position', elpos);

        endswitch;

    endif;

endfunction;
