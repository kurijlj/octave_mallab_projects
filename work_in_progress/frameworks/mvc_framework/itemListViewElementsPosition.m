% -----------------------------------------------------------------------------
%
% Subfunction 'itemListViewElementsPosition':
%
% Use:
%       -- position = itemListViewElementsPosition(hcntr, uistyle)
%
% Description:
%          Function to calculate GUI elements postion on the panel.
%
% -----------------------------------------------------------------------------
function position = itemListViewElementsPosition(hcntr, uistyle)
    fname = 'itemListViewElementsPosition';
    use_case_a = ' -- position = itemListViewElementsPosition(hcntr, uistyle)';

    % Validate input arguments ------------------------------------------------
    if(~ishghandle(hcntr))
        error( ...
            '%s: hcntr must be handle to a graphics object', ...
            fname
            );

    endif;

    if(~isa(uistyle, 'AppUiStyle'))
        error( ...
            '%s: uistyle must be an instance of the "AppUiStyle" class', ...
            fname ...
            );

    endif;

    % Get UI style parameters normalized to extents of the containing UI element
    nstyle = uistyle.normalized(getpixelposition(hcntr));

    % Calculate elements positions within container
    position = [ ...
        nstyle.padding_hor, ...
        nstyle.padding_ver, ...
        1.00 - 2*nstyle.padding_hor, ...
        1.00 - 2*nstyle.padding_ver; ...
        ];

endfunction;
