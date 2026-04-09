CREATE TABLE zona (
    id_zona BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE pais (
    id_pais BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_zona BIGINT NOT NULL,
    nombre VARCHAR(100) NOT NULL,

    CONSTRAINT fk_pais_zona FOREIGN KEY (id_zona)
        REFERENCES zona(id_zona)
        ON DELETE RESTRICT
);

CREATE INDEX idx_pais_zona ON pais(id_zona);

CREATE TABLE tipo_marca (
    id_tipo_marca BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE marca (
    id_marca BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pais BIGINT NOT NULL,
    id_tipo_marca BIGINT NOT NULL,
    nombre VARCHAR(150) NOT NULL,

    CONSTRAINT fk_marca_pais FOREIGN KEY (id_pais)
        REFERENCES pais(id_pais) ON DELETE RESTRICT,

    CONSTRAINT fk_marca_tipo FOREIGN KEY (id_tipo_marca)
        REFERENCES tipo_marca(id_tipo_marca) ON DELETE RESTRICT
);

CREATE INDEX idx_marca_pais ON marca(id_pais);

CREATE TABLE campana (
    id_campana BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_marca BIGINT NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    tipo_campana VARCHAR(100) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,

    anio SMALLINT GENERATED ALWAYS AS (YEAR(fecha_inicio)) STORED,

    CONSTRAINT fk_campana_marca FOREIGN KEY (id_marca)
        REFERENCES marca(id_marca)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT ck_fechas CHECK (fecha_fin >= fecha_inicio)
);

CREATE INDEX idx_campana_marca ON campana(id_marca);
CREATE INDEX idx_campana_anio ON campana(anio);
CREATE INDEX idx_campana_fechas ON campana(fecha_inicio, fecha_fin);

CREATE TABLE ecommerce (
    id_ecommerce BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pais BIGINT NOT NULL,
    nombre_plataforma VARCHAR(150) NOT NULL,

    CONSTRAINT fk_ecommerce_pais FOREIGN KEY (id_pais)
        REFERENCES pais(id_pais)
        ON DELETE RESTRICT
);

CREATE INDEX idx_ecom_pais ON ecommerce(id_pais);

CREATE TABLE ecommerce_campana (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_ecommerce BIGINT NOT NULL,
    id_campana BIGINT NOT NULL,
    id_marca_patrocinadora BIGINT NOT NULL,
    codigo_promocional VARCHAR(50),
    valor_pedido DECIMAL(12,2),
    moneda VARCHAR(10) DEFAULT 'USD',

    CONSTRAINT fk_ec_ecommerce FOREIGN KEY (id_ecommerce)
        REFERENCES ecommerce(id_ecommerce) ON DELETE RESTRICT,

    CONSTRAINT fk_ec_campana FOREIGN KEY (id_campana)
        REFERENCES campana(id_campana) ON DELETE RESTRICT,

    CONSTRAINT fk_ec_marca FOREIGN KEY (id_marca_patrocinadora)
        REFERENCES marca(id_marca) ON DELETE RESTRICT,

    CONSTRAINT uq_ec UNIQUE (id_ecommerce, id_campana, codigo_promocional)
);

CREATE INDEX idx_ecom_campana_ids ON ecommerce_campana(id_ecommerce, id_campana);

CREATE TABLE categoria_indicador (
    id_categoria BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE tipo_indicador (
    id_tipo_indicador BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_categoria BIGINT NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    unidad VARCHAR(50),
    tipo_agregacion VARCHAR(20) NOT NULL, 
    -- 'SUM', 'AVG', 'WEIGHTED'
    descripcion TEXT,

    CONSTRAINT fk_tipo_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria_indicador(id_categoria)
);

CREATE TABLE metrica (
    id_metrica BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_campana BIGINT NOT NULL,
    id_tipo_indicador BIGINT NOT NULL,
    id_ecommerce BIGINT NULL,
    fecha_registro DATE NOT NULL,
    valor DECIMAL(18,4) NOT NULL,

    CONSTRAINT fk_metrica_campana FOREIGN KEY (id_campana)
        REFERENCES campana(id_campana) ON DELETE RESTRICT,

    CONSTRAINT fk_metrica_tipo FOREIGN KEY (id_tipo_indicador)
        REFERENCES tipo_indicador(id_tipo_indicador) ON DELETE RESTRICT,

    CONSTRAINT fk_metrica_ecom FOREIGN KEY (id_ecommerce)
        REFERENCES ecommerce(id_ecommerce) ON DELETE SET NULL,

    CONSTRAINT uq_metrica UNIQUE (
        id_campana,
        id_tipo_indicador,
        id_ecommerce,
        fecha_registro
    )
);

CREATE INDEX idx_metrica_campana ON metrica(id_campana);
CREATE INDEX idx_metrica_tipo ON metrica(id_tipo_indicador);
CREATE INDEX idx_metrica_fecha ON metrica(fecha_registro);

-- RENDIMIENTO GENERAL
CREATE VIEW v_rendimiento_campana AS
SELECT
    z.nombre AS zona,
    p.nombre AS pais,
    m.nombre AS marca,
    c.nombre AS campana,
    c.tipo_campana,
    c.anio,
    ti.nombre AS indicador,
    ci.nombre AS categoria,
    AVG(mt.valor) AS valor_promedio,
    SUM(mt.valor) AS valor_total
FROM metrica mt
JOIN tipo_indicador ti ON mt.id_tipo_indicador = ti.id_tipo_indicador
JOIN categoria_indicador ci ON ti.id_categoria = ci.id_categoria
JOIN campana c ON mt.id_campana = c.id_campana
JOIN marca m ON c.id_marca = m.id_marca
JOIN pais p ON m.id_pais = p.id_pais
JOIN zona z ON p.id_zona = z.id_zona
GROUP BY z.nombre, p.nombre, m.nombre, c.nombre, c.tipo_campana, c.anio, ti.nombre, ci.nombre;

-- ECOMMERCE
CREATE VIEW v_ecommerce_campana AS
SELECT
    e.nombre_plataforma,
    p.nombre AS pais,
    c.nombre AS campana,
    c.tipo_campana,
    m.nombre AS marca_patrocinadora,
    ec.codigo_promocional,
    ec.valor_pedido,
    ec.moneda,
    c.fecha_inicio,
    c.fecha_fin
FROM ecommerce_campana ec
JOIN ecommerce e ON ec.id_ecommerce = e.id_ecommerce
JOIN campana c ON ec.id_campana = c.id_campana
JOIN marca m ON ec.id_marca_patrocinadora = m.id_marca
JOIN pais p ON e.id_pais = p.id_pais;

-- COSTO EFICIENTE
CREATE VIEW v_costo_eficiente AS
SELECT
    z.nombre AS zona,
    p.nombre AS pais,
    m.nombre AS marca,
    c.nombre AS campana,
    c.anio,
    ti.nombre AS kpi,
    SUM(mt.valor) AS valor_total
FROM metrica mt
JOIN tipo_indicador ti ON mt.id_tipo_indicador = ti.id_tipo_indicador
JOIN categoria_indicador ci ON ti.id_categoria = ci.id_categoria
JOIN campana c ON mt.id_campana = c.id_campana
JOIN marca m ON c.id_marca = m.id_marca
JOIN pais p ON m.id_pais = p.id_pais
JOIN zona z ON p.id_zona = z.id_zona
WHERE ci.nombre = 'Costo Eficiente'
GROUP BY z.nombre, p.nombre, m.nombre, c.nombre, c.anio, ti.nombre;

ALTER TABLE tipo_indicador
ADD COLUMN es_acumulativo BOOLEAN DEFAULT TRUE,
ADD COLUMN requiere_ecommerce BOOLEAN DEFAULT FALSE;

UPDATE tipo_indicador SET
es_acumulativo = TRUE,
requiere_ecommerce = FALSE
WHERE nombre IN ('Impresiones','Alcance','Vistas');

UPDATE tipo_indicador SET
es_acumulativo = TRUE,
requiere_ecommerce = TRUE
WHERE nombre IN ('Ventas','Clicks','Links');

UPDATE tipo_indicador SET
es_acumulativo = FALSE,
requiere_ecommerce = TRUE
WHERE nombre LIKE 'Costo%';

ALTER TABLE metrica
ADD COLUMN valor_anterior DECIMAL(18,4),
ADD COLUMN variacion_pct DECIMAL(10,4);

INSERT INTO categoria_indicador (nombre) VALUES
('Rendimiento'),
('Costo Eficiente'),
('Impacto');

INSERT INTO tipo_marca (nombre) VALUES
('Cerveza Premium'),
('Cerveza Popular'),
('Sin Alcohol'),
('Bebida Energética'),
('Refresco'),
('Agua');

INSERT INTO zona (nombre) VALUES
('Zona Andina'),
('Zona Caribe'),
('Zona Pacífico'),
('Zona Sur');

INSERT INTO pais (id_zona, nombre) VALUES
-- Zona Andina
(1,'Colombia'),(1,'Perú'),(1,'Ecuador'),(1,'Bolivia'),
(1,'Venezuela'),(1,'Chile Norte'),(1,'Argentina Norte'),
(1,'Paraguay Norte'),(1,'Brasil Oeste'),(1,'Panamá'),

-- Zona Caribe
(2,'México'),(2,'Cuba'),(2,'República Dominicana'),(2,'Puerto Rico'),
(2,'Honduras'),(2,'Guatemala'),(2,'El Salvador'),
(2,'Costa Rica'),(2,'Nicaragua'),(2,'Belice'),

-- Zona Pacífico
(3,'Japón'),(3,'Corea del Sur'),(3,'China'),(3,'Australia'),
(3,'Nueva Zelanda'),(3,'Indonesia'),(3,'Filipinas'),
(3,'Vietnam'),(3,'Tailandia'),(3,'Malasia'),

-- Zona Sur
(4,'Argentina'),(4,'Chile'),(4,'Uruguay'),(4,'Sudáfrica'),
(4,'Nigeria'),(4,'Kenia'),(4,'Egipto'),
(4,'Turquía'),(4,'India'),(4,'Arabia Saudita');

INSERT INTO marca (id_pais, id_tipo_marca, nombre)
SELECT 
    p.id_pais,
    FLOOR(1 + (RAND() * 6)),
    CONCAT(
        CASE FLOOR(1 + (RAND()*5))
            WHEN 1 THEN 'Corona'
            WHEN 2 THEN 'Heineken'
            WHEN 3 THEN 'Budweiser'
            WHEN 4 THEN 'Red Bull'
            WHEN 5 THEN 'Pepsi'
        END,
        ' ',
        p.nombre,
        ' ',
        seq.num
    )
FROM pais p
JOIN (
    SELECT 1 num UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
) seq;

CREATE TEMPORARY TABLE numeros (n INT);
INSERT INTO numeros VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

INSERT INTO campana (id_marca, nombre, tipo_campana, fecha_inicio, fecha_fin)
SELECT
    m.id_marca,
    CONCAT('Campaña ', m.nombre, ' #', a.n, b.n),
    ELT(FLOOR(1 + RAND()*4),
        'Lanzamiento',
        'Promoción',
        'Branding',
        'Performance'
    ),
    fecha_inicio,
    DATE_ADD(fecha_inicio, INTERVAL FLOOR(1 + RAND()*30) DAY)  -- siempre mayor
FROM marca m
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) a
JOIN (
    SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
) b
JOIN (
    SELECT 
        DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND()*365) DAY) AS fecha_inicio
) f;

