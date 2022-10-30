classdef MultiResSupport
% -----------------------------------------------------------------------------
%
% Class 'MultiResSupport':
%
% Description:
%       Calculates the multi-resolution support of the undecimated wavelet
%       decomposition of the 2D data. It takes a matrix containing diagonal
%       coefficients of the undecimated wavelet transform of the data to
%       calculate the multi-resolution support (see: ufwt2, iufwt2).
%
%       If the class constructor is invoked with another multi-resolution
%       support object, it makes a copy of the given object.
%
%       Multiple property-value pairs may be specified for the multi-resolution
%       support object, but they must appear in pairs.
%
%       Properties of 'Multi-Resolution Support' objects:
%
%       Dilate: bool, def. false
%           Determines whether to perform morphological dilation when
%           calculating significant coefficients for each scale.
%
%       DilateType: "cross"|{"none"}|"plus"
%           Defines the binary matrix to be used for morphological dilation.
%           Currently, two arrangements are supported: "cross" and "plus"
%           where "cross" is the following matrix:
%
%               | 1 0 1 |
%               | 0 1 0 |
%               | 1 0 1 |
%
%           and the "plus" is:
%
%               | 0 1 0 |
%               | 1 1 1 |
%               | 0 1 0 |
%
%           If 'Dilate' is true and 'DilateType' is none, the constructor will
%           automatically set it to the "plus" value. If the 'Dilate' false, the
%           value of the 'DilateType' is ignored.
%
% -----------------------------------------------------------------------------

    properties (SetAccess = private, GetAccess = public)
% -----------------------------------------------------------------------------
%
% Properties section (SetAccess: private, GetAccess: public)
%
% -----------------------------------------------------------------------------

        % Dilate (defines whether or not each scale should be dilated)
        dilate = false;
        % Dilate type (defines the binary matrix to be used for morphological
        % dilation
        dilate_type = 'none';
        % Multiresolution support array of dimensions Ix*Iy*J
        M = [];

    endproperties;

    methods (Access = public)
% -----------------------------------------------------------------------------
%
% Public methods section
%
% -----------------------------------------------------------------------------

        function mrs = MultiResSupport(varargin)
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
                mrs.dilate      = varargin{1}.dilate;
                mrs.dilate_type = varargin{1}.dilate_type;
                mrs.M           = varargin{1}.M;

            else
                % Regular constructor invoked. Parse arguments
                [ ...
                    pos, ...
                    dilate, ...
                    dilate_type ...
                    ] = parseparams( ...
                    varargin, ...
                    'Dilate', false, ...
                    'DilateType', 'none' ...
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

                % Validate the coeficients matrix
                validateattributes( ...
                    pos{1}, ...
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

                % Validate value supplied for the Dilate
                if(~isbool(dilate))
                    error('%s: Dilate must be a boolean value', fname);

                endif;

                % Validate value supplied for the DilateType
                validatestring( ...
                    dilate_type, ...
                    { ...
                        'cross', ...
                        'plus', ...
                        'none' ...
                        }, ...
                    fname, ...
                    'DilateType' ...
                    );

                % Ignore DilateType property if 'Dilate' property is not set
                % (i.e. dilate = false)
                if(dilate && iequal('none', dilate_type))
                    dilate_type = 'plus';

                elseif(~dilate && ~isequal('none', dilate_type))
                    dilate_type = 'none';

                endif;

                % Assign values to a new instance -----------------------------
                mrs.dilate = dilate;

                % Calculate the multiresolution support -----------------------

                % Load required modules
                pkg load ltfat;

                % Allocate temporary variables
                D = pos{1};

                % Allocate space for the multiresolution support
                mrs.M = zeros(size(D));

                idx = 1;
                while(size(D, 3) >= idx)
                    % We use MAD for the estimation of the noise sdev
                    s = median(abs(D(:, :, idx))(:))/0.6745;
                    % We use unified threshold method
                    mrs.M(:, :, idx) = ...
                        D(:, :, idx) ...
                        >= s*sqrt(2*log(numel(D(:, :, idx))));

                    % Dilate multiresolution support if switched on
                    if(dilate)
                        if(isequal('plus', dilate_type))
                            mrs.M(:, :, idx) = imdilate( ...
                                mrs.M(:, :, idx), ...
                                [0, 1, 0; 1, 1, 1; 0, 1, 0;] ...
                                );

                        else
                            mrs.M(:, :, idx) = imdilate( ...
                                mrs.M(:, :, idx), ...
                                [1, 0, 1; 0, 1, 0; 1, 0, 1;] ...
                                );

                        endif;

                    endif;

                    ++idx;

                endwhile;

            endif;

        endfunction;

        function disp(mrs)
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
            printf('\tMultiResSupport(\n');
            printf( ...
                '\t\tM:          [%dx%dx%d]\n', ...
                size(mrs.M, 1), ...
                size(mrs.M, 2), ...
                size(mrs.M, 3) ...
                );
            if(mrs.dilate)
                printf('\t\tDilate:     true\n');
                printf('\t\tDilateType: %s\n', mrs.dilate_type);

            else
                printf('\t\tDilate:     false\n');
                printf('\t\tDilateType: none\n');

            endif;
            printf('\t)\n');

        endfunction;

        function result = str_rep(mrs)
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
            cn = 'MultiResSupport';
            if(mrs.dilate)
                result = sprintf( ...
                    '%s([%dx%dx%d], "true", "%s")', ...
                    cn, ...
                    size(mrs.M, 1), ...
                    size(mrs.M, 2), ...
                    size(mrs.M, 3), ...
                    mrs.dilate_type ...
                    );

            else
                result = sprintf( ...
                    '%s([%dx%dx%d], "false")', ...
                    cn, ...
                    size(mrs.M, 1), ...
                    size(mrs.M, 2), ...
                    size(mrs.M, 3) ...
                    );

            endif;

        endfunction;

        function m = mask(mrs)
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
            m = ones(size(mrs.M, 1), size(mrs.M, 2));
            idx = 1;
            while(size(mrs.M, 3) >= idx)
                m = m & mrs.M(:, :, idx);

                ++idx;

            endwhile;

        endfunction;

        function show(mrs)
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
