#!/usr/bin/awk -f

#    Uuden musteen muunnin. Converts docx-files to epub-files. Written for www.uusimuste.fi
#    Copyright (C) 2016 Matti Palomäki
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

BEGIN {
    ORS = ""
    tiedosto = "META-INF/container.xml"
    print "<?xml version=\"1.0\"?>\n<container version=\"1.0\" xmlns=\"urn:oasis:names:tc:opendocument:xmlns:container\">\n\n    <rootfiles>\n        <rootfile full-path=\"OEBPS/Content.opf\" media-type=\"application/oebps-package+xml\"/>\n    </rootfiles>\n</container>" >> tiedosto
    close(tiedosto)
    
    tiedosto = "mimetype"
    print "application/epub+zip" >> tiedosto
    close(tiedosto)
    manifest = "<item id=\"ncx\" href=\"toc.ncx\" media-type=\"application/x-dtbncx+xml\"/>"
    manifest = manifest "\n    <item id=\"stylesheet\" href=\"css/tyylit.css\" media-type=\"text/css\"/>"
}
/eI OtSIKKOa muTTA lukuVAihTUU SIlti NYT. Kangas kultainen kumahti./ {
    ++luku
    ++piilolukuja
    manifest = manifest "\n    <item id=\"file_" luku "\" href=\"" luku ".xhtml\" media-type=\"application/xhtml+xml\" />"
    spine = spine "\n    <itemref idref=\"file_" luku "\" />"
    $0 = " "
}
/[^ \n\r\t]+/    {
    ++luku
    manifest = manifest "\n    <item id=\"file_" luku "\" href=\"" luku ".xhtml\" media-type=\"application/xhtml+xml\" />"
    spine = spine "\n    <itemref idref=\"file_" luku "\" />"
    navpointit = navpointit "    <navPoint id=\"file_" luku "\" playOrder=\"" (luku - piilolukuja) "\">\n      <navLabel><text>" $0 "</text></navLabel>\n      <content src=\"" luku ".xhtml\" />\n    </navPoint>\n"
}
END {
    if (luku == 0) 
    { 
	print "Varoitus! Otsikoita ei ole!\n"
	manifest = manifest "\n    <item id=\"file_1\" href=\"1.xhtml\" media-type=\"application/xhtml+xml\" />"
	spine = spine "\n    <itemref idref=\"file_1\" />"
	navpointit = navpointit "    <navPoint id=\"file_1\" playOrder=\"1\">\n      <navLabel><text>...</text></navLabel>\n      <content src=\"1.xhtml\" />\n    </navPoint>\n"
    }
    if (kansikuva) {
	alk_kansikuva = kansikuva
	gsub("^(.)*\/", "", kansikuva)
        system("cp ../" alk_kansikuva " OEBPS/" kansikuva)
        manifest = manifest "\n    <item id=\"cover\" href=\"" kansikuva  "\" media-type=\"image/jpeg\"/>"
    }
    
    tiedosto = "OEBPS/Content.opf"
    printf("<package version=\"2.0\" xmlns=\"http://www.idpf.org/2007/opf\" unique-identifier=\"tunniste\">\n  <metadata xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:opf=\"http://www.idpf.org/2007/opf\">\n    <dc:title>%s</dc:title>\n    <dc:language>%s</dc:language>\n    <dc:creator>%s</dc:creator>\n    <dc:identifier id=\"tunniste\">%s</dc:identifier>\n    <meta name=\"cover\" content=\"cover-image\" />\n  </metadata>\n  <manifest>\n    %s\n  </manifest>\n  <spine xmlns=\"http://www.idpf.org/2007/opf\" toc=\"ncx\">\n    %s\n  </spine>\n</package>", nimeke, "fi", kirjoittajat, tunniste, manifest, spine) >> tiedosto
    close(tiedosto)
    tiedosto = "OEBPS/toc.ncx"
    printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE ncx PUBLIC \"-//NISO//DTD ncx 2005-1//EN\"\n\"http://www.daisy.org/z3986/2005/ncx-2005-1.dtd\">\n\n<ncx version=\"2005-1\" xml:lang=\"en\" xmlns=\"http://www.daisy.org/z3986/2005/ncx/\">\n\n  <head>\n    <meta name=\"dtb:uid\" content=\"%s\"/> \n    <meta name=\"dtb:depth\" content=\"1\"/> \n    <meta name=\"dtb:totalPageCount\" content=\"0\"/> \n    <meta name=\"dtb:maxPageNumber\" content=\"0\"/> \n  </head>\n\n  <docTitle>\n    <text>%s</text>\n  </docTitle>\n\n  <docAuthor>\n    <text>%s</text>\n  </docAuthor>\n\n  <navMap>\n%s  </navMap>\n\n</ncx>", tunniste, nimeke, kirjoittajat, navpointit) >> tiedosto
    close(tiedosto)
    system("zip -rDq0X ../" tunniste ".epub mimetype")
    system("zip -rqgD0X ../" tunniste ".epub * -x mimetype")
    print "Vaihe d) onnistui: epub luotiin.\n"
}
