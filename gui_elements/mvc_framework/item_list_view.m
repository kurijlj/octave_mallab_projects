item_list_view_version = '1.0';

source('./app_uistyle_model.m');
source('./item_list_selection_model.m');

% -----------------------------------------------------------------------------
%
% Function 'itemListViewNewView':
%
% Use:
%       -- hfig = itemListViewNewView(view_tag, item_list)
%       -- hfig = itemListViewNewView(view_tag, item_list, huip)';
%
% Description:
% TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hfig = itemListViewNewView(view_tag, item_list, huip)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewNewView';
    use_case_a = ' -- hfig = itemListViewNewView(view_tag, item_list)';
    use_case_b = ' -- hfig = itemListViewNewView(view_tag, item_list, huip)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin && 3 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
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

    % Validate huip argument
    if(3 == nargin && ~ishandle(huip))
        error( ...
            '%s: huip must be handle to a graphics object', ...
            fname
            );

    endif;

    % Initialize variables for storing all relevant app data
    gduip = NaN;
    gddtp = NaN;

    if(2 == nargin)
        % We don't have handle to a parent UI container, so we need to run 'Item
        % List View' as a standalone application, within it's own figure and
        % with underlying app_data

        % Initialize GUI toolkit
        graphics_toolkit qt;

        % Create figure and define it as parent to 'Item' view
        huip = figure( ...
            'name', 'Item List', ...
            'menubar', 'none', ...
            'tag', 'main_figure' ...
            );
        hfig = huip;

        % Initialize structures for storing application relevant data
        gduip = struct();
        gduip.hdtp = huip;  % Set main figure as data container too
        gduip.app_uistyle = newAppUiStyle();
        gddtp = gduip;
        gddtp.app_data = struct();

    else
        % We have a handle to the parent container. get handle to the app
        % figure and validate underlying app_data structure
        hfig = gcf();
        gduip = guidata(hfig);

        % Check if object returned by guidata() contains all necessary fields
        if(~isfield(gduip, 'hdtp') || ~isfigure(gduip.hdtp))
            error( ...
                '%s: figure does not contain handle to data storage figure', ...
                fname
                );

        endif;
        if(~isfield(gduip, 'app_uistyle') || ~isAppUiStyleObject(gduip.app_uistyle))
            error( ...
                '%s: figure does not contain valid app ui style object', ...
                fname
                );

        endif;

        gddtp = guidata(gduip.hdtp);

        if(~isfield(gddtp, 'app_data') || ~isstruct(gddtp.app_data))
            error( ...
                '%s: data storage figure does not contain data storage', ...
                fname
                );

        endif;

    endif;

    view_data = itemListSelectionModelNewSelection( ...
        itemListModelNewList( ...
            itemDataModelNewItem('Empty', 'None') ...
            ) ...
        );
    if(~isempty(item_list))
        view_data = itemListSelectionModelNewSelection(item_list);

    endif;

    % save app data to data storage figure
    gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);
    guidata(gduip.hdtp, gddtp);

    itemListViewLayoutView(huip, view_tag);

    if(2 == nargin)
        % define callbacks for events we handle
        set( ...
            huip, ...
            'sizechangedfcn', {@itemListViewUpdateView, view_tag} ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% function 'itemListViewLayoutView':
%
% use:
%       -- itemListViewLayoutView(hparent, view_tag)
%
% Description:
% TODO: add function description here
%
% -----------------------------------------------------------------------------
function itemListViewLayoutView(hparent, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewLayoutView';
    use_case = ' -- itemListViewLayoutView(view_tag, hparent)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate hparent argument
    if(~ishandle(hparent))
        error( ...
            '%s: hparent must be handle to a graphics object', ...
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

    % Get figure user data
    hfigure = gcf();
    gduip = guidata(hfigure);

    % Check if object returned by guidata() contains all necessary fields
    if(~isfield(gduip, 'hdtp') || ~isfigure(gduip.hdtp))
        error( ...
            '%s: figure does not contain handle to data storage figure', ...
            fname
            );

    endif;
    if(~isfield(gduip, 'app_uistyle') || ~isAppUiStyleObject(gduip.app_uistyle))
        error( ...
            '%s: figure does not contain valid app ui style object', ...
            fname
            );

    endif;

    gddtp = guidata(gduip.hdtp);

    if(~isfield(gddtp, 'app_data') || ~isstruct(gddtp.app_data))
        error( ...
            '%s: data storage figure does not contain data storage', ...
            fname
            );

    endif;

    % Initialize gui elements positions ---------------------------------------
    position = itemListViewElementsPosition(hparent);

    % Create 'Item List View' panel -------------------------------------------
    view_panel = uipanel( ...
        'parent', hparent, ...
        'title', 'Item List', ...
        'tag', view_tag, ...
        'position', position(1, :) ...
        );

    % Create 'Items' table ------------------------------------------------------
    item_list_selection = getfield(gddtp.app_data, view_tag);
    view_table = uitable( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'table'}, '_'), ...
        'data', itemListModel2CellArray(item_list_selection.item_list), ...
        'tooltipstring', 'Select row to select item', ...
        'columnname', {'Title', 'Value'}, ...
        'cellselectioncallback', {@itemListViewOnCellSelect, view_tag}, ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );

    % Create a context menu for the table -------------------------------------

    % Create menu
    view_contex_menu = uicontextmenu( ...
        'parent', hfigure, ...
        'tag', strjoin({view_tag, 'context_menu'}, '_') ...
        );

    % Create menu items
    uimenu( ...
        'parent', view_contex_menu, ...
        'tag', strjoin({view_tag, 'add_item'}, '_'), ...
        'label', 'Add Item ...', ...
        'callback', {@itemListViewOnAddItem, view_tag}, ...
        'enable', 'on' ...
        );
    uimenu( ...
        'parent', view_contex_menu, ...
        'tag', strjoin({view_tag, 'remove_item'}, '_'), ...
        'label', 'Remove Selected Item ...', ...
        'callback', {@itemListViewOnRemoveSelectedItem, view_tag}, ...
        'enable', 'off' ...
        );

    % Assign context menu to the table
    set(view_table, 'uicontextmenu', view_contex_menu);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewUpdateView':
%
% Use:
%       -- itemListViewUpdateView(hsrc, evt, view_tag)
%
% Description:
% Update the view in response to the change of data or gui elements
% repositioning due to size changed event.
%
% hsrc must be a handle to a figure.
%
% -----------------------------------------------------------------------------
function itemListViewUpdateView(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewUpdateView';
    use_case = ' -- itemListViewUpdateView(view_tag)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(3 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case);

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

    % Get figure handles
    figure_handles = guihandles(hsrc);

    % Check if the calling figure holds our view, else we ignore the signal
    if(isfield(figure_handles, view_tag))

        % Get GUI elements postions
        position = itemListViewElementsPosition( ...
            get(getfield(figure_handles, view_tag), 'parent') ...
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
%       -- position = itemListViewElementsPosition(hcntr)
%
% Description:
% Calculate GUI elements position within set container respectively to figure
% dimensions.
%
% -----------------------------------------------------------------------------
function position = itemListViewElementsPosition(hcntr)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewElementsPosition';
    use_case = ' -- position = itemListViewElementsPosition(hcntr)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate hsrc argument
    if(~ishandle(hcntr))
        error( ...
            '%s: hsrc must be handle to a graphics object', ...
            fname
            );

    endif;

    % Check if given figure holds App Ui Style data. Get figure user data
    gduip = guidata(hcntr);

    % Check if object returned by guidata() contains all necessary fields
    if(~isfield(gduip, 'app_uistyle') || ~isAppUiStyleObject(gduip.app_uistyle))
        error( ...
            '%s: figure does not contain valid App Ui Style object', ...
            fname
            );

    endif;

    % Define return value as matrix -------------------------------------------
    position = [];

    % Calculate relative extents ----------------------------------------------
    cexts = getpixelposition(hcntr);
    horpadabs = gduip.app_uistyle.padding_px / cexts(3);
    verpadabs = gduip.app_uistyle.padding_px / cexts(4);
    btnwdtabs = gduip.app_uistyle.btn_width_px / cexts(3);
    clmwdtabs = gduip.app_uistyle.column_width_px / cexts(3);
    rowhghabs = gduip.app_uistyle.row_height_px / cexts(4);

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
% Function 'itemListViewNewItemList':
%
% Use:
%       -- itemListViewNewItemList(hfigure, view_tag, item_list)
%
% Description:
% TODO: Add function description here.
%
% -----------------------------------------------------------------------------
function itemListViewNewItemList(hfigure, view_tag, item_list)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewNewItemList';
    use_case = ' -- itemListViewNewItemList(hfigure, view_tag, item_list)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(3 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate hfigure argument
    if(~isfigure(hfigure))
        error( ...
            '%s: hfigure must be handle to a figure', ...
            fname
            );

    endif;

    % Get figure user data
    gduip = guidata(hfigure);

    % Get figure handles to UI controls
    figure_handles = guihandles(hfigure);

    % Check if given figure holds valid app data
    if(~isfield(gduip, 'hdtp') || ~isfigure(gduip.hdtp))
        error( ...
            '%s: figure does not contain handle to data storage figure', ...
            fname
            );

    endif;

    % Get data storage user data
    gddtp = guidata(gduip.hdtp);

    % Check if given figure holds valid app data
    if(~isfield(gddtp, 'app_data') || ~isstruct(gddtp.app_data))
        error( ...
            '%s: data storage figure does not contain data storage', ...
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

    % Check if given figure holds our view
    if(~isfield(figure_handles, view_tag))
        error( ...
            '%s: given figure does not contain view with given tag (%s)', ...
            fname, ...
            view_tag ...
            );

    endif;

    % Validate item_list argument
    if(~itemListModelIsItemListObj(item_list))
        error( ...
            '%s: item_list must be an instance of the Item List data structure', ...
            fname
            );

    endif;

    % Update item list --------------------------------------------------------
    view_data = itemListSelectionModelNewSelection( ...
        itemListModelNewList( ...
            itemDataModelNewItem('Empty', 'None') ...
            ) ...
        );
    if(~isempty(item_list))
        view_data = itemListSelectionModelNewSelection(item_list);

    endif;
    gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);

    guidata(gduip.hdtp, gddtp);

    % Update the view ---------------------------------------------------------
    set( ...
        getfield( ...
            figure_handles, ...
            strjoin({view_tag, 'table'}, '_') ...
            ), ...
        'Data', itemListModel2CellArray(item_list) ...
        );

    itemListViewUpdateView(hfigure, [], view_tag);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewOnCellSelect':
%
% Use:
%       -- itemListViewOnCellSelect(hsrc, evt, view_tag)
%
% Description:
% Callback to handle cell select events from the table view.
%
% -----------------------------------------------------------------------------
function itemListViewOnCellSelect(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewOnCellSelect';
    use_case = ' -- itemListViewOnCellSelect(hsrc, evt, view_tag)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(3 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Get figure user data
    gduip = guidata(hsrc);

    % Get figure handles to UI controls
    figure_handles = guihandles(hsrc);

    % Check if given figure holds valid app data
    if(~isfield(gduip, 'hdtp') || ~isfigure(gduip.hdtp))
        error( ...
            '%s: figure does not contain handle to data storage figure', ...
            fname
            );

    endif;

    % Get data storage user data
    gddtp = guidata(gduip.hdtp);

    % Check if given figure holds valid app data
    if(~isfield(gddtp, 'app_data') || ~isstruct(gddtp.app_data))
        error( ...
            '%s: data storage figure does not contain data storage', ...
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

    % Check if given figure holds our view
    if(~isfield(figure_handles, view_tag))
        error( ...
            '%s: given figure does not contain view with given tag (%s)', ...
            fname, ...
            view_tag ...
            );

    endif;

    % Process event -----------------------------------------------------------

    % Check if the calling figure holds our view, else we ignore the signal
    if(isfield(figure_handles, view_tag))

        % Get selected cells and view data
        idx = unique(evt.Indices(:, 1));
        view_data = getfield(gddtp.app_data, view_tag);

        % If user selected just a row idx will be a scalar holding row index
        if(2 == size(evt.Indices)(1) && 1 == numel(idx))
            % Row is selected, update selected item index
            view_data.selected_item = idx;

            % Enable 'Remove Item' option in the table's context menu
            set( ...
                getfield( ...
                    figure_handles, ...
                    strjoin({view_tag, 'remove_item'}, '_') ...
                    ), ...
                'enable', 'on' ...
                );

        else
            % User selected a single cell or a column, set selected item index
            % to 'no selection' (0)
            view_data.selected_item = 0;

            % Disable 'Remove Item' option in the table's context menu
            set( ...
                getfield( ...
                    figure_handles, ...
                    strjoin({view_tag, 'remove_item'}, '_') ...
                    ), ...
                'enable', 'off' ...
                );

        endif;

        % Update global data structure and save data to figure
        gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);
        guidata(gduip.hdtp, gddtp);

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewOnAddItem':
%
% Use:
%       -- itemListViewOnAddItem(hsrc, evt, view_tag)
%
% Description:
% Callback to handle 'Add Item' command from the table context menu
%
% -----------------------------------------------------------------------------
function itemListViewOnAddItem(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewOnAddItem';
    use_case = ' -- itemListViewOnAddItem(hsrc, evt, view_tag)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(3 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Get figure user data
    gduip = guidata(hsrc);

    % Get figure handles to UI controls
    figure_handles = guihandles(hsrc);

    % Check if given figure holds valid app data
    if(~isfield(gduip, 'hdtp') || ~isfigure(gduip.hdtp))
        error( ...
            '%s: figure does not contain handle to data storage figure', ...
            fname
            );

    endif;

    % Get data storage user data
    gddtp = guidata(gduip.hdtp);

    % Check if given figure holds valid app data
    if(~isfield(gddtp, 'app_data') || ~isstruct(gddtp.app_data))
        error( ...
            '%s: data storage figure does not contain data storage', ...
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

    % Check if given figure holds our view
    if(~isfield(figure_handles, view_tag))
        error( ...
            '%s: given figure does not contain view with given tag (%s)', ...
            fname, ...
            view_tag ...
            );

    endif;

    % Process event -----------------------------------------------------------

    % Check if the calling figure holds our view, else we ignore the signal
    if(isfield(figure_handles, view_tag))

        display('Add item in progress ...');

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewOnRemoveSelectedItem':
%
% Use:
%       -- itemListViewOnRemoveSelectedItem(hsrc, evt, view_tag)
%
% Description:
% Callback to handle 'Add Item' command from the table context menu
%
% -----------------------------------------------------------------------------
function itemListViewOnRemoveSelectedItem(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewOnRemoveSelectedItem';
    use_case = ' -- itemListViewOnRemoveSelectedItem(hsrc, evt, view_tag)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(3 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Get figure user data
    gduip = guidata(hsrc);

    % Get figure handles to UI controls
    figure_handles = guihandles(hsrc);

    % Check if given figure holds valid app data
    if(~isfield(gduip, 'hdtp') || ~isfigure(gduip.hdtp))
        error( ...
            '%s: figure does not contain handle to data storage figure', ...
            fname
            );

    endif;

    % Get data storage user data
    gddtp = guidata(gduip.hdtp);

    % Check if given figure holds valid app data
    if(~isfield(gddtp, 'app_data') || ~isstruct(gddtp.app_data))
        error( ...
            '%s: data storage figure does not contain data storage', ...
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

    % Check if given figure holds our view
    if(~isfield(figure_handles, view_tag))
        error( ...
            '%s: given figure does not contain view with given tag (%s)', ...
            fname, ...
            view_tag ...
            );

    endif;

    % Process event -----------------------------------------------------------

    % Check if the calling figure holds our view, else we ignore the signal
    if(isfield(figure_handles, view_tag))

        display('Remove selected item in progress ...');

    endif;

endfunction;
