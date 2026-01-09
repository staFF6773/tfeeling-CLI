#!/bin/bash

# ==============================================================================
# Script: sylvie.sh
# Descripción: Simulador interactivo basado en "Teaching Feeling".
#              Gestiona el sistema de afecto, confianza, tiempo y diálogos.
# ==============================================================================

# --- Definición de Rutas y Estilos ---
DATA_FILE="$HOME/.sylvie_save.json" # Cambiado a JSON
ENGINE_PY="$(dirname "$0")/modules/engine.py"
COLOR_RESET="\e[0m"              # Reset de formato ANSI
COLOR_PINK="\e[1;35m"             # Color para temática de Sylvie
COLOR_CYAN="\e[1;36m"             # Color para información del sistema
COLOR_WHITE="\e[1;37m"            # Color para texto general
COLOR_GRAY="\e[0;90m"             # Color para separadores y decoraciones

# --- Integración con el Motor Python ---

# @function call_engine
# @description Llama al motor Python y actualiza las variables de Bash desde el JSON resultante.
call_engine() {
    local action=$1
    local json_output
    json_output=$(python3 "$ENGINE_PY" --action "$action")
    
    # Extraer variables del JSON usando jq
    affection=$(echo "$json_output" | jq -r '.affection')
    trust=$(echo "$json_output" | jq -r '.trust')
    name=$(echo "$json_output" | jq -r '.name')
    last_action=$(echo "$json_output" | jq -r '.last_action')
    time_of_day=$(echo "$json_output" | jq -r '.time_of_day')
    hour=$(echo "$json_output" | jq -r '.hour')
    minute=$(echo "$json_output" | jq -r '.minute')
    actions_taken=$(echo "$json_output" | jq -r '.actions_taken')
}

# Inicialización: Cargar estado inicial
call_engine "status"

# Cargar diálogos (si existe el archivo)
DIALOGUES_FILE="$(dirname "$0")/modules/dialogues.sh"
if [ -f "$DIALOGUES_FILE" ]; then
    source "$DIALOGUES_FILE"
else
    # Fallback básico si falta el archivo
    DISTRUST_DIALOGUES=("...")
    NEUTRAL_DIALOGUES=("Hola.")
    TRUST_DIALOGUES=("Te quiero mucho.")
fi

# --- Persistencia de Datos ---
# @function save_data
# @description (Obsoleto) Ahora el motor Python se encarga de la persistencia.
save_data() {
    :
}

# --- Arte ASCII y UI ---
# --- Interfaz de Usuario (UI) ---

# @function draw_sylvie
# @description Limpia la terminal y muestra el arte ASCII de Sylvie con su nombre.
draw_sylvie() {
    clear
    echo -e "${COLOR_PINK}"
    cat <<'EOF'
                            

                   #########                      
                 ###+***##*#**                    
                *#+**++***=*++=:                  
                #*+****#**+*#+++                  
              # #**###*%##*--*##+                 
                *#**#%-#*##:::-%*                 
               ####*-%@%@-%:@=-**                 
               %###*#:++::::*%-#*                 
              -%###*--+-:::::: =-                 
              +%#%#**##---::: *#                  
               *#**#*=+++-=-+*=*                  
               -=-=-#*----+------                 
             ====---=--+-=-==--=---               
           ========--=====-=:==--:---:              
EOF
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_WHITE}       [ $name ]${COLOR_RESET}"
    echo -e "${COLOR_GRAY}---------------------------${COLOR_RESET}"
}

# @function show_status
# @description Muestra la barra de estado con las estadísticas actuales y el tiempo.
show_status() {
    echo -e "${COLOR_CYAN}Afecto: $affection | Confianza: $trust | Hora: $hour:$(printf "%02d" $minute) | Día: $time_of_day${COLOR_RESET}"
    echo -e "${COLOR_GRAY}---------------------------${COLOR_RESET}"
}

# --- Diálogos ---
# --- Motor de Diálogos ---

