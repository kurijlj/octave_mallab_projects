item_list_view_version = '1.0';

source('./app_uistyle_model.m');
source('./item_list_selection_model.m');

% -----------------------------------------------------------------------------
%
% Function 'newItemListView':
%
% Use:
%       -- hfig = newItemListView(view_tag, item_list)
%       -- hfig = newItemListView(view_tag, item_list, huip)';
%
% Description:
% TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hfig = newItemListView(view_tag, item_list, huip)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemListView';
    use_case_a = ' -- hfig = newItemListView(view_tag, item_list)';
    use_case_b = ' -- hfig = newItemListView(view_tag, item_list, huip)';

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
    if(~isItemListObject(item_list))
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

    view_data = newItemListSelection({newItem('empty', 'none')});
    if(~isempty(item_list))
        view_data = newItemListSelection(item_list);

    endif;

    % save app data to data storage figure
    gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);
    guidata(gduip.hdtp, gddtp);

    layoutItemListView(huip, view_tag);

    if(2 == nargin)
        % define callbacks for events we handle
        set( ...
            huip, ...
            'sizechangedfcn', {@updateItemListView, view_tag} ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% function 'layoutItemListView':
%
% use:
%       -- layoutItemListView(hparent, view_tag)
%
% Description:
% TODO: add function description here
%
% -----------------------------------------------------------------------------
function layoutItemListView(hparent, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'layoutItemListView';
    use_case = ' -- layoutItemListView(view_tag, hparent)';

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

    % get figure user data
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
    position = itemListViewElementsPosition(hfigure);

    % Create 'item list view' panel -------------------------------------------
    view_panel = uipanel( ...
        'parent', hparent, ...
        'title', 'item list', ...
        'tag', view_tag, ...
        'position', position(1, :) ...
        );

    % Create items table ------------------------------------------------------
    item_list_selection = getfield(gddtp.app_data, view_tag);
    view_table = uitable( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'table'}, '_'), ...
        'data', itemList2CellArray(item_list_selection.item_list), ...
        'tooltipstring', 'Select row to select item', ...
        'columnname', {'Title', 'Value'}, ...
        % 'cellselectioncallback', {@onItemListViewCellSelect, view_tag}, ...
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
        'label', 'add item ...', ...
        % 'callback', @onadditemmenu, ...
        'enable', 'on' ...
        );
    uimenu( ...
        'parent', view_contex_menu, ...
        'tag', strjoin({view_tag, 'remove_item'}, '_'), ...
        'label', 'remove item ...', ...
        % 'callback', @onremoveitemmenu, ...
        'enable', 'off' ...
        );

    % Assign context menu to the table
    set(view_table, 'uicontextmenu', view_contex_menu);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'updateItemListView':
