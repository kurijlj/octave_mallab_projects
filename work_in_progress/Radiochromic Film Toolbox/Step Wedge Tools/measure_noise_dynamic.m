function [ndr, ndg, ndb] = measure_noise_dynamic(ss, wt, J, scaling='sqrt')
% ------------------------------------------------------------------------------
%
% Function 'measure_noise_dynamic':
%
% Use:
%       -- [ndr, ndg, ndb] = measure_noise_dynamic(ss, w, J)
%       -- [ndr, ndg, ndb] = measure_noise_dynamic(ss, w, J, scaling)
%
% Description:
%       Calculate how noise coeficients change with each levele of decomposition
%       for the given signal and wavelet filterbank.
%
%       The function takes the following arguments:
%         ss: signal (as ScanSet structure)
%         w: wavelet filterbank (as Wavelet object)
%         J: number of decomposition levels
%         scaling: scaling of the noise coefficients
%
% For each level of decomposition, the function calculates the noise by
% subtracting the resiuduals matrix from the original image data. Then it
% calculates the mean squared values for each pixel. At the end it plots the how
% mean squared values change with each level of decomposition. diference of
% pixel value changes with each level of decomposition.for each color channel.
%
% ------------------------------------------------------------------------------

%% Define functiona name and use cases strings ---------------------------------
    fname = "measure_noise_dynamic";
    use_case_a = sprintf(" -- [ndr, ndg, ndb] = %s(ss, w, J)", fname);
    use_case_b = sprintf(" -- [ndr, ndg, ndb] = %s(ss, w, J, scaling)", fname);

%%  Add required packages to the path -----------------------------------------
    pkg load image;
    pkg load ltfat;

%% Validate input arguments ----------------------------------------------------
    % Check the number of input parameters
    if(3 ~= nargin && 4 ~= nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b ...
            );

    endif;

    % Validate scanset argument
    if(~isa(ss, 'Scanset'))
        error( ...
            '%s: ss must be an instance of the "Scanset" class', ...
            fname ...
            );

    endif;  % ~isa(ss, 'Scanset')

    if(~ss.isvalid())
        error( ...
            '%s: ss must be a valid Scanset instance', ...
            fname ...
            );

    endif;  % ~ss.isvalid()

    % Validate value(s) supplied for the wavelet filterbank definition
    try
        wt = fwtinit(wt);

    catch err
        error( ...
            '%s: %s', ...
            fname, ...
            err.message ...
            );

    end_try_catch;  % try-catch fwtinit(w)

    % This could be removed with some effort. The question is, are there such
    % wavelet filters? If your filterbank has different subsampling factors
    % after first two filters, please send a feature request.
    assert( ...
        wt.a(1) == wt.a(2), ...
        cstrcat( ...
            'First two elements of a vector w.a are not equal. ', ...
            'Such wavelet filterbank is not suported.' ...
            ) ...
        );

    % For holding the time-reversed, complex conjugate impulse responses.
    filtNo = length(wt.h);

    % Validate value supplied for the number of filterbank iterations
    validateattributes( ...
        J, ...
        {'numeric'}, ...
        { ...
            'scalar', ...
            'finite', ...
            'nonempty', ...
            'nonnan', ...
            'integer', ...
            'positive', ...
            '>=', 1 ...
            }, ...
        fname, ...
        'J' ...
        );

    % Validate value supplied for the filter scaling
    validatestring( ...
        scaling, ...
        {'noscale', 'scale', 'sqrt'}, ...
        fname, ...
        'scaling' ...
        );

%%  Verify length of the input signal -----------------------------------------
    if(2 > ss.data_size()(1) || 2 > ss.data_size()(2))
        error(
            '%s: Input signal seems not to be a matrix of at least 2x2 size.',
            fname
            );

    endif;

%%  Run computation -----------------------------------------------------------
    % Optionally scale the filters
    h = comp_filterbankscale(wt.h(:), wt.a(:), scaling);

    %Change format to a matrix
    hMat = cell2mat(cellfun(@(hEl) hEl.h(:), h(:)', 'UniformOutput', 0));

    % Delays
    hOffset = cellfun(@(hEl) hEl.offset, h(:));

    % Allocate output and mid result
    l = ss.data_size()(1);
    w = ss.data_size()(2);
    WG = zeros(l, w, J + 1);
    WB = zeros(l, w, J + 1);
    WR(:, :, 1) = ss.pixel_data()(:, :, 1);
    WG(:, :, 1) = ss.pixel_data()(:, :, 2);
    WB(:, :, 1) = ss.pixel_data()(:, :, 3);
    FR = zeros(l, w);
    FG = zeros(l, w);
    FB = zeros(l, w);
    ndr = zeros(J, 1);
    ndg = zeros(J, 1);
    ndb = zeros(J, 1);

    runPtr = J + 1;
    jj = 1;
    while(J >= jj)
        % Zero index position of the upsampled filters.
        offset = wt.a(1)^(jj-1).*(hOffset);

        % Run filterbank
        % First run on columns
        CR = comp_atrousfilterbank_td(
            WR(:, :, 1),
            hMat,
            wt.a(1)^(jj-1),
            offset
            );
        CG = comp_atrousfilterbank_td(
            WG(:, :, 1),
            hMat,
            wt.a(1)^(jj-1),
            offset
            );
        CB = comp_atrousfilterbank_td(
            WB(:, :, 1),
            hMat,
            wt.a(1)^(jj-1),
            offset
            );

        % Run on rows
        CR = comp_atrousfilterbank_td(
            squeeze(CR(:, 1, :))',
            hMat,
            wt.a(1)^(jj-1),
            offset
            );
        CG = comp_atrousfilterbank_td(
            squeeze(CG(:, 1, :))',
            hMat,
            wt.a(1)^(jj-1),
            offset
            );
        CB = comp_atrousfilterbank_td(
            squeeze(CB(:, 1, :))',
            hMat,
            wt.a(1)^(jj-1),
            offset
            );

        WR(:, :, runPtr) = WR(:, :, 1) - squeeze(CR(:, 1, :))';
        WG(:, :, runPtr) = WG(:, :, 1) - squeeze(CG(:, 1, :))';
        WB(:, :, runPtr) = WB(:, :, 1) - squeeze(CB(:, 1, :))';

        ndr(jj) = std2(ss.pixel_data()(:, :, 1) - WR(:, :, 1));
        ndg(jj) = std2(ss.pixel_data()(:, :, 2) - WG(:, :, 1));
        ndb(jj) = std2(ss.pixel_data()(:, :, 3) - WB(:, :, 1));

        WR(:, :, 1) = squeeze(CR(:, 1, :))';
        WG(:, :, 1) = squeeze(CG(:, 1, :))';
        WB(:, :, 1) = squeeze(CB(:, 1, :))';

        % Calculate mean squared difference of pixel values
        % ndr(jj) = mean2(((ss.pixel_data()(:, :, 1) - WR(:, :, 1)).^2)./ss.pixel_data()(:, :, 1).^2);
        % ndg(jj) = mean2(((ss.pixel_data()(:, :, 2) - WG(:, :, 1)).^2)./ss.pixel_data()(:, :, 2).^2);
        % ndb(jj) = mean2(((ss.pixel_data()(:, :, 3) - WB(:, :, 1)).^2)./ss.pixel_data()(:, :, 3).^2);

        --runPtr;
        ++jj;

    endwhile;

    plot(
        1:J, ndr, "color", "red",
        1:J, ndg, "color", "green",
        1:J, ndb, "color", "blue"
        );

endfunction;  % measure_noise_dynamic(f, )