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

        function m = Measurement(varargin)
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

                else
                    % Invalid call to constructor
                    error( ...
                        sprintf( ...
                            cstrcat( ...
                                'Invalid call to %s. Correct usage ', ...
                                'is:\n%s\n%s\n%s\n%s' ...
                                ), ...
                            fname, ...
                            use_case_a, ...
                            use_case_b, ...
                            use_case_c, ...
                            use_case_d ...
                            ) ...
                        );

                endif;  % isa(varargin{1}, 'Measurement')

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

                % Validate value supplied for the Title
                if(~ischar(title) || isempty(title))
                    error('%s: Title must be a non-empty string', fname);

                endif;

                % Intialize cell array to store data samples
                dss = {};

                % Validate values supplied as positional arguments
                idx = 1;
                while(numel(pos) >= idx)
                    if(~isa(pos{idx}, 'DataSample'))
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
                    endif;  % ~isa(pos{idx}, 'DataSample')

                    % Check if DataSample instance is equivalent with previous
                    % data samples
                    if(1 < numel(pos))
                        if(~pos{1}.isequivalent(pos{idx}))
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

                    endif;  % 0 < numel(m.dss)

                    dss{end+1} = pos{idx};

                    ++idx;

                endwhile;  % numel(pos) >= idx

                m.title = title;
                m.dss   = dss;

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
                while(m.numel() >= idx)
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
                };

            if(1 == m.at(1).numch())
                titles{end + 1} = 'Mean pixel value';
                titles{end + 1} = 'StDev';

            else
                titles{end + 1} = 'Mean pixel value (R)';
                titles{end + 1} = 'Mean pixel value (G)';
                titles{end + 1} = 'Mean pixel value (B)';
                titles{end + 1} = 'StDev (R)';
                titles{end + 1} = 'StDev (G)';
                titles{end + 1} = 'StDev (B)';

            endif;

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
                    if(1 == idx)
                        mmat = m.at(1).asrow();

                    else
                        mmat(end + 1, :) = m.at(idx).asrow();

                    endif;  % 1 == idx

                    ++idx;

                endwhile;

            endif;  % ~m.isempty()

        endfunction;


        function msr = append(m, ds)
%  ----------------------------------------------------------------------------
%
%  Method 'append':
%
%  Use:
%       -- msr = m.append(ds)
%
%  Description:
%          Return a copy of given "Measurement" instance, and append the given
%          data sample instance "ds" to teh end.
%
%  ----------------------------------------------------------------------------
            fname = 'append';

            if(~isa(ds, 'DataSample'))
                error( ...
                    '%s: ds must be an instance of the "DataSample" class', ...
                    fname ...
                    );

            endif;

            if(m.isempty())
                msr = Measurement(ds, 'Title', m.title);

            else
                msr = Measurement(m.dss{:}, ds, 'Title', m.title);

            endif;  % m.isempty()

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
%          measurements are equivalent if their data samples have same number of
%          channels i.e. ds1i.numch() == ds2i.numch(). Two measurement instances
%          that are empty are considered equivalent.
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

            if(other.isempty() && m.isempty())
                result = true;

            elseif(~other.isempty() && ~m.isempty())
                if(other.at(1).numch() == m.at(1).numch())
                    result = true;

                endif;  % other.at(1).numch() == m.at(1).numch()

            endif;  % End of equivalency tests

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

            result = true;
            if(other.numel() == m.numel())
                idx = 1;
                while(m.numel() >= idx)
                    if(other.at(idx) != m.at(idx))
                        result = false;
                        break;

                    endif;

                    ++idx;

                endwhile;

            else
                % other.numel() != m.numel()
                result = false;

            endif;  % other.numel() == m.numel()

        endfunction;


        function result = eq(m, other)
%  ----------------------------------------------------------------------------
%
%  Method 'eq':
%
%  Use:
%       -- result = m.eq(other)
%
%  Description:
%          Overload equality operator (==) for the Measurement class. It wraps
%          'isequal' method.
%
%  ----------------------------------------------------------------------------
            fname = 'eq';

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

            result = m.isequal(other);

        endfunction;  % eq()


        function result = ne(m, other)
%  ----------------------------------------------------------------------------
%
%  Method 'ne':
%
%  Use:
%       -- result = m.ne(other)
%
%  Description:
%          Overload non equality operator (!=) for the Measurement class. It
%          wraps 'isequal' method.
%
%  ----------------------------------------------------------------------------
            fname = 'ne';

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

            result = ~m.isequal(other);

        endfunction;  % eq()

    endmethods;

endclassdef;  % Measurement
