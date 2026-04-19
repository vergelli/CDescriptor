# CDescriptor — Especificación de Proyecto (Addon de The Elder Scrolls Online)

## Descripción General

CDescriptor es un Addon para The Elder Scrolls Online (ESO), orientado a usuarios de PC. Su objetivo es exportar información del personaje activo de forma estructurada, produciendo un archivo de texto con formato legible por máquina (inicialmente JSON) que el usuario pueda copiar al portapapeles y utilizar como contexto para modelos de lenguaje u otras herramientas externas.

El flujo de uso esperado es el siguiente:

1. El usuario abre la interfaz del addon dentro del juego.
2. El usuario presiona un botón "Generar".
3. El addon ejecuta un pipeline de extracción y transformación de datos, mostrando una barra de progreso.
4. Al finalizar, el contenido del archivo generado se muestra en una caja de texto dentro de la misma interfaz.
5. El usuario presiona un botón "Copy" para copiar el contenido al portapapeles.

En su primera versión, el addon se limita exclusivamente a esta capacidad.

---

## Motivación

El caso de uso principal es personal: poder pasarle a un modelo de lenguaje información detallada sobre un personaje de ESO (build, sets, skills, buffs, gear, etc.) para obtener análisis y recomendaciones, sin necesidad de transcribir esa información manualmente. La motivación adicional es técnica: explorar el desarrollo de addons en Lua para ESO como práctica creativa.

Este addon **no busca competir con addons existentes**. Es una herramienta de soporte personal, con potencial de iteración futura.

---

## Entorno de Desarrollo

- **Sistema Operativo:** Windows 11
- **Lenguaje del Addon:** Lua (requerimiento de la plataforma ESO)
- **Control de versiones:** Git
- **Versión de la API de ESO (APIVersion):** `101049`
  - Este valor corresponde al campo `## APIVersion` del archivo `.toc` del addon. Indica al cliente de ESO con qué versión de la API fue compilado el addon.
- **Ubicación de la API oficial descargada:** `C:\code\teso\Addons\resources\esoui`
  - Claude Code tiene acceso a este path en el filesystem local. Puede consultarlo libremente como referencia durante el desarrollo.
- **Directorio del proyecto:** `C:\code\teso\Addons\development\CDescriptor`

### Toolchain de desarrollo (verificado en la máquina de desarrollo)

| Herramienta | Versión | Instalación | Propósito |
|---|---|---|---|
| Lua | 5.1 | `winget install DEVCOM.Lua` | Intérprete para correr tests y scripts offline |
| LuaRocks | latest | `winget install LuaRocks.LuaRocks` | Package manager de Lua |
| busted | latest | `luarocks install busted` | Framework de unit testing |
| luacheck | latest | `luarocks install luacheck` | Linter estático de Lua |
| GNU Make | 3.81 | `winget install GnuWin32.Make` | Runner de comandos (Makefile) |

**Nota:** Lua 5.1 es la versión requerida para mantener compatibilidad con el entorno sandboxed de ESO. No usar versiones superiores para el código del addon ni para los tests.

---

## Nota Crítica: Accesibilidad de Datos via API de Zenimax

**No se garantiza que todos los datos del schema de referencia sean accesibles directamente mediante la API de Zenimax.** Algunos campos pueden requerir parsing de strings, heurísticas, o simplemente no estar disponibles en la API pública del addon system.

Como consecuencia, **una etapa de exploración de datos disponibles debe considerarse parte del desarrollo desde el inicio**. Antes o durante la implementación de cada módulo de extracción, Claude Code deberá:

1. Identificar qué funciones de la API de Zenimax son relevantes para el dato en cuestión.
2. Verificar en `C:\code\teso\Addons\resources\esoui` si esas funciones existen y qué devuelven.
3. Reportar explícitamente si un campo del schema de referencia no tiene una fuente directa en la API, y proponer una alternativa o marcarlo como pendiente.

Esta exploración es una actividad esperada, no un bloqueo.

---

## Schema de Referencia

El archivo de referencia a continuación define la forma y el nivel de detalle del output esperado. Vive en:
`C:\code\teso\Addons\development\CDescriptor\resources\joehl_build_pve_18_04_2026.json`

Claude Code tiene acceso a este path. El contenido es el siguiente:

