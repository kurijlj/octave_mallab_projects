item_edit_view_version = '1.0';

source('./gui_commons.m');
source('./app_uistyle_model.m');
source('./item_data_model.m');

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewNewView':
%
% Use:
%       -- itemEditViewNewView(item)
%       -- itemEditViewNewView(..., "PROPERTY", VALUE, ...)
%       -- hview = itemEditViewNewView(...)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hview = itemEditViewNewView(varargin)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'variableInputArgumentsProcessing';
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
        view_tag, ...
        title, ...
        uistyle, ...
        hparent, ...
        item_modified_callback ...
        ] = parseparams( ...
        varargin, ...
        'view_tag', 'item_edit_view', ...
        'title', 'Item Edit View', ...
        'uistyle', appUiStyleModelNewUiStyle(), ...  % Use default UI style
        'parent', NaN, ...  %WARNING: do not set this to 0 it is the result of groot()!
        'ItemModifiedCallback', NaN ...
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

    % Validate item_modified_callback argument
    if( ...
            ~is_function_handle(item_modified_callback) ...
            && ~isnan(item_modified_callback) ...
            )
        error( ...
            '%s: item_modified_callback must be handle to a function or NaN', ...
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
            'name', 'Edit Item', ...
            'menubar', 'none', ...
            'tag', 'main_figure' ...
            );

        % Since we are running in our own figure connect selected item change
        % signal to the default callback
        item_modified_callback = @itemEditViewStoreItem;

    endif;

    % Create new view
    hview = itemEditViewLayoutView( ...
        hparent, ...
        item, ...
        'view_tag', view_tag, ...
        'title', title, ...
        'uistyle', uistyle, ...
        'ItemModifiedCallback', item_modified_callback ...
        );

    % Connect size changed signal to it's slot
    set( ...
        ancestor(hparent, 'figure'), ...
        'sizechangedfcn', {@itemEditViewUpdateView, view_tag, uistyle} ...
        );

    % Save required app data
    app_data = guidata(hparent);
    app_data = setfield( ...
        app_data, ...
        strjoin({view_tag, 'data'}, '_'), ...
        item ...
        );
    guidata(hparent, app_data);

endfunction;

% -----------------------------------------------------------------------------
%
% function 'itemEditViewLayoutView':
%
% use:
%       -- itemEditViewLayoutView(hparent, item_list)
%       -- itemEditViewNewView(..., "PROPERTY", VALUE, ...)
%       -- hview = itemEditViewNewView(...)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hview = itemEditViewLayoutView(varargin)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewLayoutView';
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
        item_modified_callback ...
        ] = parseparams( ...
        varargin, ...
        'view_tag', 'item_edit_view', ...
        'title', 'Item Edit View', ...
        'uistyle', appUiStyleModelNewUiStyle(), ...  % Use default UI style
        'ItemModifiedCallback', NaN ...
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

    % Validate item argument
    item = pos{2};
    if(~itemDataModelIsItemObj(item))
        error( ...
            '%s: item must be an instance of the Item Data Model data structure', ...
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

    % Validate callback argument
    if( ...
            ~is_function_handle(item_modified_callback) ...
            && ~isnan(item_modified_callback) ...
            )
        error( ...
            '%s: item_modified_callback must be handle to a function or NaN', ...
            fname
            );

    endif;

    % Get figure containing the parent object ---------------------------------
    hfig = ancestor(hparent, 'figure');

    % Initialize gui elements positions ---------------------------------------
    position = itemEditViewElementsPosition(hparent, uistyle);

    % Create 'Item Edit View' view panel --------------------------------------
    view_panel = uipanel( ...
        'parent', hparent, ...
        'title', title, ...
        'tag', view_tag, ...
        'position', position(1, :) ...
        );

    % Create input fields -----------------------------------------------------

    % Create input field for the 'Item Title'
    uicontrol( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'title_label'}, '_'), ...
        'style', 'text', ...
        'string', 'Item Title', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(5, :) ...
        );
    uicontrol( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'title_field'}, '_'), ...
        'callback', {@itemEditViewOnItemModified, item_modified_callback}, ...
        'style', 'edit', ...
        'enable', 'on', ...
        'string', item.title, ...
        'tooltipstring', 'Item title', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(4, :) ...
        );

    % Create input field for the 'Item Value'
    uicontrol( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'value_label'}, '_'), ...
        'style', 'text', ...
        'string', 'Item Value', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(3, :) ...
        );
    uicontrol( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'value_field'}, '_'), ...
        'callback', {@itemEditViewOnItemModified, item_modified_callback}, ...
        'style', 'edit', ...
        'enable', 'on', ...
        'string', item.value, ...
        'tooltipstring', 'Item value', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );

    hview = view_panel;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewUpdateView':
