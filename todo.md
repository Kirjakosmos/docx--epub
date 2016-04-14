###Tekemättä
 * ~~sisennyksiin ja rivinväleihin varsinaisen arvon kaivaminen esiin tyylitiedostosta~~ tehty
 * rivinvälien yms. arvojen yhteydessä käytettävien yksiköiden tarkistaminen
 * ~~kansikuvalle nimi epubin hakemistoon (nykyinen toteutus ei toimi)~~ nyt toimii
 * kuvat tekstissä (liian suuritöinen, ehkä?)
 * alaviitteet
 * teksti- tai rtf-muotoisten asiakirjojen kääntäminen, lähinnä seuraava:
 * ~~otsikoiden tunnistaminen tekstin sekaan liitetyllä tunnisteella (esim. merkintöjen **"*/ ja */*"* välissä oleva teksti tulkitaan muuntaessa otsikoksi)~~ Nyt rivit, joilla on merkkijono ???o??? tulee poimituksi otsikoksi
 * numeroidut listat (mu_numerointi.awk, joka lukee numbering.xml:n?)
 * toisille tyyleille pohjaavien tyylien luominen oikein
 * ~~muotoillulla tyylillä alkavan luvun alkuun ekat kappaleet oikein~~
 * ~~sivunumeroiden automaattinen poistaminen~~
 * huonosti muotoiltujen tiedostojen käsitteleminen niin, ettei päädytä eri määrään lukuja ja otsikoita
 * käytettäville tyyleille omat nimet, sillä nykyisellään menevät päälle kiinteästi määrättyjen kanssa (ei voi yksinkertaisesti uudelleennimetä tyylejään, kun nimet ovatkin jo varattuja)
 * asiakirjassa kaytettyjen tyylien kaivaminen etukateen nimettyjen asemesta
 * ~~python-skriptin korvaaminen awkilla ja kutsulla zip:ille (unzip on jo alussa mukana)~~
 * shell-komennot awk-tiedoston sis\"a\"an system()-kutsuiksi, kaikki tiedostot yhdeksi ohjelmatiedostoksi (getline < tyylit jne.)
 * muuttujien nimien johdonmukaistaminen
 * julkaisu