```json
{
  "main_class": {
    "class": "Templar",
    "skill_line": "Restoring Light"
  },
  "subclass_1": {
    "class": "Warden",
    "skill_line": "Green Balance"
  },
  "subclass_2": {
    "class": "Arcanist",
    "skill_line": "Curative Runeform"
  },
  "bar_1_skills": {
    "1": "Radiating Regeneration IV",
    "2": "Chacram of Destiny IV",
    "3": "Extnded Ritual IV",
    "4": "REPENTANCE IV",
    "5": "Budding Seeds IV",
    "R": "Practiced Incantation IV (Ultimate)"
  },
  "bar_2_skills": {
    "1": {
      "name": "Warding Contingency IV (Ulfsid's Contingncy)",
      "scripts": {
        "a": {
          "name": "Damage Shield",
          "description": "Grants you and your allies a damage shield that absorbs 6589 damage for 6 seconds, scaling off the higher of your Max Health or Magicka and capped at 38% of your Max Health"
        },
        "b": {
          "name": "Grow Impact",
          "description": "Create a rune of power on the ground for 10 seconds which applies the Affix script in an area"
        },
        "c": {
          "name": "Force",
          "description": "Grants Minor Force for 22 seconds, increasing Critical Damage by 10%"
        }
      }
    },
    "2": {
      "name": "Wardin burst IV (Soul Burst)",
      "scripts": {
        "a": {
          "name": "Damage Shield",
          "description": "Grants you and your allies a damage shield that absorbs 6589 damage for 6 seconds, scaling off the higher of your Max Health or Magicka and capped at 38% of your Max Health"
        },
        "b": {
          "name": "Class Mastery",
          "description": "For 5 seconds, you gain 1320 Armor and 150 Weapon and Spell Damage. If Sacred Ground is active on you, these values are increased by 50%"
        },
        "c": {
          "name": "Intellect and Endurance",
          "description": "Grants Minor Intellect and Minor Endurance for 20 seconds, increasing Magicka and Stamina Recovery by 15%"
        }
      }
    },
    "3": "Channeled Focus IV",
    "4": "Echoing Vigor IV",
    "5": "Reconstructive Domain IV",
    "R": "Reviving Barrier IV (Ultimate)"
  },
  "gear": {
    "weapons": {
      "bar_1": {
        "item": "Restoration Staff",
        "set": "SPC",
        "quality": "gold",
        "enchant": "Absorb Magicka",
        "trait": "Powered"
      },
      "bar_2": {
        "item": "Ice Staff",
        "set": "SPC",
        "quality": "gold",
        "enchant": "Absorb Magicka",
        "trait": "Powered"
      }
    },
    "armor": {
      "head": {
        "item": "Ozezan",
        "weight": "Light",
        "quality": "gold",
        "enchant": "Maximum Magicka",
        "trait": "Divines"
      },
      "shoulder": {
        "item": "Ozezan",
        "weight": "Light",
        "quality": "gold",
        "enchant": "Maximum Magicka",
        "trait": "Divines"
      },
      "chest": {
        "item": "Pillager's Jerkin",
        "quality": "gold",
        "enchant": "Maximum Magicka",
        "trait": "Divines"
      },
      "gloves": {
        "item": "SPC Gloves",
        "quality": "gold",
        "enchant": "Maximum Magicka",
        "trait": "Divines"
      },
      "waist": {
        "item": "SPC Sash",
        "quality": "gold",
        "enchant": "Maximum Magicka",
        "trait": "Divines"
      },
      "legs": {
        "item": "Perfectd Pillager's Jerkin",
        "quality": "gold",
        "enchant": "Maximum Magicka",
        "trait": "Infused",
        "note": "No tenia Divines investigado para transmutarlo"
      },
      "boots": {
        "item": "Pillager's Shoes",
        "quality": "gold",
        "enchant": "Maximum Magicka",
        "trait": "Divines"
      }
    },
    "jewelry": {
      "neck": {
        "item": "SPC Necklace",
        "quality": "violet",
        "enchant": "Magicka Recovery",
        "trait": "Arcane"
      },
      "ring_1": {
        "item": "Perfectd Pillager's Band",
        "quality": "gold",
        "enchant": "Magicka Recovery",
        "trait": "Arcane"
      },
      "ring_2": {
        "item": "Perfectd Pillager's Band",
        "quality": "gold",
        "enchant": "Magicka Recovery",
        "trait": "Arcane"
      }
    }
  },
  "sets_buffs": {
    "Spell Power Cure": {
      "description": "When you overheal yourself or an ally, you give the target Major Courage for 5 seconds which increases their Weapon and Spell Damage by 430"
    },
    "Ozezan": {
      "description": "Overhealing yourself or an Ally grants them 4272 Armor for 1.1 seconds. Healing yourself or an Ally grants them Minor Vitality for 1.1 seconds, increasing their healing received and damage shield strength by 6%"
    },
    "Perfectd Pillager's": {
      "description": "Casting an Ultimate ability while in combat grants 2% of Ultimate spent as Ultimate to up to 11 other group members within 12 meters every 2 seconds over 10 seconds. Group members can only be affected by this set once every 45 seconds"
    }
  }
}
```

