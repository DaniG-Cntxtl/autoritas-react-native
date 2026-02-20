# Mobile App POC: Generative UI

Esta carpeta contiene la Prueba de Concepto (POC) para la aplicación móvil con interfaz generativa dinámica (Server-Driven UI).

## Estructura

*   `src/context/ThemeEngine.tsx`: El motor que recibe el JSON del Agente e inyecta los estilos en tiempo real.
*   `src/components/DynamicWidget.tsx`: Un ejemplo de componente (Tarjeta de Producto) que cambia radicalmente su aspecto según el tema activo.
*   `src/mockData.ts`: Contiene ejemplos de payloads JSON que enviaría la IA (Medieval, Cyberpunk, Frutiger Aero).
*   `App.tsx`: Pantalla principal con botones de simulación.

## Cómo ejecutar

Requisitos: Node.js y npm instalados.

1.  Instalar dependencias:
    ```bash
    npm install
    ```

2.  Iniciar con Expo:
    ```bash
    npx expo start
    ```

3.  Escanear el código QR con la app **Expo Go** en tu móvil (Android/iOS) o presionar `w` para versión web.

## Demo

Al pulsar los botones "Medieval", "Cyberpunk" o "Frutiger", la app inyectará el JSON correspondiente en el `ThemeEngine`, cambiando instantáneamente:
*   Colores y fuentes.
*   Formas (bordes redondeados vs cuadrados).
*   Fondo (textura de papiro vs grilla neón).
