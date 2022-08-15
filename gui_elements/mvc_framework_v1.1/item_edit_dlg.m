item_edit_dlg_version = '1.0';

source('./gui_commons.m');
source('./app_uistyle_model.m');
source('./item_data_model.m');
source('./item_edit_view.m');
source('./control_panel_view.m');

% -----------------------------------------------------------------------------
%
% Function 'itemEditDlgNewDlg':
%
% Use:
%       -- itemEditDlgNewDlg(item)
%       -- itemEditDlgNewDlg(..., "PROPERTY", VALUE, ...)
%       -- hdlg = itemEditDlgNewDlg(...)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hdlg = itemEditDlgNewDlg(varargin)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgNewDlg';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(item)' ...
        }, '');
    use_case_b = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(..., "PROPERTY", VALUE, ...)' ...
        }, '');
    use_case_c = strjoin({ ...
        ' -- hview = ', ...
        fname, ...
        '(...)' ...
        }, '');

    % Define number of supported positional parameters ------------------------

    % Define number of supported positional (numerical) parameters
    numpos = 1;

    % Define number of supported optional parameters
    numopt = 5;

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments. We determin the minimum number of
    % input arguments as number of suported positional arguments (numpos). The
    % number of maximal possible input arguments we determine as sum of numpos
    % and number of optional parameters multiplied by two (this takes into
    % account values of supplied optional parameters)
    narginchk(numpos, numpos + 2*numopt);

    % Parse arguments
    [ ...
        pos, ...
        dlg_tag, ...
        title, ...
        uistyle, ...
        hparent, ...
        on_dlg_result_callback ...
        ] = parseparams( ...
        varargin, ...
        'dlg_tag', 'item_edit_dlg', ...
        'title', 'Item Edit View', ...
        'uistyle', appUiStyleModelNewUiStyle(), ...  % Use default UI style
        'parent', NaN, ...  %WARNING: do not set this to 0 it is the result of groot()!
        'OnDlgResultCallback', NaN ...
        );

    % Validate the number of positional parameters
    if(numpos ~= numel(pos))
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b, ...
            use_case_c ...
            );

    endif;

    % Validate argument values ------------------------------------------------

    % Validate item argument
    item = pos{1};
    if(~itemDataModelIsItemObj(item))
        error( ...
            '%s: item must be an instance of the Item Data Model data structure', ...
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

    % Validate title argument
    if(~ischar(title))
        error( ...
            '%s: title must be a character array', ...
            fname
            );
    endif;

    % Validate uistyle argument
    if(~appUiStyleModelIsUiStyleObj(uistyle))
        error( ...
            '%s: uistyle must be an instance of the App UI Style data structure', ...
            fname
            );

    endif;

    % Validate hparent argument
    if(~isfigure(hparent) && ~isnan(hparent))
        error( ...
            '%s: hparent must be handle to a figure or NaN', ...
            fname
            );

    endif;

    % Validate item_modified_callback argument
    if( ...
            ~is_function_handle(on_dlg_result_callback) ...
            && ~isnan(on_dlg_result_callback) ...
            )
        error( ...
            '%s: on_dlg_result_callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Create dialog figure ----------------------------------------------------

    % Check if we have parent object
    if(isnan(hparent))
        % We don't have handle to a parent UI container, so we need to run 'Item
        % List View' as a standalone application, within it's own figure and
        % with underlying app_data

        % Initialize GUI toolkit
        graphics_toolkit qt;

        % Create figure and define it as parent to 'Item' view
        hdlg = figure( ...
            'name', title, ...
            'menubar', 'none', ...
            'tag', dlg_tag ...
            );

    else
        % We have a handle to the parent figure
        hdlg = figure( ...
            'parent', hparent, ...
            'name', title, ...
            'menubar', 'none', ...
            'tag', dlg_tag ...
            );

    endif;

    % Create dialog view ------------------------------------------------------

    itemEditDlgLayoutView( ...
        hdlg, ...
        item, ...
        'dlg_tag', dlg_tag, ...
        'title', 'Edit Item', ...
        'uistyle', uistyle, ...
        'OnBtnPushCallback', itemEditDlgGenerateOnBtnPushCallback( ...
            hdlg, ...
            dlg_tag, ...
            hparent, ...
            on_dlg_result_callback ...
            ) ...
        );

    % Connect signals ---------------------------------------------------------

    % Connect size changed signal to it's slot
    set( ...
        hdlg, ...
        'sizechangedfcn', {@itemEditDlgUpdateView, dlg_tag, uistyle} ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% function 'itemEditDlgLayoutView':
%
% use:
%       -- itemEditDlgLayoutViewiew(hparent, item)
%       -- itemEditDlgLayoutView(..., "PROPERTY", VALUE, ...)
%       -- hview = itemEditDlgLayoutView(...)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hview = itemEditDlgLayoutView(varargin)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgLayoutView';
    use_case_a = strjoin({ ...
        ' -- hview = ', ...
        fname, ...
        '(hparent, item)' ...
        }, '');
    use_case_b = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(..., "PROPERTY", VALUE, ...)' ...
        }, '');
    use_case_c = strjoin({ ...
        ' -- hview = ', ...
        fname, ...
        '(...)' ...
        }, '');

    % Define number of supported positional parameters ------------------------

    % Define number of supported positional (numerical) parameters
    numpos = 2;

    % Define number of supported optional parameters
    numopt = 4;

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    narginchk(numpos, numpos + 2*numopt);

    % Parse arguments
    [ ...
        pos, ...
        dlg_tag, ...
        title, ...
        uistyle, ...
        on_btn_push_callback ...
        ] = parseparams( ...
        varargin, ...
        'dlg_tag', 'item_edit_dlg', ...
        'title', 'Edit Item', ...
        'uistyle', appUiStyleModelNewUiStyle(), ...  % Use default UI style
        'OnBtnPushCallback', NaN ...
        );

    % Validate the number of positional parameters
    if(numpos ~= numel(pos))
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b, ...
            use_case_c ...
            );

    endif;

    % Validate hparent argument
    hparent = pos{1};
    if(~isfigure(hparent))
        error( ...
            '%s: hparent must be handle to a figure', ...
            fname
            );

    endif;

    % Validate item argument
    item = pos{2};
    if(~itemDataModelIsItemObj(item))
        error( ...
            '%s: item must be an instance of the Item Data Model data structure', ...
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

    % Validate title argument
    if(~ischar(title))
        error( ...
            '%s: title must be a character array', ...
            fname
            );
    endif;

    % Validate uistyle argument
    if(~appUiStyleModelIsUiStyleObj(uistyle))
        error( ...
            '%s: uistyle must be an instance of the App UI Style data structure', ...
            fname
            );

    endif;

    % Validate callback argument
    if( ...
            ~is_function_handle(on_btn_push_callback) ...
            && ~isnan(on_btn_push_callback) ...
            )
        error( ...
            '%s: on_btn_push_callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Create containers for the views -----------------------------------------
    data_cntr = uipanel( ...
        'parent', hparent, ...
        'bordertype', 'none', ...
        'position', [0.0, 0.2, 1.0, 0.8] ...
        );
    controls_cntr = uipanel( ...
        'parent', hparent, ...
        'bordertype', 'none', ...
        'position', [0.0, 0.0, 1.0, 0.2] ...
        );

    % Create views ------------------------------------------------------------
    hdataview = itemEditViewNewView( ...
        item, ...
        'view_tag', strjoin({dlg_tag, 'data_view'}, '_'), ...
        'title', title, ...
        'uistyle', uistyle, ...
        'parent', data_cntr ...
        );
    hcontrolsview = controlPanelViewNewView( ...
        'view_tag', strjoin({dlg_tag, 'controls_view'}, '_'), ...
        'title', '', ...
        'uistyle', uistyle, ...
        'parent', controls_cntr, ...
        'OnBtnPushCallback', on_btn_push_callback ...
        );

    hview = hdataview;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditDlgUpdateView':
%
% Use:
%       -- itemEditDlgUpdateView(hsrc, evt, dlg_tag, uistyle)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function itemEditDlgUpdateView(hsrc, evt, dlg_tag, uistyle)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgUpdateView';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hsrc, evt, dlg_tag, uistyle)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(4 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate hsrc argument
    if(~isfigure(hsrc))
        error( ...
            '%s: hsrc must be handle to a figure', ...
            fname
            );

    endif;

    % We ignore evt argument

    % Validate dlg_tag argument
    if(~ischar(dlg_tag))
        error( ...
            '%s: dlg_tag must be a character array', ...
            fname
            );
    endif;

    % Validate uistyle argument
    if(~appUiStyleModelIsUiStyleObj(uistyle))
        error( ...
            '%s: uistyle must be an instance of the App UI Style data structure', ...
            fname
            );

    endif;

    % Construct view' tags ----------------------------------------------------
    dvtag = strjoin({dlg_tag, 'data_view'}, '_');
    cvtag = strjoin({dlg_tag, 'controls_view'}, '_');

    % Check if given tags exist in the figure handles table, and if they do call
    % the update functions for the each view
    hndls = guihandles(hsrc);
    if(isfield(hndls, dvtag) && isfield(hndls, cvtag))

        itemEditViewUpdateView(hsrc, [], dvtag, uistyle);
        controlPanelViewUpdateView(hsrc, [], cvtag, uistyle);

    endif;

endfunction;


% -----------------------------------------------------------------------------
%
% Function 'itemEditDlgSetItem':
%
% Use:
%       -- itemEditDlgSetItem(hdlg, dlg_tag, item)
%
% Description:
% TODO: Add function description here.
%
% -----------------------------------------------------------------------------
function itemEditDlgSetItem(hdlg, dlg_tag, item)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgSetItem';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hdlg, dlg_tag, item)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(3 ~= nargin)
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

    % Validate item argument
    if(~itemDataModelIsItemObj(item))
        error( ...
            '%s: item must be an instance of the Item Data Model data structure', ...
            fname
            );

    endif;

    % Get view handle ---------------------------------------------------------
    hview = getfield(guihandles(hdlg), strjoin({dlg_tag, 'data_view'}, '_'));

    % Update view -------------------------------------------------------------
    itemEditViewSetItem(hview, item)

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditDlgGetItem':
%
% Use:
%       -- item = itemEditDlgGetItem(hdlg, dlg_tag)
%
% Description:
% TODO: Add function description here.
%
% -----------------------------------------------------------------------------
function item = itemEditDlgGetItem(hdlg, dlg_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgGetItem';
    use_case_a = strjoin({ ...
        ' -- item = ', ...
        fname, ...
        '(hdlg, dlg_tag)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
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

    % Get view handle ---------------------------------------------------------
    hview = getfield(guihandles(hdlg), strjoin({dlg_tag, 'data_view'}, '_'));

    % Retuen field values as item object --------------------------------------
    item = itemEditViewGetItem(hview);

endfunction;
