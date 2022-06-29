display('Item Data Model Loaded');

function item = newItem(title, value)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItem';
    use_case_a = ' -- item = newFilm()';
    use_case_b = ' -- item = newFilm(title, value)';

    % Validate input arguments ------------------------------------------------

    % Define function parameters names and array for keeping values
    parameter = {'title', 'value'};
    par_value = {title, value};

    % Validate number of input arguments
    if(0 ~= nargin && length(parameter) ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate user supplied values, if any
    if(length(parameter) == nargin)
        idx = 1;
        while(length(parameter) >= idx)
            if(~ischar(par_value{idx}) || isempty(par_value{idx}))
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
    item.title = title;
    item.value = value;

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

