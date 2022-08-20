gui_commons_version = '1.0';

% -----------------------------------------------------------------------------
%
% Function 'guiObjectTag':
%
% Use:
%       -- tag = guiObjectTag(hsrc)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function tag = guiObjectTag(hsrc)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'guiObjectTag';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hsrc)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate hsrc argument
    if(~ishghandle(hsrc))
        error( ...
            '%s: hsrc must be handle to a graphics object', ...
            fname
            );

    endif;

    tag = NaN;

    % Get containing figure and handles to all children GUI objects
    hfig = ancestor(hsrc, 'figure');
    handles = guihandles(hfig);
    fn = fieldnames(handles);

    % Traverse fieldnames and match tag by object handle
    idx = 1;
    while(numel(fn) >= idx)
        if(isequal(hsrc, getfield(handles, fn{idx})))
            tag = fn{idx};

        endif;

        idx = idx + 1;

    endwhile;

endfunction;
