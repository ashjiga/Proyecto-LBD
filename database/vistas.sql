--Vista de productos con categoría
CREATE OR REPLACE VIEW vw_productos_categoria AS
SELECT 
    p.id_producto,
    p.nombre,
    p.descripcion,
    p.precio_venta,
    c.nombre_categoria
FROM Productos p
JOIN Categorias c ON p.id_categoria = c.id_categoria;

--Vista de inventario
CREATE OR REPLACE VIEW vw_inventario AS
SELECT 
    i.id_inventario,
    p.nombre AS producto,
    i.talla,
    i.stock_actual
FROM Inventario i
JOIN Productos p ON i.id_producto = p.id_producto;

--Vista de ventas con cliente
CREATE OR REPLACE VIEW vw_ventas_cliente AS
SELECT 
    v.id_venta,
    nombre_cliente(v.id_cliente) AS cliente,
    v.fecha,
    v.total
FROM Ventas v;

--Vista detalle de ventas
CREATE OR REPLACE VIEW vw_detalle_ventas AS
SELECT 
    dv.id_detalle,
    dv.id_venta,
    p.nombre AS producto,
    i.talla,
    dv.cantidad,
    dv.precio_unitario,
    fn_subtotal(dv.cantidad, dv.precio_unitario) AS subtotal
FROM Detalle_Ventas dv
JOIN Inventario i ON dv.id_inventario = i.id_inventario
JOIN Productos p ON i.id_producto = p.id_producto;

--Vista de facturas
CREATE OR REPLACE VIEW vw_facturas AS
SELECT 
    f.id_factura,
    f.numero_factura,
    nombre_cliente(v.id_cliente) AS cliente,
    f.fecha_emision,
    f.subtotal,
    f.impuesto,
    f.total_factura,
    f.estado
FROM Facturas f
JOIN Ventas v ON f.id_venta = v.id_venta;
