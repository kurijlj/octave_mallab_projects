control_panel_view_version = '1.0';

source('./app_uistyle_model.m');

% -----------------------------------------------------------------------------
%
% Function 'controlPanelViewNewView':
%
% Use:
%       -- hfig = controlPanelViewNewView(view_tag, item)
%       -- hfig = controlPanelViewNewView(view_tag, item, huip)';
%
% Description:
% TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hfig = controlPanelViewNewView(view_tag, huip)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'controlPanelViewNewView';
    use_case_a = ' -- hfig = controlPanelViewNewView(view_tag)';
    use_case_b = ' -- hfig = controlPanelViewNewView(view_tag, huip)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin && 2 ~= nargin)
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

    if(1 == nargin)
        % We don't have handle to a parent UI container, so we need to run 'Item
        % List View' as a standalone application, within it's own figure and
        % with underlying app_data

        % Initialize GUI toolkit
        graphics_toolkit qt;

        % Create figure and define it as parent to 'Item' view
        huip = figure( ...
            'tag', 'main_figure', ...
            'name', 'Control Panel View', ...
            'menubar', 'none', ...
            'units', 'normalized' ...
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

    view_data = struct();
    view_data.accepted = false;
    gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);

    % save app data to data storage figure
    guidata(gduip.hdtp, gddtp);

    controlPanelViewLayoutView(huip, view_tag);

    if(1 == nargin)
        % define callbacks for events we handle
        set( ...
            huip, ...
            'sizechangedfcn', {@controlPanelViewUpdateView, view_tag} ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'controlPanelViewLayoutView':
%
% Use:
%       -- controlPanelViewLayoutView(hparent, view_tag)
%
% Description:
% Create an new 'Control Panel View' and assign it to the parent container.
%
% -----------------------------------------------------------------------------
function controlPanelViewLayoutView(hparent, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'controlPanelViewLayoutView';
    use_case = ' -- controlPanelViewLayoutView(hparent, view_tag)';

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
    position = controlPanelViewElementsPosition(hparent);

    % Create 'Item' view panel ------------------------------------------------
    control_panel = uipanel( ...
        'parent', hparent, ...
        'title', 'Control Panel', ...
        'tag', view_tag, ...
        'position', position(1, :) ...
        );

    % Create button elements --------------------------------------------------

    % Set 'Accept' button -----------------------------------------------------
    uicontrol( ...
        'parent', control_panel, ...
        'tag', strjoin({view_tag, 'accept_button'}, '_'), ...
        'callback', {@controlPanelViewOnAccept, view_tag}, ...
        'style', 'pushbutton', ...
        'string', 'Accept', ...
        'units', 'normalized', ...
        'position', position(3, :) ...
        );

    % Set 'Cancel' button -----------------------------------------------------
    uicontrol( ...
        'parent', control_panel, ...
        'tag', strjoin({view_tag, 'cancel_button'}, '_'), ...
        'callback', {@controlPanelViewOnCancel, view_tag}, ...
        'style', 'pushbutton', ...
        'string', 'Cancel', ...
        'units', 'normalized', ...
        'position', position(2, :) ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'controlPanelViewUpdateView':
%
% Use:
%       -- controlPanelViewUpdateView(hsrc, evt, view_tag)
%
% Description:
% Update the view in response to the change of data or GUI elements
% repositioning due to size changed event.
%
% hsrc must be a handle to a figure.
%
% -----------------------------------------------------------------------------
function controlPanelViewUpdateView(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'controlPanelViewUpdateView';
    use_case = ' -- controlPanelViewUpdateView(hsrc, evt, view_tag)';

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
        position = controlPanelViewElementsPosition( ...
            get(getfield(figure_handles, view_tag), 'parent') ...
            );

        % Reset elements position
        set( ...
            getfield(figure_handles, view_tag), ...
            'position', position(1, :) ...
            );
        set( ...
            getfield(figure_handles, strjoin({view_tag, 'cancel_button'}, '_')), ...
            'position', position(2, :) ...
            );
        set( ...
            getfield(figure_handles, strjoin({view_tag, 'accept_button'}, '_')), ...
            'position', position(3, :) ...
            );

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'controlPanelViewElementsPosition':
%
% Use:
%       -- position = controlPanelViewElementsPosition(hcntr)
%
% Description:
% Calculate GUI elements position within set container.
%
% -----------------------------------------------------------------------------
function position = controlPanelViewElementsPosition(hcntr)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'controlPanelViewElementsPosition';
    use_case = ' -- position = controlPanelViewElementsPosition(hcntr)';

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
            '%s: hntr must be handle to a GUI control', ...
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
    btnhghabs = gduip.app_uistyle.btn_height_px / cexts(4);
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

    % Set button positions ----------------------------------------------------
    idx = 1;
    while(2 >= idx)
        position = [ ...
            position; ...
            (1.00 - btnwdtabs)/2, ...
            verpadabs + (idx - 1)*(btnhghabs + verpadabs), ...
            btnwdtabs, ...
            btnhghabs; ...
            ];

        idx = idx + 1;

    endwhile;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'controlPanelViewOnAccept':
%
% Use:
%       -- controlPanelViewOnAccept(hsrc, evt, view_tag)
%
% Description:
% TODO: add function description here
%
% -----------------------------------------------------------------------------
function controlPanelViewOnAccept(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'controlPanelViewOnAccept';
    use_case = ' -- controlPanelViewOnAccept(hsrc, evt, view_tag)';

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

        % Set new view state --------------------------------------------------

        view_data.accepted = true;
        gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);

        % Save the data
        guidata(gduip.hdtp, gddtp);

        % Close the figure
        close(hfigure);

    endif;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'controlPanelViewOnCancel':
%
% Use:
%       -- controlPanelViewOnCancel(hsrc, evt, view_tag)
%
% Description:
% TODO: add function description here
%
% -----------------------------------------------------------------------------
function controlPanelViewOnCancel(hsrc, evt, view_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'controlPanelViewOnCancel';
    use_case = ' -- controlPanelViewOnCancel(hsrc, evt, view_tag)';

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

        % Set new view state --------------------------------------------------

        view_data.accepted = false;
        gddtp.app_data = setfield(gddtp.app_data, view_tag, view_data);

        % Save the data
        guidata(gduip.hdtp, gddtp);

        % Close the figure
        close(hfigure);

    endif;

endfunction;
