This repository contains sample code for paper "A Retinex-based variational model for low-light image enhancement with noise transformation".

### Proposed Method
We propose a noise transformation method based on histogram matching to convert different noises into Gaussian noise, enhancing noise robustness.

### Prerequisites
- Original code is tested on Matlab R2023a 64bit, Windows 11.

### Usage
- Our code for the variational model part is modified from [STAR-TIP2020](https://github.com/csjunxu/STAR-TIP2020).
- An example of how to run the algorithm is at `enhancement.m`.
- `noise_trans_bm3d.m` is our noise transformation method with BM3D.
- `noise_trans_ffdnet.m` is our noise transformation method with FFDNet.
### Citation
```
@article{FU2026112781,
title = {A Retinex-based variational model for low-light image enhancement with noise transformation},
journal = {Pattern Recognition},
volume = {172},
pages = {112781},
year = {2026},
author = {Sheng Fu and Junchao Zhang and Yidong Luo},
}
```
