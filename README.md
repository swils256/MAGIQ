# MAGIQ Software Suite

MAGIQ stands for MRS Analysis, Generation, and In-Vivo Quantification. This software software is used by the Bartha Lab to generate simulated prior-knowledge templates, post-process spectra, to fit spectra, and to quantify metabolite concentrations.

MAGIQ incorporates previously used tools such as PINTS, FITMAN, and BARSTOOL. All future development of these tools will be under the MAGIQ umbrella.

## Included Tools
### PINTS (Prior Information Templates)
PINTS is a program used to generate simulated semi-LASER 1 H-MRS prior information templates (basis sets). With PINTS program, you can:
* simulate metabolites
* visualize the basis sets
* generate FITMAN compatible `*.cst`, `*.ges`, and `*.dat` files

### FITMAN
FITMAN is a program used to post-process and fit MR spectra collected in-vivo. With FITMAN, you can:
* read and convert spectroscopy files generated from GE, SIEMENS, and VARIAN scannars
* perform post processing of MR spectra to remove eddy current artifacts and restore a Lorentzian lineshape
* perform subtraction of macromolecule resonances
* remove residual water signal
* fit spectra (including fitting of water suppressed and unsuppressed data)
* generate SPICeS and BARSTOOL compatible `*.out` files

### SPICeS
SPICeS is a program used to visualize fitted spectral models. with SPICeS, you can:
* visualize the raw spectra data (`*.dat` files) and fitted models (`*.out` files)
* define groups of metabolites to visualize together
* output the visualization with a variety of vector and raster image formats

### BARSTOOL
BARSTOOL is a program used to quantify metabolites measured in-vivo. With this program, you can:
* calculate metabolite ratios
* calculate metabolite Cram&eacute;r-R&aacute;o lower bounds
* calculate metabolite concentrations
* perform brain extraction and gray matter/ white matter / CSF segmentation via a graphical interface to FSL BET and FAST commands
* save results to a Microsoft Excel readable file

## Dependencies
MAGIQ requires the following dependencies to run:
* IDL Virtual Machine (version 7 or above)
* Python 2.7.10
* PyQt5
* scipy 0.17.1 (or higher)
* numpy 1.10.4 (or higher)
* pyfftw 0.10.1 (or higher)
* matplotlib 1.5.1 (or higher)
* PyGAMMA (latest version)
* FSL 5.0.9
* fslview (**_not_** fsleyes)

## Usage
After downloading MAGIQ, launch the program using the command:
`python main.py`

## Credits
**PINTS**: Dickson Wong (dwong263@uwo.ca)
**FITMAN**: Robert Bartha (rbartha@robarts.ca), John Potwarka, and Dick Drost
**SPICeS**: Dickson Wong (dwong263@uwo.ca)
**BARSTOOL**: Dickson Wong (dwong263@uwo.ca), Todd Stevens, John Adams (jadam33@uwo.ca)

## License
This software is intended for internal use by the Bartha Lab and Bartha Lab collaborators. It is not inteded for commerical use. Please do not distribute or modify the software without expression permission from the authors.
