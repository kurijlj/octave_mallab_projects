function I = make_test_scan(imsz, nrm=65535)
% -----------------------------------------------------------------------------
%
% Function 'make_test_scan':
%
% Use:
%       -- I = make_test_scan(imsz, nrm)
%
% Description:
%       Use 'phantom' function from the image package to generate test scan
%       image of the given size s.
%
%       The n parameter is used as value to which to normalize pixel values in
%       the resulting image.
%
%       See also: make_test_noisy_scan
%
% -----------------------------------------------------------------------------

    fname = 'make_test_scan';
    use_case_a = ' -- I = make_test_scan(imsz)';
    use_case_b = ' -- I = make_test_scan(imsz, nrm)';

    % Load required packages
    pkg load image;

    I = phantom(imsz);
    I = imcomplement(I);
    I = I.*nrm;

endfunction;
