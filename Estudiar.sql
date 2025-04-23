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
SHOW CON_NAME;

-- CERRAR LA BASE DE DATOS PLUGGABLE "BIBLIOTECA"
ALTER PLUGGABLE DATABASE biblioteca CLOSE IMMEDIATE;

-- ELIMINAR LA BASE DE DATOS PLUGGABLE "BIBLIOTECA"
DROP PLUGGABLE DATABASE biblioteca INCLUDING DATAFILES;

-- CAMBIAR AL CONTEXTO DE LA BASE DE DATOS CDB PARA ELIMINAR EL USUARIO
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- ELIMINAR EL USUARIO DE MANERA SEGURA
DROP USER biblioteca_admin_msv CASCADE;

/* Muestro el tablespace en el que estoy trabajando. Para ello, compruebo
    el tablespace por defecto del usuario que estoy utilizando */
SELECT username, default_tablespace 
FROM dba_users 
WHERE username = USER;

/*///////////////////////////////////////////////////////////////////////////////////*/
-------------Crear una conexión nueva con biblioteca_admin_msv-------------------------
/*///////////////////////////////////////////////////////////////////////////////////*/

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

/*///////////////////////////////////////////////////////////////////////////////////*/
-------------Explicación de los objetos-------------------------
/*///////////////////////////////////////////////////////////////////////////////////*/

-- Objetos:
DROP TYPE tDomicilio FORCE;

CREATE OR REPLACE TYPE tDomicilio AS OBJECT (
    calle varchar(50),
    numero int,
    piso int,
    escalera int,
    puerta char(2),
    MEMBER FUNCTION getDomicilio RETURN varchar
);

CREATE TYPE BODY tDomicilio AS
    MEMBER FUNCTION getDomicilio RETURN varchar IS
    BEGIN
        RETURN calle||' '||numero|| ' Piso: '||piso||' Escalera: '||escalera||
            ' Puerta: '||puerta;
    END;
END;

CREATE TABLE CLIENTE (
    NIF CHAR(9) PRIMARY KEY,
    NOMBRE VARCHAR2(50),
    DOMICILIO tDomicilio,
    TLF VARCHAR2(25),
    CIUDAD VARCHAR2(25)
);

INSERT INTO CLIENTE VALUES (
    '11111111A', 
    'ROSA PEREZ DELGADO', 
    tDomicilio('Astro', 25, 3, 1, 'A'),
    '913678090', 
    'MADRID'
);

SELECT c.NIF, c.NOMBRE, c.domicilio.getDomicilio()
FROM CLIENTE c;
