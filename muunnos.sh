#!/bin/sh

#    Uuden musteen muunnin. Converts docx-files to epub-files.
#    Copyright (C) 2016 Matti Palomäki
#
#	This program is free software: you can redistribute it and/or modify
#	    it under the terms of the GNU General Public License as published by
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

  va_kansio=./muuntimen_kansio.${$}$(date +%N)/ 
  kirjoituskansio=./muuntimen_kirjoituskansio.${$}$(date +%N)/ 
  mkdir $va_kansio
  mkdir $kirjoituskansio
  mkdir ${kirjoituskansio}/OEBPS
  mkdir ${kirjoituskansio}/OEBPS/css
  mkdir ${kirjoituskansio}/META-INF
  unzip -qq $1 -d $va_kansio
  
  ./mu_tyylit.awk kansio="${kirjoituskansio}/OEBPS/css" ${va_kansio}word/styles.xml
  
  ./mu_teksti.awk kansio="${kirjoituskansio}" otsikkokansio="${va_kansio}" kansikuva="${3:-""}" ${va_kansio}word/document.xml
  tunniste=um${$}t$(date +%s) 
  if [ -f ${va_kansio}docProps/core.xml ];  
  then
      cd $kirjoituskansio
    ../mu_metatiedot.awk tunniste="${tunniste}" otsikot="${va_kansio}otsikot" nimi="${1}" kansikuva="${3:-""}" ../${va_kansio}docProps/core.xml  
  else
    echo "Tiedosto ${1} ei sisällä metatietoja, muunnetaan käyttäen oletusarvoja."
    cd $kirjoituskansio
    ./mu_nidonta nimeke="{$tunniste}" kirjoittajat="tuntematon" tunniste="${tunniste}" nimi="${1}" kansikuva="${3:-""}" ../${va_kansio}otsikot  
  fi  
  cd .. 
  
  rm -rf $va_kansio
  rm -rf $kirjoituskansio 
  if [ -f ./${tunniste}.epub ]; 
  then
      mv ${tunniste}.epub ${2:-Uusi_muste$(date +%j)${$}}.epub 
      echo "Valmis epub: ${2:-Uusi_muste$(date +%j)${$}}.epub"
  else
      echo "Muunnoksessa jokin meni vikaan."
      echo "Epubia ei luotu."
      echo "Huomaa oikea muotoilu:"
      echo "./muunnos.sh muunnettava.docx haluttu_nimi mahdollinen_kansikuva.jpg"
  fi