INSERT INTO ecommerce (id_pais, nombre_plataforma)
SELECT 
    p.id_pais,
    ELT(FLOOR(1 + RAND()*5),
        'Amazon',
        'MercadoLibre',
        'Rappi',
        'Alibaba',
        'Éxito Online'
    )
FROM pais p
JOIN (
    SELECT 1 UNION SELECT 2 UNION SELECT 3
) t;

INSERT INTO ecommerce_campana (
    id_ecommerce,
    id_campana,
    id_marca_patrocinadora,
    codigo_promocional,
    valor_pedido,
    moneda
)
SELECT
    e.id_ecommerce,
    c.id_campana,
    m.id_marca,
    CONCAT('PROMO', FLOOR(RAND()*100000)),
    ROUND(10 + (RAND()*200),2),
    ELT(FLOOR(1 + RAND()*3),'USD','COP','EUR')
FROM campana c
JOIN marca m ON c.id_marca = m.id_marca
JOIN ecommerce e ON e.id_pais = m.id_pais
LIMIT 100000;

INSERT INTO tipo_indicador 
(id_categoria, nombre, unidad, tipo_agregacion, descripcion)
VALUES

-- IMPACTO
(3,'Impresiones','unidades','SUM','Total de veces que se mostró el anuncio'),
(3,'Clicks','unidades','SUM','Clicks en el anuncio'),
(3,'Ventas','unidades','SUM','Unidades vendidas'),
(3,'Alcance','unidades','SUM','Personas únicas alcanzadas'),

