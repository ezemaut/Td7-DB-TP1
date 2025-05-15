-- BASE LOCATION TABLES
SELECT * FROM Pais;
SELECT * FROM Provincia;
SELECT * FROM Localidad;
SELECT * FROM Calle;
SELECT * FROM Domicilio;

-- CORE ENTITIES
SELECT * FROM Empresa;
SELECT * FROM Ranking;
SELECT * FROM Categoria;
SELECT * FROM Promocion;
SELECT * FROM Caracteristica;
SELECT * FROM Titular;
SELECT * FROM Tarjeta;
SELECT * FROM Medio_de_Pago;
SELECT * FROM Factura;

-- ENTERTAINMENT STRUCTURE
SELECT * FROM Entretenimiento;
SELECT * FROM Parque_de_Diversiones;
SELECT * FROM Evento;
SELECT * FROM Atraccion;

-- LISTA_PRECIO
SELECT * FROM Lista_Precio;

-- DEPENDENT TABLES
SELECT * FROM Linea_Factura;
SELECT * FROM HistorialCategoria;

-- MANY-TO-MANY RELATIONSHIP TABLES
SELECT * FROM Promocion_Atraccion;
SELECT * FROM Promo_Entret;
SELECT * FROM cat_promo;
