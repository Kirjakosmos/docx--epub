## docx->epub
###IDEA
Takes a **docx** file and an optional cover image file (.jpeg) as input, produces an **epub** file as output.
Splits the docx into chapters in the output-epub at headings marked with "Otsikko"-style and lines which are marked with the string '¤¤¤o¤¤¤' (the string gets removed before writing the epub).

###USAGE
from command line:  
./muunnos.sh input.docx [output_name] [cover_image.jpg]

Second and third arguments are optional. The second command line argument is always interpreted as the desired name of the output, so in order to input a cover image, output name must also be specified.

Requires shell-environment, awk, zip and unzip.

Supported properties in docx-file:
* different styles, as long as they follow the naming convention outlined above, retain these properties:
  * relative font-sizes
  * justifications (left, right, centre)
  * marginals before and after paragrahps
  * left marginals
  * cursive or bold by default
* images in the text, but for now only if they are of the png format
* bold and cursive in text
* author name, title and language of the document