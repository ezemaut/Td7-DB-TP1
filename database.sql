-- BORRAR AL TERMINAR
DROP TABLE IF EXISTS Linea_Factura CASCADE;
DROP TABLE IF EXISTS Factura CASCADE;
DROP TABLE IF EXISTS Tarjeta CASCADE;
DROP TABLE IF EXISTS Titular CASCADE;
DROP TABLE IF EXISTS Categoria CASCADE;
DROP TABLE IF EXISTS HistorialCategoria CASCADE;

-- BORRAR AL TERMINAR

-- git init                            # Initialize Git repository
-- git remote add origin https://github.com/ezemaut/Td7-DB-TP1
/*
git add .                           
git commit -m "factura"
git branch -M main            # Rename current branch to 'main'
git push -u origin main       # Push it to GitHub and set it as upstream       
*/

-- Table: Titular
CREATE TABLE Titular (
    DNI VARCHAR(20) PRIMARY KEY,
    Nombre VARCHAR(100),
    Apellido VARCHAR(100),
    Celular VARCHAR(20)
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
    ID_tarjeta INT,
    Nro_factura INT,
    FOREIGN KEY (ID_tarjeta) REFERENCES Tarjeta(ID_tarjeta),
    FOREIGN KEY (Nro_factura) REFERENCES Factura(Nro_factura)
);

-- Table: Categoria
CREATE TABLE Categoria (
    nombre_cat VARCHAR(100) PRIMARY KEY,
    min_total_anual DECIMAL(10,2),
    promedio_mensual DECIMAL(10,2)
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


-- ayuda