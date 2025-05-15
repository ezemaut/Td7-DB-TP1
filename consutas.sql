
--Consultas de Deudas y Facturación

-- Muestra la deuda total por cliente incluyendo todos sus datos personales
-- Útil para cobranzas y atención al cliente, permite saber cuánto debe cada titular y cómo contactarlo.
SELECT 
    t.Nombre,
    t.Apellido,
    t.Celular,
    SUM(f.importe_total) AS deuda_total
FROM Factura f
JOIN Titular t ON f.DNI = t.DNI
WHERE f.pagado = FALSE
GROUP BY 
    t.DNI
ORDER BY deuda_total DESC;

-- Muestra todas las facturas impagas, ordenadas por fecha de vencimiento más cercana
-- Permite priorizar la gestión de cobros, mostrando facturas que están por vencer o vencidas.
SELECT 
    f.fecha_emision,
    f.fecha_vencimiento,
    f.importe_total,
    t.Nombre,
    t.Apellido,
    t.Celular
FROM Factura f
JOIN Titular t ON f.DNI = t.DNI
WHERE f.pagado = FALSE
ORDER BY f.fecha_vencimiento ASC;

-- Muestra el total gastado en el último año por cada titular
-- Clave para evaluar ascensos de categoría y analizar comportamiento de consumo anual.
SELECT ti.nombre, ti.apellido, ti.celular, SUM(lf.monto) AS total_anual
FROM Titular ti
JOIN Tarjeta t ON ti.DNI = t.DNI
JOIN Linea_Factura lf ON t.ID_tarjeta = lf.id_tarjeta
JOIN Factura f ON lf.nro_factura = f.Nro_factura
WHERE f.fecha_emision BETWEEN DATE_TRUNC('year', CURRENT_DATE) AND CURRENT_DATE
GROUP BY ti.DNI, ti.nombre, ti.apellido, ti.celular;

-- Facturación total por cada tipo de entretenimiento (parques y eventos)
-- Permite identificar los entretenimientos más rentables para enfocar recursos y marketing.
SELECT et.nombre, SUM(lf.monto) AS total_facturado
FROM Linea_Factura lf
JOIN Entretenimiento et ON lf.id_entretenimiento = et.id_entretenimiento
GROUP BY et.nombre
ORDER BY total_facturado DESC;


-- Consultas de Promociones
-- Muestra promociones historicas para entretenimientos de categorías hasta Gold (inclusive)
-- Ayuda a personalizar y mostrar promociones vigentes aplicables según categoría de usuario.
SELECT 
    p.fecha_inicio, 
    p.fecha_fin, 
    p.descuento,
    e.nombre AS nombre_entretenimiento,
    cp.nombre_cat
FROM cat_promo cp
JOIN Categoria c ON cp.nombre_cat = c.nombre_cat
JOIN Ranking r ON c.id_ranking = r.id_ranking
JOIN Promocion p ON cp.ID_promocion = p.ID_promocion
JOIN Promo_Entret pe ON p.ID_promocion = pe.ID_promocion
JOIN Entretenimiento e ON pe.id_entretenimiento = e.ID_entretenimiento
WHERE r.peso_imp <= (
    SELECT r2.peso_imp
    FROM Categoria c2
    JOIN Ranking r2 ON c2.id_ranking = r2.id_ranking
    WHERE c2.nombre_cat = 'Gold'
)
ORDER BY p.descuento DESC;

-- Muestra promociones historicas para atracciones de categorías hasta Silver (inclusive)
SELECT 
    p.fecha_inicio, 
    p.fecha_fin, 
    p.descuento,
    a.nombre_atraccion AS nombre_atraccion,
    cp.nombre_cat
FROM cat_promo cp
JOIN Categoria c ON cp.nombre_cat = c.nombre_cat
JOIN Ranking r ON c.id_ranking = r.id_ranking
JOIN Promocion p ON cp.ID_promocion = p.ID_promocion
JOIN Promocion_Atraccion pa ON p.ID_promocion = pa.ID_promocion
JOIN Atraccion a ON pa.id_atraccion = a.id_atraccion
WHERE r.peso_imp <= (
    SELECT r2.peso_imp
    FROM Categoria c2
    JOIN Ranking r2 ON c2.id_ranking = r2.id_ranking
    WHERE c2.nombre_cat = 'Silver'
)

ORDER BY p.descuento DESC;

