function[skel] = ModelToSkeleton(img)
    skel = Skeleton3D(logical(img));
    niftiwrite(int8(skel), 'AirwayTreeSkeleton.nii');
end