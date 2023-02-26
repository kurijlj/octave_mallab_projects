% -----------------------------------------------------------------------------
%
% Function 'plotcoefs':
%
% Use:
%       -- plotcoefs(A, H, V, D)
%
% Description:
%       Plot coeffcicents obtained with 'ufwt2' function.
%
%       The function requires 'ltfat' package installed to work.
%
% -----------------------------------------------------------------------------
function plotcoefs(A, H, V, D)
    fname = 'plotcoefs';
    use_case_a = ' -- plotcoefs(A, H, V, D)';

    % Add required packages to the path ---------------------------------------
    pkg load ltfat;

    % Validate input arguments ------------------------------------------------

    % Check the number of input parameters
    if(4 ~= nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case_a ...
            );

    endif;

    % Validate input coeficients format
    validateattributes( ...
        A, ...
        {'float'}, ...
        { ...
            '2d', ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'A' ...
        );
    validateattributes( ...
        H, ...
        {'float'}, ...
        { ...
            '3d', ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'H' ...
        );
    validateattributes( ...
        V, ...
        {'float'}, ...
        { ...
            '3d', ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'V' ...
        );
    validateattributes( ...
        D, ...
        {'float'}, ...
        { ...
            '3d', ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'D' ...
        );

    % Coeficient matrices must match in size
    length = size(A, 1);
    width = size(A, 2);
    J = size(H, 3);
    if(length ~= size(H, 1) || width ~= size(H, 2))
        error( ...
            '%s: Size of matrix H not in compliance with reference (A)', ...
            fname ...
            );
    elseif(length ~= size(V, 1) || width ~= size(V, 2) || J ~= size(V, 3))
        error( ...
            '%s: Size of matrix V not in compliance with reference (H)', ...
            fname ...
            );
    elseif(length ~= size(D, 1) || width ~= size(D, 2) || J ~= size(D, 3))
        error( ...
            '%s: Size of matrix D not in compliance with reference (H)', ...
            fname ...
            );
    endif;

    % Plotting section --------------------------------------------------------
    hfig = figure();
    haxes = axes(hfig);
    subplot(2, 2, 1);
    imshow(mat2gray(A));
    title("A");
    subplot(2, 2, 2);
    imshow(mat2gray(H(:, :, end)));
    title("H");
    subplot(2, 2, 3);
    imshow(mat2gray(V(:, :, end)));
    title("V");
    subplot(2, 2, 4);
    imshow(mat2gray(D(:, :, end)));
    title("D");


endfunction;