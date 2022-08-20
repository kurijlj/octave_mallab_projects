% -----------------------------------------------------------------------------
%
% Function 'itemListViewGenerateOnAddItemCallback':
%
% Use:
%       -- result = itemListViewGenerateOnAddItemCallback(view_tag)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function result = itemListViewGenerateOnAddItemCallback(view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewGenerateOnAddItemCallback';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(view_tag)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
            fname ...
            );
    endif;

    function itemListViewOnAddItemCallback(hsrc, evt, item)

        % Store function name into variable
        % for easier management of error messages ---------------------------------
        fname = 'itemListViewOnAddItemCallback';
        use_case_a = strjoin({ ...
            ' -- ', ...
            fname, ...
            '(hsrc, evt, item)' ...
            }, '');

        % Validate input arguments ------------------------------------------------

        % Validate number of input arguments
        if(3 ~= nargin)
            error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

        endif;

        % Validate hsrc argument
        if(~ishghandle(hsrc))
            error( ...
                '%s: hsrc must be handle to a graphics object', ...
                fname ...
                );

        endif;

        % Validate evt argument
        if(~isstruct(evt) ...
                || ~isfield(evt, 'Message') ...
                || ~isequal('accept_item', evt.Message) ...
                )
            error( ...
                '%s: unknown evt message: %s', ...
                fname,
                evt.Message ...
                );

        endif;

        % hfig = ancestor(hsrc, 'figure');
        % if(~isfield(guihandles(hfig), view_tag))
        %     error( ...
        %         '%s: given view_tag does not belong to parent figure', ...
        %         fname ...
        %         );
        % endif;

        % Validate item argument
        if(~(isstruct(item) && itemDataModelIsItemObj(item)) && ~isnan(item))
            error( ...
                '%s: item must be an instance of the Item Data Model data structure or NaN', ...
                fname ...
                );

        endif;

        % User accepted input. Store data to workspace namespace ------------------

        % Save item into the workspace's namespace
        assignin('base', strjoin({view_tag, 'new_item'}, '_'), item);

    endfunction;

    result = @itemListViewOnAddItemCallback;

endfunction;
