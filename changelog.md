Changelog
=========

## Versión 0.3.1 ##

  - Se agrega la posibilidad de parsear archivos del Firewall
  - Se agregan los reportes de:
    * Archivos Descargados
    * Protocolos del Firewall
    * Browsers
    * URLs NO Categorizadas
    * Clientes Únicos
  - Corrida incremental mergeando las estadísticas globales

## Versión 0.3 ##

  - Se agrega registros de versión del servidor y changelog.
  - Merge del branch que separa por fechas a la rama principal.
  - Mucho refactor de código.
  - Funcionalidad de logging en pantalla y en archivo, configurable por niveles de severidad.

## Versión 0.2 ##

  - Se crea un nuevo branch de desarrollo que genera los reportes separados por fecha
  - Se agregan los reportes de:
    * Categoría x Usuario
    * Página x Usuario
    * Tráfico x Usuario
    * Palabras buscadas
  - Varias mejoras de performance que logran parsear un archivo de 2GB en 20 minutos y con máximo 1GB de memoria.
  - Reportes TOP de cada reporte configurables. (Mostrar solo los X con más Y).

## Versión 0.1 ##

  - Prototipo inicial que parsea los logs y genera reportes globales de todo lo que parsea
  - Reportes:
    * Hosts
    * Páginas
    * Códigos de estado
    * Categorías
    * Usuario x Página x Categoría
    * Global