-- RENDIMIENTO
(1,'CTR','%','AVG','Clicks / impresiones'),
(1,'Tasa de conversión','%','AVG','Ventas / clicks'),

-- COSTO
(2,'CPC','USD','AVG','Costo por click'),
(2,'CPM','USD','AVG','Costo por mil impresiones'),
(2,'CPA','USD','AVG','Costo por adquisición');

INSERT INTO metrica (
    id_campana,
    id_tipo_indicador,
    id_ecommerce,
    fecha_registro,
    valor
)
SELECT
    c.id_campana,
    ti.id_tipo_indicador,
    e.id_ecommerce,
    CURDATE(),
    ROUND(1000 + RAND()*9000, 2)
FROM campana c
JOIN marca m ON c.id_marca = m.id_marca
JOIN ecommerce e ON e.id_pais = m.id_pais
JOIN tipo_indicador ti
LIMIT 10000;

SELECT
    c.nombre AS campana,
    c.tipo_campana,
    SUM(m.valor) AS total,
    AVG(m.variacion_pct) AS crecimiento
FROM metrica m
JOIN campana c ON m.id_campana = c.id_campana
GROUP BY c.nombre, c.tipo_campana
ORDER BY total DESC;

SELECT *
FROM v_rendimiento_campana
LIMIT 10;

-- TOP CAMPAÑAS VALOR
SELECT
    campana,
    SUM(valor_total) AS total
FROM v_rendimiento_campana
WHERE indicador = 'Ventas'
GROUP BY campana
ORDER BY total DESC
LIMIT 10;
-- PAIS QUE MAS VENDE
SELECT
    pais,
    SUM(valor_total) AS ventas
FROM v_rendimiento_campana
WHERE indicador = 'Ventas'
GROUP BY pais
ORDER BY ventas DESC;
-- MEJOR ECOMMERCE
SELECT
    nombre_plataforma,
    COUNT(*) AS campañas
FROM v_ecommerce_campana
GROUP BY nombre_plataforma
ORDER BY campañas DESC;
-- FUNNEL
SELECT *
FROM v_funnel_campana
ORDER BY ventas DESC
LIMIT 10;
-- ROI
SELECT *
FROM v_roi_campana
ORDER BY roas DESC;
-- PERFORMANCE
SELECT *
FROM v_performance_ecommerce
ORDER BY ventas DESC;
-- MALAS CAMPAÑAS
SELECT * FROM v_alertas_campana;
