/*
	===========================================================================
	PERMISOS PARA QUE EL SISTEMA PUEDA ENTRAR A LA BASE DE DATOS
	===========================================================================

	>>> ESTE SCRIPT SE EJECUTA DE ULTIMO <<<
	>>> DESPUES de haber instalado el sistema con InstalarSistema.bat  <<<

	POR QUE HACE FALTA
	------------------
	Mientras el sistema se prueba desde Visual Studio, se conecta a la base de
	datos "como la persona que inicio sesion en Windows", y por eso funciona.

	Cuando el sistema queda instalado de verdad, deja de correr a nombre de esa
	persona y pasa a correr a nombre de una cuenta interna de Windows llamada:

	        IIS APPPOOL\SistemaHotel

	Esa cuenta todavia no existe para SQL Server, asi que sin este script el
	sistema abre pero muestra un error de conexion.

	Este script le da a esa cuenta permiso para leer y escribir en DB_HOTEL,
	y NADA MAS: no la hace administradora del servidor.

	SI DA ERROR "no se encontro la entidad de seguridad"
	---------------------------------------------------
	Significa que el sistema todavia no esta instalado. Ejecutar primero
	InstalarSistema.bat y volver a correr este script.
	===========================================================================
*/

USE master

GO

-- 1. Crear el acceso de esa cuenta al servidor (si no existe todavia).
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'IIS APPPOOL\SistemaHotel')
BEGIN
	CREATE LOGIN [IIS APPPOOL\SistemaHotel] FROM WINDOWS
	PRINT 'Acceso creado para IIS APPPOOL\SistemaHotel'
END
ELSE
	PRINT 'El acceso para IIS APPPOOL\SistemaHotel ya existia'

GO

USE DB_HOTEL

GO

-- 2. Darle un usuario dentro de la base de datos del hotel.
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'IIS APPPOOL\SistemaHotel')
BEGIN
	CREATE USER [IIS APPPOOL\SistemaHotel] FOR LOGIN [IIS APPPOOL\SistemaHotel]
	PRINT 'Usuario creado dentro de DB_HOTEL'
END
ELSE
	PRINT 'El usuario dentro de DB_HOTEL ya existia'

GO

-- 3. Permisos: leer, escribir y ejecutar los procedimientos del sistema.
--    Deliberadamente NO se le da control total del servidor.
ALTER ROLE db_datareader ADD MEMBER [IIS APPPOOL\SistemaHotel]
ALTER ROLE db_datawriter ADD MEMBER [IIS APPPOOL\SistemaHotel]
GRANT EXECUTE TO [IIS APPPOOL\SistemaHotel]

PRINT 'Permisos aplicados correctamente sobre DB_HOTEL'

GO

-- 4. Comprobacion final: debe aparecer una fila con los tres permisos.
SELECT
	'IIS APPPOOL\SistemaHotel' AS Cuenta,
	IS_ROLEMEMBER('db_datareader', 'IIS APPPOOL\SistemaHotel') AS PuedeLeer,
	IS_ROLEMEMBER('db_datawriter', 'IIS APPPOOL\SistemaHotel') AS PuedeEscribir,
	(SELECT COUNT(*) FROM sys.database_permissions p
	 INNER JOIN sys.database_principals u ON u.principal_id = p.grantee_principal_id
	 WHERE u.name = 'IIS APPPOOL\SistemaHotel' AND p.permission_name = 'EXECUTE') AS PuedeEjecutar

GO
