#!/usr/bin/awk -f
# Kirjoittaa epubin tyylitiedoston syötteen perusteella. Syötteessä arvo muuttujalle "kansio", jonka nimeämään kansioon tuotos kirjoitetaan.
BEGIN {
    RS = "><"
    ORS = " "
    css = ""
}

#Otsikot
/w:style.*paragraph.*styleId=\"[Hh]eading1\"/ || /w:style.*paragraph.*styleId=\"[Oo]tsikko[ 1]?\"/ {
    css = css "p.h1 {"
    kirjoitetaan = "joo"
}

#Alaotsikot
/w:style.*paragraph.*styleId=\"[Hh]eading2\"/ || /w:style.*paragraph.*styleId=\"[Oo]tsikko( )?2\"/ {
    css = css "p.h2 {"
    kirjoitetaan = "joo"
}

#Vapaasti määriteltävät ylimääräiset tyylit
/w:style.*paragraph.*styleId=\"[Tt]yyli( )?2\"/ || /w:style.*paragraph.*styleId=\"[Ss]tyle2\"/ {
    css = css "p.tyyli2 {"
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Tt]yyli( )?3\"/ || /w:style.*paragraph.*styleId=\"[Ss]tyle3\"/ {
    css = css "p.tyyli3 {"
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Tt]yyli( )?4\"/ || /w:style.*paragraph.*styleId=\"[Ss]tyle4\"/ {
    css = css "p.tyyli4 {"
    kirjoitetaan = "joo"
}

#leipäteksti
/w:style.*paragraph.*styleId=\"[Ll]eip[äa]teksti\"/ {
    css = css "p {"
    kirjoitetaan = "joo"
}

{if (kirjoitetaan != "joo") {next}}
#Tästä eteenpäin mennään vain, jos luetaan tunnistettua tyyliä.

#fonttikoko
/w:sz (.)*val=/ {match($0, /val=\"[0-9]*\"/); koko = substr($0,RSTART+5,RLENGTH-6); koko = koko/24*100 ; css = css "font-size: " koko  "%;\n"}

#tekstin ryhmittäminen
/:jc w:val=\"center\"/ {css = css "text-align: center;"}
/:jc w:val=\"right\"/ {css = css "text-align: right;"}
/:jc w:val=\"left\"/ {css = css "text-align: left;"}
/:jc w:val=\"both\"/ {css = css "text-align: justify;"}

#sisennys
/\/w:ind w:left=\"[^0"]+/ {css = css "margin-left: 0.6em\n"}

#välistys
/spacing(.)*w:line=\"[1-9]+/ {css = css "line-height: 1.0 ;\n"}

#kappaleenvälit
/spacing(.)*w:before=\"[1-9]+/ {css = css "margin-top: 0.6em ;\n"}
/spacing(.)*w:after=\"[1-9]+/ {css = css "margin-bottom: 0.6em ;\n"}

#lihavoinnit yms.
/w:b\//	{css = css "font-weight: bold ;\n"}
/w:i\//	{css = css "font-style: italic ;\n"}

#tyylin loppu
/\/w:style/      {
    kirjoitetaan = ""
    css = css "}\n"
}

END {
    if (kirjoitetaan=="joo") {
        print "\nTyylitiedostossa on virhe.\n"
    } else {
        print "\nVaihe a) onnistui: tyylitiedosto luotiin."
    }
#Lisätään vielä muutama suositeltu muotoilu.
    css = "\n@page { margin: 5pt; }\n" css
    css = " p { text-indent: 1.5em;\n margin-top: 0.1em; }\n" css
    css = " p.eka { text-indent: 0em;\n margin-top: 0.6em; }\n" css
    css = " html, body { height: 100%; margin: 0; padding: 0; border-width: 0; }\n" css
    tiedosto = kansio "tyylit.css"
    print css > tiedosto
}
