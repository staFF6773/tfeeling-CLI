# ==============================================================================
# Script: dialogues.sh
# Descripción: Base de datos de diálogos para el simulador de Sylvie.
#              Los diálogos están estructurados en arrays asociativos por contexto.
# Uso: Este archivo debe ser 'sourced' por el script principal (sylvie.sh).
# ==============================================================================

# --- Diálogos de Sylvie ---

# Diálogos de Desconfianza (Afecto < 20 o Confianza < 10)
DISTRUST_DIALOGUES=(
    "..."
    "P-por favor, no me pegues..."
    "¿Qué... qué vas a hacerme?"
    "Me duele un poco todo..."
    "Tengo miedo..."
    "..."
    "¿Por qué eres tan amable? No lo entiendo..."
    "No me toques de repente, por favor..."
    "..."
    "¿Mañana también estaré aquí?"
    "No estoy acostumbrada a que me hablen así..."
    "¿E-está bien si me quedo en ese rincón?"
    "Si hago algo mal... ¿me castigará?"
    "Siento ser una molestia..."
    "Intentaré no estorbar..."
    "El silencio me pone nerviosa..."
    "¿Por qué me miras tanto?"
    "Cualquier cosa que pidas... la haré."
    "No sé cómo reaccionar a esto..."
    "Aún me cuesta creer que no estoy allí..."
)

# Diálogos Neutrales (Afecto 20-60 o Confianza 10-30)
NEUTRAL_DIALOGUES=(
    "Gracias por la comida."
    "Este lugar es bastante tranquilo."
    "¿Qué vamos a hacer hoy?"
    "Me gusta cuando el sol entra por la ventana."
    "¿Maestro...?"
    "Poco a poco me voy sintiendo mejor."
    "Gracias por cuidarme."
    "¿Te gusta estar conmigo?"
    "Me gusta este vestido..."
    "Hoy me siento con un poco más de energía."
    "¿Cree que algún día podré serte útil?"
    "Todavía me sorprendo de lo suave que es la cama."
    "He aprendido a que no todas las manos duelen."
    "Me pregunto qué habrá de cenar hoy..."
    "¿Le gusta leer? He visto algunos libros..."
    "Gracias por dejarme pasear un poco."
    "A veces me pierdo mirando el cielo."
    "¿Puedo sentarme cerca de usted?"
    "Su voz... es muy calmada."
    "He estado pensando en lo que dijo ayer..."
)

# Diálogos de Confianza (Afecto > 60 y Confianza > 30)
TRUST_DIALOGUES=(
    "Me siento muy segura a tu lado."
    "Gracias por salvarme de aquel lugar horrible."
    "Eres la persona más amable que he conocido."
    "Me gusta estar cerca de ti."
    "Tu mano es muy cálida, maestro."
    "Siempre quiero estar contigo."
    "Me haces muy feliz."
    "A veces me pregunto qué habría sido de mí sin ti..."
    "Me gusta cuando me sonríes."
    "¿Puedo quedarme a tu lado para siempre?"
    "Cada día que paso aquí es como un sueño."
    "Ojalá el tiempo se detuviera cuando estamos así."
    "Ya no tengo pesadillas cuando sé que estás cerca."
    "Gracias por darme un nombre y un hogar."
    "Maestro... eres mi mundo entero."
    "Me gusta escuchar los latidos de tu corazón."
    "Prometo cuidarte tanto como tú me cuidas a mí."
    "Me siento tan ligera cuando estoy contigo..."
    "Nunca imaginé que alguien podría quererme así."
    "Eres mi salvador y mi mejor amigo."
)

# --- Diálogos por Acción ---
ACTION_PAT_HEAD_LOW=(
    "E-está bien..."
    "Me pones nerviosa..."
    "..."
    "¿Mis cabellos no están sucios?"
    "No estoy acostumbrada a esto..."
)
ACTION_PAT_HEAD_HIGH=(
    "Me encanta cuando haces eso."
    "Tu mano es tan suave..."
    "Me haces sentir muy querida."
    "Podría quedarme así horas..."
    "Me hace sentir como si fuera especial para ti."
)

ACTION_TREAT_LOW=(
    "¿Es para mí? Gracias..."
    "Sabe bien..."
    "Gracias por la comida..."
    "¿Seguro que puedo comerlo?"
    "Tiene un sabor muy agradable..."
)
ACTION_TREAT_HIGH=(
    "¡Está delicioso! ¡Muchas gracias, maestro!"
    "¡Me encanta el dulce!"
    "Eres muy detallista conmigo."
    "Sabe a felicidad... ¡muchas gracias!"
    "¡Es mi favorito! ¿Cómo lo supo?"
)

# --- Diálogos por Tiempo ---
TIME_MORNING=(
    "Buenos días, maestro."
    "El sol acaba de salir..."
    "¿Ya es hora de despertar?"
    "Espero que hoy sea un gran día para ambos."
    "El aire de la mañana es muy fresco."
)
TIME_AFTERNOON=(
    "La tarde es muy tranquila, ¿verdad?"
    "¿Quieres tomar un poco de té?"
    "El día está siendo muy agradable."
    "Me gusta ver cómo cambian las sombras."
    "¿Necesitas ayuda con algo hoy?"
)
TIME_NIGHT=(
    "Ya es muy tarde..."
    "Las estrellas se ven hermosas hoy."
    "Buenas noches, maestro... que descanses."
    "El silencio de la noche es reconfortante contigo cerca."
    "Espero que tengas lindos sueños."
)
