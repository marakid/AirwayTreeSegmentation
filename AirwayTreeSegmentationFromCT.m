%CT felvétel:
fileName='10000135_1_CTce_ThAb.nii.gz';
niiFile=load_nii(fileName);
img = niiFile.img;

%Preprocessing: hard and soft filter fusion
disp('Image preprocessing in progress...');
filtered = HfSfDataFusion(img);
disp('Preprocessing finished.');

%Rough tree model
disp('Starting first pass region growing...');
segment3d = FirstPassRegionGrowing(filtered);
disp('Rough model acquired.');

%Binary mask with possible airway locations
disp('Starting morphologial reconstruction...');
binaryMask = MorphologicalReconstruction(filtered);
disp('Binary mask acquired.');

%Refined tree model
disp('Starting second pass region growing...');
refined3d = SecondPassRegionGrowing(filtered, segment3d, binaryMask);
disp('Refined model acquired.');

%Skeleton
disp('Starting skeletonization...');
skeleton = ModelToSkeleton(refined3d);
disp('Skeleton model acquired.');

%Convert skeleton to graph and label branches according to generation
disp('Starting graph labeling...');
skeletonLabeled = GraphLabeling(skeleton);
disp('Labeled graph model acquired.');

%Final result
disp('Starting final step...');
airwayTreeLabeled = SkeletonToModel(skeletonLabeled, refined3d);
disp('Final, labeled airway tree model acquired.');
niftiwrite(airwayTreeLabeled, 'Final_AirwayTreeLabeled.nii');