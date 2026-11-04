# ETECSA Supervisión

Cliente Flutter para supervisar en vivo los inversores solares del parque ETECSA: un dashboard plano con todos los inversores agrupados por sitio y un detalle por inversor con telemetría en tiempo real e historial real.

## Camino rápido

1. Demo sin backend (recomendado para probar la UI): verificar `USE_FAKE_DATA=true` en `.env` y correr `flutter run`.
2. Contra el backend real: `USE_FAKE_DATA=false`, `API_BASE_URL=http://<host>:8080`, backend levantado, y `flutter run`.
3. Verificación: `flutter analyze`, `flutter test` y `flutter build apk --debug`.

## Configuración

El `.env` está gitignoreado y todos los valores tienen fallback, así que la app arranca aunque falte.

| Variable | Default | Qué hace |
|----------|---------|----------|
| `API_BASE_URL` | `http://localhost:8080` | Base del backend JHipster (`API_URL` también se acepta como alias). |
| `USE_FAKE_DATA` | `false` | `true` usa datasources sembradas (`Random(42)`) y no hace red. |
| `WS` (derivada) | — | No se configura: `Environment.wsBaseUrl` arma `ws://<host>/websocket/tracker/websocket`. |

Autenticación: `POST /api/authenticate` con usuario/contraseña; el JWT se guarda en `flutter_secure_storage`, viaja como `Authorization: Bearer` y como `access_token` + header `login` en STOMP. Sin refresh token: un 401 limpia la sesión y vuelve al login.

## Arquitectura

| Capa | Carpeta | Contenido |
|------|---------|-----------|
| Dominio | `lib/domain` | Entidades espejo de los DTO (26 columnas de telemetría nullable), contratos de datasource/repositorio, políticas puras (`StalenessPolicy`, `SiteGrouping`). |
| Infraestructura | `lib/infraestructure` | Dio + interceptor de auth, datasources real/fake, mappers, `PeriodicPoller`, cliente STOMP. |
| Presentación | `lib/presentation` | Riverpod providers, router GoRouter, pantallas y widgets. |
| Config | `lib/config` | Tema Material 3, `Environment`, formateo de unidades (`SolarFormat`), router. |

Flujo de datos:

- **Dashboard**: carga única del catálogo (`GET /api/inversors/all`) + sondeo masivo cada 5 s de `GET /api/dato-inversors/latest-readings`, indexado por `inversorId`. Cada tarjeta escucha solo su lectura (`select`), así un tick no reconstruye las 300 tarjetas.
- **Detalle**: una sola suscripción por pantalla vía `watchLive`; STOMP en `/topic/inversor/{id}/live` cuando el cliente está conectado, con fallback de sondeo REST cada 5 s. Historial real desde `GET /api/dato-inversors?inversorId.equals=N&sort=tiempo,desc`.
- **Valores ausentes**: se pintan `—`, nunca `0`. OFFLINE cuando la lectura falta o supera `2.5 × max(cadencia, 5 s)`.

## Backend

Repo aparte: `https://github.com/jvila8512/EtecsaInversores.git` (rama `javier`). Este cliente no incluye cambios de backend; los datos de telemetría dependen de que el gateway Modbus responda.

Limitaciones conocidas:

- Sin refresh token (TTL 24 h).
- Si no hay gateway alcanzable, `latest-readings` vuelve vacío y la UI muestra `—`/OFFLINE: es el comportamiento esperado.
- El STOMP se conecta al iniciar sesión; si el detalle se abre antes del `CONNECTED`, esa pantalla usa el fallback REST.

## Verificación manual (modo demo)

Con `USE_FAKE_DATA=true`, sin backend, `flutter run`:

- [ ] S1 Arranca y aparece el login.
- [ ] S2 Cualquier usuario/contraseña abre el dashboard sin red.
- [ ] S3 Los KPI cambian solos dentro de 10 s.
- [ ] S4 El filtro pegajoso muestra `Todos` + cada sitio; filtrar angosta la lista y queda fijo al scrollear.
- [ ] S5 Las tarjetas muestran `—` cuando falta telemetría, `SLAVE n`/`MASTER`, `E07` y `ONLINE`/`OFFLINE` con `hace Xs`.
- [ ] S6 El detalle muestra las seis secciones (PV, Batería, Red, Carga, Eficiencia, Estado).
- [ ] S7 El banner indica `CONECTADO`/`RECONECTANDO`/`SONDEO`.
- [ ] S8 El gráfico usa filas reales (fake), sin series inventadas.
- [ ] S9 Tocar la planta en el breadcrumb vuelve al dashboard con ese sitio seleccionado.
- [ ] S10 Cerrar sesión borra el token y vuelve al login.

## SDD

Los artefactos de especificación viven en Engram (`sdd/live-inverter-monitoring/*`). Este repo no usa `openspec/`.
