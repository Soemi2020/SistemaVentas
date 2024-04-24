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
	<title>Venta</title>
    <link rel="stylesheet" href="styleticket.css">
</head>
<body>
<?php echo $anulada; ?>
<div id="page_pdf">
	<br>
	<br>
	<table id="factura_head">
		<tr>
			<td class="logo_factura">
				<div>
					<img src="img/<?php echo $configuracion['foto']; ?>">
				</div>
			</td>
		</tr>
		<tr>
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
					<p>RUC: <?php echo $configuracion['nit'].' &nbsp;&nbsp;Cel: '.$configuracion['telefono']; ?></p>					
				</div>
				<?php
				if ($venta['status'] == 1) {
					$tipo_pago = 'Contado';
				}elseif($venta['status'] == 3){
					$tipo_pago = 'Crédito';
				}else{
					$tipo_pago = 'Anulado';
				}
					}
	
						if ($tipo_pago == 'Crédito') {
							date_default_timezone_set("America/Managua");
							$fecha = date('d-m-Y',strtotime($venta["fecha"]));
							$fecha_a_vencer = date('d-m-Y',strtotime($fecha. '+ 30 days'));
							$vence = '<p>&nbsp;&nbsp;Vencimiento: '.$fecha_a_vencer.'</p>';
						}else{
							$vence = '';
						}
					
				 ?>
			</td>
			</tr>
			<tr>
			<td class="">

				<div class="round">
					<p>&nbsp;&nbsp;Tipo de venta: <?php echo $tipo_pago; ?></p>
					<strong>&nbsp;&nbsp;No. Venta: <?php echo str_pad($venta['noventa'],11,'0', STR_PAD_LEFT); ?>&nbsp;&nbsp;&nbsp;&nbsp;Fecha: <?php echo $venta['fechaF']; ?></strong>
					<p>&nbsp;&nbsp;Hora: <?php echo $venta['horaF']; ?></p>	
					<p>&nbsp;&nbsp;Vendedor: <?php echo $venta['vendedor'];?></p>
					
					<?php echo $vence;?>

				</div>
			</td>
		</tr>
	</table>
	<table id="factura_detalle">
			<thead>
				<tr>
					<th colspan="3" class="textleft"> ------------------------------------------------------------------ Descripción</th>
				</tr>
				<tr><th width="">Código</th>
					<th width="">Cantidad</th>
					<th class="" width="">Precio</th>
					<th class="" width="">Total</th>
				</tr>
				<tr>
					<th colspan="3" class="textleft"> ------------------------------------------------------------------ </th>
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
					<td colspan="3"width=""><?php echo $row['descripcion']; ?></td>
				</tr>
				<tr>
					<td width=""><?php echo $row['codigo']; ?></td>
					<td width=""><?php echo $row['cantidad']; ?></td>
					<td width=""><?php echo $precio_venta; ?></td>
					<td class=""><?php echo $precio_total; ?></td>
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
				$descuento = number_format($venta['descuento'],2);
			?>
			</tbody>
			<tfoot id="detalle_totales">
				<tr>
					<td colspan="3"><p>---------------------------------------------------------</p></td>
				</tr>
				<tr>
					<td></td>
					<td></td>
					<td colspan="" class=""><span>Sub total </span></td>					
					<td class=""><span> <?php echo number_format($total,2) . ' ' . $moned; ?></span></td>
				</tr>
				
				<tr>
					<td></td>
					<td></td>
					<td colspan="" class=""><span>IVA 16%</span></td>
					<td class=""><span><?php echo $descuento.' '.$moned; ?></span></td>
				</tr>

				<tr>
					<td></td>
					<td></td>
					<td colspan="" class=""><span>Total </span></td>					
					<td class=""><span> <?php echo number_format($total,2) . ' ' . $moned; ?></span></td>
				</tr>
				<?php 
					
					// Establecer conexión a la base de datos (suponiendo que $conection ya está definido)
					
					// Consulta SQL para obtener el valor de abono de la tabla venta
					$query_cambio = mysqli_query($conection, "SELECT abono FROM venta WHERE noventa = $noVenta");
					
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
					<td></td>
					<td></td>
					<td colspan="" class=""><span>Efectivo </span></td>					
					<td class=""><span> <?php echo number_format($respuesta,2) . ' ' . $moned; ?></span></td>
				</tr>


				<tr>
					<td></td>
					<td></td>
					<td colspan="" class=""><span>Cambio</span></td>                    
					<td class=""><span><?php echo number_format($cambio_dato, 2) . ' ' . $moned; ?></span></td>
				</tr>

		</tfoot>
	</table>
	<br>
	<br>
	<br>
	<div>
		<!--<p class="nota">Si usted tiene preguntas sobre esta factura, <br>pongase en contacto con nombre, teléfono y Email</p>-->
		<h4 class="label_gracias" style="font-size: 8px;">Los precios de los productos incluyen IVA</h4>

		<h4 class="label_gracias">¡Gracias por su compra!</h4>
		<p class="label_gracias">Revise su producto, antes de salir de tienda.</p>
	</div>

</div>

</body>
</html>