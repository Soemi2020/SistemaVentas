-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 24-04-2024 a las 10:06:46
-- Versión del servidor: 10.4.27-MariaDB
-- Versión de PHP: 7.4.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bd_ventas`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_precio_producto` (IN `n_cantidad` INT, IN `n_precio` DECIMAL(10,2), IN `codigo` INT)   BEGIN
    	DECLARE nueva_existencia int;
        DECLARE nuevo_total decimal(10,2);
        DECLARE nuevo_precio decimal(10,2);
        
        DECLARE cant_actual int;
        DECLARE pre_actual decimal(10,2);
        
        DECLARE actual_existencia int;
        DECLARE actual_precio decimal(10,2);
        
        SELECT precio,existencia INTO actual_precio,actual_existencia FROM producto WHERE codproducto = codigo;
        SET nueva_existencia = actual_existencia + n_cantidad;
        
        UPDATE producto SET existencia = nueva_existencia, precio = n_precio WHERE codproducto = codigo;
        
        SELECT nueva_existencia,nuevo_precio;
        
     END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_detalle_temp` (IN `codigo` INT, IN `cantidad` INT, IN `token_user` VARCHAR(50))   BEGIN
    
    	DECLARE precio_actual decimal(10,2);
        DECLARE costo_actual decimal(10,2);
        DECLARE existencia_actual int;
        DECLARE nueva_existencia int;
        
SELECT costo,precio INTO costo_actual,precio_actual FROM producto WHERE codproducto = codigo;
        
        INSERT INTO detalle_temp(token_user,codproducto,cantidad,costo,precio_venta) VALUES(token_user,codigo,cantidad,costo_actual,precio_actual);
        
        SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = codigo;

                SET nueva_existencia = existencia_actual - cantidad;
                UPDATE producto SET existencia = nueva_existencia WHERE codproducto = codigo;
        
        SELECT tmp.correlativo, tmp.codproducto,p.descripcion,tmp.cantidad,tmp.precio_venta FROM detalle_temp tmp
        INNER JOIN producto p 
        ON tmp.codproducto = p.codproducto
        WHERE tmp.token_user = token_user;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_detalle_temp_compra` (IN `codigo` INT, IN `cantidad` INT, IN `token_user` VARCHAR(50), IN `costo` DECIMAL(10,2))   BEGIN 
	    DECLARE precio_actual decimal(10,2);
        DECLARE existencia_actual int;
        DECLARE nueva_existencia int;
        
        INSERT INTO detalle_temp_compra(token_user,codproducto,cantidad,precio_venta) VALUES(token_user,codigo,cantidad,costo);
        
        SELECT tmp.correlativo, tmp.codproducto,p.descripcion,tmp.cantidad,tmp.precio_venta FROM detalle_temp_compra tmp
        INNER JOIN producto p 
        ON tmp.codproducto = p.codproducto
        WHERE tmp.token_user = token_user;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `anular_compra` (IN `no_venta` INT)   BEGIN
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
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `anular_venta` (IN `no_venta` INT)   BEGIN
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
    
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancelar_compra` (IN `token` INT)   BEGIN
    	DECLARE existe_venta int;
        DECLARE registros int;
        DECLARE a int;
        
        DECLARE cod_producto int; 
        DECLARE cant_producto int;
        DECLARE existencia_actual int;
        DECLARE nueva_existencia int;
        
        SET existe_venta = (SELECT COUNT(*) FROM detalle_temp_compra WHERE token_user = token);
        
        IF existe_venta > 0 THEN
        	CREATE TEMPORARY TABLE tbl_tmp (
                id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                cod_prod BIGINT,
                cant_prod int);
                
                SET a = 1;
                
                SET registros = (SELECT COUNT(*)FROM detalle_temp_compra WHERE token_user = token);
                
                IF registros > 0 THEN
                	INSERT INTO tbl_tmp(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detalle_temp_compra WHERE token_user = token;
                    
                    WHILE a <= registros DO
                    	SELECT cod_prod,cant_prod INTO cod_producto,cant_producto FROM tbl_tmp WHERE id = a;
                        SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = cod_producto;
                        SET nueva_existencia = existencia_actual + cant_producto;
                        UPDATE producto SET existencia = nueva_existencia WHERE codproducto = cod_producto;
                        
                        SET a=a+1;
                    
                    END WHILE;
       DELETE FROM detalle_temp_compra WHERE token_user = token;
              DROP TABLE tbl_tmp;
       SELECT * FROM detalle_temp_compra WHERE token_user = token;
                
                END IF;
        
        ELSE
        	SELECT 0 detalle_temp_compra;
        END IF;
    
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancelar_venta` (IN `token` INT)   BEGIN
    	DECLARE existe_venta int;
        DECLARE registros int;
        DECLARE a int;
        
        DECLARE cod_producto int; 
        DECLARE cant_producto int;
        DECLARE existencia_actual int;
        DECLARE nueva_existencia int;
        
        SET existe_venta = (SELECT COUNT(*) FROM detalle_temp WHERE token_user = token);
        
        IF existe_venta > 0 THEN
        	CREATE TEMPORARY TABLE tbl_tmp (
                id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                cod_prod BIGINT,
                cant_prod int);
                
                SET a = 1;
                
                SET registros = (SELECT COUNT(*)FROM detalle_temp WHERE token_user = token);
                
                IF registros > 0 THEN
                	INSERT INTO tbl_tmp(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detalle_temp WHERE token_user = token;
                    
                    WHILE a <= registros DO
                    	SELECT cod_prod,cant_prod INTO cod_producto,cant_producto FROM tbl_tmp WHERE id = a;
                        SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = cod_producto;
                        SET nueva_existencia = existencia_actual + cant_producto;
                        UPDATE producto SET existencia = nueva_existencia WHERE codproducto = cod_producto;
                        
                        SET a=a+1;
                    
                    END WHILE;
       DELETE FROM detalle_temp WHERE token_user = token;
              DROP TABLE tbl_tmp;
       SELECT * FROM detalle_temp WHERE token_user = token;
                
                END IF;
        
        ELSE
        	SELECT 0 detalle_temp;
        END IF;
    
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `dataDashboard` (IN `caja_id` INT)   BEGIN
    	
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
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `del_detalle_temp` (IN `id_detalle` INT, IN `token` VARCHAR(50))   BEGIN    
		DECLARE existe_venta int;
        DECLARE registros int;
        DECLARE a int;
        
        DECLARE cod_producto int;
        DECLARE cant_producto int;
        DECLARE existencia_actual int;
        DECLARE nueva_existencia int;
        

        	CREATE TEMPORARY TABLE tbl_tmp (id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                cod_prod BIGINT,
                cant_prod int);
                
                SET a = 1;
                
                SET registros = (SELECT COUNT(*)FROM detalle_temp WHERE correlativo = id_detalle);
                

                	INSERT INTO tbl_tmp(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detalle_temp WHERE correlativo = id_detalle;
                    
                    	SELECT cod_prod,cant_prod INTO cod_producto,cant_producto FROM tbl_tmp WHERE id = a;
                        SELECT existencia INTO existencia_actual FROM producto WHERE codproducto = cod_producto;
                        SET nueva_existencia = existencia_actual + cant_producto;
                        UPDATE producto SET existencia = nueva_existencia WHERE codproducto = cod_producto;

            DELETE FROM detalle_temp WHERE correlativo = id_detalle;
  
            SELECT tmp.correlativo, tmp.codproducto,p.descripcion,tmp.cantidad,tmp.precio_venta FROM detalle_temp tmp
            INNER JOIN producto p 
            ON tmp.codproducto = p.codproducto
            WHERE tmp.token_user = token;
        END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `del_detalle_temp_compra` (IN `id_detalle` INT, IN `token` VARCHAR(50))   BEGIN  	
  		DECLARE existe_venta int;
        DECLARE registros int;
        DECLARE a int;
        
        DECLARE cod_producto int;
        DECLARE cant_producto int;
        DECLARE existencia_actual int;
        DECLARE nueva_existencia int;
        

        CREATE TEMPORARY TABLE tbl_tmp (id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                cod_prod BIGINT,
                cant_prod int);
                
                SET a = 1;
                
         SET registros = (SELECT COUNT(*)FROM detalle_temp_compra WHERE correlativo = id_detalle);
                

         INSERT INTO tbl_tmp(cod_prod,cant_prod) SELECT codproducto,cantidad FROM detalle_temp_compra WHERE correlativo = id_detalle;
                    
         SELECT cod_prod,cant_prod INTO cod_producto,cant_producto FROM tbl_tmp WHERE id = a;

            DELETE FROM detalle_temp_compra WHERE correlativo = id_detalle;
  
            SELECT tmp.correlativo, tmp.codproducto,p.descripcion,tmp.cantidad,tmp.precio_venta FROM detalle_temp_compra tmp
            INNER JOIN producto p 
            ON tmp.codproducto = p.codproducto
            WHERE tmp.token_user = token;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `procesar_compra` (IN `cod_usuario` INT, IN `cod_cliente` INT, IN `token` VARCHAR(50), IN `tipo_pago` INT, IN `id_caja` INT)   BEGIN
        DECLARE venta INT;
        
        DECLARE registros INT;        
        DECLARE total DECIMAL(10,2);
        
        DECLARE nueva_existencia int;
        DECLARE nuevo_costo DECIMAL(10,2);
        DECLARE nuevo_total DECIMAL(10,2);
        
        DECLARE existencia_actual int;
        DECLARE costo_actual DECIMAL(10,2);
        
        DECLARE tmp_cod_prod int;
        DECLARE tmp_cant_prod int;
        DECLARE tmp_cost_prod DECIMAL(10,2);
        DECLARE a INT;
        SET a = 1;
        
        CREATE TEMPORARY TABLE tbl_tmp_tokenuser(
                id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
                cod_prod BIGINT,
                cant_prod int,
                cost_prod DECIMAL(10,2));
                
SET registros = (SELECT COUNT(*) FROM detalle_temp_compra WHERE token_user = token);
        
        IF registros > 0 THEN
  INSERT INTO tbl_tmp_tokenuser(cod_prod,cant_prod,cost_prod) SELECT codproducto,cantidad,precio_venta FROM detalle_temp_compra WHERE token_user = token;
            
INSERT INTO compras(usuario,caja,codproveedor,status) VALUES(cod_usuario,id_caja,cod_cliente,tipo_pago);
            SET venta = LAST_INSERT_ID();
            
INSERT INTO entradas(nocompra,codproducto,cantidad,precio) SELECT(venta) as nocompra, codproducto,cantidad,precio_venta FROM detalle_temp_compra WHERE token_user = token;
            
            WHILE a <= registros DO
 SELECT cod_prod,cant_prod,cost_prod INTO tmp_cod_prod,tmp_cant_prod,tmp_cost_prod FROM tbl_tmp_tokenuser WHERE id = a;
       
 SELECT costo,existencia INTO costo_actual,existencia_actual FROM producto WHERE codproducto = tmp_cod_prod;
                
SET nueva_existencia = existencia_actual + tmp_cant_prod;
SET nuevo_total = (existencia_actual * costo_actual) + (tmp_cant_prod * tmp_cost_prod);
SET nuevo_costo = nuevo_total / nueva_existencia;

UPDATE producto SET existencia = nueva_existencia,costo = nuevo_costo WHERE codproducto = tmp_cod_prod;
                
                SET a=a+1;
           
            END WHILE;
            
 SET total = (SELECT SUM(cantidad * precio_venta) FROM detalle_temp_compra WHERE token_user = token);
UPDATE compras SET totalcompra = total WHERE nocompra = venta;
DELETE FROM detalle_temp_compra WHERE token_user = token;
            TRUNCATE TABLE tbl_tmp_tokenuser;
            SELECT * FROM compras WHERE nocompra = venta;
            
        ELSE
            SELECT 0;
        END IF;
    END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `procesar_venta` (IN `cod_usuario` INT, IN `cod_cliente` INT, IN `token` VARCHAR(50), IN `tipo_pago` INT, IN `id_caja` INT, IN `descuento` FLOAT)   BEGIN
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
    END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caja`
--

CREATE TABLE `caja` (
  `id` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `inicio` decimal(10,2) DEFAULT NULL,
  `ventas` decimal(10,2) DEFAULT NULL,
  `abonos` decimal(10,2) DEFAULT NULL,
  `egresos` decimal(10,2) DEFAULT NULL,
  `creditos` decimal(10,2) DEFAULT NULL,
  `total_efectivo` decimal(10,2) DEFAULT NULL,
  `usuario` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `caja`
--

INSERT INTO `caja` (`id`, `fecha`, `inicio`, `ventas`, `abonos`, `egresos`, `creditos`, `total_efectivo`, `usuario`, `status`) VALUES
(161, '2024-04-04 23:00:13', '9000.00', '235.00', '0.00', '0.00', '0.00', '9235.00', 1, 2),
(162, '2024-04-05 12:37:47', '9000.00', '1606.76', '0.00', '990.00', '0.00', '9616.76', 39, 2),
(163, '2024-04-08 04:33:25', '6000.00', '90.00', '0.00', '120.00', '0.00', '5970.00', 1, 2),
(164, '2024-04-09 16:18:03', '700.00', '93.84', '0.00', '0.00', '0.00', '793.84', 1, 2),
(165, '2024-04-13 16:42:29', '5000.00', '51.56', '0.00', '80.00', '0.00', '4971.56', 1, 2),
(166, '2024-04-14 19:20:26', '500.00', '0.00', '0.00', '0.00', '0.00', '500.00', 1, 2),
(167, '2024-04-14 19:33:46', '9000.00', '9.28', '0.00', '0.00', '0.00', '9009.28', 1, 2),
(168, '2024-04-14 20:30:55', '600.00', '9.28', '0.00', '0.00', '0.00', '609.28', 1, 2),
(169, '2024-04-14 20:31:42', '700.00', '165.28', '0.00', '0.00', '0.00', '865.28', 1, 2),
(170, '2024-04-14 20:34:31', '9000.00', '0.00', '0.00', '0.00', '0.00', '9000.00', 1, 2),
(171, '2024-04-14 22:30:03', '90.00', '0.00', '0.00', '0.00', '0.00', '90.00', 1, 2),
(172, '2024-04-14 23:11:33', '5000.00', '37.12', '0.00', '0.00', '0.00', '5037.12', 1, 2),
(173, '2024-04-23 22:02:09', '8000.00', NULL, NULL, NULL, NULL, NULL, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `idcliente` int(11) NOT NULL,
  `nit` varchar(20) DEFAULT NULL,
  `nombre` varchar(80) DEFAULT NULL,
  `telefono` int(11) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `date_add` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario_id` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`idcliente`, `nit`, `nombre`, `telefono`, `direccion`, `date_add`, `usuario_id`, `status`) VALUES
(1, '0000000000', 'Cliente regular', 0, 'EL RAMA', '2021-12-05 15:47:39', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `nocompra` bigint(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `usuario` int(20) NOT NULL,
  `caja` int(11) NOT NULL,
  `codproveedor` int(20) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `totalcompra` decimal(10,2) NOT NULL,
  `abono` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `compras`
--

INSERT INTO `compras` (`nocompra`, `fecha`, `usuario`, `caja`, `codproveedor`, `status`, `totalcompra`, `abono`) VALUES
(203, '2024-04-24 04:54:01', 1, 173, 1, 1, '70.00', '0.00'),
(204, '2024-04-24 07:16:12', 1, 173, 1, 1, '7.00', '0.00'),
(205, '2024-04-24 08:03:05', 1, 173, 1, 1, '900.00', '0.00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `configuracion`
--

CREATE TABLE `configuracion` (
  `id` bigint(20) NOT NULL,
  `nit` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `razon_social` varchar(100) NOT NULL,
  `telefono` bigint(20) NOT NULL,
  `email` varchar(200) NOT NULL,
  `direccion` text NOT NULL,
  `iva` decimal(10,2) NOT NULL,
  `foto` varchar(200) NOT NULL,
  `moneda` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `configuracion`
--

INSERT INTO `configuracion` (`id`, `nit`, `nombre`, `razon_social`, `telefono`, `email`, `direccion`, `iva`, `foto`, `moneda`) VALUES
(1, '6232912905005C', 'SIGIA', 'Abarrotes', 85289255, 'sigia@gmail.com', 'Minatitlán', '28.00', 'logo_dedef89c2b5572028c088db2cf696f39.jpg', 'MX');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalleventa`
--

CREATE TABLE `detalleventa` (
  `correlativo` bigint(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `noventa` bigint(11) DEFAULT NULL,
  `codproducto` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `costo` decimal(10,2) NOT NULL,
  `precio_venta` decimal(10,2) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `detalleventa`
--

INSERT INTO `detalleventa` (`correlativo`, `fecha`, `noventa`, `codproducto`, `cantidad`, `costo`, `precio_venta`, `status`) VALUES
(1968, '2024-04-23 22:43:36', 1589, 2099, 1, '7.00', '9.28', 1),
(1969, '2024-04-24 01:17:57', 1590, 2099, 1, '7.00', '9.28', 1),
(1970, '2024-04-24 01:18:58', 1591, 2099, 1, '7.00', '9.28', 1),
(1971, '2024-04-24 01:18:58', 1591, 2099, 100, '7.00', '9.28', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_recibo`
--

CREATE TABLE `detalle_recibo` (
  `id` int(11) NOT NULL,
  `noventa` bigint(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `saldo_anterior` decimal(10,2) NOT NULL,
  `cantidad` decimal(10,2) NOT NULL,
  `saldo_actual` decimal(10,2) NOT NULL,
  `usuario` int(11) NOT NULL,
  `caja` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_recibo_compra`
--

CREATE TABLE `detalle_recibo_compra` (
  `id` int(11) NOT NULL,
  `nocompra` bigint(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `saldo_anterior` decimal(10,2) NOT NULL,
  `cantidad` decimal(10,2) NOT NULL,
  `saldo_actual` decimal(10,2) NOT NULL,
  `usuario` int(11) NOT NULL,
  `caja` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_temp`
--

CREATE TABLE `detalle_temp` (
  `correlativo` int(11) NOT NULL,
  `token_user` varchar(50) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `costo` decimal(10,2) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_temp_compra`
--

CREATE TABLE `detalle_temp_compra` (
  `correlativo` int(11) NOT NULL,
  `token_user` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `codproducto` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precio_venta` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `egresos`
--

CREATE TABLE `egresos` (
  `id` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `descripcion` text NOT NULL,
  `cantidad` decimal(10,2) NOT NULL,
  `usuario` int(11) NOT NULL,
  `caja` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas`
--

CREATE TABLE `entradas` (
  `correlativo` bigint(11) NOT NULL,
  `nocompra` bigint(11) NOT NULL,
  `codproducto` int(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `cantidad` int(11) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `usuario_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `entradas`
--

INSERT INTO `entradas` (`correlativo`, `nocompra`, `codproducto`, `fecha`, `cantidad`, `precio`, `usuario_id`) VALUES
(943, 203, 2100, '2024-04-23 22:54:01', 1, '70.00', 0),
(944, 204, 2099, '2024-04-24 01:16:12', 1, '7.00', 0),
(945, 205, 2102, '2024-04-24 02:03:05', 10, '90.00', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `codproducto` int(20) NOT NULL,
  `codigo` varchar(20) NOT NULL,
  `descripcion` varchar(100) DEFAULT NULL,
  `proveedor` int(11) DEFAULT NULL,
  `costo` decimal(10,2) NOT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `existencia` int(11) NOT NULL,
  `foto` text DEFAULT NULL,
  `date_add` datetime NOT NULL DEFAULT current_timestamp(),
  `status` int(11) DEFAULT 1,
  `usuario_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`codproducto`, `codigo`, `descripcion`, `proveedor`, `costo`, `precio`, `existencia`, `foto`, `date_add`, `status`, `usuario_id`) VALUES
(2099, '4040', 'lulul', 1, '7.00', '9.28', 43, 'img_producto.png', '2024-04-06 14:07:54', 1, 1),
(2100, '6060', 'soe', 1, '70.00', '92.80', 1, 'img_producto.png', '2024-04-21 18:56:42', 1, 1),
(2101, '4045', 'alan', 1, '40.00', '58.00', 0, 'img_producto.png', '2024-04-21 23:00:22', 1, 1),
(2102, '8909', 'uva', 1, '90.00', '104.40', 10, 'img_producto.png', '2024-04-24 00:57:57', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `codproveedor` int(11) NOT NULL,
  `proveedor` varchar(100) DEFAULT NULL,
  `contacto` varchar(100) DEFAULT NULL,
  `telefono` bigint(11) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `date_add` datetime NOT NULL DEFAULT current_timestamp(),
  `status` int(11) DEFAULT 1,
  `usuario_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`codproveedor`, `proveedor`, `contacto`, `telefono`, `direccion`, `date_add`, `status`, `usuario_id`) VALUES
(1, 'Mercado', 'Mercado', 99999999, 'Managua', '2021-09-21 15:52:42', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `idrol` int(11) NOT NULL,
  `rol` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`idrol`, `rol`) VALUES
(1, 'Administrador'),
(2, 'Supervisor'),
(3, 'Vendedor');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `idusuario` int(11) NOT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `usuario` varchar(15) DEFAULT NULL,
  `clave` varchar(100) DEFAULT NULL,
  `rol` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`idusuario`, `nombre`, `correo`, `usuario`, `clave`, `rol`, `status`) VALUES
(1, 'Admin', 'admin@gmail.com', 'admin', '21232f297a57a5a743894a0e4a801fc3', 1, 1),
(39, 'Deysi Jazmin', 'deysi@gmail.com', 'Supervisor', '18eba6bb36aa9078c38ff2fe5a9f0d0d', 2, 1),
(40, 'Soemi del Carmen', 'soemi@gmail.com', 'Administrador', '2a2e9a58102784ca18e2605a4e727b5f', 1, 1),
(41, 'Jannifer Shiomara', 'informatica@gmail.com', 'Vendedor', '3236b3179c1e0fd4171722e9c8170009', 3, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `noventa` bigint(11) NOT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario` int(11) DEFAULT NULL,
  `caja` int(11) NOT NULL,
  `codcliente` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `totalventa` decimal(10,2) NOT NULL,
  `descuento` decimal(10,2) NOT NULL,
  `abono` decimal(10,2) NOT NULL,
  `efectivo` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Volcado de datos para la tabla `venta`
--

INSERT INTO `venta` (`noventa`, `fecha`, `usuario`, `caja`, `codcliente`, `status`, `totalventa`, `descuento`, `abono`, `efectivo`) VALUES
(1589, '2024-04-23 22:43:36', 1, 173, 1, 1, '9.28', '1.48', '490.72', 500),
(1590, '2024-04-24 01:17:57', 1, 173, 1, 1, '9.28', '1.48', '990.72', 1000),
(1591, '2024-04-24 01:18:58', 1, 173, 1, 1, '937.28', '149.96', '62.72', 1000);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `caja`
--
ALTER TABLE `caja`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario` (`usuario`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idcliente`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`nocompra`),
  ADD KEY `usuario` (`usuario`),
  ADD KEY `codproveedor` (`codproveedor`),
  ADD KEY `caja` (`caja`);

--
-- Indices de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD PRIMARY KEY (`correlativo`),
  ADD KEY `codproducto` (`codproducto`),
  ADD KEY `noventa` (`noventa`);

--
-- Indices de la tabla `detalle_recibo`
--
ALTER TABLE `detalle_recibo`
  ADD PRIMARY KEY (`id`),
  ADD KEY `noventa` (`noventa`),
  ADD KEY `usuario` (`usuario`),
  ADD KEY `caja` (`caja`);

--
-- Indices de la tabla `detalle_recibo_compra`
--
ALTER TABLE `detalle_recibo_compra`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nocompra` (`nocompra`),
  ADD KEY `usuario` (`usuario`),
  ADD KEY `caja` (`caja`);

--
-- Indices de la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  ADD PRIMARY KEY (`correlativo`),
  ADD KEY `codproducto` (`codproducto`),
  ADD KEY `token_user` (`token_user`);

--
-- Indices de la tabla `detalle_temp_compra`
--
ALTER TABLE `detalle_temp_compra`
  ADD PRIMARY KEY (`correlativo`),
  ADD KEY `token_user` (`token_user`),
  ADD KEY `codproducto` (`codproducto`);

--
-- Indices de la tabla `egresos`
--
ALTER TABLE `egresos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `caja` (`caja`);

--
-- Indices de la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD PRIMARY KEY (`correlativo`),
  ADD KEY `codproducto` (`codproducto`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `nocompra` (`nocompra`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`codproducto`),
  ADD KEY `proveedor` (`proveedor`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`codproveedor`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`idrol`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`idusuario`),
  ADD KEY `rol` (`rol`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`noventa`),
  ADD KEY `usuario` (`usuario`),
  ADD KEY `codcliente` (`codcliente`),
  ADD KEY `caja` (`caja`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `caja`
--
ALTER TABLE `caja`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=174;

--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idcliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=75;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `nocompra` bigint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=206;

--
-- AUTO_INCREMENT de la tabla `configuracion`
--
ALTER TABLE `configuracion`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  MODIFY `correlativo` bigint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1973;

--
-- AUTO_INCREMENT de la tabla `detalle_recibo`
--
ALTER TABLE `detalle_recibo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=74;

--
-- AUTO_INCREMENT de la tabla `detalle_recibo_compra`
--
ALTER TABLE `detalle_recibo_compra`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2453;

--
-- AUTO_INCREMENT de la tabla `detalle_temp_compra`
--
ALTER TABLE `detalle_temp_compra`
  MODIFY `correlativo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=211;

--
-- AUTO_INCREMENT de la tabla `egresos`
--
ALTER TABLE `egresos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT de la tabla `entradas`
--
ALTER TABLE `entradas`
  MODIFY `correlativo` bigint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=946;

--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `codproducto` int(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2103;

--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `codproveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `idrol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `idusuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `noventa` bigint(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1592;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `caja`
--
ALTER TABLE `caja`
  ADD CONSTRAINT `caja_ibfk_1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `cliente_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`codproveedor`) REFERENCES `proveedor` (`codproveedor`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `compras_ibfk_2` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `compras_ibfk_3` FOREIGN KEY (`caja`) REFERENCES `caja` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD CONSTRAINT `detalleventa_ibfk_1` FOREIGN KEY (`noventa`) REFERENCES `venta` (`noventa`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalleventa_ibfk_2` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle_recibo`
--
ALTER TABLE `detalle_recibo`
  ADD CONSTRAINT `detalle_recibo_ibfk_1` FOREIGN KEY (`noventa`) REFERENCES `venta` (`noventa`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_recibo_ibfk_2` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_recibo_ibfk_3` FOREIGN KEY (`caja`) REFERENCES `caja` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle_recibo_compra`
--
ALTER TABLE `detalle_recibo_compra`
  ADD CONSTRAINT `detalle_recibo_compra_ibfk_1` FOREIGN KEY (`nocompra`) REFERENCES `compras` (`nocompra`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_recibo_compra_ibfk_2` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `detalle_recibo_compra_ibfk_3` FOREIGN KEY (`caja`) REFERENCES `caja` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `detalle_temp`
--
ALTER TABLE `detalle_temp`
  ADD CONSTRAINT `detalle_temp_ibfk_1` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `egresos`
--
ALTER TABLE `egresos`
  ADD CONSTRAINT `egresos_ibfk_1` FOREIGN KEY (`caja`) REFERENCES `caja` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD CONSTRAINT `entradas_ibfk_2` FOREIGN KEY (`codproducto`) REFERENCES `producto` (`codproducto`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `entradas_ibfk_3` FOREIGN KEY (`nocompra`) REFERENCES `compras` (`nocompra`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`proveedor`) REFERENCES `proveedor` (`codproveedor`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `producto_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD CONSTRAINT `proveedor_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`rol`) REFERENCES `rol` (`idrol`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`usuario`) REFERENCES `usuario` (`idusuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `venta_ibfk_2` FOREIGN KEY (`codcliente`) REFERENCES `cliente` (`idcliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `venta_ibfk_3` FOREIGN KEY (`caja`) REFERENCES `caja` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
