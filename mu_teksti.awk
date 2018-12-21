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


# Muovaa docx:n tekstiosuudesta xhtml-tiedostot. Jako tiedostoihin perustuu otsikkotyyleihin ja rivinsisäisiin kommentteihin.
# Saa syötteet:
#  otsikkokansio="${va_kansio}"  <- Tänne kirjoitetaan lukujen otsikot tiedostoon myöhempää vaihetta varten.
#  kansikuva="${3:-""}"          <- Kansikuva, jos sellainen on. 

BEGIN {
    OFS = ""
    ORS = ""
    FS = "<[ ]*"
    RS = ">[<]?"
    tiedostonro = 1
    suljettavat = ""
    virheet = ""  
    kirjoitettava = ""
    seuraavana_otsikko = "jep"
    kuvia_on = ""
    raportointi = 5000 
}
NR == 1      {
    kansio = kansio "/OEBPS/"
    tiedosto = kansio "1.xhtml"
    tiedoston_alkutekstit(tiedosto)
}
NR == 1      {
    if (kansikuva) {
	gsub("^(.)*\/", "", kansikuva)# Suhteellinen polku pois kansikuvasta.
	while( gsub("^[^\/]*\/", "", kansikuva) ) {   }# Suhteellinen polku pois kansikuvasta.
	print "<div class=\"d-cover\" style=\"text-align:center;\">\n<img src=\"" kansikuva "\" alt=\"Kansikuva\" height=\"100%\"/>\n</div>\n</body>\n</html>" >> tiedosto
	kannen_nimi = substr(kansikuva, 1, length(kansikuva)-4)# ".jpg" pois sisällysluettelosta.
	print "\n" kannen_nimi >> otsikkokansio "otsikot"
	++tiedostonro
	close(tiedosto)
	tiedosto = seuraava_luku_alkaa(tiedosto, tiedostonro, kansio)
    }
}
/body/       { rungossa = "jep!" }
rungossa == "" {next}  
NR == raportointi {
    print "\nKäsitelty " NR " riviä."
    raportointi += 5000
}
/[^ ]\r[^ ]/ { 
    if (seuraavana_otsikko) 
    { 
	gsub(/\r[^ ]/, " &", $1)
    }
}
/\r/         { gsub(/\r/, "<br />", $1) }
/PAGEREF/  {
    $1 = ""
    kirjoitettava = kirjoitettava "      "
}
/TOC \\/  {$1 = ""}
/w:instrText/ { $1 = "" }
/wp:align$/ { $1 = "" }
/¤¤¤o¤¤¤/   {
    seuraavana_otsikko = "jep"
    pakotettu_luku = "jep"
    gsub(/¤¤¤o¤¤¤/, "", $0)
    kirjoitettava = kirjoitettava suljettavat "</p>"
    suljettavat = ""
    kirjoitettava = hieronta(kirjoitettava, suljettavat)
    if (kirjoitettava ~ "[^ \t\n\r]+") {
	luku_loppuu(tiedosto, suljettavat, kirjoitettava)
	tiedostonro++
	tiedosto = seuraava_luku_alkaa(tiedosto, tiedostonro, kansio)
        suljettavat = kirjoitettava = ""
    }
    kirjoitettava = kirjoitettava "<p>"
}
NF > 1       { 
    if (seuraavana_otsikko) {
#        if (otsikko ~ "[^ ]$" && $1 ~ "^[^ ]") {otsikko = otsikko " "} # Tästä seuraa ylimääräisiä välilyöntejä otsikoihin.
        otsikko = otsikko "" $1 
    }
    kirjoitettava = kirjoitettava  $1 "\n"
    $0 = $2
}
/^w:p[ ](.)*\/$/  {
    kirjoitettava = kirjoitettava "<p><br /></p>"
    next
}

# uusi luku
/:pStyle w:val=\"[Hh]eading( )?1/ || /:pStyle w:val=\"[Oo]tsikko[ 1]?\"/  {
    kirjoitettava = kirjoitettava "</p>"
    seuraavana_otsikko = "jep"
    kirjoitettava = hieronta(kirjoitettava, suljettavat)
    if (kirjoitettava ~ "[^ \n\r\t]+") {
	tiedostonro++
	luku_loppuu(tiedosto, suljettavat, kirjoitettava)
	suljettavat=""
	kirjoitettava=""
	tiedosto = seuraava_luku_alkaa(tiedosto, tiedostonro, kansio)
    }
    kirjoitettava = kirjoitettava "<p class=\"h1\">"
}
# Uusi luku tai väliotsikko
/:pStyle w:val=\"Heading( )?2/ || /:pStyle w:val=\"[Oo]tsikko( )?2\"/  {
    if (h2luetteloon) {
	    kirjoitettava = kirjoitettava "</p>"
	    seuraavana_otsikko = "jep"
	    kirjoitettava = hieronta(kirjoitettava, suljettavat)
	    if (kirjoitettava ~ "[^ \n\r\t]+") {
		tiedostonro++
		luku_loppuu(tiedosto, suljettavat, kirjoitettava)
		suljettavat=""
		kirjoitettava=""
		tiedosto = seuraava_luku_alkaa(tiedosto, tiedostonro, kansio)
		kirjoitettava = kirjoitettava "<p class=\"h2\">"
	    }
    } else {
	kirjoitettava = kirjoitettava "</p><p class=\"h2\">"
    }
}

