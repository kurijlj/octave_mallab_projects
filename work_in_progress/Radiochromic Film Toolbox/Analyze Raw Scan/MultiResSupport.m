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
%       DilateType: "cross"|{"none"}|"plus"|"square"
%           Defines the binary matrix to be used for morphological dilation.
%           Currently, three arrangements are supported: "cross", "plus" and
%           "square", where "cross" is the following matrix:
%
%               | 1 0 1 |
%               | 0 1 0 |
%               | 1 0 1 |
%
%           "plus" is:
%
%               | 0 1 0 |
%               | 1 1 1 |
%               | 0 1 0 |
%
%           and the "square" is:
%
%               | 1 1 1 |
%               | 1 1 1 |
%               | 1 1 1 |
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
        % Multiresolution support arrays of dimensions Ix*Iy*J
        H = []; V = []; D = [];

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
%       -- mrs = MultiResSupport(A, H, D)
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

                if(3 ~= numel(pos))
                    % Invalid call to constructor
                    error( ...
                        'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
                        fname, ...
                        use_case_a, ...
                        use_case_b, ...
                        use_case_c ...
                        );

                endif;

                % Validate the coeficients matrixes
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
                    'H' ...
                    );
                validateattributes( ...
                    pos{2}, ...
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
                    pos{3}, ...
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

                % Allocate temporary variables
                H = pos{1};
                V = pos{2};
                D = pos{3};

                % Validate equivalency of the coeficient matrixes
                if(size(H) ~= size(V))
                    error('%s: Size mismatch (size(H) ~= size(V)).', fname);

                elseif(size(H) ~= size(D))
                    error('%s: Size mismatch (size(H) ~= size(D)).', fname);

                endif;

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
                        'square', ...
                        'none' ...
                        }, ...
                    fname, ...
                    'DilateType' ...
                    );

                % Ignore DilateType property if 'Dilate' property is not set
                % (i.e. dilate = false)
                if(dilate && isequal('none', dilate_type))
                    dilate_type = 'plus';

                elseif(~dilate && ~isequal('none', dilate_type))
                    dilate_type = 'none';

                endif;

                % Assign values to a new instance -----------------------------
                mrs.dilate = dilate;

                % Calculate the multiresolution support -----------------------

                % Load required modules
                pkg load ltfat;

                % Allocate space for the multiresolution support
                mrs.H = zeros(size(H));
                mrs.V = zeros(size(V));
                mrs.D = zeros(size(D));

                idx = 1;
                while(size(D, 3) >= idx)
                    % We use MAD for the estimation of the noise sdev
                    sh = median(abs(H(:, :, idx))(:))/0.6745;
                    sv = median(abs(V(:, :, idx))(:))/0.6745;
                    sd = median(abs(D(:, :, idx))(:))/0.6745;

                    % We use unified threshold method
                    mrs.H(:, :, idx) = ...
                        H(:, :, idx) ...
                        >= sh*sqrt(2*log(numel(H(:, :, idx))));
                    mrs.V(:, :, idx) = ...
                        V(:, :, idx) ...
                        >= sv*sqrt(2*log(numel(V(:, :, idx))));
                    mrs.D(:, :, idx) = ...
                        D(:, :, idx) ...
                        >= sd*sqrt(2*log(numel(D(:, :, idx))));

                    % Dilate multiresolution support if switched on
                    if(dilate)
                        if(isequal('plus', dilate_type))
                            mrs.H(:, :, idx) = imdilate( ...
                                mrs.H(:, :, idx), ...
                                [0, 1, 0; 1, 1, 1; 0, 1, 0;] ...
                                );
                            mrs.V(:, :, idx) = imdilate( ...
                                mrs.V(:, :, idx), ...
                                [0, 1, 0; 1, 1, 1; 0, 1, 0;] ...
                                );
                            mrs.D(:, :, idx) = imdilate( ...
                                mrs.D(:, :, idx), ...
                                [0, 1, 0; 1, 1, 1; 0, 1, 0;] ...
                                );

                        elseif(isequal('cross', dilate_type))
                            mrs.H(:, :, idx) = imdilate( ...
                                mrs.H(:, :, idx), ...
                                [1, 0, 1; 0, 1, 0; 1, 0, 1;] ...
                                );
                            mrs.H(:, :, idx) = imdilate( ...
                                mrs.H(:, :, idx), ...
                                [1, 0, 1; 0, 1, 0; 1, 0, 1;] ...
                                );
                            mrs.D(:, :, idx) = imdilate( ...
                                mrs.D(:, :, idx), ...
                                [1, 0, 1; 0, 1, 0; 1, 0, 1;] ...
                                );

                        else
                            mrs.H(:, :, idx) = imdilate( ...
                                mrs.H(:, :, idx), ...
                                [1, 1, 1; 1, 1, 1; 1, 1, 1;] ...
                                );
                            mrs.V(:, :, idx) = imdilate( ...
                                mrs.V(:, :, idx), ...
                                [1, 1, 1; 1, 1, 1; 1, 1, 1;] ...
                                );
                            mrs.D(:, :, idx) = imdilate( ...
                                mrs.D(:, :, idx), ...
                                [1, 1, 1; 1, 1, 1; 1, 1, 1;] ...
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
                '\t\tA/H/D:      [%dx%dx%d]\n', ...
                size(mrs.D, 1), ...
                size(mrs.D, 2), ...
                size(mrs.D, 3) ...
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
                    size(mrs.D, 1), ...
                    size(mrs.D, 2), ...
                    size(mrs.D, 3), ...
                    mrs.dilate_type ...
                    );

            else
                result = sprintf( ...
                    '%s([%dx%dx%d], "false")', ...
                    cn, ...
                    size(mrs.D, 1), ...
                    size(mrs.D, 2), ...
                    size(mrs.D, 3) ...
                    );

            endif;

        endfunction;

        function [mH, mV, mD] = apply_mask(mrs, H, V, D)
