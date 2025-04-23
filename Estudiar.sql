-- CREA UNA BASE DE DATOS PLUGGABLE (PDB) LLAMADA "BIBLIOTECA"
CREATE PLUGGABLE DATABASE biblioteca  
ADMIN USER admin IDENTIFIED BY admin_password  
FILE_NAME_CONVERT = ('opt/oracle/oradata/FREE/pdbseed/', 'opt/oracle/oradata/FREE/pdb_biblioteca/');

-- MUESTRA EL NOMBRE DE LA BASE DE DATOS ACTUAL
SHOW CON_NAME;

-- CAMBIA AL CONTEXTO DE LA BASE DE DATOS PLUGGABLE "BIBLIOTECA"
ALTER SESSION SET CONTAINER = biblioteca;

-- MUESTRA LAS BASES DE DATOS PLUGGABLES DISPONIBLES
SHOW PDBS;

-- ABRE LA BASE DE DATOS PLUGGABLE "BIBLIOTECA" PARA SU USO
ALTER PLUGGABLE DATABASE biblioteca OPEN;

-- CREA UN TABLESPACE PARA EL USUARIO
CREATE TABLESPACE biblioteca_tbs
DATAFILE '/opt/oracle/oradata/FREE/pdb_biblioteca/biblioteca_tbs.dbf'
SIZE 50M AUTOEXTEND ON NEXT 10M MAXSIZE 200M;

-- CREA UN USUARIO LLAMADO "BIBLIOTECA_ADMIN_MSV" CON CONTRASEÑA "Biblioteca1234"
-- ASIGNA TABLESPACE POR DEFECTO Y CUOTA LIMITADA
CREATE USER biblioteca_admin_msv
IDENTIFIED BY Biblioteca1234
DEFAULT TABLESPACE biblioteca_tbs
QUOTA 50M ON biblioteca_tbs;

-- CONCEDE PRIVILEGIOS DE CONEXIÓN Y RECURSOS AL USUARIO
GRANT CONNECT, RESOURCE TO biblioteca_admin_msv;

-- OTORGA PRIVILEGIOS DE DBA AL USUARIO
GRANT DBA TO biblioteca_admin_msv;

-- CERRAR LA BASE DE DATOS PLUGGABLE "BIBLIOTECA"
-- PRIMERO, CAMBIA DE SESIÓN AL USUARIO ADMINISTRADOR (NO DEBE ESTAR CONECTADO COMO EL USUARIO A ELIMINAR)
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- CERRAR LA BASE DE DATOS PLUGGABLE "BIBLIOTECA"
ALTER PLUGGABLE DATABASE biblioteca CLOSE IMMEDIATE;

-- ELIMINAR LA BASE DE DATOS PLUGGABLE "BIBLIOTECA"
DROP PLUGGABLE DATABASE biblioteca INCLUDING DATAFILES;

-- CAMBIAR AL CONTEXTO DE LA BASE DE DATOS CDB PARA ELIMINAR EL USUARIO
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- ELIMINAR EL USUARIO DE MANERA SEGURA
DROP USER biblioteca_admin_msv CASCADE;

-------------Crear una conexión nueva con biblioteca_admin_msv-------------------------

SHOW CON_NAME;

DROP TABLE IF EXISTS Socio;

