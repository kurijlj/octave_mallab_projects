% 'gui_multi_image_show' is a function from the package: 'GUI Elements RND'
%
%  -- gui_multi_image_show(I)
%       Small GuI app that creates a new figure to show passed image

function gui_multi_image_show(varargin)

    % TODO: Put input data validation lines here

    % Initialize GUI elements
    graphics_toolkit qt;

    % Define general padding value for GUI elements in pixels
   pix_pad = 6;

    % Spawn GUI elements
    main_figure = figure( ...
        'name', 'GUI Image Show', ...
        'sizechangedfcn', @update_main_figure ...
        );

    main_panel = uipanel( ...
        'parent', main_figure ...
        );

    % Get main panel draw area extents in pixels
    mps = getpixelposition(main_panel);

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
        'parent', main_panel, ...
        'position', elpos ...
        );
    imshow(I, 'parent', image_view);

    % Generate structure to store and pass to callbacks user data and GUI
    % elements handles
    h = guihandles(main_figure);
    h.pix_pad = pix_pad;
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