# väliotsikko
/:pStyle w:val=\"Heading( )?3/ || /:pStyle w:val=\"[Oo]tsikko( )?3\"/  {
    kirjoitettava = kirjoitettava "</p><p class=\"h3\">" }
/:pStyle w:val=\"Heading( )?4/ || /:pStyle w:val=\"[Oo]tsikko( )?4\"/  {
    kirjoitettava = kirjoitettava "</p><p class=\"h4\">" }
/:pStyle w:val=\"Heading( )?5/ || /:pStyle w:val=\"[Oo]tsikko( )?5\"/  {
    kirjoitettava = kirjoitettava "</p><p class=\"h5\">" }

# itse määriteltävät tyylit
/:pStyle w:val=\"[Tt]yyli( )?2/ || /:pStyle w:val=\"[Ss]tyle2\"/  {
    kirjoitettava = kirjoitettava "</p><p class=\"tyyli2\">" }
/:pStyle w:val=\"[Tt]yyli( )?3/ || /:pStyle w:val=\"[Ss]tyle3\"/  {
    kirjoitettava = kirjoitettava "</p><p class=\"tyyli3\">" }
/:pStyle w:val=\"[Tt]yyli( )?4/ || /:pStyle w:val=\"[Ss]tyle4\"/  {
    kirjoitettava = kirjoitettava "</p><p class=\"tyyli4\">" }
/:pStyle w:val=\"[Tt]yyli( )?5/ || /:pStyle w:val=\"[Ss]tyle5\"/  {
    kirjoitettava = kirjoitettava "</p><p class=\"tyyli5\">" }

# rivinvaihto
/w:br\// {kirjoitettava = kirjoitettava "<br />"}

# numeroidut listat
# Numeroi kaikki listat 1., 2., ... vaikka käsikirjoituksessa olisikin vaikkapa i, ii, ...
/w:numId w:val=/  {
    if (!(numeroinnit)) # Luetaan numeroinnit, jos ei vielä ole luettu.
    {
	numeroinnit = otsikkokansio "word/numbering.xml"
	while (getline rivi < numeroinnit)
	{
	    if (rivi ~ /w:abstractNum w/) 
	    {
		match(rivi, "=\"(.)+\"")
		numId = substr( rivi, RSTART +2, RLENGTH -3 ) + 0
	    }
	    if (rivi ~ /w:lvl w:ilvl/) # Uusi numerointi
	    {
		match(rivi, "=\"(.)+\"")
		listataso = substr( rivi, RSTART +2, RLENGTH -3 ) + 0
	    }
	    if (rivi ~ /w:start w:val=/ && listaformaatti != "bullet") # Luettavan numeroinnin alkuarvo
	    {
		match(rivi, "=\"(.)+\"")
		merkki = substr( rivi, RSTART +2, RLENGTH -3 )
		listamerkit[numId " " listataso] = merkki
	    }
	    if (rivi ~ /w:numFmt/) # Luettavan numeroinnin muoto
	    {
		match(rivi, "=\"(.)+\"")
		listaformaatti = substr( rivi, RSTART +2, RLENGTH -3 )
	    }
	    if (rivi ~ /w:lvlText/ && listaformaatti == "bullet") # Numeroimattoman listan listamerkki
	    {
		match(rivi, "=\"(.)+\"")
		merkki = substr( rivi, RSTART +2, RLENGTH -3 )
		listamerkit[numId " " listataso] = merkki
	    }
	}
	close(numeroinnit)
	print " \n  Alavaihe bb) suoritettu: asiakirjan numerointi luettu."
    }   
}
/w:ilvl w:val=/  {  # Uusi listataso
    match($0, "=\"(.)+\"")
    ilvl = substr( $0, RSTART +2, RLENGTH -3 )
}
/w:numId w:val=/  { # Uusi listanimi
   match($0, "=\"(.)+\"")
   numId = substr( $0, RSTART +2, RLENGTH -3 )
}
/w:numId w:val=/  { # Kirjoitetaan oikea teksti listanimen mukaisesti.
    kirjoitettava = kirjoitettava " " listamerkit[numId " " ilvl]
    if (listamerkit[numId " " ilvl]+0 != 0 || listamerkit[numId " " ilvl] == "0")
    # Numeroiduissa listoissa kasvatetaan laskurin arvoa.
    {
	if (seuraavana_otsikko == "jep") { otsikko = otsikko " " listamerkit[numId " " ilvl] ". "}
	kirjoitettava = kirjoitettava "."
	++listamerkit[numId " " ilvl]
    }
    kirjoitettava = kirjoitettava " "
}

