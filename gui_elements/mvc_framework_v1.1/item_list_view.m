item_list_view_version = '1.0';

source('./gui_commons.m');
source('./app_uistyle_model.m');
source('./item_list_selection_model.m');
source('./item_edit_dlg.m');

% -----------------------------------------------------------------------------
%
% Function 'itemListViewNewView':
%
% Use:
%       -- itemListViewNewView(item_list)
%       -- itemListViewNewView(..., "PROPERTY", VALUE, ...)
%       -- hview = itemListViewNewView(...)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hview = itemListViewNewView(varargin)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewNewView';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(item_list)' ...
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
        view_tag, ...
        title, ...
        uistyle, ...
        hparent, ...
        item_selection_callback, ...
        item_add_callback, ...
        item_remove_callback ...
        ] = parseparams( ...
        varargin, ...
        'view_tag', 'item_list_view', ...
        'title', 'Item List View', ...
        'uistyle', appUiStyleModelNewUiStyle(), ...  % Use default UI style
        'parent', NaN, ...  %WARNING: do not set this to 0 it is the result of groot()!
        'ItemSelectionCallback', NaN, ...
        'ItemAddCallback', NaN, ...
        'ItemRemoveCallback', NaN ...
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

    % Validate item_list argument
    item_list = pos{1};
    if(~itemListModelIsItemListObj(item_list))
        error( ...
            '%s: item_list must be an instance of the Item List data structure', ...
            fname
            );

    endif;

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
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
    if(~isnan(hparent) && ~ishghandle(hparent))
        error( ...
            '%s: parent must be handle to a graphics object', ...
            fname
            );

    endif;

    % Validate item_selection_callback argument
    if( ...
            ~is_function_handle(item_selection_callback) ...
            && ~isnan(item_selection_callback) ...
            )
        error( ...
            '%s: item_selection_callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Validate item_add_callback argument
    if( ...
            ~is_function_handle(item_add_callback) ...
            && ~isnan(item_add_callback) ...
            )
        error( ...
            '%s: item_add_callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Validate item_remove_callback argument
    if( ...
            ~is_function_handle(item_remove_callback) ...
            && ~isnan(item_remove_callback) ...
            )
        error( ...
            '%s: item_remove_callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Check if we have parent object
    if(isnan(hparent))
        % We don't have handle to a parent UI container, so we need to run 'Item
        % List View' as a standalone application, within it's own figure and
        % with underlying app_data

        % Initialize GUI toolkit
        graphics_toolkit qt;

        % Create figure and define it as parent to 'Item' view
        hparent = figure( ...
            'name', 'Item List', ...
            'menubar', 'none', ...
            'tag', 'main_figure' ...
            );

        % Since we are running in our own figure connect selected item change
        % signal to the default callback
        item_selection_callback = @itemListViewSetSelectedItem;

    endif;

    % If we got an empty item list create some dummy data for display
    if(isempty(item_list))
        item_list = itemListModelNewList( ...
            itemDataModelNewItem('Uknown', '...') ...
            );

    endif;

    % Create new view
    hview = itemListViewLayoutView( ...
        hparent, ...
        item_list, ...
        'view_tag', view_tag, ...
        'title', title, ...
        'uistyle', uistyle, ...
        'ItemSelectionCallback', item_selection_callback ...
        );

    % Connect size changed signal to it's slot
    set( ...
        ancestor(hparent, 'figure'), ...
        'sizechangedfcn', {@itemListViewUpdateView, view_tag, uistyle} ...
        );

    % Save required app data
    app_data = guidata(hparent);
    app_data = setfield( ...
        app_data, ...
        strjoin({view_tag, 'data'}, '_'), ...
        itemListSelectionModelNewSelection(item_list) ...
        );
    guidata(hparent, app_data);

endfunction;

% -----------------------------------------------------------------------------
%
% function 'itemListViewLayoutView':
%
% use:
%       -- itemListViewLayoutView(hparent, item_list)
%       -- itemListViewNewView(..., "PROPERTY", VALUE, ...)
%       -- hview = itemListViewNewView(...)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hview = itemListViewLayoutView(varargin)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewLayoutView';
    use_case_a = strjoin({ ...
        ' -- hview = ', ...
        fname, ...
        '(hparent, item_list)' ...
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
        view_tag, ...
        title, ...
        uistyle, ...
        item_selection_callback, ...
        item_add_callback, ...
        item_remove_callback ...
        ] = parseparams( ...
        varargin, ...
        'view_tag', 'item_list_view', ...
        'title', 'Item List View', ...
        'uistyle', appUiStyleModelNewUiStyle(), ...  % Use default UI style
        'ItemSelectionCallback', NaN, ...
        'ItemAddCallback', NaN, ...
        'ItemRemoveCallback', NaN ...
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
    if(~ishghandle(hparent))
        error( ...
            '%s: hparent must be handle to a graphics object', ...
            fname
            );

    endif;

    % Validate item_list argument
    item_list = pos{2};
    if(~itemListModelIsItemListObj(item_list))
        error( ...
            '%s: item_list must be an instance of the Item List data structure', ...
            fname
            );

    endif;

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
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

    % Validate item_selection_callback argument
    if( ...
            ~is_function_handle(item_selection_callback) ...
            && ~isnan(item_selection_callback) ...
            )
        error( ...
            '%s: item_selection_callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Validate item_add_callback argument
    if( ...
            ~is_function_handle(item_add_callback) ...
            && ~isnan(item_add_callback) ...
            )
        error( ...
            '%s: item_add_callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Validate item_remove_callback argument
    if( ...
            ~is_function_handle(item_remove_callback) ...
            && ~isnan(item_remove_callback) ...
            )
        error( ...
            '%s: item_remove_callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Get figure containing the parent object ---------------------------------
    hfig = ancestor(hparent, 'figure');

    % Initialize gui elements positions ---------------------------------------
    position = itemListViewElementsPosition(hparent, uistyle);

    % Create 'Item List View' panel -------------------------------------------
    view_panel = uipanel( ...
        'parent', hparent, ...
        'title', title, ...
        'tag', view_tag, ...
        'position', position(1, :) ...
        );

    % Create 'Items' table ------------------------------------------------------
    view_table = uitable( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'table'}, '_'), ...
        'data', itemListModel2CellArray(item_list), ...
        'tooltipstring', 'Select row to select item', ...
        'columnname', {'Title', 'Value'}, ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );

    % Create a context menu for the table -------------------------------------

    % Create menu
    view_contex_menu = uicontextmenu( ...
        'parent', hfig, ...
        'tag', strjoin({view_tag, 'context_menu'}, '_') ...
        );

    % Create menu items
    uimenu( ...
        'parent', view_contex_menu, ...
        'tag', strjoin({view_tag, 'add_item'}, '_'), ...
        'label', 'Add Item ...', ...
        'callback', {@itemListViewOnContextMenuOpt, uistyle, 'add', NaN}, ...
        'enable', 'on' ...
        );
    remove_item = uimenu( ...
        'parent', view_contex_menu, ...
        'tag', strjoin({view_tag, 'remove_item'}, '_'), ...
        'label', 'Remove Selected Item ...', ...
        'callback', {@itemListViewOnContextMenuOpt, uistyle, 'remove', NaN}, ...
        'enable', 'off' ...
        );

    % Assign context menu to the table
    set(view_table, 'uicontextmenu', view_contex_menu);

    % Set callbacks
    set( ...
        view_table, ...
        'cellselectioncallback', { ...
            @itemListViewOnCellSelect, ...
            remove_item, ...
            item_selection_callback ...
            } ...
        );

    hview = view_panel;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewUpdateView':
%
% Use:
%       -- itemListViewUpdateView(hsrc, evt, view_tag, uistyle)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function itemListViewUpdateView(hsrc, evt, view_tag, uistyle)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewUpdateView';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hsrc, evt, view_tag, uistyle)' ...
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

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
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

    % Get figure handles
    figure_handles = guihandles(hsrc);

    % Check if the calling figure holds our view, else we ignore the signal
    if(isfield(figure_handles, view_tag))

        % Get GUI elements postions
        position = itemListViewElementsPosition( ...
            get(getfield(figure_handles, view_tag), 'parent'), ...
            uistyle ...
            );

        % Reset elements position
        set( ...
            getfield(figure_handles, view_tag), ...
            'position', position(1, :) ...
            );
        set( ...
            getfield(figure_handles, strjoin({view_tag, 'table'}, '_')), ...
            'position', position(2, :) ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewElementsPosition':
%
% Use:
%       -- position = itemListViewElementsPosition(hcntr, uistyle)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function position = itemListViewElementsPosition(hcntr, uistyle)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewElementsPosition';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hcntr, uistyle)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case_a ...
            );

    endif;

    % Validate hcntr argument
    if(~ishghandle(hcntr))
        error( ...
            '%s: hsrc must be handle to a graphics object', ...
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

    % Define return value as matrix -------------------------------------------
    position = [];

    % Calculate relative extents ----------------------------------------------
    cexts = getpixelposition(hcntr);
    horpadabs = uistyle.padding_px / cexts(3);
    verpadabs = uistyle.padding_px / cexts(4);
    btnwdtabs = uistyle.btn_width_px / cexts(3);
    clmwdtabs = uistyle.column_width_px / cexts(3);
    rowhghabs = uistyle.row_height_px / cexts(4);

    % Set padding for the main panel ------------------------------------------
    position = [ ...
        position; ...
        horpadabs, ...
        verpadabs, ...
        1.00 - 2*horpadabs, ...
        1.00 - 2*verpadabs; ...
        ];

    % Set table view position -------------------------------------------------
    position = [ ...
        position; ...
        horpadabs, ...
        verpadabs, ...
        1.00 - 2*horpadabs, ...
        1.00 - 2*verpadabs; ...
        ];

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewSetList':
%
% Use:
%       -- itemListViewSetList(hfview, item_list)
%
% Description:
% TODO: Add function description here.
%
% -----------------------------------------------------------------------------
function itemListViewSetList(hview, item_list)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewSetList';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hview, item_list)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate hiew argument
    if(~ishghandle(hview))
        error( ...
            '%s: hview must be handle to a graphics object', ...
            fname
            );

    endif;

    % Validate item_list argument
    if(~itemListModelIsItemListObj(item_list))
        error( ...
            '%s: item_list must be an instance of the Item List data structure', ...
            fname
            );

    endif;

    % Get handle to view's table ----------------------------------------------

    % Get view tag
    view_tag = guiObjectTag(hview);

    % Get containig figure handle
    hfig = ancestor(hview, 'figure');

    htable = getfield(guihandles(hfig), strjoin({view_tag, 'table'}, '_'));

    % Update item list table --------------------------------------------------
    set(htable, 'Data', itemListModel2CellArray(item_list));

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewSetSelectedItem':
%
% Use:
%       -- itemListViewSetSelectedItem(hview, idx)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function itemListViewSetSelectedItem(hview, idx)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewSetSelectedItem';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hview, idx)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate hview argument
    if(~ishghandle(hview))
        error( ...
            '%s: hview must be handle to a graphics object', ...
            fname
            );

    endif;

    % Validate idx argument
    validateattributes( ...
        idx, ...
        {'numeric'}, ...
        { ...
            '>=', 0, ...
            'finite', ...
            'integer', ...
            'nonempty', ...
            'nonnan', ...
            'scalar' ...
            }, ...
        fname, ...
        'idx' ...
        );

    % Change and save selected item index -------------------------------------

    % Get view tag
    view_tag = guiObjectTag(hview);

    % Get app data
    app_data = guidata(hview);
    selection = getfield( ...
        app_data, ...
        strjoin({view_tag, 'data'}, '_') ...
        );

    selection.selected_item = idx;

    % Save changes
    app_data = setfield( ...
        app_data, ...
        strjoin({view_tag, 'data'}, '_'), ...
        selection ...
        );
    guidata(hview, app_data);

    % Nothing has changed in the view, so don't update it

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewOnCellSelect':
%
% Use:
%       -- itemListViewOnCellSelect(hsrc, evt, hmenuitem, callback)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function itemListViewOnCellSelect(hsrc, evt, hmenuitem, callback=NaN)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewOnCellSelect';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hsrc, evt, hmenuitem, callback)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(3 ~= nargin && 4 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate hsrc argument
    if(~ishghandle(hsrc))
        error( ...
            '%s: hsrc must be handle to a graphics object', ...
            fname
            );

    endif;

    % Validate evt argument
    if(~isstruct(evt) || ~isfield(evt, 'Indices'))
        error( ...
            '%s: evt does not contain complete data to execute callback', ...
            fname
            );

    endif;

    % Validate hmenuitem argument
    if(~ishghandle(hmenuitem))
        error( ...
            '%s: hemnuitem must be handle to a graphics object', ...
            fname
            );

    endif;

    % Validate callback argument
    if(~is_function_handle(callback) && ~isnan(callback))
        error( ...
            '%s: callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Process event -----------------------------------------------------------

    % Get selected cells
    idx = unique(evt.Indices(:, 1));

    % If user selected just a row idx will be a scalar holding row index
    if(2 == size(evt.Indices)(1) && 1 == numel(idx))

        % Execute callback for the selected item change
        if(is_function_handle(callback))
            callback(get(hsrc, 'parent'), idx);

        endif;

        % Enable 'Remove Item' option in the table's context menu
        set(hmenuitem, 'enable', 'on');

    else
        % User selected a single cell or a column, set selected item index
        % to 'no selection' (0)

        % Execute callback for the selected item change
        if(is_function_handle(callback))
            callback(get(hsrc, 'parent'), 0);

        endif;

        % Disable 'Remove Item' option in the table's context menu
        set(hmenuitem, 'enable', 'off');

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewOnContextMenuOpt':
%
% Use:
%       -- itemListViewOnContextMenuOpt(hsrc, evt, uistyle, option, callback)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function itemListViewOnContextMenuOpt(hsrc, evt, uistyle, option, callback)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewOnContextMenuOpt';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hsrc, evt, uistyle, option, callback)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(5 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate hsrc argument
    if(~ishghandle(hsrc))
        error( ...
            '%s: hsrc must be handle to a graphics object', ...
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

    % Validate option argument
    validatestring( ...
        option, ...
        {'add', 'remove'}, ...
        fname, ...
        'option' ...
        );

    % Validate callback argument
    if( ...
            ~is_function_handle(callback) ...
            && ~isnan(callback) ...
            )
        error( ...
            '%s: item_selection_callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Process event -----------------------------------------------------------

    if(isequal('add', option))
        itemEditDlgNewDlg( ...
            itemDataModelNewItem('Item #A', 'A'), ...
            'dlg_tag', 'add_item_dlg', ...
            'title', 'Add Item', ...
            'uistyle', uistyle, ...
            'parent', ancestor(hsrc, 'figure'), ...
            'OnDlgResultCallback', @itemListViewDefaultOnAddItemCallback ...
            );

    else
        display('Remove item in progress ...');

    endif;

endfunction;

function itemListViewDefaultOnAddItemCallback(hsrc, evt, item)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewDefaultOnAddItemCallback';
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
            fname
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
            evt.Message
            );

    endif;

    % Validate item argument
    if(~(isstruct(item) && itemDataModelIsItemObj(item)) && ~isnan(item))
        error( ...
            '%s: item must be an instance of the Item Data Model data structure or NaN', ...
            fname
            );

    endif;

    % User accepted input. Store data to workspace namespace ------------------

    % Save item into the workspace's namespace
    assignin('base', 'new_item', item)

endfunction;
