📝 QuickNote - Tu bloc de notas inteligente

QuickNote es una aplicación moderna de bloc de notas desarrollada con Flutter, diseñada para ofrecer una experiencia de usuario fluida, elegante y altamente personalizable. Con un enfoque en la simplicidad y la funcionalidad, QuickNote te permite capturar tus ideas de manera rápida y organizarlas eficientemente.

✨ Características Principales

📋 Gestión de Notas
●	✅ CRUD completo: Crear, leer, actualizar y eliminar notas
●	✅ Vista dual: Alterna entre vista de grid y lista
●	✅ Modo selección múltiple: Selecciona varias notas para acciones en lote
●	✅ Ordenamiento personalizable: Ordena por fecha de modificación, creación o título
●	✅ Colores personalizados: Asigna colores a tus notas para mejor organización

🔐 Seguridad y Privacidad
●	✅ Bloqueo con PIN: Protege tus notas con un PIN de 4 dígitos
●	✅ Autenticación biométrica: Desbloquea con huella digital
●	✅ Selector de método: Elige tu método de desbloqueo al iniciar
●	✅ Bloqueo automático: La app se bloquea al minimizarse

🎨 Diseño y Experiencia de Usuario
●	✅ Modo oscuro/claro: Cambia entre temas con un toggle animado
●	✅ Efecto glassmorphism: Interfaz moderna con efectos vidriosos
●	✅ Animaciones fluidas: Transiciones suaves en toda la app
●	✅ Diseño responsive: Adaptable a diferentes tamaños de pantalla

📅 Organización
●	✅ Calendario integrado: Visualiza tus notas por fecha
●	✅ Vista mensual y semanal: Navega entre diferentes vistas de calendario
●	✅ Etiquetas: Organiza tus notas por categorías (próximamente)
●	✅ Favoritos: Marca notas importantes (próximamente)
●	✅ Archivado: Guarda notas que no uses frecuentemente (próximamente)
⚡ Rendimiento y Sincronización
●	✅ Sincronización automática: Mantén tus notas actualizadas
●	✅ Respaldo manual: Crea copias de seguridad de tus notas
●	✅ Reintentos automáticos: Manejo robusto de errores de red
 
●	✅ Caché local: Acceso offline a tus notas
 Información del Desarrollador
●	✅ Perfil del desarrollador: Conoce al creador de QuickNote
●	✅ Enlaces directos: GitHub, Email y LinkedIn
●	✅ Registro de cambios: Historial completo de versiones

🚀 Instalación

Requisitos Previos
●	Flutter SDK (versión 3.11.0 o superior)
●	Dart SDK (versión 3.11.0 o superior)
●	Android Studio / VS Code
●	Git

Pasos de Instalación

# Clonar el repositorio git clone
[https://github.com/JosePablo1996/quicknote_app.git](https://github.com/JosePablo1996/quickn ote_app.git)

# Entrar al directorio cd quicknote_app

# Instalar dependencias flutter pub get

# Ejecutar la app flutter run

🏗 Estructura del Proyecto

lib/
├── screens/
│ ├── note_list_screen.dart	# Pantalla principal de notas
│ ├── note_form_screen.dart	# Crear/editar notas
│ ├── calendar_screen.dart	# Vista de calendario
│ ├── settings_screen.dart	# Configuración de la app
 
│ ├── security_setup_screen.dart # Configuración de seguridad
│ ├── app_lock_screen.dart	# Pantalla de bloqueo
│ ├── auth_method_selector.dart	# Selector de método de autenticación
│ ├── splash_screen.dart	# Pantalla de carga inicial
│ ├── developer_profile_screen.dart # Perfil del desarrollador
│ └── changelog_screen.dart	# Registro de cambios
├── providers/
│ ├── theme_provider.dart	# Gestión del tema oscuro/claro
│ └── security_provider.dart	# Gestión de seguridad
├── models/
│ ├── note.dart	# Modelo de nota
│ └── developer_profile.dart	# Modelo de perfil del desarrollador
├── services/
│ ├── api_service.dart	# Conexión con API REST
│ └── supabase_service.dart	# Servicios de Supabase
├── utils/
│ ├── snackbar_utils.dart	# Snackbars personalizados
│ └── constants.dart	# Constantes de la app
└── widgets/
├── custom_header.dart	# Header personalizado
├── left_menu.dart	# Menú lateral izquierdo
├── note_menu.dart	# Menú de opciones de notas
├── note_card.dart	# Tarjeta de nota
└── empty_state.dart	# Estado vacío animado

🧰 Tecnologías Utilizadas

Tecnología	Versión	Propósito
Flutter	3.11.0+	Framework principal
Dart	3.11.0+	Lenguaje de programación
Provider	6.1.1	Gestión de estado
http	1.2.1	Peticiones HTTP
intl	0.19.0	Formateo de fechas
local_auth	2.2.0	Autenticación biométrica
flutter_secure_storage	9.2.2	Almacenamiento seguro
shared_preferences	2.2.3	Preferencias locales
pin_code_fields	8.0.1	Campos de PIN
pattern_lock	2.0.0	Patrón de desbloqueo
image_picker	1.0.4	Selección de imágenes
url_launcher	6.2.1	Abrir enlaces externos
supabase_flutter	2.0.0	Almacenamiento en la nube
 
📊 Historial de Versiones
v2.1.1 (25 Feb 2026) - Perfil del Desarrollador y Mejoras UI
●	✨ Nueva pantalla: Perfil del Desarrollador
●	🎨 Pantalla de Ajustes simplificada y mejorada
●	🚀 Menús optimizados sin lag
●	📱 Nueva pantalla: Registro de cambios
●	🔧 Eliminadas opciones de Términos y Política de privacidad
●	⚡ Animaciones optimizadas

v2.1.0 (24 Feb 2026) - Sistema de Seguridad
●	🔐 Bloqueo con PIN de 4 dígitos
●	🔐 Autenticación biométrica
●	🎨 Splash screen renovado

v2.0.0 (24 Feb 2026) - Modo Oscuro/Claro
●	🌙 Toggle animado sol/luna
●	🎨 Efectos glassmorphism globales

v1.2.0 (24 Feb 2026) - Mejoras UI/UX
●	📅 Calendario funcional
●	🎨 Selector de color en notas

v1.1.0 (23 Feb 2026) - Mejoras de Interfaz
●	✨ Splash screen animado
●	🎴 NoteCard rediseñado

v1.0.0 (23 Feb 2026) - Versión Inicial
●	🚀 CRUD completo de notas
●	🔌 Conexión con API REST


 Desarrollador

	
Nombre	José Pablo Miranda Quintanilla
Rol	Desarrollador Full Stack
GitHub	@JosePablo1996
Email	Jmirandaquintanilla@gmail.com

