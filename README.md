# Plataforma de desarrollo basicVirtualMachineDev
Plataforma de LEMP con compass y MEAN

Asi mismo esta plataforma es de software libre.

# Desarrollo Local

Este proyecto consta de una serie de scripts para levantar un servidor virtual con 
configuración LEMP. Esta pensado para ser usado como un servidor privado 
por cada uno de los desarrolladores.

## Requerimientos para desarrollo local

Para usar este proyecto es necesario tener instalado lo siguiente:

* virtualbox
* vagrant 1.72+
* vagrant plugin install vagrant-vbguest
* putty (en caso de estar usando windows)

o en su caso wamp o similar, sin embargo en el presente documentación no se genera
documentación de la misma.

## Configuración
El servidor buscará las carpetas de los proyectos a un lado de la carpeta de este proyecto
con nombres específicos para cada proyecto. Es decir, se espera un sistema de archivos de la siguiente manera:


        (workspace)- archivos
        --VirtualMachine
           --files
       	--proyecto (carpeta)
       	  --public

Para hacer accesibles las paginas publicadas por el servidor virtual, necesitamos poner 
las siguientes lineas en el archivo hosts (/etc/hosts en linux y mac, 
C:\windows\system32\drivers\etc\hosts para windows )

        192.168.56.13  www.proyecto.local.com

## Modo de uso
Una vez que tenemos la configuración correcta podemos manipular el servidor virtual desde la linea de comandos
con los siguientes comandos

### Iniciar el servidor:
    
        vagrant  up

La primera vez que se usa este comando, vagrant genera y configura el servidor virtual,
por lo que es probable que se tarde varios minutos.

### Detener el servidor:

        vagrant halt 

### Aplicar cambios en los archivos de configuración

        vagrant reload --provision

Esto se hará cada vez que hagamos una corrección en los scripts de este proyecto para
que los servidores de cada uno tome los cambios, obvio habrá que hacer un "git pull"  previamente. 
  
### Destruir la maquina

        vagrant destroy

Esta instrucción destruye el servidor virtual y debe ser usada con cuidado, 
es útil en el caso de que se desee liberar espacio en disco, cuando ya no se ocupe más
el servidor, o en caso de querer iniciar con un servidor limpio.

Los datos en las carpetas de los proyectos no se ven afectados.

Si después de ejecutar este comando ejecutamos una vez mas vagrant up, 
la maquina se volverá a generar desde cero.

### Ingresar por ssh al servidor

        vagrant ssh

Este comando es muy útil para revisar logs del servidor, hacer cambios manuales a la configuración reiniciar servicios etc. 

Recuerda que cualquier configuración especial que hagas a mano aquí
diferirá de la configuración que tienen los demás y se perderá si ejecutas 
vagrant destroy	o en algunos casos si ejecutas vagrant reload --provision,
si deseas hacer una configuración que se pueda regenerar automáticamente, 
hay que hacerlo en los scripts de este proyecto, en puppet o en sh.

# FAQ

### ¿ Qué servicios provee el servidor virtual ?

El servidor virtual creado por vagrant con los archivos de este proyecto, tiene instalado:

	 nginx
	 php-fpm
	 mysql
	 ngimx
	 compass
	 xdebug
	 y una serie de librerías de php
 	 
Además genera las bases de datos a las que se conectan estas aplicaciones con datos muestra. ( aún hace falta llenar algunos catálogos y generar algunas vistas )
	 
### ¿ Cómo tengo que configurar los proyectos ?

Este servidor provee un ambiente monolítico ( es decir es un todo en uno) por lo que todas las conexiones a bases de datos deberían ser redirigidas a 'localhost' o '127.0.0.1' 
al igual que las conexiones a servidores de cache (memcached), la base de datos tiene los 
siguientes usuarios out-of-the -box
	
	usuario                        password 
	root@localhost                 password  (literal la palabra password)
	root@localhost                 (sin password)
	root@%                         password  (literal la palabra password)
	
