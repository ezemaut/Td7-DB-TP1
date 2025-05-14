-- ==============================================
-- DROP ALL TABLES IN CORRECT DEPENDENCY ORDER
-- ==============================================
DROP TABLE IF EXISTS cat_promo CASCADE;
DROP TABLE IF EXISTS Promo_Entret CASCADE;
DROP TABLE IF EXISTS Promocion_Atraccion CASCADE;
DROP TABLE IF EXISTS Evento CASCADE;
DROP TABLE IF EXISTS Parque_de_Diversiones CASCADE;
DROP TABLE IF EXISTS Linea_Factura CASCADE;
DROP TABLE IF EXISTS Medio_de_Pago CASCADE;
DROP TABLE IF EXISTS HistorialCategoria CASCADE;
DROP TABLE IF EXISTS Tarjeta CASCADE;
DROP TABLE IF EXISTS Factura CASCADE;
DROP TABLE IF EXISTS Atraccion CASCADE;
DROP TABLE IF EXISTS Caracteristica CASCADE;
DROP TABLE IF EXISTS Entretenimiento CASCADE;
DROP TABLE IF EXISTS Promocion CASCADE;
DROP TABLE IF EXISTS Categoria CASCADE;
DROP TABLE IF EXISTS Ranking CASCADE;
DROP TABLE IF EXISTS Empresa CASCADE;
DROP TABLE IF EXISTS Titular CASCADE;
DROP TABLE IF EXISTS Domicilio CASCADE;
DROP TABLE IF EXISTS Calle CASCADE;
DROP TABLE IF EXISTS Localidad CASCADE;
DROP TABLE IF EXISTS Provincia CASCADE;
DROP TABLE IF EXISTS Pais CASCADE;

-- ==============================================
-- CREATE BASE LOCATION TABLES FIRST
-- ==============================================
CREATE TABLE Pais (
    ID_pais INT PRIMARY KEY,
    Nombre VARCHAR(100)
);

CREATE TABLE Provincia (
    ID_provincia INT PRIMARY KEY,
    Nombre VARCHAR(100),
    ID_pais INT,
    FOREIGN KEY (ID_pais) REFERENCES Pais(ID_pais)
);

CREATE TABLE Localidad (
    ID_ciudad INT PRIMARY KEY,
    Nombre VARCHAR(100),
    ID_provincia INT,
    FOREIGN KEY (ID_provincia) REFERENCES Provincia(ID_provincia)
);

CREATE TABLE Calle (
    ID_calle INT PRIMARY KEY,
    Nombre VARCHAR(100),
    CP INT,
    ID_ciudad INT,
    FOREIGN KEY (ID_ciudad) REFERENCES Localidad(ID_ciudad)
);

CREATE TABLE Domicilio (
    id_dom INT PRIMARY KEY,
    numero VARCHAR(10),
    piso INT,
    ID_calle INT,
    FOREIGN KEY (ID_calle) REFERENCES Calle(ID_calle)
);

-- ==============================================
-- CREATE CORE ENTITIES
-- ==============================================
CREATE TABLE Empresa (
    cuit VARCHAR(50) PRIMARY KEY,
    razon_social VARCHAR(50),
    id_dom INT UNIQUE,
    FOREIGN KEY (id_dom) REFERENCES Domicilio(id_dom)
);

CREATE TABLE Ranking (
    id_ranking INT PRIMARY KEY,
    peso_imp INT
);

CREATE TABLE Categoria (
    nombre_cat VARCHAR(100) PRIMARY KEY,
    min_total_anual DECIMAL(10,2),
    promedio_mensual DECIMAL(10,2),
    id_ranking INT UNIQUE,
    FOREIGN KEY (id_ranking) REFERENCES Ranking(id_ranking)
);

CREATE TABLE Promocion (
    ID_promocion INT PRIMARY KEY,
    fecha_inicio DATE,
    fecha_fin DATE,
    descuento INT
);

CREATE TABLE Caracteristica (
    id_caracteristica INT PRIMARY KEY,
    nombre_atraccion VARCHAR(100),
    altura_min INT,
    edad_min INT
);

