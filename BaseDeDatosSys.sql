CREATE PLUGGABLE DATABASE biblioteca  
ADMIN USER admin IDENTIFIED BY admin_password  
FILE_NAME_CONVERT = ('opt/oracle/oradata/FREE/pdbseed/', 'opt/oracle/oradata/FREE/pdb_biblioteca/');

SHOW CON_NAME;

ALTER SESSION SET CONTAINER = biblioteca;
SHOW PDBS;
ALTER PLUGGABLE DATABASE biblioteca OPEN;

CREATE USER biblioteca_admin_msv IDENTIFIED BY Biblioteca1234;

GRANT CONNECT, RESOURCE TO biblioteca_admin_msv;
GRANT UNLIMITED TABLESPACE TO biblioteca_admin_msv;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE TRIGGER TO biblioteca_admin_msv;