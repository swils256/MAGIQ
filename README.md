# About MAGIQ
MAGIQ stands for MRS Analysis, Generation, and In-Vivo Quantification. This software suite is used by the Bartha Lab to generate simulated prior-knowledge templates, post-process spectra, to fit spectra, and to quantify metabolite concentrations.

## Updated Installation Instructions:

## 3T MRS Manual:
* [3T MRS Manual - SW](https://github.com/swils256/MAGIQ/blob/master/3T%20Magnetic%20Resonance%20Spectroscopy%20Manual%20-%20Final.docx)

# Usage
Navigate to the folder containing the MAGIQ files and launch the program with the following commands:
```
cd <filepath to MAGIQ>
python main.py
```
You can launch the individual programs of the MAGIQ Software Suite using:
```
python pints.py
python apps.py
python fitman.py
python spices.py
python barstool.py
```
You can also run the "Rodent Version" of BARSTOOL using the command:
```
python barstoolrv.py
```

# Included Tools
## PINTS (Prior Information Templates)
PINTS is a program used to generate simulated semi-LASER and LASER <sup>1</sup>H-MRS prior information templates (basis sets). With PINTS, you can:
* simulate metabolites
* visualize the basis sets
* generate FITMAN compatible `*.cst`, `*.ges`, and `*.dat` files

See the [PINTS User Guide](https://github.com/dwong263/MAGIQ/wiki/PINTS-Overview) for usage instructions.

## APPS (Assorted Pre-Processing Tools)
APPS is a program used to perform a variety of signal processing steps before you fit MR spectra collected *in-vivo*. Some things that can be done include:
* Converting spectroscopy files generated from Bruker scanners into a FITMAN compatible `*.dat` format
* Removal of residual water signal from the *in-vivo* spectrum
* Subtraction of a macromolecule spectrum from the full (metabolite + macromolecule) spectrum acquired during an interleaved acquisition.

See the [APPS User Guide](https://github.com/dwong263/MAGIQ/wiki/APPS-Overview) for usage instructions.

## FITMAN
FITMAN is a program used to post-process and fit MR spectra collected in-vivo. With FITMAN, you can:
* read and convert spectroscopy files generated from GE, SIEMENS, and VARIAN scanners
* perform post processing of MR spectra to remove eddy current artifacts and restore a Lorentzian lineshape
* perform subtraction of macromolecule resonances
* remove residual water signal
* fit spectra (including fitting of water suppressed and unsuppressed data)
* generate SPICeS and BARSTOOL compatible `*.out` files

See the [FITMAN User Guide](https://github.com/dwong263/MAGIQ/wiki/FITMAN-Overview) for usage instructions.

## SpICeS (Spectroscopy Interactive Component Selector)
SPICeS is a program used to visualize fitted spectral models. with SPICeS, you can:
* visualize the raw spectra data (`*.dat` files) and fitted models (`*.out` files)
* define groups of metabolites to visualize together
* output the visualization with a variety of vector and raster image formats

See the [SPICeS User Guide](https://github.com/dwong263/MAGIQ/wiki/SpICeS-User-Guide) for usage instructions.

## BARSTOOL
BARSTOOL is a program used to quantify metabolites measured in-vivo. With this program, you can:
* calculate metabolite ratios
* calculate metabolite Cram&eacute;r-R&aacute;o lower bounds
* calculate metabolite concentrations
* perform brain extraction and gray matter/ white matter / CSF segmentation via a graphical interface to FSL BET and FAST commands
* save results to a Microsoft Excel readable file

See the [BARSTOOL User Guide](https://github.com/dwong263/MAGIQ/wiki/BARSTOOL-Overview) for usage instructions.

## BARSTOOL-RV (Rodent Version)
BARSTOOL-RV is a version of the BARSTOOL program that works specifically for rodent spectroscopy data. With this program, you can:
* calculate metabolite ratios
* calculate metabolite Cram&eacute;r-R&aacute;o lower bounds
* calculate metabolite concentrations
* perform brain extraction and tissue/CSF segmentation on anatomical images via a graphical interface to PCNN3D and RATS
* save results to a Microsoft Excel readable file

See the [BARSTOOL-RV User Guide](https://github.com/dwong263/MAGIQ/wiki/BARSTOOLRV-Overview) for usage instructions.

_**Note that the "Bruker" aspects of this program has yet to be finalized. Use at your own peril!**_

# Credits
**PINTS**: Dickson Wong (dwong263@uwo.ca)

**FITMAN**: Robert Bartha (rbartha@robarts.ca), John Potwarka, and Dick Drost

**SPICeS**: Dickson Wong (dwong263@uwo.ca)

**BARSTOOL**: Dickson Wong (dwong263@uwo.ca), Todd Stevens, John Adams (jadam33@uwo.ca)

**BARSTOOL-RV**: Dickson Wong (dwong263@uwo.ca), Todd Stevens, John Adams (jadam33@uwo.ca)

# License

This software was developed for internal use by the Bartha Lab and Bartha Lab collaborators. It is not intended for commercial use.



