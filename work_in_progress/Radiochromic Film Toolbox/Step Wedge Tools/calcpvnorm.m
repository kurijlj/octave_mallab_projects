function mpvn = calcpvnorm(msig, mcnt, mzrl=NaN, varargin)
%% -----------------------------------------------------------------------------
%%
%% Function 'calcpvnorm':
%%
%% -----------------------------------------------------------------------------
%
%  Use:
%       -- mpvn = calcpvnorm(msig, mcnt)
%       -- mpvn = calcpvnorm(msig, mcnt, mzrl)
%       -- mpvn = calcpvnorm(..., "PROPERTY", VALUE, ...)
%
%% Description:
%          Calculate PVnorm for the given set of measured signal pixel values
%          and for the given set of measured control piece pixel values
%          according to procedure described in the article:
%          https://doi.org/10.1016/j.ejmp.2018.05.014
%
%          Set of the measured control piece data samples must consist of only
%          one data sample. It is not mandatory for the calculation to signal
%          data samples and control piece data samples have identical windows
%          (ROIs). However, it is mandatory for the zero-light and control piece
%          data samples to be equivalent (see help on DataSample class).
%
% -----------------------------------------------------------------------------
    fname = "calcpvnorm";
    use_case_a = sprintf(" -- mpvn = %s(msig, mcnt)", fname);
    use_case_b = sprintf(" -- mpvn = %s(msig, mcnt, mzrl)", fname);
    use_case_c = sprintf(" -- mpvn = %s(..., 'PROPERTY', VALUE, ...)", fname);

    if(2 < nargin)
        % Invalid call to function
        error( ...
            "Invalid call to %s. Correct usage is:\n%s\n%s\n%s", ...
            fname, ...
            use_case_a, ...
            use_case_b, ...
            use_case_c ...
            );

    endif;

    % Validate positional input arguments -------------------------------------

    % Validate signal measurement argument
    if(~isa(msig, "Measurement") || msig.isempty())
        % Issue error message and abort calculation
        error( ...
            sprintf( ...
                cstrcat( ...
                    "%s: msig must be an non-empty instance of the ", ...
                    "'Measurement' class" ...
                    ), ...
                fname ...
                ) ...
            );

    endif;  % ~isa(msig, "Measurement") || msig.isempty()

    % Validate control piece measurement argument
    if(~isa(mcnt, "Measurement") || mcnt.isempty())
        % Issue error message and abort calculation
        error( ...
            sprintf( ...
                cstrcat( ...
                    "%s: mcnt must be an non-empty instance of the ", ...
                    "'Measurement' class" ...
                    ), ...
                fname ...
                ) ...
            );

    endif;  % ~isa(mcnt, "Measurement") || mcnt.isempty()
    if(1 ~= mcnt.numel())
        % Issue error message and abort calculation
        error( ...
            sprintf( ...
                cstrcat( ...
                    "%s: mcnt must be exactly one data sample long" ...
                    ), ...
                fname ...
                ) ...
            );

    endif;  % 1 ~= mcnt.numel()

    % If zero-light argument is set to Nan use the default value
    if(isnan(mzrl))
        % For the default value we copy data sample from control piece
        % measurement and we set value and the stdev to zero
        dscnt = mcnt.at(1);
        mzrl = Measurement( ...
            DataSample( ...
                dscnt.position, ...
                dscnt.window, ...
                dscnt.n, ...
                dscnt.value .* 0, ...
                dscnt.stdev .* 0 ...
                ) ...
            );

    endif;  % isnan(mzrl)

    % Validate zero-light measurement argument
    if(~isa(mzrl, "Measurement") || mzrl.isempty())
        % Issue error message and abort calculation
        error( ...
            sprintf( ...
                cstrcat( ...
                    "%s: mzrl must be an non-empty instance of the ", ...
                    "'Measurement' class" ...
                    ), ...
                fname ...
                ) ...
            );

    endif;  % ~isa(mzrl, "Measurement") || mzrl.isempty()
    if(1 ~= mzrl.numel())
        % Issue error message and abort calculation
        error( ...
            sprintf( ...
                cstrcat( ...
                    "%s: mzrl must be exactly one data sample long" ...
                    ), ...
                fname ...
                ) ...
            );

    endif;  % 1 ~= mzrl.numel()
    if(~mcnt.isequivalent(mzrl))
        % Issue error message and abort calculation
        error( ...
            sprintf( ...
                cstrcat( ...
                    "%s: zero-light and control piece measurements must ", ...
                    "be equivalent (see help on 'Measurement' class)" ...
                    ), ...
                fname ...
                ) ...
            );

    endif;  % ~mcnt.isequivalent(mzrl)

    % Parse optional arguments ------------------------------------------------
    [ ...
        pos, ...
        title ...
        ] = parseparams( ...
        varargin, ...
        'Title', datestr(datenum(date())) ...
        );

    if(0 ~= numel(pos))
        % Invalid call to function
        error( ...
            "Invalid call to %s. Correct usage is:\n%s\n%s\n%s", ...
            fname, ...
            use_case_a, ...
            use_case_b, ...
            use_case_c ...
            );

    endif;  % 0 ~= numel(pos)

    % Validate optional arguments ---------------------------------------------

    % Validate Title argument
    if(~ischar(title) || isempty(title))
        error('%s: Title must be a non-empty string', fname);

    endif;

    % Do the computation ------------------------------------------------------

    % Initialize the return variable
    mpvn = Measurement('Title', title);

    idx = 1;
    dscnt = mcnt.at(1);
    dszrl = mzrl.at(1);
    while(msig.numel() >= idx)
        dssig = msig.at(idx);

        % Calculate the signal value corrected for the zero-light
        scorr = dssig.value - dszrl.value;

        % Calculate the control piece value corrected for the zero-ligh
        ccorr = dscnt.value - dszrl.value;

        % Calculate the ratio of the corrected control piece value to the
        % corrected signal value
        rcorr = ccorr ./ scorr;

        % Calculate the PVnorm value
        pvn = rcorr - 1;

        % Calculate the standard deviation for the PVnorm as the function of
        % number of samples and standard error of indirectly measured quantity
        pvnstd = (sqrt(dssig.n)/3) ...
            .* ( ...
                (dscnt.stderr(3) + dszrl.stderr(3))./(ccorr) ...
                + (dssig.stderr(3) + dszrl.stderr(3))./(scorr) ...
                ) ...
            .* rcorr;

        mpvn = mpvn.append( ...
            DataSample( ...
                dssig.position, ...
                dssig.window, ...
                dssig.n, ...
                pvn, ...
                pvnstd ...
                ) ...
            );

        ++idx;

    endwhile;  % End of computation

endfunction;  % calcpvnorm()
