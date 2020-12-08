function[segment3d] = FirstPassRegionGrowing(img)
    img = double(img);    
    d3 = size(img, 3);
    szelet = img(:, :, d3-30);
    figure(2);
    disp('Select the seed point');
    imshow(uint8(szelet));
    [y,x] = getpts;
    
    valid = false;
    threshold = 35;
    while(~valid)
        segment3d = regGrow().segment(img,[x y d3-30],threshold,inf,false);
        N = nnz(segment3d);
        if(N > 50000)
            threshold = threshold - 0.2;
        else
            valid = true;
        end
    end
    
    niftiwrite(int8(segment3d), 'RoughAirwayTree.nii');
end