--  INSERTS
INSERT INTO Categorias VALUES (1,'Camisetas');
INSERT INTO Categorias VALUES (2,'Pantalones');
INSERT INTO Categorias VALUES (3,'Vestidos');
INSERT INTO Categorias VALUES (4,'Conjuntos');
INSERT INTO Categorias VALUES (5,'Accesorios');
INSERT INTO Categorias VALUES (6,'Abrigos');

INSERT INTO Productos VALUES (1,1,'Camiseta Dinosaurio','Camiseta infantil estampada',4500);
INSERT INTO Productos VALUES (2,1,'Camiseta Superheroe','Camiseta algodón',5000);
INSERT INTO Productos VALUES (3,1,'Camiseta Animales','Camiseta con estampado de animales',4000);
INSERT INTO Productos VALUES (4,2,'Pantalon Jeans','Pantalon resistente',5000);
INSERT INTO Productos VALUES (5,2,'Pantalon Deportivo','Pantalon cómodo',4500);
INSERT INTO Productos VALUES (6,3,'Vestido Floral','Vestido infantil',5500);
INSERT INTO Productos VALUES (7,3,'Vestido Princesa','Vestido elegante infantil',6000);
INSERT INTO Productos VALUES (8,4,'Conjunto Deportivo','Camiseta y short',5000);
INSERT INTO Productos VALUES (9,4,'Conjunto Casual','Conjunto camiseta y pantalon',7000);
INSERT INTO Productos VALUES (10,5,'Gorra Infantil','Gorra ajustable',2000);
INSERT INTO Productos VALUES (11,5,'Medias Infantiles','Medias de algodón',1500);
INSERT INTO Productos VALUES (12,6,'Chaqueta Infantil','Chaqueta para clima frío',6000);

INSERT INTO Inventario VALUES (1,1,'3M',15);
INSERT INTO Inventario VALUES (2,1,'6M',12);
INSERT INTO Inventario VALUES (3,1,'1A',10);
INSERT INTO Inventario VALUES (4,2,'2A',9);
INSERT INTO Inventario VALUES (5,2,'4A',8);
INSERT INTO Inventario VALUES (6,3,'6A',11);
INSERT INTO Inventario VALUES (7,3,'8A',7);
INSERT INTO Inventario VALUES (8,4,'10A',6);
INSERT INTO Inventario VALUES (9,4,'12A',5);
INSERT INTO Inventario VALUES (10,5,'14A',8);
INSERT INTO Inventario VALUES (11,6,'4A',10);
INSERT INTO Inventario VALUES (12,6,'6A',9);
INSERT INTO Inventario VALUES (13,7,'8A',6);
INSERT INTO Inventario VALUES (14,7,'10A',5);
INSERT INTO Inventario VALUES (15,8,'6A',12);
INSERT INTO Inventario VALUES (16,9,'8A',9);
INSERT INTO Inventario VALUES (17,10,'2A',14);
INSERT INTO Inventario VALUES (18,11,'4A',20);
INSERT INTO Inventario VALUES (19,12,'10A',7);
INSERT INTO Inventario VALUES (20,12,'12A',6);

INSERT INTO Clientes VALUES (1,'Ana','Lopez','88881111','ana@email.com');
INSERT INTO Clientes VALUES (2,'Carlos','Ramirez','88882222','carlos@email.com');
INSERT INTO Clientes VALUES (3,'Maria','Gomez','88883333','maria@email.com');
INSERT INTO Clientes VALUES (4,'Jose','Perez','88884444','jose@email.com');
INSERT INTO Clientes VALUES (5,'Marcela','Fernandez','88885555','marcela@email.com');
INSERT INTO Clientes VALUES (6,'Pedro','Soto','88886666','pedro@email.com');

INSERT INTO Ventas VALUES (1,1,SYSDATE,13000);
INSERT INTO Ventas VALUES (2,2,SYSDATE,8000);
INSERT INTO Ventas VALUES (3,3,SYSDATE,8500);
INSERT INTO Ventas VALUES (4,4,SYSDATE,7000);
INSERT INTO Ventas VALUES (5,5,SYSDATE,8000);

INSERT INTO Detalle_Ventas VALUES (1,1,1,1,4500);
INSERT INTO Detalle_Ventas VALUES (2,4,1,1,5000);
INSERT INTO Detalle_Ventas VALUES (3,13,1,1,2000);
INSERT INTO Detalle_Ventas VALUES (4,14,1,1,1500);
INSERT INTO Detalle_Ventas VALUES (5,2,2,1,4500);
INSERT INTO Detalle_Ventas VALUES (6,13,2,1,2000);
INSERT INTO Detalle_Ventas VALUES (7,14,2,1,1500);
INSERT INTO Detalle_Ventas VALUES (8,6,3,1,4000);
INSERT INTO Detalle_Ventas VALUES (9,8,3,1,4500);
INSERT INTO Detalle_Ventas VALUES (10,7,4,1,5000);
INSERT INTO Detalle_Ventas VALUES (11,13,4,1,2000);
INSERT INTO Detalle_Ventas VALUES (12,11,5,1,5000);
INSERT INTO Detalle_Ventas VALUES (13,14,5,2,1500);

INSERT INTO Facturas VALUES (1,1,'FAC-01',SYSDATE,13000,0,13000,'Pagada');
INSERT INTO Facturas VALUES (2,2,'FAC-02',SYSDATE,8000,0,8000,'Pagada');
INSERT INTO Facturas VALUES (3,3,'FAC-03',SYSDATE,8500,0,8500,'Pagada');
INSERT INTO Facturas VALUES (4,4,'FAC-04',SYSDATE,7000,0,7000,'Pagada');
INSERT INTO Facturas VALUES (5,5,'FAC-05',SYSDATE,8000,0,8000,'Pagada');

INSERT INTO Detalle_Facturas VALUES (1,1,1,'Camiseta Dinosaurio',1,4500,4500);
INSERT INTO Detalle_Facturas VALUES (2,1,4,'Pantalon Jeans',1,5000,5000);
INSERT INTO Detalle_Facturas VALUES (3,1,13,'Gorra Infantil',1,2000,2000);
INSERT INTO Detalle_Facturas VALUES (4,1,14,'Medias Infantiles',1,1500,1500);
INSERT INTO Detalle_Facturas VALUES (5,2,2,'Camiseta Superheroe',1,4500,4500);
INSERT INTO Detalle_Facturas VALUES (6,2,13,'Gorra Infantil',1,2000,2000);
INSERT INTO Detalle_Facturas VALUES (7,2,14,'Medias Infantiles',1,1500,1500);

INSERT INTO Historial_Ventas VALUES (1,1,1,'Ana Lopez',SYSDATE,13000,'FAC-01',4,'Camiseta Dinosaurio, Pantalon Jeans, Gorra, Medias',SYSDATE);
INSERT INTO Historial_Ventas VALUES (2,2,2,'Carlos Ramirez',SYSDATE,8000,'FAC-02',3,'Camiseta, Gorra, Medias',SYSDATE);
INSERT INTO Historial_Ventas VALUES (3,3,3,'Maria Gomez',SYSDATE,8500,'FAC-03',2,'Camiseta Animales, Pantalon Deportivo',SYSDATE);
INSERT INTO Historial_Ventas VALUES (4,4,4,'Jose Perez',SYSDATE,7000,'FAC-04',2,'Pantalon Jeans, Gorra',SYSDATE);
INSERT INTO Historial_Ventas VALUES (5,5,5,'Marcela Fernandez',SYSDATE,8000,'FAC-05',2,'Conjunto Deportivo, Medias',SYSDATE);
