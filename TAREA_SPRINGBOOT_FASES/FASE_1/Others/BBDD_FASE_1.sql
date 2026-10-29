-- =====================================================================
-- BBDD: BIBLIOTECA (Fase I.1)
-- =====================================================================

-- ENTIDADES (9, sin contar intermedias):

-- Socio
-- Libro
-- Carnet
-- Autor
-- Editorial
-- Categoria
-- Ejemplar
-- Bibliotecario
-- Prestamo

-- TABLAS INTERMEDIAS (2)

-- Libro_autor (libro n:m autor)
-- Libro_categoria (libro n:m categoria)


-- RELACIONES:
-- 1:1 -> 
-- Socio - carnet

-- 1:N -> 
-- Editorial-libro
-- Libro-ejemplar
-- Socio-prestamo
-- Ejemplar-prestamo
-- Bibliotecario-prestamo

-- N:M -> 
-- Libro-autor
-- Libro-categoria
-- =====================================================================

DROP DATABASE IF EXISTS biblioteca_db;
CREATE DATABASE biblioteca_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE biblioteca_db;

-- ---------------------------------------------------------------------
-- 1. SOCIO (entidad principal)
-- ---------------------------------------------------------------------
CREATE TABLE socio (
    id_socio         BIGINT AUTO_INCREMENT PRIMARY KEY,
    dni              VARCHAR(9)   NOT NULL UNIQUE,
    nombre           VARCHAR(50)  NOT NULL,
    apellidos        VARCHAR(100) NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE,
    telefono         VARCHAR(15),
    direccion        VARCHAR(150),
    fecha_nacimiento DATE,
    fecha_alta       DATE         NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. CARNET (relación 1:1 con socio)
--    UNIQUE sobre id_socio => un socio solo tiene un carnet
-- ---------------------------------------------------------------------
CREATE TABLE carnet (
    id_carnet        BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_socio         BIGINT      NOT NULL UNIQUE,
    numero           VARCHAR(12) NOT NULL UNIQUE,
    fecha_emision    DATE        NOT NULL,
    fecha_caducidad  DATE        NOT NULL,
    activo           BOOLEAN     NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_carnet_socio
        FOREIGN KEY (id_socio) REFERENCES socio(id_socio)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. EDITORIAL
-- ---------------------------------------------------------------------
CREATE TABLE editorial (
    id_editorial     BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(80) NOT NULL UNIQUE,
    pais             VARCHAR(50),
    web              VARCHAR(100)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. AUTOR
-- ---------------------------------------------------------------------
CREATE TABLE autor (
    id_autor         BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    nacionalidad     VARCHAR(50),
    fecha_nacimiento DATE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. CATEGORIA (ficción, historia, informática...)
-- ---------------------------------------------------------------------
CREATE TABLE categoria (
    id_categoria     BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(50) NOT NULL UNIQUE,
    descripcion      VARCHAR(200)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. LIBRO (entidad secundaria)
--    1:N con editorial (una editorial publica muchos libros)
-- ---------------------------------------------------------------------
CREATE TABLE libro (
    id_libro         BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_editorial     BIGINT       NOT NULL,
    isbn             VARCHAR(13)  NOT NULL UNIQUE,
    titulo           VARCHAR(150) NOT NULL,
    anio_publicacion SMALLINT,
    num_paginas      INT,
    idioma           VARCHAR(30),
    sinopsis         VARCHAR(500),
    CONSTRAINT fk_libro_editorial
        FOREIGN KEY (id_editorial) REFERENCES editorial(id_editorial)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. EJEMPLAR (copia física de un libro) -> 1:N con libro
-- ---------------------------------------------------------------------
CREATE TABLE ejemplar (
    id_ejemplar      BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_libro         BIGINT      NOT NULL,
    codigo_barras    VARCHAR(20) NOT NULL UNIQUE,
    estado           ENUM('NUEVO','BUENO','DETERIORADO') NOT NULL DEFAULT 'BUENO',
    disponible       BOOLEAN     NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_ejemplar_libro
        FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. BIBLIOTECARIO
-- ---------------------------------------------------------------------
CREATE TABLE bibliotecario (
    id_bibliotecario BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(50)  NOT NULL,
    apellidos        VARCHAR(100) NOT NULL,
    email            VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 9. PRESTAMO
--    1:N con socio, con ejemplar y con bibliotecario
-- ---------------------------------------------------------------------
CREATE TABLE prestamo (
    id_prestamo         BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_socio            BIGINT NOT NULL,
    id_ejemplar         BIGINT NOT NULL,
    id_bibliotecario    BIGINT NOT NULL,
    fecha_prestamo      DATE   NOT NULL DEFAULT (CURRENT_DATE),
    fecha_devolucion_prevista DATE NOT NULL,
    fecha_devolucion_real     DATE,                  -- NULL = aún no devuelto
    CONSTRAINT fk_prestamo_socio
        FOREIGN KEY (id_socio) REFERENCES socio(id_socio),
    CONSTRAINT fk_prestamo_ejemplar
        FOREIGN KEY (id_ejemplar) REFERENCES ejemplar(id_ejemplar),
    CONSTRAINT fk_prestamo_bibliotecario
        FOREIGN KEY (id_bibliotecario) REFERENCES bibliotecario(id_bibliotecario)
) ENGINE=InnoDB;

-- =====================================================================
-- TABLAS INTERMEDIAS (N:M)
-- =====================================================================

-- N:M libro <-> autor
CREATE TABLE libro_autor (
    id_libro  BIGINT NOT NULL,
    id_autor  BIGINT NOT NULL,
    PRIMARY KEY (id_libro, id_autor),
    CONSTRAINT fk_la_libro
        FOREIGN KEY (id_libro) REFERENCES libro(id_libro) ON DELETE CASCADE,
    CONSTRAINT fk_la_autor
        FOREIGN KEY (id_autor) REFERENCES autor(id_autor) ON DELETE CASCADE
) ENGINE=InnoDB;

-- N:M libro <-> categoria
CREATE TABLE libro_categoria (
    id_libro      BIGINT NOT NULL,
    id_categoria  BIGINT NOT NULL,
    PRIMARY KEY (id_libro, id_categoria),
    CONSTRAINT fk_lc_libro
        FOREIGN KEY (id_libro) REFERENCES libro(id_libro) ON DELETE CASCADE,
    CONSTRAINT fk_lc_categoria
        FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- DATOS DE PRUEBA (mínimos)
-- =====================================================================
INSERT INTO socio (dni, nombre, apellidos, email, telefono)
VALUES ('12345678A', 'Ana', 'López Ruiz', 'ana@mail.com', '600111222');

INSERT INTO carnet (id_socio, numero, fecha_emision, fecha_caducidad)
VALUES (1, 'CAR-0001', '2026-01-10', '2028-01-10');

INSERT INTO editorial (nombre, pais) VALUES ('Anaya', 'España');
INSERT INTO autor (nombre, nacionalidad) VALUES ('Miguel de Cervantes', 'España');
INSERT INTO categoria (nombre) VALUES ('Clásicos');

INSERT INTO libro (id_editorial, isbn, titulo, anio_publicacion, num_paginas, idioma)
VALUES (1, '9788466700000', 'Don Quijote de la Mancha', 1605, 900, 'Español');

INSERT INTO libro_autor VALUES (1, 1);
INSERT INTO libro_categoria VALUES (1, 1);

INSERT INTO ejemplar (id_libro, codigo_barras) VALUES (1, 'EJ-000001');
INSERT INTO bibliotecario (nombre, apellidos, email)
VALUES ('Luis', 'García', 'luis@biblio.com');

INSERT INTO prestamo (id_socio, id_ejemplar, id_bibliotecario, fecha_devolucion_prevista)
VALUES (1, 1, 1, DATE_ADD(CURRENT_DATE, INTERVAL 15 DAY));