# Lithophane generator 3Ds Max Script
3Ds max script to generate flat or curved lithophanes from pictures.
![Example lithophane](https://github.com/cenmir/Lithophane-Generator-3Ds-Max/raw/master/LithophaneGeneratorSettings.png)
Example lithophane

## Installation
* Clone this repo to you script folder
* Run the `lithophaneGenerator.ms`  in Max

## How to use
1. Choose an image
2. Click on *Create!*

### Settings
| Setting | Description  |
|--|--|
| Width | Once and image is loaded, when modified changes the Height to keep the same aspect ratio as the image |
| Height | Works like the width field |
|Minimum thickness | The lithophane will not be thinner than this value |
|Displacement strength | How much to displace the front face of the lithophane using the chosen image. Higher values will result in a higher contrast. Positive values will generate positive lithophanes.|
|Tesselations | The flat face is uniformly tesseleted this many times. The number of faces generated are: $n_F=4^{n-1}$, where $n$ is the number of tesselations. Values of 8 are considered coarse, while a value of 10 is considered very high detail.|
|Bend angle| If checked, a *Bend* modifier will be added with an angle around the x-axis.|

## Rendering
The image is rendered in max using a *Subsurface Scattering Fast Material* with these settings:
![Material setttings](https://github.com/cenmir/Lithophane-Generator-3Ds-Max/raw/master/MaterialSettings.png)