<?php

	//print_r($_REQUEST);
	//exit;
	//echo base64_encode('2');
	//exit;
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
		echo "No es posible generar la venta.";
	}else{

		if(isset($_POST['respuesta'])) {

		
		$respuesta = $_POST['respuesta'];
		$codCliente = $_REQUEST['cl'];
		$noVenta = $_REQUEST['f'];
		$anulada = '';


		
		$query_totalventa = mysqli_query($conection, "SELECT totalventa FROM venta WHERE noventa = $noVenta");

        $totalventa_result = mysqli_fetch_assoc($query_totalventa);
        $totalventa = $totalventa_result['totalventa'];

        // Guardar el valor proporcionado por el usuario en el campo "abono"
        $abono = $respuesta;
		
		$abono1 = $respuesta - $totalventa;

        // Actualizar el campo "abono" y usar el valor totalventa obtenido anteriormente
        $query_abono = "UPDATE venta SET abono = $abono1, totalventa = $totalventa WHERE noventa = $noVenta";
        mysqli_query($conection, $query_abono);

		$query_config   = mysqli_query($conection,"SELECT * FROM configuracion");
		$result_config  = mysqli_num_rows($query_config);
		if($result_config > 0){
			$configuracion = mysqli_fetch_assoc($query_config);
		}


		$query = mysqli_query($conection,"SELECT f.noventa, DATE_FORMAT(f.fecha, '%d/%m/%Y') as fechaF, DATE_FORMAT(f.fecha,'%H:%i:%s') as  horaF, f.codcliente, f.status,f.fecha,f.descuento,
												 v.nombre as vendedor,
												 cl.nit, cl.nombre, cl.telefono,cl.direccion
											FROM venta f
											INNER JOIN usuario v
											ON f.usuario = v.idusuario
											INNER JOIN cliente cl
											ON f.codcliente = cl.idcliente
											WHERE f.noventa = $noVenta AND f.codcliente = $codCliente  AND f.status != 10 ");

		$result = mysqli_num_rows($query);
		if($result > 0){

			$venta = mysqli_fetch_assoc($query);
			$no_venta = $venta['noventa'];

			if($venta['status'] == 2){
				$anulada = '<img class="anulada" src="img/anulado.png" alt="Anulada">';
			}

			$query_productos = mysqli_query($conection,"SELECT p.descripcion,dt.cantidad,dt.precio_venta,(dt.cantidad * dt.precio_venta) as precio_total,p.codigo
														FROM venta f
														INNER JOIN detalleventa dt
														ON f.noventa = dt.noventa
														INNER JOIN producto p
														ON dt.codproducto = p.codproducto
														WHERE f.noventa = $no_venta ");
			$result_detalle = mysqli_num_rows($query_productos);

			ob_start();
		    include(dirname('__FILE__').'/ticket.php');
		    $html = ob_get_clean();

			// instantiate and use the dompdf class
			$dompdf = new Dompdf();

			$dompdf->loadHtml($html);
			// (Optional) Setup the paper size and orientation
			$paper_size = array(0,0,204,1000);
			$dompdf->setPaper($paper_size);
			// Render the HTML as PDF
			$dompdf->render();
			// Output the generated PDF to Browser
			$dompdf->stream('venta_'.$noVenta.'.pdf',array('Attachment'=>0));
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
					<input type="submit" value="Generar ticket" style="background-color: #007bff; color: #fff; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">
				</form>
			</div>
		';

    }
}
?>

