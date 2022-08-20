% 'utl_cli_progress_indicator' is a function from the package: 'Utility Toolbox'
%
%  -- utl_cli_progress_indicator (C)
%      Print progress indicator to the 'stdout'.
%
%      C is variable indicating relative completness of a task normalized to 1.
%
%      See also: 

function utl_cli_progress_indicator(C)
    if(0.0 == C)
        printf("processing:   0%%");

    elseif(1.0 == C)
        printf("\b\b\b\b\b Completed!\n");

    else
        printf("\b\b\b\b\b%4d%%", round(C*100));

    endif;

endfunction;
