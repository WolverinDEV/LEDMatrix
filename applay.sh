#!/bin/bash

for i in "$@"
do
case $i in
    -h|--help)
    	echo "-h or --help | Shows this page"
	echo "-b or --build | Compile the assambler code"
	echo "-u or --upload | Uploads the newest code"
	echo "-ueep or --uploadEEP | Upload the programm eep"
	echo "-bp or --buildEEP | Rebuild the pixelmap"
	exit 3
    	shift # past argument=value
    ;;
    -b|--build)
	rebuild=YES
	shift # past argument=value	
	;;
    -be|--buildEEP|-bp|--buildPixelmap)
	buildPM=YES
	shift
	;;
    -u|--upload)
	    upload=YES
	    shift # past argument=value
    ;;
#    -l=*|--lib=*)
#	    LIBPATH="${i#*=}"
#	    shift # past argument=value
#    ;;
    -ueep|--updateEEP)
	    uploadEEP=YES
	    shift # past argument with no value
    ;;
    *)
            # unknown option
    ;;
esac
done

echo "FILE EXTENSION  = ${update}"
echo "SEARCH PATH     = ${updateEEP}"

if [[ -n ${rebuild} ]]; then
	mkdir generated
	echo "Recompiling assambler code"
	avra MatrixImage.asm
	mv MatrixImage.eep.hex generated/eep.hex
	mv MatrixImage.hex generated/MatrixImage.hex
	mv MatrixImage.obj generated/MatrixImage.obj
	mv MatrixImage.cof generated/MatrixImage.cof
fi

if [[ -n ${buildPM} ]]; then
	cat Pixels | tr -d '\n' > generated/PixelMapStriped
	avr-objcopy -I binary -O ihex generated/PixelMapStriped generated/eep.hex
fi

if [[ -n ${upload} ]]; then
	if [[ -n ${uploadEEP} ]]; then
		echo "Uploading EEP and FLASH"
		sudo avrdude -c avrispmkII -P usb -p m8 -U flash:w:generated/MatrixImage.hex:a -U eeprom:w:generated/eep.hex
	else
		echo "Uploading FLASH"
		sudo avrdude -c avrispmkII -P usb -p m8 -U eeprom:w:generated/eep.hex
	fi
else
	if [[ -n ${uploadEEP} ]]; then
		echo "Uploading EEP"
		sudo avrdude -c avrispmkII -P usb -p m8 -U eeprom:w:generated/eep.hex
	fi
fi