# kappale
/^w:p$/ || /^w:p w/   {
    kirjoitettava = kirjoitettava "<p>"
}
/\/w:p$/      {
    kirjoitettava = kirjoitettava suljettavat "</p>"
    suljettavat = ""
    if (seuraavana_otsikko) {
	if (otsikko ~ /[^ \n\r\t]+/) {
	    gsub("(\n)+", " ", otsikko)
	    otsikko = "\n" otsikko
	    print otsikko "" >> otsikkokansio "otsikot"
	    otsikko = seuraavana_otsikko = pakotettu_luku = ""
	} else if (pakotettu_luku) {
	    otsikko = otsikko "eI OtSIKKOa muTTA lukuVAihTUU SIlti NYT. Kangas kultainen kumahti."
	    print otsikko "" >> otsikkokansio "otsikot"
	    otsikko = seuraavana_otsikko = pakotettu_luku = ""
	}
    }
}

# lihavointi
/w:b\//       {
    kirjoitettava = kirjoitettava "<b>"
    suljettavat = "</b>" suljettavat}

# kursiivi
/w:i\//       {
    kirjoitettava = kirjoitettava "<i>"
    suljettavat = "</i>" suljettavat}

# alleviivaus
/w:u(.)*\// && (!($0 ~ "none"))      {  # Jäljempikin testi tarpeen, koska alleviivaus arvolla "none" -> ei alleviivausta :P
    kirjoitettava = kirjoitettava "<span style=\"text-decoration:underline;\">" 
    suljettavat = "</span>" suljettavat}

# "run":in loppu - yhdellä runilla on samat tekstiominaisuudet
/\/w:r$/       { 
    kirjoitettava = kirjoitettava suljettavat
    suljettavat = ""}

# kuvat (oletuksena png, komentoriviparametrilla -jpg)
/a:blip( )+r:embed/ {
    if (!kuvia_on) {
	kuvia_on = "on"
	system("mkdir " kansio "kuvat") # Luodaan kuvakansio vasta, jos kuvia tulee vastaan.
	system("cp " otsikkokansio "word/media/*." kuvamuoto " " kansio "kuvat/")
    }
    match($0, "embed=\"[^\"]+\"")
    kuvan_id = substr($0, RSTART + 7 , RLENGTH -8)
    kirjoitettava = kirjoitettava suljettavat "<div>\n<img src=\"kuvat/" kuvan_id "." kuvamuoto "\" alt=\"\">\n</div>\n</img> \n"
    suljettavat = ""
    print "\nKuvatiedostO NyT. Oudon kAnssA AAmut astui." kuvan_id "." kuvamuoto >> otsikkokansio "otsikot"
}
END {
    if (!rungossa) {virheet = virheet  "Asiakirjalla ei ollut \"<body> ... </body>\"-rakennetta.\n"}
    kirjoitettava = hieronta(kirjoitettava, suljettavat)
    luku_loppuu(tiedosto, suljettavat, kirjoitettava)
    if (virheet) {
        print "\nTiedoston tekstin lukemisessa kohdattiin seuraavat virheet:\n" virheet
    } else {
        print "\nVaihe b) onnistui: tiedoston teksti luettiin ja luotiin " tiedostonro + 0 " otsaketta sisällysluetteloon.\n"
    }
}

# Tiedoston alkuun XHTML:n vaatima tiedostomäärittely. 
function tiedoston_alkutekstit(tiedosto) {
    print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\"" > tiedosto
    print "\n\"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">" >> tiedosto
    print  "\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n" >> tiedosto
    print "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />\n<title>" tiedostonro  >> tiedosto
    print "</title>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"css/tyylit.css\" />\n</head>" >> tiedosto
    print "\n<body>" >> tiedosto
}

