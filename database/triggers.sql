--  TRIGGERS
-- 1. Validar stock antes de insertar un detalle de venta
CREATE OR REPLACE TRIGGER trg_validar_stock
BEFORE INSERT ON Detalle_Ventas
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT stock_actual
    INTO   v_stock
    FROM   Inventario
    WHERE  id_inventario = :NEW.id_inventario;
    IF v_stock < :NEW.cantidad THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Stock insuficiente. Disponible: ' || v_stock ||
            ', solicitado: ' || :NEW.cantidad);
    END IF;
END;
/

-- 2. Descontar stock al confirmar venta
CREATE OR REPLACE TRIGGER trg_descuento_stock
AFTER INSERT ON Detalle_Ventas
FOR EACH ROW
BEGIN
    UPDATE Inventario
    SET    stock_actual = stock_actual - :NEW.cantidad
    WHERE  id_inventario = :NEW.id_inventario;
END;
/

-- 3. Registrar en historial al crear una venta
CREATE OR REPLACE TRIGGER trg_historial_ventas
AFTER INSERT ON Ventas
FOR EACH ROW
BEGIN
    INSERT INTO Historial_Ventas (
        id_historico, id_venta, id_cliente, nombre_cliente,
        fecha_venta, total_venta, numero_factura,
        cantidad_items, productos_detalle, fecha_registro
    ) VALUES (
        SEQ_HISTORIAL_VENTAS.NEXTVAL,
        :NEW.id_venta,
        :NEW.id_cliente,
        nombre_cliente(:NEW.id_cliente),
        :NEW.fecha,
        :NEW.total,
        NULL, 0, NULL, SYSDATE
    );
END;
/

-- 4. Actualizar total de venta cuando cambia la cantidad en el detalle
CREATE OR REPLACE TRIGGER trg_actualizar_total_venta
AFTER UPDATE OF cantidad ON Detalle_Ventas
FOR EACH ROW
BEGIN
    UPDATE Ventas
    SET    total = fn_total_venta(:NEW.id_venta)
    WHERE  id_venta = :NEW.id_venta;
END;
/

-- 5. Poblar Detalle_Facturas automáticamente al emitir factura
CREATE OR REPLACE TRIGGER trg_detalle_factura_auto
AFTER INSERT ON Facturas
FOR EACH ROW
BEGIN
    INSERT INTO Detalle_Facturas (
        id_detalle_fac, id_factura, id_inventario,
        descripcion_item, cantidad, precio_unitario, subtotal_linea
    )
    SELECT SEQ_DETALLE_FACTURAS.NEXTVAL,
           :NEW.id_factura,
           dv.id_inventario,
           p.nombre,
           dv.cantidad,
           dv.precio_unitario,
           dv.cantidad * dv.precio_unitario
    FROM   Detalle_Ventas dv
    JOIN   Inventario     i ON i.id_inventario = dv.id_inventario
    JOIN   Productos      p ON p.id_producto   = i.id_producto
    WHERE  dv.id_venta = :NEW.id_venta;
END;
/
