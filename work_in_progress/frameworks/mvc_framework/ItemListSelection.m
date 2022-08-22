% -----------------------------------------------------------------------------
%
% Class 'ItemListSelection':
%
% Description:
%       TODO: Put class description here
%
% -----------------------------------------------------------------------------
classdef ItemListSelection

% -----------------------------------------------------------------------------
%
% Public properties section
%
% -----------------------------------------------------------------------------
    properties (Access = public)
        list = ItemList();
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
% Method 'ItemListSelection':
%
% Use:
%       -- selec = ItemListSelection()
%       -- selec = ItemListSelection(list)
%       -- selec = ItemListSelection(list, idx)
%       -- selec_copy = ItemListSelection(selec)
%
% Description:
%          Class constructor.
%
% -----------------------------------------------------------------------------
        function selec = ItemListSelection(varargin)
            fname = 'ItemListSelection';
            use_case_a = ' -- selec = ItemListSelection()';
            use_case_b = ' -- selec = ItemListSelection(list)';
            use_case_c = ' -- selec = ItemListSelection(list, idx)';
            use_case_d = ' -- selec_copy = ItemListSelection(selec)';

            if(0 == nargin)
                % Default constructor invoked

            elseif(1 == nargin)
                % Two scenarios can occur: 1) user passed just an item_list,
                % takin default selectin (idx=0); 2) user passed another
                % selection to make copy of
                if(isa(varargin{1}, 'ItemList'))
                    % Constructor with deafult selection invoked
                    selec.list = varargin{1};

                elseif(isa(varargin{1}, 'ItemListSelection'))
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
                if(~isa(varargin{1}, 'ItemList'))
                    error( ...
                        '%s: varargin{1} must be an instance of the "ItemList" class', ...
                        fname ...
                        );

                endif;

                validateattributes( ...
                    varargin{2}, ...
                    {'numeric'}, ...
                    { ...
                        '>=', 1, ...
                        '<=', varargin{1}.numel(), ...
                        'integer', ...
                        'nonnan', ...
                        'scalar' ...
                        }, ...
                    fname, ...
                    'varargin{2}' ...
                    );

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
            printf('ItemListSelection(\n');
            idx = 1;
            while(selec.list.numel() >= idx)
                name = selec.list.items{idx}.name;
                value = selec.list.items{idx}.value;
                if(idx == selec.idx)
                    printf( ...
                        '%6s[ Item("%s\", "%s") ], ...\n', ...
                        ' ', ...
                        selec.list.items{idx}.name, ...
                        selec.list.items{idx}.value ...
                        );

                else
                    printf( ...
                        '\tItem("%s\", "%s"), ...\n', ...
                        selec.list.items{idx}.name, ...
                        selec.list.items{idx}.value ...
                        );

                endif;

                idx = idx + 1;

            endwhile;
            printf(')\n');

        endfucntion;

% -----------------------------------------------------------------------------
%
% Method 'select_item':
%
% Use:
%       -- selec.select_item(item)
%
% Description:
%          If given item is member of the selection list, set selection index to
%          value of the index of a given item in the selection list.
%
% -----------------------------------------------------------------------------
        function selec = select_item(selec, item)
            fname = 'select_item';

            if(~isa(item, 'Item'))
                error( ...
                    '%s: item must be an instance of the "Item" class', ...
                    fname ...
                    );

            endif;

            if(selec.list.ismember(item))
                selec.idx = selec.list.index(item);

            endif;

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'selected_item':
%
% Use:
%       -- selec.selected_item()
%
% Description:
%          Return item from the list pointed by the selection index.
%
% -----------------------------------------------------------------------------
        function item = selected_item(selec)
            item = selec.list{selec.idx};

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequivalent':
%
% Use:
%       -- result = selec.isequivalent(other)
%
% Description:
%          Return whether or not two lists selections are equivalent. Two
%          list selections are equivalent if their lists are equivalent.
%
% -----------------------------------------------------------------------------
        function result = isequivalent(selec, other)
            fname = 'isequivalent';

            if(~isa(other, 'ItemListSelection'))
                error( ...
                    '%s: other must be an instance of the "ItemListSelection" class', ...
                    fname ...
                    );

            endif;

            result = selec.list.isequivalent(other.list);

        endfunction;

% -----------------------------------------------------------------------------
%
% Method 'isequal':
%
% Use:
%       -- result = list.isequal(other)
%
% Description:
%          Return whether or not two lists selections are equal. Two list
%          selections are equal if both their lists and selection indexes are
%          equal.
%
% -----------------------------------------------------------------------------
        function result = isequal(selec, other)
            fname = 'isequal';

            if(~isa(other, 'ItemListSelection'))
                error( ...
                    '%s: other must be an instance of the "ItemListSelection" class', ...
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
