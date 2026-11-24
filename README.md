# od_fakeplates

Recurso modular para colocar y retirar placas falsas persistentes en vehículos de jugadores en FiveM. Incluye detección automática de integraciones, traducciones y compatibilidad con la interfaz del recurso original.

**Autor:** Oscar Dev

**Créditos:** basado en [Brazzers Fake Plates](https://github.com/Brazzers-Development/brazzers-fakeplates), de Brazzers Development. Se conserva la licencia original en [LICENSE](LICENSE).

## Características

- Frameworks: QBCore, Qbox y ESX Legacy.
- Target: qb-target y ox_target.
- Inventarios: qb-inventory, ox_inventory y el inventario de ESX.
- Llaves: qb-vehiclekeys y qbx_vehiclekeys, con opción para desactivarlas.
- Idiomas: inglés y español en `locales/`.
- El servidor comprueba la entidad, la distancia, el propietario registrado y el objeto antes de cambiar una placa.
- Los eventos y exports antiguos disponen de un puente de compatibilidad.

## Requisitos

- FiveM con OneSync activado.
- oxmysql y ox_lib.
- Uno de los frameworks, sistemas de inventario y targets compatibles.
- Para Qbox: ox_inventory. Para la barra de QBCore: el recurso `progressbar` usado por tu framework.

Inicia las dependencias antes de `od_fakeplates`. La detección automática solo encuentra recursos iniciados o que se están iniciando.

## Instalación

1. Coloca la carpeta `od_fakeplates` en tus recursos. Si vienes del recurso anterior, retíralo o desactívalo: no ejecutes ambos a la vez.
2. Registra el objeto `fakeplate` en tu inventario. Para QBCore hay un ejemplo en `README/ITEMS.txt`; para ESX, añádelo según tu inventario. En ox_inventory puedes agregar a `data/items.lua`:

   ```lua
   ['fakeplate'] = {
       label = 'Fake Plate',
       weight = 100,
       stack = true,
       close = true,
   },
   ```

3. Revisa `shared/config.lua`. Los bridges están en `auto` por defecto; cambia `Config.Locale` a `es` para usar español. Si tienes varios recursos del mismo tipo, selecciona el deseado manualmente.
4. Añade `ensure od_fakeplates` a tu `server.cfg`, después de las dependencias.

### Base de datos

Al iniciar, el recurso espera la conexión de oxmysql, comprueba la tabla de vehículos configurada y crea la columna nullable `fakeplate VARCHAR(8)` **solo si no existe**. En arranques posteriores conserva la columna y sus datos. La tabla de vehículos y sus columnas de placa y propietario deben existir antes de iniciar el recurso.

La cuenta de la base de datos necesita permiso `ALTER` para crear la columna. Si no tiene permisos, o faltan la tabla o las columnas requeridas, el recurso muestra un error en la consola y no registra sus funciones. Corrige el problema y reinícialo. Puedes desactivar la creación con `Config.AutoCreateColumn = false` y añadir la columna manualmente. Ajusta `Config.Storage` si tu esquema usa otros nombres. Haz una copia de seguridad antes de modificar tu base de datos.

## Configuración

| Opción | Valores | Función |
| --- | --- | --- |
| `Config.Framework` | `auto`, `qb`, `qbx`, `esx` | Framework y tabla de vehículos. |
| `Config.Target` | `auto`, `qb`, `ox` | Sistema de interacción. |
| `Config.Inventory` | `auto`, `qb`, `ox`, `esx` | Sistema de inventario. |
| `Config.Keys` | `auto`, `qb`, `qbx`, `none` | Integración de llaves. |
| `Config.Locale` | `en`, `es` | Idioma de los mensajes. |
| `Config.AutoCreateColumn` | `true`, `false` | Creación automática de la columna SQL. |
| `Config.ContainerTables` | Lista de tablas | Migración opcional de maleteros y guanteras heredados. |

En modo automático se prioriza Qbox sobre ESX y QBCore, ox_target sobre qb-target, ox_inventory sobre el inventario del framework y qbx_vehiclekeys sobre qb-vehiclekeys. Si no hay un sistema de llaves compatible iniciado, se usa `none`.

`Config.ContainerTables` está vacío por defecto. Añade las tablas heredadas únicamente si tu inventario realmente las utiliza y tienen una columna `plate`. Otros formatos de almacenamiento necesitan una integración específica. Los bridges de llaves entregan una llave al jugador, pero no revocan llaves antiguas ni actualizan las de otros jugadores.

## Uso y compatibilidad

El jugador usa el objeto cerca de un vehículo de su propiedad y retira la placa mediante el target. El servidor genera la placa y la guarda; al retirarla, devuelve el objeto si el inventario lo permite. Los vehículos prestados, de NPC o sin registro de propiedad no están admitidos por defecto.

Los exports de servidor `isFakePlateOnVehicle`, `getPlateFromFakePlate` y `getFakePlateFromPlate` están disponibles bajo `od_fakeplates` y el nombre anterior. También se aceptan los eventos anteriores de aplicación y retiro, pero el servidor ignora las placas y llaves enviadas por el cliente y verifica el vehículo. El callback antiguo de QBCore está disponible en QB y en Qbox cuando su bridge QB está habilitado.

Los scripts de garaje, depósito y aparición de vehículos deben restaurar la placa falsa desde la base de datos si quieres conservarla después de guardar o reaparecer el vehículo. Este recurso no modifica esos scripts automáticamente.

## Pruebas

Ejecuta `lua tests/service.lua`, `lua tests/detection.lua`, `lua tests/compat.lua`, `lua tests/progress.lua` y `lua tests/schema.lua` desde la carpeta del recurso. Estas pruebas usan simulaciones; prueba además la sincronización, el inventario, las llaves y el garaje en tu servidor antes de usarlo en producción.
