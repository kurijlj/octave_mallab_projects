function results = slaveController(hparent, hbtn1, hbtn2, hbtnc, hmaster)
    function result = Controller(varargin)
        hsrc = varargin{1};
        evt = varargin{2};
        msg = varargin{3};
        result = NaN;

        if(ishghandle(hsrc))
            if(isequal(hsrc, hmaster))
                if(isequal('enable', msg))
                    set(hbtn1, 'enable', 'on');
                    set(hbtn2, 'enable', 'on');
                    result = 'on';

                elseif(isequal('disable', msg))
                    set(hbtn1, 'enable', 'off');
                    set(hbtn2, 'enable', 'off');
                    result = 'off';

                elseif(isequal('inactivate', msg))
                    set(hbtn1, 'enable', 'inactive');
                    set(hbtn2, 'enable', 'inactive');
                    result = 'inactivate';

                endif;

            elseif(isequal(hsrc, hbtn1))
                if(isequal('clicked', msg))
                    set(hmaster, 'name', 'Master: Button1 Clicked!');
                    result = 'click1';

                endif;

            elseif(isequal(hsrc, hbtn2))
                if(isequal('clicked', msg))
                    set(hmaster, 'name', 'Master: Button2 Clicked!');
                    result = 'click2';

                endif;

            elseif(isequal(hsrc, hbtnc))
                if(isequal('clicked', msg))
                    callback = varargin{4};
                    result = callback();
                    close(hparent);

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

                elseif(isequal('hbtnc', property))
                    result = hbtnc;

                elseif(isequal('hmaster', property))
                    result = hmaster;

                else
                    result = NaN;

                endif;

            endif;

        endif;

    endfunction;

    results = @Controller;

endfunction;