-- Muestra promociones futuras para entretenimientos, para categorías hasta Gold
-- Útil para anticipar y planificar campañas promocionales.
SELECT 
    p.fecha_inicio, 
    p.fecha_fin, 
    p.descuento,
    e.nombre AS nombre_entretenimiento,
    cp.nombre_cat
FROM cat_promo cp
JOIN Categoria c ON cp.nombre_cat = c.nombre_cat
JOIN Ranking r ON c.id_ranking = r.id_ranking
JOIN Promocion p ON cp.ID_promocion = p.ID_promocion
JOIN Promo_Entret pe ON p.ID_promocion = pe.ID_promocion
JOIN Entretenimiento e ON pe.id_entretenimiento = e.id_entretenimiento
WHERE r.peso_imp <= (
    SELECT r2.peso_imp
    FROM Categoria c2
    JOIN Ranking r2 ON c2.id_ranking = r2.id_ranking
    WHERE c2.nombre_cat = 'Gold'
)
AND CURRENT_DATE <= p.fecha_inicio 
ORDER BY p.descuento DESC;

-- Muestra promociones futuras para atracciones, para categorías hasta Gold
SELECT 
    p.fecha_inicio, 
    p.fecha_fin, 
    p.descuento,
    a.nombre_atraccion AS nombre_atraccion,
    cp.nombre_cat
FROM cat_promo cp
JOIN Categoria c ON cp.nombre_cat = c.nombre_cat
JOIN Ranking r ON c.id_ranking = r.id_ranking
JOIN Promocion p ON cp.ID_promocion = p.ID_promocion
JOIN Promocion_Atraccion pa ON p.ID_promocion = pa.ID_promocion
JOIN Atraccion a ON pa.id_atraccion = a.id_atraccion
WHERE r.peso_imp <= (
    SELECT r2.peso_imp
    FROM Categoria c2
    JOIN Ranking r2 ON c2.id_ranking = r2.id_ranking
    WHERE c2.nombre_cat = 'Gold'
)
AND CURRENT_DATE <= p.fecha_inicio 
ORDER BY p.descuento DESC;

-- Muestra todas las promociones historicas disponibles para una categoría específica hasta Gold
-- Permite informar promociones que aplican a usuarios según su categoría.
SELECT p.fecha_inicio, p.fecha_fin, p.descuento, c.nombre_cat
FROM cat_promo cp
JOIN Promocion p ON cp.ID_promocion = p.ID_promocion
JOIN Categoria c ON cp.nombre_cat = c.nombre_cat
JOIN Ranking r ON c.id_ranking = r.id_ranking
WHERE r.peso_imp <= (
    SELECT r2.peso_imp
    FROM Categoria c2
    JOIN Ranking r2 ON c2.id_ranking = r2.id_ranking
    WHERE c2.nombre_cat = 'Gold'
);






-- Consultas de Titulares y Categorías

-- Muestra cuánto gastó cada categoría en el año actual
-- Permite analizar la facturación total agrupada por categoría de tarjeta.
WITH CategoriaVigente AS (
    SELECT
        hc.ID_tarjeta,
        hc.nombre_cat,
        ROW_NUMBER() OVER (PARTITION BY hc.ID_tarjeta ORDER BY hc.fecha_de_inicio DESC) AS rn
    FROM HistorialCategoria hc
    WHERE hc.fecha_de_inicio <= CURRENT_DATE
)
SELECT
    cv.nombre_cat,
    SUM(lf.monto) AS total_gastado_anio
FROM CategoriaVigente cv
JOIN Linea_Factura lf ON cv.ID_tarjeta = lf.id_tarjeta
JOIN Factura f ON lf.nro_factura = f.Nro_factura
WHERE cv.rn = 1
  AND f.fecha_emision BETWEEN DATE_TRUNC('year', CURRENT_DATE) AND CURRENT_DATE
GROUP BY cv.nombre_cat
ORDER BY total_gastado_anio DESC;

-- Lista los parques y eventos usados por un titular específico
-- Útil para análisis de preferencias y generar recomendaciones personalizadas.
SELECT et.nombre AS entretenimiento
FROM Linea_Factura lf
JOIN Tarjeta t ON lf.id_tarjeta = t.ID_tarjeta
JOIN Entretenimiento et ON lf.id_entretenimiento = et.id_entretenimiento
WHERE t.DNI = 43866294;

-- Lista las atracciones usadas por un titular específico
-- Permite analizar preferencias en atracciones para promociones o historial del cliente.
SELECT 
    a.nombre_atraccion AS atraccion,
    pe.nombre AS nombre_parque
