-- ==============================================
-- DROP ALL TABLES IN CORRECT DEPENDENCY ORDER
-- ==============================================
DROP TABLE IF EXISTS cat_promo CASCADE;
DROP TABLE IF EXISTS Promo_Entret CASCADE;
DROP TABLE IF EXISTS Promocion_Atraccion CASCADE;
DROP TABLE IF EXISTS HistorialCategoria CASCADE;
DROP TABLE IF EXISTS Linea_Factura CASCADE;
DROP TABLE IF EXISTS Lista_Precio CASCADE;
DROP TABLE IF EXISTS Atraccion CASCADE;
DROP TABLE IF EXISTS Evento CASCADE;
DROP TABLE IF EXISTS Parque_de_Diversiones CASCADE;
DROP TABLE IF EXISTS Entretenimiento CASCADE;
DROP TABLE IF EXISTS Promocion CASCADE;
DROP TABLE IF EXISTS Factura CASCADE;
DROP TABLE IF EXISTS Tarjeta CASCADE;
DROP TABLE IF EXISTS Medio_de_Pago CASCADE;
DROP TABLE IF EXISTS Caracteristica CASCADE;
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
    altura_min DECIMAL(5,2),
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
    fecha_pago DATE,
    FOREIGN KEY (DNI) REFERENCES Titular(DNI),
    FOREIGN KEY (id_medio_pago) REFERENCES Medio_de_Pago(id_medio)
);

-- ==============================================
-- CREATE ENTRETAINMENT STRUCTURE
-- ==============================================
CREATE TABLE Entretenimiento (
    id_entretenimiento INT PRIMARY KEY,
    nombre VARCHAR(50),
    tipo VARCHAR(50),
    nombre_categoria VARCHAR(100),
    id_domicilio INT,
    FOREIGN KEY (nombre_categoria) REFERENCES Categoria(nombre_cat),
    FOREIGN KEY (id_domicilio) REFERENCES Domicilio(id_dom)
);

CREATE TABLE Parque_de_Diversiones (
    id_entretenimiento INT,
    PRIMARY KEY (id_entretenimiento),
    FOREIGN KEY (id_entretenimiento) REFERENCES Entretenimiento(id_entretenimiento)
);

CREATE TABLE Evento (
    id_entretenimiento INT PRIMARY KEY,
    fecha_inicio DATE,
    fecha_fin DATE,
    cuit VARCHAR(50),
    FOREIGN KEY (id_entretenimiento) REFERENCES Entretenimiento(id_entretenimiento),
    FOREIGN KEY (cuit) REFERENCES Empresa(cuit)
);

CREATE TABLE Atraccion (
    id_atraccion INT PRIMARY KEY,
    nombre_atraccion VARCHAR(100),
    id_caracteristica INT,
    id_entretenimiento INT,
    nombre_categoria VARCHAR(100),
    FOREIGN KEY (id_caracteristica) REFERENCES Caracteristica(id_caracteristica),
    FOREIGN KEY (id_entretenimiento) REFERENCES Parque_de_Diversiones(id_entretenimiento),
    FOREIGN KEY (nombre_categoria) REFERENCES Categoria(nombre_cat)
);

-- ==============================================
-- CREATE LISTA_PRECIO TABLE
-- ==============================================
CREATE TABLE Lista_Precio (
    id_precio INT PRIMARY KEY,
    precio DECIMAL(10,2),
    fecha DATE,
    id_entretenimiento INT,
    id_atraccion INT,
    FOREIGN KEY (id_entretenimiento) REFERENCES Entretenimiento(id_entretenimiento),
    FOREIGN KEY (id_atraccion) REFERENCES Atraccion(id_atraccion)
);

-- ==============================================
-- CREATE DEPENDENT TABLES
-- ==============================================
CREATE TABLE Linea_Factura (
    id_linea INT,
    nro_factura INT,
    fecha_de_consumo DATE,
    monto DECIMAL(10,2),
    id_tarjeta INT,
    id_entretenimiento INT,
    id_atraccion INT,
    id_precio INT,
    PRIMARY KEY (id_linea, nro_factura),
    FOREIGN KEY (nro_factura) REFERENCES Factura(Nro_factura),
    FOREIGN KEY (id_tarjeta) REFERENCES Tarjeta(ID_tarjeta),
    FOREIGN KEY (id_entretenimiento) REFERENCES Entretenimiento(id_entretenimiento),
    FOREIGN KEY (id_atraccion) REFERENCES Atraccion(id_atraccion),
    FOREIGN KEY (id_precio) REFERENCES Lista_Precio(id_precio)
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
    PRIMARY KEY (ID_promocion, id_atraccion),
    FOREIGN KEY (ID_promocion) REFERENCES Promocion(ID_promocion),
    FOREIGN KEY (id_atraccion) REFERENCES Atraccion(id_atraccion)
);