# Tekstin siistiminen ennen kirjoittamista.
function hieronta(kirjoitettava, suljettavat) {
    kirjoitettava = kirjoitettava "" suljettavat
    gsub(/\n/, "", kirjoitettava) # Jos kappaleenvaihtoja eksynyt mukaan, otetaan pois.
    gsub(/<p>[ \t\f\n\r\v]*<\/p>/, "<p><br /></p>", kirjoitettava) # Tyhjät merkit pois rivinvaihtokappaleista.
    gsub(/<\/p><p><br \/><\/p><p>/, "<br /><br /></p><p>", kirjoitettava) 
    while (gsub(/<p>[<br \/>]*<\/p>$/, "", kirjoitettava)) {   } 
    gsub(/<p>[ \t\f\n\r\v]*<br \/>[ \t\f\n\r\v]*<\/p>[ \t\f\n\r\v]*<p>/, "<p>\n<br />\n", kirjoitettava)  
    gsub(/<i>(<i>)+/, "<i>", kirjoitettava) # Ylimääräiset kursiivi-...
    gsub(/<b>(<b>)+/, "<b>", kirjoitettava) # ja lihavointi-tägit pois.
    gsub(/<\/i>(<\/i>)+/, "</i>", kirjoitettava) # Ylimääräiset kursiivinsulku-...
    gsub(/<\/b>(<\/b>)+/, "</b>", kirjoitettava) # ja lihavoinninsulku-tägit pois.
    while (gsub(/<b><\/b>/, "", kirjoitettava) || gsub(/<i><\/i>/, "", kirjoitettava)) {   } # Tyhjät auki-kiinni-tägit pois.
    while (gsub(/<\/i><i>/, "", kirjoitettava) || gsub(/<\/b><b>/, "", kirjoitettava)) {   } # Turhat kiinni-auki-parit pois.
    gsub(/>/, ">\n", kirjoitettava) # Lisätään nokkien yhteyteen...
    gsub(/</, "\n<", kirjoitettava) # rivinvaihdot luettavuuden lisäämiseksi.
    gsub(/\n<b>\n/, "<b>", kirjoitettava) # Otetaan...
    gsub(/\n<i>\n/, "<i>", kirjoitettava) # ...juuri lisätyt rivinvaihdot pois...
    gsub(/\n<\/b>\n/, "</b>", kirjoitettava) # ... tägien...
    gsub(/\n<\/i>\n/, "</i>", kirjoitettava) # ...ympäriltä.
    gsub(/p></, "p>\n<", kirjoitettava) # Jos kappale alkaa...
    gsub(/><\/p/, ">\n</p", kirjoitettava) # ...tai loppuu muotoiluun, palautetaan äsken poistettu rivinvaihto.
    while (gsub(/<p[^<]*>[\n]*<\/p>/, "", kirjoitettava)) {   } # Poistaa tyhjät kappaleet.
    gsub(/>[\n]+</, ">\n<", kirjoitettava) # Poistetaan lukemista helpottavista rivinvaihdoista turhat peräkkäiset.
    gsub(/<p[^h>]*>/, "&\r", kirjoitettava) # Merkitään muiden kuin otsikkotason kappaleiden alut väliaikaisesti \r-merkillä seuraavia vaiheita varten.
    gsub(/class=\"h[1-9]?\"[^\r]+<p/, "& class=\"eka\"", kirjoitettava) # Tehdään otsikkotasoa seuraavista kappaleista "eka"-luokkaa aina ensimmäiseen \r-merkintään saakka. Siis vain ensimmäisestä otsikkotasoa seuraavasta kappaleesta tulee "eka"-luokkaa.
    gsub(/class=\"eka\"[^<>\"]+class=\"/, " class=\"eka", kirjoitettava) # Poistetaan syntyneet tuplaluokat.
    gsub(/\r/, "", kirjoitettava) # Poistetaan väliaikaiset \r-merkinnät.
    gsub(/\n[\n]+/, "\n", kirjoitettava) # Pelkkiä \n-merkkejä sisältäviin kappaleisiin jää vain yksi \n-merkki.
    gsub(/<\/p>[\t\n\r\f\v]*</, "</p>\n<", kirjoitettava) # Poistetaan ylimääräisiä (sisällön ulkopuolisia) tyhjiä merkkejä. 
    return kirjoitettava
}

# Tiedoston loppuun tulee päälle jääneiden tägien sulkimet. Sulkee tiedoston. 
function luku_loppuu(tiedosto, suljettavat, kirjoitettava) {    
    print kirjoitettava "</body>\n</html>" >> tiedosto
    close(tiedosto)
}

# Päivittää käsiteltävänä olevan tiedoston nimen ja kirjoituttaa siihen alkutekstit.
function seuraava_luku_alkaa(tiedosto, tiedostonro, kansio) {
    tiedosto = kansio tiedostonro ".xhtml"
    tiedoston_alkutekstit(tiedosto)
    return tiedosto
}
