<?php

session_start();
if(empty($_SESSION['active']))
{
    header('location: ../');
}

include "../../conexion.php";
require_once '../pdf/vendor/autoload.php';
use Dompdf\Dompdf;

if(empty($_REQUEST['cl']) || empty($_REQUEST['f']))
{
    echo "No es posible generar la factura.";
} else {
    // Verificar si se ha enviado el formulario de suma
    if(isset($_POST['respuesta'])) {
        $respuesta = $_POST['respuesta'];
		
        
        $codCliente = $_REQUEST['cl'];
        $noFactura = $_REQUEST['f'];
        $anulada = '';

        // Obtener el valor totalventa de la tabla venta
        $query_totalventa = mysqli_query($conection, "SELECT totalventa FROM venta WHERE noventa = $noFactura");
        $totalventa_result = mysqli_fetch_assoc($query_totalventa);
        $totalventa = $totalventa_result['totalventa'];

        // Guardar el valor proporcionado por el usuario en el campo "abono"
        $abono = $respuesta;

        $query_abono = "UPDATE venta SET efectivo = $abono WHERE noventa = $noFactura";
        mysqli_query($conection, $query_abono);
    	

		
		$abono1 = $respuesta - $totalventa;

		

        // Actualizar el campo "abono" y usar el valor totalventa obtenido anteriormente
        $query_abono = "UPDATE venta SET abono = $abono1, totalventa = $totalventa WHERE noventa = $noFactura";
        mysqli_query($conection, $query_abono);
    	


        $query_config   = mysqli_query($conection,"SELECT * FROM configuracion");
        $result_config  = mysqli_num_rows($query_config);
        if($result_config > 0){
            $configuracion = mysqli_fetch_assoc($query_config);

		
		
        }

		

        $query = mysqli_query($conection,"SELECT f.noventa, DATE_FORMAT(f.fecha, '%d/%m/%Y') as fecha, DATE_FORMAT(f.fecha,'%H:%i:%s') as  hora, f.codcliente, f.status,f.descuento,
                                                    v.nombre as vendedor,
                                                    cl.nit, cl.nombre, cl.telefono,cl.direccion
                                            FROM venta f
                                            INNER JOIN usuario v
                                            ON f.usuario = v.idusuario
                                            INNER JOIN cliente cl
                                            ON f.codcliente = cl.idcliente
                                            WHERE f.noventa = $noFactura AND f.codcliente = $codCliente  AND f.status != 10 ");

        $result = mysqli_num_rows($query);
        if($result > 0){

            $factura = mysqli_fetch_assoc($query);
            $no_factura = $factura['noventa'];

            if($factura['status'] == 2){
                $anulada = '<img class="anulada" src="img/anulado.png" alt="Anulada">';
            }

            $query_productos = mysqli_query($conection,"SELECT p.descripcion,dt.cantidad,dt.precio_venta,(dt.cantidad * dt.precio_venta) as precio_total
                                                        FROM venta f
                                                        INNER JOIN detalleventa dt
                                                        ON f.noventa = dt.noventa
                                                        INNER JOIN producto p
                                                        ON dt.codproducto = p.codproducto
                                                        WHERE f.noventa = $no_factura ");
            $result_detalle = mysqli_num_rows($query_productos);

            // Guardar el valor proporcionado por el usuario en el campo "abono"
            //$abono = $respuesta;
            //$query_abono = "UPDATE venta SET abono = $abono WHERE noventa = $no_factura";
            //mysqli_query($conection, $query_abono);

            ob_start();
            include(dirname('__FILE__').'/factura.php');
            $html = ob_get_clean();

            // instantiate and use the dompdf class
            $dompdf = new Dompdf();

            $dompdf->loadHtml($html);
            // (Optional) Setup the paper size and orientation
            $dompdf->setPaper('letter', 'portrait');
            // Render the HTML as PDF
            $dompdf->render();
            // Output the generated PDF to Browser
            $dompdf->stream('factura_'.$noFactura.'.pdf',array('Attachment'=>0));
            exit;

        }
    } else {
        // Mostrar el formulario para la suma
        echo '
			<div style="text-align: center; background-color: #f0f0f0; padding: 20px;">
				<form method="post" action="">
					<label for="respuesta" style="color: #333; font-size: 18px;">Introduce el valor de la denominación con la que se pagará: </label>
					<input type="text" name="respuesta" id="respuesta" style="padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 5px;">
					<br>
					<input type="submit" value="Generar factura" style="background-color: #007bff; color: #fff; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">
				</form>
			</div>
		';

    }
}
?>