FROM Linea_Factura lf
JOIN Tarjeta t ON lf.id_tarjeta = t.ID_tarjeta
JOIN Atraccion a ON lf.id_atraccion = a.id_atraccion
JOIN Parque_de_Diversiones pd ON a.id_parque = pd.id_entretenimiento
JOIN Entretenimiento pe ON pd.id_entretenimiento = pe.id_entretenimiento
WHERE t.DNI = 43866294;





-- Consulta que muestra todos los entretenimientos y atracciones accesibles para una categoría determinada (y todas las inferiores)
-- Ayuda a saber qué contenido y servicios puede usar el titular según su categoría.
WITH CategoriaSeleccionada AS (
    SELECT r.peso_imp
    FROM Categoria c
    JOIN Ranking r ON c.id_ranking = r.id_ranking
    WHERE c.nombre_cat = 'Gold'
),

CategoriasAccesibles AS (
    SELECT c.nombre_cat
    FROM Categoria c
    JOIN Ranking r ON c.id_ranking = r.id_ranking
    WHERE r.peso_imp <= (SELECT peso_imp FROM CategoriaSeleccionada)
)

SELECT
    e.nombre AS nombre_entretenimiento,
    NULL AS nombre_atraccion,
    e.tipo,
    e.min_categoria
FROM Entretenimiento e
WHERE e.min_categoria IN (SELECT nombre_cat FROM CategoriasAccesibles)

UNION

SELECT
    e.nombre AS nombre_entretenimiento,
    a.nombre_atraccion,
    'Atracción' AS tipo,
    a.min_categoria
FROM Atraccion a
JOIN Parque_de_Diversiones pd ON a.id_parque = pd.id_entretenimiento
JOIN Entretenimiento e ON pd.id_entretenimiento = e.id_entretenimiento
WHERE a.min_categoria IN (SELECT nombre_cat FROM CategoriasAccesibles);

-- Muestra los titulares con su categoría actual
-- Importante para conocer la categoría vigente de cada titular y fecha de asignación.
SELECT
    t.Nombre,
    t.Apellido,
    hc.nombre_cat AS categoria_actual,
    hc.fecha_de_inicio AS fecha_categoria_actual
FROM Titular t
JOIN Tarjeta tar ON t.DNI = tar.DNI
    AND tar.estado = TRUE                      -- Solo tarjetas activas
JOIN HistorialCategoria hc ON tar.ID_tarjeta = hc.ID_tarjeta
WHERE hc.fecha_de_inicio = (
    SELECT MAX(fecha_de_inicio)
    FROM HistorialCategoria hc2
    WHERE hc2.ID_tarjeta = hc.ID_tarjeta
)
ORDER BY t.Apellido, t.Nombre;





-- Consultas sobre Entretenimiento y Atracciones

-- Lista los eventos ordenados por fecha de inicio
SELECT et.nombre, e.fecha_inicio, e.fecha_fin, em.razon_social
FROM Evento e
JOIN Entretenimiento et ON e.id_entretenimiento = et.id_entretenimiento
JOIN Empresa em ON e.cuit = em.cuit
WHERE e.fecha_inicio >= CURRENT_DATE
ORDER BY e.fecha_inicio;

-- Importante para ofrecer a los usuarios información actualizada sobre eventos disponibles,
-- y para preparar campañas promocionales específicas.



-- Lista las atracciones y su parque con el número de promociones activas
-- Ayuda a identificar qué atracciones tienen mayor apoyo promocional.
SELECT 
    a.nombre_atraccion,
    e.nombre AS parque,
    COUNT(pa.ID_promocion) AS promociones_activas
FROM Atraccion a
JOIN Parque_de_Diversiones pd ON a.id_parque = pd.id_entretenimiento
JOIN Entretenimiento e ON pd.id_entretenimiento = e.id_entretenimiento
LEFT JOIN Promocion_Atraccion pa ON a.id_atraccion = pa.id_atraccion
LEFT JOIN Promocion p ON pa.ID_promocion = p.ID_promocion AND CURRENT_DATE BETWEEN p.fecha_inicio AND p.fecha_fin
GROUP BY a.nombre_atraccion, e.nombre;

-- Muestra entretimientos que tengan promociones activas hoy
SELECT DISTINCT e.nombre
FROM Entretenimiento e
JOIN Promo_Entret pe ON e.id_entretenimiento = pe.id_entretenimiento
JOIN Promocion p ON pe.ID_promocion = p.ID_promocion
WHERE CURRENT_DATE BETWEEN p.fecha_inicio AND p.fecha_fin;

