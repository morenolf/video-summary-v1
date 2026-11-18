# Puerta de calidad de transcripción

La calidad se valida antes de ejecutar un lote masivo. Una demostración con un video fácil no es evidencia suficiente.

## Objetivo

Elegir una combinación de motor, modelo y preprocesamiento que mantenga palabras y conceptos útiles, timestamps utilizables y cobertura suficiente para formación y llamadas en español. La decisión es explícita: aprobar, ajustar y repetir, o rechazar.

## Diseño de muestra

Construir una muestra estratificada y congelarla en el manifest local. Incluir al menos:

- 8 clips de 8 a 12 minutos, de archivos distintos;
- voz limpia y voz con ruido;
- una y varias personas;
- micrófonos, acentos y velocidad de habla diferentes;
- vocabulario de negocio/técnico y nombres propios;
- una demostración de pantalla si existe.

No elegir sólo el principio de cada archivo. Seleccionar ventanas con semilla anotada, sin solapamientos, y reservar dos clips como conjunto de aceptación: no se usan para escoger parámetros.

## Referencia humana

Para cada clip, crear una transcript de referencia revisada por una segunda persona. Conservar palabras relevantes, números, URLs y términos propios; marcar inteligible, ininteligible y solapamientos según una guía estable. Esta referencia no se publica ni se envía a un servicio externo.

Antes de medir, normalizar ambos textos de la misma forma: minúsculas, espacios, puntuación definida, números con una regla única y muletillas conforme a la política acordada. Guardar el original y el normalizado.

## Candidatos

Probar al menos dos configuraciones razonables en los clips de calibración; por ejemplo, un modelo equilibrado y otro más preciso. Mantener fijos idioma, preprocesamiento y parámetros durante la comparación. Documentar tiempo real por hora de audio y recursos usados, además de calidad.

Elegir la configuración sobre calibración y verificarla una sola vez sobre los dos clips reservados. No ajustar parámetros después de mirar el conjunto reservado: si hace falta ajustar, crear una nueva reserva.

## Métricas

Medir y registrar por clip y globalmente:

- WER: (sustituciones + eliminaciones + inserciones) / palabras de referencia.
- Recuperación de glosario: proporción de términos críticos correctamente transcritos.
- Cobertura: porcentaje de duración con habla que tiene texto correspondiente.
- Error de timestamp: diferencia absoluta contra puntos de referencia auditados.
- Segmentos críticos: cantidad de números, nombres, URLs, decisiones o instrucciones con error material.
- Velocidad: minutos de proceso por minuto de audio y uso de CPU/GPU.
- Revisión cualitativa: ¿se entiende sin volver al audio?, ¿faltan frases?, ¿hay repeticiones o texto ajeno?

Un WER bueno no basta: un error en un importe, contraseña, nombre de producto o decisión puede tener alto impacto. Esos casos se anotan por separado.

## Umbrales iniciales de aprobación

Los siguientes son puntos de partida y se ajustan al caso de uso antes de aprobar:

| Métrica | Material limpio | Muestra global |
| --- | ---: | ---: |
| WER | hasta 15% | hasta 22% |
| Recuperación de glosario crítico | 97% o más | 95% o más |
| Cobertura de habla | 98% o más | 95% o más |
| Error de timestamp p90 | hasta 2 segundos | hasta 4 segundos |
| Errores materiales en segmentos críticos | 0 | 0 |

La aceptación exige cumplir todos los umbrales en los clips reservados y no tener regresiones importantes en los demás estratos. Si se usará para decisiones, soporte al cliente o información regulada, endurecer los umbrales y exigir revisión humana.

## Protocolo de decisión

1. Preparar el manifest de muestra y las referencias humanas.
2. Ejecutar candidatos sobre calibración.
3. Comparar métricas, costos de cómputo y errores materiales.
4. Elegir una configuración y congelarla: motor, versión, modelo, idioma, parámetros y preprocesamiento.
5. Ejecutarla una vez en el conjunto reservado.
6. Registrar decisión y firma/fecha del responsable local: aprobado, repetir o rechazado.
7. Sólo si está aprobado, iniciar el primer lote limitado.

## Vigilancia durante producción

- Canary: dos archivos variados antes de cada lote o cada cambio de máquina.
- Auditoría: revisar manualmente una muestra aleatoria de al menos 2% de los archivos o 30 minutos por cada 10 horas, lo que resulte mayor.
- Alerta: investigar si el WER estimado, la cobertura o la recuperación de glosario cae más de 3 puntos respecto del piloto.
- Revalidación completa: obligatoria al cambiar modelo, binario, parámetros, idioma, VAD, preprocesamiento, GPU/driver de forma significativa o tipo de material.

Una respuesta del chatbot no se considera validación de una transcript. Debe evaluarse contra audio y referencia humana.

## Registro mínimo de resultado

    fecha, id_clip, conjunto(calibracion|aceptacion|auditoria),
    motor, version_motor, modelo, parametros, preprocesamiento,
    duracion_audio, tiempo_proceso, WER, cobertura, p90_timestamp,
    glosario_total, glosario_correcto, errores_materiales,
    revisor, resultado, observaciones

