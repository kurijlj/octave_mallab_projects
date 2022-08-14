% -----------------------------------------------------------------------------
%
% Function 'itemEditDlgGenerateOnBtnPushCallback':
%
% Use:
%       -- result = itemEditDlgGenerateOnBtnPushCallback(hdlg, dlg_tag)
%
% Description:
% TODO: Add function description here.
%
% -----------------------------------------------------------------------------
function result = itemEditDlgGenerateOnBtnPushCallback( ...
        hdlg, ...
        dlg_tag, ...
        hparent, ...
        callback ...
        )

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgGenerateOnBtnPushCallback';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hdlg, dlg_tag)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(4 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate hdlg argument
    if(~isfigure(hdlg))
        error( ...
            '%s: hdlg must be handle to a figure', ...
            fname
            );

    endif;

    % Validate dlg_tag argument
    if(~ischar(dlg_tag))
        error( ...
            '%s: dlg_tag must be a character array', ...
            fname
            );
    endif;

    % Validate hparent argument
    if(~isfigure(hparent))
        error( ...
            '%s: hparent must be handle to a figure', ...
            fname
            );

    endif;

    % Validate callback argument
    if( ...
            ~is_function_handle(callback) ...
            && ~isnan(callback) ...
            )
        error( ...
            '%s: callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    function itemEditDlgOnBtnPushSelfCallback(hcpview, option)

        % Store function name into variable
        % for easier management of error messages -----------------------------
        fname = 'itemEditDlgOnBtnPushSelfCallback';
        use_case_a = strjoin({ ...
            ' -- ', ...
            fname, ...
            '(hcpview, option)' ...
            }, '');

        % Validate input arguments --------------------------------------------

        % Validate number of input arguments
        if(2 ~= nargin)
            error( ...
                'Invalid call to %s. Correct usage is:\n%s', ...
                fname, ...
                use_case_a ...
                );

        endif;

        % Validate hcpview argument
        if(~ishghandle(hcpview))
            error( ...
                '%s: hcpview must be handle to a graphics object', ...
                fname
                );

        endif;

        % Validate option argument
        validatestring( ...
            option, ...
            {'accept', 'cancel'}, ...
            fname, ...
            'option' ...
            );

        % Check if the given dialog is a parent of the signal source ----------
        if(~isequal(hdlg, ancestor(hcpview, 'figure')))
            error( ...
                '%s: given hcpview does not belong to the given hdlg', ...
                fname
                );

        endif;

        if(isequal('accept', option))

            % User accepted input. Store data to workspace namespace ----------

            % Get data from the data view
            hdataview = getfield( ...
                guihandles(hdlg), ...
                strjoin({dlg_tag, 'data_view'}, '_') ...
                );

            % Create item from view's fields
            item = itemEditViewGetItem(hdataview);

            % Save item into the workspace's namespace
            assignin('base', 'new_item', item)

        endif;

    endfunction;

    function itemEditDlgOnBtnPushParentCallback(hcpview, option)

        % Store function name into variable
        % for easier management of error messages -----------------------------
        fname = 'itemEditDlgOnBtnPushParentCallback';
        use_case_a = strjoin({ ...
            ' -- ', ...
            fname, ...
            '(hcpview, option)' ...
            }, '');

        % Validate input arguments --------------------------------------------

        % Validate number of input arguments
        if(2 ~= nargin)
            error( ...
                'Invalid call to %s. Correct usage is:\n%s', ...
                fname, ...
                use_case_a ...
                );

        endif;

        % Validate hcpview argument
        if(~ishghandle(hcpview))
            error( ...
                '%s: hcpview must be handle to a graphics object', ...
                fname
                );

        endif;

        % Validate option argument
        validatestring( ...
            option, ...
            {'accept', 'cancel'}, ...
            fname, ...
            'option' ...
            );

        % Check if the given dialog is a parent of the signal source ----------
        if(~isequal(hdlg, ancestor(hcpview, 'figure')))
            error( ...
                '%s: given hcpview does not belong to the given hdlg', ...
                fname
                );

        endif;

        item = NaN;  % Set item value to default
        if(isequal('accept', option))

            % User accepted input. Store data to workspace namespace ----------

            % Get data from the data view
            hdataview = getfield( ...
                guihandles(hdlg), ...
                strjoin({dlg_tag, 'data_view'}, '_') ...
                );

            % Create item from view's fields
            item = itemEditViewGetItem(hdataview);

        endif;

        % Pass item value to the callback supplied by the parent
        if(is_function_handle(callback))
            evt = struct();
            evt.Message = 'accept_item';
            callback(get(hcpview, 'parent'), evt, item);

        endif;

    endfunction;

    if(isfigure(hparent))
        result = @itemEditDlgOnBtnPushParentCallback;

    else
        result = @itemEditDlgDefaultOnBtnPushCallback;

    endif;

endfunction;
