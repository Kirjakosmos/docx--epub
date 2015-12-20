#!/usr/bin/awk -f

BEGIN {
    RS = "><"
    ORS = " "
    css = ""
}

# otsikot
/w:style.*paragraph.*styleId=\"[Oo]tsikko\"/ {
    css = css "p.h1 {"
    kirjoitetaan = "joo"
}

# alaotsikot
/w:style.*paragraph.*styleId=\"[Hh]eading2\"/ || /w:style.*paragraph.*styleId=\"[Oo]tsikko( )?2\"/ {
    css = css "p.h2 {"
    kirjoitetaan = "joo"
}

# vapaasti määriteltävät ylimääräiset tyylit
/w:style.*paragraph.*styleId=\"[Tt]yyli( )?2\"/ || /w:style.*paragraph.*styleId=\"[Ss]tyle( )?2\"/ {
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

# leipäteksti
/w:style.*paragraph.*styleId=\"[Ll]eip[äa]?teksti\"/ {
    css = css "p {"
    kirjoitetaan = "joo"
}

{if (kirjoitetaan != "joo") {next}}
# Tästä eteenpäin mennään vain, jos luetaan tunnistettua tyyliä.

# fonttikoko
/w:sz (.)*val=/ { koko = kaiva_arvo($0,"val")/24*100 ; css = css "font-size: " koko  "% ;\n"}

# tekstin ryhmittäminen
/:jc w:val=\"center\"/ {css = css "text-align: center ;\n"}
/:jc w:val=\"right\"/ {css = css "text-align: right ;\n"}
/:jc w:val=\"left\"/ {css = css "text-align: left ;\n"}
/:jc w:val=\"both\"/ {css = css "text-align: justify ;\n"}

# sisennys
/(\/)?w:ind w:left=\"[^0"]+/ {arvo = kaiva_arvo( $0, "left" ) / 100 ; css = css "margin-left: " arvo "em ;\n"}

# välistys
/spacing(.)*lineRule=\"auto(.)*w:line=\"[1-9]+/ {arvo = kaiva_arvo( $0, "line") / 240 ; css = css "line-height: " arvo " ;\n"}
/spacing(.)*lineRule=\"atLeast(.)*w:line=\"[1-9]+/ {arvo = kaiva_arvo( $0, "line") / 567 ; css = css "line-height: " arvo " ;\n"}

# kappaleenvälit
/spacing(.)*w:before=\"[1-9]+/ {arvo = kaiva_arvo( $0, "before" ) / 567 ; css = css "margin-top: " arvo "em ;\n"}
/spacing(.)*w:after=\"[1-9]+/ {arvo = kaiva_arvo($0, "after" ) / 567 ; css = css "margin-bottom: " arvo "em ;\n"}

# lihavoinnit yms.
/w:b\//	{css = css "font-weight: bold ;\n"}
/w:i\//	{css = css "font-style: italic ;\n"}
/w:u/   {}

# tyylin loppu
/\/w:style/      {
    kirjoitetaan = ""
    css = css "}\n"
}

END {
    if (kirjoitetaan=="joo") {
        print "\nSyötteen tyyleissä on virhe.\n"
    } else {
        print "\nVaihe a) onnistui: tyylitiedosto luotiin."
    }
# Lisätään vielä muutama suositeltu muotoilu.
    css = "\n@page { margin: 5pt ; }\n" css
    css = " p { text-indent: 1.5em;\n margin-top: 0.1em ; }\n" css
    css = css " p.eka { text-indent: 0em;\n margin-top: 0.6em ; }"
    css = " html, body { height: 100% ;\n margin: 0 ;\n padding: 0 ;\n border-width: 0 ;\n }\n" css
    tiedosto = kansio "tyylit.css"
    print css > tiedosto
}

# kaivaa riviltä muuttuja="luku" -kohdasta annettua muuttujaa vastaavan luvun
function kaiva_arvo( rivi, muuttuja ){
match(rivi, muuttuja "=\"[0-9]*\"")
arvo = substr( rivi, RSTART +2 +length(muuttuja), RLENGTH -3 -length(muuttuja) )
return(arvo + 0)
}
