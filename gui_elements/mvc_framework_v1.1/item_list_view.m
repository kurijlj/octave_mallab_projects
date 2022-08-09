item_list_view_version = '1.0';

source('./app_uistyle_model.m');
source('./item_list_selection_model.m');

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
    fname = 'variableInputArgumentsProcessing';
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
    numopt = 3;

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
        uistyle, ...
        hparent, ...
        callback ...
        ] = parseparams( ...
        varargin, ...
        'view_tag', 'item_list_view', ...
        'uistyle', appUiStyleModelNewUiStyle(), ...  % Use default UI style
        'parent', NaN, ...  %WARNING: do not set this to 0 it is the result of groot()!
        'callback', NaN ...
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

    % Validate callback argument
    if(~is_function_handle(callback) && ~isnan(callback))
        error( ...
            '%s: callback must be handle to a function', ...
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

    endif;

    % If we got an empty item list create some dummy data for display
    if(isempty(item_list))
        item_list = itemListModelNewList( ...
            itemDataModelNewItem('Uknown', '...') ...
            );

    endif;

    % Create new view
    hview = itemListViewLayoutView(item_list, view_tag, hparent, uistyle);

    % Connect size changed signal to it slot
    set( ...
        ancestor(hparent, 'figure'), ...
        'sizechangedfcn', {@itemListViewUpdateView, view_tag, uistyle} ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% function 'itemListViewLayoutView':
%
% use:
%       -- hview = itemListViewLayoutView(hparent, view_tag, item_list, uistyle)
%
% Description:
% TODO: add function description here
%
% -----------------------------------------------------------------------------
function hview = itemListViewLayoutView(item_list, view_tag, hparent, uistyle)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemListViewLayoutView';
    use_case_a = strjoin({ ...
        ' -- hview = ', ...
        fname, ...
        '(view_tag, hparent, item_list, uistyle)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(4 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate item_list argument
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

    % Validate hparent argument
    if(~ishghandle(hparent))
        error( ...
            '%s: hparent must be handle to a graphics object', ...
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

    % Get figure containing the parent object ---------------------------------
    hfig = ancestor(hparent, 'figure');

    % Initialize gui elements positions ---------------------------------------
    position = itemListViewElementsPosition(hparent, uistyle);

    % Create 'Item List View' panel -------------------------------------------
    view_panel = uipanel( ...
        'parent', hparent, ...
        'title', 'Item List', ...
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
        % 'cellselectioncallback', {@itemListViewOnCellSelect, view_panel}, ...
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
        % 'callback', {@itemListViewOnAddItem, view_tag}, ...
        'enable', 'on' ...
        );
    uimenu( ...
        'parent', view_contex_menu, ...
        'tag', strjoin({view_tag, 'remove_item'}, '_'), ...
        'label', 'Remove Selected Item ...', ...
        % 'callback', {@itemListViewOnRemoveSelectedItem, view_tag}, ...
        'enable', 'off' ...
        );

    % Assign context menu to the table
    set(view_table, 'uicontextmenu', view_contex_menu);

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
% Update the view in response to the change of data or gui elements
% repositioning due to size changed event.
%
% hsrc must be a handle to a figure.
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
% Calculate GUI elements position within set container respectively to figure
% dimensions.
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

