import zipfile
import argparse
import os

index_tpl = '''<package version="2.0" xmlns="http://www.idpf.org/2007/opf" unique-identifier="tunniste">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
    <dc:title>%(title)s</dc:title>
    <dc:language>%(language)s</dc:language>
    <dc:creator>%(authors)s</dc:creator>
    <dc:identifier id="tunniste">%(identifier)s</dc:identifier>
    <meta name="cover" content="cover-image" />
  </metadata>
  <manifest>
    %(manifest)s
  </manifest>
  <spine xmlns="http://www.idpf.org/2007/opf" toc="ncx">
    %(spine)s
  </spine>
</package>'''

toc_tpl = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN"
"http://www.daisy.org/z3986/2005/ncx-2005-1.dtd">

<ncx version="2005-1" xml:lang="en" xmlns="http://www.daisy.org/z3986/2005/ncx/">

  <head>
    <meta name="dtb:uid" content="%(identifier)s"/> 
    <meta name="dtb:depth" content="1"/> 
    <meta name="dtb:totalPageCount" content="0"/> 
    <meta name="dtb:maxPageNumber" content="0"/> 
  </head>

  <docTitle>
    <text>%(title)s</text>
  </docTitle>

  <docAuthor>
    <text>%(authors)s</text>
  </docAuthor>

  <navMap>
%(navpointit)s  </navMap>

</ncx>'''

def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("--styles")
    parser.add_argument("--identifier")
    parser.add_argument("--lang", default="fi")
    parser.add_argument("--title", default="nimi puuttuu")
    parser.add_argument("--authors", default="tuntematon")
    parser.add_argument("--output")
    parser.add_argument("--otsikot")
    parser.add_argument("--kansikuva")

    args = parser.parse_args()
    output = "out.epub"
    if args.output:
        output = args.output
    epub = zipfile.ZipFile(output, 'w')
    epub.writestr("mimetype", "application/epub+zip")
    epub.writestr(
        "META-INF/container.xml",
        '''<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">

    <rootfiles>
        <rootfile full-path="OEBPS/Content.opf" media-type="application/oebps-package+xml"/>
    </rootfiles>
</container>''')

    if args.otsikot:
        with open(args.otsikot, 'r') as tiedostossa:
            luetut = tiedostossa.read()
            lukujen_nimet = luetut.splitlines()
    manifest = '<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>'
    if args.styles:
        manifest += '\n    <item id="stylesheet" href="css/style.css" media-type="text/css"/>'
    if args.kansikuva:
        epub.write(args.kansikuva, 'OEBPS/%s' % args.kansikuva)
        manifest += '\n    <item id="cover" href="OEBPS/%s" media-type="image/jpeg"/>' % args.kansikuva
    spine = ""
    navpointit = ""
    for directory, _, files in os.walk(args.input):
        for i, html in enumerate(files):
            otsikko = i + 1
            if args.otsikot:
                otsikko = lukujen_nimet[i + 1]
            basename = os.path.basename(directory + html)
            manifest += '\n    <item id="file_%s" href="%s.xhtml" media-type="application/xhtml+xml" />' % (i + 1, i + 1)
            spine += '\n    <itemref idref="file_%s" />' % (i + 1)
            navpointit += '''    <navPoint id="file_%s" playOrder="%s">
      <navLabel><text>%s</text></navLabel>
      <content src="%s.xhtml" />
    </navPoint>
''' % (i + 1, i + 1, otsikko, i + 1)
            epub.write("%s/%s" % (directory, html), 'OEBPS/' + basename)
            
    epub.writestr(
        'OEBPS/Content.opf',
        index_tpl % {
            'authors': args.authors,
            'title': args.title,
            'language': args.lang,
            'manifest': manifest,
            'spine': spine,
            'identifier': args.identifier,
        }
    )

    if args.styles:
        epub.write(args.styles, 'OEBPS/css/style.css')

    epub.writestr(
        "OEBPS/toc.ncx",
        toc_tpl % {
        'authors': args.authors,
        'title': args.title,
        'identifier': args.identifier,
        'navpointit': navpointit,
        }
    )

if __name__ == '__main__':
    main()
