function hsw = SlaveWindow(hmaster)
    hsw = struct();
    hsw.figure = figure('parent', hmaster, 'name', 'Slave');
    hsw.main_panel = uipanel( ...
        'parent', hsw.figure, ...
        'bordertype', 'none', ...
        'position', [0.00, 0.00, 1.00, 1.00] ...
        );

    position = slaveWindowElementsPosition(hsw.main_panel);

    hsw.btn_1 = uicontrol( ...
        'parent', hsw.main_panel, ...
        'string', 'Button 1', ...
        'units', 'normalized', ...
        'position', position(1, :) ...
        );
    hsw.btn_2 = uicontrol( ...
        'parent', hsw.main_panel, ...
        'string', 'Button 2', ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );
    hsw.btn_close = uicontrol( ...
        'parent', hsw.main_panel, ...
        'string', 'Close', ...
        'units', 'normalized', ...
        'position', position(3, :) ...
        );

    set(hsw.figure, 'sizechangedfcn', {@onWindowResize, hsw});

endfunction;

function position = slaveWindowElementsPosition(hcntr)
    cexts = getpixelposition(hcntr);
    padpx = 6;  % Padding in pixels
    padnw = padpx / cexts(3);
    padnh = padpx / cexts(4);
    rownh = (1 - 4*padnh) / 3;

    position = [];

    idx = 1;
    while(3 >= idx)
        position = [ ...
            position; ...
            padnw, ...
            (4 - idx)*padnh + (4 - (idx + 1))*rownh, ...
            1 - 2*padnw, ...
            rownh; ...
            ];

        idx = idx + 1;

    endwhile;

endfunction;

function onWindowResize(hsrc, evt, hsw)
    position = slaveWindowElementsPosition(hsw.main_panel);
    set(hsw.btn_1, 'position', position(1, :));
    set(hsw.btn_2, 'position', position(2, :));
    set(hsw.btn_close, 'position', position(3, :));

endfunction;