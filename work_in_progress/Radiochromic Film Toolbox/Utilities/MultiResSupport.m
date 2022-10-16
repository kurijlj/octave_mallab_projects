% -----------------------------------------------------------------------------
%
% Class 'MultiResSupport':
%
% Description:
%       TODO: Add class descritpion here.
%
% -----------------------------------------------------------------------------
classdef MultiResSupport

% -----------------------------------------------------------------------------
%
% Properties section (SetAccess: private, GetAccess: public)
%
% -----------------------------------------------------------------------------
    properties (SetAccess = private, GetAccess = public)
        % Wavelet definition
        wt = 'db8';
        % Number of filterbank iterations
        J = 1;
        % Filter scaling ('sqrt', 'noscale', 'scale')
        fs = 'sqrt';
        % Dilate (defines whether or not each scale should be dilated)
        dilate = false;
        % Multiresolution support array of dimensions Ix*Iy*J
        M = [];

    endproperties;

% -----------------------------------------------------------------------------
%
% Public methods section
%
% -----------------------------------------------------------------------------
    methods (Access = public)

% -----------------------------------------------------------------------------
%
% Method 'MultiResSupport':
%
% Use:
%       -- mrs = MultiResSupport()
%       -- mrs = MultiResSupport(..., "PROPERTY", VALUE, ...)
%       -- mrs = MultiResSupport(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function mrs = MultiResSupport(varargin)
            fname = 'MultiResSupport';
            use_case_a = ' -- mrs = MultiResSupport()';
            use_case_b = ' -- mrs = MultiResSupport(..., "PROPERTY", VALUE, ...)';
            use_case_c = ' -- mrs = MultiResSupport(other)';

            % Valdiate input arguments ----------------------------------------
            if(0 == nargin)
                % Invalid call to constructor
                error( ...
                    'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
                    fname, ...
                    use_case_a, ...
                    use_case_b, ...
                    use_case_c ...
                    );

            elseif(1 == nargin && isa(varargin{1}, 'MultiResSupport'))
                % Copy constructor invoked
                mrs.wt     = varargin{1}.wt;
                mrs.J      = varargin{1}.J;
                mrs.fs     = varargin{1}.fs;
                mrs.dilate = varargin{1}.dilate;
                mrs.M      = varargin{1}.M;

            else
                % Regular constructor invoked. Parse arguments
                [ ...
                    pos, ...
                    wt, ...
                    J, ...
                    fs, ...
                    dilate ...
                    ] = parseparams( ...
                    varargin, ...
                    'Wavelet', 'db8', ...
                    'NumberOfIterations', 1, ...
                    'FilterScaling', 'sqrt', ...
                    'Dilate', false ...
                    );

                if(1 ~= numel(pos))
                    % Invalid call to constructor
                    error( ...
                        'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
                        fname, ...
                        use_case_a, ...
                        use_case_b, ...
                        use_case_c ...
                        );

                endif;

                % Validate the input data
                validateattributes( ...
                    pos{1}, ...
                    {'numeric'}, ...
                    { ...
                        'nonnan', ...
                        'nonempty', ...
                        '2d' ...
                        }, ...
                    fname, ...
                    'img' ...
                    );

                % Validate value supplied for the Wavelet
                if(~ischar(wt) || isempty(wt))
                    error('%s: Wavelet must be a non-empty string', fname);

                endif;

                % Validate value supplied for the NumberOfIterations
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
                    'NumberOfIterations' ...
                    );

                % Validate value supplied for the FilterScaling
                validatestring( ...
                    fs, ...
                    {'sqrt', 'noscale', 'scale'}, ...
                    fname, ...
                    'FilterScaling' ...
                    );

                % Validate value supplied for the Dilate
                if(~isbool(dilate))
                    error('%s: Dilate must be a boolean value', fname);

                endif;

                % Assign values to a new instance -----------------------------
                mrs.wt     = wt;
                mrs.J      = J;
                mrs.fs     = fs;
                mrs.dilate = dilate;

                % Calculate the multiresolution support -----------------------

                % Load required modules
                pkg load ltfat;

                % Allocate space for the multiresolution support
                mrs.M = zeros(size(pos{1}, 1), size(pos{1}, 2), J);

                idx = 1;
                while(J >= idx)
                    [coef, info] = uwfbt( ...
                        pos{1}, ...
                        {mrs.wt, idx, 'full'}, ...
                        mrs.fs ...
                        );
                    w = reshape(coef(:, 2, :), size(coef, 1), size(coef, 3));
                    % We use MAD for the estimation of the noise sdev
                    s = median(abs(w)(:))/0.6745;
                    % We use unified threshold method
                    mrs.M(:, :, idx) = w >= s*sqrt(2*log(numel(w)));

                    % Dilate multiresolution support if switched on
                    if(dilate)
                        mrs.M(:, :, idx) = imdilate( ...
                            mrs.M(:, :, idx), ...
                            [0, 1, 0; 1, 1, 1; 0, 1, 0;] ...
                            );

                    endif;

                    ++idx;

                endwhile;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- mrs.disp()
