function result = masterController(hparent, hbtn1, hbtn2, hbtn3, hslave)
    function result = Controller(varargin)
        hsrc = varargin{1};
        evt = varargin{2};
        msg = varargin{3};

        if(ishghandle(hsrc))
            if(isequal(hsrc, hbtn1))
                if(isequal('clicked', msg))
                    callback = varargin{4};
                    result = callback(hparent, [], 'enable');

                endif;

            elseif(isequal(hsrc, hbtn2))
                if(isequal('clicked', msg))
                    callback = varargin{4};
                    result = callback(hparent, [], 'disable');

                endif;

            elseif(isequal(hsrc, hbtn3))
                if(isequal('clicked', msg))
                    callback = varargin{4};
                    result = callback(hparent, [], 'inactivate');

                endif;

            endif;

        elseif(isnan(hsrc))
            if(isequal('get', msg))
                property = varargin{4};

                if(isequal('hparent', property))
                    result = hparent;

                elseif(isequal('hbtn1', property))
                    result = hbtn1;

                elseif(isequal('hbtn2', property))
                    result = hbtn2;

                elseif(isequal('hslave', property))
                    result = hslave;

                endif;

            elseif(isequal('set', msg))
                property = varargin{4};
                value = varargin{5};

                if(isequal('hbtn1', property))
                    result = masterController(hparent, value, hbtn2, hslave);

                elseif(isequal('hbtn2', property))
                    result = masterController(hparent, hbtn1, value, hslave);

                elseif(isequal('hslave', property))
                    result = masterController(hparent, hbtn1, hbtn2, value);

                endif;


            endif;

        endif;

    endfunction;

    result = @Controller;

endfunction;
