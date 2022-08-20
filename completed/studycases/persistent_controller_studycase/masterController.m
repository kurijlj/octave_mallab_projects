function resultm = masterController(hparent, hbtnl, hbtne, hbtnd, hbtni, hslave)
    function result = Controller(varargin)
        hsrc = varargin{1};
        evt = varargin{2};
        msg = varargin{3};
        result = NaN;

        if(ishghandle(hsrc))
            if(isequal(hsrc, hbtnl))
                if(isequal('clicked', msg))
                    callback = varargin{4};
                    value = varargin{5};
                    result = callback(value);

                endif;

            elseif(isequal(hsrc, hbtne))
                if(isequal('clicked', msg))
                    if(ishghandle(hslave))
                        callback = varargin{4};
                        result = callback(hparent, [], 'enable');

                    endif;

                endif;

            elseif(isequal(hsrc, hbtnd))
                if(isequal('clicked', msg))
                    if(ishghandle(hslave))
                        callback = varargin{4};
                        result = callback(hparent, [], 'disable');

                    endif;

                endif;

            elseif(isequal(hsrc, hbtni))
                if(isequal('clicked', msg))
                    if(ishghandle(hslave))
                        callback = varargin{4};
                        result = callback(hparent, [], 'inactive');

                    endif;

                endif;

            endif;

        elseif(isnan(hsrc))
            if(isequal('get', msg))
                property = varargin{4};

                if(isequal('hparent', property))
                    result = hparent;

                elseif(isequal('hbtnl', property))
                    result = hbtnl;

                elseif(isequal('hbtne', property))
                    result = hbtne;

                elseif(isequal('hbtnd', property))
                    result = hbtnd;

                elseif(isequal('hbtni', property))
                    result = hbtni;

                elseif(isequal('hslave', property))
                    result = hslave;

                endif;

            elseif(isequal('set', msg))
                property = varargin{4};
                value = varargin{5};

                if(isequal('hslave', property))
                    result = masterController( ...
                        hparent, ...
                        hbtnl, ...
                        hbtne, ...
                        hbtnd, ...
                        hbtni, ...
                        value ...
                        );

                endif;

            endif;

        endif;

    endfunction;

    resultm = @Controller;

endfunction;
