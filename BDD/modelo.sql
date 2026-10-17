-- =====================================================================================
-- Sistema de Gestión de Fondos Externos y Cooperación Internacional (ESPE / CEDIA)
-- MODELO RELACIONAL GENÉRICO — SQL estándar (ANSI SQL:2003), independiente del motor
-- Total: 30 tablas catálogo + 35 tablas transaccionales = 65 tablas.
-- =====================================================================================


-- =====================================================================================
-- 1. CATÁLOGOS (paramétricos)
-- =====================================================================================

CREATE TABLE cat_roles (
    id              INTEGER      NOT NULL PRIMARY KEY,
    nombre          VARCHAR(50)  NOT NULL UNIQUE,        -- INVESTIGADOR, DIRECTOR_DEPARTAMENTO, UGI, ADMINISTRADOR
    descripcion     TEXT
);

CREATE TABLE cat_paises (
    id              INTEGER      NOT NULL PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL UNIQUE,
    codigo_iso      CHAR(2)      NOT NULL UNIQUE
);

CREATE TABLE cat_departamentos (
    id                   INTEGER      NOT NULL PRIMARY KEY,
    nombre               VARCHAR(150) NOT NULL UNIQUE,
    tipo                 VARCHAR(20)  NOT NULL CHECK (tipo IN ('DEPARTAMENTO','CENTRO')),
    facultad             VARCHAR(150),
    director_usuario_id  CHAR(36),                      -- FK a usuarios: se agrega después (referencia cruzada)
    activo               BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE cat_entidades_financiadoras (
    id              INTEGER      NOT NULL PRIMARY KEY,
    nombre          VARCHAR(200) NOT NULL UNIQUE,        -- CEDIA, Comisión Europea, BBSRC, INOCAR, ...
    sigla           VARCHAR(30),
    pais_id         INTEGER      REFERENCES cat_paises(id),   -- NULL para organismos supranacionales (UE)
    tipo            VARCHAR(20)  NOT NULL CHECK (tipo IN ('NACIONAL','INTERNACIONAL')),
    naturaleza      VARCHAR(30)  CHECK (naturaleza IN ('PUBLICA','PRIVADA','ORGANISMO_SUPRANACIONAL',
                                       'UNIVERSIDAD','CORPORACION_ACADEMICA','CONSORCIO','ONG')),
    sitio_web       VARCHAR(300),
    correo_contacto VARCHAR(150),
    created_at      TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cat_tipos_requisito_documental (
    id              INTEGER      NOT NULL PRIMARY KEY,
    nombre          VARCHAR(150) NOT NULL UNIQUE,
    descripcion     TEXT,
    orden           SMALLINT     NOT NULL,
    obligatorio     BOOLEAN      NOT NULL DEFAULT TRUE
);

CREATE TABLE cat_tipos_alerta (
    id                INTEGER      NOT NULL PRIMARY KEY,
    codigo            VARCHAR(60)  NOT NULL UNIQUE,      -- VENCIMIENTO_REGISTRO_60D, ...
    nombre            VARCHAR(150) NOT NULL,
    descripcion       TEXT,
    dias_anticipacion INTEGER      NOT NULL DEFAULT 0
);

CREATE TABLE cat_instituciones_socias (
    id               INTEGER      NOT NULL PRIMARY KEY,
    nombre           VARCHAR(200) NOT NULL,
    pais_id          INTEGER      REFERENCES cat_paises(id),
    tipo_institucion VARCHAR(50)  NOT NULL CHECK (tipo_institucion IN
                        ('UNIVERSIDAD','EMPRESA','CENTRO_INVESTIGACION','ONG','GUBERNAMENTAL','OTRO')),
    UNIQUE (nombre, pais_id)
);

CREATE TABLE cat_periodos_academicos (
    id              INTEGER      NOT NULL PRIMARY KEY,
    nombre          VARCHAR(50)  NOT NULL,               -- '2026-I'
    anio            SMALLINT     NOT NULL,
    periodo         SMALLINT     NOT NULL CHECK (periodo IN (1,2)),
    fecha_inicio    DATE         NOT NULL,
    fecha_fin       DATE         NOT NULL,
    CHECK (fecha_fin > fecha_inicio),
    UNIQUE (anio, periodo)
);

CREATE TABLE cat_roles_proyecto (
    id              INTEGER      NOT NULL PRIMARY KEY,
    codigo          VARCHAR(40)  NOT NULL UNIQUE,
    nombre          VARCHAR(100) NOT NULL,               -- Director, Codirector, Investigador Asociado, ...
    descripcion     TEXT,
    permite_externo BOOLEAN      NOT NULL DEFAULT FALSE,
    orden           SMALLINT
);

CREATE TABLE cat_programas_postgrado (
    id      INTEGER      NOT NULL PRIMARY KEY,
    nombre  VARCHAR(200) NOT NULL UNIQUE
);

CREATE TABLE cat_dominios_academicos (
    id      INTEGER      NOT NULL PRIMARY KEY,
    nombre  VARCHAR(200) NOT NULL UNIQUE
);

CREATE TABLE cat_lineas_investigacion (
    id                    INTEGER      NOT NULL PRIMARY KEY,
    dominio_academico_id  INTEGER      NOT NULL REFERENCES cat_dominios_academicos(id),
    nombre                VARCHAR(200) NOT NULL,
    UNIQUE (dominio_academico_id, nombre)
);

CREATE TABLE cat_grupos_investigacion (
    id              INTEGER      NOT NULL PRIMARY KEY,
    codigo          VARCHAR(20)  NOT NULL UNIQUE,
    nombre          VARCHAR(200) NOT NULL,
    departamento_id INTEGER      REFERENCES cat_departamentos(id)
);

CREATE TABLE cat_tipos_investigacion (
    id      INTEGER      NOT NULL PRIMARY KEY,
    nombre  VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE cat_disciplinas_cientificas (
    id      INTEGER      NOT NULL PRIMARY KEY,
    nombre  VARCHAR(150) NOT NULL UNIQUE                  -- OCDE / Frascati
);

CREATE TABLE cat_objetivos_socioeconomicos (
    id      INTEGER      NOT NULL PRIMARY KEY,
    nombre  VARCHAR(200) NOT NULL UNIQUE                  -- NABS
);

CREATE TABLE cat_areas_conocimiento_espe (
    id      INTEGER      NOT NULL PRIMARY KEY,
    nombre  VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE cat_areas_unesco (
    id      INTEGER      NOT NULL PRIMARY KEY,
    codigo  VARCHAR(10)  NOT NULL UNIQUE,
    nombre  VARCHAR(200) NOT NULL
);

CREATE TABLE cat_subareas_unesco (
    id              INTEGER      NOT NULL PRIMARY KEY,
    area_unesco_id  INTEGER      NOT NULL REFERENCES cat_areas_unesco(id),
    codigo          VARCHAR(10)  NOT NULL UNIQUE,
    nombre          VARCHAR(200) NOT NULL
);

CREATE TABLE cat_campos_amplios (
    id      INTEGER      NOT NULL PRIMARY KEY,
    codigo  VARCHAR(10)  NOT NULL UNIQUE,
    nombre  VARCHAR(200) NOT NULL
);

CREATE TABLE cat_campos_especificos (
    id               INTEGER      NOT NULL PRIMARY KEY,
    campo_amplio_id  INTEGER      NOT NULL REFERENCES cat_campos_amplios(id),
    codigo           VARCHAR(10)  NOT NULL UNIQUE,
    nombre           VARCHAR(200) NOT NULL
);

CREATE TABLE cat_campos_detallados (
    id                   INTEGER      NOT NULL PRIMARY KEY,
    campo_especifico_id  INTEGER      NOT NULL REFERENCES cat_campos_especificos(id),
    codigo               VARCHAR(10)  NOT NULL UNIQUE,
    nombre               VARCHAR(200) NOT NULL
);

CREATE TABLE cat_ods (
    id      INTEGER      NOT NULL PRIMARY KEY,
    numero  SMALLINT     NOT NULL UNIQUE CHECK (numero BETWEEN 1 AND 17),
    nombre  VARCHAR(200) NOT NULL
);

CREATE TABLE cat_ods_metas (
    id           INTEGER     NOT NULL PRIMARY KEY,
    ods_id       INTEGER     NOT NULL REFERENCES cat_ods(id),
    codigo       VARCHAR(10) NOT NULL,                    -- '4.3'
    descripcion  TEXT        NOT NULL,
    UNIQUE (ods_id, codigo)
);


CREATE TABLE cat_monedas (
    id          INTEGER      NOT NULL PRIMARY KEY,
    codigo_iso  CHAR(3)      NOT NULL UNIQUE,            -- USD, EUR, GBP (ISO 4217)
    nombre      VARCHAR(50)  NOT NULL,
    simbolo     VARCHAR(5)
);

CREATE TABLE cat_tipos_oportunidad (
    id      INTEGER      NOT NULL PRIMARY KEY,
    codigo  VARCHAR(40)  NOT NULL UNIQUE,                -- PROGRAMA_MARCO, FONDO_CONCURSABLE_ID, BECA_MOVILIDAD, MISION, ...
    nombre  VARCHAR(150) NOT NULL
);

CREATE TABLE cat_tipos_beneficiario (
    id      INTEGER      NOT NULL PRIMARY KEY,
    codigo  VARCHAR(40)  NOT NULL UNIQUE,                -- IES_MIEMBRO_CEDIA, CANDIDATO_DOCTORAL, PYME, ...
    nombre  VARCHAR(150) NOT NULL
);

CREATE TABLE cat_plataformas_postulacion (
    id      INTEGER      NOT NULL PRIMARY KEY,
    nombre  VARCHAR(150) NOT NULL UNIQUE,                -- EasyChair, EU Funding & Tenders Portal, UKRI Funding Service, ...
    url     VARCHAR(300)
);

-- Tipos de acción de Horizon Europe y similares (RIA, IA, CSA)
CREATE TABLE cat_tipos_accion (
    id                     INTEGER      NOT NULL PRIMARY KEY,
    codigo                 VARCHAR(10)  NOT NULL UNIQUE,
    nombre                 VARCHAR(150) NOT NULL,
    trl_min                SMALLINT     CHECK (trl_min BETWEEN 1 AND 9),
    trl_max                SMALLINT     CHECK (trl_max BETWEEN 1 AND 9),
    tasa_financiacion_pct  DECIMAL(5,2) CHECK (tasa_financiacion_pct BETWEEN 0 AND 100),  -- NULL = diferenciada por tipo de entidad
    descripcion            TEXT,
    CHECK (trl_max IS NULL OR trl_min IS NULL OR trl_max >= trl_min)
);


-- =====================================================================================
-- 2. USUARIOS Y ROLES
-- =====================================================================================

CREATE TABLE usuarios (
    id               CHAR(36)     NOT NULL PRIMARY KEY,
    cedula           VARCHAR(20)  NOT NULL UNIQUE,
    nombres          VARCHAR(150) NOT NULL,
    apellidos        VARCHAR(150) NOT NULL,
    email            VARCHAR(150) NOT NULL UNIQUE,
    password_hash    VARCHAR(255) NOT NULL,
    telefono         VARCHAR(20),
    departamento_id  INTEGER      REFERENCES cat_departamentos(id),
    indice_h_actual  SMALLINT     NOT NULL DEFAULT 0 CHECK (indice_h_actual >= 0),
    activo           BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE cat_departamentos
    ADD CONSTRAINT fk_departamento_director
        FOREIGN KEY (director_usuario_id) REFERENCES usuarios(id);

CREATE TABLE usuario_roles (
    usuario_id        CHAR(36)  NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    rol_id            INTEGER   NOT NULL REFERENCES cat_roles(id),
    fecha_asignacion  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, rol_id)
);


-- =====================================================================================
-- 3. BANCO DE OPORTUNIDADES: programas -> convocatorias
-- =====================================================================================

-- Programa o fondo marco. Jerárquico: Horizon Europe -> MSCA; Erasmus+ -> Erasmus Mundus.
CREATE TABLE programas_financiamiento (
    id                   CHAR(36)      NOT NULL PRIMARY KEY,
    programa_padre_id    CHAR(36)      REFERENCES programas_financiamiento(id),
    nombre               VARCHAR(250)  NOT NULL,
    sigla                VARCHAR(30),
    tipo_oportunidad_id  INTEGER       NOT NULL REFERENCES cat_tipos_oportunidad(id),
    descripcion          TEXT,
    presupuesto_total    DECIMAL(18,2) CHECK (presupuesto_total >= 0),
    moneda_id            INTEGER       REFERENCES cat_monedas(id),
    anio_inicio          SMALLINT,
    anio_fin             SMALLINT,
    url_oficial          VARCHAR(300),
    activo               BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at           TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (anio_fin IS NULL OR anio_inicio IS NULL OR anio_fin >= anio_inicio),
    CHECK (presupuesto_total IS NULL OR moneda_id IS NOT NULL)
);

-- Entidades que participan en un programa y con qué rol
CREATE TABLE programa_entidades (
    programa_id              CHAR(36)    NOT NULL REFERENCES programas_financiamiento(id) ON DELETE CASCADE,
    entidad_financiadora_id  INTEGER     NOT NULL REFERENCES cat_entidades_financiadoras(id),
    rol                      VARCHAR(20) NOT NULL CHECK (rol IN ('PROMOTORA','ENTREGADORA','COORDINADORA',
                                                               'MIEMBRO_CONSORCIO','GESTORA_ADMISION')),
    PRIMARY KEY (programa_id, entidad_financiadora_id, rol)
);

CREATE TABLE programa_fuentes (
    programa_id  CHAR(36) NOT NULL REFERENCES programas_financiamiento(id) ON DELETE CASCADE,
    fuente_id    INTEGER  NOT NULL REFERENCES cat_fuentes_informacion(id),
    PRIMARY KEY (programa_id, fuente_id)
);

-- Convocatoria concreta (edición con fechas) a la que se postula
CREATE TABLE convocatorias (
    id                              CHAR(36)      NOT NULL PRIMARY KEY,
    programa_id                     CHAR(36)      REFERENCES programas_financiamiento(id),
    entidad_financiadora_id         INTEGER       NOT NULL REFERENCES cat_entidades_financiadoras(id),
    tipo_oportunidad_id             INTEGER       NOT NULL REFERENCES cat_tipos_oportunidad(id),
    tipo_accion_id                  INTEGER       REFERENCES cat_tipos_accion(id),
    codigo                          VARCHAR(50)   UNIQUE,
    nombre                          VARCHAR(250)  NOT NULL,
    descripcion                     TEXT,
    fecha_apertura                  DATE,                        -- NULL = por anunciar
    fecha_cierre                    DATE,                        -- NULL = por anunciar
    moneda_id                       INTEGER       NOT NULL REFERENCES cat_monedas(id),
    presupuesto_total_convocatoria  DECIMAL(18,2) CHECK (presupuesto_total_convocatoria >= 0),
    monto_maximo_proyecto           DECIMAL(14,2) CHECK (monto_maximo_proyecto >= 0),     -- CEDIA: 50.000 USD
    porcentaje_contraparte_min      DECIMAL(5,2)  CHECK (porcentaje_contraparte_min BETWEEN 0 AND 100),  -- CEDIA: 30 %
    tasa_financiacion_pct           DECIMAL(5,2)  CHECK (tasa_financiacion_pct BETWEEN 0 AND 100),       -- RIA/CSA: 100 %
    modalidad_financiamiento        VARCHAR(20)   NOT NULL DEFAULT 'DIRECTO'
                                    CHECK (modalidad_financiamiento IN ('DIRECTO','INDIRECTO','BECA',
                                           'EN_ESPECIE','RECONOCIMIENTO','MIXTO')),
    duracion_min_meses              SMALLINT      CHECK (duracion_min_meses > 0),
    duracion_max_meses              SMALLINT      CHECK (duracion_max_meses > 0),
    prorroga_max_dias               SMALLINT      CHECK (prorroga_max_dias >= 0),         -- CEDIA: 90 días
    plataforma_postulacion_id       INTEGER       REFERENCES cat_plataformas_postulacion(id),
    proceso_postulacion             TEXT,
    requiere_envio_fisico           BOOLEAN       NOT NULL DEFAULT FALSE,   -- cartas con firma física (CEDIA Cuenca)
    url_bases                       VARCHAR(300),
    estado                          VARCHAR(20)   NOT NULL DEFAULT 'POR_ANUNCIAR'
                                    CHECK (estado IN ('POR_ANUNCIAR','ABIERTA','CERRADA','ANULADA')),
    created_at                      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (fecha_cierre IS NULL OR fecha_apertura IS NULL OR fecha_cierre > fecha_apertura),
    CHECK (duracion_max_meses IS NULL OR duracion_min_meses IS NULL OR duracion_max_meses >= duracion_min_meses)
);

-- Fases de la convocatoria (Postulación, Desarrollo, Gestión del conocimiento, ...)
CREATE TABLE convocatoria_fases (
    id                 CHAR(36)     NOT NULL PRIMARY KEY,
    convocatoria_id    CHAR(36)     NOT NULL REFERENCES convocatorias(id) ON DELETE CASCADE,
    orden              SMALLINT     NOT NULL,
    nombre             VARCHAR(150) NOT NULL,
    descripcion        TEXT,
    fecha_inicio       DATE,
    fecha_fin          DATE,
    duracion_meses     SMALLINT     CHECK (duracion_meses > 0),
    prorroga_max_dias  SMALLINT     CHECK (prorroga_max_dias >= 0),
    UNIQUE (convocatoria_id, orden),
    CHECK (fecha_fin IS NULL OR fecha_inicio IS NULL OR fecha_fin >= fecha_inicio)
);

-- Requisitos de elegibilidad de la convocatoria. valor_minimo + unidad permiten reglas
-- cuantificables: 3 instituciones, 2 ciudades, 2 años de experiencia, 180 ECTS, ...
CREATE TABLE convocatoria_requisitos (
    id               CHAR(36)      NOT NULL PRIMARY KEY,
    convocatoria_id  CHAR(36)      NOT NULL REFERENCES convocatorias(id) ON DELETE CASCADE,
    orden            SMALLINT      NOT NULL,
    categoria        VARCHAR(15)   NOT NULL CHECK (categoria IN ('ELEGIBILIDAD','CONSORCIO','EQUIPO',
                                                  'DOCUMENTAL','ACADEMICO','TECNICO','ETICO')),
    descripcion      TEXT          NOT NULL,
    valor_minimo     DECIMAL(10,2),
    unidad           VARCHAR(40),
    obligatorio      BOOLEAN       NOT NULL DEFAULT TRUE,
    UNIQUE (convocatoria_id, orden)
);

-- Qué cubre la convocatoria y con qué tope: rubros monetarios (honorarios hasta 1.000/mes,
-- equipos hasta 40 %) y beneficios no monetarios (exención de matrícula, mentoría de 10 h).
CREATE TABLE convocatoria_coberturas (
    id               CHAR(36)      NOT NULL PRIMARY KEY,
    convocatoria_id  CHAR(36)      NOT NULL REFERENCES convocatorias(id) ON DELETE CASCADE,
    concepto         VARCHAR(200)  NOT NULL,
    tipo             VARCHAR(15)   NOT NULL CHECK (tipo IN ('MONETARIA','EN_ESPECIE','EXENCION',
                                                  'FORMACION','MENTORIA','RECONOCIMIENTO')),
    tope_monto       DECIMAL(14,2) CHECK (tope_monto >= 0),
    tope_porcentaje  DECIMAL(5,2)  CHECK (tope_porcentaje BETWEEN 0 AND 100),
    periodicidad     VARCHAR(10)   CHECK (periodicidad IN ('UNICA','MENSUAL','DIARIA','ANUAL')),
    cantidad         DECIMAL(10,2),
    unidad           VARCHAR(40),                         -- horas, cupos, ...
    observaciones    TEXT
);

CREATE TABLE convocatoria_beneficiarios (
    convocatoria_id       CHAR(36) NOT NULL REFERENCES convocatorias(id) ON DELETE CASCADE,
    tipo_beneficiario_id  INTEGER  NOT NULL REFERENCES cat_tipos_beneficiario(id),
    PRIMARY KEY (convocatoria_id, tipo_beneficiario_id)
);

-- Categorías de concursos (I+D, Innovación y emprendimiento, Transformación digital, ...)
CREATE TABLE convocatoria_categorias (
    id               CHAR(36)     NOT NULL PRIMARY KEY,
    convocatoria_id  CHAR(36)     NOT NULL REFERENCES convocatorias(id) ON DELETE CASCADE,
    nombre           VARCHAR(150) NOT NULL,
    UNIQUE (convocatoria_id, nombre)
);

CREATE TABLE convocatoria_fuentes (
    convocatoria_id  CHAR(36) NOT NULL REFERENCES convocatorias(id) ON DELETE CASCADE,
    fuente_id        INTEGER  NOT NULL REFERENCES cat_fuentes_informacion(id),
    PRIMARY KEY (convocatoria_id, fuente_id)
);


-- =====================================================================================
-- 4. PROYECTOS (tabla central)
-- =====================================================================================

CREATE TABLE proyectos (
    id                                 CHAR(36)      NOT NULL PRIMARY KEY,
    codigo_proyecto                    VARCHAR(50)   NOT NULL UNIQUE,
    convocatoria_id                    CHAR(36)      NOT NULL REFERENCES convocatorias(id),
    titulo                             VARCHAR(300)  NOT NULL,
    titulo_ingles                      VARCHAR(300),
    resumen                            TEXT,
    investigador_principal_id          CHAR(36)      NOT NULL REFERENCES usuarios(id),
    departamento_id                    INTEGER       NOT NULL REFERENCES cat_departamentos(id),

    -- Metadatos académicos / científicos
    programa_postgrado_id              INTEGER       REFERENCES cat_programas_postgrado(id),
    linea_investigacion_id             INTEGER       NOT NULL REFERENCES cat_lineas_investigacion(id),
    grupo_investigacion_id             INTEGER       NOT NULL REFERENCES cat_grupos_investigacion(id),
    tipo_investigacion_id              INTEGER       NOT NULL REFERENCES cat_tipos_investigacion(id),
    disciplina_cientifica_id           INTEGER       NOT NULL REFERENCES cat_disciplinas_cientificas(id),
    objetivo_socioeconomico_id         INTEGER       NOT NULL REFERENCES cat_objetivos_socioeconomicos(id),
    area_conocimiento_espe_id          INTEGER       NOT NULL REFERENCES cat_areas_conocimiento_espe(id),
    subarea_unesco_id                  INTEGER       NOT NULL REFERENCES cat_subareas_unesco(id),
    campo_detallado_id                 INTEGER       NOT NULL REFERENCES cat_campos_detallados(id),

    tipo_financiamiento                VARCHAR(10)   NOT NULL DEFAULT 'DIRECTO'
                                       CHECK (tipo_financiamiento IN ('DIRECTO','INDIRECTO')),  -- BBSRC: indirecto
    fecha_adjudicacion_externa         DATE          NOT NULL,
    fecha_limite_registro              DATE,         -- regla RN-01: adjudicación + 60 días hábiles
    fecha_registro                     DATE,

    -- Presupuesto en 4 rubros (total en vista v_proyecto_presupuesto)
    presupuesto_inversion_espe         DECIMAL(14,2) NOT NULL DEFAULT 0 CHECK (presupuesto_inversion_espe >= 0),
    presupuesto_corriente_espe         DECIMAL(14,2) NOT NULL DEFAULT 0 CHECK (presupuesto_corriente_espe >= 0),
    presupuesto_inversion_auspiciante  DECIMAL(14,2) NOT NULL DEFAULT 0 CHECK (presupuesto_inversion_auspiciante >= 0),
    presupuesto_corriente_auspiciante  DECIMAL(14,2) NOT NULL DEFAULT 0 CHECK (presupuesto_corriente_auspiciante >= 0),

    fecha_inicio_ejecucion             DATE,
    fecha_fin_planificada              DATE,
    fecha_fin_real                     DATE,
    estado                             VARCHAR(30)   NOT NULL DEFAULT 'EN_EDICION'
                                       CHECK (estado IN ('EN_EDICION','POSTULADO','EN_REVISION_DEPARTAMENTAL',
                                              'EN_REVISION_UGI','APROBADO','EN_EJECUCION','EN_CIERRE',
                                              'BLOQUEADO','CERRADO','RECHAZADO')),
    created_at                         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (fecha_fin_planificada IS NULL OR fecha_inicio_ejecucion IS NULL
           OR fecha_fin_planificada >= fecha_inicio_ejecucion)
);

CREATE TABLE proyecto_aprobaciones (
    id                CHAR(36)    NOT NULL PRIMARY KEY,
    proyecto_id       CHAR(36)    NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    nivel             VARCHAR(20) NOT NULL CHECK (nivel IN ('DEPARTAMENTO','UGI')),
    aprobador_id      CHAR(36)    REFERENCES usuarios(id),
    fecha_solicitud   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_resolucion  TIMESTAMP,
    estado            VARCHAR(20) NOT NULL DEFAULT 'PENDIENTE'
                      CHECK (estado IN ('PENDIENTE','APROBADO','RECHAZADO','DEVUELTO')),
    observaciones     TEXT,
    UNIQUE (proyecto_id, nivel)
);

CREATE TABLE proyecto_requisitos_documentales (
    id                 CHAR(36)     NOT NULL PRIMARY KEY,
    proyecto_id        CHAR(36)     NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    tipo_requisito_id  INTEGER      NOT NULL REFERENCES cat_tipos_requisito_documental(id),
    archivo_url        VARCHAR(400),
    fecha_carga        TIMESTAMP,
    cargado_por        CHAR(36)     REFERENCES usuarios(id),
    estado             VARCHAR(20)  NOT NULL DEFAULT 'PENDIENTE'
                       CHECK (estado IN ('PENDIENTE','CARGADO','VALIDADO','RECHAZADO')),
    observaciones      TEXT,
    UNIQUE (proyecto_id, tipo_requisito_id)
);

-- Aportes al proyecto por entidad: financiador externo, ESPE o institución socia, en
-- efectivo o en especie (p. ej. contraparte del 30 % en CEDIA, gastos asumidos por INOCAR).
CREATE TABLE proyecto_aportes (
    id                       CHAR(36)      NOT NULL PRIMARY KEY,
    proyecto_id              CHAR(36)      NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    tipo_aportante           VARCHAR(25)   NOT NULL CHECK (tipo_aportante IN
                                           ('ESPE','ENTIDAD_FINANCIADORA','INSTITUCION_SOCIA')),
    entidad_financiadora_id  INTEGER       REFERENCES cat_entidades_financiadoras(id),
    institucion_socia_id     INTEGER       REFERENCES cat_instituciones_socias(id),
    tipo_aporte              VARCHAR(10)   NOT NULL CHECK (tipo_aporte IN ('EFECTIVO','ESPECIE')),
    concepto                 VARCHAR(200),
    monto                    DECIMAL(14,2) NOT NULL CHECK (monto >= 0),
    moneda_id                INTEGER       NOT NULL REFERENCES cat_monedas(id),
    created_at               TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (
        (tipo_aportante = 'ESPE'                 AND entidad_financiadora_id IS NULL     AND institucion_socia_id IS NULL) OR
        (tipo_aportante = 'ENTIDAD_FINANCIADORA' AND entidad_financiadora_id IS NOT NULL AND institucion_socia_id IS NULL) OR
        (tipo_aportante = 'INSTITUCION_SOCIA'    AND institucion_socia_id IS NOT NULL    AND entidad_financiadora_id IS NULL)
    )
);


-- =====================================================================================
-- 5. EQUIPO DEL PROYECTO Y LIBERACIÓN DE HORAS
-- =====================================================================================

CREATE TABLE proyecto_equipo (
    id                      CHAR(36)     NOT NULL PRIMARY KEY,
    proyecto_id             CHAR(36)     NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    rol_proyecto_id         INTEGER      NOT NULL REFERENCES cat_roles_proyecto(id),
    usuario_id              CHAR(36)     REFERENCES usuarios(id),                 -- interno (NULL si externo)
    externo_identificacion  VARCHAR(20),
    externo_nombres         VARCHAR(150),
    externo_apellidos       VARCHAR(150),
    externo_institucion_id  INTEGER      REFERENCES cat_instituciones_socias(id),
    externo_correo          VARCHAR(150),
    fecha_incorporacion     DATE         NOT NULL DEFAULT CURRENT_DATE,
    fecha_salida            DATE,
    CHECK (
        (usuario_id IS NOT NULL AND externo_identificacion IS NULL
            AND externo_nombres IS NULL AND externo_apellidos IS NULL)
        OR
        (usuario_id IS NULL AND externo_identificacion IS NOT NULL
            AND externo_nombres IS NOT NULL AND externo_apellidos IS NOT NULL)
    )
    -- RN-02: un mismo usuario / identificación externa no se repite en el mismo proyecto
);

CREATE TABLE liberacion_horas (
    id                     CHAR(36)     NOT NULL PRIMARY KEY,
    proyecto_id            CHAR(36)     NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    usuario_id             CHAR(36)     NOT NULL REFERENCES usuarios(id),
    periodo_academico_id   INTEGER      NOT NULL REFERENCES cat_periodos_academicos(id),
    horas_semanales        DECIMAL(5,2) NOT NULL CHECK (horas_semanales > 0),
    horas_totales_periodo  DECIMAL(6,2),
    justificacion          TEXT         NOT NULL,
    estado                 VARCHAR(20)  NOT NULL DEFAULT 'SOLICITADA'
                           CHECK (estado IN ('SOLICITADA','APROBADA','RECHAZADA','FINALIZADA')),
    aprobado_por           CHAR(36)     REFERENCES usuarios(id),
    fecha_aprobacion       TIMESTAMP,
    UNIQUE (proyecto_id, usuario_id, periodo_academico_id)
);


-- =====================================================================================
-- 6. FORMULACIÓN: objetivos, riesgos, impactos, ODS y texto largo
-- =====================================================================================

CREATE TABLE proyecto_objetivos (
    id                   CHAR(36)    NOT NULL PRIMARY KEY,
    proyecto_id          CHAR(36)    NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    tipo_objetivo        VARCHAR(12) NOT NULL CHECK (tipo_objetivo IN ('GENERAL','ESPECIFICO')),
    objetivo_general_id  CHAR(36)    REFERENCES proyecto_objetivos(id),          -- autorreferencia
    descripcion          TEXT        NOT NULL,
    indicador            TEXT,
    meta                 TEXT,
    orden                SMALLINT,
    CHECK (
        (tipo_objetivo = 'GENERAL'    AND objetivo_general_id IS NULL) OR
        (tipo_objetivo = 'ESPECIFICO' AND objetivo_general_id IS NOT NULL)
    )
);

CREATE TABLE proyecto_riesgos (
    id                    CHAR(36)    NOT NULL PRIMARY KEY,
    proyecto_id           CHAR(36)    NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    objetivo_afectado_id  CHAR(36)    REFERENCES proyecto_objetivos(id),
    riesgo                TEXT        NOT NULL,
    probabilidad          VARCHAR(5)  NOT NULL CHECK (probabilidad IN ('ALTO','MEDIO','BAJO')),
    impacto               VARCHAR(5)  NOT NULL CHECK (impacto      IN ('ALTO','MEDIO','BAJO')),
    accion_mitigacion     TEXT        NOT NULL,
    created_at            TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE proyecto_impactos (
    id           CHAR(36)    NOT NULL PRIMARY KEY,
    proyecto_id  CHAR(36)    NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    categoria    VARCHAR(25) NOT NULL CHECK (categoria IN ('SOCIAL','CIENTIFICO','ECONOMICO',
                                             'POLITICO','AMBIENTAL','SOSTENIBILIDAD_GENERO')),
    descripcion  TEXT        NOT NULL,
    created_at   TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE proyecto_ods_metas (
    proyecto_id  CHAR(36) NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    ods_meta_id  INTEGER  NOT NULL REFERENCES cat_ods_metas(id),
    PRIMARY KEY (proyecto_id, ods_meta_id)
);

-- Relación 1:1 con proyectos (comparte la PK)
CREATE TABLE proyecto_formulacion (
    proyecto_id                        CHAR(36)  NOT NULL PRIMARY KEY REFERENCES proyectos(id) ON DELETE CASCADE,
    diagnostico_problema               TEXT,
    linea_base                         TEXT,
    metodologia_investigacion          TEXT,
    viabilidad_tecnica                 TEXT,
    estrategia_difusion_transferencia  TEXT,
    updated_at                         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================================================
-- 7. HITOS Y TAREAS (seguimiento tipo Gantt)
-- =====================================================================================

CREATE TABLE hitos (
    id                        CHAR(36)     NOT NULL PRIMARY KEY,
    proyecto_id               CHAR(36)     NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    objetivo_especifico_id    CHAR(36)     REFERENCES proyecto_objetivos(id),
    nombre                    VARCHAR(250) NOT NULL,
    descripcion               TEXT,
    orden                     SMALLINT,
    fecha_inicio_planificada  DATE         NOT NULL,
    fecha_fin_planificada     DATE         NOT NULL,
    fecha_inicio_real         DATE,
    fecha_fin_real            DATE,
    porcentaje_avance         SMALLINT     NOT NULL DEFAULT 0 CHECK (porcentaje_avance BETWEEN 0 AND 100),
    estado                    VARCHAR(15)  NOT NULL DEFAULT 'NO_INICIADO'
                              CHECK (estado IN ('NO_INICIADO','EN_PROGRESO','COMPLETADO','ATRASADO','CANCELADO')),
    created_at                TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (fecha_fin_planificada >= fecha_inicio_planificada)
);

CREATE TABLE tareas (
    id                        CHAR(36)     NOT NULL PRIMARY KEY,
    hito_id                   CHAR(36)     NOT NULL REFERENCES hitos(id) ON DELETE CASCADE,
    nombre                    VARCHAR(250) NOT NULL,
    descripcion               TEXT,
    responsable_id            CHAR(36)     REFERENCES usuarios(id),
    fecha_inicio_planificada  DATE         NOT NULL,
    fecha_fin_planificada     DATE         NOT NULL,
    fecha_inicio_real         DATE,
    fecha_fin_real            DATE,
    porcentaje_avance         SMALLINT     NOT NULL DEFAULT 0 CHECK (porcentaje_avance BETWEEN 0 AND 100),
    recursos_asignados        TEXT,
    estado                    VARCHAR(15)  NOT NULL DEFAULT 'NO_INICIADO'
                              CHECK (estado IN ('NO_INICIADO','EN_PROGRESO','COMPLETADO','ATRASADO','CANCELADO')),
    CHECK (fecha_fin_planificada >= fecha_inicio_planificada)
);


-- =====================================================================================
-- 8. INFORMES DE SEGUIMIENTO (calendario dual EXTERNO / INTERNO)
-- =====================================================================================

CREATE TABLE periodos_reporte (
    id                       CHAR(36)     NOT NULL PRIMARY KEY,
    tipo                     VARCHAR(10)  NOT NULL CHECK (tipo IN ('EXTERNO','INTERNO')),
    entidad_financiadora_id  INTEGER      REFERENCES cat_entidades_financiadoras(id),
    periodo_academico_id     INTEGER      REFERENCES cat_periodos_academicos(id),
    anio                     SMALLINT     NOT NULL,
    fecha_corte              DATE         NOT NULL,
    etiqueta                 VARCHAR(100) NOT NULL,
    CHECK (
        (tipo = 'EXTERNO' AND entidad_financiadora_id IS NOT NULL AND periodo_academico_id IS NULL) OR
        (tipo = 'INTERNO' AND periodo_academico_id IS NOT NULL AND entidad_financiadora_id IS NULL)
    ),
    UNIQUE (tipo, entidad_financiadora_id, periodo_academico_id, fecha_corte)
);

CREATE TABLE informes_seguimiento (
    id                            CHAR(36)     NOT NULL PRIMARY KEY,
    proyecto_id                   CHAR(36)     NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    periodo_reporte_id            CHAR(36)     NOT NULL REFERENCES periodos_reporte(id),
    fecha_limite_presentacion     DATE         NOT NULL,
    fecha_presentacion            TIMESTAMP,
    archivo_url                   VARCHAR(400),
    avance_tecnico_pct            SMALLINT     CHECK (avance_tecnico_pct    BETWEEN 0 AND 100),
    avance_financiero_pct         SMALLINT     CHECK (avance_financiero_pct BETWEEN 0 AND 100),
    horas_liberadas_justificadas  DECIMAL(6,2),
    estado                        VARCHAR(15)  NOT NULL DEFAULT 'PENDIENTE'
                                  CHECK (estado IN ('PENDIENTE','EN_ELABORACION','PRESENTADO',
                                                    'OBSERVADO','APROBADO','ATRASADO')),
    observaciones                 TEXT,
    presentado_por                CHAR(36)     REFERENCES usuarios(id),
    created_at                    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (proyecto_id, periodo_reporte_id)
);


-- =====================================================================================
-- 9. PRÓRROGAS Y CIERRE
-- =====================================================================================

CREATE TABLE prorrogas (
    id                          CHAR(36)     NOT NULL PRIMARY KEY,
    proyecto_id                 CHAR(36)     NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    fecha_solicitud             TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento_original  DATE         NOT NULL,
    fecha_nueva_vencimiento     DATE         NOT NULL,
    motivo                      TEXT         NOT NULL,
    documento_aval_externo_url  VARCHAR(400) NOT NULL,
    estado                      VARCHAR(20)  NOT NULL DEFAULT 'SOLICITADA'
                                CHECK (estado IN ('SOLICITADA','AVALADA_EXTERNO','RECHAZADA','APLICADA')),
    fecha_aval_externo          DATE,
    solicitado_por              CHAR(36)     REFERENCES usuarios(id),
    aprobado_por                CHAR(36)     REFERENCES usuarios(id),
    CHECK (fecha_nueva_vencimiento > fecha_vencimiento_original)
);

CREATE TABLE cierres_proyecto (
    id                    CHAR(36)     NOT NULL PRIMARY KEY,
    proyecto_id           CHAR(36)     NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    fecha_cierre          DATE,
    certificado_aval_url  VARCHAR(400),
    estado                VARCHAR(20)  NOT NULL DEFAULT 'EN_PROCESO'
                          CHECK (estado IN ('EN_PROCESO','CERTIFICADO_EMITIDO','OBSERVADO')),
    aprobado_por          CHAR(36)     REFERENCES usuarios(id),
    observaciones         TEXT,
    created_at            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================================================
-- 10. RESULTADOS E IMPACTO
-- =====================================================================================

CREATE TABLE publicaciones (
    id                 CHAR(36)     NOT NULL PRIMARY KEY,
    proyecto_id        CHAR(36)     NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    titulo             VARCHAR(400) NOT NULL,
    tipo               VARCHAR(15)  NOT NULL DEFAULT 'ARTICULO'
                       CHECK (tipo IN ('ARTICULO','LIBRO','CAPITULO_LIBRO','PONENCIA','OTRO')),
    revista_evento     VARCHAR(250),
    doi                VARCHAR(150),
    fecha_publicacion  DATE,
    indexacion         VARCHAR(100),                    -- Scopus, WoS, Latindex, ...
    url                VARCHAR(400),
    created_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE publicacion_autores (
    publicacion_id        CHAR(36)     NOT NULL REFERENCES publicaciones(id) ON DELETE CASCADE,
    orden_autor           SMALLINT     NOT NULL,
    usuario_id            CHAR(36)     REFERENCES usuarios(id),
    nombre_autor_externo  VARCHAR(200),
    PRIMARY KEY (publicacion_id, orden_autor),
    CHECK (usuario_id IS NOT NULL OR nombre_autor_externo IS NOT NULL)
);

CREATE TABLE patentes (
    id               CHAR(36)     NOT NULL PRIMARY KEY,
    proyecto_id      CHAR(36)     NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    titulo           VARCHAR(400) NOT NULL,
    numero_registro  VARCHAR(100),
    pais_id          INTEGER      REFERENCES cat_paises(id),
    fecha_solicitud  DATE,
    fecha_concesion  DATE,
    estado           VARCHAR(15)  NOT NULL DEFAULT 'EN_TRAMITE'
                     CHECK (estado IN ('EN_TRAMITE','CONCEDIDA','RECHAZADA')),
    url_documento    VARCHAR(400)
);

CREATE TABLE indice_h_historico (
    id              CHAR(36)    NOT NULL PRIMARY KEY,
    usuario_id      CHAR(36)    NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    valor           SMALLINT    NOT NULL CHECK (valor >= 0),
    fecha_medicion  DATE        NOT NULL DEFAULT CURRENT_DATE,
    fuente          VARCHAR(50) NOT NULL,                -- Scopus, Google Scholar, WoS, ...
    UNIQUE (usuario_id, fecha_medicion, fuente)
);

CREATE TABLE proyecto_instituciones_socias (
    proyecto_id           CHAR(36)     NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
    institucion_socia_id  INTEGER      NOT NULL REFERENCES cat_instituciones_socias(id),
    tipo_cooperacion      VARCHAR(100),                  -- Movilidad, Copublicación, Cofinanciamiento, ...
    fecha_vinculacion     DATE         NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (proyecto_id, institucion_socia_id)
);


-- =====================================================================================
-- 11. ALERTAS Y NOTIFICACIONES
-- =====================================================================================

CREATE TABLE eventos_notificacion (
    id                      CHAR(36)    NOT NULL PRIMARY KEY,
    proyecto_id             CHAR(36)    REFERENCES proyectos(id) ON DELETE CASCADE,
    tipo_alerta_id          INTEGER     NOT NULL REFERENCES cat_tipos_alerta(id),
    usuario_destino_id      CHAR(36)    NOT NULL REFERENCES usuarios(id),
    fecha_programada        TIMESTAMP   NOT NULL,
    fecha_envio             TIMESTAMP,
    canal                   VARCHAR(10) NOT NULL DEFAULT 'SISTEMA' CHECK (canal IN ('EMAIL','SISTEMA','SMS')),
    estado                  VARCHAR(10) NOT NULL DEFAULT 'PENDIENTE'
                            CHECK (estado IN ('PENDIENTE','ENVIADA','LEIDA','FALLIDA')),
    mensaje                 TEXT        NOT NULL,
    tabla_referencia        VARCHAR(50),                 -- referencia polimórfica (sin FK)
    registro_referencia_id  CHAR(36),
    metadata                TEXT,                        -- JSON serializado
    created_at              TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- =====================================================================================
-- 12. ÍNDICES (claves foráneas y filtros frecuentes)
-- =====================================================================================

CREATE INDEX idx_lineas_dominio             ON cat_lineas_investigacion(dominio_academico_id);
CREATE INDEX idx_subareas_area              ON cat_subareas_unesco(area_unesco_id);
CREATE INDEX idx_camposesp_amplio           ON cat_campos_especificos(campo_amplio_id);
CREATE INDEX idx_camposdet_especifico       ON cat_campos_detallados(campo_especifico_id);
CREATE INDEX idx_ods_metas_ods              ON cat_ods_metas(ods_id);
CREATE INDEX idx_programas_padre            ON programas_financiamiento(programa_padre_id);
CREATE INDEX idx_programas_tipo             ON programas_financiamiento(tipo_oportunidad_id);
CREATE INDEX idx_convocatorias_programa     ON convocatorias(programa_id);
CREATE INDEX idx_convocatorias_entidad      ON convocatorias(entidad_financiadora_id);
CREATE INDEX idx_convocatorias_tipo         ON convocatorias(tipo_oportunidad_id);
CREATE INDEX idx_convocatorias_estado       ON convocatorias(estado);
CREATE INDEX idx_convocatorias_cierre       ON convocatorias(fecha_cierre);
CREATE INDEX idx_conv_fases_conv            ON convocatoria_fases(convocatoria_id);
CREATE INDEX idx_conv_requisitos_conv       ON convocatoria_requisitos(convocatoria_id);
CREATE INDEX idx_conv_coberturas_conv       ON convocatoria_coberturas(convocatoria_id);
CREATE INDEX idx_aportes_proyecto           ON proyecto_aportes(proyecto_id);
CREATE INDEX idx_proyectos_estado           ON proyectos(estado);
CREATE INDEX idx_proyectos_investigador     ON proyectos(investigador_principal_id);
CREATE INDEX idx_proyectos_departamento     ON proyectos(departamento_id);
CREATE INDEX idx_proyectos_convocatoria     ON proyectos(convocatoria_id);
CREATE INDEX idx_proyectos_fecha_limite     ON proyectos(fecha_limite_registro);
CREATE INDEX idx_proyectos_linea            ON proyectos(linea_investigacion_id);
CREATE INDEX idx_proyectos_grupo            ON proyectos(grupo_investigacion_id);
CREATE INDEX idx_proyectos_campo_detallado  ON proyectos(campo_detallado_id);
CREATE INDEX idx_aprobaciones_proyecto      ON proyecto_aprobaciones(proyecto_id);
CREATE INDEX idx_requisitos_proyecto        ON proyecto_requisitos_documentales(proyecto_id);
CREATE INDEX idx_equipo_proyecto            ON proyecto_equipo(proyecto_id);
CREATE INDEX idx_equipo_usuario             ON proyecto_equipo(usuario_id);
CREATE INDEX idx_equipo_rol                 ON proyecto_equipo(rol_proyecto_id);
CREATE INDEX idx_liberacion_usuario         ON liberacion_horas(usuario_id);
CREATE INDEX idx_liberacion_periodo         ON liberacion_horas(periodo_academico_id);
CREATE INDEX idx_objetivos_proyecto         ON proyecto_objetivos(proyecto_id);
CREATE INDEX idx_objetivos_general          ON proyecto_objetivos(objetivo_general_id);
CREATE INDEX idx_riesgos_proyecto           ON proyecto_riesgos(proyecto_id);
CREATE INDEX idx_impactos_proyecto          ON proyecto_impactos(proyecto_id);
CREATE INDEX idx_hitos_proyecto             ON hitos(proyecto_id);
CREATE INDEX idx_hitos_objetivo             ON hitos(objetivo_especifico_id);
CREATE INDEX idx_tareas_hito                ON tareas(hito_id);
CREATE INDEX idx_tareas_responsable         ON tareas(responsable_id);
CREATE INDEX idx_periodos_reporte_tipo      ON periodos_reporte(tipo);
CREATE INDEX idx_informes_proyecto          ON informes_seguimiento(proyecto_id);
CREATE INDEX idx_informes_estado            ON informes_seguimiento(estado);
CREATE INDEX idx_prorrogas_proyecto         ON prorrogas(proyecto_id);
CREATE INDEX idx_cierres_proyecto           ON cierres_proyecto(proyecto_id);
CREATE INDEX idx_publicaciones_proyecto     ON publicaciones(proyecto_id);
CREATE INDEX idx_patentes_proyecto          ON patentes(proyecto_id);
CREATE INDEX idx_indice_h_usuario           ON indice_h_historico(usuario_id);
CREATE INDEX idx_notif_programada           ON eventos_notificacion(fecha_programada, estado);
CREATE INDEX idx_notif_destino              ON eventos_notificacion(usuario_destino_id);
CREATE INDEX idx_notif_proyecto             ON eventos_notificacion(proyecto_id);


-- =====================================================================================
-- 13. VISTA: presupuesto total (reemplaza la columna generada de PostgreSQL)
-- =====================================================================================

CREATE VIEW v_proyecto_presupuesto AS
SELECT p.id,
       p.codigo_proyecto,
       p.presupuesto_inversion_espe,
       p.presupuesto_corriente_espe,
       p.presupuesto_inversion_auspiciante,
       p.presupuesto_corriente_auspiciante,
       p.presupuesto_inversion_espe + p.presupuesto_corriente_espe
     + p.presupuesto_inversion_auspiciante + p.presupuesto_corriente_auspiciante AS presupuesto_total
FROM proyectos p;


-- =====================================================================================
-- 14. REGLAS DE NEGOCIO (en el original son triggers PL/pgSQL; implementar en la
--     aplicación o con triggers del motor elegido)
-- =====================================================================================
-- RN-01  Al crear un proyecto, fecha_limite_registro = fecha_adjudicacion_externa + 60 días
--        hábiles (lunes a viernes) y se programa una alerta VENCIMIENTO_REGISTRO_60D.
-- RN-02  proyecto_equipo: (proyecto_id, usuario_id) único cuando usuario_id no es NULL, y
--        (proyecto_id, externo_identificacion) único cuando es externo.
-- RN-03  Si proyectos.estado = 'BLOQUEADO' no se pueden insertar/actualizar hitos ni
--        informes_seguimiento hasta que se aplique una prórroga avalada.
-- RN-04  proyecto_objetivos: un objetivo ESPECIFICO debe apuntar a un objetivo GENERAL
--        del mismo proyecto.
-- RN-05  hitos.objetivo_especifico_id y proyecto_riesgos.objetivo_afectado_id deben
--        pertenecer al mismo proyecto que el hito/riesgo.
-- RN-06  updated_at se actualiza en cada UPDATE (usuarios, convocatorias, proyectos,
--        hitos, proyecto_formulacion).
-- RN-07  Flujo de estados del proyecto:
--        EN_EDICION -> POSTULADO -> EN_REVISION_DEPARTAMENTAL -> EN_REVISION_UGI -> APROBADO
--        -> EN_EJECUCION -> EN_CIERRE -> CERRADO   (RECHAZADO / BLOQUEADO como desvíos)
-- RN-08  Contraparte: la suma de aportes que no son de la entidad financiadora debe ser al
--        menos convocatorias.porcentaje_contraparte_min del total del proyecto.
-- RN-09  El aporte de la entidad financiadora no puede superar convocatorias.monto_maximo_proyecto,
--        y cada rubro respeta su tope en convocatoria_coberturas (monto o porcentaje).
-- RN-10  La prórroga solicitada (prorrogas) no puede superar convocatorias.prorroga_max_dias.
-- RN-11  convocatorias.estado se deriva de las fechas: sin fechas = POR_ANUNCIAR; entre
--        apertura y cierre = ABIERTA; después del cierre = CERRADA (ANULADA es manual).
-- RN-12  Un proyecto solo puede vincularse a una convocatoria cuyo tipo de oportunidad
--        financie proyectos (no a becas de movilidad o posgrado individuales).
-- =====================================================================================


-- =====================================================================================
-- 15. DATOS SEMILLA DEL BANCO DE OPORTUNIDADES
--     Los UUID de ejemplo son fijos y legibles; en producción los genera la aplicación.
-- =====================================================================================

INSERT INTO cat_monedas (id, codigo_iso, nombre, simbolo) VALUES
 (1, 'USD', 'Dólar estadounidense', '$'),
 (2, 'EUR', 'Euro', '€'),
 (3, 'GBP', 'Libra esterlina', '£');

INSERT INTO cat_tipos_oportunidad (id, codigo, nombre) VALUES
 (1, 'PROGRAMA_MARCO',          'Programa marco de investigación e innovación'),
 (2, 'FONDO_CONCURSABLE_ID',    'Fondo concursable de proyectos I+D+i'),
 (3, 'CONCURSO_INNOVACION',     'Concurso de proyectos innovadores'),
 (4, 'BECA_MOVILIDAD',          'Beca de movilidad estudiantil'),
 (5, 'BECA_POSGRADO',           'Beca de máster o posgrado'),
 (6, 'BECA_INVESTIGACION',      'Beca o fellowship de investigación'),
 (7, 'MISION',                  'Misión temática'),
 (8, 'CONVOCATORIA_TEMATICA',   'Convocatoria temática (clúster, work programme)'),
 (9, 'APOYO_INNOVACION_EMPRESA','Apoyo a innovación empresarial / PYME');

INSERT INTO cat_tipos_beneficiario (id, codigo, nombre) VALUES
 (1,  'IES_MIEMBRO_CEDIA',          'Institución miembro pleno de CEDIA'),
 (2,  'DOCENTE_INVESTIGADOR',       'Docente o investigador universitario'),
 (3,  'INVESTIGADOR_AUTONOMO',      'Investigador autónomo'),
 (4,  'INSTITUCION_EXTERNA',        'Institución externa no miembro'),
 (5,  'TECNICO_AYUDANTE',           'Técnico o ayudante de investigación'),
 (6,  'ESTUDIANTE_GRADO',           'Estudiante de grado o ciclo corto'),
 (7,  'ESTUDIANTE_POSGRADO',        'Estudiante de máster'),
 (8,  'CANDIDATO_DOCTORAL',         'Candidato doctoral'),
 (9,  'INVESTIGADOR_POSTDOCTORAL',  'Investigador postdoctoral'),
 (10, 'PYME',                       'PYME o empresa innovadora'),
 (11, 'CONSORCIO_INTERNACIONAL',    'Consorcio internacional'),
 (12, 'SECTOR_PUBLICO',             'Sector público / ciudades');

INSERT INTO cat_plataformas_postulacion (id, nombre, url) VALUES
 (1, 'EasyChair',                         'https://easychair.org'),
 (2, 'EU Funding & Tenders Portal',       'https://ec.europa.eu/info/funding-tenders/opportunities/portal'),
 (3, 'University Admissions (Suecia)',    'https://www.universityadmissions.se'),
 (4, 'UKRI Funding Service',              'https://funding-service.ukri.org'),
 (5, 'Oficina internacional de la IES',   NULL);

INSERT INTO cat_tipos_accion (id, codigo, nombre, trl_min, trl_max, tasa_financiacion_pct, descripcion) VALUES
 (1, 'RIA', 'Research and Innovation Action',   2, 6,    100, 'Investigación colaborativa; presupuestos típicos de 3 a 6 M EUR'),
 (2, 'IA',  'Innovation Action',                4, 7,    NULL, 'Demostración tecnológica; tasa diferenciada según tipo de entidad'),
 (3, 'CSA', 'Coordination and Support Action',  NULL, NULL, 100, 'Trabajo en red, formación y coordinación; no investigación pura');

INSERT INTO cat_paises (id, nombre, codigo_iso) VALUES
 (1, 'Ecuador', 'EC'),
 (2, 'Reino Unido', 'GB');

INSERT INTO cat_entidades_financiadoras (id, nombre, sigla, pais_id, tipo, naturaleza) VALUES
 (1, 'Corporación Ecuatoriana para el Desarrollo de la Investigación y la Academia', 'CEDIA', 1, 'NACIONAL', 'CORPORACION_ACADEMICA'),
 (2, 'Comisión Europea', 'CE', NULL, 'INTERNACIONAL', 'ORGANISMO_SUPRANACIONAL'),
 (3, 'Biotechnology and Biological Sciences Research Council', 'BBSRC', 2, 'INTERNACIONAL', 'PUBLICA');

INSERT INTO cat_fuentes_informacion (id, titulo, referencia_notebook) VALUES
 (1, 'Bases Fondo I+D+i Universidades CEDIA 2024 (fuente del cuaderno)', '1'),
 (8, 'Documentación Horizon Europe / MSCA 2026 (fuente del cuaderno)',     '8');

-- Programas: FONDO I+D+i (CEDIA) y Horizon Europe -> MSCA
INSERT INTO programas_financiamiento (id, programa_padre_id, nombre, sigla, tipo_oportunidad_id, presupuesto_total, moneda_id, anio_inicio, anio_fin, descripcion) VALUES
 ('00000000-0000-0000-0000-00000000a001', NULL, 'FONDO I+D+i Universidades', 'CEPRA', 2, NULL, NULL, NULL, NULL,
  'Fondo concursable de CEDIA para proyectos de investigación entre instituciones miembro (antes CEPRA).'),
 ('00000000-0000-0000-0000-00000000a002', NULL, 'Horizon Europe', 'HE', 1, 95500000000.00, 2, 2021, 2027,
  'Programa marco de la UE. Presupuesto indicativo entre 93.500 y 95.500 millones de EUR.'),
 ('00000000-0000-0000-0000-00000000a003', '00000000-0000-0000-0000-00000000a002', 'Acciones Marie Skłodowska-Curie', 'MSCA', 6, NULL, NULL, 2021, 2027,
  'Pilar 1 de Horizon Europe: becas y movilidad de investigadores.');

INSERT INTO programa_entidades (programa_id, entidad_financiadora_id, rol) VALUES
 ('00000000-0000-0000-0000-00000000a001', 1, 'PROMOTORA'),
 ('00000000-0000-0000-0000-00000000a002', 2, 'PROMOTORA'),
 ('00000000-0000-0000-0000-00000000a003', 2, 'PROMOTORA');

INSERT INTO programa_fuentes (programa_id, fuente_id) VALUES
 ('00000000-0000-0000-0000-00000000a001', 1),
 ('00000000-0000-0000-0000-00000000a002', 8);

-- Convocatorias
INSERT INTO convocatorias (id, programa_id, entidad_financiadora_id, tipo_oportunidad_id, codigo, nombre,
    fecha_apertura, fecha_cierre, moneda_id, presupuesto_total_convocatoria, monto_maximo_proyecto,
    porcentaje_contraparte_min, modalidad_financiamiento, duracion_min_meses, duracion_max_meses,
    prorroga_max_dias, plataforma_postulacion_id, proceso_postulacion, requiere_envio_fisico, estado) VALUES
 ('00000000-0000-0000-0000-00000000c001', '00000000-0000-0000-0000-00000000a001', 1, 2, 'CEDIA-IDI-2024',
  'Fondo I+D+i Universidades 2024', '2024-05-01', '2024-07-01', 1, NULL, 50000.00, 30.00, 'DIRECTO', 12, 12, 90, 1,
  'Registro en EasyChair con formulario y anexos en PDF; cartas con firma física se envían a CEDIA en Cuenca.', TRUE, 'CERRADA'),
 ('00000000-0000-0000-0000-00000000c002', '00000000-0000-0000-0000-00000000a003', 2, 6, 'MSCA-PF-2026',
  'MSCA Postdoctoral Fellowships 2026', '2026-04-09', '2026-09-09', 2, 399050000.00, NULL, NULL, 'BECA', NULL, NULL, NULL, 2,
  'Presentación de propuestas a través del portal de la UE antes del cierre.', FALSE, 'CERRADA');

INSERT INTO convocatoria_fases (id, convocatoria_id, orden, nombre, fecha_inicio, fecha_fin, duracion_meses, prorroga_max_dias) VALUES
 ('00000000-0000-0000-0000-0000000f0001', '00000000-0000-0000-0000-00000000c001', 1, 'Postulación',              '2024-05-01', '2024-07-01', NULL, NULL),
 ('00000000-0000-0000-0000-0000000f0002', '00000000-0000-0000-0000-00000000c001', 2, 'Desarrollo del proyecto',  NULL, NULL, 12, 90),
 ('00000000-0000-0000-0000-0000000f0003', '00000000-0000-0000-0000-00000000c001', 3, 'Gestión del conocimiento', NULL, NULL, 12, NULL);

INSERT INTO convocatoria_requisitos (id, convocatoria_id, orden, categoria, descripcion, valor_minimo, unidad) VALUES
 ('00000000-0000-0000-0000-0000000e0001', '00000000-0000-0000-0000-00000000c001', 1, 'ELEGIBILIDAD', 'Instituciones miembros plenos de CEDIA con contrato vigente de Red Avanzada', NULL, NULL),
 ('00000000-0000-0000-0000-0000000e0002', '00000000-0000-0000-0000-00000000c001', 2, 'CONSORCIO',    'Participación mínima de instituciones miembros plenos', 3, 'instituciones'),
 ('00000000-0000-0000-0000-0000000e0003', '00000000-0000-0000-0000-00000000c001', 3, 'CONSORCIO',    'Sedes en ciudades distintas', 2, 'ciudades'),
 ('00000000-0000-0000-0000-0000000e0004', '00000000-0000-0000-0000-00000000c001', 4, 'EQUIPO',       'Director con título de cuarto nivel y codirector', NULL, NULL),
 ('00000000-0000-0000-0000-0000000e0005', '00000000-0000-0000-0000-00000000c001', 5, 'EQUIPO',       'Integrantes registrados en REDI y ORCID', NULL, NULL),
 ('00000000-0000-0000-0000-0000000e0006', '00000000-0000-0000-0000-00000000c001', 6, 'ACADEMICO',    'MOOC del Fondo I+D+i aprobado', NULL, NULL),
 ('00000000-0000-0000-0000-0000000e0007', '00000000-0000-0000-0000-00000000c001', 7, 'DOCUMENTAL',   'Cartas de compromiso y cesión de derechos firmadas', NULL, NULL),
 ('00000000-0000-0000-0000-0000000e0008', '00000000-0000-0000-0000-00000000c001', 8, 'TECNICO',      'Propuesta original, no continuación de proyectos previos, ejecutada principalmente en Ecuador', NULL, NULL);

INSERT INTO convocatoria_coberturas (id, convocatoria_id, concepto, tipo, tope_monto, tope_porcentaje, periodicidad) VALUES
 ('00000000-0000-0000-0000-0000000b0001', '00000000-0000-0000-0000-00000000c001', 'Honorarios profesionales por técnico', 'MONETARIA', 1000.00, NULL, 'MENSUAL'),
 ('00000000-0000-0000-0000-0000000b0002', '00000000-0000-0000-0000-00000000c001', 'Consultorías',                       'MONETARIA', NULL, 25.00, NULL),
 ('00000000-0000-0000-0000-0000000b0003', '00000000-0000-0000-0000-00000000c001', 'Equipos',                            'MONETARIA', NULL, 40.00, NULL),
 ('00000000-0000-0000-0000-0000000b0004', '00000000-0000-0000-0000-00000000c001', 'Materiales, pasajes y viáticos',     'MONETARIA', NULL, NULL, NULL),
 ('00000000-0000-0000-0000-0000000b0005', '00000000-0000-0000-0000-00000000c001', 'Licencias y publicaciones',          'MONETARIA', NULL, NULL, NULL),
 ('00000000-0000-0000-0000-0000000b0006', '00000000-0000-0000-0000-00000000c001', 'Servicios de gestión del conocimiento','MONETARIA', NULL, NULL, NULL);

INSERT INTO convocatoria_beneficiarios (convocatoria_id, tipo_beneficiario_id) VALUES
 ('00000000-0000-0000-0000-00000000c001', 1), ('00000000-0000-0000-0000-00000000c001', 2),
 ('00000000-0000-0000-0000-00000000c001', 3), ('00000000-0000-0000-0000-00000000c001', 4),
 ('00000000-0000-0000-0000-00000000c001', 5),
 ('00000000-0000-0000-0000-00000000c002', 9);

INSERT INTO convocatoria_fuentes (convocatoria_id, fuente_id) VALUES
 ('00000000-0000-0000-0000-00000000c001', 1),
 ('00000000-0000-0000-0000-00000000c002', 8);
