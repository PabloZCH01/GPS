# OrbitLink · Rastreo GPS en Tiempo Real y Walkie-Talkie PTT para Android

**OrbitLink** es una plataforma completa de localización en tiempo real, zonas seguras (geovallas) y comunicación de voz **Walkie-Talkie (Push-To-Talk)** de baja latencia para dispositivos Android (celulares, plegables y tablets), estructurada en un monorrepo multimódulo en Kotlin.

---

## Arquitectura del Proyecto

```text
OrbitLink/
├── protocol/   # Módulo Kotlin JVM compartido: contratos REST, protocolo WebSocket, códec de audio G.711 µ-law y tramas binarias
├── server/     # Backend en tiempo real con Ktor 3 + Netty: gestión de círculos, presencia, historial GPS, alertas SOS y arbitraje PTT
└── app/        # Aplicación Android nativa (Jetpack Compose Material 3 Adaptive, Hilt, Room, DataStore, Ktor, MapLibre, FusedLocation)
```

### Tecnologías Principales
- **UI Moderna y Adaptable:** Jetpack Compose + **Material 3 Adaptive (`NavigationSuiteScaffold`)** + layouts responsivos que alternan automáticamente entre barra inferior en móviles y paneles laterales de cristal (`GlassCard`) en tablets y pantallas grandes.
- **Inyección de Dependencias y Persistencia:** **Hilt (Dagger)** + **Room** (caché offline-first de círculos y último estado conocido de miembros) + **Preferences DataStore**.
- **Rastreo GPS en Segundo Plano:** `TrackingService` (`LifecycleService` con `foregroundServiceType="location"`), perfiles configurables de telemetría (`REALTIME 3s`, `BALANCED 10s`, `SAVER 30s`), nivel de batería/carga, modo fantasma con un toque y motor de geovallas con histéresis (`PlaceMonitor`).
- **Walkie-Talkie Push-To-Talk (PTT):** Captura de voz PCM 16 kHz mono con `AudioRecord` (`VOICE_COMMUNICATION`, `AcousticEchoCanceler` y `NoiseSuppressor`), compresión en **G.711 µ-law** (640 muestras / 40 ms por trama), control de turno en el servidor (*floor control*: un orador activo por círculo) y reproducción con `AudioTrack` en modo de baja latencia con `preroll` anti-jitter.
- **Cartografía Interactiva sin Claves de API:** **MapLibre Native Android** con 3 estilos (`Oscuro`, `Satélite`, `Claro`), marcadores dinámicos con iniciales y halo de estado, polígonos de zonas seguras y polilínea de historial de recorrido.

---

## Cómo Ejecutar el Proyecto

### 1. Iniciar el Servidor en Tiempo Real (`:server`)
Desde una terminal en la raíz del proyecto:

```powershell
.\gradlew.bat :server:run
```

El servidor escuchará en `0.0.0.0:8080` y guardará el estado de usuarios y círculos en `server/data/state.json`.

### 2. Compilar e Instalar la App Android (`:app`)
Abre el proyecto en **Android Studio** y ejecuta el módulo `app`, o compila el APK desde la terminal:

```powershell
.\gradlew.bat :app:assembleDebug
```

El APK generado estará en `app/build/outputs/apk/debug/app-debug.apk`.

### 3. Conectar Varios Dispositivos
- **En el Emulador Android:** La URL predeterminada (`http://10.0.2.2:8080`) apunta automáticamente al servidor que corre en tu PC.
- **En Celulares o Tablets Físicos (misma red Wi-Fi):** En la pantalla de bienvenida o en **Ajustes → Servidor OrbitLink**, ingresa la dirección IP local de tu PC (por ejemplo, `http://192.168.1.50:8080`).
- **Vincular dispositivos:** En el primer dispositivo ve a **Círculos → Crear** y comparte el código de 6 caracteres (`ABC-DEF`). En los demás dispositivos elige **Círculos → Unirse** e introduce ese código.

---

## Ejecutar las Pruebas Automatizadas

```powershell
.\gradlew.bat :protocol:test :server:test :app:testDebugUnitTest
```

