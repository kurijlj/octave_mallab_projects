function BW = segment_film_piece(ss)
%% -----------------------------------------------------------------------------
%%
%% Function: 'segment_film_piece':
%%
%% -----------------------------------------------------------------------------
%
%  Use:
%       -- BW = segment_film_piece(ss)
%
%% Description:
%       Return binary mask of a film piece for each color channel from a Scanset
%       object.
%
%       The function is used to segment a film piece from a Scanset object, for
%       each color channel. The steps that are taken to segment the film %
%       piece or a optical density step wedge from the scanner background are:
%           1.  Smooth the image with a Gaussian filter.
%           2.  Subtract smoothed image from original image to get the unsharp
%               mask.
%           3.  Normalize the edges to the range [0, 1].
%           4.  Apply unsharp mask to original image.
%           5.  Calculate the image gradient of the edge enhanced image.
%           6.  Apply iamge dilate to the gradient image.
%           7.  Apply watershed segmentation to the dilated gradient image.
%           8.  Apply image fill holes to the watershed segmented image.
%           9.  Apply image erode to the filled image.
%
%       Function parameters:
%       ss: Scanset object
%           The Scanset object of the scanned film piece.
%
%       Return values:
%       BW: matrix
%           Binary mask of the film piece for each color channel.
%
% -----------------------------------------------------------------------------
    fname = "segment_film_piece";
    use_case_a = sprintf(" -- BW = %s(ss)", fname);

    % Check input arguments ---------------------------------------------------

    % Check number of input arguments
    if nargin != 1
        error( ...
            "Invalid call to %s. Correct usage is:\n%s", ...
            fname, ...
            use_case_a ...
            );

    endif;  % if nargin != 1

    % Check type of input argument
    if(~isa(ss, 'Scanset'))
        error( ...
            '%s: ss must be an instance of the "Scanset" class', ...
            fname ...
            );
    
    endif;  % if !isa(ss, "Scanset")

    % Do the computation ------------------------------------------------------

    % Make a kernel for the Gaussian filter
    sigma = 2;  % Standard deviation of the Gaussian kernel
    % Calculate the size of the kernel based on the desired sigma value
    kernel_size = (2 * ceil(3 * sigma) + 1) .* [1 1];
    kernel = fspecial('gaussian', kernel_size, 2);

    % Calculate the smoothed image from the original pixel values
    smtd = imfilter(ss.pixel_data(), kernel, "symmetric");

    % Calculate the unsharp mask
    unsharp_mask = ss.pixel_data() - smtd;

    % Normalize the edges to the range [0, 1]
    unsharp_mask = mat2gray(unsharp_mask);

    % Apply the unsharp mask to the original image
    edge_enhanced = mat2gray(ss.pixel_data() .* unsharp_mask);

    % Calculate the image gradient of the edge enhanced image
    gradR = imgradient(edge_enhanced(:, :, 1));
    gradG = imgradient(edge_enhanced(:, :, 2));
    gradB = imgradient(edge_enhanced(:, :, 3));
    
    % Calculate mean pixel value for each gradient image
    meanR = mean2(gradR);
    meanG = mean2(gradG);
    meanB = mean2(gradB);

    % Threshold the gradient images
    grad_mask_R = gradR > meanR;
    grad_mask_G = gradG > meanG;
    grad_mask_B = gradB > meanB;

    % Dilate the resulting gradient image
    se = strel('disk', 1, 0);
    dilatedR = imdilate(grad_mask_R, se);
    dilatedG = imdilate(grad_mask_G, se);
    dilatedB = imdilate(grad_mask_B, se);

    % Apply watershed segmentation to the dilated gradient image
    watershedR = watershed(dilatedR);
    watershedG = watershed(dilatedG);
    watershedB = watershed(dilatedB);

    % Fill holes in the inverted watershed segmented image
    filledR = imfill(~watershedR, "holes");
    filledG = imfill(~watershedG, "holes");
    filledB = imfill(~watershedB, "holes");

    % Erode the filled image
    maskR = imerode(filledR, se);
    maskG = imerode(filledG, se);
    maskB = imerode(filledB, se);

    % Return the binary mask for each color channel
    BW = cat(3, maskR, maskG, maskB);

endfunction;  % function segment_film_piece