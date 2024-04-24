<?php 
	session_start(); 

	// Encabezado para indicar que el contenido será un archivo Excel
	header("Content-Type: application/vnd.ms-excel");
	header("Content-Disposition: attachment; filename=productos_sin_existencia.xls");
?>

<!DOCTYPE html>
<html lang="es">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>Productos sin Existencia</title>
	<style>
		table {
			width: 100%;
			border-collapse: collapse;
			border: 4px solid black; /* Agregamos un borde negro a la tabla */
		}
		th, td {
			padding: 8px;
			text-align: left;
			border-bottom: 1px solid #ddd;
			border-right: 2px solid black; /* Agregamos un borde derecho a las celdas */
		}
		th {
			background-color: #f2f2f2;
			border-top: 2px solid black; /* Agregamos un borde superior más grueso a las celdas de encabezado */
		}
		td {
			border-top: 4px solid black; /* Agregamos un borde superior a las celdas de datos */
		}
	</style>
</head>
<body>
	<table>
		<tr>
			<th>Código</th>
			<th>Descripción</th>
			<th>Existencia</th>
			<th>Costo</th>
			<th>Precio</th>
			<th>Proveedor</th>
		</tr>

		<?php
		include "../conexion.php";

		$query = mysqli_query($conection,"SELECT p.codproducto, p.codigo, p.descripcion,p.costo, p.precio, p.existencia, pr.proveedor, p.status FROM producto p
			INNER JOIN proveedor pr
			ON p.proveedor = pr.codproveedor
			WHERE p.status = 1 AND p.existencia = 0 ORDER BY p.codproducto");

		$result = mysqli_num_rows($query);

		if ($result > 0) {
			while ($data = mysqli_fetch_assoc($query)){
		?>
		<tr>
			<td><?php echo $data['codigo']; ?></td>
			<td><?php echo $data['descripcion'] ; ?></td>
			<td><?php echo $data['existencia'] ; ?></td>
			<td><?php echo $data['costo']; ?></td>
			<td><?php echo $data['precio']; ?></td>
			<td><?php echo $data['proveedor'] ; ?></td>
		</tr>
		<?php 
			}
		} 
		?>
	</table>
</body>
</html>
