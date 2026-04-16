--  VISTAS
-- 1. Productos con su categoría
CREATE OR REPLACE VIEW vw_productos_categoria AS
SELECT p.id_producto, p.nombre, p.descripcion,
       p.precio_venta, c.nombre_categoria
FROM   Productos  p
JOIN   Categorias c ON p.id_categoria = c.id_categoria;

-- 2. Inventario con nombre del producto
CREATE OR REPLACE VIEW vw_inventario_completo AS
SELECT i.id_inventario, p.nombre AS producto,
       i.talla, i.stock_actual, p.precio_venta
FROM   Inventario i
JOIN   Productos  p ON p.id_producto = i.id_producto;

-- 3. Items con stock bajo
CREATE OR REPLACE VIEW vw_stock_bajo AS
SELECT p.nombre AS producto, c.nombre_categoria,
       i.talla, i.stock_actual
FROM   Inventario i
JOIN   Productos  p ON p.id_producto  = i.id_producto
JOIN   Categorias c ON c.id_categoria = p.id_categoria
WHERE  i.stock_actual < 10;

-- 4. Ventas con nombre de cliente y total calculado
CREATE OR REPLACE VIEW vw_ventas_totales AS
SELECT v.id_venta,
       nombre_cliente(v.id_cliente) AS cliente,
       v.fecha,
       fn_total_venta(v.id_venta)   AS total_calculado,
       v.total                      AS total_registrado
FROM   Ventas v;

-- 5. Facturas con nombre del cliente
CREATE OR REPLACE VIEW vw_facturas_cliente AS
SELECT f.id_factura, f.numero_factura,
       nombre_cliente(v.id_cliente) AS cliente,
       f.fecha_emision, f.subtotal,
       f.impuesto, f.total_factura, f.estado
FROM   Facturas f
JOIN   Ventas   v ON v.id_venta = f.id_venta;

-- 6. Facturas pendientes o anuladas
CREATE OR REPLACE VIEW vw_facturas_pendientes AS
SELECT f.id_factura, f.numero_factura,
       nombre_cliente(v.id_cliente) AS cliente,
       f.fecha_emision, f.total_factura, f.estado
FROM   Facturas f
JOIN   Ventas   v ON v.id_venta = f.id_venta
WHERE  f.estado <> 'Pagada';

-- 7. Detalle de facturas con número de factura
CREATE OR REPLACE VIEW vw_detalle_facturas AS
SELECT df.id_detalle_fac, f.numero_factura,
       df.descripcion_item, df.cantidad,
       df.precio_unitario, df.subtotal_linea
FROM   Detalle_Facturas df
JOIN   Facturas         f ON f.id_factura = df.id_factura;

-- 8. Productos más vendidos por unidades
CREATE OR REPLACE VIEW vw_productos_mas_vendidos AS
SELECT p.nombre,
       SUM(dv.cantidad)                      AS unidades_vendidas,
       SUM(dv.cantidad * dv.precio_unitario) AS ingresos_total
FROM   Detalle_Ventas dv
JOIN   Inventario     i ON i.id_inventario = dv.id_inventario
JOIN   Productos      p ON p.id_producto   = i.id_producto
GROUP  BY p.nombre
ORDER  BY unidades_vendidas DESC;

-- 9. Resumen estadístico por categoría
CREATE OR REPLACE VIEW vw_resumen_categoria AS
SELECT c.nombre_categoria,
       COUNT(p.id_producto) AS total_productos,
       AVG(p.precio_venta)  AS precio_promedio,
       MIN(p.precio_venta)  AS precio_min,
       MAX(p.precio_venta)  AS precio_max
FROM   Categorias c
JOIN   Productos  p ON p.id_categoria = c.id_categoria
GROUP  BY c.nombre_categoria;

-- 10. Historial de ventas resumido
CREATE OR REPLACE VIEW vw_historial_ventas AS
SELECT id_historico, id_venta, nombre_cliente,
       fecha_venta, total_venta, numero_factura,
       cantidad_items, productos_detalle
FROM   Historial_Ventas;