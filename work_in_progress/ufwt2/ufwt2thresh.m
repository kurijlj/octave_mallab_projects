function [Vt, Ht, Dt] = ufwt2thresh(V, H, D, varargin)
% -----------------------------------------------------------------------------
%
% Function 'ufwt2thresh':
%
% Use:
%       -- [Vt, Ht, Dt] = ufwt2thresh(V, H, D)
%       -- [Vt, Ht, Dt] = ufwt2thresh(..., "PROPERTY", VALUE, ...)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
%%  Define function name and use cases strings --------------------------------
    fname = 'ufwt2thresh';
    use_case_a = sprintf(' -- [Vt, Ht, Dt] = %s(V, H, D)', fname);
    use_case_b = sprintf(
        ' -- [Vt, Ht, Dt] = %s(..., "PROPERTY", VALUE, ...)',
        fname
        );

%%  Add required packages to the path -----------------------------------------
    pkg load image;
    pkg load ltfat;

%%  Validate input arguments --------------------------------------------------

    % Check positional parameters ---------------------------------------------

    % Check the number of positional parameters
    if(3 > nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate input coeficients format
    validateattributes( ...
        V, ...
        {'float'}, ...
        { ...
            'ndims', 4, ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'V' ...
        );

    [J, filtNo, L, W] = size(V);

    validateattributes( ...
        H, ...
        {'float'}, ...
        { ...
            'ndims', 4, ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'H' ...
        );

    if(J ~= size(H, 1))
        error( ...
            sprintf( ...
                cstrcat( ...
                    "%s: Number of levels in the coefficients matrix H", ...
                    " does not match number of levels in the V (expected", ...
                    " %d, got %d)." ...
                    ), ...
                fname, J, size(H, 1) ...
                ) ...
            );

    elseif(filtNo ~= size(H, 2))
        error( ...
            sprintf( ...
                cstrcat( ...
                    ": Number of filterbank coefficients in the", ...
                    " coefficients matrix H does not match number of", ...
                    " filterbank coeficients in the V (expected %d,", ...
                    " got %d)." ...
                    ), ...
                fname, filtNo, size(H, 1) ...
                ) ...
            );

    elseif(L ~= size(H, 3) || W ~= size(H, 4))
        error( ...
            sprintf( ...
                cstrcat( ...
                    "%s: Size of coefficients matrix H does not match", ...
                    " the size of V (expected %dx%d, got %dx%d)." ...
                    ), ...
                fname, L, W, size(H, 3), size(H, 4) ...
                ) ...
            );

    endif;

    validateattributes( ...
        D, ...
        {'float'}, ...
        { ...
            'ndims', 5, ...
            'finite', ...
            'nonempty', ...
            'nonnan' ...
            }, ...
        fname, ...
        'D' ...
        );

    if(J ~= size(D, 1))
        error( ...
            sprintf( ...
                cstrcat( ...
                    "%s: Number of levels in the coefficients matrix D", ...
                    " does not match number of levels in the V (expected", ...
                    " %d, got %d)." ...
                    ), ...
                fname, J, size(D, 1) ...
                ) ...
            );

    elseif(filtNo ~= size(D, 2) || filtNo ~= size(D, 3))
        error( ...
            sprintf( ...
                cstrcat( ...
                    ": Number of filterbank coefficients in the", ...
                    " coefficients matrix D does not match number of", ...
                    " filterbank coeficients in the V (expected %dx%d,", ...
                    " got %dx%d)." ...
                    ), ...
                fname, filtNo, filtNo, size(D, 2), size(D, 3) ...
                ) ...
            );

    elseif(L ~= size(D, 4) || W ~= size(D, 5))
        error( ...
            sprintf( ...
                cstrcat( ...
                    "%s: Size of coefficients matrix D does not match", ...
                    " the size of V (expected %dx%d, got %dx%d)." ...
                    ), ...
                fname, L, W, size(H, 4), size(H, 5) ...
                ) ...
            );

    endif;

    % Check optional arguments (if any) ---------------------------------------

    % Parse optional arguments
    [ ...
        pos, ...
        thrtype, ...
        modifier, ...
        setype ...
        ] = parseparams( ...
        varargin, ...
        'ThresholdType', 'hard', ...
        'Modifier', 'none', ...
        'SEType', 'x' ...
        );

    % We don't take any more positional arguments
    if(0 ~= numel(pos))
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate value supplied for the ThresholdType
    validatestring( ...
        thrtype, ...
        {'hard', 'soft'}, ...
        fname, ...
        'ThresholdType' ...
        );

    % Validate value supplied for the Modifier
    validatestring( ...
        modifier, ...
        {'none', 'erode', 'dilate'}, ...
        fname, ...
        'Modifier' ...
        );

    % Validate value supplied for the SEType
    validatestring( ...
        setype, ...
        {'.', '+', 'x', 'square'}, ...
        fname, ...
        'SEType' ...
        );

%%  Run computation -----------------------------------------------------------
    % Determine threshold factor
    w = 3;
    if(isequal('soft', thrtype))
        w = sqrt(2*log(L*W));
    endif;

    % Determine structuring element for the erosion and dilation (if required)
    se = [1 0 1; 0 1 0; 1 0 1];
    if(isequal('.', setype))
        se = [0 0 0; 0 1 0; 0 0 0];

    elseif(isequal('+', setype))
        se = [0 1 0; 1 1 1; 0 1 0];

    elseif(isequal('square', setype))
        se = [1 1 1; 1 1 1; 1 1 1];

    endif;

    % Allocate the result
    Vt = Ht = zeros(J, filtNo, L, W);
    Dt = zeros(J, filtNo, filtNo, L, W);

    jj = 1;
    while(J >= jj)

        kk = 1;
        while(filtNo >= kk)
            mV = V(jj, kk, :, :) > std2(V(jj, kk, :, :))*w;
            mH = H(jj, kk, :, :) > std2(H(jj, kk, :, :))*w;
            if(isequal('dilate', modifier))
                mV = imdilate(mV, se, 'same');
                mH = imdilate(mH, se, 'same');

            elseif(isequal('erode', modifier))
                mV = imerode(mV, se, 'same');
                mH = imerode(mH, se, 'same');

            endif;

            Vt(jj, kk, :, :) = V(jj, kk, :, :).*mV;
            Ht(jj, kk, :, :) = H(jj, kk, :, :).*mH;

            ll = 1;
            while(filtNo >= ll)
                mD = D(jj, kk, ll, :, :) > std2(D(jj, kk, ll, :, :))*w;
                if(isequal('dilate', modifier))
                    mD = imdilate(mD, se, 'same');

                elseif(isequal('erode', modifier))
                    mD = imerode(mD, se, 'same');

                endif;

                Dt(jj, kk, ll, :, :) = D(jj, kk, ll, :, :).*mD;

                ++ll;

            endwhile;  % while(filtNo >= ll)

            ++kk;

        endwhile;  % while(filtNo >= kk)

        ++jj;

    endwhile;  % while(J >= jj)