CREATE TABLE Titular (
    DNI INT PRIMARY KEY,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Celular VARCHAR(50),
    id_dom INT,
    FOREIGN KEY (id_dom) REFERENCES Domicilio(id_dom)
);

CREATE TABLE Tarjeta (
    ID_tarjeta INT PRIMARY KEY,
    foto VARCHAR(255),
    estado BOOLEAN,
    Total_gastado DECIMAL(10,2),
    DNI INT,
    FOREIGN KEY (DNI) REFERENCES Titular(DNI)
);

CREATE TABLE Medio_de_Pago (
    id_medio INT PRIMARY KEY,
    banco VARCHAR(100),
    tipo VARCHAR(50)
);

CREATE TABLE Factura (
    Nro_factura INT PRIMARY KEY,
    fecha_emision DATE,
    fecha_vencimiento DATE,
    importe_total DECIMAL(10,2),
    pagado BOOLEAN,
    DNI INT,
    id_medio_pago INT,
    FOREIGN KEY (DNI) REFERENCES Titular(DNI),
    FOREIGN KEY (id_medio_pago) REFERENCES Medio_de_Pago(id_medio)
);

-- ==============================================
-- CREATE ENTRETAINMENT STRUCTURE
-- ==============================================
CREATE TABLE Entretenimiento (
    id_entretenimiento INT,
    fecha DATE,
    nombre VARCHAR(50),
    precio DECIMAL(10,2),
    tipo VARCHAR(50),
    min_categoria VARCHAR(100),
    id_domicilio INT,  -- Foreign key to Domicilio
    PRIMARY KEY (id_entretenimiento, fecha),
    FOREIGN KEY (min_categoria) REFERENCES Categoria(nombre_cat),
    FOREIGN KEY (id_domicilio) REFERENCES Domicilio(id_dom)  -- Adding the foreign key reference to Domicilio
);


CREATE TABLE Parque_de_Diversiones (
    id_entretenimiento INT,
    fecha DATE,
    PRIMARY KEY (id_entretenimiento, fecha),
    FOREIGN KEY (id_entretenimiento, fecha) REFERENCES Entretenimiento(id_entretenimiento, fecha)
);

CREATE TABLE Evento (
    id_entretenimiento INT PRIMARY KEY,
    fecha DATE,
    fecha_inicio DATE,
    fecha_fin DATE,
    cuit VARCHAR(50),
    FOREIGN KEY (id_entretenimiento, fecha) REFERENCES Entretenimiento(id_entretenimiento, fecha),
    FOREIGN KEY (cuit) REFERENCES Empresa(cuit)
);

CREATE TABLE Atraccion (
    id_atraccion INT,
    fecha DATE,
    precio DECIMAL(10,2),
    id_caracteristica INT,
    id_parque INT,
    fecha_parque DATE,
    min_categoria VARCHAR(100),  -- Added column for min_categoria
    PRIMARY KEY (id_atraccion, fecha),
    FOREIGN KEY (id_caracteristica) REFERENCES Caracteristica(id_caracteristica),
    FOREIGN KEY (id_parque, fecha_parque) REFERENCES Parque_de_Diversiones(id_entretenimiento, fecha),
    FOREIGN KEY (min_categoria) REFERENCES Categoria(nombre_cat)  -- Foreign key to Categoria
);

-- ==============================================
-- CREATE DEPENDENT TABLES
-- ==============================================
CREATE TABLE Linea_Factura (
    id_linea INT PRIMARY KEY,
    fecha_de_consumo DATE,
    monto DECIMAL(10,2),
    nro_factura INT,
    id_tarjeta INT,
    id_entretenimiento INT,
    fecha_entret DATE,
    id_atraccion INT,
    fecha_atraccion DATE,
    FOREIGN KEY (nro_factura) REFERENCES Factura(Nro_factura),
    FOREIGN KEY (id_tarjeta) REFERENCES Tarjeta(ID_tarjeta),
    FOREIGN KEY (id_entretenimiento, fecha_entret) REFERENCES Entretenimiento(id_entretenimiento, fecha),
    FOREIGN KEY (id_atraccion, fecha_atraccion) REFERENCES Atraccion(id_atraccion, fecha)
);

