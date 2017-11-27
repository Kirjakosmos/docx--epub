#!/bin/sh

# Etsii kansion epubeista tietynnimisen metatietojen mukaan.

if [ -d OEBPS ] 
then echo "Kansio OEBPS on jo olemassa ja tyhjenisi! Keskeytys."; exit 1;
fi

ls *b | \
while read -r avattava; do
    unzip  -qq $avattava OEBPS/Content.opf
    awk '/<dc:title>(.)+<\/dc:title>/ {
         if (index($0,etsittava))
                  {
                   print "Löytyi, " nimi
                  }
                                     } 
         ' etsittava=$1 nimi=$avattava OEBPS/Content.opf
    rm -rf OEBPS/*
done

rm -rf OEBPS/
