% 'dcm_view_series' is a function from the package: 'DICOM Toolbox'
%
%  -- dcm_view_series ()
%      TODO: Put function description and help here

function dcm_view_series()
    % Store function name into variable for easier lgo reporting and user
    % feedback management
    fname = 'dcm_view_series';

    series_dir = uigetdir('title', 'DICOM Series View');

    % Load required modules
    graphics_toolkit qt;
    pkg load dicom;

    if(0 == series_dir(1))
        printf('%s: No directory selected.\n', fname);

        return;

    endif;

    series_file = readdir(series_dir);
    if(isempty(series_file))
        printf('%s: Nothing to load. Empty directory.\n', fname);

        return;

    endif;

    series_info = {};
    series_data = {};
    slice_location = [];
    slice_order = [];

    i = 3;
    progress_window = waitbar( ...
        0.0, ...
        'Loading DICOM data ...', ...
        'name', 'DICOM Series View' ...
        );
    while(length(series_file) >= i)
        path = fullfile(series_dir, series_file{i});
        if(isdicom(path))
            info = dicominfo(path);
            if( ...
                    ismember('ImageOrientationPatient', fieldnames(info)) ...
                    && ismember('ImagePositionPatient', fieldnames(info)) ...
                    )
                series_info = {series_info{:} info};
                series_data = {series_data{:} dicomread(path)};
                position = [info.ImagePositionPatient];
                orientation = [info.ImageOrientationPatient];
                norm = cross(orientation(1:3), orientation(4:end));
                slice_location = [slice_location dot(norm, position)];

            else
                printf('%s: WARNING! File: \"%s\" ignored. No spatial info.\n', fname, path);

            endif;

        else
            printf('%s: WARNING! Not a DICOM file: \"%s\".\n', fname, path);

        endif;

        waitbar(i/length(series_file), progress_window);
        i = i + 1;

    endwhile;

    % Clean up GUI
    if(ishandle(progress_window))
        delete(progress_window);

    endif;

    if(isempty(series_data))
        printf('%s: ERROR! Not enough data to reconstruct DICOM series.\n', fname, path);

        return;

    endif;

    % Determine the slice order
    i = 1;
    slice_location_sorted = sort(slice_location);
    while(length(series_info) >= i)
        [res, ind] = ismember(slice_location(i), slice_location_sorted);
        slice_order(ind) = i;
        i = i + 1;
    endwhile;

    hfig = figure( ...
        'name', 'DICOM Series View', ...
        'units', 'points', ...
        'sizechangedfcn', @dcm_resize_series_view ...
        );
    guisz = get(hfig, 'position');
    hax = axes( ...
        % 'parent', hfig ...
        'parent', hfig, ...
        'units', 'points', ...
        'position', [ ...
            0.05*guisz(3) 0.15*guisz(4) ...
            0.90*guisz(3) 0.80*guisz(4) ...
            ] ...
        );
    hslsel = uicontrol( ...
        'parent', hfig, ...
        'style', 'slider', ...
        'units', 'points', ...
        'tag', 'slice_selector', ...
        'tooltipstring', 'Select slice', ...
        'callback', @dcm_update_series_view, ...
        'min', 1, 'max', length(series_info), ...
        'sliderstep', [ ...
            1/(length(series_info) - 1), ...
            1/(length(series_info) - 1) ...
            ], ...
        % 'value', 1 ...
        'value', 1, ...
        % 'position', [0.05 0.05 0.90 0.20] ...
        'position', [ ...
            0.05*guisz(3) 0.05*guisz(4) ...
            0.90*guisz(3) 0.05*guisz(4) ...
            ] ...
        );

    % Calculate index of slice in the middle of the series and display it
    msi = ceil(length(series_data)/2);
    blevel ...
        = series_info{slice_order(msi)}.WindowCenter ...
        - series_info{slice_order(msi)}.WindowWidth/2;
    class_min = double(intmin(class(series_data{1})));
    if(class_min > blevel)
        blevel = class_min;
    endif;
    tlevel ...
        = series_info{slice_order(msi)}.WindowCenter ...
        + series_info{slice_order(msi)}.WindowWidth/2;
    class_max = double(intmax(class(series_data{1})));
    if(class_max < tlevel)
        tlevel = class_max;
    endif;
    set(hslsel, 'value', msi);
    imshow(series_data{slice_order(msi)}, [blevel, tlevel], 'parent', hax);

    % Save GUI state
    hgui = guihandles(hfig);
    hgui.main_figure = hfig;
    hgui.hax_view = hax;
    hgui.hslsel = hslsel;
    hgui.series_data = series_data;
    hgui.series_info = series_info;
    hgui.slice_order = slice_order;
    hgui.itf = [blevel tlevel];
    guidata(hfig, hgui);

endfunction;


function dcm_resize_series_view(obj)
    hgui = guidata(obj);

    switch(gcbo)
        case {hgui.main_figure}
            guisz = get(hgui.main_figure, 'position');
            set( ...
                hgui.hax_view, ...
                'position', [ ...
                    0.05*guisz(3) 0.15*guisz(4) ...
                    0.90*guisz(3) 0.80*guisz(4) ...
                    ] ...
                );
            set( ...
                hgui.hslsel, ...
                'position', [ ...
                    0.05*guisz(3) 0.05*guisz(4) ...
                    0.90*guisz(3) 0.05*guisz(4) ...
                    ] ...
                );

    endswitch;

endfunction;

function dcm_update_series_view(obj)
    hgui = guidata(obj);

    switch(gcbo)
        case {hgui.hslsel}
            slindex = round(get(hgui.hslsel, 'value'));
            srindex = hgui.slice_order(slindex);
            imshow(hgui.series_data{srindex}, hgui.itf, 'parent', hgui.hax_view);

    endswitch;

endfunction;