% -----------------------------------------------------------------------------
%
% Method 'apply_mask':
%
% Use:
%       -- [mH, mV, mD] = apply_mask(mrs, H, V, D)
%
% Description:
%          Calculate binary mask from the given multiresolution support.
%
% -----------------------------------------------------------------------------
            fname = 'mrs.apply_mask';

            % Validate the coeficients matrixes
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

            % Validate equivalency of the coeficient matrixes
            if(size(mrs.H) ~= size(H))
                error('%s: Input coeficients size does not match size of the Multiresolution support.', fname);

            elseif(size(H) ~= size(V))
                error('%s: Size mismatch (size(H) ~= size(V)).', fname);

            elseif(size(H) ~= size(D))
                error('%s: Size mismatch (size(H) ~= size(D)).', fname);

            endif;

            mH = zeros(size(H));
            mV = zeros(size(V));
            mD = zeros(size(D));

            idx = 1;
            while(size(H, 3) >= idx)
                mH(:, :, idx) = H(:, :, idx) .* mrs.H(:, :, idx);
                mV(:, :, idx) = V(:, :, idx) .* mrs.V(:, :, idx);
                mD(:, :, idx) = D(:, :, idx) .* mrs.D(:, :, idx);

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
            hr = zeros(size(mrs.H, 1), size(mrs.H, 2));
            vr = zeros(size(mrs.V, 1), size(mrs.V, 2));
            dr = zeros(size(mrs.D, 1), size(mrs.D, 2));
            idx = 1;
            while(size(mrs.H, 3) >= idx)
                hr = hr + power(2, idx)*mrs.H(:, :, idx);
                vr = vr + power(2, idx)*mrs.V(:, :, idx);
                dr = dr + power(2, idx)*mrs.D(:, :, idx);

                ++idx;

            endwhile;

            subplot(1, 3, 1);
            imshow(mat2gray(hr), []);
            subplot(1, 3, 2);
            imshow(mat2gray(vr), []);
            subplot(1, 3, 3);
            imshow(mat2gray(dr), []);

        endfunction;

    endmethods;

endclassdef;
