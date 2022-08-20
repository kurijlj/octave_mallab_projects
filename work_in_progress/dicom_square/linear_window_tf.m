function result = linear_window_tf (bit_depth, window, level)
    switch (bit_depth)
        case "uint8"
            rho_min = 0;
            rho_max = power(2, 8) - 1;

        case "uint16"
            rho_min = 0;
            rho_max = power(2, 16) - 1;

        case "int8"
            rho_min = -(power(2, 8) / 2);
            rho_max = (power(2, 8) / 2) - 1;

        case "int16"
            rho_min = -(power(2, 16) / 2);
            rho_max = (power(2, 16) / 2) - 1;

        otherwise
            error(
                "linear_window_tf: Unsupported pixel type",
                "Image pixel data type not supported"
                );

    endswitch;

    min_pixel_val = 0;
    max_pixel_val = 255;
    range        = rho_max - rho_min + 1;
    window_lower = level - window / 2 - rho_min;
    window_upper = level + window / 2 - rho_min;

    if((rho_min > (level - window / 2))
        || (rho_max < (level + window / 2)))
        % printf(
        %     "rho_min: %d\nrho_max: %d\nwindow_lower: %d\nwindow_upper: %d\n",
        %     rho_min, rho_max, (level - window / 2), window_upper
        %     );
        error(
            "linear_window_tf: W/L out of range",
            "Window / Level is out of range"
            );
    endif;

    % Because it holds pixel values "result" must be of type "uint8"
    result = uint8(zeros((rho_max - rho_min) + 1, 1));

    for i = 1:range
        if(i <= window_lower)
            result(i,1) = min_pixel_val;
        elseif(i >= window_upper)
            result(i,1) = max_pixel_val;
        else
            result(i,1) = uint8(
                (max_pixel_val / window) * (i - window_lower)
                );
        endif;
    endfor;

endfunction;
