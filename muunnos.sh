#!/bin/sh

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

  
  
  
  
  
  
  
  
  
epubversio=2
muunnostila=1
kirjoittajat="tuntematon"
while [ "$1" != "" ] 
do
    case $1 in
        -u | -o | --ulos )  
	    shift
            valmiin_nimi=$1
            ;;
        -k | -i | --kansikuva ) 
	    shift
            kansikuva=$1
            ;;
        -r | --runo )  
	    shift
	    muunnostila=2
	    echo "Epubia ei luotu."
	    echo "Runomuuntimen toiminnallisuus on vielä työn alla."
            exit 1
	    ;;
        -v3 | --versio | --epub3 )  
	    epubversio=3
	    echo "HUOMIO! Toistaiseksi muunnin tuottaa vain EPUB 2 -standardin mukaisia epubeja, EPUB 3 -standardi on työn alla!"
	    ;;
        -v2 | --epub2 )
	    epubversio=2
	    ;;
        -h | --info | --ohje | --help )
	    echo "Epubia ei luotu."
	    echo "Huomaa oikea käyttö:"
	    echo "./muunnos.sh  muunnettava.docx -u haluttu_nimi -k mahdollinen_kansikuva.jpg"
            exit 1
	    ;;
        -t | --kirjoittaja ) 
	    shift
	    kirjoittajat=$1
	    ;;
        -n | --teos ) 
	    shift
	    teosnimi=$1
	    ;;
        * )   
            kohde=$1
    esac
    shift  
done
  va_kansio=./muuntimen_kansio.${$}$(date +%N)/ 
  kirjoituskansio=./muuntimen_kirjoituskansio.${$}$(date +%N)/ 
  mkdir $va_kansio
  mkdir $kirjoituskansio
  mkdir ${kirjoituskansio}/OEBPS
  mkdir ${kirjoituskansio}/OEBPS/css
  mkdir ${kirjoituskansio}/META-INF
  unzip -qq $kohde -d $va_kansio
  
  ./mu_kuvat.awk kansio="${va_kansio}word/media/" ${va_kansio}word/_rels/document.xml.rels
  
  ./mu_tyylit.awk kansio="${kirjoituskansio}/OEBPS/css" ${va_kansio}word/styles.xml
  
  ./mu_teksti.awk kansio="${kirjoituskansio}" otsikkokansio="${va_kansio}" kansikuva="${kansikuva:-""}" ${va_kansio}word/document.xml
  tunniste=um${$}t$(date +%s) 
  if [ -f ${va_kansio}docProps/core.xml ];  
  then
      cd $kirjoituskansio
    ../mu_metatiedot.awk tunniste="${tunniste}" otsikot="${va_kansio}otsikot" nimi="${kohde}" kansikuva="${kansikuva:-""}" ../${va_kansio}docProps/core.xml  
  else
    echo "Tiedosto ${1} ei sisällä metatietoja, muunnetaan käyttäen oletusarvoja."
    cd $kirjoituskansio
    ./mu_nidonta.awk nimeke="${teosnimi:-$tunniste}" kirjoittajat="${kirjoittajat}" tunniste="${tunniste}" kansikuva="${kansikuva:-""}" ../${va_kansio}otsikot  
  fi  
  cd .. 
  
  rm -rf $va_kansio
  rm -rf $kirjoituskansio 
  if [ -f ./${tunniste}.epub ]; 
  then
      mv ${tunniste}.epub ${valmiin_nimi:-Uusi_muste$(date +%j)${$}}.epub
      echo "Valmis epub: ${valmiin_nimi:-Uusi_muste$(date +%j)${$}}.epub"
  else
      echo "Muunnoksessa jokin meni vikaan."
      echo "Epubia ei luotu."
      echo "Huomaa oikea muotoilu:"
      echo "./muunnos.sh muunnettava.docx -u haluttu_nimi -k mahdollinen_kansikuva.jpg"
  fi
