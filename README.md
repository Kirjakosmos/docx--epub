## docx->epub
###IDEA
Takes a **docx** file and an optional cover image file (.jpeg) as input, produces **epub** file as output.
Splits the docx into chapters in the output-epub at headings marked with "Otsikko"-style.

###USAGE
from command line: 
./muunnos.sh input.docx [output_name] [cover_image.jpeg]

Requires shell-environment, awk, zip and unzip.