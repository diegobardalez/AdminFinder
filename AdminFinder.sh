#!/bin/sh

# Iniciar color rojo
ROJO="\033[31m"
# Resetear color a predeterminado
RESETEAR="\033[0m"

echo ""
echo ""
# Banner ASCII Art en rojo
echo "${ROJO} █████  ██████  ███    ███ ██ ███    ██ ███████ ██ ███    ██ ██████  ███████ ██████  ${RESETEAR}"
echo "${ROJO}██   ██ ██   ██ ████  ████ ██ ████   ██ ██      ██ ████   ██ ██   ██ ██      ██   ██ ${RESETEAR}"
echo "${ROJO}███████ ██   ██ ██ ████ ██ ██ ██ ██  ██ █████   ██ ██ ██  ██ ██   ██ █████   ██████  ${RESETEAR}"
echo "${ROJO}██   ██ ██   ██ ██  ██  ██ ██ ██  ██ ██ ██      ██ ██  ██ ██ ██   ██ ██      ██   ██ ${RESETEAR}"
echo "${ROJO}██   ██ ██████  ██      ██ ██ ██   ████ ██      ██ ██   ████ ██████  ███████ ██   ██ ${RESETEAR}"
echo "${ROJO}                                                                                     ${RESETEAR}"
echo "${ROJO}                                                                                     ${RESETEAR}"
echo "                                                               By Diego Bardalez"

echo ""

if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <archivo con nombres de carpetas> <URL base>"
    exit 1
fi

# El primer argumento es la ruta al archivo de texto
ARCHIVO="$1"

# El segundo argumento es la URL base
URL_BASE="$2"

# Asegurarse de que URL_BASE termine con una barra (/) para construir correctamente las URLs completas
case "$URL_BASE" in
    */)
        ;;
    *)
        URL_BASE="${URL_BASE}/"
        ;;
esac

# Limpiar la línea antes de imprimir la nueva ruta
LIMPIAR_LINEA=$(tput el)

#Generar un GUID para detectar estados 200 en cualquier ruta
UUID=$(openssl rand -hex 16 | sed 's/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1\2\3\4-\5\6-\7\8-\8\7-\6\5\4\3\2\1/')

URL_COMPLETA="${URL_BASE}${UUID}"
CODIGO_HTTP=$(curl -I -o /dev/null -w '%{http_code}' -s "${URL_COMPLETA}")

if [ "$CODIGO_HTTP" = "200" ]; then
    echo "No se puede determinar el estado 404 ya que el servidor muestra estado 200 en cualquier path"
    echo ${URL_COMPLETA}
    exit
fi

# Leer cada línea del archivo, asumiendo que cada línea es un nombre de carpeta
while IFS= read -r carpeta; do
    # Guardar la posición del cursor
    tput sc
    
    # Mover el cursor a la última línea y limpiarla
    tput cup $(tput lines) 0
    echo -n "${LIMPIAR_LINEA}Probando ruta: ${URL_BASE}${carpeta}"
    
    # Restaurar la posición del cursor
    tput rc

    # Construir la URL completa
    URL_COMPLETA="${URL_BASE}${carpeta}"

    # Usar 'curl' para hacer una solicitud HEAD a la URL y obtener el código de estado HTTP
    CODIGO_HTTP=$(curl -I -o /dev/null -w '%{http_code}' -s "${URL_COMPLETA}")

    # Verificar si el código de estado HTTP es 200, lo que indica que el recurso existe
    if [ "$CODIGO_HTTP" = "200" ]; then
        echo "La carpeta existe en la URL: $URL_COMPLETA"
    fi
    
    # Esperar un momento para que el mensaje "Probando ruta: ..." sea legible
    sleep 0.5
done < "$ARCHIVO"

# Limpiar la última línea después de completar el bucle
tput cup $(tput lines) 0
echo -n "${LIMPIAR_LINEA}"