### Observaciones sobre el schema

- El campo `scripts` dentro de habilidades de bar_2 corresponde al sistema de **Scribing** (introducido en la expansión Gold Road). Es posible que los datos de Scribing no estén disponibles directamente en la API; esto debe explorarse durante el desarrollo.
- Los campos de `sets_buffs` incluyen descripciones en texto natural. Estas descripciones probablemente deban ser construidas o extraídas de `GetItemLinkSetInfo` o funciones similares, y pueden requerir parsing.
- El schema es una **referencia de forma y nivel de detalle**, no una especificación rígida campo por campo. Si algún dato no es accesible, debe reportarse y el campo puede omitirse o marcarse como `null` en la primera versión.

---

## Arquitectura

### Decisión de arquitectura

Se adopta una **arquitectura modular por responsabilidades**, análoga en espíritu a una arquitectura hexagonal simplificada, pero adaptada a las convenciones y limitaciones de Lua en el contexto de ESO (sin clases, sin imports de sistema, entorno de scripting sandboxed).

El principio central es: **la API de Zenimax nunca se llama directamente desde el pipeline ni desde la UI**. Toda interacción con funciones globales de ESO pasa por la capa de adaptadores.

### Estructura de directorios propuesta

```
CDescriptor/
├── CDescriptor.txt              # Manifest del addon (.toc)
├── CDescriptor.lua              # Entry point: solo inicialización y registro de eventos top-level
├── cdescriptor-0.1.0-1.rockspec # Declaración de dependencias de desarrollo (equivalente a requirements.txt)
├── Makefile                     # Runner de comandos de desarrollo (install, test, lint)
├── install.ps1                  # Script de bootstrap del entorno de desarrollo (llamado por make install)
│
├── core/
│   ├── events.lua               # Registro y despacho de eventos del addon
│   └── settings.lua             # Configuración persistente via SavedVariables (para uso futuro)
│
├── adapters/
│   └── zenimax/
│       ├── character.lua        # Wrappers sobre funciones de personaje (GetUnitName, GetUnitRace, GetUnitClass, etc.)
│       ├── skills.lua           # Wrappers sobre funciones de habilidades (GetSlotSkillInfo, GetSkillAbilityInfo, etc.)
│       ├── gear.lua             # Wrappers sobre funciones de equipamiento (GetItemInfo, GetItemLink, GetEquippedItemInfo, etc.)
│       └── sets.lua             # Wrappers sobre funciones de set bonuses
│
├── pipeline/
│   ├── extractor.lua            # Orquesta llamadas a adapters/zenimax/, produce datos crudos estructurados
│   ├── transformer.lua          # Convierte datos crudos al schema de salida (tabla Lua intermedia)
│   └── serializer.lua           # Serializa la tabla Lua al string JSON final
│
├── ui/
│   ├── CDescriptor.xml          # Definición declarativa de controles de UI (ventana, botones, caja de texto, barra de progreso)
│   └── interface.lua            # Lógica de UI: event handlers de botones, actualización de controles, clipboard
│
├── lib/
│   └── json.lua                 # Librería JSON standalone (ej: JSON.lua de Craig/Rxi — sin dependencias externas)
│
└── spec/                        # Suite de unit tests (corre con Lua estándar, fuera del cliente de ESO)
    ├── test_transformer.lua
    ├── test_serializer.lua
    └── test_extractor.lua       # Usa mocks de adapters/zenimax/
```

