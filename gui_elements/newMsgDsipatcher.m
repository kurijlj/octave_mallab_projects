function result = newMsgDsipatcher(hparent, hbtn1, hbtn2)
    function Dispatcher(varargin)
        hsrc = varargin{1};
        evt = varargin{2};
        msg = varargin{3};

        if(isequal(hsrc, hparent))
            if(isequal('enable', msg))
                set(hbtn1, 'enable', 'on');
                set(hbtn2, 'enable', 'on');

            elseif(isequal('disable', msg))
                set(hbtn1, 'enable', 'off');
                set(hbtn2, 'enable', 'off');

            elseif(isequal('inactive', msg))
                set(hbtn1, 'enable', 'inactive');
                set(hbtn2, 'enable', 'inactive');

            endif;

        elseif(isequal(hsrc, hbtn1))
            if(isequal('clicked', msg))
                state = get(hbtn2, 'enable');
                if(isequal('on', state))
                    set(hbtn2, 'enable', 'off');
                else
                    set(hbtn2, 'enable', 'on');
                endif;

            endif;

        elseif(isequal(hsrc, hbtn2))
            if(isequal('clicked', msg))
                state = get(hbtn1, 'enable');
                if(isequal('on', state))
                    set(hbtn1, 'enable', 'off');
                else
                    set(hbtn1, 'enable', 'on');
                endif;

            endif;
        endif;

    endfunction;

    result = @Dispatcher;

endfunction;
