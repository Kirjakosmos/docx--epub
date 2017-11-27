#!/bin/sh

# Kirjoittaa tiedostoon kansion docx-tiedostojen ensirivit.

if [ -d kurkistuskansio ] 
then echo "Kansio kurkistuskansio on jo olemassa ja tuhoutuisi! Lopetetaan."; exit 1;
fi
mkdir kurkistuskansio

ls *x | \
while read -r avattava; do
    unzip  -qq $avattava -d kurkistuskansio
    awk ' BEGIN  {
                  FS = "<[ ]*"
                  RS = ">[<]?"
                  ORS = ""
                 }
          NF > 1 && $1 ~ /[a-öA-Ö]+/ && $1 !~ /center/ {
                      print $1 "\n"  >> "docxien_alut.txt";
                      if (toka==3) {
                                 print "  " tunniste "\n\n" >> "docxien_alut.txt";
                                 exit;
                                }
                      ++toka;
                 } 
         ' tunniste=$avattava kurkistuskansio/word/document.xml 
    rm -rf kurkistuskansio/*
done

echo "Word-tiedostojen alut on nyt kirjoitettu tiedostoon docxien_alut.txt."