### Responsabilidades por capa

| Capa | Responsabilidad | No debe hacer |
|---|---|---|
| `adapters/zenimax/` | Encapsular llamadas a funciones globales de ESO. Devolver datos crudos en tablas Lua simples. | Formatear, transformar, ni conocer el schema de salida. |
| `pipeline/extractor.lua` | Orquestar la recolección de datos llamando a los adaptadores. | Llamar funciones de Zenimax directamente. |
| `pipeline/transformer.lua` | Mapear datos crudos al schema de salida. Aplicar lógica de negocio. | Conocer la UI ni la API de Zenimax. |
| `pipeline/serializer.lua` | Convertir la tabla Lua transformada a string JSON. | Aplicar lógica de negocio. |
| `ui/interface.lua` | Manejar eventos de usuario, actualizar controles, invocar el pipeline. | Extraer datos ni conocer el schema. |
| `lib/` | Utilidades de terceros standalone. | Depender de otras capas del proyecto. |
| `core/` | Inicialización, eventos globales del addon, configuración persistente. | Lógica de negocio ni UI. |

---

## Pipeline de Ejecución

Cuando el usuario presiona "Generar", el flujo es el siguiente:

```
[UI: botón "Generar"]
        │
        ▼
[extractor.lua]  ←──  [adapters/zenimax/character.lua]
                  ←──  [adapters/zenimax/skills.lua]
                  ←──  [adapters/zenimax/gear.lua]
                  ←──  [adapters/zenimax/sets.lua]
        │
        ▼ (tabla Lua con datos crudos)
[transformer.lua]
        │
        ▼ (tabla Lua con schema de salida)
[serializer.lua]
        │
        ▼ (string JSON)
[UI: caja de texto + botón "Copy"]
```

La barra de progreso puede actualizarse entre etapas del pipeline (post-extracción, post-transformación, post-serialización), dado que ESO no permite operaciones asíncronas reales en Lua.

---

## Aspectos Técnicos Generales

- **Lua moderno:** Seguir convenciones idiomáticas de Lua 5.1 (versión usada por el cliente de ESO). Documentación inline con comentarios claros. Sin uso de herencia de clases; preferir funciones libres y módulos como tablas.
- **Standalone:** El addon no debe depender de otros addons. La única dependencia externa permitida en v1 es una librería JSON standalone incluida en `lib/`.
- **Separación API/código propio:** Ningún archivo fuera de `adapters/zenimax/` debe llamar funciones globales de la API de Zenimax directamente.
- **Interoperabilidad:** No requerida en v1. No cerrar la puerta para versiones futuras.
- **Formato de salida:** JSON en v1. El diseño del serializer debe permitir agregar YAML u otros formatos en iteraciones futuras sin modificar el transformer.

---

## Preferencias de Desarrollo

- **Pragmatismo sobre completitud:** Priorizar que el pipeline funcione end-to-end con un subconjunto de campos antes que implementar todos los campos del schema. Iterar por módulo.
- **Exploración explícita:** Si durante el desarrollo se descubre que un dato no es accesible via API, reportarlo con claridad y continuar con los datos disponibles.
- **Sin over-engineering:** La arquitectura propuesta es el techo de complejidad para v1, no el piso. Si un módulo puede ser más simple, debe serlo.

---

## Testing

### Principio fundamental: dos entornos de Lua

El cliente de ESO corre un intérprete Lua 5.1 sandboxed sin acceso a `io`, `os`, ni `require` de módulos externos. Ese entorno **no puede reproducirse fuera del juego**. Como consecuencia, el código del addon se divide en dos categorías con estrategias de testing distintas:

| Módulo | Testeable offline | Razón |
|---|---|---|
| `pipeline/transformer.lua` | **Sí** | Lógica pura sobre tablas Lua, sin dependencias externas. |
| `pipeline/serializer.lua` | **Sí** | Entrada tabla Lua, salida string. Sin dependencias externas. |
| `pipeline/extractor.lua` | **Sí, con mocks** | Testeable si los adapters se inyectan como parámetro. |
| `adapters/zenimax/` | **No** | Depende de funciones globales inyectadas por ESO en runtime. |
| `ui/interface.lua` | **No** | Depende de controles de UI de ESO. |

