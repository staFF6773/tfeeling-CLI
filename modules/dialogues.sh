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
    "¿Por qué no me dejas ir?"
    "No confío en lo que haces... pero no sé por qué..."
    "Me siento perdida aquí..."
    "Mis manos tiemblan cuando estás cerca..."
    "Quiero creer que me cuidas, pero no puedo..."
    "¿Estás seguro de que es seguro estar aquí?"
    "No sé si debo creer tus palabras..."
    "¿Me dejarías ir algún día?"
    "Nunca pensé que alguien me haría sentir así..."
    "Cada vez que te acercas, siento un nudo en el estómago..."
    "No sé si me siento más a salvo o más atrapada..."

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
    "¿Qué opinas de este lugar? Es diferente a lo que imaginaba."
    "A veces, me pregunto qué haría si pudiera salir un día."
    "Nunca había tenido un día tan tranquilo antes."
    "Me siento más fuerte, pero aún tengo miedo."
    "Hoy me siento como si pudiera aprender algo nuevo..."
    "¿Le gusta el café o el té? He visto que hay opciones."
    "¿Qué haría si pudiera decidir algo por mí misma?"
    "Gracias por todo lo que haces por mí."
    "¿Suele caminar por aquí? Es un buen lugar para reflexionar."
    "Me pregunto si alguna vez podré ser más útil para ti."

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
    "Cada día me siento más tranquila a tu lado."
    "Me has dado más de lo que jamás imaginé..."
    "El simple hecho de escuchar tu voz me hace sonreír."
    "No sé cómo agradecerte por todo lo que has hecho por mí."
    "Quiero que sepas que siempre estaré aquí para ti también."
    "Cuando me abrazas, siento que todo está bien."
    "Tu bondad es algo que nunca dejaré de admirar."
    "Estar a tu lado es el lugar donde más feliz me siento."
    "A veces me siento tan afortunada de tenerte cerca."
    "Eres mi refugio, mi protector, mi amigo."

)

# --- Diálogos por Acción ---
ACTION_PAT_HEAD_LOW=(
    "E-está bien..."
    "Me pones nerviosa..."
    "..."
    "¿Mis cabellos no están sucios?"
    "No estoy acostumbrada a esto..."
    "Eso... me incomoda un poco."
    "No estoy segura de cómo me siento con esto..."
    "Creo que debería acostumbrarme..."
    "¿Me va a doler si me tocas de nuevo?"
    "No me lo esperaba..."

)
ACTION_PAT_HEAD_HIGH=(
    "Me encanta cuando haces eso."
    "Tu mano es tan suave..."
    "Me haces sentir muy querida."
    "Podría quedarme así horas..."
    "Me hace sentir como si fuera especial para ti."
    "Es tan reconfortante..."
    "Me haces sentir protegida."
    "Nunca quiero que dejes de acariciarme..."
    "Es tan relajante estar cerca de ti."
    "Me gusta cuando me acaricias la cabeza, me hace sentir especial."

)

ACTION_TREAT_LOW=(
    "¿Es para mí? Gracias..."
    "Sabe bien..."
    "Gracias por la comida..."
    "¿Seguro que puedo comerlo?"
    "Tiene un sabor muy agradable..."
    "¿Me dejarías probar más? Esto sabe tan bien..."
    "Está bien... No es lo que esperaba, pero está bien."
    "No estoy acostumbrada a que me den cosas como esta..."
    "Gracias, pero... ¿seguro que no es para ti?"
    "¿Debería aceptar todo lo que me das?"

)
ACTION_TREAT_HIGH=(
    "¡Está delicioso! ¡Muchas gracias, maestro!"
    "¡Me encanta el dulce!"
    "Eres muy detallista conmigo."
    "Sabe a felicidad... ¡muchas gracias!"
    "¡Es mi favorito! ¿Cómo lo supo?"
    "¡Esto es increíble! Gracias por pensar en mí."
    "¿Cómo supiste que me gustaba tanto?"
    "Es perfecto... ¿puedo tener un poco más?"
    "Este sabor... nunca había probado algo tan bueno."
    "¡Me haces sentir tan especial con estos detalles!"

)

# --- Diálogos por Tiempo ---
TIME_MORNING=(
    "Buenos días, maestro."
    "El sol acaba de salir..."
    "¿Ya es hora de despertar?"
    "Espero que hoy sea un gran día para ambos."
    "El aire de la mañana es muy fresco."
    "Hoy parece ser un día brillante."
    "¿Es un buen día para salir?"
    "¿Qué vamos a hacer hoy, maestro?"
    "La luz del sol hace que todo se vea tan bonito."
    "Espero que tengas un buen día por delante."

)
TIME_AFTERNOON=(
    "La tarde es muy tranquila, ¿verdad?"
    "¿Quieres tomar un poco de té?"
    "El día está siendo muy agradable."
    "Me gusta ver cómo cambian las sombras."
    "¿Necesitas ayuda con algo hoy?"
    "La tarde está tan calmada. ¿Hacemos algo juntos?"
    "Ya es tarde... ¿no deberíamos descansar un poco?"
    "Me gusta estar contigo cuando el día está tan tranquilo."
    "¿Es tarde ya? El tiempo pasa tan rápido."
    "El sol empieza a ponerse, el cielo se ve tan bonito."

)
TIME_NIGHT=(
    "Ya es muy tarde..."
    "Las estrellas se ven hermosas hoy."
    "Buenas noches, maestro... que descanses."
    "El silencio de la noche es reconfortante contigo cerca."
    "Espero que tengas lindos sueños."
    "¿Necesitas algo más?"
    "¿Quieres que te ayude a descansar?"
    "Me siento tan agradecida por tener un lugar seguro."
    "¿Quieres que te ayude a descansar?"
    "Es hora de descansar, ¿verdad?"
    "¿Te parece si hablamos un poco antes de dormir?"
    "¿Me contarías un cuento para dormir?"
    "Las estrellas se ven tan lejanas, pero al mismo tiempo cerca."
    "Siempre me siento más tranquila cuando es de noche."

)