CREATE TABLE HistorialCategoria (
    id_historial INT PRIMARY KEY,
    fecha_de_inicio DATE,
    ID_tarjeta INT,
    nombre_cat VARCHAR(100),
    FOREIGN KEY (ID_tarjeta) REFERENCES Tarjeta(ID_tarjeta),
    FOREIGN KEY (nombre_cat) REFERENCES Categoria(nombre_cat)
);

-- ==============================================
-- CREATE MANY-TO-MANY RELATIONSHIP TABLES
-- ==============================================
CREATE TABLE Promocion_Atraccion (
    ID_promocion INT,
    id_atraccion INT,
    fecha DATE,
    PRIMARY KEY (ID_promocion, id_atraccion, fecha),
    FOREIGN KEY (ID_promocion) REFERENCES Promocion(ID_promocion),
    FOREIGN KEY (id_atraccion, fecha) REFERENCES Atraccion(id_atraccion, fecha)
);

CREATE TABLE Promo_Entret (
    ID_promocion INT,
    id_entretenimiento INT,
    fecha DATE,
    PRIMARY KEY (ID_promocion, id_entretenimiento, fecha),
    FOREIGN KEY (ID_promocion) REFERENCES Promocion(ID_promocion),
    FOREIGN KEY (id_entretenimiento, fecha) REFERENCES Entretenimiento(id_entretenimiento, fecha)
);

CREATE TABLE cat_promo (
    nombre_cat VARCHAR(100),
    ID_promocion INT,
    PRIMARY KEY (nombre_cat, ID_promocion),
    FOREIGN KEY (nombre_cat) REFERENCES Categoria(nombre_cat),
    FOREIGN KEY (ID_promocion) REFERENCES Promocion(ID_promocion)
);