CREATE OR REPLACE TYPE tSocio AS OBJECT (
  NIF VARCHAR2(9),  
  Nombre VARCHAR2(100),     
  Telefono VARCHAR2(15),    
  -- MÉTODO getSocio que devolverá todos los datos de Socio
  MEMBER FUNCTION getSocio RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY tSocio AS
  MEMBER FUNCTION getSocio RETURN VARCHAR2 IS
  BEGIN
    -- DEVUELVE UNA CADENA CON LA CONCATENACIÓN DE LOS DATOS PERSONALES DEL SOCIO
    RETURN 'NIF: ' || NIF || ', Nombre: ' || Nombre || ', Teléfono: ' || Telefono;
  END;
END;

CREATE TABLE Socio OF tSocio (
  NIF PRIMARY KEY 
);

INSERT INTO Socio VALUES (tSocio('12345678A', 'Mario Sanz', '123456789'));
INSERT INTO Socio VALUES (tSocio('87654321B', 'Ricardo Perez', '987654321'));

SELECT * FROM Socio;

-- CREAMOS UNA TABLA A PARTIR DE LOS DATOS DEL OBJETO TSOCIO

DROP TABLE IF EXISTS Libro;
CREATE OR REPLACE TYPE tLibro AS OBJECT (
    Referencia VARCHAR2(20),
    Titulo VARCHAR2(100),
    Autor VARCHAR2(100),
    Editorial VARCHAR2(100),
    FechaPrestamo DATE,
    NIFSocio VARCHAR2(9),
    
    MEMBER FUNCTION getLibro RETURN VARCHAR2,
    MEMBER FUNCTION diasPrestamo RETURN NUMBER,
    MEMBER FUNCTION diasMulta RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY tLibro AS
    MEMBER FUNCTION getLibro RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Referencia: ' || Referencia || ', Título: ' || Titulo || ', Autor: ' || Autor || 
               ', Editorial: ' || Editorial || ', Fecha de Préstamo: ' || TO_CHAR(FechaPrestamo, 'DD/MM/YYYY') || 
               ', NIF Socio: ' || NIFSocio;
    END;
    MEMBER FUNCTION diasPrestamo RETURN NUMBER IS dias NUMBER;
        BEGIN
            -- Calcular los días que lleva prestado el libro
            dias := SYSDATE - FechaPrestamo;
            RETURN dias;
        END;
    MEMBER FUNCTION diasMulta RETURN NUMBER IS dias NUMBER;
        BEGIN
            -- Calcular los días de multa (si pasaron más de 7 días desde el préstamo)
            dias := SYSDATE - FechaPrestamo;
            IF dias > 7 THEN
                RETURN dias - 7;  -- Días de multa
            ELSE
                RETURN 0;  -- No hay multa si el préstamo no supera los 7 días
            END IF;
        END;
END;

CREATE TABLE Libro OF tLibro (
    Referencia PRIMARY KEY, 
    NIFSocio REFERENCES Socio(NIF)  
);

INSERT INTO Libro VALUES (tLibro('l1', 'La República', 'Platón', 'Editorial A', TO_DATE('2025-03-01', 'YYYY-MM-DD'), '87654321B'));
INSERT INTO Libro VALUES (tLibro('l2', 'El concepto de la angustia', 'Søren Kierkegaard', 'Editorial E', TO_DATE('2025-03-20', 'YYYY-MM-DD'), '87654321B'));
INSERT INTO Libro VALUES (tLibro('l3', 'Meditaciones', 'Marco Aurelio', 'Editorial C', TO_DATE('2025-03-10', 'YYYY-MM-DD'), '12345678A'));
INSERT INTO Libro VALUES (tLibro('l4', 'El ser y la nada', 'Jean-Paul Sartre', 'Editorial D', TO_DATE('2025-03-15', 'YYYY-MM-DD'), '12345678A'));

SELECT * FROM libro;SHOW CON_NAME;

DROP TABLE IF EXISTS Socio;

CREATE OR REPLACE TYPE tSocio AS OBJECT (
  NIF VARCHAR2(9),  
  Nombre VARCHAR2(100),     
  Telefono VARCHAR2(15),    
  -- MÉTODO getSocio que devolverá todos los datos de Socio
  MEMBER FUNCTION getSocio RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY tSocio AS
  MEMBER FUNCTION getSocio RETURN VARCHAR2 IS
  BEGIN
    -- DEVUELVE UNA CADENA CON LA CONCATENACIÓN DE LOS DATOS PERSONALES DEL SOCIO
    RETURN 'NIF: ' || NIF || ', Nombre: ' || Nombre || ', Teléfono: ' || Telefono;
  END;
END;

CREATE TABLE Socio OF tSocio (
  NIF PRIMARY KEY 
);

INSERT INTO Socio VALUES (tSocio('12345678A', 'Mario Sanz', '123456789'));
INSERT INTO Socio VALUES (tSocio('87654321B', 'Ricardo Perez', '987654321'));

SELECT * FROM Socio;

-- CREAMOS UNA TABLA A PARTIR DE LOS DATOS DEL OBJETO TSOCIO

DROP TABLE IF EXISTS Libro;
CREATE OR REPLACE TYPE tLibro AS OBJECT (
    Referencia VARCHAR2(20),
    Titulo VARCHAR2(100),
    Autor VARCHAR2(100),
    Editorial VARCHAR2(100),
    FechaPrestamo DATE,
    NIFSocio VARCHAR2(9),
    
    MEMBER FUNCTION getLibro RETURN VARCHAR2,
    MEMBER FUNCTION diasPrestamo RETURN NUMBER,
    MEMBER FUNCTION diasMulta RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY tLibro AS
    MEMBER FUNCTION getLibro RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Referencia: ' || Referencia || ', Título: ' || Titulo || ', Autor: ' || Autor || 
               ', Editorial: ' || Editorial || ', Fecha de Préstamo: ' || TO_CHAR(FechaPrestamo, 'DD/MM/YYYY') || 
               ', NIF Socio: ' || NIFSocio;
    END;
    MEMBER FUNCTION diasPrestamo RETURN NUMBER IS dias NUMBER;
        BEGIN
            -- Calcular los días que lleva prestado el libro
            dias := SYSDATE - FechaPrestamo;
            RETURN dias;
        END;
    MEMBER FUNCTION diasMulta RETURN NUMBER IS dias NUMBER;
        BEGIN
            -- Calcular los días de multa (si pasaron más de 7 días desde el préstamo)
            dias := SYSDATE - FechaPrestamo;
            IF dias > 7 THEN
                RETURN dias - 7;  -- Días de multa
            ELSE
                RETURN 0;  -- No hay multa si el préstamo no supera los 7 días
            END IF;
        END;
END;

CREATE TABLE Libro OF tLibro (
    Referencia PRIMARY KEY, 
    NIFSocio REFERENCES Socio(NIF)  
);

INSERT INTO Libro VALUES (tLibro('l1', 'La República', 'Platón', 'Editorial A', TO_DATE('2025-03-01', 'YYYY-MM-DD'), '87654321B'));
INSERT INTO Libro VALUES (tLibro('l2', 'El concepto de la angustia', 'Søren Kierkegaard', 'Editorial E', TO_DATE('2025-03-20', 'YYYY-MM-DD'), '87654321B'));
INSERT INTO Libro VALUES (tLibro('l3', 'Meditaciones', 'Marco Aurelio', 'Editorial C', TO_DATE('2025-03-10', 'YYYY-MM-DD'), '12345678A'));
INSERT INTO Libro VALUES (tLibro('l4', 'El ser y la nada', 'Jean-Paul Sartre', 'Editorial D', TO_DATE('2025-03-15', 'YYYY-MM-DD'), '12345678A'));

SELECT * FROM libro;