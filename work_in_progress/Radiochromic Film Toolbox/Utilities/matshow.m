% -----------------------------------------------------------------------------
%
% Function 'matshow':
%
% Use:
%       -- matshow(M)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function matshow(M)
    fname = 'matshow';
    use_case_a = ' -- matshow(M)';

    % Validate input arguments ------------------------------------------------
    if(0 == nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case_a ...
            );

    endif;

    if(2 ~= ndims(M) && 3 ~= ndims(M))
        % Not supported matrix dimensions
        error( ...
            '%s: M has unsupported dimensions', ...
            fname ...
            );

    endif;

    % Convert matrix values to shades of gray ---------------------------------
    R = zeros(size(M, 1), size(M, 2), size(M, 3));

    idx = 1;
    while(size(mat, 3) >= idx)
        R(:, :, idx) = mat2gray(M(:, :, idx));

        ++idx;

    endwhile;

    % Display converted values using imshow -----------------------------------
    imshow(R, []);

endfunction;
