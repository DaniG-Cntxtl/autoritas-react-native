# Solución para Errores de Conexión LiveKit (DTLS Timeout)

El error `ConnectionError: could not establish pc connection` y `dtls timeout` indica que el tráfico **UDP** necesario para el audio/video está siendo bloqueado o no está mapeado correctamente en tu contenedor Docker.

Para arreglar esto, debes asegurarte de que tu contenedor de LiveKit tenga expuestos los siguientes puertos UDP.

## 1. Si usas `docker run`:

Asegúrate de incluir estos flags:
```bash
docker run -p 7880:7880 
  -p 7881:7881 
  -p 7882:7882/udp 
  -p 50000-60000:50000-60000/udp 
  livekit/livekit-server
```

## 2. Si usas `docker-compose.yaml`:

Añade la sección `ports` a tu servicio `livekit`:

```yaml
services:
  livekit:
    image: livekit/livekit-server
    command: --config /livekit.yaml --node-ip 127.0.0.1
    ports:
      - "7880:7880"
      - "7881:7881"
      - "7882:7882/udp"
      - "50000-60000:50000-60000/udp"
    environment:
      - LIVEKIT_KEYS=...
```

### Importante: `--node-ip`
Es CRUCIAL que el servidor sepa que su IP pública es `127.0.0.1` para que el navegador sepa a dónde enviar los paquetes. Asegúrate de pasar el argumento:
`--node-ip 127.0.0.1`

## 3. Verificación
Una vez reiniciado el contenedor, intenta conectar de nuevo.