%
% Use:
%       -- itemEditViewUpdateView(hsrc, evt, view_tag, uistyle)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function itemEditViewUpdateView(hsrc, evt, view_tag, uistyle)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewUpdateView';
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
        position = itemEditViewElementsPosition( ...
            get(getfield(figure_handles, view_tag), 'parent'), ...
            uistyle ...
            );

        % Reset elements position
        set( ...
            getfield(figure_handles, view_tag), ...
            'position', position(1, :) ...
            );
        set( ...
            getfield(figure_handles, strjoin({view_tag, 'value_field'}, '_')), ...
            'position', position(2, :) ...
            );
        set( ...
            getfield(figure_handles, strjoin({view_tag, 'value_label'}, '_')), ...
            'position', position(3, :) ...
            );
        set( ...
            getfield(figure_handles, strjoin({view_tag, 'title_field'}, '_')), ...
            'position', position(4, :) ...
            );
        set( ...
            getfield(figure_handles, strjoin({view_tag, 'title_label'}, '_')), ...
            'position', position(5, :) ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewElementsPosition':
%
% Use:
%       -- position = itemEditViewElementsPosition(hcntr, uistyle)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function position = itemEditViewElementsPosition(hcntr, uistyle)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewElementsPosition';
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

    % Set fields position -----------------------------------------------------
    idx = 2;
    while(1 <= idx)
        position = [ ...
            position; ...
            horpadabs, ...
            1.00 - idx*verpadabs - (2*idx)*rowhghabs, ...
            1.00 - 2*horpadabs, ...
            rowhghabs; ...
            horpadabs, ...
            1.00 - idx*verpadabs - (2*idx - 1)*rowhghabs, ...
            1.00 - 2*horpadabs, ...
            rowhghabs; ...
            ];

        idx = idx - 1;

    endwhile;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewSetItem':
%
% Use:
%       -- itemEditViewSetItem(hfview, item)
%
% Description:
% TODO: Add function description here.
%
% -----------------------------------------------------------------------------
function itemEditViewSetItem(hview, item)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewSetItem';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hview, item)' ...
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

    % Validate item argument
    if(~itemDataModelIsItemObj(item))
        error( ...
            '%s: item must be an instance of the Item Data Model data structure', ...
            fname
            );

    endif;

    % Get handle to view fields -----------------------------------------------

    % Get view tag
    view_tag = guiObjectTag(hview);

    % Get containig figure handle
    hfig = ancestor(hview, 'figure');

    htitle = getfield(guihandles(hfig), strjoin({view_tag, 'title_field'}, '_'));
    hvalue = getfield(guihandles(hfig), strjoin({view_tag, 'value_field'}, '_'));

    % Update fields -----------------------------------------------------------
    set(htitle, 'string', item.title);
    set(hvalue, 'string', item.value);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewGetItem':
%
% Use:
%       -- item = itemEditViewGetItem(hfview)
%
% Description:
% TODO: Add function description here.
%
% -----------------------------------------------------------------------------
function item = itemEditViewGetItem(hview)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewGetItem';
    use_case_a = strjoin({ ...
        ' -- item = ', ...
        fname, ...
        '(hview)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate hiew argument
    if(~ishghandle(hview))
        error( ...
            '%s: hview must be handle to a graphics object', ...
            fname
            );

    endif;

    % Get handle to view fields -----------------------------------------------

    % Get view tag
    view_tag = guiObjectTag(hview);

    % Get containig figure handle
    hfig = ancestor(hview, 'figure');

    htitle = getfield(guihandles(hfig), strjoin({view_tag, 'title_field'}, '_'));
    hvalue = getfield(guihandles(hfig), strjoin({view_tag, 'value_field'}, '_'));

    % Retuen field values as item object --------------------------------------
    item = itemDataModelNewItem( ...
        get(htitle, 'string'), ...
        get(hvalue, 'string') ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewStoreItem':
%
% Use:
%       -- itemEditViewStoreItem(hview, item)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function itemEditViewStoreItem(hview, item)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewStoreItem';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hview, item)' ...
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

    % Validate item argument
    if(~itemDataModelIsItemObj(item))
        error( ...
            '%s: item must be an instance of the Item Data Model data structure', ...
            fname
            );

    endif;

    % Store given item to app data --------------------------------------------

    % Get view tag
    view_tag = guiObjectTag(hview);

    % Get app data
    app_data = guidata(hview);
    destination = getfield( ...
        app_data, ...
        strjoin({view_tag, 'data'}, '_') ...
        );

    destination = item;

    % Save changes
    app_data = setfield( ...
        app_data, ...
        strjoin({view_tag, 'data'}, '_'), ...
        destination ...
        );
    guidata(hview, app_data);

    % Nothing has changed in the view, so don't update it

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewOnItemModified':
%
% Use:
%       -- itemEditViewOnItemModified(hsrc, evt)
%
% Description:
%          TODO: Add function description here
%
% -----------------------------------------------------------------------------
function itemEditViewOnItemModified(hsrc, evt, callback=NaN)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewOnItemModified';
    use_case_a = strjoin({ ...
        ' -- ', ...
        fname, ...
        '(hsrc, evt)' ...
        }, '');

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin && 3 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case_a);

    endif;

    % Validate hsrc argument
    if(~ishghandle(hsrc))
        error( ...
            '%s: hsrc must be handle to a graphics object', ...
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

    % Process events ----------------------------------------------------------

    if(is_function_handle(callback))

        % Get handle to view fields -------------------------------------------

        % Get view tag
        view_tag = guiObjectTag(get(hsrc, 'parent'));

        % Get containig figure handle
        hfig = ancestor(hsrc, 'figure');

        htitle = getfield( ...
            guihandles(hfig), ...
            strjoin({view_tag, 'title_field'}, '_') ...
            );
        hvalue = getfield( ...
            guihandles(hfig), ...
            strjoin({view_tag, 'value_field'}, '_') ...
            );

        % Get field values ----------------------------------------------------
        item = itemDataModelNewItem( ...
            get(htitle, 'string'), ...
            get(hvalue, 'string') ...
            );

        % Execute callback ----------------------------------------------------
        callback(get(hsrc, 'parent'), item);

    endif;

endfunction;
