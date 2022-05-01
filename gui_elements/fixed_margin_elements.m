% 'fixed_margin_elements' is a function from the package: 'GUI Elements RND'
%
%  -- fixed_margin_elements()
%       Proof of concept for the algorithm for handling display of GUI elements
%       with fixed margin (padding) within containing GUI element

function fixed_margin_elements()

    % Initialize GUI elements
    graphics_toolkit qt;

    % Define general padding value for GUI elements in pixels
   pix_pad = 6;

    % Spawn GUI elements
    main_figure = figure( ...
        'name', 'Resizable Image Window Test', ...
        'sizechangedfcn', @update_main_figure ...
        );

    main_panel = uipanel( ...
        'parent', main_figure, ...
        'bordertype', 'beveledout'
        );

    % Get main panel draw area extents in pixels
    mps = getpixelposition(main_panel);

    % Calculate left and right panel extents
    rel_hpad = pix_pad/(mps(3) - mps(1));
    rel_vpad = pix_pad/(mps(4) - mps(2));

    % Calculate postion for the left panel within main panel
    elpos = [ ...
        rel_hpad, ...
        rel_vpad, ...
        0.5 - 2*rel_hpad, ...
        1 - 2*rel_vpad ...
        ];

    % Initialize left panel and set it's position
    left_panel = uipanel( ...
        'parent', main_panel, ...
        'bordertype', 'beveledout',
        'position', elpos
        );

    % Calculate postion for the left panel within main panel
    elpos = [ ...
        0.5 + rel_hpad, ...
        rel_vpad, ...
        0.5 - 2*rel_hpad, ...
        1 - 2*rel_vpad ...
        ];

    % Initialize left panel and set it's position
    right_panel = uipanel( ...
        'parent', main_panel, ...
        'bordertype', 'beveledout',
        'position', elpos
        );

    % Generate structure to store and pass to callbacks user data and GUI
    % elements handles
    h = guihandles(main_figure);
    h.pix_pad = pix_pad;
    h.main_figure = main_figure;
    h.main_panel = main_panel;
    h.left_panel = left_panel;
    h.right_panel = right_panel;

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

                % Calculate and set new position for the left panel
                elpos = [ ...
                    rel_hpad, ...
                    rel_vpad, ...
                    0.5 - 2*rel_hpad, ...
                    1 - 2*rel_vpad ...
                    ];
                set(h.left_panel, 'position', elpos);

                % Calculate and set new position for the right panel
                elpos = [ ...
                    0.5 + rel_hpad, ...
                    rel_vpad, ...
                    0.5 - 2*rel_hpad, ...
                    1 - 2*rel_vpad ...
                    ];
                set(h.right_panel, 'position', elpos);

        endswitch;

    endif;

endfunction;
