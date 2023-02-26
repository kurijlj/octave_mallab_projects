function [I_ns, I] = make_test_noisy_scan(imsz, noise, sdev, nrm=65535)
% -----------------------------------------------------------------------------
%
% Function 'make_test_noisy_scan':
%
% Use:
%       -- [Ins, I] = make_test_noisy_scan(imsz, noise, sdev)
%       -- [Ins, I] = make_test_noisy_scan(imsz, noise, sdev, nrm)
%
% Description:
%       TODO: Add function descritpion here.
%
% -----------------------------------------------------------------------------

    fname = 'make_test_noisy_scan';
    use_case_a = ' -- [Ins, I] = make_test_noisy_scan(imsz, noise, sdev)';
    use_case_b = ' -- [Ins, I] = make_test_noisy_scan(imsz, noise, sdev, nrm)';

    % Load required packages
    pkg load image;

    I    = make_test_scan(imsz, nrm - 9*sdev);
    I_ns = imnoise(I, noise, 0, power(sdev, 2));
    I    = I + 4.5*sdev;
    I_ns = I_ns + 4.5*sdev;

endfunction;
