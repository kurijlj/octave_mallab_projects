% -----------------------------------------------------------------------------
%
% Function 'make_test_noisy_img':
%
% Use:
%       -- make_test_noisy_img(imsz, noise, sdev)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------
function I = make_test_noisy_img(imsz, noise, sdev)
    fname = 'make_test_noisy_img';
    use_case_a = ' -- make_test_noisy_img(imsz, noise, sdev)';

    I = make_test_img(imsz);
    I = imnoise(I, noise, 0 - 6*sdev, power(sdev, 2));

endfunction;
