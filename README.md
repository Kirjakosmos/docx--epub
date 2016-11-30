## docx->epub
###IDEA
Takes a **docx** file and an optional cover image file (.jpeg) as input, produces an **epub** file as output.
Splits the docx into chapters in the output-epub at headings marked with "Otsikko"-style and lines which are marked with the string '¤¤¤o¤¤¤' (the string gets removed before writing the epub).

###USAGE
from command line:  
./muunnos.sh input.docx [-u output_name] [-k cover_image.jpg]

Second and third arguments are optional. The second command line argument is always interpreted as the desired name of the output, so in order to input a cover image, output name must also be specified.

Requires shell-environment, awk, zip and unzip.

Supported properties in docx-file:
* images in the text, but for now only if they are of the png format
* bold, cursive and underlined sections in text
* author name, title and language of the document
* different styles, as long as they follow the naming convention outlined above, retain these properties:
  * relative font-sizes
  * justifications (left, right, centre)
  * marginals before and after paragrahps
  * left marginals
  * cursive or bold by default


###INNER WORKINGS

The script **muunnos.sh** juggles the following five AWK scripts.  
**mu_kuvat.awk** digs through the docx contents to prepare the images to be included in the epub.  
**mu_tyylit.awk** finds the properties for styles for the epubs css.  
**mu_teksti.awk** creates xhtml files from the text contents of the docx.  
**mu_metatiedot.awk** checks for usable metadata in the docx.  
Finally **mu_nidonta.awk** combines the elements prepared by the previous scripts and adds the necessary bits to create a valid epub file.