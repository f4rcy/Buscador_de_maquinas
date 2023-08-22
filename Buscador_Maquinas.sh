#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Ctrl C
function ctrl_c(){
	echo -e "\n\n[x]Saliendo...\n"
	tput cnorm && exit 1
}

trap ctrl_c INT

#Variables Globales
url="https://htbmachines.github.io/bundle.js"
respuesta_no_valida="\n${redColour}[!]${endColour} ${grayColour}Esa respuesta no es válida${endColour}\n"

#funciones
function help_panel(){
	echo -e "\n${yellowColour}[x]${endColour} uso: "
	echo -e "\t${purpleColour}u:${endColour} Descargar o actualizar archivos necesarios."
	echo -e "\t${purpleColour}m:${endColour} Buscar una maquina."
	echo -e "\t${purpleColour}i:${endColour} Buscar por direción IP."
	echo -e "\t${purpleColour}o:${endColour} Buscar por Sistema operativo."
	echo -e "\t${purpleColour}d:${endColour} Buscar por nivel de dificultad."
	echo -e "\t${purpleColour}s:${endColour} Buscar por skills. ${yellowColour}(colocalas entre doble comillas para evitar errores)${endColour}"
	echo -e "\t${purpleColour}l:${endColour} Obtener link de youtube de una maquina."
	echo -e "\t${purpleColour}h:${endColour} Mostrar este panel de ayuda."
}

function update(){
        tput civis
        if [ ! -f bundle.js ]; then
        echo -e "\n[x] Descargando archivos necesarios.."
        curl -s $url > budle.js
        js-beautify budle.js | sponge bundle.js
        echo -e "\n[x] Archivos descargados :D"
        else
        curl -s $url > budle_temp.js
        js-beautify budle_temp.js | sponge bundle_temp.js
        md5=$(md5sum bundle.js | awk '{print $1}')
        md5_temp=$(md5sum bundle_temp.js | awk '{print $1}')

        if [ "$md5_temp" == "$md5_temp" ]; then
        echo -e "\n[x] No hay actualizaciones pendientes"
        rm -r bundle_temp.js
        else
        echo -e "\n[x] Actualizando.."
        rm bundle.js && mv bundle_temp.js bundle.js
        fi
        tput cnorm
        fi
}

function searchmachine(){
        name_machine="$1"
	echo -e "\n${greenColour}[-]${endColour} Listando propiedades de la maquina ${purpleColour}$name_machine${endColour}: \n"
	cat bundle.js | awk "/name: \"$name_machine\"/,/resuelta/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d ',' | sed 's/ *//'
}

function searchIP(){
	dir_ip="$1"
	name_machine=$(cat bundle.js | grep "ip: \"$dir_ip\"" -B 5 | grep "name: " | tr -d ',' | tr -d '"' | awk 'NF{print $NF}')
	echo -e "\n${greenColour}[-]${endColour} El nombre de la maquina de la IP ${blueColour}$dir_ip es: ${purpleColour}$name_machine${endColour}\n"
}

function searchlink(){
	name_machine="$1"

	if [ "name_machine" ]; then
	link="$(cat bundle.js | awk "/name: \"$name_machine\"/,/resuelta/" | grep -vE "id|sku|resuelta" | tr -d '"' | tr -d ',' | sed 's/ *//' | grep "youtube" | awk 'NF{print $NF}')"
	echo -e "\n${greenColour}[-]${endColour} El link de youtube de la maquina ${purpleColour}$name_machine${endColour} es: ${blueColour}$link${endColour}"
	else
	echo -e "\n${redColour}[x]${endColour} La maquina no existe"
	fi
}

function searchdif(){
	dificultad="$1"
	name_machine=$(cat bundle.js | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | tr -d ',' | tr -d '"' | awk 'NF{print $NF}' | column)

	if [ "name_machine" ]; then
	echo -e "\n${greenColour}[-]${endColour} Las maquinas de dificultad ${blueColour}$dificultad${endColour} son:\n"
	cat bundle.js | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | tr -d ',' | tr -d '"' | awk 'NF{print $NF}' | column
	else
	echo -e "\n${redColour}[x]${endColour} ${grayColour}No existe esa dificultad${endColour}\n"
	fi
}

function searchOs(){
	os="$1"
	name_machine=$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column)

	if  [ "name_machine" ]; then
	echo -e "\n${greenColour}[-]${endColour} Las maquinas con sistema operativo ${blueColour}$os${endColour} son: \n"
	cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column
	else
	echo -e "\n${redColour}[x]${endColour} ${grayColour}No existe ese sistema operativo${endColour}\n"
	fi
}

function searchdif_os(){
	dificultad="$1"
	os="$2"
	name_machine=$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column)

	if [ "name_machine" ]; then
	echo -e "\n${greenColour}[-]${endColour} Listando maquinas con dificultad ${blueColour}$dificultad${endColour} y sistema operativo ${purpleColour}$os${endColour}..."
	cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$dificultad\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d ',' | tr -d '"' | column
	else
	echo -e "\n${redColour}[x]${endColour} ${grayColour}No existe esa dificultad o sistema operativo${endColour}\n"
	fi
}

function searchskill(){
	skill="$1"
	name_machine=$(cat bundle.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name: " | tr -d ',' | tr -d '"' | awk 'NF{print $NF}' | column)

	if [ "name_machine" ]; then
	echo -e "\n${greenColour}[-]${endColour} Las maquinas con skill ${blueColour}$skill${endColour} son:\n"
	cat bundle.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name: " | tr -d ',' | tr -d '"' | awk 'NF{print $NF}' | column
	else
	echo -e "\n${redColour}[x]${endColour} ${grayColour}No existe esa skill${endColour}\n"
	fi
}

#indicadores o variables
declare -i parametro=0

#chivatos
declare -i chivato_os=0
declare -i chivato_dif=0

while getopts "m:ui:l:d:o:s:h" arg; do
	case $arg in
	m) name_machine=$OPTARG; let parametro+=1;;
	u) let parametro+=2;;
	i) dir_ip=$OPTARG; let parametro+=3;;
	l) name_machine=$OPTARG; let parametro+=4;;
	d) dificultad=$OPTARG; chivato_dif=1; let parametro+=5;;
	o) os=$OPTARG; chivato_os=1; let parametro+=6;;
	s) skill=$OPTARG; let parametro+=7;;
	h) ;;
	esac
done

if [ $parametro -eq 1 ]; then
	searchmachine $name_machine
elif [ $parametro -eq 2 ]; then
	update
elif [ $parametro -eq 3 ]; then
	searchIP $dir_ip
elif [ $parametro -eq 4 ]; then
	searchlink $name_machine
elif [ $parametro -eq 5 ]; then
	searchdif $dificultad
elif [ $parametro -eq 6 ]; then
	searchOs $os
elif [ $chivato_dif -eq 1 ] && [ $chivato_os -eq 1 ]; then
	searchdif_os $dificultad $os
elif [ $parametro -eq 7 ]; then
	searchskill "$skill"
else
	help_panel
fi
