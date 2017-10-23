# Neural Scene De-rendering

This repository contains scripts for rendering Minecraft images as those in the CVPR'17 Neural Scene De-rendering paper.

http://nsd.csail.mit.edu

<img src="http://nsd.csail.mit.edu/images/repo.jpg" width="600">

## Prerequisites

**Project Malmo**: Please follow the instructions from [`Malmo`](https://github.com/Microsoft/malmo) to launch the Minecraft client (0.30.0).

Please also include the path to Malmo schemas in the environment variable `MALMO_XSD_PATH`.

**Torch**: We use [`Torch 7`](http://torch.ch) for our implementation with these additional packages:

- [`libMalmoLua`](https://github.com/Microsoft/malmo): offered in Project Malmo. Its path should be included in the environment variable `LUA_CPATH`.


## Guide
Our current release has been tested on Ubuntu 14.04.

#### Cloning the repository
```sh
git clone git@github.com:jiajunwu/nsd.git
cd nsd
```

#### Connecting to the client
Please update line 101 of `mc-gen.lua` with the actual IP and port of your Minecraft client.

#### Image rendering demo (`main.lua`)
The demo calls the rendering function to render an image based on the scene XML. Please find descriptions of the scene XML we used in the source file.

```sh
th main.lua 
```
The script renders the image and saves it as `demo.png`. It should look as follows.

<img src="http://nsd.csail.mit.edu/images/demo.png" width="400">

Sometimes the image might look darker than expected, in which cases please try again.

## Reference

    @inproceedings{nsd,
      title={{Neural Scene De-rendering}},
      author={Wu, Jiajun and Tenenbaum, Joshua B and Kohli, Pushmeet},
      booktitle={IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
      year={2017}
    }

For any questions, please contact Jiajun Wu (jiajunwu@mit.edu). 
