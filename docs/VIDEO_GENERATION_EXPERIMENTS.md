# Estrategia experimental para video generativo de producto

Este documento evita una receta única ("un frame", "muchos frames", "prompt largo" o "prompt corto"). La meta es aprender, con pruebas pequeñas y trazables, qué combinación conserva el producto, representa la acción y produce una toma útil al menor costo.

No se sube ningún frame, video ni otro material a un servicio de generación sin una autorización específica. El análisis, la selección de frames y el registro de pruebas pueden hacerse localmente.

## Principio operativo

Una toma generada combina dos problemas que deben evaluarse por separado:

1. **Identidad del producto:** silueta, color, material, controles, cable/accesorios y proporciones.
2. **Dirección de la toma:** acción, manos, encuadre, cámara, duración y transición.

Una referencia visual puede fijar mejor la identidad, pero también puede quitar libertad al movimiento. En Firefly, añadir un primer cuadro inhabilita controles como tamaño de plano, ángulo, estilo y referencia de composición; añadir también el último cuadro inhabilita el control de movimiento. Por eso los dos extremos no se usan por defecto: se reservan para la hipótesis de que el final exacto importa más que esos controles.

El prompt no compensa una referencia mal elegida ni una acción demasiado amplia. Debe describir sólo lo que el sistema necesita decidir: sujeto, acción, contexto, encuadre/cámara y restricciones críticas. La guía de Adobe también recomienda prompts estructurados y concisos.

## Preparación local de referencias

Para cada acción, crear una tarjeta de toma local. No se usan todos los fotogramas del clip por inercia.

| Activo local | Para qué sirve | Criterio de selección |
|---|---|---|
| Frame de inicio | Identidad y composición inicial | Producto completo, nítido, sin mano tapando controles importantes |
| Frame de detalle | Verificar rasgos no negociables | Control, conector, textura o logotipo que no puede cambiar |
| Frame de destino | Sólo si el resultado debe cerrar exactamente allí | Pose y producto físicamente alcanzables desde el inicio |
| Segmento de movimiento | Entender la acción de referencia | Una sola acción clara, sin corte ni cambio de intención |

Una toma larga con varias acciones se divide antes de generar. Los cambios de escena detectados automáticamente son candidatos; la revisión humana decide si son realmente un nuevo plano o sólo movimiento.

## Hipótesis iniciales

Se prueban en este orden. Cada resultado lleva configuración, prompt, referencias, semilla si existe, duración, créditos/costo y rúbrica. Nunca se cambia todo a la vez.

| ID | Hipótesis | Configuración controlada | Qué demostraría |
|---|---|---|---|
| H1 | Un solo frame inicial deja suficiente libertad para la acción | Inicio + prompt conciso + movimiento de cámara, sin frame final | La identidad se mantiene y la acción ocurre sin deformar el producto |
| H2 | El frame final mejora una transición que ya deriva | Mismo inicio y prompt que H1 + destino | El cierre mejora más de lo que se pierde en control de cámara/movimiento |
| H3 | Un detalle del producto resuelve una deriva de identidad | Reemplazar o mejorar sólo la referencia de inicio; no alargar el prompt | Mejoran los rasgos críticos sin empeorar la acción |
| H4 | La instrucción mínima es más robusta que una instrucción recargada | Misma referencia y controles; prompt conciso vs. extendido | Se elige el que gana la rúbrica, no el que "suena" mejor |
| H5 | Dos clips de una acción cada uno superan un clip largo | Misma intención total, generada por segmentos | Mejor continuidad y menos errores por crédito consumido |

No es un diseño factorial completo: sería caro y no enseña rápido. Se empieza con dos variantes que sólo difieran en una decisión. Sólo la variante prometedora recibe réplicas.

## Escalera de pruebas y presupuesto

1. Definir una tarjeta de toma y sus rasgos no negociables.
2. Generar previews breves y de menor costo de H1. Usar dos intentos independientes si la herramienta no expone semilla.
3. Puntuar, conservar evidencia y descartar fallos claros.
4. Si el fallo es de identidad, probar H3; si es de cierre, H2; si son varias acciones, H5. No saltar directamente a más texto.
5. Repetir la mejor configuración dos o tres veces para medir variación.
6. Sólo entonces invertir en duración, resolución, extensión, audio, edición o múltiples versiones.

