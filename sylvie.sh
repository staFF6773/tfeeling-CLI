#!/bin/bash

# ==============================================================================
# Script: sylvie.sh
# Descripción: Simulador interactivo basado en "Teaching Feeling".
#              Gestiona el sistema de afecto, confianza, tiempo y diálogos.
# Autor: Antigravity Assistant
# Versión: 2.0.0
# ==============================================================================

# --- Definición de Rutas y Estilos ---
DATA_FILE="$HOME/.sylvie_data"    # Archivo de persistencia de datos del usuario
COLOR_RESET="\e[0m"              # Reset de formato ANSI
COLOR_PINK="\e[1;35m"             # Color para temática de Sylvie
COLOR_CYAN="\e[1;36m"             # Color para información del sistema
COLOR_WHITE="\e[1;37m"            # Color para texto general
COLOR_GRAY="\e[0;90m"             # Color para separadores y decoraciones

# --- Inicialización del Sistema de Persistencia ---
# Verifica la existencia del archivo de datos y crea uno nuevo con valores 
# predeterminados por primera vez.
if [ ! -f "$DATA_FILE" ]; then
    cat <<EOF > "$DATA_FILE"
affection=0
trust=0
name=Sylvie
last_action=none
time_of_day=morning
hour=8
minute=0
actions_taken=0
EOF
fi

# Cargar datos
source "$DATA_FILE"

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
# @description Guarda el estado actual de todas las variables globales en el archivo de datos.
save_data() {
    cat <<EOF > "$DATA_FILE"
affection=$affection
trust=$trust
name=$name
last_action=$last_action
time_of_day=$time_of_day
hour=$hour
minute=$minute
actions_taken=$actions_taken
EOF
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
    affection=$((affection + 2))
    trust=$((trust + 1))
    last_action="pat_head"
    actions_taken=$((actions_taken + 1))
    save_data
    draw_sylvie
    echo -e "${COLOR_PINK}Acaricias suavemente la cabeza de Sylvie.${COLOR_RESET}"
    echo -e "${COLOR_WHITE}Sylvie: ${COLOR_RESET}$(get_dialogue $affection "none" $last_action $time_of_day)"
    sleep 2
}

# @function give_treat
# @description Acción de regalar un dulce. Gran incremento de afecto y confianza.
#              Avanza el contador de acciones.
give_treat() {
    affection=$((affection + 5))
    trust=$((trust + 2))
    last_action="give_treat"
    actions_taken=$((actions_taken + 1))
    save_data
    draw_sylvie
    echo -e "${COLOR_CYAN}Le das un dulce a Sylvie.${COLOR_RESET}"
    echo -e "${COLOR_WHITE}Sylvie: ${COLOR_RESET}$(get_dialogue $affection "treat" $last_action $time_of_day)"
    sleep 2
}

# @function talk
# @description Acción de conversación. Diálogos variados según estadísticas.
#              Avanza el contador de acciones.
talk() {
    draw_sylvie
    echo -e "${COLOR_CYAN}Hablas con Sylvie.${COLOR_RESET}"
    echo -e "${COLOR_WHITE}Sylvie: ${COLOR_RESET}$(get_dialogue $affection "none" $last_action $time_of_day)"
    sleep 2
    actions_taken=$((actions_taken + 1))
    save_data
}

# --- Motor de Tiempo ---

# @function update_time_of_day
# @description Sincroniza la etiqueta descriptiva del día según la hora actual (0-23).
update_time_of_day() {
    if [ "$hour" -ge 6 ] && [ "$hour" -lt 12 ]; then
        time_of_day="morning"
    elif [ "$hour" -ge 12 ] && [ "$hour" -lt 18 ]; then
        time_of_day="afternoon"
    else
        time_of_day="night"
    fi
}

# @function advance_time
# @description Avanza el reloj interno 30 minutos y gestiona el ciclo de 24h.
#              Resetea el contador de acciones tras el avance.
advance_time() {
    minute=$((minute + 30))
    if [ "$minute" -ge 60 ]; then
        minute=0
        hour=$((hour + 1))
    fi
    
    if [ "$hour" -ge 24 ]; then
        hour=0
    fi
    
    update_time_of_day
    actions_taken=0
    save_data
}

# --- Menú Principal ---
while true; do
    update_time_of_day
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

    # Cada 2 acciones avanzamos el tiempo para que no sea tan lento
    if [ "$actions_taken" -ge 2 ]; then
        echo -e "${COLOR_GRAY}Ha pasado un tiempo...${COLOR_RESET}"
        sleep 1
        advance_time
    fi
done
