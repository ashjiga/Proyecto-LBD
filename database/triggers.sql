--Triggers--
--Secuencia Historial_Ventas
CREATE SEQUENCE seq_historial_ventas START WITH 6 INCREMENT BY 1;
/

--Trigger descontar stock
CREATE OR REPLACE TRIGGER trg_descuento_stock
AFTER INSERT ON Detalle_Ventas
FOR EACH ROW
BEGIN
    UPDATE Inventario
    SET stock_actual = stock_actual - :NEW.cantidad
    WHERE id_inventario = :NEW.id_inventario;
END;
/

--Trigger validar stock
CREATE OR REPLACE TRIGGER trg_validar_stock
BEFORE INSERT ON Detalle_Ventas
FOR EACH ROW
DECLARE
    v_stock NUMBER;
BEGIN
    SELECT stock_actual INTO v_stock
    FROM Inventario
    WHERE id_inventario = :NEW.id_inventario;

    IF v_stock < :NEW.cantidad THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Stock insuficiente. Disponible: ' || v_stock ||
            ', solicitado: ' || :NEW.cantidad);
    END IF;
END;
/

--Trigger registrar historial de ventas
CREATE OR REPLACE TRIGGER trg_historial_ventas AFTER
    INSERT ON ventas
    FOR EACH ROW
BEGIN
INSERT INTO historial_ventas (
    id_historico,
    id_venta,
    id_cliente,
    nombre_cliente,
    fecha_venta,
    total_venta,
    numero_factura,
    cantidad_items,
    productos_detalle,
    fecha_registro
) VALUES ( seq_historial_ventas.NEXTVAL,
           :new.id_venta,
           :new.id_cliente,
           nombre_cliente(:new.id_cliente),
           :new.fecha,
           :new.total,
           NULL,
           0,
           NULL,
           sysdate );

end;
/