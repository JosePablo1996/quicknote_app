# QuickNote 📝

QuickNote es una aplicación de notas moderna y elegante desarrollada con Flutter, diseñada para ofrecer una experiencia de usuario fluida y visualmente atractiva. Con sincronización en la nube, calendario integrado y una interfaz con efectos Liquid Glass, QuickNote transforma la manera de tomar notas.

## 🎯 Características Principales

### 📋 Gestión de Notas
- **CRUD completo**: Crear, leer, actualizar y eliminar notas
- **Categorías personalizables**: Todas, Personal, Trabajo
- **Favoritos**: Marca notas importantes
- **Etiquetas**: Organiza tus notas con etiquetas personalizadas
- **Colores personalizados**: Cada nota puede tener su propio color

### 📅 Calendario Integrado
- **Vista mensual**: Visualiza tus notas por mes
- **Vista semanal**: Organización detallada por semanas
- **Navegación intuitiva**: Cambia entre meses y semanas fácilmente
- **Notas por día**: Al seleccionar un día, muestra todas las notas creadas en esa fecha

### 🎨 Diseño y Experiencia de Usuario
- **Efecto Liquid Glass**: Menús con efecto vidrio y animaciones suaves
- **Tema personalizable**: Selector de colores en tiempo real
- **Animaciones fluidas**: Transiciones y micro-interacciones profesionales
- **Modo claro/oscuro**: Adaptable a las preferencias del sistema
- **Responsive**: Diseño adaptable a diferentes tamaños de pantalla

### ⚙️ Backend en la Nube
- **API RESTful**: Desarrollada con FastAPI (Python)
- **Base de datos PostgreSQL**: Almacenamiento seguro y escalable
- **Hosting en Render**: Disponible 24/7 en la nube
- **Sincronización en tiempo real**: Tus notas siempre actualizadas

### 🔧 Funcionalidades Adicionales
- **Búsqueda**: Encuentra notas rápidamente
- **Pull to refresh**: Actualiza tu lista de notas
- **Snackbars personalizados**: Notificaciones visuales atractivas
- **Empty State**: Diseño especial cuando no hay notas
- **Menús contextuales**: Acciones rápidas en cada nota

## 🏗️ Arquitectura del Proyecto

### Frontend (Flutter)
- **Lenguaje**: Dart
- **Arquitectura**: Clean Architecture con separación por capas
- **Manejo de estado**: Provider + StatefulWidget
- **Peticiones HTTP**: http package
- **Animaciones**: AnimationController personalizado

### Backend (FastAPI)
- **Framework**: FastAPI (Python)
- **Base de datos**: PostgreSQL
- **Hosting**: Render.com
- **API REST**: Endpoints CRUD para notas
- **Autenticación**: (Próximamente)

## 📁 Estructura del Proyecto

quicknote_app/
├── lib/
│ ├── models/ # Modelos de datos
│ ├── screens/ # Pantallas de la app
│ ├── services/ # Servicios (API, etc.)
│ ├── utils/ # Utilidades y helpers
│ └── widgets/ # Widgets reutilizables
├── assets/ # Imágenes, iconos, fuentes
└── test/ # Pruebas unitarias


## 🚀 Enlaces

- **Repositorio Backend**: [API Notas Personales](https://github.com/JosePablo1996/api-notas-personales)
- **API en producción**: [https://api-notas-personales.onrender.com](https://api-notas-personales.onrender.com)
- **Documentación API**: [https://api-notas-personales.onrender.com/docs](https://api-notas-personales.onrender.com/docs)

## 📊 Estado del Proyecto

✅ **Semana 1 completada** - UI/UX y funcionalidades básicas
- [x] Header personalizado con menús
- [x] Menú lateral izquierdo con Liquid Glass
- [x] Menú lateral derecho con animaciones
- [x] Calendario integrado (vistas mensual/semanal)
- [x] Selector de colores para notas
- [x] CRUD completo de notas
- [x] Snackbars personalizados
- [x] Empty State animado

🚧 **Semana 2 (Próximamente)**
- [ ] Tema claro/oscuro persistente
- [ ] Búsqueda en tiempo real
- [ ] Categorías y etiquetas avanzadas
- [ ] Compartir notas
- [ ] Notas de voz
- [ ] Widgets para pantalla de inicio


## 🛠️ Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.16+
- Dart 3.2+
- Android Studio / VS Code
- Git

### Pasos para ejecutar localmente

```bash
# Clonar el repositorio
git clone https://github.com/JosePablo1996/quicknote_app.git

# Entrar al directorio
cd quicknote_app

# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run

👨‍💻 Autor

Jose Pablo Miranda Quintanilla- @JosePablo1996