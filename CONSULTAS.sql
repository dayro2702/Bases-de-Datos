/*1. Inventario Activo (INNER JOIN)*/
SELECT s.estado,
s.id_instancia, 
s.sIStema_operativo, 
p.nombre_proveedor, 
p.regiON_principal 
FROM servidores_instancias s 
INNER JOIN proveedores_nube p
ON s.id_proveedor = p.id_proveedor 
WHERE s.estado = "Activo" 
LIMIT 15;

/*2. Auditoría de Servidores Locales (LEFT JOIN y Nulos):*/
SELECT s.id_instancia, 
s.fecha_despliegue, 
s.estado 
FROM servidores_instancias s 
LEFT JOIN proveedores_nube p 
ON s.id_proveedor = p.id_proveedor 
WHERE s.id_proveedor IS NULL 
LIMIT 15;


SELECT COUNT(*)
FROM servidores_instancias s 
LEFT JOIN proveedores_nube p 
ON s.id_proveedor = p.id_proveedor 
WHERE s.id_proveedor IS NULL;

/*3. Estandarización de Nomenclaturas (FunciONes de Texto):*/
SELECT p.nombre_proveedor, 
UPPER(LEFT(s.id_instancia, 4)) AS entorno_servidor, 
p.correo_soporte, 
SUBSTRING(p.correo_soporte, 8 + 1) AS dominio_correo 
FROM proveedores_nube p 
INNER JOIN servidores_instancias s 
ON p.id_proveedor = s.id_proveedor 
LIMIT 15;


SELECT p.nombre_proveedor,
UPPER(SUBSTRING(s.id_instancia, 1, 4)) AS entorno,
p.correo_soporte,
SUBSTRING(p.correo_soporte, LOCATE("@", p.correo_soporte)+1, LENGTH(p.correo_soporte)) AS dominio
FROM servidores_instancias s
INNER JOIN proveedores_nube p
ON p.id_proveedor = s.id_proveedor 
LIMIT 15;

/*4. Ciclo de Vida de la Infraestructura (FunciONes de Fecha):*/
SELECT 
s.id_instancia,
s.fecha_despliegue, 
current_date AS fecha_hoy, 
datediff(current_date, s.fecha_despliegue) 
AS dias_encendido, year (s.fecha_despliegue) 
AS anio_lanzamiento 
FROM servidores_instancias s 
WHERE s.estado = "Activo" 
order by s.fecha_despliegue 
ASC LIMIT 10;


/*7.Alerta de Costos Históricos (Uso de HAVING):*/
SELECT 
S.id_instancia,
S.sistema_operativo,
SUM(F.costo_total) AS "Costo Total Historico"
FROM facturacion_mensual F
INNER JOIN servidores_instancias S
ON F.id_instancia = S.id_instancia
GROUP BY S.id_instancia, S.sistema_operativo
HAVING SUM(F.costo_total) >= 5000
ORDER BY SUM(F.costo_total) DESC;


SELECT COUNT(*) AS conteo,
S.id_instancia,
S.sistema_operativo,
SUM(F.costo_total) AS "Costo Total Historico"
FROM facturacion_mensual F
INNER JOIN servidores_instancias S
ON F.id_instancia = S.id_instancia
GROUP BY S.id_instancia, S.sistema_operativo
HAVING SUM(F.costo_total) >= 5000
ORDER BY SUM(F.costo_total) DESC;


/*8.Plan de Remediación de Sistemas (REPLACE y LIKE)*/
SELECT id_instancia,
sistema_operativo,
REPLACE(sistema_operativo, "(Deprecated)", "[ACTUALIZAR URGENTE]") AS Obsoletos
FROM servidores_instancias
WHERE sistema_operativo LIKE "%(Deprecated)%"
LIMIT 15;


/*9.CASE, WHEN*/
SELECT id_instancia,
vcpus,
memoria_gb,
CASE 
    WHEN vcpus <= 4 THEN "Small"
    WHEN vcpus > 4 AND vcpus <= 16 THEN "Medium"
    WHEN vcpus > 16 THEN "Large / Enterprise"
    ELSE "Desconocido"
END AS "tamaño instancia"
FROM servidores_instancias
WHERE estado = "Activo"
LIMIT 15;


/*10.*/
SELECT SUBSTRING_INDEX(P.correo_soporte, "@", -1) AS dominio_proveedor,
DATE_FORMAT(F.mes_facturacion, "%Y-%m")AS periodo,
COUNT(DISTINCT S.id_instancia) AS maquinas_facturadas,
ROUND(AVG(F.tarifa_hora), 4) AS tarifa_promedio,
SUM(F.costo_total) AS costo_mensual_total
FROM facturacion_mensual F
INNER JOIN servidores_instancias S
ON F.id_instancia = S.id_instancia
INNER JOIN proveedores_nube P
ON S.id_proveedor = P.id_proveedor
WHERE S.estado != "Terminado"
GROUP BY dominio_proveedor, DATE_FORMAT(F.mes_facturacion, "%Y-%m")
ORDER BY periodo DESC, costo_mensual_total DESC; 