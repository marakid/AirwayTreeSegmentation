function[refinedTree] = SecondPassRegionGrowing(img, tree, mask)

    d3 = size(img, 3);
    szelet = img(:, :, d3-30);
    figure(1);
    disp('Select the seed point');
    imshow(uint8(szelet));
    [y,x] = getpts;
    
    [~, refinedTree] = regionGrowing(img,[round(x), round(y), d3-30], Inf, Inf, [], true, false, tree, mask);
    
    niftiwrite(int8(refinedTree), 'RefinedAirwayTree.nii');
end