INSERT INTO Pais (ID_pais, Nombre) VALUES (1, 'Northern Mariana Islands');
INSERT INTO Pais (ID_pais, Nombre) VALUES (2, 'Bouvet Island (Bouvetoya)');
INSERT INTO Pais (ID_pais, Nombre) VALUES (3, 'Anguilla');
INSERT INTO Pais (ID_pais, Nombre) VALUES (4, 'Saint Vincent and the Grenadines');
INSERT INTO Pais (ID_pais, Nombre) VALUES (5, 'Falkland Islands (Malvinas)');
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (1, 'Kansas', 1);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (2, 'Iowa', 1);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (3, 'Florida', 3);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (4, 'West Virginia', 2);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (5, 'Connecticut', 2);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (6, 'Utah', 2);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (7, 'West Virginia', 1);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (8, 'Ohio', 5);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (9, 'Colorado', 1);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (10, 'Pennsylvania', 5);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (1, 'Johnsonland', 7);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (2, 'East William', 1);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (3, 'New Jamesside', 1);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (4, 'Robinsonshire', 2);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (5, 'Lisatown', 4);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (6, 'Lake Roberto', 4);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (7, 'Ericmouth', 9);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (8, 'North Noahstad', 10);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (9, 'Cassandraton', 1);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (10, 'Herrerafurt', 9);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (11, 'New Kellystad', 4);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (12, 'Lake Chad', 9);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (13, 'Port Keith', 7);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (14, 'Port Jesseville', 4);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (15, 'Ramirezstad', 8);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (1, 'Mitchell Fords', '88342', 10);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (2, 'Miles Springs', '85440', 5);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (3, 'Chelsea Extension', '70511', 13);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (4, 'Frank Light', '35883', 14);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (5, 'Gabrielle Ville', '07832', 1);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (6, 'Lydia Valley', '41848', 13);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (7, 'Adams Forest', '74842', 13);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (8, 'Lewis Parks', '52357', 3);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (9, 'Thomas Dam', '32826', 12);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (10, 'Burgess Meadow', '76985', 7);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (11, 'Cox Dam', '67285', 6);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (12, 'Davis Causeway', '14872', 5);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (13, 'Courtney Turnpike', '89693', 3);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (14, 'Carlson Lights', '50520', 4);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (15, 'Rice Plaza', '02005', 13);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (16, 'Erin Plain', '98920', 6);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (17, 'Mack Junctions', '15122', 2);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (18, 'Graham Motorway', '00926', 2);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (19, 'Stanton Track', '23917', 7);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (20, 'Monica Hills', '84249', 2);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (1, '932', 5, 12);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (2, '2880', 9, 9);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (3, '570', 0, 15);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (4, '54303', 8, 4);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (5, '117', 6, 3);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (6, '82278', 8, 10);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (7, '48963', 10, 20);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (8, '346', 5, 19);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (9, '578', 3, 3);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (10, '1331', 0, 8);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (11, '0983', 4, 3);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (12, '301', 3, 4);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (13, '031', 6, 9);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (14, '51834', 7, 12);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (15, '738', 2, 12);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (16, '99737', 5, 7);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (17, '3116', 10, 9);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (18, '6670', 10, 3);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (19, '106', 9, 6);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (20, '513', 8, 8);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (21, '38726', 2, 15);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (22, '47317', 6, 9);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (23, '108', 10, 18);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (24, '13267', 3, 11);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (25, '3602', 0, 8);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (26, '0647', 0, 11);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (27, '6872', 6, 9);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (28, '43098', 1, 7);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (29, '50097', 9, 11);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (30, '820', 3, 16);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('202970753705', 'Miller, Lopez and Larson', 9);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('201599707677', 'Hensley, Powell and David', 24);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('207805745017', 'Sanchez, Wheeler and Harvey', 29);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('207801222128', 'Sandoval-Cunningham', 12);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('205284391408', 'Donovan-Harris', 17);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (43271130, 'John', 'Foster', '+1-647-451-0799x11838', 16);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (43855396, 'Nicole', 'Suarez', '(442)678-4980x841', 3);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (39936571, 'Pamela', 'Newton', '(944)693-5348', 25);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (38852264, 'Christopher', 'Henderson', '300-352-4278x680', 2);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (49593385, 'Rebecca', 'Gardner', '(598)326-2045x053', 28);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (43933742, 'Kimberly', 'Henson', '(392)832-2602x56342', 4);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (38649691, 'Michele', 'Walker', '754.833.0365x414', 5);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (49400422, 'Tina', 'Herrera', '8147294019', 21);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (43262632, 'Samuel', 'Joyce', '569-734-0608', 6);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (45235969, 'Chad', 'Beck', '895-814-8465x64823', 26);
INSERT INTO Medio_de_Pago (id_medio, banco, tipo) VALUES (1, 'Adkins, Thompson and Carroll', 'Transferencia');
INSERT INTO Medio_de_Pago (id_medio, banco, tipo) VALUES (2, 'Kelley-Smith', 'Débito');
INSERT INTO Medio_de_Pago (id_medio, banco, tipo) VALUES (3, 'Clark-Floyd', 'Transferencia');
INSERT INTO Medio_de_Pago (id_medio, banco, tipo) VALUES (4, 'Pena, Marshall and Ramos', 'Crédito');
INSERT INTO Medio_de_Pago (id_medio, banco, tipo) VALUES (5, 'Dixon Ltd', 'Débito');
INSERT INTO Ranking (id_ranking, peso_imp) VALUES (1, 1);
INSERT INTO Ranking (id_ranking, peso_imp) VALUES (2, 2);
INSERT INTO Ranking (id_ranking, peso_imp) VALUES (3, 3);
INSERT INTO Ranking (id_ranking, peso_imp) VALUES (4, 4);
INSERT INTO Ranking (id_ranking, peso_imp) VALUES (5, 5);
INSERT INTO Categoria (nombre_cat, min_total_anual, promedio_mensual, id_ranking) VALUES ('Bronze', 9739.71, 874.7, 1);
INSERT INTO Categoria (nombre_cat, min_total_anual, promedio_mensual, id_ranking) VALUES ('Silver', 1103.33, 748.65, 2);
INSERT INTO Categoria (nombre_cat, min_total_anual, promedio_mensual, id_ranking) VALUES ('Gold', 7135.39, 583.27, 3);
INSERT INTO Categoria (nombre_cat, min_total_anual, promedio_mensual, id_ranking) VALUES ('Diamond', 3401.43, 676.87, 4);
INSERT INTO Categoria (nombre_cat, min_total_anual, promedio_mensual, id_ranking) VALUES ('Platinum', 2003.97, 491.29, 5);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (1, '2025-02-02 22:49:09', '2025-02-17 22:49:09', 5);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (2, '2025-05-08 22:28:01', '2025-06-01 22:28:01', 21);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (3, '2025-01-17 11:10:33', '2025-02-03 11:10:33', 16);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (4, '2025-02-25 02:32:25', '2025-03-14 02:32:25', 11);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (5, '2025-04-11 02:10:49', '2025-05-09 02:10:49', 45);
INSERT INTO Caracteristica (id_caracteristica, nombre_atraccion, altura_min, edad_min) VALUES (1, 'Record', 138, 18);
INSERT INTO Caracteristica (id_caracteristica, nombre_atraccion, altura_min, edad_min) VALUES (2, 'Property', 181, 13);
INSERT INTO Caracteristica (id_caracteristica, nombre_atraccion, altura_min, edad_min) VALUES (3, 'President', 177, 8);
INSERT INTO Caracteristica (id_caracteristica, nombre_atraccion, altura_min, edad_min) VALUES (4, 'Government', 119, 10);
INSERT INTO Caracteristica (id_caracteristica, nombre_atraccion, altura_min, edad_min) VALUES (5, 'Better', 197, 7);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (1, 'https://picsum.photos/481/635', True, 431.36, 43262632);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (2, 'https://picsum.photos/407/301', False, 0.0, 45235969);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (3, 'https://dummyimage.com/94x501', True, 896.61, 49400422);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (4, 'https://dummyimage.com/149x932', False, 54.49, 43855396);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (5, 'https://dummyimage.com/398x786', True, 0.0, 49593385);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (6, 'https://picsum.photos/818/499', True, 0.0, 43271130);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (7, 'https://dummyimage.com/11x218', True, 0.0, 45235969);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (8, 'https://placekitten.com/448/360', False, 37.45, 43855396);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (9, 'https://placekitten.com/951/102', True, 80.14, 43855396);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (10, 'https://dummyimage.com/510x248', False, 0.0, 39936571);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (1, '2025-01-26 21:24:18', '2025-04-01 00:00:00', 294.66, False, 49400422, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (2, '2025-05-10 15:08:15', '2025-04-14 00:00:00', 133.39, False, 49400422, 5);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (3, '2025-04-19 12:46:50', '2025-04-26 00:00:00', 91.94, True, 43855396, 5);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (4, '2025-03-03 14:42:56', '2025-03-27 00:00:00', 368.52, False, 43262632, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (5, '2025-04-29 23:10:00', '2025-04-09 00:00:00', 62.84, False, 43262632, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (6, '2025-03-24 20:45:21', '2025-04-17 00:00:00', 431.11, True, 49400422, 4);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (7, '2025-03-28 14:06:28', '2025-01-31 00:00:00', 80.14, True, 43855396, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (8, '2025-04-03 04:08:35', '2025-03-29 00:00:00', 0.0, True, 39936571, 1);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (9, '2025-02-20 07:55:12', '2025-02-18 00:00:00', 37.45, True, 49400422, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (10, '2025-05-04 19:43:03', '2025-02-23 00:00:00', 0.0, True, 43271130, 1);
INSERT INTO Entretenimiento (id_entretenimiento, fecha, nombre, precio, tipo, min_categoria, id_domicilio) VALUES (1, '2025-12-03 01:58:36', 'Simsview Fest', 25.65, 'Evento', 'Gold', 29);
INSERT INTO Entretenimiento (id_entretenimiento, fecha, nombre, precio, tipo, min_categoria, id_domicilio) VALUES (2, '2025-11-01 11:01:12', 'Lake Justinview Fest', 62.84, 'Evento', 'Diamond', 17);
INSERT INTO Entretenimiento (id_entretenimiento, fecha, nombre, precio, tipo, min_categoria, id_domicilio) VALUES (3, '2025-09-22 01:26:10', 'Patricialand Fest', 43.82, 'Evento', 'Platinum', 18);
INSERT INTO Entretenimiento (id_entretenimiento, fecha, nombre, precio, tipo, min_categoria, id_domicilio) VALUES (4, '2025-07-07 08:51:00', 'Parque Edward', 161.23, 'Parque', 'Diamond', 8);
INSERT INTO Entretenimiento (id_entretenimiento, fecha, nombre, precio, tipo, min_categoria, id_domicilio) VALUES (5, '2025-10-10 09:15:28', 'Lake Jason Fest', 37.45, 'Evento', 'Diamond', 4);
INSERT INTO Entretenimiento (id_entretenimiento, fecha, nombre, precio, tipo, min_categoria, id_domicilio) VALUES (6, '2025-10-22 17:57:33', 'Parque Rick', 94.0, 'Parque', 'Bronze', 14);
INSERT INTO Entretenimiento (id_entretenimiento, fecha, nombre, precio, tipo, min_categoria, id_domicilio) VALUES (7, '2025-12-11 08:36:45', 'Perryborough Fest', 92.47, 'Evento', 'Gold', 2);
INSERT INTO Entretenimiento (id_entretenimiento, fecha, nombre, precio, tipo, min_categoria, id_domicilio) VALUES (8, '2025-10-24 19:07:54', 'Steinshire Fest', 54.49, 'Evento', 'Platinum', 8);
INSERT INTO Entretenimiento (id_entretenimiento, fecha, nombre, precio, tipo, min_categoria, id_domicilio) VALUES (9, '2025-05-22 05:09:40', 'Parque Melissa', 95.94, 'Parque', 'Gold', 5);
INSERT INTO Entretenimiento (id_entretenimiento, fecha, nombre, precio, tipo, min_categoria, id_domicilio) VALUES (10, '2025-12-24 04:55:59', 'Parque Omar', 177.41, 'Parque', 'Bronze', 8);
INSERT INTO Parque_de_Diversiones (id_entretenimiento, fecha) VALUES (4, '2025-07-07 08:51:00');
INSERT INTO Parque_de_Diversiones (id_entretenimiento, fecha) VALUES (6, '2025-10-22 17:57:33');
INSERT INTO Parque_de_Diversiones (id_entretenimiento, fecha) VALUES (9, '2025-05-22 05:09:40');
INSERT INTO Parque_de_Diversiones (id_entretenimiento, fecha) VALUES (10, '2025-12-24 04:55:59');
INSERT INTO Evento (id_entretenimiento, fecha, fecha_inicio, fecha_fin, cuit) VALUES (1, '2025-12-03 01:58:36', '2025-05-14 00:00:00', '2025-05-16 00:00:00', '207801222128');
INSERT INTO Evento (id_entretenimiento, fecha, fecha_inicio, fecha_fin, cuit) VALUES (2, '2025-11-01 11:01:12', '2025-05-14 00:00:00', '2025-09-27 00:00:00', '205284391408');
INSERT INTO Evento (id_entretenimiento, fecha, fecha_inicio, fecha_fin, cuit) VALUES (3, '2025-09-22 01:26:10', '2025-05-14 00:00:00', '2025-09-06 00:00:00', '202970753705');
INSERT INTO Evento (id_entretenimiento, fecha, fecha_inicio, fecha_fin, cuit) VALUES (5, '2025-10-10 09:15:28', '2025-05-14 00:00:00', '2026-03-02 00:00:00', '202970753705');
INSERT INTO Evento (id_entretenimiento, fecha, fecha_inicio, fecha_fin, cuit) VALUES (7, '2025-12-11 08:36:45', '2025-05-14 00:00:00', '2025-10-12 00:00:00', '205284391408');
INSERT INTO Evento (id_entretenimiento, fecha, fecha_inicio, fecha_fin, cuit) VALUES (8, '2025-10-24 19:07:54', '2025-05-14 00:00:00', '2026-04-10 00:00:00', '202970753705');
INSERT INTO Atraccion (id_atraccion, fecha, precio, id_caracteristica, id_parque, min_categoria) VALUES (1, '2025-03-23 08:46:50', 2815.92, 2, 4, 'Silver');
INSERT INTO Atraccion (id_atraccion, fecha, precio, id_caracteristica, id_parque, min_categoria) VALUES (2, '2025-04-15 12:17:22', 1714.1, 2, 10, 'Diamond');
INSERT INTO Atraccion (id_atraccion, fecha, precio, id_caracteristica, id_parque, min_categoria) VALUES (3, '2025-04-17 01:09:39', 911.59, 1, 4, 'Diamond');
INSERT INTO Atraccion (id_atraccion, fecha, precio, id_caracteristica, id_parque, min_categoria) VALUES (4, '2025-04-28 03:21:38', 2816.3, 4, 9, 'Gold');
INSERT INTO Atraccion (id_atraccion, fecha, precio, id_caracteristica, id_parque, min_categoria) VALUES (5, '2025-02-12 19:47:05', 2241.48, 5, 10, 'Diamond');
INSERT INTO Atraccion (id_atraccion, fecha, precio, id_caracteristica, id_parque, min_categoria) VALUES (6, '2025-04-05 19:18:51', 974.74, 2, 6, 'Bronze');
INSERT INTO Atraccion (id_atraccion, fecha, precio, id_caracteristica, id_parque, min_categoria) VALUES (7, '2025-02-12 14:34:44', 2369.94, 1, 4, 'Bronze');
INSERT INTO Atraccion (id_atraccion, fecha, precio, id_caracteristica, id_parque, min_categoria) VALUES (8, '2025-02-22 23:58:14', 1757.13, 5, 10, 'Silver');
INSERT INTO Atraccion (id_atraccion, fecha, precio, id_caracteristica, id_parque, min_categoria) VALUES (9, '2025-03-26 15:08:34', 2901.95, 1, 4, 'Silver');
INSERT INTO Atraccion (id_atraccion, fecha, precio, id_caracteristica, id_parque, min_categoria) VALUES (10, '2025-04-05 07:15:20', 1987.59, 2, 4, 'Diamond');
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento, fecha) VALUES (5, 2, '2025-11-01 11:01:12');
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento, fecha) VALUES (5, 4, '2025-07-07 08:51:00');
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento, fecha) VALUES (1, 10, '2025-12-24 04:55:59');
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento, fecha) VALUES (4, 10, '2025-12-24 04:55:59');
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento, fecha) VALUES (5, 10, '2025-12-24 04:55:59');
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento, fecha) VALUES (3, 6, '2025-10-22 17:57:33');
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento, fecha) VALUES (3, 4, '2025-07-07 08:51:00');
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento, fecha) VALUES (4, 3, '2025-07-07 08:51:00');
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento, fecha) VALUES (4, 5, '2025-10-10 09:15:28');
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento, fecha) VALUES (1, 6, '2025-10-22 17:57:33');
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion, fecha) VALUES (4, 1, '2025-03-23 08:46:50');
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion, fecha) VALUES (5, 10, '2025-04-05 07:15:20');
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion, fecha) VALUES (1, 2, '2025-04-15 12:17:22');
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion, fecha) VALUES (2, 9, '2025-03-26 15:08:34');
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion, fecha) VALUES (3, 9, '2025-03-26 15:08:34');
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion, fecha) VALUES (3, 3, '2025-04-17 01:09:39');
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion, fecha) VALUES (2, 2, '2025-04-15 12:17:22');
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion, fecha) VALUES (3, 6, '2025-04-05 19:18:51');
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion, fecha) VALUES (4, 3, '2025-04-17 01:09:39');
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion, fecha) VALUES (5, 9, '2025-03-26 15:08:34');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (1, '2025-11-01 11:01:12', 62.84, 1, 3, 2, '2025-11-01 11:01:12', 3, '2025-04-17 01:09:39');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (2, '2025-11-01 11:01:12', 62.84, 5, 1, 2, '2025-11-01 11:01:12', 9, '2025-03-26 15:08:34');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (3, '2025-10-10 09:15:28', 37.45, 3, 8, 5, '2025-10-10 09:15:28', 10, '2025-04-05 07:15:20');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (4, '2025-07-07 08:51:00', 161.23, 4, 1, 4, '2025-07-07 08:51:00', 5, '2025-02-12 19:47:05');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (5, '2025-10-10 09:15:28', 37.45, 9, 3, 5, '2025-10-10 09:15:28', 1, '2025-03-23 08:46:50');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (6, '2025-10-10 09:15:28', 37.45, 2, 3, 5, '2025-10-10 09:15:28', 1, '2025-03-23 08:46:50');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (7, '2025-09-22 01:26:10', 43.82, 1, 3, 3, '2025-09-22 01:26:10', 5, '2025-02-12 19:47:05');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (8, '2025-10-24 19:07:54', 54.49, 3, 9, 8, '2025-10-24 19:07:54', 9, '2025-03-26 15:08:34');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (9, '2025-12-03 01:58:36', 25.65, 7, 9, 1, '2025-12-03 01:58:36', 2, '2025-04-15 12:17:22');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (10, '2025-05-22 05:09:40', 95.94, 2, 3, 9, '2025-05-22 05:09:40', 1, '2025-03-23 08:46:50');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (11, '2025-12-11 08:36:45', 92.47, 6, 3, 7, '2025-12-11 08:36:45', 3, '2025-04-17 01:09:39');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (12, '2025-10-22 17:57:33', 94.0, 1, 3, 6, '2025-10-22 17:57:33', 1, '2025-03-23 08:46:50');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (13, '2025-07-07 08:51:00', 161.23, 6, 3, 4, '2025-07-07 08:51:00', 2, '2025-04-15 12:17:22');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (14, '2025-12-24 04:55:59', 177.41, 6, 3, 10, '2025-12-24 04:55:59', 3, '2025-04-17 01:09:39');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (15, '2025-09-22 01:26:10', 43.82, 4, 1, 3, '2025-09-22 01:26:10', 7, '2025-02-12 14:34:44');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (16, '2025-10-22 17:57:33', 94.0, 1, 3, 6, '2025-10-22 17:57:33', 7, '2025-02-12 14:34:44');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (17, '2025-09-22 01:26:10', 43.82, 4, 1, 3, '2025-09-22 01:26:10', 2, '2025-04-15 12:17:22');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (18, '2025-10-24 19:07:54', 54.49, 7, 4, 8, '2025-10-24 19:07:54', 4, '2025-04-28 03:21:38');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (19, '2025-10-22 17:57:33', 94.0, 4, 1, 6, '2025-10-22 17:57:33', 5, '2025-02-12 19:47:05');
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, fecha_entret, id_atraccion, fecha_atraccion) VALUES (20, '2025-12-03 01:58:36', 25.65, 4, 1, 1, '2025-12-03 01:58:36', 4, '2025-04-28 03:21:38');
INSERT INTO HistorialCategoria (id_tarjeta, nombre_cat, fecha_asignacion) VALUES (7, 'Gold', '2020-03-31 00:00:00');
INSERT INTO HistorialCategoria (id_tarjeta, nombre_cat, fecha_asignacion) VALUES (5, 'Bronze', '2023-04-23 00:00:00');
INSERT INTO HistorialCategoria (id_tarjeta, nombre_cat, fecha_asignacion) VALUES (5, 'Gold', '2022-11-10 00:00:00');
INSERT INTO HistorialCategoria (id_tarjeta, nombre_cat, fecha_asignacion) VALUES (9, 'Diamond', '2023-06-10 00:00:00');
INSERT INTO HistorialCategoria (id_tarjeta, nombre_cat, fecha_asignacion) VALUES (9, 'Gold', '2021-05-27 00:00:00');
INSERT INTO HistorialCategoria (id_tarjeta, nombre_cat, fecha_asignacion) VALUES (1, 'Bronze', '2023-12-23 00:00:00');
INSERT INTO HistorialCategoria (id_tarjeta, nombre_cat, fecha_asignacion) VALUES (5, 'Silver', '2021-01-31 00:00:00');
INSERT INTO HistorialCategoria (id_tarjeta, nombre_cat, fecha_asignacion) VALUES (10, 'Gold', '2025-04-17 00:00:00');
INSERT INTO HistorialCategoria (id_tarjeta, nombre_cat, fecha_asignacion) VALUES (1, 'Bronze', '2024-07-17 00:00:00');
INSERT INTO HistorialCategoria (id_tarjeta, nombre_cat, fecha_asignacion) VALUES (10, 'Diamond', '2020-03-24 00:00:00');
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Gold', 3);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Diamond', 5);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Platinum', 1);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Silver', 3);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Bronze', 4);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Bronze', 5);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Platinum', 2);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Gold', 4);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Bronze', 3);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Platinum', 3);
