% -----------------------------------------------------------------------------
%
% Function 'pkg_loaded':
%
% Use:
%       -- pkg_loaded(pkg_name)
%
% Description:
%
%       Check if the named package is added to the path (loaded). It returns:
%
%           1 if package is added to the path;
%           0 if package is not added to the path;
%          -1 if the package does not exist.
%
% -----------------------------------------------------------------------------
function result = pkg_loaded(pkg_name)
    fname = 'pkg_loaded';
    use_case_a = ' -- pkg_loaded(pkg_name)';

    % Validate input arguments ------------------------------------------------

    % Check the numbe rof input parameters
    if(1 ~= nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case_a ...
            );

    endif;

    % Check if we are dealing with non-empty string ---------------------------
    if(~ischar(pkg_name) || isempty(pkg_name))
        error( ...
            '%s: pkg_name must be a non-empty string', ...
            fname, ...
            pkg_name ...
            );

    endif;

    % Initialize return variable to the deafult value
    result = -1;  % Package doesn't exist

    % Retrieve info abuut installed packages
    info = pkg('list');

    % Search installed packages for the named package
    idx = 1;
    while(numel(info) >= idx)
        if(isequal(info{idx}.name, pkg_name))
            % Named package found. Check if package is added to the path
            result = info{idx}.loaded;
            return;

        endif;

        ++idx;

    endwhile;


endfunction;
