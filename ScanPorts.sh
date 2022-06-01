#!/bin/bash
# Author: Andres Felipe Rodriguez

ARCHIVO_CSV="eipmap" # Nombre del archivo CSV

scan () { #   Funcion que realiza el escaneo de la red (dependiente de las otras funciones)
    comprobar_ip $1
    echo "Escaneando IP's..."
    for PUERTO in {0..65534};
    do
        timeout 1 bash -c "</dev/tcp/$DOMAIN/$PUERTO" 2>/dev/null && OPENPORTS+=($PUERTO)
    done

    print_info $OPENPORTS
    save_csv $OPENPORTS
}

comprobar_ip () { #   Funcion para comprobar si la IP es valida y tambien para traducir el dominio a IP
    ping -c 1 $1 &> /dev/null
    if [ "$(echo $?)" = "0" ]; then
        DOMAIN="$(ping -c 1 $IP | awk {'print $3'} | awk 'NR==1' | tr -d '()')" #   Obtiene la IP del dominio
    else
        echo -e "\e[1;31m[-]\e[0m La IP $1 no es valida / no alcanzable"
        exit
    fi
}

print_info () { #   Funcion para imprimir por pantalla la informacion
    echo -e """EIPmap desarrollado por el estudiante Andres Felipe Rodriguez
Hora de ejecucion: $(date)\n
\e[1;33m[*]\e[0m Escaneo de puertos sobre $IP en proceso
    """
    for PUERTO in $1;
    do
        echo -e "      \e[1;32m[+] $PUERTO \e[0m-- puerto abierto"
    done
}

save_csv () { # Funcion para guardar los puertos abiertos en un archivo con extensión '.csv'
    for PUERTO in $1
    do
        echo "$IP;$PUERTO;open" >> $ARCHIVO_CSV.csv
    done
}

main () { # Funcion principal
    if [ -z $1 ]; then
        echo "Es necesario proporcionar una direccion IP/Dominio O directamente ./eipmap.sh <IP>"
        read -p "Dirección: " IP

        if [ -z $IP ]; then
            clear
            main
        else
            scan $IP
        fi
    else
        IP=$1
        scan $IP
    fi    
}
main $1