El valor concentrado del testing está en `transformer` y `serializer`, que son lógica pura y los más propensos a errores silenciosos de mapeo o serialización.

### Estrategia de inyección de dependencia para el extractor

Para que `extractor.lua` sea testeable, **recibe los adapters como parámetro** en lugar de requerirlos directamente. Esto permite pasar stubs en los tests sin modificar el código de producción:

```lua
-- extractor.lua (producción)
local M = {}
function M.extract(adapters)
  local character = adapters.character.get_info()
  local skills    = adapters.skills.get_all_bars()
  local gear      = adapters.gear.get_equipped()
  return { character = character, skills = skills, gear = gear }
end
return M

-- spec/test_extractor.lua (test con mock)
local mock_adapters = {
  character = { get_info = function() return { name = "Joehl", class = "Templar" } end },
  skills    = { get_all_bars = function() return { bar1 = {}, bar2 = {} } end },
  gear      = { get_equipped = function() return {} end }
}
local result = extractor.extract(mock_adapters)
assert.equals("Templar", result.character.class)
```

### Framework de testing

**busted** — instalado via LuaRocks (`luarocks install busted`). Sintaxis tipo RSpec, output legible, compatible con Lua 5.1.

Los tests viven en `spec/` en la raíz del proyecto. Convención de nombres: `test_<modulo>.lua`.

### Gestión de dependencias de desarrollo

El archivo `cdescriptor-0.1.0-1.rockspec` en la raíz del proyecto declara las dependencias de desarrollo. Es el equivalente al `requirements.txt` de Python — **no afecta al addon en sí**, que debe seguir siendo standalone.

```lua
-- cdescriptor-0.1.0-1.rockspec
package = "cdescriptor"
version = "0.1.0-1"

source = {
   url = "git+https://github.com/tuusuario/cdescriptor"
}

description = {
   summary = "ESO addon — character build exporter",
   license = "MIT"
}

dependencies = {
   "lua == 5.1",
   "busted >= 2.0",
   "luacheck >= 1.0"
}

build = {
   type = "none"
}
```

Para instalar todas las dependencias de desarrollo al clonar el repo:
```
luarocks install --deps-only cdescriptor-0.1.0-1.rockspec
```

### Makefile

El `Makefile` en la raíz centraliza los comandos de desarrollo. Requiere GNU Make 3.81 (`winget install GnuWin32.Make`, agregado al PATH manualmente).

```makefile
.PHONY: install test lint

install:
	powershell -ExecutionPolicy Bypass -File install.ps1

test:
	busted spec/

lint:
	luacheck adapters/ pipeline/ core/ ui/ --std lua51
```

Comandos disponibles:

| Comando | Acción |
|---|---|
| `make install` | Instala el entorno de desarrollo completo (Lua, LuaRocks, busted, luacheck) |
| `make test` | Corre la suite de unit tests con busted |
| `make lint` | Corre luacheck sobre todo el código fuente |

El punto de entrada para un desarrollador nuevo que clone el repo es siempre `make install`, seguido de `make test` para verificar que el entorno quedó operativo.

### Qué no se testea en v1

`adapters/zenimax/` y `ui/interface.lua` no tienen tests automatizados. La validación de los adapters se hace manualmente dentro del juego durante la etapa de exploración de la API de Zenimax. Esto es una limitación conocida y aceptada, no un olvido.

---

## Recursos de Referencia

| Recurso | Ubicación | Notas |
|---|---|---|
| API oficial de ESO (esoui) | `C:\code\teso\Addons\resources\esoui` | Claude Code tiene acceso. Usar como referencia para funciones disponibles. |
| Schema JSON de referencia | `C:\code\teso\Addons\development\CDescriptor\resources\joehl_build_pve_18_04_2026.json` | Claude Code tiene acceso. Incluido inline en este documento. |
| Schema YAML de referencia | `C:\code\teso\Addons\development\CDescriptor\resources\teso_build_pve_healer_18_04_2026.yaml` | Claude Code tiene acceso. Menos detallado que el JSON; usar como referencia secundaria. |
| Directorio del proyecto | `C:\code\teso\Addons\development\CDescriptor` | Directorio raíz de trabajo. |
