/*
	===========================================================================
	DATOS DE EJEMPLO  ***OPCIONAL - NO EJECUTAR EN EL HOTEL***
	===========================================================================
	Este script llena el sistema con datos INVENTADOS (habitaciones, productos
	y clientes de mentira) para poder practicar y ver como se comporta todo
	sin dañar informacion real.

	Ejecutarlo SOLO en un computador de pruebas.

	En la instalacion real del hotel NO se ejecuta: las habitaciones, pisos,
	categorias y productos verdaderos se cargan desde el sistema, con el
	navegador.

	Usuario empleado de ejemplo que crea este script:
	    Correo: empleado@ejemplo.com   Contrasena: 456
	===========================================================================
*/

USE DB_HOTEL

GO

INSERT INTO CATEGORIA(Descripcion) VALUES
('Matrimonial'),
('Doble'),
('Individual')

GO

INSERT INTO PISO(Descripcion) VALUES
('PRIMERO'),
('SEGUNDO'),
('TERCERO')

GO

INSERT INTO HABITACION(numero,detalle,precio,IdEstadoHabitacion,IdPiso,IdCategoria) values
('001','WIFI + BANO + TV + CABLE','70',1,1,3),
('002','WIFI + BANO + TV + CABLE','80',1,1,2),
('003','BANO + TV + CABLE','60',1,1,3),
('004','WIFI + BANO + TV + CABLE','80',1,1,2),
('005','WIFI + BANO','50',1,1,3),

('006','WIFI + BANO + TV 4K + CABLE','80',1,2,3),
('007','WIFI + BANO + TV 4K + CABLE','90',1,2,2),
('008','WIFI + BANO + TV + CABLE','70',1,2,3),
('009','WIFI + BANO + TV + CABLE','80',1,2,2),
('010','WIFI + BANO + TV + CABLE','70',1,2,3),

('011','WIFI + BANO + TV 4K + CABLE','120',1,3,1),
('012','WIFI + BANO + TV 4K + CABLE','120',1,3,1),
('013','WIFI + BANO + TV 4K + CABLE','120',1,3,1),
('014','WIFI + BANO + TV + CABLE','85',1,3,2),
('015','WIFI + BANO + TV + CABLE','75',1,3,3)

GO

insert into PRODUCTO(Nombre,Detalle,Precio,Cantidad) values
('GALLETAS DORAS','NINGUNA','0.70',50),
('REFRESCO POCMAS','350 ML','1.50',80),
('CHOCOLATE DMX','50 GRM','0.80',60),
('PAPAS DORADAS','150 GRM','2.60',20),
('REFRESCO OXA','300 ML','2',30),
('CIGARRILLOS DEM','10 UNID','3.50',55),
('AGUA LIFE','250 ML','3',45),
('GASEOSA ALMOADA','350 ML','4.50',30),
('CEREALES PANDA','NIN','2.70',40),
('SHAMPOO GH','200 ML','2.50',20)

GO

-- Usuario empleado de ejemplo. La clave cifrada corresponde a '456'.
insert into PERSONA(TipoDocumento,documento,nombre,apellido,correo,clave,IdTipoPersona) values
('DNI','4353434','Empleado','de Ejemplo','empleado@ejemplo.com','100000.jFGQKHy8cFPiq1WAF8hc+A==.SDuja5XyxXfmQ+yZNvXY+cScloEwLRhfNBFMKQBpDI0=',2)

GO

-- Clientes de ejemplo.
insert into PERSONA(TipoDocumento,documento,nombre,apellido,correo,IdTipoPersona) values
('DNI','34345656','Bartolome','Abe','Abe@gmail.com',3),
('DNI','56567878','Hanan','Beppu','Beppu@gmail.com',3),
('DNI','34237878','Haru','Endo','Endo@gmail.com',3),
('PASAPORTE','78909078','Juan Luis','Vico','Vico@gmail.com',3),
('DNI','45456767','Victoriano','Araujo','Araujo@gmail.com',3),
('DNI','45343434','Kameyo','Hashimoto','Hashimoto@gmail.com',3),
('PASAPORTE','34232334','Nerea','Chavez','Chavez@gmail.com',3),
('DNI','78676756','Maria Sonia','Lillo','Lillo@gmail.com',3),
('DNI','78787979','Nagore','Quiros','Quiros@gmail.com',3),
('DNI','70707878','Maria Belen','Antunez','Antunez@gmail.com',3)

GO