Se detiene una rama después de dos fallos equivalentes sin una hipótesis nueva. Se prohíbe aumentar resolución o duración para "arreglar" identidad, física de manos o continuidad: sólo aumenta el costo del mismo riesgo.

## Rúbrica de selección

Puntuar cada eje de 0 a 2; un 0 en identidad crítica o interacción física descarta el clip aunque el total sea alto.

| Eje | 0 | 1 | 2 |
|---|---|---|---|
| Identidad del producto | Cambia rasgos críticos | Conserva lo general, falla un detalle visible | Rasgos críticos reconocibles |
| Interacción | Mano/objeto imposible o ambigua | Acción legible con defectos menores | Manipulación clara y plausible |
| Continuidad temporal | Cambios o saltos notorios | Artefactos breves tolerables | Movimiento coherente |
| Dirección de toma | No ocurre la acción o cámara pedida | Parcial | Acción, encuadre y cámara correctos |
| Uso final | Afirma algo no verificable, texto defectuoso o no es reutilizable | Requiere edición menor | Listo para montaje |

Al evaluar, se separa **fidelidad a la referencia** de **calidad estética**. Una toma atractiva que inventa un control del producto no es aprobable.

## Diagnóstico, no superstición

| Síntoma | Primera corrección | Evitar |
|---|---|---|
| El producto deriva | Mejorar el frame de inicio o usar un detalle más limpio | Agregar adjetivos sin límite |
| El video queda inmóvil | Reducir condicionamiento y describir una sola acción observable | Forzar inicio y final por defecto |
| El final no llega al objetivo | Probar frame final o segmentar la acción | Repetir H1 sin cambiar la hipótesis |
| Cámara incorrecta | Fijar una dirección de cámara y un encuadre | Mezclar varias cámaras en un clip corto |
| Manos/uso físico inverosímil | Simplificar la interacción o aislar el plano | Ocultarlo con más duración o upscale |
| Variabilidad alta | Mantener modelo, controles y semilla cuando exista; replicar | Atribuir una mejora a un único resultado |

## Uso responsable de comunidad y teoría

La documentación oficial define los controles que realmente tiene la herramienta; por ejemplo, Firefly permite usar primero y último cuadro como puntos de guía, pero cambia los controles disponibles. La investigación de difusión de video explica por qué la continuidad temporal es un problema propio, no una simple secuencia de imágenes.

Los foros de comunidad se usan para descubrir hipótesis y fallos repetidos, no como prueba concluyente. Un reporte aislado se transforma en una prueba local controlada. Si el patrón se repite, queda registrado con configuración y resultados antes de adoptarlo.

## Registro mínimo por generación

```text
id: P01-H1-A
objetivo: una acción, un plano
modelo/version:
fecha:
referencia_inicio: ruta local + hash
referencia_final: ninguna | ruta local + hash
prompt:
controles: aspecto, duración, cámara, semilla, resolución
costo/creditos:
resultado: ruta local
rubrica: identidad / interacción / continuidad / dirección / uso
fallo dominante:
decisión: descartar | repetir | pasar a H2/H3/H5
```

## Fuentes de partida

- [Adobe: generar video usando imágenes](https://helpx.adobe.com/firefly/web/work-with-audio-and-video/work-with-video/generate-videos-using-images.html)
- [Adobe: redactar prompts efectivos para video](https://helpx.adobe.com/firefly/web/work-with-audio-and-video/work-with-video/writing-effective-text-prompts-for-video-generation.html)
- [Adobe: usar referencia de movimiento de cámara](https://helpx.adobe.com/nz/firefly/web/work-with-audio-and-video/work-with-video/match-camera-motion-to-reference-video.html)
- [Stable Video Diffusion (artículo técnico)](https://arxiv.org/abs/2311.15127)
- [Ejemplo de incidencia de comunidad: la referencia no garantiza consistencia](https://community.adobe.com/bug-reports-403/firefly-video-identical-first-and-last-frame-issue-1482456)
