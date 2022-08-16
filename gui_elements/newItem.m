function item = newItem(title, value)
    function result = itemInstance(varargin)
        msg = varargin{1};

        if(isequal('str', msg))
            result = sprintf('Item(%s, %s)', title, value);

        elseif(isequal('title', msg))
            result = title;

        elseif(isequal('value', msg))
            result = value;

        elseif(isequal('change_value', msg))
            new_value = varargin{2};
            result = newItem(title, new_value);

        else
            error('Item: Unknown message: %s', msg);

        endif;

    endfunction;

    item = @itemInstance;

endfunction;
