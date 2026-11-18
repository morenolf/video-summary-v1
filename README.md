# Video Summary Local

Proceso local, reproducible y privado para convertir videos de formación y llamadas autorizadas en transcripciones con marcas de tiempo, resúmenes con evidencia visual y una base consultable.

## Principios

- El audio, los videos, las transcripciones y los enlaces de origen nunca se suben a GitHub.
- La inferencia se ejecuta localmente; no se usa una API de transcripción.
- Cada respuesta posterior debe poder indicar video y timestamp de la evidencia.
- No se procesa masivamente hasta superar la puerta de calidad documentada en [docs/QUALITY_GATE.md](docs/QUALITY_GATE.md).

## Qué produce

1. Inventario local de archivos, duración, hash y estado.
2. Audio normalizado y transcripción TXT, SRT, VTT y JSON por video.
3. Un resumen factual con acciones, conceptos y timestamps.
4. Imágenes de referencia seleccionadas por cambios visuales o secciones, no capturas indiscriminadas.
5. Un índice local para recuperar fragmentos y responder preguntas citando su fuente.

## Inicio seguro

1. Seguir [docs/PILOT_CHECKLIST.md](docs/PILOT_CHECKLIST.md): prepara el entorno y limita cada avance.
2. Crear un workspace local con [scripts/Initialize-Workspace.ps1](scripts/Initialize-Workspace.ps1).
3. Verificar binarios, espacio y GPU opcional con [scripts/Test-Prerequisites.ps1](scripts/Test-Prerequisites.ps1).
4. Ejecutar una prueba de humo de 3 a 5 minutos; después, un único piloto de 8 a 12 minutos.
5. Aplicar la validación estratificada y ciega de [docs/QUALITY_GATE.md](docs/QUALITY_GATE.md).
6. Sólo con una aprobación explícita, procesar el primer lote limitado. Nunca lanzar el lote completo por una única prueba satisfactoria.

## Herramientas elegidas

- FFmpeg: inspección de medios, extracción de audio y fotogramas.
- Whisper local: whisper.cpp o faster-whisper. La configuración definitiva se decide con el piloto.
- Base local de búsqueda y LLM local opcional: se incorpora sólo cuando ya existan transcripciones validadas.
- Los pesos de modelos y los binarios se descargan una vez, pero no son parte del repositorio.

## Límites deliberados

La diarización de hablantes no se considera fiable por defecto y no bloquea la transcripción inicial. Se añadirá sólo si el piloto demuestra valor y calidad suficiente. Los resúmenes no sustituyen la fuente: deben enlazar a timestamps.

## Estructura versionada

- docs/OPERATIONS.md: operación, privacidad, lotes e incidentes.
- docs/PILOT_CHECKLIST.md: avance gradual y puntos de detención.
- docs/QUALITY_GATE.md: diseño de validación, métricas, umbrales y decisión.
- scripts/: preparación local y preflight técnico.
- .gitignore: barreras para que datos sensibles y modelos no entren al repositorio.
