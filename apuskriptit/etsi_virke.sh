#!/bin/sh

# Etsii kansion docx-tiedostoista annettua sanaa. Jos se tulee vastaan, tulostaa tiedostonimen ja kyseisen rivin.

if [ -d word ] 
then echo "Kansio OEBPS on jo olemassa ja tyhjenisi! Keskeytys."; exit 1;
fi


ls *x | \
while read -r avattava; do
    unzip  -qq $avattava 
    awk 'BEGIN {
    OFS = ""
    ORS = ""
    FS = "<[ ]*"
    RS = ">[<]?"
               }
    NF > 1     { 
         if (index($0,etsittava))
                  {
               print "Löytyi, " nimi "\n" $1
                  }
               }
         ' etsittava=$1 nimi=$avattava word/document.xml
    rm -rf word/*
done

rm -rf word/
