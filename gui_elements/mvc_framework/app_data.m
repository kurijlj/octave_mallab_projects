app_data_version = '1.0';

source('./ui_layout_guides.m');

% -----------------------------------------------------------------------------
%
% Function 'newAppData':
%
% Use:
%       -- app_data = newAppData()
%
% Description:
%
% TODO: Add function description here
% -----------------------------------------------------------------------------
function app_data = newAppData(hfigure)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'newAppData';
    use_case = ' -- app_data = newAppData(hfigure)';

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

    app_data = struct();

    % Initialize structure for keeping common GUI guides
    app_data.ui_layout_guides = newUiLayoutGuides();

    % Initialize structure for keeping GUI handles
    app_data.ui_handles = struct();
    app_data.ui_handles.hfigure = hfigure;

    % Initialize array for storing views data
    app_data.data = struct();

endfunction;

% -----------------------------------------------------------------------------
%
% Function 'isAppDataStructure':
%
% Use:
%       -- result = isAppDataStructure(obj)
%
% Description:
%
% TODO: Add function description here
% -----------------------------------------------------------------------------
function result = isAppDataStructure(obj)

    % Store function name into variable
    % for easier management of error messages ---------------------------------
    fname = 'isAppDataStructure';
    use_case = ' -- result = isAppDataStructure(obj)';

    % Validate input arguments ------------------------------------------------

    % Validate number of input arguments
    if(1 ~= nargin)
        error( ...
            'Invalid call to %s.  Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case ...
            );

    endif;

    % Initialize return value to default
    result = false;

    if( ...
            isstruct(obj) ...
            && isfield(obj, 'ui_layout_guides') ...
            && isUiLayoutGuidesStructure(obj.ui_layout_guides) ...
            && isfield(obj, 'ui_handles') ...
            && isstruct(obj.ui_handles) ...
            && isfield(obj.ui_handles, 'hfigure') ...
            && isfield(obj, 'data') ...
            && isstruct(obj.data) ...
            )

        % Check obj.ui_handles fields
        idx = 1;
        flds = fieldnames(obj.ui_handles);
        while(numel(flds) >= idx)
            if(~ishandle(getfield(obj.ui_handles, flds{idx})))
                return;

            endif;

            idx = idx + 1;

        endwhile;

        result = true;

    endif;

endfunction;
