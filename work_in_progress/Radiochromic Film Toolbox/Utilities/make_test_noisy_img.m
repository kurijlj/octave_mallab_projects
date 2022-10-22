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

    % I = make_test_img(imsz);
    I = make_test_img(imsz) - 6*sdev;
    % I = imnoise(I, noise, 0 - 6*sdev, power(sdev, 2));
    I = imnoise(I, noise, 0, power(sdev, 2));
    I = I.*(I >= 0);
    % I = I - min(min(I));
    % I = I.*(65535/(max(max(I)) - min(min(I))));
endfunction;
