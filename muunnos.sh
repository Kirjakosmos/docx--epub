#!/bin/sh

#Saa syötteenä arkistomuotoiden tiedoston. Toisena argumenttina voi antaa nimen epubille. Kolmantena argumenttina voi antaa jpeg-muotoisen kansikuvan.
#Pitää ajaa sudona.

  va_kansio=./muuntimen_kansio.${$}$(date +%N)/
  kirjoituskansio=./muuntimen_kirjoituskansio.${$}$(date +%N)/
  tyylikansio=./muuntimen_tyylikansio.${$}$(date +%N)/
  mkdir $va_kansio
  mkdir $kirjoituskansio
  mkdir $tyylikansio
  unzip -qq $1 -d $va_kansio

  if [ -f ${va_kansio}word/footer1.xml ];
  then
      echo "Varoitus: tiedostossa on sivunumerot (tai muu alatunniste) käytössä!"
      echo "Yritetään poistamista."
      rm ${va_kansio}word/footer1.xml
  fi

  ./mu_tyylit.awk kansio="${tyylikansio}" ${va_kansio}word/styles.xml
  ./mu_teksti.awk kansio="${kirjoituskansio}" otsikkokansio="${tyylikansio}" kansikuva="${3:-""}" ${va_kansio}word/document.xml
  tunniste=um${$}t$(date +%s)

  if [ -f ${va_kansio}docProps/core.xml ];
  then
    ./mu_metatiedot.awk kansio="${kirjoituskansio}" tunniste="${tunniste}" tyylit="${tyylikansio}tyylit.css" otsikot="${tyylikansio}otsikot" nimi="${1}" kansikuva="${3:-""}" ${va_kansio}docProps/core.xml  
  else
    echo "Tiedosto ${1} ei sisällä metatietoja, muunnetaan käyttäen oletusarvoja."
    python muunneltu_Harrin_skripti.py $kirjoituskansio --identifier $tunniste --title $tunniste --styles ${tyylikansio}tyylit.css --otsikot ${tyylikansio}otsikot
  fi

  rm -rf $va_kansio
  rm -rf $kirjoituskansio
  rm -rf $tyylikansio
  mv out.epub ${2:-Uusi_muste$(date +%j)${$}}.epub
echo "Valmis epub: ${2:-Uusi_muste$(date +%j)${$}}.epub"

