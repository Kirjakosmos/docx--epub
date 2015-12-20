#!/usr/bin/awk -f
# Kaivaa syötetiedostosta muutaman parametrin esiin, kutsuu Harrin ohjelmaa niillä. 
# Saa syötteenä myös arvon tyylit, joka on tyylit sisältävä css-tiedosto ja jonka antaa eteenpäin Harrin skriptille.
# Vielä saa syötteenä arvon tunniste, joka laitetaan eteenpäin ja josta tulee epubin "unique-identifier".
# Ja vielä syöte nimi, jossa alkuperäisen docx:n nimi.
BEGIN {
    komento="python muunneltu_Harrin_skripti.py"
}

#Onko seuraavassa jäljempi match tarpeen, asettuvatko RSTART ja RLENGTH jo alkutestissä? Kokeiltu; on ja eivät asetu :(
/title>[^<]+<\//  {match($0, /title>[^<]+<\//); komento = komento " --title '" substr($0,RSTART+6,RLENGTH-8) "'"}
/creator>[^<]+<\//  {match($0, /creator>[^<]+<\//); komento = komento " --authors '" substr($0,RSTART+8,RLENGTH-10) "'"}
# Harrin ohjelman pyytämistä argumenteista jää etsimättä --lang ja --output

END {
    if (!index(komento,"--title")){
        gsub(/\.doc[x]?/,"",nimi)  #tiedostotyypin tunniste pois nimestä
        komento = komento " --title '" nimi "'"
    }
    if (otsikot != "") {
        komento = komento " --otsikot " otsikot
    }
    if (kansikuva != "") {
        komento = komento " --kansikuva " kansikuva
    }
    komento = komento " --styles " tyylit  " --identifier " tunniste " " kansio
    print "Vaihe c) onnistui: metatiedot löytyivät.\nMuunnetaan epubiksi."
    system(komento)
}