-- Muestra las atracciones con promociones activas para categorías inferiores o iguales a Silver
SELECT a.nombre_atraccion
FROM Atraccion a
JOIN Promocion_Atraccion pa ON a.id_atraccion = pa.id_atraccion
JOIN Promocion p ON pa.ID_promocion = p.ID_promocion
JOIN cat_promo cp ON p.ID_promocion = cp.ID_promocion
JOIN Categoria c ON cp.nombre_cat = c.nombre_cat
JOIN Ranking r ON c.id_ranking = r.id_ranking
WHERE r.peso_imp <= (
    SELECT peso_imp FROM Categoria WHERE nombre_cat = 'Silver'
)
AND CURRENT_DATE BETWEEN p.fecha_inicio AND p.fecha_fin;

-- Consulta que muestra las atracciones disponibles en parques de diversiones
-- Filtra aquellas atracciones que permiten el ingreso a personas con altura menor o igual a 150 cm
-- Incluye el nombre de la atracción, altura mínima requerida, nombre del parque y categoría mínima


SELECT 
    a.nombre_atraccion,
    c.altura_min,
    p_ent.nombre AS nombre_parque,
    a.min_categoria
FROM Atraccion a
JOIN Caracteristica c ON a.id_caracteristica = c.id_caracteristica
JOIN Parque_de_Diversiones p ON a.id_parque = p.id_entretenimiento
JOIN Entretenimiento p_ent ON p.id_entretenimiento = p_ent.id_entretenimiento
WHERE c.altura_min <= 150  
ORDER BY p_ent.nombre;



-- Consulta que muestra titulares con sus tarjetas activas y la categoría actual de cada tarjeta
-- Se obtiene la categoría vigente usando la última fecha de inicio en el historial de categorías
-- Filtra solo tarjetas activas (estado = TRUE)
-- Ordena los resultados por DNI del titular para fácil identificación

SELECT
    t.DNI,
    t.Nombre,
    t.Apellido,
    tar.ID_tarjeta,
    hc.nombre_cat AS categoria_actual,
    hc.fecha_de_inicio AS fecha_categoria_actual
FROM Titular t
JOIN Tarjeta tar ON t.DNI = tar.DNI
    AND tar.estado = TRUE                      -- Solo tarjetas activas
JOIN HistorialCategoria hc ON tar.ID_tarjeta = hc.ID_tarjeta
WHERE hc.fecha_de_inicio = (
    -- Obtenemos la última fecha de inicio para esa tarjeta (la categoría vigente)
    SELECT MAX(hc2.fecha_de_inicio)
    FROM HistorialCategoria hc2
    WHERE hc2.ID_tarjeta = tar.ID_tarjeta
)
ORDER BY t.DNI;






-- Consultas de Domicilios

-- Consulta que muestra información completa de los titulares junto con su domicilio
-- Incluye DNI, nombre, apellido, calle, número, piso, localidad, provincia y país
-- Ordena los resultados por apellido y nombre para facilitar la lectura

SELECT
    t.DNI,
    t.Nombre,
    t.Apellido,
    c.Nombre AS calle,
    d.numero,
    d.piso,
    l.Nombre AS localidad,
    pr.Nombre AS provincia,
    p.Nombre AS pais
FROM Titular t
JOIN Domicilio d ON t.id_dom = d.id_dom
JOIN Calle c ON d.ID_calle = c.ID_calle
JOIN Localidad l ON c.ID_ciudad = l.ID_ciudad
JOIN Provincia pr ON l.ID_provincia = pr.ID_provincia
JOIN Pais p ON pr.ID_pais = p.ID_pais
ORDER BY t.Apellido, t.Nombre;


-- Consulta que cuenta la cantidad de titulares por país
-- Útil para obtener estadísticas de distribución geográfica de los titulares
-- Agrupa los titulares por país y ordena los resultados de mayor a menor cantidad

SELECT 
    p.Nombre AS pais,
    COUNT(*) AS cantidad_titulares
FROM Titular t
JOIN Domicilio d ON t.id_dom = d.id_dom
JOIN Calle c ON d.ID_calle = c.ID_calle
JOIN Localidad l ON c.ID_ciudad = l.ID_ciudad
JOIN Provincia pr ON l.ID_provincia = pr.ID_provincia
JOIN Pais p ON pr.ID_pais = p.ID_pais
GROUP BY p.Nombre
ORDER BY cantidad_titulares DESC;



