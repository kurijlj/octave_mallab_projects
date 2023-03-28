function mnod = calcnetod(msig, mbkg, mzrl=NaN, varargin)
%% -----------------------------------------------------------------------------
%%
%% Function 'calcnetod':
%%
%% -----------------------------------------------------------------------------
%
%  Use:
%       -- mnod = calcnetod(msig, mbkg)
%       -- mnod = calcnetod(msig, mbkg, mzrl)
%       -- mnod = calcnetod(..., "PROPERTY", VALUE, ...)
%
%% Description:
%          Calculate netOD for the given set of measured signal pixel valueas
%          and for the given set of measured background pixel values
%          according to procedure described in the article:
%          https://doi.org/10.1016/j.ejmp.2018.05.014
%
%          Set of the measured background data samples must consist of only one
%          data sample. It is not mandatory for the calculation to signal data
%          samples and background data samples have identical windows (ROIs).
%          However, it is mandatory for the zero-light and control piece
%          data samples to be equivalent (see help on DataSample class).
%
% -----------------------------------------------------------------------------
    fname = 'calcnetod';
    use_case_a = sprintf(' -- mpvn = %s(msig, mbkg)', fname);
    use_case_b = sprintf(' -- mpvn = %s(msig, mbkg, mzrl)', fname);
    use_case_c = sprintf(' -- mpvn = %s(..., "PROPERTY", VALUE, ...)', fname);

    if(2 < nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s\n%s\n%s', ...
            fname, ...
            use_case_a, ...
            use_case_b, ...
            use_case_c ...
            );

    endif;

endfunction;  % calcnetod()
