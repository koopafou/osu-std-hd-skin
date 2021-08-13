#!/bin/sh
# Usage : path-to-this-folder/make-all.sh
SRCPATH=`dirname "$0"`

if [ -z ${OSU_ALPHA+x} ] ; then
		export OSU_ALPHA_TRANSFORM=
else
		export OSU_ALPHA_TRANSFORM="-channel A +level ${OSU_ALPHA} +channel"
		# example to make everything 50% more transparent, OSU_ALPHA='0%,50%'
fi

copy () {
		if [ . -ef "${SRCPATH}" ] ; then
				echo "Script in same folder, avoiding operations on $1"
		else
				if [ ! -e "$1" -o "${SRCPATH}/$1" -nt "$1" ] ; then
						echo "copying $1"
						cp "${SRCPATH}/$1" .
				fi
		fi
}

dupe () {
		if [ ! -e "$2" -o "$1" -nt "$2" ] ; then
				echo "duplicating $1 -> $2"
				cp "$1" "$2"
		fi
}

create () {
		PNG=`echo "$1.png" | envsubst`
		MGK="${SRCPATH}/$1.mgk"
		if [ ! -e "${PNG}" -o "${MGK}" -nt "${PNG}" ] ; then
				echo "generating ${PNG}"
				< "${MGK}" envsubst | magick-script - > "${PNG}"
		fi
}

####### misc
copy skin.ini
create alphapixel
create comboburst
create star2

####### cursor
copy cursortrail.png
create cursormiddle
create cursor

###### hit circles
create hitcircleoverlay
create hitcircle
create approachcircle

####### sliders
create sliderendcircle
create sliderstartcircle
dupe hitcircleoverlay.png sliderstartcircleoverlay.png
create sliderfollowcircle
create sliderscorepoint
create sliderb

####### spinners
create spinner-bottom
create spinner-glow
create spinner-middle
create spinner-top
create spinner-spin
create spinner-clear

####### default digits
NDIGITS=10
ARC_OUTER=$((360 / (5 * $NDIGITS) * 2))
ARC_INNER=$((360 / (4 * $NDIGITS)))
export i
for i in `seq 0 $(($NDIGITS - 1))` ; do
		ARC_CENTER=$((360 * $i / $NDIGITS))
		export ARC_OL=$(($ARC_CENTER - $ARC_OUTER))
		export ARC_OR=$(($ARC_CENTER + $ARC_OUTER))
		export ARC_IL=$(($ARC_CENTER - $ARC_INNER))
		export ARC_IR=$(($ARC_CENTER + $ARC_INNER))
		create default-\$i
done

####### hitbursts
BURSTFRAMES=12
HIT100ANGLE=0.8
create hit0
create hit50
angle () {
		echo "23 + 20 * c($1)" | bc -l
		echo ','
		echo "23 + 20 * s($1)" | bc -l
}
export HIT100A=`angle ${HIT100ANGLE}`
export HIT100B=`angle "${HIT100ANGLE} + 8 * a(1) / 3"`
export HIT100C=`angle "${HIT100ANGLE} - 8 * a(1) / 3"`
create hit100
create hit300
for j in 0:0 50:50 100:100 100:100k 300:300 300:300k 300:300g ; do
		ja=`cut -d : -f 1 <<< ${j}`
		jb=`cut -d : -f 2 <<< ${j}`
		if [ -e hit${jb}-$(($BURSTFRAMES + 2)).png ] ; then
				rm -f hit${jb}-*.png
		fi
		for i in `seq 0 $BURSTFRAMES` ; do
				dupe hit${ja}.png hit${jb}-${i}.png
		done
		dupe alphapixel.png hit${jb}-$(($BURSTFRAMES + 1)).png
done

###### followpoints
create followpoint-0
dupe followpoint-0.png followpoint-1.png
create followpoint-2
dupe followpoint-2.png followpoint-3.png
dupe followpoint-0.png followpoint-4.png


###### extras
create generic-red
create generic-blue
