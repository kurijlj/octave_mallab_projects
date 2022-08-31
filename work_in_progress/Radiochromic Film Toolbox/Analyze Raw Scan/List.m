% -----------------------------------------------------------------------------
%
% Class 'List':
%
% Description:
%       Data container that contains an unsorted set of unique objects of type
%       FilmDigitizer and FilmPiece. Two lists are equivalent if they have same
%       number of equivalent objects. Two lists are equal if they are equivalent
%       and their equivalent objects are equal too.
%
% -----------------------------------------------------------------------------
classdef List

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (SetAccess = private, GetAccess = public)
        items = {};
        type = NaN;

    endproperties;

% -----------------------------------------------------------------------------
%
% Public methods section
%
% -----------------------------------------------------------------------------
    methods (Access = public)

% -----------------------------------------------------------------------------
%
% Method 'List':
%
% Use:
%       -- list = List()
%       -- list = List(item1, item2, ...)
%       -- list = List("DB_FILE_PATH", type)
%       -- list = List(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function list = List(varargin)
            fname = 'List';
            use_case_a = ' -- list = List()';
            use_case_b = ' -- list = List(item1, item2, ...)';
            use_case_c = ' -- list = List("DB_FILE_PATH", type)';
            use_case_d = ' -- list = List(other)';

            if(0 == nargin)
                % Default constructor invoked

            elseif(1 == nargin)
                if(isa(varargin{1}, 'List'))
                    % Copy constructor invoked
                    list.items = varargin{1}.items;
                    list.type = varargin{1}.type;

                elseif( ...
                        isa(varargin{1}, 'FilmDigitizer') ...
                        || isa(varargin{1}, 'FilmPiece') ...
                        )
                    % Only one object passed for the constructor
                    list.type = class(varargin{1});
                    list.items = {varargin{1}};

                else
                    error( ...
                        'Invalid call to %s. Correct usage is:\n%s\n%s\n%s\n%s', ...
                        fname, ...
                        use_case_a, ...
                        use_case_b, ...
                        use_case_c, ...
                        use_case_d ...
                        );

                endif;

            elseif(2 == nargin)
                if(ischar(varargin{1}) && ~isempty(varargin{1}) ...
                        && ischar(varargin{2}) && ~isempty(varargin{2}) ...
                        )
                    % Load item list from a database file

                    % Check if given file path poins to actual file
                    if(~isfile(varargin{1}))
                        % Database does not exist, print error message and return empty list
                        warning( ...
                            '%s: file "%s" does not exist\nCalling default constructor\n', ...
                            fname, ...
                            file_path ...
                            );

                        return;

                    endif;

                    % Check if valid object type passed
                    validatestring( ...
                        varargin{2}, ...
                        {'FilmDigitizer', 'FilmPiece'}, ...
                        fname, ...
                        'type' ...
                        );

                    % Load required packages
                    pkg load io;  % Required by 'csv2cell'

                    % Load database entries as cell array
                    entries = csv2cell(varargin{1});

                    % Unload loaded packages
                    pkg unload io;

                    % Populate the list
                    list.type = varargin{2};
                    idx = 2;  % We skip column headers
                    while(size(entries, 1) >= idx)
                        item = NaN;
                        if(isequal('FilmDigitizer', list.type))
                            item = FilmDigitizer( ...
                                'Title', entries{idx, 1}, ...
                                'Manufacturer', entries{idx, 2}, ...
                                'Model', entries{idx, 3}, ...
                                'SerialNumber', entries{idx, 4}, ...
                                'OpticalResolution', entries{idx, 5}, ...
                                'OpticalDensity', entries{idx, 6}, ...
                                'LightSource', entries{idx, 7}, ...
                                'ScanningMode', entries{idx, 8}, ...
                                'ScanningResolution', entries{idx, 9}, ...
                                'FilmFixation', entries{idx, 10} ...
                                );

                        else
                            item = FilmPiece( ...
                                'Title', entries{idx, 1}, ...
                                'Manufacturer', entries{idx, 2}, ...
                                'Model', entries{idx, 3}, ...
                                'LOT', entries{idx, 4}, ...
                                'CustomCut', entries{idx, 5} ...
                                );

                        endif;

                        list = list.add(item);

                        idx = idx + 1;

                    endwhile;

                elseif( ...
                        (isa(varargin{1}, 'FilmDigitizer') ...
                        && isa(varargin{2}, 'FilmDigitizer')) ...
                        || (isa(varargin{1}, 'FilmPiece') ...
                        && isa(varargin{2}, 'FilmPiece')) ...
                        )
                    % Only two object passed for the constructor
                    list.type = class(varargin{1});
                    list = list.add(varargin{1});
                    list = list.add(varargin{2});

                else
                    error( ...
                        'Invalid call to %s. Correct usage is:\n%s\n%s\n%s\n%s', ...
                        fname, ...
                        use_case_a, ...
                        use_case_b, ...
                        use_case_c, ...
                        use_case_d ...
                        );

                endif;

            elseif(2 < nargin)
                % Regular constructor invoked

                % Set type to a type of the first argument
                list.type = class(varargin{1});

                idx = 1;
                while(nargin >= idx)
                    if( ...
                            ~isa(varargin{idx}, 'FilmDigitizer') ...
                            && ~isa(varargin{idx}, 'FilmPiece') ...
                            )
                        error( ...
                            '%s: object{%d} must be an instance of the "FilmDigitizer" or the "FilmPiece" class', ...
                            fname, ...
                            idx ...
                            );

                    elseif(isa(varargin{idx}, list.type))
                        list = list.add(varargin{idx});

                    else
                        error( ...
                            '%s: List container does not support mixing of object types: list.type = "%s", varargin{%d}.type = "%s"', ...
                            fname, ...
                            list.type, ...
                            idx, ...
                            class(varargin{idx}) ...
                            );

                    endif;

                    idx = idx + 1;

                endwhile;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- list.disp()
%
% Description:
%          The disp method is used by Octave whenever a class should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(list)
            if(list.isempty())
                printf('\tItemList( ...\n\t\t{}(0x0), ...\n\t)\n');

            else
                printf('\tList( ...\n');
                idx = 1;
                while(list.numel() >= idx)
                    printf('\t\t');
                    list.items{idx}.disp_short();
                    if(list.numel() == idx)
                        printf(' ...\n');

                    else
                        printf(', ...\n');

                    endif;

                    idx = idx + 1;

                endwhile;
                printf('\t)\n');

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'ismember':
%
% Use:
%       -- result = list.ismember(obj)
%
% Description:
%          Return 'true' if obj with title obj.title is member of the list.
%          Otherwise return 'false'.
%
% -----------------------------------------------------------------------------
        function result = ismember(list, obj)
            fname = 'ismember';

            result = false;
            if(list.isempty())
                return;

            endif;

            if(~isa(obj, list.type))
                error( ...
                    '%s: obj must be an instance of the "%s"', ...
                    fname, ...
                    list.type ...
                    );

            endif;

            [result, idx] = ismember(obj.title, list.titles());

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'index':
%
% Use:
%       -- idx = list.index(obj)
%
% Description:
%          Search for obj with name obj.title in the list. If obj exists in
%          the list return obj index, otherwise return 0.
%
% -----------------------------------------------------------------------------
        function idx = index(list, obj)
            fname = 'index';

            idx = 0;
            if(list.isempty())
                return;

            endif;

            if(~isa(obj, list.type))
                error( ...
                    '%s: obj must be an instance of the "%s"', ...
                    fname, ...
                    list.type ...
                    );

            endif;

            [tf, idx] = ismember(obj.title, list.titles());

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'titles':
%
% Use:
%       -- tl = list.titles()
%
% Description:
%          Return list of title values of all the objects in the list.
%
% -----------------------------------------------------------------------------
        function tl = titles(list)
            tl = {};
            if(list.isempty())
                return;

            endif;

            idx = 1;
            while(numel(list.items) >= idx)
                tl = {tl{:}, list.items{idx}.title};

                idx = idx + 1;

            endwhile;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'cellarray':
%
% Use:
%       -- cell_list = list.cellarry()
%
% Description:
%          Return list as cell array.
%
% -----------------------------------------------------------------------------
        function cell_list = cellarray(list)
            cell_list = {};

            if(list.isempty())
                return;

            else
                cell_list = cell( ...
                    numel(list.items), ...
                    numel(list.at(1).cellarray()) ...
                    );
                cell_list(1, :) = list.at(1).cellarray();

                idx = 2;

                while(numel(list) >= idx)
                    cell_list(idx, :) = list.at(idx).cellarray();

                    idx = idx + 1;

                endwhile;

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'add':
%
% Use:
%       -- list = list.add(obj)
%
% Description:
%          Append obj to the end of the list. If there is already obj in the
%          list that is equivalent to the given obj it updates fields of the
%          obj ont the list using field values of the given obj.
%
% -----------------------------------------------------------------------------
        function list = add(list, obj)
            fname = 'add';

            if(list.isempty())
                if(~isa(obj, 'FilmDigitizer') && ~isa(obj, 'FilmPiece'))
                    error( ...
                        '%s: obj must be an instance of the "FilmDigitizer" or the "FilmPiece" class', ...
                        fname, ...
                        idx ...
                        );

                endif;

                list.type = class(obj);

            endif;

            if(~isa(obj, list.type))
                error( ...
                    '%s: obj must be an instance of the "%s"', ...
                    fname, ...
                    list.type ...
                    );

            endif;

            if(list.ismember(obj))
                list.items{list.index(obj)} = obj;

            else
                list.items = {list.items{:}, obj};

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'remove':
%
% Use:
%       -- list = list.remove(idx)
%
% Description:
%          Remove obj with the given index idx from the list.
%
% -----------------------------------------------------------------------------
        function list = remove(list, idx)
            fname = 'remove';

            validateattributes( ...
                idx, ...
                {'numeric'}, ...
                { ...
                    '>=', 1, ...
                    '<=', list.numel(), ...
                    'integer', ...
                    'nonnan', ...
                    'scalar' ...
                    }, ...
                fname, ...
                'idx' ...
                );

            list.items = { ...
                list.items{1:idx - 1}, ...
                list.items{idx + 1:end} ...
                };

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'numel':
%
% Use:
%       -- n = list.numel()
%
% Description:
%          Return number of objects (elements) in the list.
%
% -----------------------------------------------------------------------------
        function n = numel(list)
            n = numel(list.items);

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isempty':
%
% Use:
%       -- result = list.isempty()
%
% Description:
%          Return whether the list contains any item or not.
%
% -----------------------------------------------------------------------------
        function result = isempty(list)
            result = isempty(list.items);

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'at':
%
% Use:
%       -- obj = list.at(idx)
%
% Description:
%          Return item with index idx from the list.
%
% -----------------------------------------------------------------------------
        function obj = at(list, idx)
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

            if(list.isempty())
                obj = NaN;
                return;

            endif;

            if(1 > idx || list.numel() < idx)
                error( ...
                    '%s: idx out of bounds ([1, %d] <> %d)', ...
                    fname, ...
                    list.numel(), ...
                    idx ...
                    );

            endif;

            obj = list.items{idx};

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = list.isequivalent(other)
%
% Description:
%          Return whether or not two lists are equivalent. Two list are
%          equivalent if they have same number of objects with the identical
%          titles.
%
% -----------------------------------------------------------------------------
        function result = isequivalent(list, other)
            fname = 'isequivalent';

            if(~isa(other, 'List'))
                error( ...
                    '%s: other must be an instance of the "List" class', ...
                    fname ...
                    );

            endif;

            result = isequal(sort(list.titles()), sort(other.titles()));

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = list.isequal(other)
%
% Description:
%          Return whether or not two lists are equal. Two list are equal if
%          they are equivalent and their equivalent objects are equal too.
%
% -----------------------------------------------------------------------------
        function result = isequal(list, other)
            fname = 'isequal';

            if(~isa(other, 'List'))
                error( ...
                    '%s: other must be an instance of the "List" class', ...
                    fname ...
                    );

            endif;

            % Initialize result to a default value
            result = false;

            if(list.isequivalent(other))
                idx = 1;
                while(list.numel() >= idx)
                    if(~list.items{idx}.isequal(other.items{idx}))
                        return;

                    endif;

                    idx = idx + 1;

                endwhile;

                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
