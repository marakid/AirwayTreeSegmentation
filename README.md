# Airway tree segmentation from CT

This code performs an airway tree segmentation from a CT image, then using graph algorithms it
labels and colours the branches based on their generation.

For certain parts of my algorithm, I've used the following codes:
- Adrian Becker (2020). Region Growing (2D/3D) in C (https://www.mathworks.com/matlabcentral/fileexchange/63317-region-growing-2d-3d-in-c), MATLAB Central File Exchange. Retrieved December 8, 2020.
- Daniel (2020). Region Growing (2D/3D grayscale) (https://www.mathworks.com/matlabcentral/fileexchange/32532-region-growing-2d-3d-grayscale), MATLAB Central File Exchange. Retrieved December 8, 2020.
- Kollmannsberger, Kerschnitzki et al., "The small world of osteocytes: connectomics of the lacuno-canalicular network in bone." New Journal of Physics 19:073019, 2017.
Skeleton3D https://www.mathworks.com/matlabcentral/fileexchange/43400-skeleton3d?fbclid=IwAR3unHJ-kQl75_epY5rDV3i3b4rNojK1FolOJ_GNEV-l4Zum7qFsJLlY0As
- Kollmannsberger, Kerschnitzki et al., "The small world of osteocytes: connectomics of the lacuno-canalicular network in bone." New Journal of Physics 19:073019, 2017.
Skel2Graph 3D https://www.mathworks.com/matlabcentral/fileexchange/43527-skel2graph-3d

For handling NIfTI files, the following toolbox is necessary:
- Jimmy Shen (2020). Tools for NIfTI and ANALYZE image (https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image), MATLAB Central File Exchange. Retrieved December 8, 2020.

To use this algorithm, you have to run the 'AirwayTreeSegmentationFromCT.m' file. It requires a CT image as an input, in '.nii.gz' or '.nii' format.
The results of each step are saved in an appropriately named '.nii' file.
