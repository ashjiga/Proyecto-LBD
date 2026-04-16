-- TABLAS
CREATE TABLE Categorias (
    id_categoria NUMBER PRIMARY KEY,
    nombre_categoria VARCHAR2(100) NOT NULL
);

CREATE TABLE Productos (
    id_producto NUMBER PRIMARY KEY,
    id_categoria NUMBER,
    nombre VARCHAR2(100) NOT NULL,
    descripcion VARCHAR2(200),
    precio_venta NUMBER(10,2) NOT NULL,
    CONSTRAINT fk_producto_categoria
    FOREIGN KEY (id_categoria)
    REFERENCES Categorias(id_categoria)
);

CREATE TABLE Inventario (
    id_inventario NUMBER PRIMARY KEY,
    id_producto NUMBER,
    talla VARCHAR2(5),
    stock_actual NUMBER,
    CONSTRAINT fk_inventario_producto
    FOREIGN KEY (id_producto)
    REFERENCES Productos(id_producto),
    CONSTRAINT chk_talla
    CHECK (talla IN ('3M','6M','1A','2A','4A','6A','8A','10A','12A','14A'))
);

CREATE TABLE Clientes (
    id_cliente NUMBER PRIMARY KEY,
    nombre VARCHAR2(100),
    apellido VARCHAR2(100),
    telefono VARCHAR2(20),
    email VARCHAR2(100)
);

CREATE TABLE Ventas (
    id_venta NUMBER PRIMARY KEY,
    id_cliente NUMBER,
    fecha DATE,
    total NUMBER(10,2),
    CONSTRAINT fk_venta_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES Clientes(id_cliente)
);

CREATE TABLE Detalle_Ventas (
    id_detalle NUMBER PRIMARY KEY,
    id_inventario NUMBER,
    id_venta NUMBER,
    cantidad NUMBER,
    precio_unitario NUMBER(10,2),
    CONSTRAINT fk_detalle_inventario
    FOREIGN KEY (id_inventario)
    REFERENCES Inventario(id_inventario),
    CONSTRAINT fk_detalle_venta
    FOREIGN KEY (id_venta)
    REFERENCES Ventas(id_venta)
);

CREATE TABLE Facturas (
    id_factura NUMBER PRIMARY KEY,
    id_venta NUMBER,
    numero_factura VARCHAR2(50),
    fecha_emision DATE,
    subtotal NUMBER(10,2),
    impuesto NUMBER(10,2),
    total_factura NUMBER(10,2),
    estado VARCHAR2(20),
    CONSTRAINT fk_factura_venta
    FOREIGN KEY (id_venta)
    REFERENCES Ventas(id_venta)
);

CREATE TABLE Detalle_Facturas (
    id_detalle_fac NUMBER PRIMARY KEY,
    id_factura NUMBER,
    id_inventario NUMBER,
    descripcion_item VARCHAR2(200),
    cantidad NUMBER,
    precio_unitario NUMBER(10,2),
    subtotal_linea NUMBER(10,2),
    CONSTRAINT fk_detallefac_factura
    FOREIGN KEY (id_factura)
    REFERENCES Facturas(id_factura),
    CONSTRAINT fk_detallefac_inventario
    FOREIGN KEY (id_inventario)
    REFERENCES Inventario(id_inventario)
);

CREATE TABLE Historial_Ventas (
    id_historico NUMBER PRIMARY KEY,
    id_venta NUMBER,
    id_cliente NUMBER,
    nombre_cliente VARCHAR2(200),
    fecha_venta DATE,
    total_venta NUMBER(10,2),
    numero_factura VARCHAR2(50),
    cantidad_items NUMBER,
    productos_detalle VARCHAR2(500),
    fecha_registro DATE
);