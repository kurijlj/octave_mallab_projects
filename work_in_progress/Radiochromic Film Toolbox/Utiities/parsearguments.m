% -----------------------------------------------------------------------------
%
% Function 'parsearguments':
%
% Use:
%       -- [pos, props] = parsearguments(args)
%       -- [pos, props] = parsearguments(args, proptbl)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function [pos, props] = parsearguments(args, proptbl={})
    fname = 'parsearguments';
    use_case_a = ' -- [pos, props] = parsearguments(args)';
    use_case_b = ' -- [pos, props] = parsearguments(args, proptbl)';

    % Validate input arguments ------------------------------------------------
    if(1 ~= nargin && 2 ~= nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    if(~iscell(args))
        % Invalid call to function
        error( ...
            '%s: args must be a cell array', ...
            fname ...
            );

    endif;

    if(~iscell(proptbl))
        % Invalid call to function
        error( ...
            '%s: proptbl must be a cell array', ...
            fname ...
            );

    endif;

    if(~isempty(proptbl))
        % Check if we have a two-column cell array
        if(2 ~= size(proptbl)(2))
            % Invalid call to function
            error( ...
                '%s: proptbl must be a two column cell array, containing property-default value pairs', ...
                fname ...
                );

        endif;

        % Check if all property names are character arrays
        if(~iscellstr(proptbl(:, 1)))
            % Invalid call to function
            idx = 1;
            p = proptbl(:, 1);
            while(numel(p) >= idx)
                if(~ischar(p{idx}))
                    error( ...
                        '%s: property name for proptbl{%d, 1} must be a character array', ...
                        fname, ...
                        idx ...
                        );
                endif;

                ++idx;

            endwhile;

        endif;

    endif;

    % Initialize return variables ---------------------------------------------
    pos = {};
    props = {};

    % Determine positional arguments ------------------------------------------

    % We expect that first n arguments are positional. Starting from n + 1
    % either have no more arguments or property-value portion starts
    idx = 1;
    while(numel(args) >= idx)
        if( ...
                ~isempty(proptbl) ...
                && ischar(args{idx}) ...
                && ismember(args{idx}, proptbl(:, 1)) ...
                )
            break;

        endif;

        pos = {pos{:}, args{idx}};

        ++idx;

    endwhile;

    % Determine properties ----------------------------------------------------

    % Copy properties with default values to resulting variable
    props = proptbl;

    % Traverse rest of the arguments in search of properties and their values
    if(~isempty(props))
        idx = numel(pos) + 1;
        while(numel(args) >= idx)
            if(ischar(args{idx}))
                [result, sidx] = ismember(args{idx}, props(:, 1));
                if(result)
                    % We have a property from the table

                    % Check if user supplied a value or we are using default one
                    if( ...
                            ~ischar(args{idx + 1}) ...
                            || ~ismember(args{idx + 1}, props(:, 1)) ...
                            )
                        props(sidx, 2) = args{idx + 1};

                        % Increase poiter
                        ++idx;

                    endif;

                else
                    % We have a property that is not defined in the properties table
                    error( ...
                        '%s: unrecognized option: %s', ...
                        fname, ...
                        args{idx} ...
                        );

                endif;

            else
                % We have a strained argument
                error( ...
                    '%s: arg{%d} not an property', ...
                    fname, ...
                    idx ...
                    );

            endif;

            ++idx;

        endwhile;

    endif;

endfunction;
