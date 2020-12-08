# Airway tree segmentation from CT

A szakdolgozatom keretei között kidolgozott algoritmus CT felvételről végzi el a hörgőfa szegmentálását,
majd a szegmentált modell ágait generációjuk szerint csoportokba sorolja és ennek megfelelően különböző színekkel jelöli.

Az algoritmus részét képező, külső forrásból származó kódok:
- Region Growing (2D/3D) in C https://www.mathworks.com/matlabcentral/fileexchange/63317-region-growing-2d-3d-in-c
- Region Growing (2D/3D grayscale) https://www.mathworks.com/matlabcentral/fileexchange/32532-region-growing-2d-3d-grayscale
- Skeleton3D https://www.mathworks.com/matlabcentral/fileexchange/43400-skeleton3d?fbclid=IwAR3unHJ-kQl75_epY5rDV3i3b4rNojK1FolOJ_GNEV-l4Zum7qFsJLlY0As
- Skel2Graph 3D https://www.mathworks.com/matlabcentral/fileexchange/43527-skel2graph-3d
