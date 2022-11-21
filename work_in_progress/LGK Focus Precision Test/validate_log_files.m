function pt = validate_log_files(dir)
% -----------------------------------------------------------------------------
%
% Function 'validate_log_files':
%
% Use:
%       -- pt = find_profile_edges(x, Dp)
%
% Description:
%       Validate integrity of the LGK Focus Precision Test log files. It
%       traverses the given diractory and checks if given files of the proper
%       file extension ('*.rmd') and file length ().
%
%       It returns cell array containing file names in the first column and a
%       status indicator in the second column ('PASS', 'FAIL');
%
% -----------------------------------------------------------------------------
    fname = 'validate_log_files';
    use_case_a = sprintf('-- pt = %s(dir)', fname);

    % Validate number of passed arguments
    if(1 ~= nargin)
        % Invalid call to function
        error( ...
            'Invalid call to %s. Correct usage is:\n%s', ...
            fname, ...
            use_case_a ...
            );

    endif;

    % Validate 'dir' argument
    if(~ischar(dir) || isempty(dir))
        error('%s: dir must be a non-empty string', fname);

    endif;
    if(~isfolder(dir))
        error('%s: dir must point to a valid folder', fname);

    endif;

    dlst = readdir(dir);
    dlst = dlst(3:end);

    pt = cell(1, 2);

    idx = 1;
    while(numel(dlst) >= idx)
        pt{idx, 1} = dlst{idx};

        if(isfile(fullfile(dir, dlst{idx})))
            [d, n, e] = fileparts(dlst{idx});

            if(isequal('.rmd', e))
                if(41 == numel(n) && isequal('QAFocusPrecisionTest', n(1:20)))
                    fid = fopen(fullfile(dir, dlst{idx}));
                    if(-1 ~= fid)
                        if(-1 ~= fseek(fid, 0, 'eof'))
                            if(34000 < ftell(fid))
                                pt{idx, 2} = 'VALID_FOCUS_PRECISON_LOG';

                            else
                                pt{idx, 2} = 'NOT_A_VALID_FOCUS_PRECISON_LOG';

                            endif;

                        else
                            pt{idx, 2} = 'ERROR_READING_FILE';

                        endif;

                        fclose(fid);

                    else
                        pt{idx, 2} = 'ERROR_OPENING_FILE';

                    endif;

                else
                    pt{idx, 2} = 'NOT_A_VALID_FOCUS_PRECISON_LOG';

                endif;

            else
                pt{idx, 2} = 'NOT_A_FOCUS_PRECISON_LOG';

            endif;

        else
            pt{idx, 2} = 'NOT_A_VALID_FILE';

        endif;

        ++idx;

    endwhile;

endfunction;
