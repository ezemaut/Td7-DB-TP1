-- BORRAR AL TERMINAR
DROP TABLE IF EXISTS Promocion_Entretenimiento CASCADE;
DROP TABLE IF EXISTS Promocion_Atraccion CASCADE;
DROP TABLE IF EXISTS Promo_Entret CASCADE;
DROP TABLE IF EXISTS Promocion CASCADE;
DROP TABLE IF EXISTS Atraccion CASCADE;
DROP TABLE IF EXISTS Empresa CASCADE;
DROP TABLE IF EXISTS Evento CASCADE;
DROP TABLE IF EXISTS Parque_de_Diversiones CASCADE;
-- Must appear before dropping Linea_Factura or Entretenimiento
ALTER TABLE Linea_Factura DROP CONSTRAINT IF EXISTS linea_factura_id_entretenimiento_fkey;
DROP TABLE IF EXISTS Entretenimiento CASCADE;
DROP TABLE IF EXISTS Medio_de_Pago CASCADE;
DROP TABLE IF EXISTS Linea_Factura CASCADE;
DROP TABLE IF EXISTS Factura CASCADE;
DROP TABLE IF EXISTS HistorialCategoria CASCADE;
DROP TABLE IF EXISTS Tarjeta CASCADE;
DROP TABLE IF EXISTS Categoria CASCADE;
DROP TABLE IF EXISTS Ranking CASCADE;
DROP TABLE IF EXISTS Titular CASCADE;
DROP TABLE IF EXISTS Domicilio CASCADE;
DROP TABLE IF EXISTS Calle CASCADE;
DROP TABLE IF EXISTS Localidad CASCADE;
DROP TABLE IF EXISTS Provincia CASCADE;
DROP TABLE IF EXISTS Pais CASCADE;




-- git init                            # Initialize Git repository
-- git remote add origin https://github.com/ezemaut/Td7-DB-TP1
/*
git add .                           
git commit -m "factura"
git branch -M main            
git push -u origin main       
*/
-- BORRAR AL TERMINAR

-- Table: Pais
CREATE TABLE Pais (
    ID_pais INT PRIMARY KEY,
    Nombre VARCHAR(100)
);

-- Table: Provincia
CREATE TABLE Provincia (
    ID_provincia INT PRIMARY KEY,
    Nombre VARCHAR(100),
    ID_pais INT,
    FOREIGN KEY (ID_pais) REFERENCES Pais(ID_pais)
);

-- Table: Localidad
CREATE TABLE Localidad (
    ID_ciudad INT PRIMARY KEY,
    Nombre VARCHAR(100),
    ID_provincia INT,
    FOREIGN KEY (ID_provincia) REFERENCES Provincia(ID_provincia)
);

-- Table: Calle
CREATE TABLE Calle (
    ID_calle INT PRIMARY KEY,
    Nombre VARCHAR(100)
    ID_ciudad INT,
    FOREIGN KEY (ID_ciudad) REFERENCES Localidad(ID_ciudad)
);

-- Table: Domicilio
CREATE TABLE Domicilio (
    id_dom INT PRIMARY KEY,
    numero VARCHAR(10),
    piso VARCHAR(10),
    CP VARCHAR(10),
    ID_calle INT,
    FOREIGN KEY (ID_calle) REFERENCES Calle(ID_calle), 
);

-- Table: Titular
CREATE TABLE Titular (
    DNI VARCHAR(20) PRIMARY KEY,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Celular VARCHAR(20),
    id_dom INT,
    FOREIGN KEY (id_dom) REFERENCES Domicilio(id_dom)
);

-- Table: Tarjeta
CREATE TABLE Tarjeta (
    ID_tarjeta INT PRIMARY KEY,
    foto VARCHAR(255),
    estado VARCHAR(50),
    Total_gastado DECIMAL(10,2),
    DNI VARCHAR(20),
    FOREIGN KEY (DNI) REFERENCES Titular(DNI)
);

-- Table: HistorialCategoria
CREATE TABLE HistorialCategoria (
    id_historial INT PRIMARY KEY,
    ID_tarjeta INT,
    nombre_cat VARCHAR(100),
    fecha_de_inicio DATE,
    FOREIGN KEY (ID_tarjeta) REFERENCES Tarjeta(ID_tarjeta),
    FOREIGN KEY (nombre_cat) REFERENCES Categoria(nombre_cat)
);

-- Table: Factura
CREATE TABLE Factura (
    Nro_factura INT PRIMARY KEY,
    fecha_emision DATE,
    fecha_vencimiento DATE,
    importe_total DECIMAL(10,2),
    pagado BOOLEAN,
    DNI VARCHAR(20),
    FOREIGN KEY (DNI) REFERENCES Titular(DNI)
);