%
% Use:
%       -- updateItemListView(view_tag)
%
% Description:
% Update the view in response to the change of data or gui elements
% repositioning due to size changed event.
%
% -----------------------------------------------------------------------------
function updateItemListView(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'updateItemListView';
    use_case = ' -- updateItemListView(view_tag)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(3 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate hsrc argument
    if(~ishandle(hsrc))
        error( ...
            '%s: hsrc must be handle to a graphics object', ...
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

    % Get figure handles
    hfigure = gcbf();
    figure_handles = guihandles(hfigure);

    % Check if current figure holds our view
    if(~isfield(figure_handles, view_tag))
        error( ...
            '%s: current figure does not contain view with given tag (%s)', ...
            fname, ...
            view_tag ...
            );

    endif;

    % Get GUI elements postions
    position = itemListViewElementsPosition(hfigure);

    set( ...
        getfield(figure_handles, view_tag), ...
        'position', position(1, :) ...
        );
    set( ...
        getfield(figure_handles, strjoin({view_tag, 'table'}, '_')), ...
        'position', position(2, :) ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemListViewElementsPosition':
%
% Use:
%       -- position = itemListViewElementsPosition(hfigure)
%
% Description:
% Calculate GUI elements position within set container respectively to figure
% dimensions.
%
% -----------------------------------------------------------------------------
function position = itemListViewElementsPosition(hfigure)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewElementsPosition';
    use_case = ' -- position = itemListViewElementsPosition(hfigure)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Validate hfigure argument
    if(~isfigure(hfigure))
        error( ...
            '%s: hfigure must be handle to a figure', ...
            fname
            );

    endif;

    % Check if given figure holds App Ui Style data. Get figure user data
    gduip = guidata(hfigure);

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
    cexts = getpixelposition(hfigure);
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
%       -- itemListViewNewItemList(view_tag, item_list)
%
% Description:
% TODO: Add function description here.
%
% -----------------------------------------------------------------------------
function itemListViewNewItemList(hsrc, evt, view_tag, item_list)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewNewItemList';
    use_case = ' -- itemListViewNewItemList(hsrc, evt, view_tag, item_list)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(4 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
            fname
            );
    endif;

    % Validate item_list argument
    if(~isItemListObject(item_list))
        error( ...
            '%s: item_list must be an instance of the Item List data structure', ...
            fname
            );

    endif;

    % Check if cureent figure holds valid app data
    app_data = guidata(hsrc);
    if(~isAppDataStructure(app_data))
        error( ...
            '%s: GUI data does not hold actual App Data structure', ...
            fname
            );

    endif;

    % Check if current figure holds our view
    if(~isfield(app_data.ui_handles, view_tag))
        error( ...
            '%s: current figure does not contain view with given tag (%s)', ...
            fname, ...
            view_tag ...
            );

    endif;

    view_data = newItemListSelection({newItem('Empty', 'None')});
    if(~isempty(item_list))
        view_data = newItemListSelection(item_list);

    endif;
    app_data.data = setfield(app_data.data, view_tag, view_data);

    guidata(app_data.ui_handles.hfigure, app_data);

    set( ...
        getfield( ...
            app_data.ui_handles, ...
            strjoin({view_tag, 'table'}, '_') ...
            ), ...
        'Data', itemList2CellArray(item_list) ...
        );

    updateItemListView(app_data.ui_handles.hfigure, [], view_tag);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'onItemListViewCellSelect':
%
% Use:
%       -- onItemListViewCellSelect(hsrc, evt, view_tag)
%
% Description:
% Callback to handle cell select events from the table view.
%
% -----------------------------------------------------------------------------
function onItemListViewCellSelect(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'onItemListViewCellSelect';
    use_case = ' -- onItemListViewCellSelect(hsrc, evt, view_tag)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(3 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
            fname
            );
    endif;

    % Check if cureent figure holds valid app data
    app_data = guidata(hsrc);
    if(~isAppDataStructure(app_data))
        error( ...
            '%s: GUI data does not hold actual App Data structure', ...
            fname
            );

    endif;

    % Check if current figure holds our view
    if(~isfield(app_data.ui_handles, view_tag))
        error( ...
            '%s: current figure does not contain view with given tag (%s)', ...
            fname, ...
            view_tag ...
            );

    endif;

    % Process event -----------------------------------------------------------

    % Get selected cells and view data
    idx = unique(evt.Indices(:, 1));
    view_data = getfield(app_data.data, view_tag);

    % If user selected just a row idx will be a scalar holding row index
    if(2 == size(evt.Indices)(1) && 1 == numel(idx))
        % Row is selected, update selected item index
        view_data.selected_item = idx;

        % Enable 'Remove Item' option in the table's context menu
        set( ...
            getfield( ...
                app_data.ui_handles, ...
                strjoin({view_tag, 'remove_item'}, '_') ...
                ), ...
            'enable', 'on' ...
            );

    else
        % User selected a single cell or a column, set selected item index to
        % 'no selection' (0)
        view_data.selected_item = 0;

        % Disable 'Remove Item' option in the table's context menu
        set( ...
            getfield( ...
                app_data.ui_handles, ...
                strjoin({view_tag, 'remove_item'}, '_') ...
                ), ...
            'enable', 'off' ...
            );

    endif;

    % Update global data structure and save data to figure
    app_data.data = setfield(app_data.data, view_tag, view_data);
    guidata(hsrc, app_data);

endfunction;
