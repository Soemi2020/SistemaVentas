<?php
	$subtotal 	= 0;
	$iva 	 	= 0;
	$impuesto 	= 0;
	$tl_sniva   = 0;
	$total 		= 0;
 //print_r($configuracion); ?>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<title>Factura</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<?php echo $anulada; ?>
<div id="page_pdf">
	<table id="factura_head">
		<tr>
			<td class="logo_factura">
				<div>
					<img src="img/<?php echo $configuracion['foto']; ?>">
				</div>
			</td>
			<td class="info_empresa">
				<?php
					if($result_config > 0){
						$iva = $configuracion['iva'];
						$moned = $configuracion['moneda'];
				 ?>
				<div>
					<span class="h2"><?php echo strtoupper($configuracion['nombre']); ?></span>
					<p><?php echo $configuracion['razon_social']; ?></p>
					<p><?php echo $configuracion['direccion']; ?></p>
					<p>NIT: <?php echo $configuracion['nit']; ?></p>
					<p>Teléfono: <?php echo $configuracion['telefono']; ?></p>
					<p>Email: <?php echo $configuracion['email']; ?></p>
				</div>
				<?php
					}
				 ?>
			</td>
			<td class="info_factura">
				<div class="round">
					<span class="h3">Factura</span>
					<p>No. Factura: <strong><?php echo $factura['noventa']; ?></strong></p>
					<p>Fecha: <?php echo $factura['fecha']; ?></p>
					<p>Hora: <?php echo $factura['hora']; ?></p>
					<p>Vendedor: <?php echo $factura['vendedor']; ?></p>
				</div>
			</td>
		</tr>
	</table>
	<table id="factura_cliente">
		<tr>
			<td class="info_cliente">
				<div class="round">
					<span class="h3">Cliente</span>
					<table class="datos_cliente">
						<tr>
							<td><label>Nit:</label><p><?php echo $factura['nit']; ?></p></td>
							<td><label>Teléfono:</label> <p><?php echo $factura['telefono']; ?></p></td>
						</tr>
						<tr>
							<td><label>Cliente:</label> <p><?php echo $factura['nombre']; ?></p></td>
							<td><label>Dirección:</label> <p><?php echo $factura['direccion']; ?></p></td>
						</tr>
					</table>
				</div>
			</td>

		</tr>
	</table>

	<table id="factura_detalle">
			<thead>
				<tr>
					<th width="50px">Cant.</th>
					<th class="textleft">Descripción</th>
					<th class="" width="150px">Precio Unitario.</th>
					<th class="" width="150px"> Precio Total</th>
				</tr>
			</thead>
			<tbody id="detalle_productos">

			<?php

				if($result_detalle > 0){

					while ($row = mysqli_fetch_assoc($query_productos)){
						$precio_venta = number_format($row['precio_venta'],2);
						$precio_total = number_format($row['precio_total'],2);

			 ?>
				<tr>
					<td class="textcenter"><?php echo $row['cantidad']; ?></td>
					<td><?php echo $row['descripcion']; ?></td>
					<td class=""><?php echo $moned.' '.$precio_venta; ?></td>
					<td class=""><?php echo $moned.' '.$precio_total; ?></td>
				</tr>
			<?php
						$precio_total = $row['precio_total'];
						$subtotal = round($subtotal + $precio_total, 2);
					}
				}

				$impuesto 	= round($subtotal * ($iva / 100), 2);
				$tl_sniva 	= round($subtotal - $impuesto,2 );
				$total 		= $tl_sniva + $impuesto;
				$tl_sniva1 = number_format($subtotal - $impuesto,2);
				$impuesto1 = number_format($subtotal * ($iva / 100), 2);
				$desc = $factura['descuento'];
			?>
			</tbody>
			<tfoot id="detalle_totales">
				<tr>
					<td colspan="3" class="textright"><span>Subtotal &nbsp;&nbsp;&nbsp; </span></td>
					<td class=""><span> <?php echo number_format($total,2) . ' ' . $moned; ?></span></td>
				</tr>
				<tr>
					<td colspan="3" class="textright"><span>IVA incluido 16%&nbsp;&nbsp;&nbsp; </span></td>
					<td class=""><span> <?php echo number_format($desc,2) . ' ' . $moned; ?></span></td>
				</tr>
				<tr>
					<td colspan="3" class="textright"><span>Total &nbsp;&nbsp;&nbsp; </span></td>
					<td class=""><span> <?php echo number_format($total,2) . ' ' . $moned; ?></span></td>
				</tr>
				<?php 
					
					// Establecer conexión a la base de datos (suponiendo que $conection ya está definido)
					
					// Consulta SQL para obtener el valor de abono de la tabla venta
					$query_cambio = mysqli_query($conection, "SELECT abono FROM venta WHERE noventa = $noFactura");
					
					// Verificar si se recuperaron resultados de la consulta
					$result_cambio = mysqli_num_rows($query_cambio);
					if ($result_cambio > 0) {                  
						// Si hay resultados, obtener los datos y asignarlos a la variable $moned
						$data_cambio = mysqli_fetch_assoc($query_cambio);
						$cambio_dato = $data_cambio['abono'];
					} else {
						// Manejar el caso en el que no se recuperen resultados (opcional)
						$cambio_dato = "0"; // o asignar un valor predeterminado
						// También podrías mostrar un mensaje de error o realizar otra acción apropiada
					}
				?>

				<tr>
					<td colspan="3" class="textright"><span>Efectivo &nbsp;&nbsp;&nbsp; </span></td>
					<td class=""><span><?php echo number_format($respuesta, 2) . ' ' . $moned; ?></span></td>
					
				</tr>



				<tr>
					<td colspan="3" class="textright"><span>Cambio efectivo &nbsp;&nbsp;&nbsp; </span></td>
					<td class=""><span><?php echo number_format($cambio_dato, 2) . ' ' . $moned; ?></span></td>
				</tr>

				

				

				

	</table>
	<div>
		<!--<p class="nota">Si usted tiene preguntas sobre esta factura, <br>pongase en contacto con nombre, teléfono y Email</p>-->
		<h4 class="label_gracias">¡Gracias por su compra!</h4>
		<p class="label_gracias">Revise su producto, antes de salir de tienda.</p>
	</div>
</div>
</body>
</html>