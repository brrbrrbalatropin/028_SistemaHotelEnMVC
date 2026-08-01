/*
	===========================================================================
	DATOS INICIALES DEL SISTEMA
	===========================================================================
	Este script deja el sistema LISTO PARA USAR y VACIO: sin habitaciones,
	sin productos y sin clientes inventados.

	Solo crea:
	  - Los estados de habitacion y los tipos de persona, que el sistema
	    necesita para funcionar (NO se deben modificar nunca).
	  - Un usuario administrador para poder entrar la primera vez.

	Las habitaciones, pisos, categorias, productos y usuarios del hotel se
	cargan DESDE EL SISTEMA, con el navegador. No hace falta volver aqui.

	---------------------------------------------------------------------------
	  USUARIO PARA ENTRAR LA PRIMERA VEZ

	      Correo:     admin@hotel.com
	      Contrasena: admin123

	  >>> CAMBIAR ESTA CONTRASENA APENAS SE ENTRE POR PRIMERA VEZ <<<
	      (menu Usuarios -> boton editar -> escribir la contrasena nueva)

	  Es publica: esta escrita en este archivo y cualquiera puede leerla.
	---------------------------------------------------------------------------

	Si se quieren datos de ejemplo para practicar antes de usarlo en serio,
	ejecutar tambien el script 003b_DATOS_DE_EJEMPLO.sql (opcional).
	===========================================================================
*/

USE DB_HOTEL

GO

-- Estados en los que puede estar una habitacion.
-- El sistema los busca por numero: NO cambiar los numeros ni borrar filas.
insert into ESTADO_HABITACION(IdEstadoHabitacion,Descripcion) values
(1,'DISPONIBLE'),
(2,'OCUPADO'),
(3,'LIMPIEZA')

go

-- Tipos de persona. Igual que arriba: el sistema los busca por numero.
-- NO cambiar los numeros ni borrar filas.
insert into TIPO_PERSONA(IdTipoPersona, Descripcion) values
(1,'Administrador'),
(2,'Empleado'),
(3,'Cliente')

go

-- Usuario administrador inicial.
-- La contrasena se guarda cifrada (PBKDF2 + salt), NUNCA en texto plano.
-- El valor de abajo corresponde a la contrasena 'admin123'.
insert into PERSONA(TipoDocumento,documento,nombre,apellido,correo,clave,IdTipoPersona) values
('DNI','00000000','Administrador','del Hotel','admin@hotel.com','100000.XAsClZ3RKQHzKVEicavTWg==.n4sVW5NEEnB8ySgB1/BToucKqP5vb4vBagaJt57tXMQ=',1)

GO
