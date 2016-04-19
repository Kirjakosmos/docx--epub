#!/usr/bin/awk -f

#Tekstin hieronta omaksi funktiokseen!
#Hieronnan jalkeen tarkistus, onko mitaan kirjoitettavaa. 
#Tiedostonumeron kasvattaminen vasta tarkastusten jalkeen.


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
    raportointi = 5000;
}

NR == 1      { kansio = kansio "/OEBPS/"; tiedosto = kansio "1.xhtml"; tiedoston_alkutekstit(tiedosto)}
NR == 1      { if (kansikuva) {
	print "<div class=\"d-cover\" style=\"text-align:center;\">\n<img src=\"" kansikuva "\" alt=\"image\" height=\"100%\"/>\n</div>\n</body>\n</html>" >> tiedosto
	kannen_nimi = substr(kansikuva, 1, length(kansikuva)-4)
	gsub("^(.)*\/", "", kannen_nimi )
	print "\n" kannen_nimi >> otsikkokansio "otsikot"

	tiedostonro++
	close(tiedosto)
	tiedosto = seuraava_luku_alkaa(tiedosto, tiedostonro, kansio)
    }
}

/body/       { rungossa = "jep!" }

rungossa == "" {next}  

NR == raportointi {print "\nKäsitelty " NR " riviä."; raportointi += 5000}

/[^ ]\r[^ ]/ { if (seuraavana_otsikko == "jep"){ gsub(/\r[^ ]/, " &", $1) } }
/\r/         { gsub(/\r/, "<br />", $1) }

/PAGEREF/  {$1 = ""; kirjoitettava = kirjoitettava "      "}
/TOC \\/  {$1 = ""}
/w:instrText/ { $1 = "" }
/wp:align$/ { $1 = "" }

/¤¤¤o¤¤¤/   { seuraavana_otsikko = "jep"
    gsub(/¤¤¤o¤¤¤/, "", $0)
    if (eka=="mennyt"){
	gsub(/<p>$/,"",kirjoitettava)
	if (kirjoitettava) {
	    kirjoitettava = hieronta(kirjoitettava, suljettavat)
	    if (kirjoitettava ~ "[^ \t\n\r]+") {
		luku_loppuu(tiedosto, suljettavat,kirjoitettava)
		tiedosto = seuraava_luku_alkaa(tiedosto, tiedostonro, kansio)
		tiedostonro++;
	    }
	}
	suljettavat=""; kirjoitettava=""
    } else {eka = "mennyt"}
    kirjoitettava = kirjoitettava "<p>"
}

NF>1         { 
    if (seuraavana_otsikko == "jep") {
        if (otsikko ~ "[^ ]$" && $1 ~ "^[^ ]") {otsikko = otsikko " "
	}
        otsikko = otsikko "" $1 
    } 
    kirjoitettava = kirjoitettava  $1 "\n"; $0 = $2;
}

/^w:p[ ](.)*\/$/  {kirjoitettava = kirjoitettava "<p><br /></p>"; next}

# uusi luku
/:pStyle w:val=\"[Hh]eading( )?1/ || /:pStyle w:val=\"[Oo]tsikko[ 1]?\"/  {
     kirjoitettava = kirjoitettava "</p>"
     seuraavana_otsikko = "jep"
     if (eka=="mennyt"){
	 kirjoitettava = hieronta(kirjoitettava, suljettavat)
	 if (kirjoitettava ~ "[^ \n\r\t]+") {
	     tiedostonro++;
	     luku_loppuu(tiedosto, suljettavat,kirjoitettava)
	     suljettavat=""
	     kirjoitettava=""
	     tiedosto = seuraava_luku_alkaa(tiedosto, tiedostonro, kansio)
	 }
     } else {eka = "mennyt"}
     kirjoitettava = kirjoitettava "<p class=\"h1\">"
}

# väliotsikko
/:pStyle w:val=\"Heading( )?2/ || /:pStyle w:val=\"[Oo]tsikko( )?2\"/  {
     kirjoitettava = kirjoitettava "</p><p class=\"h2\">" }
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

#lista, ei lopullinen
/w:numId w:val=/  {
    lista++
    kirjoitettava = kirjoitettava " " lista ". "
    if (seuraavana_otsikko == "jep") { otsikko = otsikko " " lista ". "}
    }

# kappale
/^w:p$/ || /^w:p w/   {kirjoitettava = kirjoitettava "<p>"}
/\/w:p$/      {kirjoitettava = kirjoitettava suljettavat "</p>"; suljettavat = ""
    if (seuraavana_otsikko == "jep"){
        gsub("(\n)+"," ",otsikko)
        otsikko = "\n" otsikko
        print otsikko "" >> otsikkokansio "otsikot"
        otsikko = seuraavana_otsikko = ""
	eka = "mennyt"
    }
}

