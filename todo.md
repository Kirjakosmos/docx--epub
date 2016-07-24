###Tekemättä
 * ~~sisennyksiin ja rivinväleihin varsinaisen arvon kaivaminen esiin tyylitiedostosta~~ tehty
 * rivinvälien yms. arvojen yhteydessä käytettävien yksiköiden tarkistaminen
 * ~~kansikuvalle nimi epubin hakemistoon (nykyinen toteutus ei toimi)~~ nyt toimii
 * kuvat tekstissä (liian suuritöinen, ehkä?)
 * alaviitteet - loppuviitteiksi kaiketi?
 * teksti- tai rtf-muotoisten asiakirjojen kääntäminen, lähinnä seuraava:
 * ~~otsikoiden tunnistaminen tekstin sekaan liitetyllä tunnisteella (esim. merkintöjen **"*/ ja */*"* välissä oleva teksti tulkitaan muuntaessa otsikoksi)~~ Nyt rivit, joilla on merkkijono ¤¤¤o¤¤¤ tunnistetaan otsikoiksi.
 * numeroidut listat (mu_numerointi.awk, joka lukee numbering.xml:n?)
 * toisille tyyleille pohjaavien tyylien luominen oikein
 * ~~muotoillulla tyylillä alkavan luvun alkuun ekat kappaleet oikein~~ Tehty.
 * ~~sivunumeroiden automaattinen poistaminen~~ Tehty kertaalleen, muttei lienekään tarpeen.
 * ~~huonosti muotoiltujen tiedostojen käsitteleminen niin, ettei päädytä eri määrään lukuja ja otsikoita~~ Toivottavasti tehty - pidetään silmät auki.
 * käytettäville tyyleille omat nimet, sillä nykyisellään menevät päälle kiinteästi määrättyjen kanssa (ei voi yksinkertaisesti uudelleennimetä tyylejään, kun nimet ovatkin jo varattuja)
 * asiakirjassa kaytettyjen tyylien kaivaminen etukateen nimettyjen asemesta
 * ~~python-skriptin korvaaminen awkilla ja kutsulla zip:ille (unzip on jo alussa mukana)~~ Tehty, ja nyt muutoksen jäljiltä toimiikin taas. :)
 * ~~shell-komennot awk-tiedoston sisään system()-kutsuiksi, kaikki tiedostot yhdeksi ohjelmatiedostoksi (getline < tyylit jne.)~~ Ei liene sittenkään tarkoituksenmukaista. Harkinnassa vielä.
 * muuttujien nimien johdonmukaistaminen
 * ~~lisenssi~~
 * julkaisu
 * Ennen ensimmäistä otsikkoa esiintyvä leipäteksti sotkee sisällysluetteloa yhdellä askeleella.
