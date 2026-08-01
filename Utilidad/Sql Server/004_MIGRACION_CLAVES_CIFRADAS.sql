/*
	MIGRACION: claves cifradas (PBKDF2 + salt)

	Solo para bases de datos QUE YA EXISTEN y tienen las claves en texto plano.
	En instalaciones nuevas no hace falta: los scripts 001, 002 y 003 ya quedan cifrados.

	Que hace:
	1. Amplia PERSONA.Clave de varchar(50) a varchar(200) (un hash no cabe en 50 caracteres).
	2. Corrige sp_ModificarPersona, que recibia @Clave pero NUNCA la actualizaba.
	3. Reemplaza las claves en texto plano de los usuarios de ejemplo por su hash
	   (siguen entrando con '123' y '456').
*/

USE DB_HOTEL
GO

-- 1. Ampliar la columna
ALTER TABLE PERSONA ALTER COLUMN Clave varchar(200)
GO

-- 2. El procedimiento de registro debe aceptar el hash completo
ALTER PROC sp_RegistrarPersona(
@TipoDocumento varchar(50),
@Documento varchar(50),
@Nombre varchar(50),
@Apellido varchar(50),
@Correo varchar(50),
@Clave varchar(200),
@IdTipoPersona int,
@Resultado bit output
)as
begin
	SET @Resultado = 1
	DECLARE @IDPERSONA INT
	IF NOT EXISTS (SELECT * FROM persona WHERE Documento = @Documento)
	begin
		insert into persona(TipoDocumento, Documento,Nombre,Apellido,Correo,Clave,IdTipoPersona) values (
		@TipoDocumento,@Documento,@Nombre,@Apellido,@Correo,@Clave,@IdTipoPersona)
	end
	ELSE
		SET @Resultado = 0

end
GO

-- 3. Correccion del bug: ahora si actualiza la clave (y la conserva si viene vacia)
ALTER procedure sp_ModificarPersona(
@IdPersona int,
@TipoDocumento varchar(50),
@Documento varchar(50),
@Nombre varchar(50),
@Apellido varchar(50),
@Correo varchar(50),
@Clave varchar(200),
@IdTipoPersona int,
@Estado bit,
@Resultado bit output
)
as
begin
	SET @Resultado = 1
	IF NOT EXISTS (SELECT * FROM persona WHERE Documento =@Documento and IdPersona != @IdPersona)

		update PERSONA set
		TipoDocumento = @TipoDocumento,
		Documento = @Documento,
		Nombre = @Nombre,
		Apellido = @Apellido,
		Correo = @Correo,
		-- Si viene vacia, se conserva la clave actual; si viene con valor, se reemplaza.
		Clave = ISNULL(NULLIF(@Clave,''), Clave),
		IdTipoPersona = @IdTipoPersona,
		Estado = @Estado
		where IdPersona = @IdPersona
	ELSE
		SET @Resultado = 0

end
GO

-- 4. Cifrar las claves de ejemplo que estaban en texto plano
--    (el formato es  iteraciones.salt.hash  y corresponde a '123' y '456')
UPDATE PERSONA SET Clave = '100000.uCY9bXiM44BblTNzaY26Qg==.X6YvH9DlpdWnGocie1HC3nqqOrV7VWMXwHJPG3gYrws='
WHERE Correo = 'Konoe@gmail.com' AND Clave = '123'

UPDATE PERSONA SET Clave = '100000.jFGQKHy8cFPiq1WAF8hc+A==.SDuja5XyxXfmQ+yZNvXY+cScloEwLRhfNBFMKQBpDI0='
WHERE Correo = 'Mizuki@gmail.com' AND Clave = '456'
GO
