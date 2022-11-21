function arr = extract_profile(data, c)
    idx = 1;
    arr = zeros(1, 2);

    while(size(data, 1) >= idx)
        if(0.0 < data(idx, c))
            if(1 == idx)
                arr(idx, :) = [data(idx, 1), data(idx, c)];

            else
                arr(end+1, :) = [data(idx, 1), data(idx, c);];

            endif;

        endif;

        ++idx;

    endwhile;

endfunction;
