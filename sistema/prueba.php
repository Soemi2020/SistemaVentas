BEGIN
    	DECLARE existe_venta int;
        DECLARE registros int;
        DECLARE a int;
        
        DECLARE cod_producto int;
        DECLARE cant_producto int;
        DECLARE existencia_actual int;
        DECLARE nueva_existencia int;
        
        SET existe_venta = (SELECT COUNT(*) FROM venta WHERE noventa = no_venta and status != 2);
        
        IF existe_venta > 0 THEN
        	CREATE TEMPORARY TABLE tbl_tmp (
                id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                cod_prod BIGINT,
                cant_prod int);
                
                SET a = 1;
                
                SET registros = (SELECT COUNT(*)FROM detalleventa WHERE noventa = no_venta);
                
                IF registros > 0 THEN
                	INSERT INTO tbl_tmp(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detalleventa WHERE noventa = no_venta;
                    
                    WHILE a <= registros DO
                    	SELECT cod_prod,cant_prod INTO cod_producto,cant_producto FROM tbl_tmp WHERE id = a;
                        SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = cod_producto;
                        SET nueva_existencia = existencia_actual + cant_producto;
                        UPDATE producto SET existencia = nueva_existencia WHERE codproducto = cod_producto;
           UPDATE detalleventa SET status = 2 WHERE noventa = no_venta;
           DELETE FROM venta WHERE noventa = no_venta;
        
                        SET a=a+1;
                    
                    END WHILE;
                    UPDATE venta SET status = 2 WHERE noventa = no_venta;
                    
                    DROP TABLE tbl_tmp;
                    SELECT * FROM venta WHERE noventa = no_venta;
                
                END IF;
        
        ELSE
        	SELECT 0 venta;
        END IF;
    
    END





    COMPRA..................................................
BEGIN
	DECLARE existe_venta int;
        DECLARE registros int;
        DECLARE a int;
        
        DECLARE cod_producto int;
        DECLARE cant_producto int;
        DECLARE existencia_actual int;
        DECLARE nueva_existencia int;
        
        SET existe_venta = (SELECT COUNT(*) FROM compras WHERE nocompra = no_venta and status != 2);
        
        IF existe_venta > 0 THEN
        	CREATE TEMPORARY TABLE tbl_tmp (
                id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                cod_prod BIGINT,
                cant_prod int);
                
                SET a = 1;
                
                SET registros = (SELECT COUNT(*)FROM entradas WHERE nocompra = no_venta);
                
                IF registros > 0 THEN
                	INSERT INTO tbl_tmp(cod_prod,cant_prod) SELECT codproducto,cantidad FROM entradas WHERE nocompra = no_venta;
                    
                    WHILE a <= registros DO
                    	SELECT cod_prod,cant_prod INTO cod_producto,cant_producto FROM tbl_tmp WHERE id = a;
                        SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = cod_producto;
                        SET nueva_existencia = existencia_actual - cant_producto;
                        UPDATE producto SET existencia = nueva_existencia WHERE codproducto = cod_producto;
                        
                        SET a=a+1;
                    
                    END WHILE;
                    UPDATE compras SET status = 2 WHERE nocompra = no_venta;
                    DELETE FROM compras WHERE nocompra = no_venta;
                    DROP TABLE tbl_tmp;
                    SELECT * FROM compras WHERE nocompra = no_venta;
                
                END IF;
        
        ELSE
        	SELECT 0 compras;
        END IF;
    
END

DESCUENTO ---------------------------------------------
BEGIN
    	DECLARE venta INT;
        
        DECLARE registros INT;
        DECLARE subtotal DECIMAL(10,2);
        DECLARE total DECIMAL(10,2);
        
        
        
        DECLARE nueva_existencia int;
        DECLARE existencia_actual int;
        
        DECLARE tmp_cod_producto int;
        DECLARE tmp_cant_producto int;
        DECLARE a INT;
        SET a = 1;
        
        CREATE TEMPORARY TABLE tbl_tmp_tokenuser(
        		id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
        		cod_prod BIGINT,
        		cant_prod int);
        
       
        SET registros = (SELECT COUNT(*) FROM detalle_temp WHERE token_user = token);
        
        IF registros > 0 THEN
        	INSERT INTO tbl_tmp_tokenuser(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detalle_temp WHERE token_user = token;



            
            INSERT INTO venta(usuario,caja,codcliente,status,descuento) VALUES(cod_usuario,id_caja,cod_cliente,tipo_pago,descuento);
            SET venta = LAST_INSERT_ID();
            
            INSERT INTO detalleventa(noventa,codproducto,cantidad,costo,precio_venta) SELECT(venta) as noventa, codproducto,cantidad,costo,precio_venta FROM detalle_temp WHERE token_user = token;
            
            WHILE a <= registros DO
            	SELECT cod_prod,cant_prod INTO tmp_cod_producto,tmp_cant_producto FROM tbl_tmp_tokenuser WHERE id = a;
                
                SET a=a+1;
           
            END WHILE;
            
            SET subtotal = (SELECT SUM(cantidad * precio_venta) FROM detalle_temp WHERE token_user = token);
            SET total = subtotal ;
            UPDATE venta SET totalventa = total WHERE noventa = venta;

            SELECT totalventa INTO descuento FROM venta WHERE noventa = venta;


            SET descuento = descuento * .16;
            UPDATE venta SET descuento = descuento WHERE noventa = venta;





            DELETE FROM detalle_temp WHERE token_user = token;
            TRUNCATE TABLE tbl_tmp_tokenuser;
            SELECT * FROM venta WHERE noventa = venta;
            
        ELSE
        	SELECT 0;
        END IF;
    END








    BEGIN
    	
        DECLARE usuarios int;
        DECLARE clientes int;
        DECLARE proveedores int;
        DECLARE productos int;
        DECLARE ventas decimal(10,2);
        DECLARE abonos decimal(10,2);
        DECLARE pagos decimal(10,2);
        DECLARE compra decimal(10,2);
        DECLARE cobrar decimal(10,2);
        DECLARE pagar decimal(10,2);
        DECLARE egreso decimal(10,2);
        DECLARE credito decimal(10,2);
        DECLARE inicios decimal(10,2);
        
        SELECT COUNT(*) INTO usuarios FROM usuario WHERE status !=10;
        SELECT COUNT(*) INTO clientes FROM cliente WHERE status !=10;
        SELECT COUNT(*) INTO proveedores FROM proveedor WHERE status !=10;
        SELECT COUNT(*) INTO productos FROM producto WHERE status !=10;
        SELECT SUM(totalventa) INTO ventas FROM venta WHERE caja = caja_id AND status =1;
        SELECT SUM(totalventa) INTO credito FROM venta WHERE caja = caja_id AND status =3;
        SELECT SUM(cantidad) INTO abonos FROM detalle_recibo WHERE caja = caja_id;
        SELECT SUM(cantidad) INTO pagos FROM detalle_recibo_compra WHERE caja = caja_id;
        SELECT SUM(totalcompra) INTO compra FROM compras WHERE caja = caja_id AND status =1;
        SELECT SUM(cantidad) INTO egreso FROM egresos WHERE caja = caja_id;
        SELECT SUM(totalventa-abono) INTO cobrar FROM venta WHERE status =3;
        SELECT SUM(totalcompra-abono) INTO pagar FROM compras WHERE status =3;
        SELECT inicio INTO inicios FROM caja WHERE status =1;
        
        SELECT usuarios,clientes,proveedores,productos,ventas,abonos,pagos,compra,cobrar,pagar,egreso,credito,inicios;
    END




