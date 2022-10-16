classdef TestClass
    properties (SetAccess = private, GetAccess = public)
        name = 'None';

    endproperties;

    methods (Access = public)
        function tc = TestClass(name)
            tc.name = name;

        endfunction;

        function disp(tc)
            if(1 ~= nargin)
                error('Invalid call to tc.disp()');

            endif;

            if(~isa(tc, 'TestClass'))
                error('tc must be a "TestClass" instance');

            endif;

        endfunction;

    endmethods;

endclassdef;
