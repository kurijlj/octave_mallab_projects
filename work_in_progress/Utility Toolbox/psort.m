function [as, bs] = psort(a, b)
    idxi = 1;
    while(max([numel(a), numel(b)]) >= idxi)
        if(numel(a) >= idxi)
            grt_a = a(idxi);
        endif;

        if(numel(b) >= idxi)
            grt_b = b(idxi);
        endif;

        idxj = 1;
        while(max([numel(a), numel(b)]) >= idxj)
            if(numel(a) >= idxi && numel(a) >= idxj)
                if(a(idxj) > grt_a)
                    grt_a = a(idxj);
                    a(idxj) = a(idxi);
                    a(idxi) = grt_a;

                endif;

            endif;

            if(numel(b) >= idxi && numel(b) >= idxj)
                if(b(idxj) > grt_b)
                    grt_b = b(idxj);
                    b(idxj) = b(idxi);
                    b(idxi) = grt_b;

                endif;

            endif;

            idxj++;

        endwhile;

        idxi++;

    endwhile;

    as = a; bs = b;

endfunction;
