# PDF for lulu formatter

Tools for formatting pdf files to send to lulu xpress

## Overview

This application is a small program to help you format pdf files to send them to print at lulu normal/xpress/beta.

The program does the following:

* Resize pdf to a security area.
* Add bleed up to 0.25 inches.

## Requirements

* R language, a statistical and graphics program; you can download and install from www.r-project.org
* Imagemagick, a program to manipulate images; you can download It from www.imagemagick.org or install it inside R (see below).
* Community release of Coherent PDF.

## Notes on installation

### How to install required programs:

Use installers at:

http://www.imagemagick.org
https://community.coherentpdf.com

### How to install required packages:

Inside R, run the following commands, this is only required to be run once:

```
install.packages("tidyverse")
install.packages("pdftools")
install.packages("png")
```

If you encounter any problem install packages, refer to the package documentation.

### How to download the function:

Download this repository using the Clone or download button, decompress it to any directory and write it down to use later (path/to/the/decompressed.repository).

## How to run the program

Load the three required packages:

```
library(tidyverse)
library(pdftools)
library(png)
```

Load the function

```
source("path/to/the/decompressed.repository/format.lulu.pdf.R")
```

Run the function:

```
format.lulu.pdf(i.pdf = "path.to.the.original.pdf", 
                i.cpdf = "path/to/cpdf/executable", 
                i.magick = "path/to/imagemagick/executables",
                i.out="path.to.the.original.pdf",
                i.booksize = "US Letter")
```

## Output

* portadacompleta.pdf, pdf with the cover
* textofinal.pdf, pdf with the contents

## More parameters of the function

* i.pdf, full path to the original pdf 
* i.out = getwd(), full path to the output directory 
* i.cpdf = "H:/Portables/cpdf", full path to the directory there coherent pdf is located
* i.magick = "C:/Program Files/ImageMagick-7.0.9-Q16", full path to the directory there imagemagick is located
* i.booksize="US Letter", format of the output pdf
* i.width = 8.5, optional, if i.booksize is not specified, width of the output pdf
* i.height = 11, optional, if i.booksize is not specified, height of the output pdf
* i.white = 0.10, lenght of the white frame around the resized pdf, it can be up to 0.25 (length of the bleed)
* i.shift.odd = 0.05, shift odd pages in inches, positive number=shift to the right, negavite, to the left
* i.shift.even = -0.05, shift even pages in inches, positive number=shift to the right, negavite, to the left
* i.pages.front=NA, which page is the front page
* i.pages.back=NA, which page is the back page
* i.pages.contents=NA, which pages are the contents, the format can contain "-" for range of pages and "," por concatenating segment, for example: 3-10,20-25 (from pages 3 to 10 and from 20 to 25)
* i.pages.add=NA, add page at these locations
* i.delete.temp=T, delete temporary files
* i.additional.shifts=data.frame(), more shifts for specific pages, it must be a data.frame with columns "page"" and "shift", for example: data.frame(page=c(46,36,129), shift=c(0.05,0.05,-0.05))
* i.ppp = 300, density of images for generating the cover
* i.spine = NA, length of spine width, as shown in lulu when creating the pdf
* i.spine.color="#000000", background color of the spine
* i.rotate.right=NA, pages to rotate to the right (clockwise)
* i.rotate.left=NA, pages to rotate to the left (counterclockwise)
* i.convert="-trim +repage", more parameters to the convert executable for imagemagick