# @function get_dialogue
# @description Motor de selección de diálogos basado en heurística de estadísticas y contexto.
# @param $1 - Nivel de afecto actual.
# @param $2 - Modo de diálogo (e.g., "treat" para dulces).
# @param $3 - Última acción realizada.
# @param $4 - Momento del día actual.
get_dialogue() {
    local level=$1
    local mode=$2
    local last_action=$3
    local time_of_day=$4
    local current_trust=$trust
    
    # choices: Array temporal para consolidar opciones válidas según contexto
    declare -a choices
    
    # FASE 1: Selección base según el nivel de afinidad (Desconfianza -> Neutral -> Confianza)
    if [ "$level" -lt 20 ] || [ "$current_trust" -lt 10 ]; then
        choices=("${DISTRUST_DIALOGUES[@]}")
    elif [ "$level" -lt 60 ] || [ "$current_trust" -lt 30 ]; then
        choices=("${NEUTRAL_DIALOGUES[@]}")
    else
        choices=("${TRUST_DIALOGUES[@]}")
    fi

    # FASE 2: Inyección de diálogos específicos por acción
    if [ "$last_action" == "pat_head" ]; then
        if [ "$level" -lt 40 ]; then
            choices+=("${ACTION_PAT_HEAD_LOW[@]}")
        else
            choices+=("${ACTION_PAT_HEAD_HIGH[@]}")
        fi
    elif [ "$last_action" == "give_treat" ]; then
        if [ "$level" -lt 40 ]; then
            choices+=("${ACTION_TREAT_LOW[@]}")
        else
            choices+=("${ACTION_TREAT_HIGH[@]}")
        fi
    fi

    # FASE 3: Inyección de diálogos contextuales por tiempo
    case $time_of_day in
        "morning") choices+=("${TIME_MORNING[@]}") ;;
        "afternoon") choices+=("${TIME_AFTERNOON[@]}") ;;
        "night") choices+=("${TIME_NIGHT[@]}") ;;
    esac

    # FASE 4: Modo forzado (Sobrescribe la selección si es una acción directa de objeto)
    if [ "$mode" == "treat" ]; then
        if [ "$level" -lt 40 ]; then
            choices=("${ACTION_TREAT_LOW[@]}")
        else
            choices=("${ACTION_TREAT_HIGH[@]}")
        fi
    fi

    # Retorna un elemento aleatorio del conjunto final de opciones
    echo "${choices[$RANDOM % ${#choices[@]}]}"
}

# --- Acciones Disponibles ---

# @function pat_head
# @description Acción de acariciar. Incrementa afecto y confianza. 
#              Avanza el contador de acciones.
pat_head() {
    echo -e "${COLOR_PINK}Acaricias suavemente la cabeza de Sylvie.${COLOR_RESET}"
    call_engine "pat_head"
    draw_sylvie
    echo -e "${COLOR_PINK}Acaricias suavemente la cabeza de Sylvie.${COLOR_RESET}"
    echo -e "${COLOR_WHITE}Sylvie: ${COLOR_RESET}$(get_dialogue $affection "none" $last_action $time_of_day)"
    sleep 2
}

# @function give_treat
# @description Acción de regalar un dulce. Gran incremento de afecto y confianza.
#              Avanza el contador de acciones.
give_treat() {
    echo -e "${COLOR_CYAN}Le das un dulce a Sylvie.${COLOR_RESET}"
    call_engine "give_treat"
    draw_sylvie
    echo -e "${COLOR_CYAN}Le das un dulce a Sylvie.${COLOR_RESET}"
    echo -e "${COLOR_WHITE}Sylvie: ${COLOR_RESET}$(get_dialogue $affection "treat" $last_action $time_of_day)"
    sleep 2
}

# @function talk
# @description Acción de conversación. Diálogos variados según estadísticas.
#              Avanza el contador de acciones.
talk() {
    call_engine "talk"
    draw_sylvie
    echo -e "${COLOR_CYAN}Hablas con Sylvie.${COLOR_RESET}"
    echo -e "${COLOR_WHITE}Sylvie: ${COLOR_RESET}$(get_dialogue $affection "none" $last_action $time_of_day)"
    sleep 2
}

# --- Motor de Tiempo ---

# @function update_time_of_day
# @description Sincroniza la etiqueta descriptiva del día según la hora actual (0-23).
# (Esta función ahora es manejada por el motor Python)

# @function advance_time
# @description Avanza el reloj interno 30 minutos y gestiona el ciclo de 24h.
#              Resetea el contador de acciones tras el avance.
# (Esta función ahora es manejada por el motor Python)

# --- Menú Principal ---
while true; do
    # Sincronizar estado antes de mostrar el menú
    call_engine "status"
    draw_sylvie
    show_status
    echo "1) Acariciar cabeza"
    echo "2) Hablar"
    echo "3) Dar dulce"
    echo "4) Salir"
    read -p "Elige una opción: " opt

    case $opt in
        1) pat_head ;;
        2) talk ;;
        3) give_treat ;;
        4) 
            echo "Hasta luego..."
            exit 0 
            ;;
        *) echo "Opción no válida." ; sleep 1 ;;
    esac
done
