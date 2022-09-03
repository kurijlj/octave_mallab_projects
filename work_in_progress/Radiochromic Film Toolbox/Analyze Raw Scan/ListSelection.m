% -----------------------------------------------------------------------------
%
% Class 'ListSelection':
%
% Description:
%       TODO: Put class description here
%       Represents an object selected from the list of objects. Two selections
%       are equivalent if their lists are equal. Two selections are equal
%       if both their lists and selection indexes are equal.
%
% -----------------------------------------------------------------------------
classdef ListSelection

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (SetAccess = private, GetAccess = public)
        list = List();
        idx = 0;

    endproperties;

% -----------------------------------------------------------------------------
%
% Public methods section
%
% -----------------------------------------------------------------------------
    methods (Access = public)

% -----------------------------------------------------------------------------
%
% Method 'ListSelection':
%
% Use:
%       -- selec = ListSelection()
%       -- selec = ListSelection(list)
%       -- selec = ListSelection(list, idx)
%       -- selec = ListSelection(other)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function selec = ListSelection(varargin)
            fname = 'ListSelection';
            use_case_a = ' -- selec = ListSelection()';
            use_case_b = ' -- selec = ListSelection(list)';
            use_case_c = ' -- selec = ListSelection(list, idx)';
            use_case_d = ' -- selec = ListSelection(other)';

            if(0 == nargin)
                % Default constructor invoked

            elseif(1 == nargin)
                % Two scenarios can occur: 1) user passed just an item_list,
                % takin default selectin (idx=0); 2) user passed another
                % selection to make copy of
                if(isa(varargin{1}, 'List'))
                    % Constructor with deafult selection invoked
                    selec.list = varargin{1};

                elseif(isa(varargin{1}, 'ListSelection'))
                    % Copy constructor invoked
                    selec.list = varargin{1}.list;
                    selec.idx = varargin{1}.idx;

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
                % Regular constructor invoked
                if(~isa(varargin{1}, 'List'))
                    error( ...
                        '%s: list must be an instance of the "List" class', ...
                        fname ...
                        );

                endif;

                validateattributes( ...
                    varargin{2}, ...
                    {'numeric'}, ...
                    { ...
                        'integer', ...
                        'nonnan', ...
                        'scalar' ...
                        }, ...
                    fname, ...
                    'idx' ...
                    );

                if(1 > varargin{2} || varargin{1}.numel() < varargin{2})
                    error( ...
                        '%s: idx out of bounds ([1, %d] <> %d)', ...
                        fname, ...
                        varargin{1}.numel(), ...
                        varargin{2} ...
                        );

                endif;

                selec.list = varargin{1};
                selec.idx = varargin{2};

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

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'disp':
%
% Use:
%       -- selec.disp()
%
% Description:
%          The disp method is used by Octave whenever a class should be
%          displayed on the screen.
%
% -----------------------------------------------------------------------------
        function disp(selec)
            if(selec.isempty())
                printf('\tItemListSelection( ...\n\t\t{}(0x0), ...\n\t)\n');

            else
                printf('\tItemListSelection( ...\n');
                idx = 1;
                while(selec.list.numel() >= idx)
                    if(idx == selec.idx)
                        printf('\t%6s[ ', ' ');
                        selec.list.at(idx).disp_short();
                        printf(' ], ...\n');

                    else
                        printf('\t\t');
                        selec.list.at(idx).disp_short();
                        printf(', ...\n');

                    endif;

                    ++idx;

                endwhile;
                printf('\t)\n');

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'numel':
%
% Use:
%       -- n = selec.numel()
%
% Description:
%          Return number of objects (elements) in the selection list.
%
% -----------------------------------------------------------------------------
        function n = numel(selec)
            n = selec.list.numel();

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isempty':
%
% Use:
%       -- result = selec.isempty()
%
% Description:
%          Return whether the selection is empty or not. Selection is empty if
%          the selection list is an empty list.
%
% -----------------------------------------------------------------------------
        function result = isempty(selec)
            result = selec.list.isempty();

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'select_index':
%
% Use:
%       -- selec = selec.select_index(idx)
%
% Description:
%          Changes selection to the object with index idx if object with such
%          index exists in the list. Otherwise it returns an error.
%
% -----------------------------------------------------------------------------
        function selec = select_index(selec, idx)
            fname = 'select_index';

            validateattributes( ...
                idx, ...
                {'numeric'}, ...
                { ...
                    'integer', ...
                    'nonnan', ...
                    'scalar' ...
                    }, ...
                fname, ...
                'varargin{2}' ...
                );

            if(0 > idx || selec.numel() < idx)
                error( ...
                    '%s: idx out of bounds ([0, %d] <> %d)', ...
                    fname, ...
                    selec.numel(), ...
                    idx ...
                    );

            endif;

            selec.idx = idx;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'select_obj':
%
% Use:
%       -- selec = selec.select_obj(obj)
%
% Description:
%          If given object is member of the selection list, set selection index
%          to value of the index of a given object in the selection list.
%          Otherwise it returns an error.
%
% -----------------------------------------------------------------------------
        function selec = select_obj(selec, obj)
            fname = 'select_item';

            if(~isa(obj, selec.list.type))
                error( ...
                    '%s: obj must be an instance of the "%s" class', ...
                    fname, ...
                    selec.list.type
                    );

            endif;

            if(selec.list.ismember(obj))
                selec.idx = selec.list.index(obj);

            else
                error( ...
                    '%s: obj is not a member of the selection list', ...
                    fname ...
                    );

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'selected_obj':
%
% Use:
%       -- obj = selec.selected_obj()
%
% Description:
%          Return object from the list pointed by the selection index. If no
%          object is selected method returns NaN.
%
% -----------------------------------------------------------------------------
        function obj = selected_obj(selec)
            if(0 == selec.idx)
                obj = NaN;

            else
                obj = selec.list.at(selec.idx);

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = selec.isequivalent(other)
%
% Description:
%          Return whether or not two list selections are equivalent. Two
%          list selections are equivalent if their lists are equal.
%
% -----------------------------------------------------------------------------
        function result = isequivalent(selec, other)
            fname = 'isequivalent';

            if(~isa(other, 'ListSelection'))
                error( ...
                    '%s: other must be an instance of the "ListSelection" class', ...
                    fname ...
                    );

            endif;

            result = selec.list.isequal(other.list);

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = list.isequal(other)
%
% Description:
%          Return whether or not two list selections are equal. Two list
%          selections are equal if both their lists and selection indexes are
%          equal.
%
% -----------------------------------------------------------------------------
        function result = isequal(selec, other)
            fname = 'isequal';

            if(~isa(other, 'ListSelection'))
                error( ...
                    '%s: other must be an instance of the "ListSelection" class', ...
                    fname ...
                    );

            endif;

            result = false;
            if(selec.list.isequal(other.list) && isequal(selec.idx, other.idx))
                result = true;

            endif;

        endfunction;

    endmethods;

endclassdef;
