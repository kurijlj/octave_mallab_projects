function hmw = MainWindow()
    hmw = struct();
    hmw.figure = figure('name', 'Master');
    hmw.main_panel = uipanel( ...
        'parent', hmw.figure, ...
        'bordertype', 'none', ...
        'position', [0.00, 0.00, 1.00, 1.00] ...
        );

    position = mainWindowElementsPosition(hmw.main_panel);

    hmw.btn_launch = uicontrol( ...
        'parent', hmw.main_panel, ...
        'string', 'Launch Slave', ...
        'units', 'normalized', ...
        'position', position(1, :) ...
        );
    hmw.btn_enable = uicontrol( ...
        'parent', hmw.main_panel, ...
        'string', 'Enable', ...
        'units', 'normalized', ...
        'enable', 'off', ...
        'position', position(2, :) ...
        );
    hmw.btn_disable = uicontrol( ...
        'parent', hmw.main_panel, ...
        'string', 'Disable', ...
        'units', 'normalized', ...
        'enable', 'off', ...
        'position', position(3, :) ...
        );
    hmw.btn_inactivate = uicontrol( ...
        'parent', hmw.main_panel, ...
        'string', 'Inactivate', ...
        'units', 'normalized', ...
        'enable', 'off', ...
        'position', position(4, :) ...
        );

    set(hmw.figure, 'sizechangedfcn', {@onWindowResize, hmw});

endfunction;

function position = mainWindowElementsPosition(hcntr)
    cexts = getpixelposition(hcntr);
    padpx = 6;  % Padding in pixels
    padnw = padpx / cexts(3);
    padnh = padpx / cexts(4);
    rownh = (1 - 5*padnh) / 4;

    position = [];

    idx = 1;
    while(4 >= idx)
        position = [ ...
            position; ...
            padnw, ...
            (5 - idx)*padnh + (5 - (idx + 1))*rownh, ...
            1 - 2*padnw, ...
            rownh; ...
            ];

        idx = idx + 1;

    endwhile;

endfunction;

function onWindowResize(hsrc, evt, hmw)
    position = mainWindowElementsPosition(hmw.main_panel);
    set(hmw.btn_launch, 'position', position(1, :));
    set(hmw.btn_enable, 'position', position(2, :));
    set(hmw.btn_disable, 'position', position(3, :));
    set(hmw.btn_inactivate, 'position', position(4, :));

endfunction;