CREATE TABLE Promo_Entret (
    ID_promocion INT,
    id_entretenimiento INT,
    PRIMARY KEY (ID_promocion, id_entretenimiento),
    FOREIGN KEY (ID_promocion) REFERENCES Promocion(ID_promocion),
    FOREIGN KEY (id_entretenimiento) REFERENCES Entretenimiento(id_entretenimiento)
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
INSERT INTO Pais (ID_pais, Nombre) VALUES (6, 'Ecuador');
INSERT INTO Pais (ID_pais, Nombre) VALUES (7, 'Czech Republic');
INSERT INTO Pais (ID_pais, Nombre) VALUES (8, 'Burundi');
INSERT INTO Pais (ID_pais, Nombre) VALUES (9, 'Saint Pierre and Miquelon');
INSERT INTO Pais (ID_pais, Nombre) VALUES (10, 'Bosnia and Herzegovina');
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (1, 'Utah', 2);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (2, 'West Virginia', 1);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (3, 'Ohio', 5);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (4, 'Colorado', 4);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (5, 'Pennsylvania', 4);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (6, 'Nevada', 3);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (7, 'Arizona', 2);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (8, 'Alaska', 9);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (9, 'Colorado', 2);
INSERT INTO Provincia (ID_provincia, Nombre, ID_pais) VALUES (10, 'Indiana', 10);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (1, 'New Carolyn', 7);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (2, 'Lake Debra', 1);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (3, 'Robinsonshire', 1);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (4, 'Lisatown', 2);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (5, 'Lake Roberto', 4);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (6, 'Ericmouth', 4);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (7, 'North Noahstad', 9);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (8, 'Cassandraton', 10);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (9, 'Herrerafurt', 1);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (10, 'New Kellystad', 9);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (11, 'Lake Chad', 4);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (12, 'Port Keith', 9);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (13, 'Port Jesseville', 7);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (14, 'Ramirezstad', 4);
INSERT INTO Localidad (ID_ciudad, Nombre, ID_provincia) VALUES (15, 'West Michael', 8);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (1, 'Miles Springs', '85440', 10);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (2, 'Chelsea Extension', '70511', 5);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (3, 'Frank Light', '35883', 13);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (4, 'Gabrielle Ville', '07832', 14);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (5, 'Lydia Valley', '41848', 1);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (6, 'Adams Forest', '74842', 13);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (7, 'Lewis Parks', '52357', 13);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (8, 'Thomas Dam', '32826', 3);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (9, 'Burgess Meadow', '76985', 12);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (10, 'Cox Dam', '67285', 7);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (11, 'Davis Causeway', '14872', 6);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (12, 'Courtney Turnpike', '89693', 5);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (13, 'Carlson Lights', '50520', 3);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (14, 'Rice Plaza', '02005', 4);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (15, 'Erin Plain', '98920', 13);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (16, 'Mack Junctions', '15122', 6);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (17, 'Graham Motorway', '00926', 2);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (18, 'Stanton Track', '23917', 2);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (19, 'Monica Hills', '84249', 7);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (20, 'Eric Track', '21675', 2);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (21, 'Carol Overpass', '03053', 6);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (22, 'Sarah Wells', '40807', 14);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (23, 'Brian Wells', '74865', 6);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (24, 'Christopher Oval', '09572', 10);
INSERT INTO Calle (ID_calle, Nombre, CP, ID_ciudad) VALUES (25, 'David Mountains', '72564', 5);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (1, '48963', 0, 24);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (2, '346', 7, 18);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (3, '578', 1, 13);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (4, '1331', 1, 18);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (5, '0983', 4, 21);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (6, '301', 9, 12);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (7, '031', 9, 7);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (8, '51834', 1, 2);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (9, '738', 10, 8);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (10, '99737', 4, 3);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (11, '3116', 3, 4);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (12, '6670', 6, 9);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (13, '106', 7, 21);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (14, '513', 5, 6);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (15, '38726', 5, 12);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (16, '47317', 3, 22);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (17, '108', 4, 23);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (18, '13267', 10, 21);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (19, '3602', 1, 20);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (20, '0647', 10, 6);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (21, '6872', 8, 24);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (22, '43098', 3, 6);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (23, '50097', 7, 13);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (24, '820', 4, 21);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (25, '121', 8, 8);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (26, '136', 10, 11);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (27, '93990', 0, 8);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (28, '169', 0, 11);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (29, '854', 6, 9);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (30, '53462', 1, 7);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (31, '475', 9, 23);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (32, '07991', 5, 7);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (33, '83842', 10, 16);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (34, '1354', 6, 21);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (35, '78498', 7, 5);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (36, '84124', 4, 5);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (37, '18244', 3, 24);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (38, '353', 8, 18);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (39, '487', 4, 24);
INSERT INTO Domicilio (id_dom, numero, piso, ID_calle) VALUES (40, '0164', 9, 14);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('204922644564', 'Smith and Sons', 38);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('203813163240', 'Whitney, Martin and Ramos', 26);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('204561557300', 'Patterson, Smith and Jones', 24);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('202272849424', 'Mckee, Gardner and Davenport', 15);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('203652563013', 'Tran, Jordan and Williams', 9);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('203639042338', 'Nolan-Flynn', 33);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('204559321289', 'Nolan and Sons', 32);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('204010258946', 'Wright, Garcia and Deleon', 6);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('204272528809', 'Dickson-Brady', 4);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('203079815404', 'Hancock and Sons', 28);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('204376087131', 'Johnson-Doyle', 34);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('205697020653', 'Patton-Jenkins', 5);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('202049310608', 'Shields, Cochran and Adams', 21);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('204921794983', 'Rodriguez, Brennan and Garrison', 35);
INSERT INTO Empresa (CUIT, razon_social, id_dom) VALUES ('205095476665', 'Gonzalez Group', 39);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (43866294, 'Kevin', 'Pope', '730.836.5414', 8);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (49400422, 'Tina', 'Herrera', '8147294019', 35);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (43262632, 'Samuel', 'Joyce', '569-734-0608', 18);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (45235969, 'Chad', 'Beck', '895-814-8465x64823', 22);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (49363509, 'Kaitlin', 'Thompson', '001-746-980-4436', 8);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (45411939, 'Scott', 'Lewis', '221.248.9513x4332', 19);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (42107776, 'Tracey', 'Carr', '001-517-469-3676x32016', 28);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (49675462, 'April', 'Williams', '917.827.8895', 11);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (47191766, 'Sean', 'Moore', '674.734.8734x7143', 30);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (43363836, 'Patricia', 'Miller', '(936)823-1665', 1);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (39044645, 'Jamie', 'Fisher', '001-590-996-7054x66889', 17);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (41681284, 'Joshua', 'Tucker', '(356)827-2980x6990', 33);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (40276659, 'Michelle', 'White', '965-237-5564x641', 12);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (47049949, 'Brett', 'Crane', '510.403.3092', 33);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (45945036, 'Elizabeth', 'Elliott', '674.352.9912', 7);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (47708718, 'Anthony', 'Collins', '+1-866-731-9314x91905', 20);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (39156902, 'William', 'Peterson', '(971)865-7262x84987', 33);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (47940074, 'Joseph', 'Christian', '247-937-9965', 39);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (43452832, 'Hunter', 'Lewis', '954-594-8083x136', 13);
INSERT INTO Titular (DNI, Nombre, Apellido, Celular, id_dom) VALUES (49586502, 'Thomas', 'Joseph', '701.843.6349x578', 10);
INSERT INTO Medio_de_Pago (id_medio, banco, tipo) VALUES (1, 'Pierce, Bell and Chavez', 'Débito');
INSERT INTO Medio_de_Pago (id_medio, banco, tipo) VALUES (2, 'King-Martinez', 'Crédito');
INSERT INTO Medio_de_Pago (id_medio, banco, tipo) VALUES (3, 'Stewart Ltd', 'Transferencia');
INSERT INTO Medio_de_Pago (id_medio, banco, tipo) VALUES (4, 'Tapia, Vaughn and Lee', 'Transferencia');
INSERT INTO Medio_de_Pago (id_medio, banco, tipo) VALUES (5, 'Washington, Hardy and Bray', 'Crédito');
INSERT INTO Ranking (id_ranking, peso_imp) VALUES (1, 1);
INSERT INTO Ranking (id_ranking, peso_imp) VALUES (2, 2);
INSERT INTO Ranking (id_ranking, peso_imp) VALUES (3, 3);
INSERT INTO Ranking (id_ranking, peso_imp) VALUES (4, 4);
INSERT INTO Ranking (id_ranking, peso_imp) VALUES (5, 5);
INSERT INTO Categoria (nombre_cat, min_total_anual, promedio_mensual, id_ranking) VALUES ('Bronze', 6390.5, 539.75, 1);
INSERT INTO Categoria (nombre_cat, min_total_anual, promedio_mensual, id_ranking) VALUES ('Silver', 2006.81, 426.68, 2);
INSERT INTO Categoria (nombre_cat, min_total_anual, promedio_mensual, id_ranking) VALUES ('Gold', 9867.89, 826.1, 3);
INSERT INTO Categoria (nombre_cat, min_total_anual, promedio_mensual, id_ranking) VALUES ('Platinum', 3155.07, 316.78, 4);
INSERT INTO Categoria (nombre_cat, min_total_anual, promedio_mensual, id_ranking) VALUES ('Diamond', 6106.21, 170.88, 5);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (1, '2025-07-03 20:59:06', '2025-07-30 20:59:06', 9);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (2, '2025-07-23 21:14:47', '2025-08-17 21:14:47', 13);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (3, '2025-04-01 22:52:10', '2025-04-23 22:52:10', 35);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (4, '2025-04-20 12:29:08', '2025-04-26 12:29:08', 21);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (5, '2025-05-05 16:39:12', '2025-06-02 16:39:12', 43);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (6, '2025-05-12 12:36:30', '2025-05-19 12:36:30', 39);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (7, '2025-03-31 04:08:54', '2025-04-23 04:08:54', 24);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (8, '2025-05-22 01:49:39', '2025-06-13 01:49:39', 46);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (9, '2025-04-12 20:15:29', '2025-04-27 20:15:29', 38);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (10, '2025-05-16 16:40:08', '2025-05-20 16:40:08', 20);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (11, '2025-02-20 17:56:10', '2025-02-23 17:56:10', 26);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (12, '2025-05-06 17:14:59', '2025-05-25 17:14:59', 40);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (13, '2025-03-15 13:55:09', '2025-04-03 13:55:09', 19);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (14, '2025-03-15 06:23:00', '2025-03-18 06:23:00', 50);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (15, '2025-02-05 20:07:06', '2025-02-13 20:07:06', 9);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (16, '2025-02-04 14:06:34', '2025-03-04 14:06:34', 26);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (17, '2025-05-17 10:50:22', '2025-06-03 10:50:22', 20);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (18, '2025-04-22 17:27:19', '2025-05-14 17:27:19', 36);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (19, '2025-03-13 12:30:18', '2025-03-31 12:30:18', 13);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (20, '2025-07-23 20:41:16', '2025-07-31 20:41:16', 35);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (21, '2025-06-17 07:39:37', '2025-06-24 07:39:37', 11);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (22, '2025-02-21 22:05:35', '2025-03-15 22:05:35', 32);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (23, '2025-03-09 09:09:39', '2025-03-23 09:09:39', 31);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (24, '2025-07-10 11:19:59', '2025-08-07 11:19:59', 8);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (25, '2025-03-29 05:07:02', '2025-03-31 05:07:02', 30);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (26, '2025-06-04 03:32:53', '2025-06-30 03:32:53', 11);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (27, '2025-05-24 22:58:11', '2025-05-31 22:58:11', 17);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (28, '2025-06-23 12:44:00', '2025-07-08 12:44:00', 13);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (29, '2025-05-21 03:48:17', '2025-05-27 03:48:17', 22);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (30, '2025-04-25 19:11:49', '2025-05-03 19:11:49', 9);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (31, '2025-03-27 23:25:58', '2025-04-22 23:25:58', 40);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (32, '2025-03-23 00:38:04', '2025-03-25 00:38:04', 46);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (33, '2025-07-01 18:22:45', '2025-07-28 18:22:45', 5);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (34, '2025-02-23 03:41:04', '2025-03-25 03:41:04', 20);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (35, '2025-02-23 16:31:20', '2025-03-09 16:31:20', 36);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (36, '2025-06-08 19:25:55', '2025-06-15 19:25:55', 30);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (37, '2025-05-03 11:42:18', '2025-05-09 11:42:18', 29);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (38, '2025-02-04 09:14:52', '2025-02-17 09:14:52', 21);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (39, '2025-07-10 01:06:48', '2025-07-20 01:06:48', 32);
INSERT INTO Promocion (id_promocion, fecha_inicio, fecha_fin, descuento) VALUES (40, '2025-07-24 05:25:46', '2025-07-29 05:25:46', 17);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (1, 137, 8);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (2, 107, 14);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (3, 194, 13);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (4, 107, 16);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (5, 140, 5);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (6, 106, 14);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (7, 161, 13);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (8, 167, 7);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (9, 107, 13);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (10, 110, 18);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (11, 123, 6);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (12, 176, 6);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (13, 186, 18);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (14, 130, 11);
INSERT INTO Caracteristica (id_caracteristica, altura_min, edad_min) VALUES (15, 115, 14);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (1, 'https://picsum.photos/109/310', True, 48.42, 49675462);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (2, 'https://picsum.photos/622/174', True, 163.82, 43452832);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (3, 'https://placekitten.com/242/852', True, 96.07, 49586502);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (4, 'https://dummyimage.com/462x779', True, 178.01, 49400422);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (5, 'https://placekitten.com/906/608', False, 279.76, 49586502);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (6, 'https://placekitten.com/878/625', True, 100.3, 43262632);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (7, 'https://picsum.photos/123/203', True, 639.42, 47049949);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (8, 'https://placekitten.com/432/541', False, 89.32, 43452832);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (9, 'https://picsum.photos/166/321', False, 437.85, 43452832);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (10, 'https://picsum.photos/355/153', True, 453.73, 39156902);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (11, 'https://dummyimage.com/5x836', True, 23.48, 39044645);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (12, 'https://picsum.photos/962/596', True, 170.5, 47191766);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (13, 'https://placekitten.com/474/590', True, 1263.96, 42107776);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (14, 'https://picsum.photos/579/929', False, 98.25, 39044645);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (15, 'https://placekitten.com/478/541', False, 0.0, 49675462);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (16, 'https://picsum.photos/405/870', False, 48.61, 47191766);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (17, 'https://dummyimage.com/460x305', True, 512.37, 40276659);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (18, 'https://picsum.photos/291/146', True, 199.38, 49363509);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (19, 'https://placekitten.com/339/629', True, 0.0, 43363836);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (20, 'https://picsum.photos/591/899', True, 39.33, 45945036);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (21, 'https://placekitten.com/959/622', False, 0.0, 39044645);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (22, 'https://placekitten.com/824/557', False, 368.01, 43262632);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (23, 'https://picsum.photos/1011/896', True, 344.6, 43866294);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (24, 'https://placekitten.com/81/884', False, 0.0, 45945036);
INSERT INTO Tarjeta (id_tarjeta, foto, estado, Total_gastado, DNI) VALUES (25, 'https://picsum.photos/660/512', False, 150.15, 49586502);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (1, '2025-02-14 10:51:54', '2025-04-20 00:00:00', 0.0, True, 49400422, 5);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (2, '2025-04-22 16:37:19', '2025-05-06 00:00:00', 23.48, True, 39044645, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (3, '2025-01-05 00:40:50', '2025-02-26 00:00:00', 101.3, True, 49586502, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (4, '2025-04-22 21:30:20', '2025-04-22 00:00:00', 117.88, False, 49586502, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (5, '2025-02-04 00:26:52', '2025-05-06 00:00:00', 454.81, False, 42107776, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (6, '2025-04-11 18:32:48', '2025-05-12 00:00:00', 106.4, False, 43452832, 5);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (7, '2025-03-27 20:56:18', '2025-04-23 00:00:00', 183.96, True, 40276659, 5);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (8, '2025-02-05 05:48:02', '2025-04-30 00:00:00', 234.57, False, 47049949, 5);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (9, '2025-05-04 06:18:40', '2025-05-13 00:00:00', 22.37, True, 49586502, 1);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (10, '2025-04-06 11:36:29', '2025-04-10 00:00:00', 227.79, True, 42107776, 1);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (11, '2025-04-02 06:24:25', '2025-04-18 00:00:00', 0.0, True, 45945036, 5);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (12, '2025-03-21 07:02:24', '2025-04-22 00:00:00', 315.22, True, 42107776, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (13, '2025-03-04 08:14:23', '2025-05-08 00:00:00', 39.33, True, 45945036, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (14, '2025-01-21 07:28:14', '2025-02-21 00:00:00', 192.77, False, 47049949, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (15, '2025-03-06 00:59:47', '2025-04-14 00:00:00', 122.08, True, 42107776, 1);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (16, '2025-04-07 05:03:10', '2025-04-20 00:00:00', 53.58, False, 47049949, 4);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (17, '2025-05-09 15:51:47', '2025-05-14 00:00:00', 344.6, False, 43866294, 1);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (18, '2025-03-19 18:14:33', '2025-05-11 00:00:00', 244.31, False, 39156902, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (19, '2025-01-08 03:01:15', '2025-04-06 00:00:00', 259.19, False, 43262632, 4);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (20, '2025-01-18 02:23:18', '2025-03-20 00:00:00', 98.25, True, 39044645, 1);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (21, '2025-02-19 00:15:50', '2025-03-22 00:00:00', 178.01, True, 49400422, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (22, '2025-01-23 12:14:01', '2025-04-11 00:00:00', 348.33, True, 43452832, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (23, '2025-04-10 22:11:32', '2025-04-10 00:00:00', 219.11, True, 47191766, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (24, '2025-05-08 16:55:10', '2025-05-14 00:00:00', 144.06, True, 42107776, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (25, '2025-03-31 16:57:56', '2025-04-20 00:00:00', 61.46, True, 49586502, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (26, '2025-01-11 12:36:33', '2025-02-16 00:00:00', 158.5, True, 47049949, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (27, '2025-04-11 16:06:09', '2025-04-28 00:00:00', 48.42, False, 49675462, 5);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (28, '2025-05-01 21:41:02', '2025-05-13 00:00:00', 328.41, True, 40276659, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (29, '2025-05-02 10:36:57', '2025-05-12 00:00:00', 141.51, True, 43452832, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (30, '2025-01-11 00:31:41', '2025-02-19 00:00:00', 222.97, True, 49586502, 4);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (31, '2025-02-21 20:34:20', '2025-04-15 00:00:00', 75.49, False, 43262632, 3);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (32, '2025-01-26 10:33:57', '2025-03-22 00:00:00', 209.42, False, 39156902, 2);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (33, '2025-03-27 01:46:08', '2025-05-13 00:00:00', 133.63, False, 43262632, 1);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (34, '2025-01-24 13:53:11', '2025-01-29 00:00:00', 94.75, False, 43452832, 1);
INSERT INTO Factura (Nro_factura, fecha_emision, fecha_vencimiento, importe_total, pagado, DNI, id_medio_pago) VALUES (35, '2025-05-03 08:06:59', '2025-05-10 00:00:00', 199.38, False, 49363509, 2);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (1, 'Parque Lauren', 'Parque', 'Silver', 20);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (2, 'West Andrea Fest', 'Evento', 'Silver', 2);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (3, 'Parque Andrea', 'Parque', 'Gold', 22);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (4, 'East Victoriaville Fest', 'Evento', 'Gold', 18);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (5, 'Parque Steven', 'Parque', 'Gold', 35);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (6, 'Lake Marilynfort Fest', 'Evento', 'Gold', 8);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (7, 'Williamview Fest', 'Evento', 'Gold', 38);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (8, 'Davenportfort Fest', 'Evento', 'Diamond', 7);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (9, 'Parque John', 'Parque', 'Gold', 23);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (10, 'Parque Andrea', 'Parque', 'Diamond', 39);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (11, 'Leehaven Fest', 'Evento', 'Diamond', 25);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (12, 'Port Chad Fest', 'Evento', 'Bronze', 17);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (13, 'Parque Kendra', 'Parque', 'Diamond', 1);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (14, 'Morganhaven Fest', 'Evento', 'Platinum', 24);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (15, 'Loriport Fest', 'Evento', 'Diamond', 22);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (16, 'Parque Jessica', 'Parque', 'Gold', 8);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (17, 'Parque Mary', 'Parque', 'Gold', 27);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (18, 'Parque Bethany', 'Parque', 'Diamond', 19);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (19, 'Grimesmouth Fest', 'Evento', 'Platinum', 13);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (20, 'Parque Amanda', 'Parque', 'Diamond', 12);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (21, 'Parque Michael', 'Parque', 'Diamond', 26);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (22, 'Gibsonmouth Fest', 'Evento', 'Gold', 20);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (23, 'Lake John Fest', 'Evento', 'Diamond', 28);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (24, 'Parque Patrick', 'Parque', 'Platinum', 30);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (25, 'Parque Melissa', 'Parque', 'Diamond', 14);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (26, 'Parque Robert', 'Parque', 'Bronze', 11);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (27, 'Parque Louis', 'Parque', 'Diamond', 33);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (28, 'Parque Thomas', 'Parque', 'Silver', 6);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (29, 'Parque Robin', 'Parque', 'Silver', 15);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (30, 'Hughesberg Fest', 'Evento', 'Bronze', 2);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (31, 'Hannaberg Fest', 'Evento', 'Diamond', 31);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (32, 'Mollymouth Fest', 'Evento', 'Platinum', 30);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (33, 'New Reneetown Fest', 'Evento', 'Platinum', 25);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (34, 'Parque Jennifer', 'Parque', 'Silver', 16);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (35, 'Pittsberg Fest', 'Evento', 'Platinum', 7);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (36, 'South Kimberlyview Fest', 'Evento', 'Diamond', 12);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (37, 'Parque Matthew', 'Parque', 'Diamond', 4);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (38, 'Santosmouth Fest', 'Evento', 'Platinum', 8);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (39, 'Finleyfort Fest', 'Evento', 'Diamond', 30);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (40, 'Parque Monique', 'Parque', 'Diamond', 29);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (41, 'Parque Barry', 'Parque', 'Platinum', 36);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (42, 'East Crystalport Fest', 'Evento', 'Platinum', 31);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (43, 'Parque Wendy', 'Parque', 'Gold', 16);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (44, 'Parque Julie', 'Parque', 'Gold', 16);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (45, 'Parque Ryan', 'Parque', 'Gold', 5);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (46, 'Port Cynthiaville Fest', 'Evento', 'Gold', 18);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (47, 'Parque Scott', 'Parque', 'Bronze', 35);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (48, 'Rebeccaton Fest', 'Evento', 'Silver', 10);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (49, 'Parque Mark', 'Parque', 'Silver', 10);
INSERT INTO Entretenimiento (id_entretenimiento, nombre, tipo, nombre_categoria, id_domicilio) VALUES (50, 'West Michaelchester Fest', 'Evento', 'Platinum', 27);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (1);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (3);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (5);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (9);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (10);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (13);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (16);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (17);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (18);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (20);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (21);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (24);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (25);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (26);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (27);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (28);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (29);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (34);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (37);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (40);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (41);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (43);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (44);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (45);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (47);
INSERT INTO Parque_de_Diversiones (id_entretenimiento) VALUES (49);
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (2, '2025-04-01 06:24:15', '2025-10-07 00:00:00', '204272528809');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (4, '2025-07-02 03:24:52', '2025-12-09 00:00:00', '204559321289');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (6, '2025-05-17 21:24:57', '2026-02-05 00:00:00', '202272849424');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (7, '2025-04-18 23:07:33', '2025-08-28 00:00:00', '204559321289');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (8, '2025-02-25 23:52:56', '2025-04-27 00:00:00', '204921794983');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (11, '2025-07-06 08:26:15', '2025-12-01 00:00:00', '204010258946');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (12, '2025-05-21 08:03:34', '2026-02-10 00:00:00', '203639042338');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (14, '2025-04-15 18:20:53', '2026-05-06 00:00:00', '202049310608');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (15, '2025-07-02 05:42:33', '2025-08-26 00:00:00', '204921794983');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (19, '2025-04-29 02:04:35', '2025-10-25 00:00:00', '204272528809');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (22, '2025-08-01 20:51:03', '2025-11-07 00:00:00', '202049310608');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (23, '2025-05-18 05:45:13', '2025-08-25 00:00:00', '204010258946');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (30, '2025-06-27 11:42:10', '2025-06-30 00:00:00', '203652563013');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (31, '2025-06-15 08:14:14', '2025-10-04 00:00:00', '204010258946');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (32, '2025-06-04 13:53:44', '2026-01-02 00:00:00', '204559321289');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (33, '2025-04-04 16:13:11', '2025-05-31 00:00:00', '204376087131');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (35, '2025-06-06 18:36:35', '2025-10-18 00:00:00', '205697020653');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (36, '2025-06-05 02:16:57', '2025-09-29 00:00:00', '204921794983');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (38, '2025-07-23 01:40:12', '2026-01-03 00:00:00', '205095476665');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (39, '2025-06-20 01:05:38', '2025-09-25 00:00:00', '203079815404');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (42, '2025-06-26 17:00:33', '2025-10-21 00:00:00', '204922644564');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (46, '2025-04-19 16:25:06', '2026-02-11 00:00:00', '203079815404');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (48, '2025-04-27 19:54:46', '2025-06-07 00:00:00', '203813163240');
INSERT INTO Evento (id_entretenimiento, fecha_inicio, fecha_fin, cuit) VALUES (50, '2025-05-01 01:27:31', '2025-09-26 00:00:00', '204561557300');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (1, 'Explosivo Viaje', 5, 27, 'Platinum');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (2, 'Misterioso Templo', 6, 21, 'Gold');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (3, 'Encantado Caída', 13, 47, 'Platinum');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (4, 'Vertiginoso Templo', 1, 18, 'Diamond');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (5, 'Intergaláctico Tren', 11, 3, 'Bronze');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (6, 'Mágico Viaje', 4, 47, 'Silver');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (7, 'Fantástico Dragón', 4, 1, 'Silver');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (8, 'Vertiginoso Laberinto', 4, 28, 'Platinum');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (9, 'Salvaje Aventura', 3, 44, 'Diamond');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (10, 'Vertiginoso Dragón', 5, 40, 'Bronze');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (11, 'Mágico Caída', 10, 37, 'Platinum');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (12, 'Misterioso Tornado', 10, 25, 'Silver');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (13, 'Salvaje Laberinto', 13, 9, 'Bronze');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (14, 'Fantástico Viaje', 6, 49, 'Diamond');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (15, 'Intergaláctico Tornado', 9, 26, 'Gold');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (16, 'Encantado Templo', 2, 1, 'Platinum');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (17, 'Peligroso Dragón', 7, 24, 'Silver');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (18, 'Legendario Caída', 10, 45, 'Diamond');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (19, 'Peligroso Templo', 7, 47, 'Diamond');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (20, 'Intergaláctico Tren', 14, 18, 'Bronze');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (21, 'Peligroso Tren', 13, 18, 'Platinum');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (22, 'Fantástico Remolino', 6, 37, 'Bronze');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (23, 'Intergaláctico Dragón', 8, 28, 'Silver');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (24, 'Salvaje Aventura', 5, 24, 'Diamond');
INSERT INTO Atraccion (id_atraccion, nombre_atraccion, id_caracteristica, id_entretenimiento, nombre_categoria) VALUES (25, 'Salvaje Desafío', 1, 44, 'Diamond');
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (1, 125.63, '2024-11-27 21:38:49', 1, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (2, 101.9, '2023-02-04 05:56:05', 2, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (3, 141.61, '2024-11-26 21:05:03', 3, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (4, 149.69, '2022-07-22 05:50:39', 4, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (5, 113.48, '2022-07-22 06:00:03', 5, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (6, 146.91, '2020-03-25 03:56:05', 6, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (7, 84.8, '2023-05-25 17:24:55', 7, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (8, 82.11, '2022-05-06 18:44:27', 8, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (9, 135.77, '2020-02-06 03:49:41', 9, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (10, 91.16, '2024-11-09 06:43:33', 10, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (11, 78.82, '2020-06-14 09:00:14', 11, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (12, 131.36, '2025-03-17 00:56:43', 12, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (13, 53.67, '2024-03-26 06:40:15', 13, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (14, 81.45, '2022-06-19 04:10:57', 14, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (15, 61.59, '2022-01-09 22:52:15', 15, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (16, 90.42, '2025-03-18 02:02:48', 16, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (17, 132.49, '2022-12-31 14:57:16', 17, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (18, 115.77, '2021-11-29 10:09:42', 18, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (19, 96.2, '2021-08-15 17:16:07', 19, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (20, 68.76, '2025-04-25 01:00:03', 20, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (21, 112.26, '2022-03-05 16:05:18', 21, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (22, 112.54, '2021-03-25 22:59:56', 22, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (23, 55.16, '2025-05-14 21:34:27', 23, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (24, 104.92, '2020-11-27 21:04:03', 24, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (25, 78.8, '2025-06-01 10:40:03', 25, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (26, 119.83, '2020-05-06 11:33:37', 26, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (27, 52.89, '2022-09-07 19:42:18', 27, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (28, 110.89, '2023-10-09 14:09:35', 28, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (29, 120.98, '2020-04-23 15:50:22', 29, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (30, 105.08, '2024-12-23 16:09:18', 30, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (31, 90.8, '2023-02-15 14:01:31', 31, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (32, 149.23, '2021-03-14 06:46:28', 32, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (33, 61.35, '2020-10-11 00:49:53', 33, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (34, 114.77, '2022-07-10 21:01:49', 34, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (35, 99.84, '2022-11-04 01:56:37', 35, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (36, 79.19, '2023-08-06 22:09:22', 36, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (37, 77.34, '2021-07-26 16:40:23', 37, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (38, 98.25, '2021-10-01 20:20:43', 38, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (39, 74.37, '2021-03-04 14:32:55', 39, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (40, 64.46, '2024-08-09 21:09:26', 40, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (41, 142.19, '2023-02-27 16:18:53', 41, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (42, 124.63, '2024-07-12 07:13:19', 42, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (43, 136.4, '2024-04-17 00:31:45', 43, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (44, 127.27, '2022-05-24 17:06:43', 44, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (45, 91.49, '2021-06-25 05:19:17', 45, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (46, 128.77, '2022-03-18 09:04:40', 46, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (47, 132.05, '2024-02-16 01:10:41', 47, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (48, 122.61, '2022-08-01 23:20:29', 48, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (49, 108.69, '2022-12-10 08:26:23', 49, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (50, 98.96, '2020-12-28 19:40:33', 50, NULL);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (51, 25.09, '2024-01-11 01:19:08', NULL, 1);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (52, 20.53, '2020-09-08 22:43:38', NULL, 2);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (53, 39.33, '2021-03-26 07:36:13', NULL, 3);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (54, 25.49, '2021-12-12 23:03:02', NULL, 4);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (55, 44.13, '2023-06-11 17:08:55', NULL, 5);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (56, 15.75, '2024-10-10 12:14:27', NULL, 6);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (57, 15.51, '2023-03-07 10:09:53', NULL, 7);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (58, 23.48, '2020-10-18 13:28:12', NULL, 8);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (59, 38.51, '2023-06-02 21:36:42', NULL, 9);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (60, 46.1, '2020-02-26 05:51:01', NULL, 10);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (61, 22.37, '2022-04-23 15:27:39', NULL, 11);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (62, 40.66, '2024-08-15 01:43:53', NULL, 12);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (63, 49.14, '2021-02-03 23:26:38', NULL, 13);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (64, 48.42, '2023-11-18 23:18:15', NULL, 14);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (65, 27.6, '2023-03-10 03:44:19', NULL, 15);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (66, 19.94, '2022-03-29 12:10:17', NULL, 16);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (67, 44.34, '2025-01-05 03:57:35', NULL, 17);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (68, 9.49, '2023-04-28 19:19:12', NULL, 18);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (69, 25.56, '2023-03-24 03:04:56', NULL, 19);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (70, 11.49, '2020-12-30 14:52:15', NULL, 20);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (71, 34.47, '2022-01-01 11:01:29', NULL, 21);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (72, 8.37, '2024-01-30 19:51:48', NULL, 22);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (73, 48.61, '2020-03-29 17:58:22', NULL, 23);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (74, 33.05, '2025-04-21 20:45:44', NULL, 24);
INSERT INTO Lista_Precio (id_precio, precio, fecha, id_entretenimiento, id_atraccion) VALUES (75, 34.24, '2024-11-07 05:34:06', NULL, 25);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (13, 6);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (16, 47);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (27, 32);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (36, 49);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (16, 45);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (31, 42);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (32, 29);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (2, 6);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (19, 15);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (26, 45);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (16, 20);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (38, 24);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (31, 36);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (34, 23);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (28, 48);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (36, 22);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (23, 45);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (30, 18);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (20, 17);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (15, 8);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (13, 21);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (8, 48);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (35, 49);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (12, 13);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (14, 48);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (31, 18);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (38, 49);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (34, 39);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (19, 7);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (13, 19);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (15, 24);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (12, 20);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (1, 46);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (35, 9);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (18, 3);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (4, 36);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (19, 45);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (9, 41);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (32, 7);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (1, 37);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (19, 31);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (31, 29);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (22, 12);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (4, 17);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (31, 8);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (5, 26);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (32, 5);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (37, 41);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (4, 10);
INSERT INTO Promo_Entret (id_promocion, id_entretenimiento) VALUES (10, 37);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (20, 3);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (16, 4);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (36, 25);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (27, 20);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (39, 20);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (15, 25);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (34, 13);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (29, 15);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (20, 19);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (28, 10);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (37, 20);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (4, 20);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (7, 25);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (14, 21);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (14, 9);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (6, 6);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (16, 6);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (36, 3);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (11, 1);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (27, 15);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (39, 16);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (19, 2);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (15, 10);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (19, 23);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (30, 3);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (15, 9);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (38, 22);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (13, 14);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (8, 18);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (15, 21);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (10, 9);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (10, 3);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (4, 6);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (20, 20);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (37, 10);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (29, 4);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (30, 23);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (20, 23);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (26, 9);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (33, 18);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (32, 15);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (6, 20);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (3, 14);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (21, 20);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (17, 1);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (6, 8);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (37, 19);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (2, 25);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (18, 19);
INSERT INTO Promocion_Atraccion (id_promocion, id_atraccion) VALUES (3, 25);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (1, '2022-04-23 15:27:39', 22.37, 22, 9, 37, 11, 61);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (2, '2025-03-18 02:02:48', 90.42, 35, 18, 16, NULL, 16);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (3, '2021-12-12 23:03:02', 25.49, 15, 13, 18, 4, 54);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (4, '2024-01-11 01:19:08', 25.09, 29, 2, 27, 1, 51);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (5, '2024-08-15 01:43:53', 40.66, 21, 4, 25, 12, 62);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (6, '2022-07-10 21:01:49', 114.77, 28, 17, 34, NULL, 34);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (7, '2020-03-25 03:56:05', 119.0, 12, 13, 6, NULL, 6);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (8, '2022-01-09 22:52:15', 53.58, 16, 7, 15, NULL, 15);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (9, '2024-01-30 19:51:48', 8.37, 17, 23, 37, 22, 72);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (10, '2022-07-22 06:00:03', 61.28, 30, 5, 5, NULL, 5);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (11, '2020-03-29 17:58:22', 48.61, 23, 16, 28, 23, 73);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (12, '2025-06-01 10:40:03', 78.8, 30, 5, 25, NULL, 25);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (13, '2023-03-24 03:04:56', 25.56, 7, 17, 47, 19, 69);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (14, '2024-04-17 00:31:45', 136.4, 19, 22, 43, NULL, 43);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (15, '2021-03-04 14:32:55', 59.5, 18, 10, 39, NULL, 39);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (16, '2020-10-18 13:28:12', 23.48, 19, 6, 28, 8, 58);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (17, '2023-02-27 16:18:53', 88.16, 17, 23, 41, NULL, 41);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (18, '2021-10-01 20:20:43', 98.25, 20, 14, 38, NULL, 38);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (19, '2022-04-23 15:27:39', 22.37, 9, 3, 37, 11, 61);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (20, '2022-11-04 01:56:37', 99.84, 12, 13, 35, NULL, 35);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (21, '2024-10-10 12:14:27', 15.75, 34, 9, 47, 6, 56);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (22, '2021-12-12 23:03:02', 25.49, 31, 22, 18, 4, 54);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (23, '2022-05-24 17:06:43', 127.27, 5, 13, 44, NULL, 44);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (24, '2024-01-11 01:19:08', 25.09, 24, 13, 27, 1, 51);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (25, '2024-08-15 01:43:53', 40.66, 35, 18, 25, 12, 62);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (26, '2021-12-12 23:03:02', 25.49, 25, 25, 18, 4, 54);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (27, '2020-12-30 14:52:15', 11.49, 31, 6, 18, 20, 70);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (28, '2022-01-01 11:01:29', 34.47, 5, 13, 18, 21, 71);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (29, '2024-11-26 21:05:03', 90.63, 8, 7, 3, NULL, 3);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (30, '2025-03-18 02:02:48', 90.42, 32, 10, 16, NULL, 16);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (31, '2024-01-30 19:51:48', 8.37, 25, 5, 37, 22, 72);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (32, '2021-03-14 06:46:28', 123.86, 10, 13, 32, NULL, 32);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (33, '2023-03-07 10:09:53', 15.51, 18, 10, 1, 7, 57);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (34, '2021-12-12 23:03:02', 25.49, 29, 2, 18, 4, 54);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (35, '2020-05-06 11:33:37', 68.3, 35, 18, 26, NULL, 26);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (36, '2021-03-26 07:36:13', 39.33, 13, 20, 47, 3, 53);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (37, '2020-10-18 13:28:12', 23.48, 2, 11, 28, 8, 58);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (38, '2021-10-01 20:20:43', 98.25, 14, 7, 38, NULL, 38);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (39, '2021-03-04 14:32:55', 59.5, 15, 13, 39, NULL, 39);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (40, '2022-11-04 01:56:37', 99.84, 18, 10, 35, NULL, 35);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (41, '2020-02-06 03:49:41', 86.89, 12, 13, 9, NULL, 9);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (42, '2024-01-11 01:19:08', 25.09, 23, 12, 27, 1, 51);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (43, '2022-08-01 23:20:29', 61.3, 17, 23, 48, NULL, 48);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (44, '2023-02-15 14:01:31', 79.0, 34, 2, 31, NULL, 31);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (45, '2025-01-05 03:57:35', 44.34, 24, 13, 24, 17, 67);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (46, '2023-03-10 03:44:19', 27.6, 3, 25, 26, 15, 65);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (47, '2023-11-18 23:18:15', 48.42, 4, 5, 49, 14, 64);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (48, '2020-03-25 03:56:05', 119.0, 32, 10, 6, NULL, 6);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (49, '2021-11-29 10:09:42', 69.46, 10, 13, 18, NULL, 18);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (50, '2023-03-10 03:44:19', 27.6, 25, 25, 26, 15, 65);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (51, '2023-10-09 14:09:35', 110.89, 7, 17, 28, NULL, 28);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (52, '2023-03-10 03:44:19', 27.6, 15, 13, 26, 15, 65);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (53, '2023-11-18 23:18:15', 48.42, 27, 1, 49, 14, 64);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (54, '2022-05-24 17:06:43', 127.27, 17, 23, 44, NULL, 44);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (55, '2020-03-25 03:56:05', 119.0, 5, 13, 6, NULL, 6);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (56, '2023-08-06 22:09:22', 47.51, 7, 17, 36, NULL, 36);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (57, '2022-09-07 19:42:18', 52.89, 22, 9, 27, NULL, 27);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (58, '2020-12-30 14:52:15', 11.49, 28, 17, 18, 20, 70);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (59, '2024-11-09 06:43:33', 72.02, 23, 12, 10, NULL, 10);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (60, '2023-04-28 19:19:12', 9.49, 15, 13, 45, 18, 68);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (61, '2023-10-09 14:09:35', 110.89, 8, 7, 28, NULL, 28);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (62, '2021-11-29 10:09:42', 69.46, 18, 10, 18, NULL, 18);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (63, '2025-03-17 00:56:43', 89.32, 22, 8, 12, NULL, 12);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (64, '2022-08-01 23:20:29', 61.3, 26, 7, 48, NULL, 48);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (65, '2025-06-01 10:40:03', 78.8, 6, 9, 25, NULL, 25);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (66, '2020-11-27 21:04:03', 82.89, 30, 5, 24, NULL, 24);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (67, '2024-11-09 06:43:33', 72.02, 21, 4, 10, NULL, 10);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (68, '2021-11-29 10:09:42', 69.46, 4, 25, 18, NULL, 18);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (69, '2023-11-18 23:18:15', 48.42, 28, 17, 49, 14, 64);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (70, '2023-11-18 23:18:15', 48.42, 14, 7, 49, 14, 64);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (71, '2020-09-08 22:43:38', 20.53, 19, 22, 21, 2, 52);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (72, '2022-06-19 04:10:57', 81.45, 26, 7, 14, NULL, 14);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (73, '2020-02-26 05:51:01', 46.1, 14, 7, 40, 10, 60);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (74, '2025-04-21 20:45:44', 33.05, 8, 7, 24, 24, 74);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (75, '2023-04-28 19:19:12', 9.49, 12, 13, 45, 18, 68);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (76, '2020-05-06 11:33:37', 68.3, 33, 22, 26, NULL, 26);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (77, '2021-03-26 07:36:13', 39.33, 28, 17, 47, 3, 53);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (78, '2020-02-26 05:51:01', 46.1, 28, 17, 40, 10, 60);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (79, '2024-10-10 12:14:27', 15.75, 26, 7, 47, 6, 56);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (80, '2021-12-12 23:03:02', 25.49, 24, 13, 18, 4, 54);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (81, '2020-05-06 11:33:37', 68.3, 28, 17, 26, NULL, 26);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (82, '2024-11-07 05:34:06', 34.24, 22, 2, 44, 25, 75);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (83, '2020-12-28 19:40:33', 98.96, 5, 13, 50, NULL, 50);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (84, '2023-05-25 17:24:55', 45.79, 23, 12, 7, NULL, 7);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (85, '2021-03-04 14:32:55', 59.5, 17, 23, 39, NULL, 39);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (86, '2023-03-10 03:44:19', 27.6, 5, 13, 26, 15, 65);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (87, '2020-04-23 15:50:22', 65.33, 21, 4, 29, NULL, 29);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (88, '2023-06-02 21:36:42', 38.51, 31, 22, 44, 9, 59);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (89, '2023-03-10 03:44:19', 27.6, 23, 12, 26, 15, 65);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (90, '2020-02-26 05:51:01', 46.1, 3, 3, 40, 10, 60);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (91, '2023-03-10 03:44:19', 27.6, 6, 9, 26, 15, 65);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (92, '2022-03-05 16:05:18', 90.93, 29, 9, 21, NULL, 21);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (93, '2020-04-23 15:50:22', 65.33, 33, 6, 29, NULL, 29);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (94, '2020-10-11 00:49:53', 61.35, 22, 9, 33, NULL, 33);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (95, '2023-03-10 03:44:19', 27.6, 3, 3, 26, 15, 65);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (96, '2021-02-03 23:26:38', 49.14, 24, 13, 9, 13, 63);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (97, '2023-02-27 16:18:53', 88.16, 22, 9, 41, NULL, 41);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (98, '2023-08-06 22:09:22', 47.51, 5, 13, 36, NULL, 36);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (99, '2021-03-25 22:59:56', 78.78, 19, 22, 22, NULL, 22);
INSERT INTO Linea_Factura (id_linea, fecha_de_consumo, monto, nro_factura, id_tarjeta, id_entretenimiento, id_atraccion, id_precio) VALUES (100, '2022-01-01 11:01:29', 34.47, 10, 13, 18, 21, 71);
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (959715, '2022-10-16 00:00:00', 5, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (232120, '2025-03-10 00:00:00', 23, 'Bronze');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (666269, '2020-07-15 00:00:00', 10, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (953562, '2023-12-13 00:00:00', 13, 'Gold');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (680776, '2022-07-27 00:00:00', 5, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (122343, '2023-06-22 00:00:00', 3, 'Platinum');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (47549, '2021-03-10 00:00:00', 17, 'Gold');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (319149, '2020-04-25 00:00:00', 1, 'Gold');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (121761, '2024-03-10 00:00:00', 10, 'Silver');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (246205, '2020-10-28 00:00:00', 7, 'Gold');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (142254, '2024-07-28 00:00:00', 25, 'Platinum');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (475679, '2023-04-22 00:00:00', 7, 'Silver');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (703055, '2023-02-26 00:00:00', 5, 'Silver');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (439486, '2024-08-05 00:00:00', 3, 'Gold');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (778325, '2024-12-29 00:00:00', 4, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (928423, '2021-04-25 00:00:00', 25, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (686735, '2023-07-13 00:00:00', 24, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (874190, '2020-11-03 00:00:00', 2, 'Gold');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (645558, '2024-02-29 00:00:00', 25, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (984668, '2023-06-21 00:00:00', 5, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (34305, '2022-05-19 00:00:00', 13, 'Silver');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (227823, '2023-02-25 00:00:00', 6, 'Silver');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (466297, '2023-10-09 00:00:00', 23, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (897004, '2022-01-03 00:00:00', 6, 'Platinum');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (104180, '2023-01-31 00:00:00', 2, 'Platinum');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (570913, '2023-02-15 00:00:00', 12, 'Silver');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (63491, '2023-01-19 00:00:00', 15, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (289282, '2023-05-21 00:00:00', 10, 'Platinum');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (128093, '2021-08-12 00:00:00', 8, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (96126, '2023-11-13 00:00:00', 8, 'Gold');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (672875, '2021-10-20 00:00:00', 16, 'Silver');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (22394, '2025-01-29 00:00:00', 12, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (825013, '2020-06-06 00:00:00', 15, 'Platinum');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (255400, '2022-11-02 00:00:00', 25, 'Gold');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (825206, '2021-01-26 00:00:00', 25, 'Platinum');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (215173, '2024-10-20 00:00:00', 17, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (870127, '2020-08-01 00:00:00', 14, 'Silver');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (217220, '2024-09-17 00:00:00', 7, 'Diamond');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (226441, '2024-12-26 00:00:00', 5, 'Gold');
INSERT INTO HistorialCategoria (id_historial, fecha_de_inicio, ID_tarjeta, nombre_cat) VALUES (344519, '2021-12-24 00:00:00', 2, 'Platinum');
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Gold', 36);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Bronze', 34);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Bronze', 19);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Bronze', 11);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Gold', 29);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Diamond', 10);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Platinum', 6);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Silver', 29);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Gold', 2);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Platinum', 4);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Platinum', 33);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Gold', 16);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Gold', 15);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Bronze', 21);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Bronze', 22);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Silver', 9);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Platinum', 9);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Platinum', 29);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Diamond', 1);
INSERT INTO cat_promo (nombre_cat, id_promocion) VALUES ('Bronze', 2);
