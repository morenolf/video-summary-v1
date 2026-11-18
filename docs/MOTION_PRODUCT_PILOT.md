# Piloto visual: producto en movimiento

Este protocolo complementa la transcripción. Un video de producto no se considera comprendido sólo porque exista audio o texto: el sistema debe conservar qué producto aparece, dónde está, qué acción ocurre y en qué momento.

## Unidad de piloto

Usar primero un solo clip corto, de aproximadamente 12 segundos. No incorporar este archivo, su nombre, su hash, enlaces de origen ni fotogramas al repositorio. Todo resultado visual permanece en el workspace local.

## Objetivo verificable

Producir una línea de tiempo local que permita responder con evidencia:

- qué producto se ve;
- en qué intervalos es visible;
- qué movimiento o manipulación se observa;
- qué fotogramas prueban cada afirmación;
- cuándo el objeto se pierde, queda tapado o deja de ser identificable.

La salida no debe afirmar propiedades del producto que no sean visibles.

## Iteración 1: inspección y fotogramas de control

1. Verificar que el archivo abre, su duración coincide y no está truncado.
2. Extraer ocho fotogramas equiespaciados: inicio, aproximadamente 1.5 s, 3 s, 4.5 s, 6 s, 7.5 s, 9 s y final.
3. Extraer también fotogramas de picos de movimiento, detectados por diferencia entre cuadros; no depender sólo de intervalos fijos.
4. Crear una plancha de contacto local con timestamp visible.
5. Marcar para cada fotograma: producto visible, porcentaje estimado de oclusión, desenfoque, cambio de plano y acción.

Éxito de la iteración 1: ningún intervalo de movimiento relevante queda sin al menos un fotograma utilizable. Si ocurre, aumentar la frecuencia sólo en esa ventana.

## Iteración 2: anclas humanas y seguimiento

La primera versión de seguimiento se valida contra anclas humanas, no contra una intuición del modelo.

Anotar manualmente una caja del producto en el primer cuadro visible y luego cada 1 o 2 segundos, además de antes y después de cada oclusión o corte. Guardar localmente una estructura como:

    {
      "timestamp_seconds": 3.0,
      "product_id": "producto_01",
      "bbox_xywh": [x, y, width, height],
      "visible_fraction": 0.9,
      "occluded": false,
      "shot_id": 2,
      "action": "rotacion"
    }

Un rastreador de objeto puede interpolar entre anclas, pero nunca reemplaza la revisión de las anclas.

## Métricas de aceptación visual

| Control | Umbral inicial |
| --- | --- |
| Cobertura de producto visible | Todos los intervalos visibles tienen evidencia con timestamp |
| Identidad | El producto no se confunde con mano, fondo u otro objeto |
| Seguimiento | IoU promedio de 0.70 o más contra anclas; ningún ancla menor a 0.50 |
| Oclusiones/cortes | Se detectan y reinician seguimiento; no se fuerza continuidad falsa |
| Evidencia | Toda acción del resumen apunta a uno o más timestamps y fotogramas |
| Calidad de cuadro | Ninguna prueba se basa únicamente en un cuadro borroso o tapado |

IoU es la superposición entre la caja seguida y la caja anotada. Los umbrales se endurecen cuando el resultado vaya a alimentar automatizaciones o publicidad.

## Bucle de corrección

1. Si el objeto se pierde por movimiento rápido, agregar anclas alrededor del evento y elevar temporalmente la frecuencia de cuadros.
2. Si hay cambio de plano, terminar el tramo anterior y comenzar una nueva pista; no enlazar objetos por proximidad.
3. Si hay desenfoque u oclusión, etiquetarlo como incertidumbre y no inferir una acción específica.
4. Si el mismo producto reaparece, confirmar visualmente la identidad antes de reutilizar producto_01.
5. Repetir sólo las ventanas fallidas; no reanalizar el archivo completo por un error local.

Cada cambio de herramienta, detector, frecuencia de muestreo o criterio de identificación vuelve a ejecutar este piloto.

## Entregables locales antes de escalar

- plancha de contacto con timestamps;
- anotaciones de ancla y tramos de seguimiento;
- línea de tiempo de acciones con evidencia;
- lista de fallas, oclusiones y cuadros descartados;
- informe breve: aprobado, repetir con ajustes o rechazado.

Sólo después de aprobar este piloto visual se integran transcripción, resumen y búsqueda. La búsqueda debe conservar los mismos timestamps que la evidencia visual.
