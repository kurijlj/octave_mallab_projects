% -----------------------------------------------------------------------------
%
% Function 'OkCancelDialog':
%
% Use:
%       -- handles = OkCancelDialog(name, uistyle)
%
% Description:
%          Demo and functionality test dialog for the OkCancelPanel view.
%
% -----------------------------------------------------------------------------
function handles = OkCancelDialog(name, uistyle)
    fname = 'OkCancelDialog';
    use_case_a = ' -- handles = OkCancelDialog(name, uistyle)';

    % Validate input arguments ------------------------------------------------

    if(~ischar(name) || isempty(name))  % name can be an empty string
        error( ...
            '%s: name must be an nonempty character array', ...
            fname
            );

    endif;

    if(~isa(uistyle, 'AppUiStyle'))
        error( ...
            '%s: uistyle must be an instance of the "AppUiStyle" class', ...
            fname ...
            );

    endif;

    % Create the GUI elements -------------------------------------------------
    handles = struct();

    % Create main figure
    handles.figure = figure('name', name);

    % Create main view
    handles.main_view = OkCancelPanel(handles.figure, 'Select Option', uistyle);

    % Connect callbacks to events ---------------------------------------------
    set( ...
        handles.figure, ...
        'sizechangedfcn', {@onWindowResize, handles.main_view, uistyle} ...
        );

endfunction;


% -----------------------------------------------------------------------------
%
% Callbacks section
%
% -----------------------------------------------------------------------------

% -----------------------------------------------------------------------------
%
% Callback 'onWindowResize':
%
% Use:
%       -- onWindowResize(hsrc, evt, handles, uistyle)
%
% Description:
%          Callback for the 'SizeChangedFcn' event.
%
% -----------------------------------------------------------------------------
function onWindowResize(hsrc, evt, handles, uistyle)
    position = okCancelPanelElementsPosition(handles.main_panel, uistyle);
    set(handles.btn_ok, 'position', position(1, :));
    set(handles.btn_cancel, 'position', position(2, :));

endfunction;
