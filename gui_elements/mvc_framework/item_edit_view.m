item_edit_view_version = '1.0';

source('./app_uistyle_model.m');
source('./item_data_model.m');

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewNewView':
%
% Use:
%       -- hfig = itemEditViewNewView(view_tag, item)
%       -- hfig = itemEditViewNewView(view_tag, item, huip)';
%
% Description:
% TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hfig = itemEditViewNewView(view_tag, item, huip)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewNewView';
    use_case_a = ' -- hfig = itemEditViewNewView(view_tag, item)';
    use_case_b = ' -- hfig = itemEditViewNewView(view_tag, item, huip)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin && 3 ~= nargin)
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s', ...
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

    % Validate item argument
    if(~itemDataModelIsItemObject(item))
        error( ...
            '%s: item must be an instance of the Item data structure', ...
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
            'name', 'Item Edit View', ...
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
        % We have a handle to the parent container. Get handle to the app
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

    view_data = struct();
    view_data.item = item;
    gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);

    % save app data to data storage figure
    guidata(gduip.hdtp, gddtp);

    itemEditViewLayoutView(huip, view_tag);

    if(2 == nargin)
        % define callbacks for events we handle
        set( ...
            huip, ...
            'sizechangedfcn', {@itemEditViewUpdateView, view_tag} ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewLayoutView':
%
% Use:
%       -- itemEditViewLayoutView(hparent, view_tag)
%
% Description:
% TODO: add function description here
%
% -----------------------------------------------------------------------------
function itemEditViewLayoutView(hparent, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewLayoutView';
    use_case = ' -- itemEditViewLayoutView(hparent, view_tag)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error('Invalid call to %s.  Correct usage is:\n%s', fname, use_case);

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
    position = itemEditViewElementsPosition(hfigure);

    % Create 'Item Edit' view panel -------------------------------------------
    view_panel = uipanel( ...
        'parent', hparent, ...
        'title', 'Item Edit', ...
        'tag', view_tag, ...
        'position', position(1, :) ...
        );

    % Create fields view elements ---------------------------------------------
    view_data = getfield(gddtp.app_data, view_tag);

    % Set 'Title' view elemets ------------------------------------------------
    item_title_label = uicontrol( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'title_label'}, '_'), ...
        'style', 'text', ...
        'string', 'Item Title', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(5, :) ...
        );
    item_title_field = uicontrol( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'title_field'}, '_'), ...
        'callback', {@itemEditViewOnTitleEdit, view_tag}, ...
        'style', 'edit', ...
        'enable', 'on', ...
        'string', view_data.item.title, ...
        'tooltipstring', 'Item title', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(4, :) ...
        );

    % Set 'Value' view elemets ------------------------------------------------
    item_value_label = uicontrol( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'value_label'}, '_'), ...
        'style', 'text', ...
        'string', 'Item Value', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(3, :) ...
        );
    item_value_field = uicontrol( ...
        'parent', view_panel, ...
        'tag', strjoin({view_tag, 'value_field'}, '_'), ...
        'callback', {@itemEditViewOnValueEdit, view_tag}, ...
        'style', 'edit', ...
        'enable', 'on', ...
        'string', view_data.item.value, ...
        'tooltipstring', 'Item value', ...
        'horizontalalignment', 'left', ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewUpdateView':
%
% Use:
%       -- itemEditViewUpdateView(hsrc, evt, view_tag)
%
% Description:
% Update the view in response to the change of data or GUI elements
% repositioning due to size changed event.
%
% hsrc must be a handle to a figure.
%
% -----------------------------------------------------------------------------
function itemEditViewUpdateView(hsrc, evt, view_tag)

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

        % Get figure user data
        gduip = guidata(hsrc);

        % Check if object returned by guidata() contains all necessary fields
        if(~isfield(gduip, 'hdtp') || ~isfigure(gduip.hdtp))
            error( ...
                '%s: figure does not contain handle to data storage figure', ...
                fname
                );

        endif;

        % Get data container user data
        gddtp = guidata(gduip.hdtp);

        if(~isfield(gddtp, 'app_data') || ~isstruct(gddtp.app_data))
            error( ...
                '%s: data storage figure does not contain data storage', ...
                fname
                );

        endif;

        % Get view's data
        view_data = getfield(gddtp.app_data, view_tag);

        % Get GUI elements postions
        position = itemEditViewElementsPosition(hsrc);

        set( ...
            getfield(figure_handles, view_tag), ...
            'position', position(1, :) ...
            );
        set( ...
            getfield(figure_handles, strjoin({view_tag, 'value_field'}, '_')), ...
            'position', position(2, :), ...
            'string', view_data.item.value ...
            );
        set( ...
            getfield(figure_handles, strjoin({view_tag, 'value_label'}, '_')), ...
            'position', position(3, :) ...
            );
        set( ...
            getfield(figure_handles, strjoin({view_tag, 'title_field'}, '_')), ...
            'position', position(4, :), ...
            'string', view_data.item.title ...
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
%       -- position = itemEditViewElementsPosition(hfigure)
%
% Description:
% Calculate GUI elements position within set container.
%
% -----------------------------------------------------------------------------
function position = itemEditViewElementsPosition(hfigure)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewElementsPosition';
    use_case = ' -- position = itemEditViewElementsPosition(hfigure)';

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
% Function 'itemEditViewNewItem':
%
% Use:
%       -- itemEditViewNewItem(hfigure, view_tag, item)
%
% Description:
% TODO: Add function description here.
%
% -----------------------------------------------------------------------------
function itemEditViewNewItem(hfigure, view_tag, item)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewNewItem';
    use_case = ' -- itemEditViewNewItem(hfigure, view_tag, item)';

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

    % Validate item argument
    if(~itemDataModelIsItemObject(item))
        error( ...
            '%s: item must be an instance of the Item data structure', ...
            fname
            );

    endif;

    % Update the item ---------------------------------------------------------
    view_data = struct();
    view_data.item = item;
    gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);

    % save app data to data storage figure
    guidata(gduip.hdtp, gddtp);

    % Update the view ---------------------------------------------------------
    itemEditViewUpdateView(hfigure, [], view_tag);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewOnTitleEdit':
%
% Use:
%       -- itemEditViewOnTitleEdit(hsrc, evt, view_tag)
%
% Description:
% TODO: add function description here
%
% -----------------------------------------------------------------------------
function itemEditViewOnTitleEdit(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewOnTitleEdit';
    use_case = ' -- itemEditViewOnTitleEdit(hsrc, evt, view_tag)';

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

    % We ignore evt argument

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
            fname
            );
    endif;

    % Get figure handles
    hfigure = gcbf();
    figure_handles = guihandles(hsrc);

    % Check if the calling figure holds our view, else we ignore the signal
    if(isfield(figure_handles, view_tag))

        % Get figure user data
        gduip = guidata(hfigure);

        % Check if object returned by guidata() contains all necessary fields
        if(~isfield(gduip, 'hdtp') || ~isfigure(gduip.hdtp))
            error( ...
                '%s: figure does not contain handle to data storage figure', ...
                fname
                );

        endif;

        % Get data container user data
        gddtp = guidata(gduip.hdtp);

        if(~isfield(gddtp, 'app_data') || ~isstruct(gddtp.app_data))
            error( ...
                '%s: data storage figure does not contain data storage', ...
                fname
                );

        endif;

        % % Get view's data
        view_data = getfield(gddtp.app_data, view_tag);

        % Set new item title --------------------------------------------------

        % Get field value
        view_data.item.title = get( ...
            getfield( ...
                figure_handles, ...
                strjoin({view_tag, 'title_field'}, '_') ...
                ), ...
            'string' ...
            );
        gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);

        % Save the data
        guidata(gduip.hdtp, gddtp);

    endif;

    itemEditViewUpdateView(hfigure, [], view_tag);

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditViewOnValueEdit':
%
% Use:
%       -- itemEditViewOnValueEdit(hsrc, evt, view_tag)
%
% Description:
% TODO: add function description here
%
% -----------------------------------------------------------------------------
function itemEditViewOnValueEdit(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditViewOnValueEdit';
    use_case = ' -- itemEditViewOnValueEdit(hsrc, evt, view_tag)';

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

    % We ignore evt argument

    % Validate view_tag argument
    if(~ischar(view_tag))
        error( ...
            '%s: view_tag must be a character array', ...
            fname
            );
    endif;

    % Get figure handles
    hfigure = gcbf();
    figure_handles = guihandles(hsrc);

    % Check if the calling figure holds our view, else we ignore the signal
    if(isfield(figure_handles, view_tag))

        % Get figure user data
        gduip = guidata(hfigure);

        % Check if object returned by guidata() contains all necessary fields
        if(~isfield(gduip, 'hdtp') || ~isfigure(gduip.hdtp))
            error( ...
                '%s: figure does not contain handle to data storage figure', ...
                fname
                );

        endif;

        % Get data container user data
        gddtp = guidata(gduip.hdtp);

        if(~isfield(gddtp, 'app_data') || ~isstruct(gddtp.app_data))
            error( ...
                '%s: data storage figure does not contain data storage', ...
                fname
                );

        endif;

        % % Get view's data
        view_data = getfield(gddtp.app_data, view_tag);

        % Set new item value --------------------------------------------------

        % Get field value
        view_data.item.value = get( ...
            getfield( ...
                figure_handles, ...
                strjoin({view_tag, 'value_field'}, '_') ...
                ), ...
            'string' ...
            );
        gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);

        % Save the data
        guidata(gduip.hdtp, gddtp);

    endif;

    itemEditViewUpdateView(hfigure, [], view_tag);

endfunction;
