display('Item Data Model Loaded');

function item = newItem(item_title, item_value)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItem';
    use_case = ' -- item = newFilm(item_title, item_value)';

    % Validate input arguments ------------------------------------------------

    % Define function parameters names
    parameter = {'item_title', 'item_value'};

    % Validate number of input arguments
    if(numel(parameter) ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate user supplied values, if any
    if(numel(parameter) == nargin)
        prm_val = {item_title, item_value};
        idx = 1;
        while(numel(parameter) >= idx)
            if(~ischar(prm_val{idx}) || isempty(prm_val{idx}))
                error( ...
                    '%s: %s must be a non-empty string', ...
                    fname, ...
                    parameter{idx} ...
                    );

            endif;

            idx = idx + 1;

        endwhile;

    endif;

    % Create and populate 'Item' structure ------------------------------------
    item = struct();
    item.title = item_title;
    item.value = item_value;

endfunction;

function result = isItemDataStruct(obj)

    % Define common message strings
    fname = 'isItemDataStruct';
    use_case = ' -- result = isItemDataStruct(film_obj)';

    % Validate input arguments
    if(1 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    result = false;
    if( ...
            isstruct(obj) ...
            && isfield(obj, 'title') ...
            && ischar(obj.title) ...
            && ~isempty(obj.title) ...
            && isfield(obj, 'value') ...
            && ischar(obj.value) ...
            && ~isempty(obj.value) ...
            )
        result = true;

    endif;

endfunction;