%
% Description:
%          The disp method is used by Octave whenever a class instance should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(mrs)
            printf('\tMultiResSupport(\n');
            printf('\t\tWavelet:                  "%s",\n', mrs.wt);
            printf('\t\tNumber of iterations (J): %d\n', mrs.J);
            printf('\t\tFilter scaling:           "%s",\n', mrs.fs);
            if(mrs.dilate)
                printf('\t\tDilate:                   "true"\n');

            else
                printf('\t\tDilate:                   "false"\n');

            endif;
            printf( ...
                '\t\tM:                        [%dx%dx%d]\n', ...
                size(mrs.M, 1), ...
                size(mrs.M, 2), ...
                size(mrs.M, 3) ...
                );
            printf('\t)\n');

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'str_rep':
%
% Use:
%       -- result = mrs.str_rep()
%
% Description:
%          A convenience method that is used to format string representation of
%          the MultiResSupport instance.
%
% -----------------------------------------------------------------------------
        function result = str_rep(mrs)
            cn = 'MultiResSupport';
            if(mrs.dilate)
                result = sprintf( ...
                    '%s("%s", %d, "%s", "true", [%dx%dx%d])', ...
                    cn, ...
                    mrs.wt, ...
                    mrs.J, ...
                    mrs.fs, ...
                    size(mrs.M, 1), ...
                    size(mrs.M, 2), ...
                    size(mrs.M, 3) ...
                    );

            else
                result = sprintf( ...
                    '%s("%s", %d, "%s", "false", [%dx%dx%d])', ...
                    cn, ...
                    mrs.wt, ...
                    mrs.J, ...
                    mrs.fs, ...
                    size(mrs.M, 1), ...
                    size(mrs.M, 2), ...
                    size(mrs.M, 3) ...
                    );

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'mask':
%
% Use:
%       -- m = mrs.mask()
%
% Description:
%          Calculate binary mask from the given multiresolution support.
%
% -----------------------------------------------------------------------------
        function m = mask(mrs)
            m = ones(size(mrs.M, 1), size(mrs.M, 2));
            idx = 1;
            while(size(mrs.M, 3) >= idx)
                m = m & mrs.M(:, :, idx);

                ++idx;

            endwhile;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'show':
%
% Use:
%       -- show()
%
% Description:
%          Calculate nd display image representation from the given
%          multiresolution support.
%
% -----------------------------------------------------------------------------
        function show(mrs)
            ir = zeros(size(mrs.M, 1), size(mrs.M, 2));
            idx = 1;
            while(size(mrs.M, 3) >= idx)
                ir = ir + power(2, idx)*mrs.M(:, :, idx);

                ++idx;

            endwhile;

            imshow(mat2gray(ir), []);

        endfunction;

    endmethods;

endclassdef;
