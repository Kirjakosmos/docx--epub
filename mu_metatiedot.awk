#!/usr/bin/awk -f

#    Uuden musteen muunnin. Converts docx-files to epub-files.
#    Copyright (C) 2016 Matti Palomäki. 
#    Written for www.uusimuste.fi
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
        komento = komento " kansikuva=\"" kansikuva "\""
    }
    komento = komento  " tunniste=\"" tunniste "\" ../" otsikot
    print "Vaihe c) onnistui: metatiedot löytyivät."
    system(komento) 
}
