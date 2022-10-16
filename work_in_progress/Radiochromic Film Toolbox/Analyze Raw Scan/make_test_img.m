% -----------------------------------------------------------------------------
%
% Function 'make_test_img':
%
% Use:
%       -- make_test_img(s)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function I = make_test_img(s)
    fname = 'make_test_img';
    use_case_a = ' -- make_test_img(s)';

    I = phantom(s);
    I = imcomplement(I);
    I = I.*65535;

endfunction;
