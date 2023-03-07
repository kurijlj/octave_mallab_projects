classdef Measurement
%% ----------------------------------------------------------------------------
%%
%% Class 'Measurement':
%%
%% ----------------------------------------------------------------------------
%
%% Description:
%       Represents an ordered set of measured data points (i.e. 'DataSamples').
%       Two measurements are equivalent if the windows of their data sample are
%       equivalent. Two measurements are equal it they have the same number of
%       data samples, and corresponding data samples are equal.
%
%       'Measurement' class instances have following properties:
%
%       title: string, def. "Measurement dd-mmm-yyyy"
%           A string containing a title describing measured data points.
%
%       dss: cell array of 'DataSample' instances, def. {}
%           Cell array containing all measured data points.
%
%  ----------------------------------------------------------------------------

    properties (SetAccess = private, GetAccess = public)
%% ----------------------------------------------------------------------------
%%
%% Public properties section
%%
%% ----------------------------------------------------------------------------
        title = '';
        dss   = {};

    endproperties;


%% ----------------------------------------------------------------------------
%%
%% Public methods section
%%
%% ----------------------------------------------------------------------------
    methods (Access = public)

        function list = Measurement(varargin)
%  ----------------------------------------------------------------------------
%
%  Method 'Measurement':
%
%  Use:
%       -- m = Measurement()
%       -- m = Measurement(ds1, ds2, ...)
%       -- m = Measurement(..., "PROPERTY", VALUE, ...)
%       -- m = Measurement(other)
%
%  Description:
%          Class constructor.
%
%          Class constructor supports following property-value pairs:
%
%          title:
%              String representing measurement title. Deafult value is
%              'Measurement dd-mmm-yyyy' (i.e. 'Measurement 05-Mar-2023').
%
%  ----------------------------------------------------------------------------
            fname = 'Measurement';
            use_case_a = sprintf(' -- m = %s()', fname);
            use_case_b = sprintf(' -- m = %s(ds1, ds2, ...)', fname);
            use_case_c = sprintf( ...
                ' -- m = %s(..., "PROPERTY", VALUE, ...)', ...
                fname ...
                );
            use_case_d = sprintf(' -- m = %s(other)', fname);

            if(0 == nargin)
                % Default constructor invoked
                m.title = datestr(datenum(date()));

            elseif(1 == nargin)
                if(isa(varargin{1}, 'Measurement'))
                    % Copy constructor invoked
                    m.title = varargin{1}.title;
                    m.dss   = varargin{1}.dss;

                elseif(isa(varargin{1}, 'DataSample'))
                    % Construct measurement out of one data sample
                    m.dss = {varargin{1}};

            elseif(1 < nargin)
                % Regular constructor invoked

                % Parse arguments
                [ ...
                    pos, ...
                    title ...
                    ] = parseparams( ...
                    varargin, ...
                    'Title', datestr(datenum(date())) ...
                    );

                if(0 ~= numel(pos))
                    % Invalid call to constructor
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                'Invalid call to %s. Correct usage ' ...
                                'is:\n%s\n%s\n%s\n%s' ...
                                ), ...
                            fname, ...
                            use_case_a, ...
                            use_case_b, ...
                            use_case_c, ...
                            use_case_d ...
                            ) ...
                        );

                endif;

                % Validate value supplied for the Title
                if(~ischar(title) || isempty(title))
                    error('%s: Title must be a non-empty string', fname);

                endif;

                % Validate values supplied as positional arguments
                idx = 0;
                while(numel(pos) >= idx)
                    if(~isa(pos(idx), 'DataSample'))
                        error( ...
                            sprintf( ...
                                cstrcat( ...
                                    '%s: varargin{%d} must be an instance ', ...
                                    'of the "DataSample" class' ...
                                    ), ...
                                fname, ...
                                idx ...
                                ) ...
                            );
                    endif;

                    % Check if DataSample instance is equivalent with previous
                    % data samples
                    if(0 < numel(m.dss))
                        if(~m.dss{1}.isequivalent(pos(idx)))
                            error( ...
                                sprintf( ...
                                    cstrcat( ...
                                        '%s: varargin{%d} not equivalent ', ...
                                        'with previous data samples' ...
                                        ), ...
                                    fname, ...
                                    idx ...
                                    ) ...
                                );

                        endif;

                    endif;

                    ++idx;

                endwhile;

            endif;  % 0 == nargin

        endfunction;  % Measurement()


        function disp(m)
%  ----------------------------------------------------------------------------
%
%  Method 'disp':
%
%  Use:
%       -- m.disp()
%
%  Description:
%          The disp method is used by Octave whenever a instance of the class
%          should be displayed on the screen.
%
%  ----------------------------------------------------------------------------
            if(m.isempty())
                printf( ...
                    cstrcat( ...
                        '\tMeasurement( ...\n\t\t"%s", ...\n\t\t[](0x0),', ...
                        ' ...\n\t)\n' ...
                        ), ...
                    m.title ...
                    );

            else
                printf('\tMeasurement( ...\n');
                printf('\t\t%s, ...\n', m.title);
                printf('\t\t[ ...\n');
                idx = 1;
                while(list.numel() >= idx)
                    printf('\t\t');
                    disp(m.dss{idx}.asrow());
                    printf(' ...\n');

                    ++idx;

                endwhile;
                printf('\t\t] ...\n');
                printf('\t)\n');

            endif;

        endfunction;


        function titles = columnTitles(m)
