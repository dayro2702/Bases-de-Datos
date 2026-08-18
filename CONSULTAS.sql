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


/*11. Anomalías de Despliegue Reciente (Filtros Combinados de Fechas y Valores)*/
SELECT s.id_instancia,
s.fecha_despliegue,
f.mes_facturacion,
f.costo_total
FROM servidores_instancias s
INNER JOIN facturacion_mensual f
ON s.id_instancia = f.id_instancia
WHERE YEAR(s.fecha_despliegue) = 2026
AND f.costo_total > 1000
ORDER BY f.costo_total DESC;

/*12. Densidad de Recursos por Sistema Operativo (Exclusión mediante JOIN)*/
SELECT s.sistema_operativo,
COUNT(s.id_instancia) AS total_instancias,
SUM(s.vcpus) AS total_vcpus,
SUM(s.memoria_gb) AS total_memoria_RAM
FROM servidores_instancias s
WHERE s.estado = "Activo"
AND s.id_proveedor IS NOT NULL
GROUP BY s.sistema_operativo 
ORDER BY total_memoria_RAM DESC;


/*13. Consistencia de Facturación (HAVING Avanzado)*/
SELECT s.id_instancia,
p.nombre_proveedor,
COUNT(f.mes_facturacion) AS meses_facturados,
ROUND(AVG(f.costo_total), 2) AS promedio_mesual
FROM servidores_instancias s
LEFT JOIN  facturacion_mensual f 
ON s.id_instancia = f.id_instancia
INNER JOIN proveedores_nube p
ON s.id_proveedor = p.id_proveedor
GROUP BY s.id_instancia,
p.nombre_proveedor
HAVING COUNT(f.mes_facturacion) >= 3
AND AVG(f.costo_total) > 500
ORDER BY promedio_mesual DESC;

/*=================================================================================================
SUBQUERYS
=================================================================================================*/

/*Reto 1: Optimización de Hardware (Subconsulta Escalar)*/
SELECT s.id_instancia,
s.sistema_operativo,
s.memoria_gb
FROM servidores_instancias s 
WHERE memoria_gb > (
    SELECT AVG(memoria_gb) 
    FROM servidores_instancias
)
ORDER BY memoria_gb DESC;

/*Reto 2: Proveedores con Alta Disponibilidad (Subconsulta de Lista)*/
SELECT p.nombre_proveedor,
p.region_principal
FROM proveedores_nube P
WHERE p.id_proveedor IN (  
    SELECT s.id_proveedor
    FROM facturacion_mensual f
    INNER JOIN servidores_instancias s
    ON s.id_instancia = f.id_instancia
    WHERE f.horas_uso > 720
);

/*Reto 3: El Top 3 de Facturación Histórica (Tabla Derivada en el FROM)*/
SELECT id_instancia,
costo_total_historico
FROM (
    SELECT f.id_instancia,
    SUM(f.costo_total) AS costo_total_historico
    FROM facturacion_mensual f
    GROUP BY f.id_instancia
) AS resumen_servidores
ORDER BY costo_total_historico DESC
LIMIT 3;

/*=================================================================================================
ACTIVIDAD 13 AGOST
=================================================================================================*/
SELECT
    f.id_instancia,
    f.mes_facturacion,
    f.costo_total
FROM facturacion_mensual f 
INNER JOIN servidores_instancias s
    ON f.id_instancia = s.id_instancia
WHERE f.costo_total > (
    SELECT AVG(costo_total) AS costo_total
    FROM facturacion_mensual f2
    INNER JOIN servidores_instancias s2
        ON f2.id_instancia = s2.id_instancia
    WHERE s.id_proveedor = s2.id_proveedor
)
ORDER BY f.costo_total DESC;

/*=================================================================================================
EJERCICIOS EXPOCICION VISTAS Y VISTAS MATERIALIZADAS
=================================================================================================*/
/*EJERCICIO 1*/
CREATE VIEW v_servidores_activos AS
SELECT 
    id_instancia, 
    sistema_operativo, 
    vcpus, 
    memoria_gb, 
    fecha_despliegue
FROM servidores_instancias
WHERE estado = 'Activo';

-- Consulta de uso:
SELECT * FROM v_servidores_activos;

/*EJERCICIO 2*/
CREATE VIEW v_detalle_servidor_proveedor AS
SELECT 
    s.id_instancia,
    s.sistema_operativo,
    s.estado,
    p.nombre_proveedor,
    p.region_principal,
    p.correo_soporte
FROM servidores_instancias s
INNER JOIN proveedores_nube p ON s.id_proveedor = p.id_proveedor;

-- Consulta de uso:
SELECT * FROM v_detalle_servidor_proveedor WHERE region_principal = 'us-west-2';


/*VISTAS MATERIALIZADAS*/
/*EJERCICIO 1*/
CREATE MATERIALIZED VIEW mv_resumen_costos_instancia AS
SELECT 
    id_instancia,
    COUNT(id_factura) AS total_facturas,
    SUM(horas_uso) AS total_horas_uso,
    SUM(costo_total) AS costo_acumulado_usd
FROM facturacion_mensual
GROUP BY id_instancia;

-- Para actualizar los datos cuando entren nuevas facturas:
REFRESH MATERIALIZED VIEW mv_resumen_costos_instancia;

/*EJERCICIO 2*/
CREATE MATERIALIZED VIEW mv_capacidad_por_proveedor AS
SELECT 
    p.nombre_proveedor,
    COUNT(s.id_instancia) AS total_servidores,A
    SUM(s.vcpus) AS total_vcpus,
    SUM(s.memoria_gb) AS total_ram_gb
FROM proveedores_nube p
JOIN servidores_instancias s ON p.id_proveedor = s.id_proveedor
GROUP BY p.nombre_proveedor;

-- Consulta directa al disco (ultra rápida):
SELECT * FROM mv_capacidad_por_proveedor ORDER BY total_ram_gb DESC;