-- Table: Linea_Factura
CREATE TABLE Linea_Factura (
    id_linea INT PRIMARY KEY,
    fecha_de_consumo DATE,
    monto DECIMAL(10,2),
    nro_factura INT,
    id_tarjeta INT,
    id_entretenimiento INT,
    FOREIGN KEY (nro_factura) REFERENCES Factura(nro_factura),
    FOREIGN KEY (id_tarjeta) REFERENCES Tarjeta(ID_tarjeta),
    FOREIGN KEY (id_entretenimiento) REFERENCES Entretenimiento(id_entretenimiento)
);


-- Table: Medio_de_Pago
CREATE TABLE Medio_de_Pago (
    id_medio INT PRIMARY KEY,
    banco VARCHAR(100),
    tipo VARCHAR(50),
    Nro_factura INT,
    FOREIGN KEY (Nro_factura) REFERENCES Factura(Nro_factura)
);

-- Table: Ranking
CREATE TABLE Ranking (
    id_ranking INT PRIMARY KEY,
    peso_imp DECIMAL(5,2)
);

-- Updated Table: Categoria (add FK to Ranking)
CREATE TABLE Categoria (
    nombre_cat VARCHAR(100) PRIMARY KEY,
    min_total_anual DECIMAL(10,2),
    promedio_mensual DECIMAL(10,2),
    id_ranking INT UNIQUE,
    FOREIGN KEY (id_ranking) REFERENCES Ranking(id_ranking)
);

-- Table: Entretenimiento (base table)
CREATE TABLE Entretenimiento (
    id_entretenimiento INT PRIMARY KEY,
    nombre VARCHAR(100),
    precio DECIMAL(10,2),
    tipo VARCHAR(20), -- 'Evento' o 'Parque'
    min_categoria VARCHAR(100),
    FOREIGN KEY (min_categoria) REFERENCES Categoria(nombre_cat)
);

-- Table: Parque_de_Diversiones (inherits from Entretenimiento)
CREATE TABLE Parque_de_Diversiones (
    id_entretenimiento INT PRIMARY KEY,
    FOREIGN KEY (id_entretenimiento) REFERENCES Entretenimiento(id_entretenimiento)
);

-- Table: Evento (inherits from Entretenimiento)
CREATE TABLE Evento (
    id_entretenimiento INT PRIMARY KEY,
    fecha_inicio DATE,
    fecha_fin DATE,
    FOREIGN KEY (id_entretenimiento) REFERENCES Entretenimiento(id_entretenimiento)
);

-- Table: Empresa
CREATE TABLE Empresa (
    cuit VARCHAR(20) PRIMARY KEY,
    razon_social VARCHAR(100),
    id_dom INT UNIQUE,
    FOREIGN KEY (id_dom) REFERENCES Domicilio(id_dom)
);

-- Table: Atraccion
CREATE TABLE Atraccion (
    id_atraccion INT PRIMARY KEY,
    nombre_atraccion VARCHAR(100),
    precio DECIMAL(10,2),
    altura_min INT,
    edad_min INT,
    fecha DATE,
    min_categoria VARCHAR(100),
    FOREIGN KEY (min_categoria) REFERENCES Categoria(nombre_cat)
);

-- Table: Promocion
CREATE TABLE Promocion (
    ID_promocion INT PRIMARY KEY,
    fecha_inicio DATE,
    fecha_fin DATE,
    categoria VARCHAR(50),
    descuento DECIMAL(5,2)
);

-- NN Table: Promocion_Atraccion
CREATE TABLE Promocion_Atraccion (
    ID_promocion INT,
    id_atraccion INT,
    PRIMARY KEY (ID_promocion, id_atraccion),
    FOREIGN KEY (ID_promocion) REFERENCES Promocion(ID_promocion),
    FOREIGN KEY (id_atraccion) REFERENCES Atraccion(id_atraccion)
);

-- NN Table: Promocion_Entretenimiento
CREATE TABLE Promo_Entret (
    ID_promocion INT,
    id_entretenimiento INT,
    PRIMARY KEY (ID_promocion, id_entretenimiento),
    FOREIGN KEY (ID_promocion) REFERENCES Promocion(ID_promocion),
    FOREIGN KEY (id_entretenimiento) REFERENCES Entretenimiento(id_entretenimiento)
);

-- NN Table: Categoria_Promocion
CREATE TABLE Categoria_Promocion (
    nombre_cat VARCHAR(100),
    ID_promocion INT,
    PRIMARY KEY (nombre_cat, ID_promocion),
    FOREIGN KEY (nombre_cat) REFERENCES Categoria(nombre_cat),
    FOREIGN KEY (ID_promocion) REFERENCES Promocion(ID_promocion)
);
