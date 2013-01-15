Changelog
=========

## Versión 0.3.3 ##

  - Se elimina el módulo Data::HashFlatten y toda las funciones recursivas por problemas de memoria.
  - Reestructuración de todo el código.
  - Separación de configuración de "top_limit": Valor máximo a guardar por día en formato datatables
   	(en formato interno se guarda todo). Se agrega el valor "globals_limit", que consiste en la cantidad
   	de entradas con las que se va a trabajar internamente al guardar estadísticas globales.
  - Se cambia el framework de objetos Mouse por Moose.


## Versión 0.3.2 ##

  - Se guardan los archivos internos con el módulo Storable para mejorar la performance y reducir el espacio en disco.
  - Se divide el proceso de logs en parseo del día y actualización de datos globales.
  - Se agrega la posiblidad de generar reportes semanales, mensuales o de cualquier intervalo de fechas.
  - Optimización en la traducción de datos a formato datatables utilizando el módulo Sub::Recursive.
  - Refactor de código para mejor organización y mayor flexibilidad.
  - Se agregan archivos bash para cronear reportes diarios y semanales.
  - Configuraciones por parámetro de línea de comandos.
  

## Versión 0.3.1 ##

  - Se agrega la posibilidad de parsear archivos del Firewall
  - Se agregan los reportes de:
    * Archivos Descargados
    * Protocolos del Firewall
    * Browsers
    * URLs NO Categorizadas
    * Clientes Únicos
  - Corrida incremental mergeando las estadísticas globales
  - Parámetros por consola para el script principal:
  	* Regex pattern para archivos que tiene que parsear (-w regex y -f regex para archivos web y firewall respectivamente)
  	* Carpetas de entrada y salida (-i input/folder/ -o output/folder/ para carpeta de entrada y salida respectivamente)

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