#!/usr/bin/awk -f
BEGIN {
    RS = "><"
    ORS = " "
    css = ""
    ekat_versiot = ""
}
/w:style.*paragraph.*styleId=\"[Oo]tsikko\"/ {
    css = css "p.h1 {"
    ekat_versiot = ekat_versiot  "turha {"
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Oo]tsikko( )?2\"/ {
    css = css "p.h2 {"
    ekat_versiot = ekat_versiot  "turha {"
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Oo]tsikko( )?3\"/ {
    css = css "p.h3 {"
    ekat_versiot = ekat_versiot  "turha {"
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Hh]eading4\"/ || /w:style.*paragraph.*styleId=\"[Oo]tsikko( )?4\"/ {
    css = css "p.h4 {"
    ekat_versiot = ekat_versiot  "turha {"
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Hh]eading5\"/ || /w:style.*paragraph.*styleId=\"[Oo]tsikko( )?5\"/ {
    css = css "p.h5 {"
    ekat_versiot = ekat_versiot  "turha {"
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Tt]yyli( )?2\"/ || /w:style.*paragraph.*styleId=\"[Ss]tyle( )?2\"/ {
    css = css "p.tyyli2 {"
    ekat_versiot = ekat_versiot "p.ekatyyli2 {" 
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Tt]yyli( )?3\"/ || /w:style.*paragraph.*styleId=\"[Ss]tyle3\"/ {
    css = css "p.tyyli3 {"
    ekat_versiot = ekat_versiot "p.ekatyyli3 {"
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Tt]yyli( )?4\"/ || /w:style.*paragraph.*styleId=\"[Ss]tyle4\"/ {
    css = css "p.tyyli4 {"
    ekat_versiot = ekat_versiot "p.ekatyyli4 {"
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Tt]yyli( )?5\"/ || /w:style.*paragraph.*styleId=\"[Ss]tyle5\"/ {
    css = css "p.tyyli5 {"
    ekat_versiot = ekat_versiot "p.ekatyyli5 {"
    kirjoitetaan = "joo"
}
/w:style.*paragraph.*styleId=\"[Ll]eip[äa]?teksti\"/ {
    css = css "p {"
    ekat_versiot = ekat_versiot "turha {"
    kirjoitetaan = "joo"
}
{if (kirjoitetaan != "joo") {next}}
/w:sz (.)*val=/ { koko = kaiva_arvo($0,"val")/24*100 ; css = css "font-size: " koko  "% ;\n"; ekat_versiot = ekat_versiot "font-size: " koko  "% ;\n"}
/:jc w:val=\"center\"/ {css = css "text-align: center ;\n"; ekat_versiot = ekat_versiot "text-align: center ;\n"}
/:jc w:val=\"right\"/ {css = css "text-align: right ;\n"; ekat_versiot = ekat_versiot "text-align: right ;\n"}
/:jc w:val=\"left\"/ {css = css "text-align: left ;\n"; ekat_versiot = ekat_versiot "text-align: left ;\n"}
/:jc w:val=\"both\"/ {css = css "text-align: justify ;\n"; ekat_versiot = ekat_versiot "text-align: justify ;\n"}
/(\/)?w:ind w:left=\"[^0"]+/ {arvo = kaiva_arvo( $0, "left" ) / 100 ; css = css "margin-left: " arvo "em ;\n"; ekat_versiot = ekat_versiot "margin-left: " arvo "em ;\n"}
/spacing(.)*lineRule=\"auto(.)*w:line=\"[1-9]+/ {arvo = kaiva_arvo( $0, "line") / 240 ; css = css "line-height: " arvo " ;\n"; ekat_versiot = ekat_versiot "line-height: "}
/spacing(.)*lineRule=\"atLeast(.)*w:line=\"[1-9]+/ {arvo = kaiva_arvo( $0, "line") / 567 ; css = css "line-height: " arvo " ;\n"; ekat_versiot = ekat_versiot "line-height: " arvo " ;\n"}
/spacing(.)*w:before=\"[1-9]+/ {arvo = kaiva_arvo( $0, "before" ) / 567 ; css = css "margin-top: " arvo "em ;\n"; ekat_versiot = ekat_versiot "margin-top: " arvo "em ;\n"}
/spacing(.)*w:after=\"[1-9]+/ {arvo = kaiva_arvo($0, "after" ) / 567 ; css = css "margin-bottom: " arvo "em ;\n"; ekat_versiot = ekat_versiot "margin-bottom: " arvo "em ;\n"}
/w:b\//	{css = css "font-weight: bold ;\n"; ekat_versiot = ekat_versiot "font-weight: bold ;\n"}
/w:i\//	{css = css "font-style: italic ;\n"; ekat_versiot = ekat_versiot "font-style: italic ;\n"}
/w:u/   {}
/\/w:style/      {
    kirjoitetaan = ""
    css = css "}\n"
    ekat_versiot = ekat_versiot "}\n"
}
END {
    if (kirjoitetaan=="joo") {
        print "\nSyötteen tyyleissä on virhe.\n"
    } else {
        print "\nVaihe a) onnistui: tyylitiedosto luotiin."
    }
    css = "\n@page { margin: 5pt ; }\n" css
    css = " p { text-indent: 1.5em;\n margin-top: 0.1em ; }\n" css
    css = css " p.eka { text-indent: 0em;\n margin-top: 0.6em ; }"
    css = " html, body { height: 100% ;\n margin: 0 ;\n padding: 0 ;\n border-width: 0 ;\n }\n" css
    tiedosto = kansio "/tyylit.css"
    gsub(/ekatyyli[1-9]?[ ]?{/,"& \r" , ekat_versiot)
    gsub(/^[^\r]*ekatyyli1[ ]?{/, "& text-indent: 0em;\n", ekat_versiot)
    gsub(/^[^\r]*ekatyyli2[ ]?{/, "& text-indent: 0em;\n", ekat_versiot)
    gsub(/^[^\r]*ekatyyli3[ ]?{/, "& text-indent: 0em;\n", ekat_versiot)
    gsub(/^[^\r]*ekatyyli4[ ]?{/, "& text-indent: 0em;\n", ekat_versiot)
    gsub(/^[^\r]*ekatyyli5[ ]?{/, "& text-indent: 0em;\n", ekat_versiot)
    gsub(/^[^\r]*ekatyyli6[ ]?{/, "& text-indent: 0em;\n", ekat_versiot)
    gsub(/^[^\r]*ekatyyli7[ ]?{/, "& text-indent: 0em;\n", ekat_versiot)
    gsub(/^[^\r]*ekatyyli8[ ]?{/, "& text-indent: 0em;\n", ekat_versiot)
    gsub(/^[^\r]*ekatyyli9[ ]?{/, "& text-indent: 0em;\n", ekat_versiot)
    gsub(/\r/,"",ekat_versiot)
    gsub(/turha {[^}]*}/,"",ekat_versiot)
    gsub(/ekatyyli[1-9]?[ ]?{/,"& \r" , css)
    gsub(/^[^\r]*h1[ ]?{/, "& text-indent: 0em;\n", css)
    gsub(/^[^\r]*h2[ ]?{/, "& text-indent: 0em;\n", css)
    gsub(/^[^\r]*h3[ ]?{/, "& text-indent: 0em;\n", css)
    gsub(/^[^\r]*h4[ ]?{/, "& text-indent: 0em;\n", css)
    gsub(/^[^\r]*h5[ ]?{/, "& text-indent: 0em;\n", css)
    gsub(/\r/,"",css)
    print css "\n" ekat_versiot > tiedosto
}
function kaiva_arvo( rivi, muuttuja ){
    match(rivi, muuttuja "=\"[0-9]*\"")
    arvo = substr( rivi, RSTART +2 +length(muuttuja), RLENGTH -3 -length(muuttuja) )
    return(arvo + 0)
}
