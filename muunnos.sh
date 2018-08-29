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

  
  

# Tämä ohjelma jönglöörää neljällä awk-skriptillä, jotka muovaavat docx-tiedostostoa (ja haluttaessa myös jpeg-tiedostosta) epub-tiedoston.

# Käytettävät muuttujat:
 ## kohde              - muunnettava docx-tiedosto.
 ## epubversio= 2 | 3 - ollaanko tekemässä EPUB 2 vai EPUB 3 -standardin mukaista tuotosta.
 ## muunnotila= 1 | 2 - käytetäänkö muotoiluissa proosan vai lyriikan asetuksia.
 ## kirjoittajat       - teoksen tekijät, oletuksena "tuntematon", saatetaan kaivaa tiedoston metatiedoista esiin.
 ## kansikuva          - mahdollisesti annettu kansikuva.
 ## tunniste           - puolisatunnainen rimpsu, kullakin teoksella ainutlaatuinen.
 ## teosnimi           - teoksen varsinainen (ei tiedoston-) nimi, saatetaan kaivaa metatiedoista, oletuksena tunniste-rimpsu.
 ## va_kansio          - Tänne menee purettu docx ja muut väliaikaiset tiedostot.
 ## kirjoituskansio    - Tänne menee menee valmistuvan epubin osaset.   
  
  
  
  

# Luetaan komentoriviparametrit muuttujiksi.  
epubversio=2
muunnostila=0
kirjoittajat="tuntematon"
while [ "$1" != "" ] 
do
    case $1 in
        -u | -o | --ulos )  ## Valmiin epubin nimi
	    shift
            valmiin_nimi=$1
            ;;
        -k | -i | --kansikuva ) ## Kansikuvatiedosto 
	    shift
            kansikuva=$1
            ;;
        -r | --runo )  ## Enimmäkseen toteuttamatta!
	    muunnostila=1
	    echo "Runomuuntimen toiminnallisuus -r valittu: teksti käsitellään säkeinä, ei kappaleina."
	    ;;
        -v3 | --versio | --epub3 )  ## Toteuttamatta!
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
        -t | --kirjoittaja ) ## Toteuttamatta!
	    shift
	    kirjoittajat=$1
	    ;;
        -n | --teos ) 
	    shift
	    teosnimi=$1 ## Toteuttamatta!
	    ;;
        * )   
            kohde=$1
    esac
    shift  
done
va_kansio=./muuntimen_kansio.${$}$(date +%N)/  # Tänne menee purettu docx ja muut väliaikaiset tiedostot.                        
kirjoituskansio=./muuntimen_kirjoituskansio.${$}$(date +%N)/ # Tänne menee menee valmistuvan epubin osaset.                                     
  mkdir $va_kansio
  mkdir $kirjoituskansio
  mkdir ${kirjoituskansio}/OEBPS
  mkdir ${kirjoituskansio}/OEBPS/css
  mkdir ${kirjoituskansio}/META-INF
  unzip -qq $kohde -d $va_kansio

  
# Muokataan kuvatiedostojen nimet sopiviksi.  
  ./mu_kuvat.awk kansio="${va_kansio}word/media/" ${va_kansio}word/_rels/document.xml.rels
  # Puretaan ennalta määrätyt tyylit open xml -muodosta epubin css:ksi.
  ./mu_tyylit.awk kansio="${kirjoituskansio}/OEBPS/css" runo="${muunnostila}" ${va_kansio}word/styles.xml
# Tehdään varsinaisesta tekstistä xhtml:ää.
  ./mu_teksti.awk kansio="${kirjoituskansio}" otsikkokansio="${va_kansio}" kansikuva="${kansikuva:-""}" ${va_kansio}word/document.xml
  tunniste=um${$}t$(date +%s) # Yksilöivä tunnus teokselle (vrt. ISBN)
  if [ -f ${va_kansio}docProps/core.xml ];  # Tarkistetaan, onko metatietoja olemassa - joillain editoreilla ei synny. Varsinaisen epubin luova mu_nidonta tarvitsee jotkin metatiedot.
  then
      cd $kirjoituskansio
      ../mu_metatiedot.awk tunniste="${tunniste}" otsikot="${va_kansio}otsikot" nimi="${kohde}" kansikuva="${kansikuva:-""}" ../${va_kansio}docProps/core.xml  # Jos metatiedot on, kaivetaan ne esiin. mu_metatiedot kutsuu mu_nidontaa suoraan. 
  else
    echo "Tiedosto ${1} ei sisällä metatietoja, muunnetaan käyttäen oletusarvoja."
    cd $kirjoituskansio
    ../mu_nidonta.awk nimeke="${teosnimi:-$tunniste}" kirjoittajat="${kirjoittajat}" tunniste="${tunniste}" kansikuva="${kansikuva:-""}" ../${va_kansio}otsikot  # Jos metatietoja ei ole, kutsutaan mu_nidontaa oletusarvoin. 
  fi  
  cd .. # Kansiossa käytiin, jotta saatiin epubiin oikeat suhteelliset polut.
  
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
