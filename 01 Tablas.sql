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
