#!/usr/bin/awk -f

BEGIN {
    komento="python muunneltu_Harrin_skripti.py"
}

/title>[^<]+<\//  {match($0, /title>[^<]+<\//); komento = komento " --title '" substr($0,RSTART+6,RLENGTH-8) "'"}
/creator>[^<]+<\//  {match($0, /creator>[^<]+<\//); komento = komento " --authors '" substr($0,RSTART+8,RLENGTH-10) "'"}

END {
    if (!index(komento,"--title")){
        gsub(/\.doc[x]?/,"",nimi)
        komento = komento " --title '" nimi "'"
    }
    if (otsikot != "") {
        komento = komento " --otsikot " otsikot
    }
    if (kansikuva != "") {
        komento = komento " --kansikuva " kansikuva
    }
    komento = komento " --styles " tyylit  " --identifier " tunniste " " kansio
    print "Vaihe c) onnistui: metatiedot löytyivät."
    system(komento)
}
