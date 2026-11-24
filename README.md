# od_fakeplates

Recurso modular para colocar y retirar placas falsas persistentes en veh?culos de jugadores en FiveM. Incluye detecci?n autom?tica de integraciones, traducciones y compatibilidad con la interfaz del recurso original.

**Autor:** Oscar Dev

**Cr?ditos:** basado en [Brazzers Fake Plates](https://github.com/Brazzers-Development/brazzers-fakeplates), de Brazzers Development. Se conserva la licencia original en [LICENSE](LICENSE).

## Caracter?sticas

- Frameworks: QBCore, Qbox y ESX Legacy.
- Target: qb-target y ox_target.
- Inventarios: qb-inventory, ox_inventory y el inventario de ESX.
- Llaves: qb-vehiclekeys y qbx_vehiclekeys, con opci?n para desactivarlas.
- Idiomas: ingl?s y espa?ol en `locales/`.
- El servidor comprueba la entidad, la distancia, el propietario registrado y el objeto antes de cambiar una placa.
- Los eventos y exports antiguos disponen de un puente de compatibilidad.

## Requisitos

- FiveM con OneSync activado.
- oxmysql y ox_lib.
- Uno de los frameworks, sistemas de inventario y targets compatibles.
- Para Qbox: ox_inventory. Para la barra de QBCore: el recurso `progressbar` usado por tu framework.

Inicia las dependencias antes de `od_fakeplates`. La detecci?n autom?tica solo encuentra recursos iniciados o que se est?n iniciando.

## Instalaci?n

1. Coloca la carpeta `od_fakeplates` en tus recursos. Si vienes del recurso anterior, ret?ralo o desact?valo: no ejecutes ambos a la vez.
2. Registra el objeto `fakeplate` en tu inventario. Para QBCore hay un ejemplo en `README/ITEMS.txt`; para ESX, a??delo seg?n tu inventario. En ox_inventory puedes agregar a `data/items.lua`:

   ```lua
   ['fakeplate'] = {
       label = 'Fake Plate',
       weight = 100,
       stack = true,
       close = true,
   },
   ```

3. Revisa `shared/config.lua`. Los bridges est?n en `auto` por defecto; cambia `Config.Locale` a `es` para usar espa?ol. Si tienes varios recursos del mismo tipo, selecciona el deseado manualmente.
4. A?ade `ensure od_fakeplates` a tu `server.cfg`, despu?s de las dependencias.

### Base de datos

Al iniciar, el recurso espera la conexi?n de oxmysql, comprueba la tabla de veh?culos configurada y crea la columna nullable `fakeplate VARCHAR(8)` **solo si no existe**. En arranques posteriores conserva la columna y sus datos. La tabla de veh?culos y sus columnas de placa y propietario deben existir antes de iniciar el recurso.

La cuenta de la base de datos necesita permiso `ALTER` para crear la columna. Si no tiene permisos, o faltan la tabla o las columnas requeridas, el recurso muestra un error en la consola y no registra sus funciones. Corrige el problema y rein?cialo. Puedes desactivar la creaci?n con `Config.AutoCreateColumn = false` y a?adir la columna manualmente. Ajusta `Config.Storage` si tu esquema usa otros nombres. Haz una copia de seguridad antes de modificar tu base de datos.

## Configuraci?n

| Opci?n | Valores | Funci?n |
| --- | --- | --- |
| `Config.Framework` | `auto`, `qb`, `qbx`, `esx` | Framework y tabla de veh?culos. |
| `Config.Target` | `auto`, `qb`, `ox` | Sistema de interacci?n. |
| `Config.Inventory` | `auto`, `qb`, `ox`, `esx` | Sistema de inventario. |
| `Config.Keys` | `auto`, `qb`, `qbx`, `none` | Integraci?n de llaves. |
| `Config.Locale` | `en`, `es` | Idioma de los mensajes. |
| `Config.AutoCreateColumn` | `true`, `false` | Creaci?n autom?tica de la columna SQL. |
| `Config.ContainerTables` | Lista de tablas | Migraci?n opcional de maleteros y guanteras heredados. |

En modo autom?tico se prioriza Qbox sobre ESX y QBCore, ox_target sobre qb-target, ox_inventory sobre el inventario del framework y qbx_vehiclekeys sobre qb-vehiclekeys. Si no hay un sistema de llaves compatible iniciado, se usa `none`.

`Config.ContainerTables` est? vac?o por defecto. A?ade las tablas heredadas ?nicamente si tu inventario realmente las utiliza y tienen una columna `plate`. Otros formatos de almacenamiento necesitan una integraci?n espec?fica. Los bridges de llaves entregan una llave al jugador, pero no revocan llaves antiguas ni actualizan las de otros jugadores.

## Uso y compatibilidad

El jugador usa el objeto cerca de un veh?culo de su propiedad y retira la placa mediante el target. El servidor genera la placa y la guarda; al retirarla, devuelve el objeto si el inventario lo permite. Los veh?culos prestados, de NPC o sin registro de propiedad no est?n admitidos por defecto.

Los exports de servidor `isFakePlateOnVehicle`, `getPlateFromFakePlate` y `getFakePlateFromPlate` est?n disponibles bajo `od_fakeplates` y el nombre anterior. Tambi?n se aceptan los eventos anteriores de aplicaci?n y retiro, pero el servidor ignora las placas y llaves enviadas por el cliente y verifica el veh?culo. El callback antiguo de QBCore est? disponible en QB y en Qbox cuando su bridge QB est? habilitado.

Los scripts de garaje, dep?sito y aparici?n de veh?culos deben restaurar la placa falsa desde la base de datos si quieres conservarla despu?s de guardar o reaparecer el veh?culo. Este recurso no modifica esos scripts autom?ticamente.

## Pruebas

Ejecuta `lua tests/service.lua`, `lua tests/detection.lua`, `lua tests/compat.lua`, `lua tests/progress.lua` y `lua tests/schema.lua` desde la carpeta del recurso. Estas pruebas usan simulaciones; prueba adem?s la sincronizaci?n, el inventario, las llaves y el garaje en tu servidor antes de usarlo en producci?n.
