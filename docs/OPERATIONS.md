# Operación local del pipeline

## 1. Alcance y seguridad

Procesar únicamente material cuya descarga y análisis estén autorizados. Crear el workspace fuera de este repositorio; ejemplo: D:\formacion-local. No guardar en GitHub enlaces compartidos, credenciales, videos, audio, transcripts ni capturas. El repositorio contiene proceso, plantillas y código reutilizable, no contenido.

Estructura local recomendada:

    D:\formacion-local\
      00_inbox\          videos descargados
      01_inventory\      manifest y hashes
      02_audio\          audio normalizado
      03_transcripts\    txt, srt, vtt y json
      04_frames\         imágenes de referencia
      05_summaries\      resúmenes con timestamps
      06_index\          índice local de búsqueda
      07_quality\        muestras de referencia y resultados
      logs\

El manifest local debe registrar: identificador interno, ruta, nombre original, SHA-256, duración, idioma esperado, tipo de contenido, número aproximado de hablantes, estado, configuración usada y fecha. Evitar nombres reales o datos personales cuando no sean necesarios.

## 2. Preparación técnica

Instalar localmente un binario de FFmpeg y una implementación de Whisper. No fijar un modelo ni parámetros de producción todavía: ambos son resultado de la validación. Conservar una carpeta separada para pesos de modelos y registrar versión, checksum y licencia en el manifest local.

Comprobar antes de procesar:

- FFmpeg puede leer el video y reportar duración y streams.
- El disco admite originales, audio, transcripciones e imágenes. No borrar originales hasta verificar el lote.
- La carpeta temporal y el workspace tienen permisos de escritura.
- Si hay GPU, anotar modelo de GPU, VRAM, driver y versión de runtime. Si no, usar CPU y medir velocidad real.
- El proceso puede ejecutarse sin conexión después de descargar binarios y pesos.

## 3. Inventario y normalización

1. Copiar o descargar un archivo a 00_inbox.
2. Calcular SHA-256 y registrar el archivo. Si el hash ya existe, marcar como duplicado y no reprocesar.
3. Extraer audio mono a 16 kHz. Mantener el original; no reemplazarlo.
4. Detectar audio vacío, corrupto o con duración anómala antes de llamar al transcriptor.
5. Escribir cada error y reintento en logs con el identificador del archivo.

Mantener un estado finito por archivo: recibido, inventariado, audio_listo, transcrito, revisado, resumido, indexado, fallido. Un archivo fallido no debe detener el lote; se reencola con causa visible.

## 4. Transcripción

La corrida debe ser determinista en lo posible: idioma español explícito, temperatura fija y la misma versión de binario, modelo y parámetros para todo un lote. Persistir el JSON detallado, además de SRT/VTT para revisar subtítulos y TXT para lectura.

Cada salida debe incluir en sus metadatos:

- id del archivo y SHA-256 de origen;
- modelo, versión de motor y parámetros;
- fecha, duración de procesamiento y modo CPU/GPU;
- idioma solicitado y confianza o segmentos reportados;
- versión del pipeline.

No corregir silenciosamente el texto automático. Las correcciones humanas se almacenan como una capa separada con quién, cuándo, motivo y rango temporal.

## 5. Imágenes y resúmenes

Extraer fotogramas únicamente en cambios de escena, inicio de secciones, diapositivas legibles o demostraciones de pantalla. Cada imagen se nombra con id y timestamp, y el resumen sólo la cita si añade evidencia. Revisar manualmente que una captura no exponga información sensible antes de compartirla.

El resumen se elabora desde transcript y timestamps, no desde suposiciones. Debe contener: objetivo, ideas principales, acciones, advertencias, términos relevantes, preguntas abiertas y referencias [id @ hh:mm:ss]. Las afirmaciones importantes conservan al menos un timestamp.

## 6. Lotes y recuperación

Primero se ejecuta la puerta de calidad. Una vez aprobada, procesar en lotes pequeños (por ejemplo 10 a 25 horas de video) y verificar el lote antes de continuar. Hacer una corrida canario con 2 archivos variados al inicio de cada nuevo lote o cambio de entorno.

Detener el lote y abrir incidencia si ocurre cualquiera de estos eventos:

- el audio no corresponde al video o aparece truncado;
- la transcripción se queda sin contenido en una ventana extensa;
- se modifica modelo, binario, parámetros, driver o preprocesamiento sin repetir validación;
- la muestra de auditoría cae bajo el umbral acordado;
- aparecen datos sensibles que requieren mayor control de acceso.

Para reanudar: aislar los archivos afectados, documentar causa, corregir configuración, repetir canario y preservar las salidas previas para trazabilidad.

## 7. Consulta local posterior

Construir el índice únicamente con transcripts aprobados. Partir textos en fragmentos con solapamiento y guardar junto a cada fragmento el id de archivo, rangos de tiempo y hash de la transcript. El chatbot local debe recuperar fragmentos antes de responder y mostrar citas. Si no hay evidencia recuperada, debe responder que no encontró soporte; no inventar.

