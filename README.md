# GLMM
Registering Retinal Vessel Images from Global to Local via Multiscale and Multicycle Features.

Installation

1. In `Dataset/Image/`, there is only one pair of example images. The `index.txt` presents one pair of retinal images from same eye in every row.
2. Run `./preconditioning.m` first to preprocess retinal images and obtain skeleton images, the results are saved in `Dataset/Skeleton/`. 
3. Run `./registration.m` to save optimal registration result of retinal images in `Results/`.

