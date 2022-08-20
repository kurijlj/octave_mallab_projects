item_edit_dlg_version = '1.0';

source('./item_edit_view.m');
source('./control_panel_view.m');

% -----------------------------------------------------------------------------
%
% Function 'itemEditDlgNewDlg':
%
% Use:
%       -- hfig = itemEditDlgNewDlg(dlg_tag)
%       -- hfig = itemEditDlgNewDlg(dlg_tag, hparent)
%
% Description:
% TODO: Add function description here
%
% -----------------------------------------------------------------------------
function hfig = itemEditDlgNewDlg(dlg_tag, name, hparent)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgNewDlg';
    use_case_a = ' -- hfig = itemEditDlgNewDlg(dlg_tag, name)';
    use_case_a = ' -- hfig = itemEditDlgNewDlg(dlg_tag, name, hparent)';

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

    % Validate dlg_tag argument
    if(~ischar(dlg_tag))
        error( ...
            '%s: dlg_tag must be a character array', ...
            fname
            );
    endif;

    % Validate name argument
    if(~ischar(name))
        error( ...
            '%s: name must be a character array', ...
            fname
            );
    endif;

    % Validate hparent argument
    if(3 == nargin && ~isfigure(hparent))
        error( ...
            '%s: hparent must be handle to a parent figure', ...
            fname
            );

    endif;

    % Initialize variables for storing all relevant app data
    gduip = NaN;
    gddtp = NaN;

    if(2 == nargin)
        % We don't have handle to a parent figure, so we need to run 'Item
        % Edit Dialoge' as a standalone application.

        % Initialize GUI toolkit
        graphics_toolkit qt;

        % Create figure
        huip = figure( ...
            'tag', dlg_tag, ...
            'name', name, ...
            'menubar', 'none', ...
            'units', 'normalized', ...
            'deletefcn', {@itemEditDlgOnClose, dlg_tag}, ...
            'sizechangedfcn', @itemEditDlgUpdateView ...
            );

        % Initialize structures for storing application relevant data
        gduip = struct();
        gduip.hdtp = huip;  % Set main figure as data container too
        gduip.app_uistyle = newAppUiStyle();
        gddtp = gduip;
        gddtp.app_data = struct();

        % save app data to data storage figure
        guidata(gduip.hdtp, gddtp);

    else
        % We have a handle to the parent figure. Get handle to the app data
        % and validate it
        gddtp = guidata(hparent);

        if(~isfield(gddtp, 'app_data') || ~isstruct(gddtp.app_data))
            error( ...
                '%s: data storage figure does not contain data storage', ...
                fname
                );

        endif;

        % Create figure
        huip = figure( ...
            'parent', hparent, ...
            'tag', dlg_tag, ...
            'name', name, ...
            'menubar', 'none', ...
            'units', 'normalized', ...
            'deletefcn', {@itemEditDlgOnClose, dlg_tag}, ...
            'sizechangedfcn', @itemEditDlgUpdateView ...
            );

        % Initialize structures for storing application relevant data
        gduip = struct();
        gduip.hdtp = hparent;  % Set main figure as data container too
        gduip.app_uistyle = newAppUiStyle();

        % save app data to data storage figure
        guidata(huip, gduip);

    endif;

    itemEditDlgLayoutDlg(huip, dlg_tag);
    hfig = huip;

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditDlgLayoutDlg':
%
% Use:
%       -- itemEditDlgLayoutDlg(hfig, dlg_tag)
%
% Description:
% TODO: add function description here
%
% -----------------------------------------------------------------------------
function itemEditDlgLayoutDlg(hfig, dlg_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgLayoutDlg';
    use_case = ' -- itemEditDlgLayoutDlg(hfig, dlg_tag)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
        error('Invalid call to %s. Correct usage is:\n%s', fname, use_case);

    endif;

    % Validate hfig argument
    if(~isfigure(hfig))
        error( ...
            '%s: hparent must be handle to a graphics object', ...
            fname
            );

    endif;

    % Validate dlg_tag argument
    if(~ischar(dlg_tag))
        error( ...
            '%s: view_tag must be a character array', ...
            fname
            );
    endif;

    % Initialize gui elements positions ---------------------------------------
    position = itemEditDlgElementsPosition(hfig);

    % Create top panels -------------------------------------------------------

    % Create 'Item Edit View' panel
    data_panel = uipanel( ...
        'parent', hfig, ...
        'tag', 'data_panel',
        'bordertype', 'none',
        'position', position(2, :) ...
        );

    % Create bottom panel for the controls
   control_panel = uipanel( ...
        'parent', hfig, ...
        'tag', 'control_panel',
        'bordertype', 'none',
        'position', position(1, :) ...
        );

    % Create views ------------------------------------------------------------
    itemEditViewNewView( ...
        strjoin({dlg_tag, 'item_edit_view'}, '_'), ...
        itemDataModelNewItem( ...
            'Eneter item title here (unique)', ...
            'Enter item value here' ...
            ), ...
        data_panel ...
        );
    controlPanelViewNewView( ...
        strjoin({dlg_tag, 'control_panel'}, '_'), ...
        control_panel ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditDlgUpdateView':
%
% Use:
%       -- itemEditDlgUpdateView(hsrc, evt, dlg_tag)
%
% Description:
% Update the view in response to the change of data or GUI elements
% repositioning due to size changed event.
%
% hsrc must be a handle to a figure.
%
% -----------------------------------------------------------------------------
function itemEditDlgUpdateView(hsrc, evt)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgUpdateView';
    use_case = ' -- itemEditDlgUpdateView(hsrc, evt)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(2 ~= nargin)
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

    % Get figure handles
    figure_handles = guihandles(hsrc);

    % Get GUI elements postions
    position = itemEditDlgElementsPosition(hsrc);

    % Reset elements position
    set( ...
        getfield(figure_handles, 'data_panel'), ...
        'position', position(2, :) ...
        );
    set( ...
        getfield(figure_handles, 'control_panel'), ...
        'position', position(1, :) ...
        );

    % Update iews too
    itemEditViewUpdateView( ...
        hsrc, ...
        [], ...
        strjoin({dlg_tag, 'item_edit_view'}, '_') ...
        );
    controlPanelViewUpdateView( ...
        hsrc, ...
        [], ...
        strjoin({dlg_tag, 'control_panel'}, '_') ...
        );

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditDlgElementsPosition':
%
% Use:
%       -- position = itemEditDlgElementsPosition(hcntr)
%
% Description:
% Calculate GUI elements position within set container.
%
% -----------------------------------------------------------------------------
function position = itemEditDlgElementsPosition(hcntr)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgElementsPosition';
    use_case = ' -- position = itemEditDlgElementsPosition(hcntr)';

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

    % Set top-panel positions -------------------------------------------------

    % Bottom panel position
    position = [ ...
        position; ...
        horpadabs, ...
        verpadabs, ...
        1.00 - 2*horpadabs, ...
        (1.00 - 3*verpadabs)*0.25; ...
        ];

    % Top panel position
    position = [ ...
        position; ...
        horpadabs, ...
        2*verpadabs + (1.00 - 3*verpadabs)*0.25, ...
        1.00 - 2*horpadabs, ...
        (1.00 - 3*verpadabs)*0.75; ...
        ];

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'itemEditDlgOnClose':
%
% Use:
%       -- itemEditDlgOnClose(hsrc, evt, dlg_tag)
%
% Description:
% TODO: add function description here
%
% -----------------------------------------------------------------------------
function itemEditDlgOnClose(hsrc, evt, dlg_tag)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'itemEditDlgOnClose';
    use_case = ' -- itemEditDlgOnClose(hsrc, evt, dlg_tag)';

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

    % Validate dlg_tag argument
    if(~ischar(dlg_tag))
        error( ...
            '%s: dlg_tag must be a character array', ...
            fname
            );
    endif;

    % Get figure handles
    figure_handles = guihandles(hsrc);

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

    if( ...
            ~isfield(gddtp, 'app_data') ...
            || ~isstruct(gddtp.app_data) ...
            || ~isfield( ...
                gddtp.app_data, ...
                strjoin({dlg_tag, 'control_panel'}, '_') ...
                ) ...
            || ~isstruct( ...
                getfield( ...
                    gddtp.app_data, ...
                    strjoin({dlg_tag, 'control_panel'}, '_') ...
                    ) ...
                ) ...
            )
        error( ...
            '%s: data storage figure does not contain data storage', ...
            fname
            );

    endif;

    % Get dialog result
    cpdt = getfield(gddtp.app_data, strjoin({dlg_tag, 'control_panel'}, '_'));

    if(0 == cpdt.accepted)

        % User hit the cancel button. Invalidate item data
        edit_data = getfield( ...
            gddtp.app_data, ...
            strjoin({dlg_tag, 'item_edit_view'}, '_') ...
            );
        edit_data.item = NaN;
        gddtp.app_data = setfield( ...
            gddtp.app_data, ...
            strjoin({dlg_tag, 'item_edit_view'}, '_'), ...
            edit_data ...
            );

        % Save data to container
        guidata(gduip.hdtp, gddtp);

    endif;

endfunction;
