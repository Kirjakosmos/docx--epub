#!/bin/sh

# Uudelleennimeää kansion epubit metatietoihin (oikeastaan kaikki b:hen päättyvät tiedostot) niiden tiedostonimen mukaiseksi.

if [ -d OEBPS ] 
then echo "Kansio OEBPS on jo olemassa ja tyhjenisi! Keskeytys."; exit 1;
fi


ls *b | \
while read -r avattava; do
    unzip  -qq $avattava OEBPS/Content.opf
    awk '/<dc:title>(.)+<\/dc:title>/ {
         gsub(/<dc:title>(.)+<\/dc:title>/,"<dc:title>" tiedostonimi "</dc:title>")
                                     } 
              {
               kirjoitettava = kirjoitettava "\n" $0
              }
         END {
              print "" kirjoitettava > "OEBPS/Content.opf"
             } 
         ' tiedostonimi=$avattava OEBPS/Content.opf
    zip -rq0X $avattava OEBPS/Content.opf
    rm -rf OEBPS/*
done

rm -rf OEBPS/
