#!/usr/bin/awk -f
#Ohjelma muuntaa Wordin xml-tiedoston xhtml-tiedostoiksi.

BEGIN {
    OFS = ""
    ORS = ""
    FS = "<[ ]*"
    RS = ">[<]?"
    tiedostonro = 1
    tiedosto = tiedostonro ".xhtml"
    suljettavat = ""
    virheet = ""  
    kirjoitettava = ""
    seuraavana_otsikko = "jep"
}

NR == 1      {tiedosto = kansio tiedosto; tiedoston_alkutekstit(tiedosto)}
NR == 1      { if (kansikuva != "" ){
  print "<div class=\"d-cover\" style=\"text-align:center;\">\n<img src=\"" kansikuva "\" alt=\"image\" height=\"100%\"/>\n</div>\n</body>\n</html>" >> tiedosto
  kannen_nimi = substr(kansikuva, 1, length(kansikuva)-4)
  gsub("^(.)*\/", "", kannen_nimi )
  print "\n" kannen_nimi >> otsikkokansio "otsikot"

  tiedostonro++
  close(tiedosto)
  tiedosto = seuraava_luku_alkaa(tiedosto, tiedostonro, kansio)
}
}

/body/       {rungossa = "jep!"}

rungossa == "" {next}  

/[^ ]\r[^ ]/ {gsub(/\r[^ ]/, " &", $1)}
/\r/         {gsub(/\r/, "<br/>", $1)}

/PAGEREF/  {$1 = ""; kirjoitettava = kirjoitettava "      "}
/TOC \\/  {$1 = ""}
/w:instrText/ { $1 = "" }
/wp:align$/ { $1 = "" }


NF>1         { 
    if (seuraavana_otsikko == "jep"){
        if (otsikko ~ "[^ ]$" && $1 ~ "^[^ ]") {otsikko = otsikko " "}
        otsikko = otsikko "" $1 
    }    
    kirjoitettava = kirjoitettava  $1 "\n"; $0 = $2;
}

/^w:p[ ](.)*\/$/  {kirjoitettava = kirjoitettava "<p><br/></p>"; next}

# uusi luku
/:pStyle w:val=\"[Hh]eading1/ || /:pStyle w:val=\"[Oo]tsikko[ 1]?\"/  {
     kirjoitettava = kirjoitettava "</p>"
     seuraavana_otsikko = "jep"
     if (eka=="mennyt"){
         tiedostonro++;
         luku_loppuu(tiedosto, suljettavat,kirjoitettava); suljettavat=""; kirjoitettava=""
         tiedosto = seuraava_luku_alkaa(tiedosto, tiedostonro, kansio)
     } else {eka = "mennyt"}
     kirjoitettava = kirjoitettava "<p class=\"h1\">"
}

# väliotsikko
/:pStyle w:val=\"Heading2/ || /:pStyle w:val=\"[Oo]tsikko( )?2\"/  {
     kirjoitettava = kirjoitettava "</p><p class=\"h2\">" }

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
/w:br\// {kirjoitettava = kirjoitettava "<br/>"}

# kappale
/^w:p$/ || /^w:p w/   {kirjoitettava = kirjoitettava "<p>"}
/\/w:p$/      {kirjoitettava = kirjoitettava suljettavat "</p>"; suljettavat = ""
    if (seuraavana_otsikko == "jep"){
        gsub("(\n)+"," ",otsikko)
        otsikko = "\n" otsikko
        print otsikko "" >> otsikkokansio "otsikot"
        otsikko = seuraavana_otsikko = ""
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
    print "</title>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"css/style.css\" />\n</head>" >> tiedosto
    print "\n<body>" >> tiedosto
}

# Tiedoston loppuun tulee päälle jääneiden tägien sulkimet. Sulkee tiedoston.
function luku_loppuu(tiedosto, suljettavat, kirjoitettava){
# hierotaan tekstiä siistimmäksi
    kirjoitettava = kirjoitettava "" suljettavat
    gsub(/\n/,"",kirjoitettava)
    gsub(/>[ \s]+</,"><",kirjoitettava)
    gsub(/<p>[ \t\f\n\r\v]*<br\/>[ \t\f\n\r\v]*<\/p>[ \t\f\n\r\v]*<p>/,"<p>\n<br/>\n",kirjoitettava)  
    while (gsub(/<b><\/b>/,"",kirjoitettava) || gsub(/<i><\/i>/,"",kirjoitettava)) {    }
    while (gsub(/<\/i><i>/,"",kirjoitettava) || gsub(/<\/b><b>/,"",kirjoitettava)) { }
    gsub(/<i>(<i>)+/,"<i>",kirjoitettava)
    gsub(/<b>(<b>)+/,"<b>",kirjoitettava)
    gsub(/<\/i>(<\/i>)+/,"</i>",kirjoitettava)
    gsub(/<\/b>(<\/b>)+/,"</b>",kirjoitettava)
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
    gsub(/<p>/,"<p>\r",kirjoitettava)
    gsub(/class=\"h[1-9]?\"[^\r]+<p/,"& class=\"eka\"",kirjoitettava)
    gsub(/\r/,"",kirjoitettava)
    gsub(/\n[\n]{1,}/,"\n",kirjoitettava)
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
