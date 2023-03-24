function msr = measure(AT, ss, window)
%% -----------------------------------------------------------------------------
%%
%% Function 'measure':
%%
%% -----------------------------------------------------------------------------
%
%  Use:
%       -- msr = msr(AT, ss, window)
%
%% Description:
%       Return a Measurement instance containing measured data samples for the
%       given pixel coordinates(AT(, scanset (ss) and window.
%
% -----------------------------------------------------------------------------
    fname = 'measure';
    use_case_a = sprintf(' -- msr = %s(AT, ss, window)', fname);

    if(3 ~= nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case_a ...
            );

    endif;

endfunction;  % measure(AT, ss, window)
