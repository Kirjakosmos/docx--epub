BEGIN {
    komento="../mu_nidonta.awk"
}
/title>[^<]+<\//  {match($0, /title>[^<]+<\//); komento = komento " nimeke=\"" substr($0,RSTART+6,RLENGTH-8) "\""}
/creator>[^<]+<\//  {match($0, /creator>[^<]+<\//); komento = komento " kirjoittajat=\"" substr($0,RSTART+8,RLENGTH-10) "\""}
END {
    if (!index(komento,"nimeke=")){
        gsub(/\.doc[x]?/,"",nimi)
        gsub(/^(.)*\//,"",nimi)
        komento = komento " nimeke=\"" nimi "\""
    }
    if (!index(komento,"kirjoittajat=")){
	komento = komento " kirjoittajat=\"tuntematon\""
    }
    if (kansikuva) {
	print "kansi: " kansikuva "\n" 
        komento = komento " kansikuva=\"" kansikuva "\""
    }
    komento = komento  " tunniste=\"" tunniste "\" ../" otsikot
    print "Vaihe c) onnistui: metatiedot löytyivät."
    print komento "\n" 
    system(komento) 
}