%  ----------------------------------------------------------------------------
%
%  Method 'columnTitles':
%
%  Use:
%       -- titles = m.columnTitles()
%
%  Description:
%          Return list of column titles.
%
%  ----------------------------------------------------------------------------
            titles = { ...
                'row [pixels]', ...
                'column [pixels]', ...
                'L [pixels]', ...
                'W [pixels]', ...
                'Number of samples', ...
                'Mean pixel value', ...
                'StDev' ...
                };

        endfunction;


        function mcell = ascell(m)
%  ----------------------------------------------------------------------------
%
%  Method 'ascell':
%
%  Use:
%       -- mcell = m.ascell()
%
%  Description:
%          Return list as cell array. This function is required if the class is
%          used as model for the table view.
%
%  ----------------------------------------------------------------------------
            mcell = {};

            if(m.isempty())
                mcell = DataSample().ascell();

            else
                mcell = cell();
                idx = 1;
                while(m.numel() >= idx)
                    mcell{end + 1} = m.at(idx).ascell();

                    ++idx;

                endwhile;

            endif;

        endfunction;


        function mmat = asmatrix(m)
%  ----------------------------------------------------------------------------
%
%  Method 'asmatrix':
%
%  Use:
%       -- mmat = m.asmatrix()
%
%  Description:
%          Return measurement data as matrix.
%
%  ----------------------------------------------------------------------------
            mmat = [];

            if(~m.isempty())
                idx = 1;
                while(m.numel() >= idx)
                    mmat(end + 1) = m.at(idx).asrow();

                    ++idx;

                endwhile;

            endif;

        endfunction;


        function m = append(m, ds)
%  ----------------------------------------------------------------------------
%
%  Method 'append':
%
%  Use:
%       -- m = m.append(ds)
%
%  Description:
%          Append given data sample to the end of the data samples array.
%
%  ----------------------------------------------------------------------------
            fname = 'append';

            if(~isa(ds, 'DataSample'))
                error( ...
                    '%s: ds must be an instance of the "DataSample" class', ...
                    fname ...
                    );

            endif;

            m.dss{end + 1} = ds;

        endfunction;


        function n = numel(m)
%  ----------------------------------------------------------------------------
%
%  Method 'numel':
%
%  Use:
%       -- n = m.numel()
%
%  Description:
%          Return number of data sampples in the measurement.
%
%  ----------------------------------------------------------------------------
            n = numel(m.dss);

        endfunction;


        function result = isempty(m)
%  ----------------------------------------------------------------------------
%
%  Method 'isempty':
%
%  Use:
%       -- result = m.isempty()
%
%  Description:
%          Return whether the measurement contains any data samples or not.
%
%  ----------------------------------------------------------------------------
            result = isempty(m.dss);

        endfunction;


        function ds = at(m, idx)
%  ----------------------------------------------------------------------------
%
%  Method 'at':
%
%  Use:
%       -- ds = m.at(idx)
%
%  Description:
%          Return data sample with index idx from the measurement.
%
%  ----------------------------------------------------------------------------
            fname = 'at';

            validateattributes( ...
                idx, ...
                {'numeric'}, ...
                { ...
                    'integer', ...
                    'nonnan', ...
                    'scalar' ...
                    }, ...
                fname, ...
                'idx' ...
                );

            if(1 > idx || m.numel() < idx)
                error( ...
                    '%s: idx out of bounds ([1, %d] <> %d)', ...
                    fname, ...
                    m.numel(), ...
                    idx ...
                    );

            endif;

            ds = m.dss{idx};

        endfunction;


        function result = isequivalent(m, other)
%  ----------------------------------------------------------------------------
%
%  Method 'isequivalent':
%
%  Use:
%       -- result = m.isequivalent(other)
%
%  Description:
%          Return whether or not two measurements are equivalent. Two
%          measurements are equivalent if they have same number of data samples
%          and data samples are equivalent.
%
%  ----------------------------------------------------------------------------
            fname = 'isequivalent';

            if(~isa(other, 'Measurement'))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: other must be an instance of the ', ...
                            '"Measurement" class' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;

            result = false;
            if(other.numel() == m.numel())
                idx = 1;
                while(m.numel() >= idx)
                    if(~m.at(idx).isequivalent(other.at(idx)))
                        break;

                    endif;

                    ++idx;

                endwhile;

            endif;  % other.numel() == m.numel()

        endfunction;


        function result = isequal(m, other)
%  ----------------------------------------------------------------------------
%
%  Method 'isequal':
%
%  Use:
%       -- result = m.isequal(other)
%
%  Description:
%          Return whether or not two measurements are equal. Two measurements
%          are equal if they have equal datasamples.
%
%  ----------------------------------------------------------------------------
            fname = 'isequal';

            if(~isa(other, 'Measurement'))
                error( ...
                    sprintf( ...
                        cstrcat( ...
                            '%s: other must be an instance of the ', ...
                            '"Measurement" class' ...
                            ), ...
                        fname ...
                        ) ...
                    );

            endif;

            result = false;
            if(other.numel() == m.numel())
                idx = 1;
                while(m.numel() >= idx)
                    if(~m.at(idx).isequval(other.at(idx)))
                        break;

                    endif;

                    ++idx;

                endwhile;

            endif;  % other.numel() == m.numel()

        endfunction;

    endmethods;

endclassdef;  % Measurement
