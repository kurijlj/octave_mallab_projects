function f = scanset_load(varargin);
% -----------------------------------------------------------------------------
%
% Function 'scanset_load':
%
% Use:
%       -- f = scanset_load(filename)
%       -- f = scanset_load(filename1, filename2, ...)
%       -- f = scanset_load(..., "PROPERTY", VALUE, ...)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
%%  Define function name and use cases strings --------------------------------
    fname = 'scanset_load';
    use_case_a = sprintf(' -- f = %s(filename)', fname);
    use_case_b = sprintf(' -- f = %s(filename1, filename2, ...)', fname);
    use_case_c = sprintf(' -- f = %s(..., "PROPERTY", VALUE, ...)', fname);

%%  Add required packages to the path -----------------------------------------
    pkg load image;
    pkg load ltfat;

%%  Validate input arguments --------------------------------------------------
    if(1 <= nargin)
        % Determine index of the first optional argument
        idx = 1;
        while(nargin >= idx);
            if( ...
                isequal('smoothing', varargin{idx}) ...
                || isequal('window', varargin{idx}) ...
                || isequal('wt', varargin{idx}) ...
                || isequal('J', varargin{idx}) ...
                || isequal('fs', varargin{idx}) ...
                )
                break;

            endif;

            ++idx;

        endwhile;

        % Parse optional arguments
        [ ...
            pos, ...
            smoothing, ...
            window, ...
            wt, ...
            J, ...
            fs ...
            ] = parseparams( ...
            varargin(idx:end), ...
            'smoothing', 'none', ...
            'window', [], ...
            'wt', 'none', ...
            'J', 0, ...
            'fs', 'none' ...
            );

        if(0 ~= numel(pos))
            % Invalid call to function
            error( ...
                'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
                fname, ...
                use_case_a, ...
                use_case_b, ...
                use_case_c ...
                );

        endif;

        pos = varargin(1:idx - 1);

%%      Validate value supplied for the smoothing -----------------------------
        validatestring( ...
            smoothing, ...
            {'none', 'median', 'wiener', 'uwt'}, ...
            fname, ...
            'smoothing' ...
            );

%%      Validate value supplied for the window --------------------------------
        if(isequal('median', smoothing) || isequal('wiener', smoothing))
            % Window property value is only required if smoothing is set to
            % Median or Wiener ...

            % If window is empty assign the default value
            if(isempty(window))
                window = [3 3];

            endif;

            validateattributes( ...
                window, ...
                {'numeric'}, ...
                { ...
                    'vector', ...
                    'numel', 2, ...
                    'integer', ...
                    '>=', 1 ...
                    }, ...
                fname, ...
                'window' ...
                );

        else
            % ... for all other filter selections we ignore value of the
            % Window property
            window = [];

        endif;

%%      Validate values of the properties related to 'UWT' smoothing ----------
        if(isequal('uwt', smoothing))
            % Wavelet filterbank definition, number of filterbank iterations,
            % filter scaling and threshold type properties are only required if
            % filter is set to 'uwt' ...

            % Validate value of the wavelet filterbank definition property

            % Use the default value if 'None' assigned
            if(isequal('none', wt))
                wt = 'ana:spline3:7';

            endif;

            try
                wt = fwtinit(wt);

            catch err
                error( ...
                    '%s: %s', ...
                    fname, ...
                    err.message ...
                    );

            end_try_catch;

            % Validate value of the number of wavelet filterbank
            % iterations property

            % Use the default value if none (0) assigned
            if(0 == J)
                J = 3;

            endif;

            validateattributes( ...
                J, ...
                {'numeric'}, ...
                { ...
                    'nonnan', ...
                    'nonempty', ...
                    'integer', ...
                    'scalar', ...
                    '>=', 1 ...
                    }, ...
                fname, ...
                'J' ...
                );

            % Validate the value of the wavelet filter scaling property

            % Use the default value if 'none' assigned
            if(isequal('none', fs))
                fs = 'sqrt';

            endif;

            validatestring( ...
                fs, ...
                {'sqrt', 'noscale', 'scale'}, ...
                fname, ...
                'fs' ...
                );

        else
            % ... for all other cases we ignore the values of these
            % properties
            wt  = 'none';
            J  = 0;
            fs = 'none';

        endif;  % if(isequal('uwt', smoothing))

%%  Validate positional arguments (matrices containig pixel data) -------------
    idx = 1;
    L = W = 0;
    C = 3;      % We only accept RGB images
    while(numel(pos) >= idx)
        try
            im_info = imfinfo(pos{idx});

        catch err
            error( ...
                '%s: %s', ...
                fname, ...
                err.message ...
                );

        end_try_catch;

        if(~isequal('TIFF', im_info.Format))
            error( ...
                '%s: File \"%s\" is not a TIFF file.', ...
                fname, ...
                pos{idx} ...
                );

        endif;

        if(16 ~= im_info.BitDepth)
            error( ...
                '%s: Number of bits per channel for file \"%s\" is not 16.', ...
                fname, ...
                pos{idx} ...
                );

        endif;

        % Read scan data
        img = imread(pos{idx});

        % If first image file, set it size as reference
        if(1 == idx)
            [L, W, C] = size(img);

        endif;

        % Check if all supplied scans comply in size
        if(L ~= size(img, 1) || W ~= size(img, 2) || C ~= size(img, 3))
            error( ...
                cstrcat( ...
                    '%s: Size of image file \"%s\" does not comply to ', ...
                    'reference size (expected %dx%dx%d, got %dx%dx%d).' ...
                    ), ...
                fname, ...
                pos{idx}, ...
                L, W, C, ...
                size(pos{idx}, 1), size(pos{idx}, 2), size(pos{idx}, 3) ...
                );

        endif;

        % If first iteration allocate output data
        if(1 == idx)
            f = zeros(L, W, C);

        endif;

        % Convert pixel values to floating point
        img = double(img);

        % Smooth pixel data if required
        if(~isequal('none', smoothing))
            if(isequal('median', smoothing))
                cc = 1;
                while(3 >= cc)
                    img(:, :, cc) = medfilt2(img(:, :, cc), window);
                    ++cc;
                endwhile;

            elseif(isequal('wiener', smoothing))
                cc = 1;
                while(3 >= cc)
                    img(:, :, cc) = wiener2(img(:, :, cc), window);
                    ++cc;
                endwhile;

            else
                cc = 1;
                while(3 >= cc)
                    img(:, :, cc) = mrs_denoise_soft(img(:, :, cc), wt, J, fs);
                    ++cc;
                endwhile;

            endif;

        endif;

        % Average pixel data and accumulate
        f = f + img/numel(pos);

        ++idx;

    endwhile;  % while(numel(pos) >= idx)

    else  % No arguments supplied
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b, ...
            use_case_c ...
            );

    endif;  % if(1 <= nargin)

endfunction;  % scanset_load()