function result = slaveController(hparent, hbtn1, hbtn2, hmaster)
    function result = Controller(varargin)
        hsrc = varargin{1};
        evt = varargin{2};
        msg = varargin{3};

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

                endif;

            elseif(isequal(hsrc, hbtn2))
                if(isequal('clicked', msg))
                    set(hmaster, 'name', 'Master: Button2 Clicked!');

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

                elseif(isequal('hmaster', property))
                    result = hmaster;

                endif;

            elseif(isequal('set', msg))
                property = varargin{4};
                value = varargin{5};

                if(isequal('hbtn1', property))
                    result = masterController(hmaster, hparent, value, hbtn2);

                elseif(isequal('hbtn2', property))
                    result = masterController(hmaster, hparent, hbtn1, value);

                endif;


            endif;

        endif;

    endfunction;

    result = @Controller;

endfunction;
