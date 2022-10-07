% -----------------------------------------------------------------------------
%
% Function 'make_test_img':
%
% Use:
%       -- make_test_img(s, n, v)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function I = make_test_img(s, n, m, v)
    fname = 'make_test_img';
    use_case_a = ' -- make_test_img(s, n, v)';

    I = phantom(s);
    I = imcomplement(I);
    I = I*65535;
    I = imnoise(I, n, m, v);

endfunction;
