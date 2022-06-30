display('Item View Loaded');

function newItemView(item, hparent)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemView';
    use_case = ' -- result = newItemView(item, hparent)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Create view panel -------------------------------------------------------

endfunction;

function updateItemView(item)
endfunction;