Por lo que tienes que crear los usuarios que necesitas o usar alguno de los anteriores 
en tus archivos de configuración.
	
### ¿ Cómo puedo usarlo para desarrollar ?

Los archivos de los proyectos (si los pusiste en la estructura mencionada) 
son compartidos por vagrant con el servidor virtual, por lo cual puedes 
editarlos, con el editor o el IDE que mas te guste y ver los cambios que 
has hecho en el navegador por medio de la url que diste de alta en el archivo host

Puedes además inspeccionar y manipular la base de datos con el cliente de tu preferencia conectándote con los siguientes datos:
	
	host: 192.168.56.13
	puerto: 3306
	usuario: root
	password: password
	
Puedes conectarte al servidor ejecutando vagrant ssh, y revisar los logs
los logs de php los puedes encontrar en.
	
	/var/log/php-fpm/www-error.log
	
Te recomiendo ejecutar dentro del servidor
	
	tail -f /var/log/php-fpm/www-error.log
	
para ver las ultimas lineas del log, y puedes ejecutar tu pagina 
para revisar en tiempo real los logs que se generan

para terminar tail lo haces por medio de la combinación de teclas
	
	ctrl-c
	
Si ocupas un IDE que te permita hacer debug con xdebug puedes hacerlo, 
el servidor ya esta configurado para permitirlo, yo lo hago en eclipse 
pero se que también lo pueden hacer netbeans, phpstorm y komodo.

## Troubleshooting

En caso de haber algún error al hacer por primera vez vagrant up, y el problema se da al estar instalando y configurando la máquina virtual puedes probar haciéndolo de nuevo, ya que el problema puede ser por conexión de red, bloqueos de urls o incluso por algún error en las dependencias declaradas en el archivo site.pp, 

    vagrant reload --provision

Sí no da resultado haciéndolo de nuevo envíame el log para revisarlo.
	
En caso de que algún sitio no funcione, hay que revisar el log de php-fpm, 
para determinar las posibles causas. Las causas mas probables son:
	
1. Que haga falta que cambies parámetros de conexiones a DB:
    * síntomas: verás errores al intentar hacer un connect.
    * solución: verifica y corrige los datos de conexión.

2. Que haga falta alguna tabla/campo/vista/esquema en la base de datos:
    * Síntomas: Verás errores al ejecutar sentencias de sql.
    * Nota: Cuando determines que es lo que hace falta por favor agrega un script a la carpeta vagrant/database  para que los demás no tengan este problema en el futuro.

3. Que se este intentando contactar algún servicio inalcanzable.
    * Síntomas: generalmente en estos casos verás que tarda mucho en responderte el sitio y posteriormente fallará, en el log verás el error referente a que no puedes alcanzar alguna url.
    * Solución: En estos casos tendrás que revisar si existe algún sandbox para el servicio y cambiar la url por la del sandbox en caso de no existir sandbox, se podría intentar construir un stakeholder para trabajar con el.

4. Que haga falta alguna librería en el servidor. 
    * Síntomas: Verás errores de funciones desconocidas.
    * Solución: Será necesario por principio averiguar cual librería es la que hace falta, e integrarla al script de puppet ( si requieren ayuda en ese punto puedo apoyarlos sin ningún problema )
    * Nota: es pasible hacer la instalación de las librerías directamente en el servidor, sin embargo no se los recomiendo ya que no podemos replicar el cambio para los demás e incluso se podría perder el cambio en caso de tener que reconstruir el servidor virtual. 
		

Cualquier otra duda o problema, pueden contactarme para revisarlo y corregirlo.
		
5. Se han agregado cambios en varios script, si tu quieres agregar campos para que puedan correr los demas tu desarrollo, por favor agregarlo en el archivo de schema_change.sql, solo los campos extra que no se registraron en la base de datos.


# Author

El presente repositorio son de:

        Ricardo Jesus Ruiz Cruz <ricardojesus.ruizcruz@gmail.com>
        Eduardo Cruz <eduardo.cruz.a85@gmail.com>