# lihavointi
/w:b\//       {kirjoitettava = kirjoitettava "<b>"
               suljettavat = "</b>" suljettavat}
# kursiivi
/w:i\//       {kirjoitettava = kirjoitettava "<i>"
    suljettavat = "</i>" suljettavat}
# alleviivaus
/w:u(.)*\//       {kirjoitettava = kirjoitettava "<u>"
    suljettavat = "</u>" suljettavat}

/\/w:t/       {kirjoitettava = kirjoitettava suljettavat; suljettavat = ""}


END {
    if (rungossa=="") {virheet = virheet  "Asiakirjalla ei ollut \"<body> ... </body>\"-rakennetta.\n"}
    if (eka=="") {virheet = virheet  "Huom! Asiakirjasta ei löytynyt lainkaan otsikoita.\n"}
    kirjoitettava = hieronta(kirjoitettava, suljettavat)
    luku_loppuu(tiedosto, suljettavat, kirjoitettava)
    if (virheet == ""){
        print "\nVaihe b) onnistui: tiedoston teksti luettiin ja luotiin " tiedostonro + 0 " otsaketta sisällysluetteloon.\n"
    } else {
        print "\nTiedoston tekstin lukemisessa kohdattiin seuraavat virheet:\n" virheet
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

function hieronta(kirjoitettava, suljettavat) {
    kirjoitettava = kirjoitettava "" suljettavat
    gsub(/\n/,"",kirjoitettava)
    gsub(/>[ \s]+</,"><",kirjoitettava)
    gsub(/<p>[ \t\f\n\r\v]*<br \/>[ \t\f\n\r\v]*<\/p>[ \t\f\n\r\v]*<p>/,"<p>\n<br />\n",kirjoitettava)  
    gsub(/<i>(<i>)+/,"<i>",kirjoitettava)
    gsub(/<b>(<b>)+/,"<b>",kirjoitettava)
    gsub(/<\/i>(<\/i>)+/,"</i>",kirjoitettava)
    gsub(/<\/b>(<\/b>)+/,"</b>",kirjoitettava)
    while (gsub(/<b><\/b>/,"",kirjoitettava) || gsub(/<i><\/i>/,"",kirjoitettava)) {    } # Ongelmia aiemmassa sijainnissa.
    while (gsub(/<\/i><i>/,"",kirjoitettava) || gsub(/<\/b><b>/,"",kirjoitettava)) { } # Ongelmia aiemmassa sijainnissa.
    gsub(/>/,">\n",kirjoitettava)
    gsub(/</,"\n<",kirjoitettava)
    gsub(/h1\">\n/,"h1\">",kirjoitettava)
    gsub(/\n<b>\n/,"<b>",kirjoitettava)
    gsub(/\n<i>\n/,"<i>",kirjoitettava)
    gsub(/\n<\/b>\n/,"</b>",kirjoitettava)
    gsub(/\n<\/i>\n/,"</i>",kirjoitettava)
    gsub(/p></,"p>\n<",kirjoitettava)
    gsub(/><\/p/,">\n</p",kirjoitettava)
    while (gsub(/<p>[\n]*<\/p>/,"",kirjoitettava)) { }
    gsub(/>[\n]+</,">\n<",kirjoitettava)
    gsub(/<p[^h>]*>/,"&\r",kirjoitettava)
    gsub(/class=\"h[1-9]?\"[^\r]+<p/,"& class=\"eka\"",kirjoitettava)
#    gsub(/class=\"eka\"[^<>\"]+class=\"[^<>]*\"/," class=\"eka\"",kirjoitettava)
    gsub(/class=\"eka\"[^<>\"]+class=\"/," class=\"eka",kirjoitettava)
    gsub(/\r/,"",kirjoitettava)
    gsub(/\n[\n]{1,}/,"\n",kirjoitettava)
    return kirjoitettava
}

# Tiedoston loppuun tulee päälle jääneiden tägien sulkimet. Sulkee tiedoston.
function luku_loppuu(tiedosto, suljettavat, kirjoitettava){
    #Sitten kirjoitetaan tiedostoon.
    print kirjoitettava "</body>\n</html>" >> tiedosto
    close(tiedosto)
}

# Päivittää käsiteltävänä olevan tiedoston nimen, kirjoituttaa siihen alkutekstit.
function seuraava_luku_alkaa(tiedosto, tiedostonro, kansio){
    tiedosto = kansio tiedostonro ".xhtml"
    tiedoston_alkutekstit(tiedosto)
    return tiedosto
}
