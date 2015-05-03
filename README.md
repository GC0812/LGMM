GLMM
==================

Registering Retinal Vessel Images from Global to Local via Multiscale and Multicycle Features.

Installation
==================

1. In `Dataset/Image/`, there is only one pair of example images. The `index.txt` presents one pair of retinal images from same eye in every row.
2. Run `./preconditioning.m` first to preprocess retinal images and obtain skeleton images, the results are saved in `Dataset/Skeleton/`. 
3. The file `sdfs.cpp` is known as Space-based Depth-First Search algorithm for finding the cycle structures, which should be compiled prior to use such as `g++ sdfs.cpp -o sdfs` in Linux and Mac OS X systems.  
4. Run `./registration.m` to save optimal registration result of retinal images in `Results/`.

Notes
==================
1. The code is run with 64-bit Matlab R2013a on Mac OS X Yosemite, so two *.cpp files should be recompiled in other operating systems, which are in `PreProcessing/mex`.
2. The `legacy` flag of `unique` and `intersect` functions should be removed in Matlab R2012b and prior releases in your code, and the two functions are applied in `export_featuremat.m`, `export_loop.m` and `find_loop.m` files.
