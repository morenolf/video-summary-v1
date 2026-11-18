# Checklist de avance gradual

Este checklist transforma el diseño en ejecuciones pequeñas y reversibles. No autoriza procesamiento masivo.

## Punto 0 — Preparar, sin material de formación

Objetivo: demostrar que el entorno puede trabajar localmente.

1. Crear un workspace fuera del repositorio con scripts/Initialize-Workspace.ps1.
2. Instalar o señalar las rutas locales de FFmpeg y Whisper.
3. Ejecutar scripts/Test-Prerequisites.ps1 contra el workspace.
4. Conservar el informe local y no subirlo si contiene rutas o datos personales.

Ejemplo desde la carpeta clonada del repositorio:

    .\scripts\Initialize-Workspace.ps1 -WorkspacePath "D:\formacion-local"
    .\scripts\Test-Prerequisites.ps1 -WorkspacePath "D:\formacion-local"

Si los binarios no están en PATH, señalar los ejecutables sin instalar ni descargar contenido de formación:

    .\scripts\Test-Prerequisites.ps1 -WorkspacePath "D:\formacion-local" -FfmpegCommand "D:\herramientas\ffmpeg.exe" -WhisperCommand "D:\herramientas\whisper-cli.exe"

Se puede pasar al punto 1 sólo cuando el informe indique ready_for_smoke_test: true.

## Punto 1 — Prueba de humo: un clip de 3 a 5 minutos

Objetivo: comprobar el recorrido completo, no medir aún la calidad final.

Elegir un único fragmento con autorización y copiarlo al inbox local. Verificar:

- FFmpeg lee el archivo y la duración coincide con el reproductor.
- Se genera audio normalizado sin recortar el final.
- Whisper devuelve TXT, SRT/VTT y JSON con timestamps.
- El texto no está vacío y corresponde al idioma esperado.
- Se escuchan tres puntos (inicio, medio y final) y el timestamp no se desvía de forma evidente.
- Las salidas llevan el identificador y hash del origen.

Cualquier fallo devuelve al punto 0. No se arregla manualmente la salida para declarar éxito.

## Punto 2 — Piloto de archivo real: una ventana de 8 a 12 minutos

Objetivo: evaluar una configuración sobre contenido representativo.

Ejecutar una sola configuración candidata, revisar el audio y construir una referencia humana para ese clip. Registrar tiempo de ejecución, errores visibles, cobertura y diez términos importantes. Este punto permite descubrir problemas de acento, ruido, solapamiento o vocabulario antes de invertir más cómputo.

El resultado sólo habilita el punto 3; no habilita un lote.

## Punto 3 — Validación formal: 8 clips estratificados

Aplicar exactamente docs/QUALITY_GATE.md:

- seis clips de calibración para elegir configuración;
- dos clips reservados de aceptación;
- WER, cobertura, recuperación de glosario, timestamps y errores materiales;
- decisión escrita: aprobar, ajustar/repetir o rechazar.

Sólo una decisión aprobada permite procesar el primer lote limitado.

## Punto 4 — Producción controlada

Primer lote: 10 a 25 horas como máximo, con dos archivos canario antes de comenzar. Auditar como mínimo el 2% de archivos o 30 minutos por cada 10 horas. Parar ante una caída de calidad, cambio de configuración o datos sensibles inesperados.

## No avanzar si

- no hay informe de requisitos satisfactorio;
- se cambió modelo, binario, parámetros o preprocesamiento;
- no existe referencia humana para la fase de calidad;
- se pretende inferir calidad a partir de un resumen o chatbot;
- la muestra no representa ruido, voces y tipos de contenido del lote real.
