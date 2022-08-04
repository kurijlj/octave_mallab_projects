item_list_view_version = '1.0';

source('./app_data.m');
source('./item_list_model.m');

% -----------------------------------------------------------------------------
%
% Function 'newItemListView':
%
% Use:
%       -- handle = newItemListView(view_tag, item_list, hparent)
%
% Description:
% TODO: Add function description here
%
% -----------------------------------------------------------------------------
function handle = newItemListView(view_tag, item_list, hparent)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newItemListView';
    use_case_a = ' -- controller = newItemListView(view_tag, item_list)';
    use_case_b = ' -- controller = newItemListView(view_tag, item_list, hparent)';

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

    % Validate hparent argument
    if(3 == nargin && ~ishandle(hparent))
        error( ...
            '%s: hparent must be handle to a graphics object', ...
            fname
            );

    endif;

    % Initialize variable for storing all relevant app data
    app_data = NaN;

    if(2 == nargin)
        % We don't have handle to a parent UI container, so we need to run 'Item
        % List View' as a standalone application, within it's own figure and
        % with underlying app_data

        % Create figure and define it as parent to 'Item' view
        hparent = figure( ...
            'name', 'Item List', ...
            'menubar', 'none' ...
            );

        % Create new 'App Data' structure
        app_data = newAppData(hparent);

    else
        % We have a handle to the parent container. Get handle to the app
        % figure and validate underlying app_data structure
        app_data = guidata(gcf());

        % Check if object returned by guidata() is an actual 'App Data'
        % structure
        if(~isAppDataStructure(app_data))
            error( ...
                '%s: GUI data does not hold actual App Data structure', ...
                fname
                );

        endif;

    endif;

    view_data = struct();
    view_data.item_list = item_list;
    view_data.selected_item = 0;  % Indicates that no item is yet selected
    if(isempty(item_list))
        view_data.item_list = {newItem('Empty', 'None')};

    endif;
    app_data.data = setfield(app_data.data, view_tag, view_data);

    guidata(app_data.ui_handles.hfigure, app_data);

    layoutItemListView(view_tag, hparent);

    if(2 == nargin)
        % Define callbacks for events we handle
        set( ...
            hparent, ...
            'sizechangedfcn', {@updateItemListView, view_tag} ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'layoutItemListView':
%
% Use:
%       -- layoutItemListView(view_tag, hparent)
%
% Description:
% TODO: Add function description here
%
% -----------------------------------------------------------------------------
function layoutItemListView(view_tag, hparent)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'layoutItemListView';
    use_case = ' -- layoutItemListView(view_tag, hparent)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
            fname
            );
    endif;

    % Validate hparent argument
    if(~ishandle(hparent))
        error( ...
            '%s: hparent must be handle to a graphics object', ...
            fname
            );

    endif;

    % Check if cureent figure holds valid app data
    app_data = guidata(gcf());
    if(~isAppDataStructure(app_data))
        error( ...
            '%s: GUI data does not hold actual App Data structure', ...
            fname
            );

    endif;

    % Initialize GUI elements positions ---------------------------------------
    position = itemListViewElementsPosition(app_data.ui_handles.hfigure);

    % Create 'Item List View' panel -------------------------------------------
    app_data.ui_handles = setfield( ...
        app_data.ui_handles, ...
        view_tag, ...
        uipanel( ...
            'parent', hparent, ...
            'title', 'Item List', ...
            'position', position(1, :) ...
            ) ...
        );

    % Create items table ------------------------------------------------------
    item_list_selection = getfield(app_data.data, view_tag);
    app_data.ui_handles = setfield( ...
        app_data.ui_handles, ...
        strjoin({view_tag, 'table'}, '_'), ...
        uitable( ...
            'parent', getfield(app_data.ui_handles, view_tag), ...
            'Data', itemList2CellArray(item_list_selection.item_list), ...
            'tooltipstring', 'Select row to select Item', ...
            'ColumnName', {'Title', 'Value'}, ...
            'CellSelectionCallback', {@onItemListViewCellSelect, view_tag}, ...
            % 'ButtonDownFcn', {@onBtnDwn, view_tag}, ...
            % 'ColumnEditable', true, ...
            'units', 'normalized', ...
            'position', position(2, :) ...
            ) ...
        );

    guidata(app_data.ui_handles.hfigure, app_data);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'updateItemListView':
%
% Use:
%       -- updateItemListView(view_tag)
%
% Description:
% Update the view in response to the change of data or GUI elements
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

    % Get GUI elements postions
    position = itemListViewElementsPosition(hsrc);

    set( ...
        getfield(app_data.ui_handles, view_tag), ...
        'position', position(1, :) ...
        );
    set( ...
        getfield(app_data.ui_handles, strjoin({view_tag, 'table'}, '_')), ...
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

    % Check if given figure holds valid app data
    app_data = guidata(hfigure);
    if(~isAppDataStructure(app_data))
        error( ...
            '%s: GUI data does not hold actual App Data structure', ...
            fname
            );

    endif;

    % Define return value as matrix -------------------------------------------
    position = [];

    % Calculate relative extents ----------------------------------------------
    cexts = getpixelposition(hfigure);
    horpadabs = app_data.ui_layout_guides.padding_px / cexts(3);
    verpadabs = app_data.ui_layout_guides.padding_px / cexts(4);
    btnwdtabs = app_data.ui_layout_guides.btn_width_px / cexts(3);
    clmwdtabs = app_data.ui_layout_guides.column_width_px / cexts(3);
    rowhghabs = app_data.ui_layout_guides.row_height_px / cexts(4);

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

    else
        % User selected a single cell or a column, set selected item index to
        % 'no selection' (0)
        view_data.selected_item = 0;

    endif;

    % Update global data structure and save data to figure
    app_data.data = setfield(app_data.data, view_tag, view_data);
    guidata(hsrc, app_data);

endfunction;

function onBtnDwn(hsrc, evt, view_tag)

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

endfunction;
