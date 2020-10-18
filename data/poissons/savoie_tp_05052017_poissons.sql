--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.6
-- Dumped by pg_dump version 9.5.5

-- Started on 2017-05-05 19:04:11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 10 (class 2615 OID 47460)
-- Name: poisson; Type: SCHEMA; Schema: -; Owner: postgres
--

-- CREATE ROLE createur_savoie NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN PASSWORD 'savoie';
-- CREATE ROLE lecteur_savoie NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN PASSWORD 'savoie';
-- create extension postgis
/*
CREATE SCHEMA poisson;

REVOKE ALL ON SCHEMA poisson FROM PUBLIC;
REVOKE ALL ON SCHEMA poisson FROM postgres;
GRANT ALL ON SCHEMA poisson TO postgres;
GRANT ALL ON SCHEMA poisson TO createur_savoie;
GRANT USAGE ON SCHEMA poisson TO lecteur_savoie;
*/

ALTER SCHEMA poisson OWNER TO postgres;

SET search_path = poisson, pg_catalog;



SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 209 (class 1259 OID 48517)
-- Name: campagne; Type: TABLE; Schema: poisson; Owner: createur_savoie
--

CREATE TABLE campagne (
    nom_campagne character varying NOT NULL,
    date_debut date,
    mois_debut integer,
    annee_debut integer,
    date_fin date,
    mois_fin integer,
    annee_fin integer,
    financement character varying
);


ALTER TABLE campagne OWNER TO createur_savoie;

--
-- TOC entry 207 (class 1259 OID 48458)
-- Name: espece; Type: TABLE; Schema: poisson; Owner: createur_savoie
--

CREATE TABLE espece (
    cd_nom integer NOT NULL,
    nom_scientifique character varying,
    nom_vernaculaire character varying,
    famille character varying
);


ALTER TABLE espece OWNER TO createur_savoie;

--
-- TOC entry 4379 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE espece; Type: COMMENT; Schema: poisson; Owner: createur_savoie
--

COMMENT ON TABLE espece IS 'Liste les especes qui sont utiles dans ce domaine d''application. 
A noter : il faut éviter de refaire une table de taxonomie et préférer référencer les dictionnaires existants (TAXREF, WORWS, etc.) 
par leur identifiant (CD_NOM, APHIA_ID, etc.), et ne conserver que le strictement utile à l''application';


--
-- TOC entry 4380 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN espece.cd_nom; Type: COMMENT; Schema: poisson; Owner: createur_savoie
--

COMMENT ON COLUMN espece.cd_nom IS 'Identifiant unique de l''espèce dans le dictionnaire TAXREF';


--
-- TOC entry 200 (class 1259 OID 47473)
-- Name: id_seq; Type: SEQUENCE; Schema: poisson; Owner: postgres
--

CREATE SEQUENCE id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE id_seq OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 52013)
-- Name: mesure; Type: TABLE; Schema: poisson; Owner: createur_savoie
--

CREATE TABLE mesure (
    id_mesure integer NOT NULL,
    prelevement integer NOT NULL,
    espece integer NOT NULL,
    poids numeric,
    nombre_individu integer
);


ALTER TABLE mesure OWNER TO createur_savoie;

--
-- TOC entry 218 (class 1259 OID 52011)
-- Name: mesure_id_mesure_seq; Type: SEQUENCE; Schema: poisson; Owner: createur_savoie
--

CREATE SEQUENCE mesure_id_mesure_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE mesure_id_mesure_seq OWNER TO createur_savoie;

--
-- TOC entry 4384 (class 0 OID 0)
-- Dependencies: 218
-- Name: mesure_id_mesure_seq; Type: SEQUENCE OWNED BY; Schema: poisson; Owner: createur_savoie
--

ALTER SEQUENCE mesure_id_mesure_seq OWNED BY mesure.id_mesure;


--
-- TOC entry 208 (class 1259 OID 48482)
-- Name: methode; Type: TABLE; Schema: poisson; Owner: createur_savoie
--

CREATE TABLE methode (
    nom_methode character varying NOT NULL,
    description character varying,
    url character varying
);


ALTER TABLE methode OWNER TO createur_savoie;

--
-- TOC entry 214 (class 1259 OID 51685)
-- Name: personne; Type: TABLE; Schema: poisson; Owner: createur_savoie
--

CREATE TABLE personne (
    id_personne integer NOT NULL,
    nom character varying,
    prenom character varying,
    courriel character varying,
    organisme character varying,
    statut character varying,
    statut_a_choisir character varying
);


ALTER TABLE personne OWNER TO createur_savoie;

--
-- TOC entry 213 (class 1259 OID 51683)
-- Name: personne_id_personne_seq; Type: SEQUENCE; Schema: poisson; Owner: createur_savoie
--

CREATE SEQUENCE personne_id_personne_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE personne_id_personne_seq OWNER TO createur_savoie;

--
-- TOC entry 4388 (class 0 OID 0)
-- Dependencies: 213
-- Name: personne_id_personne_seq; Type: SEQUENCE OWNED BY; Schema: poisson; Owner: createur_savoie
--

ALTER SEQUENCE personne_id_personne_seq OWNED BY personne.id_personne;


--
-- TOC entry 217 (class 1259 OID 51928)
-- Name: prelevement; Type: TABLE; Schema: poisson; Owner: createur_savoie
--

CREATE TABLE prelevement (
    id_prelevement integer NOT NULL,
    date_prelevement date,
    nom_station character varying,
    nom_campagne character varying,
    methode_prelevement character varying,
    caracteristique character varying
);


ALTER TABLE prelevement OWNER TO createur_savoie;

--
-- TOC entry 216 (class 1259 OID 51926)
-- Name: prelevement_id_prelevement_seq; Type: SEQUENCE; Schema: poisson; Owner: createur_savoie
--

CREATE SEQUENCE prelevement_id_prelevement_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE prelevement_id_prelevement_seq OWNER TO createur_savoie;

--
-- TOC entry 4391 (class 0 OID 0)
-- Dependencies: 216
-- Name: prelevement_id_prelevement_seq; Type: SEQUENCE OWNED BY; Schema: poisson; Owner: createur_savoie
--

ALTER SEQUENCE prelevement_id_prelevement_seq OWNED BY prelevement.id_prelevement;


--
-- TOC entry 215 (class 1259 OID 51718)
-- Name: responsable_campagne; Type: TABLE; Schema: poisson; Owner: createur_savoie
--

CREATE TABLE responsable_campagne (
    id_personne integer NOT NULL,
    nom_campagne character varying NOT NULL
);


ALTER TABLE responsable_campagne OWNER TO createur_savoie;

--
-- TOC entry 210 (class 1259 OID 48559)
-- Name: station; Type: TABLE; Schema: poisson; Owner: createur_savoie
--

CREATE TABLE station (
    nom_station character varying NOT NULL,
    longitude numeric,
    latitude numeric,
    descriptif character varying,
    commune character varying,
    geom_point public.geometry(Point,4326)
);


ALTER TABLE station OWNER TO createur_savoie;

--
-- TOC entry 4214 (class 2604 OID 52016)
-- Name: id_mesure; Type: DEFAULT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY mesure ALTER COLUMN id_mesure SET DEFAULT nextval('mesure_id_mesure_seq'::regclass);


--
-- TOC entry 4212 (class 2604 OID 51688)
-- Name: id_personne; Type: DEFAULT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY personne ALTER COLUMN id_personne SET DEFAULT nextval('personne_id_personne_seq'::regclass);


--
-- TOC entry 4213 (class 2604 OID 51931)
-- Name: id_prelevement; Type: DEFAULT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY prelevement ALTER COLUMN id_prelevement SET DEFAULT nextval('prelevement_id_prelevement_seq'::regclass);


--
-- TOC entry 4364 (class 0 OID 48517)
-- Dependencies: 209
-- Data for Name: campagne; Type: TABLE DATA; Schema: poisson; Owner: createur_savoie
--

INSERT INTO campagne (nom_campagne, date_debut, mois_debut, annee_debut, date_fin, mois_fin, annee_fin, financement) VALUES ('Suivi des Ablettes', '2010-06-01', 6, 2009, '2009-07-31', NULL, NULL, 'Labex BCDIV');
INSERT INTO campagne (nom_campagne, date_debut, mois_debut, annee_debut, date_fin, mois_fin, annee_fin, financement) VALUES ('Lac Bourget 2013-2', '2013-06-30', NULL, NULL, '2014-01-10', NULL, NULL, 'Fond propre');
INSERT INTO campagne (nom_campagne, date_debut, mois_debut, annee_debut, date_fin, mois_fin, annee_fin, financement) VALUES ('Lac Bourget 2013', '2013-04-01', NULL, NULL, '2013-06-30', NULL, NULL, 'ANR Poissons');
INSERT INTO campagne (nom_campagne, date_debut, mois_debut, annee_debut, date_fin, mois_fin, annee_fin, financement) VALUES ('Savoie 2010', '2010-06-01', NULL, NULL, '2010-06-15', NULL, NULL, 'ERC Evolution');
INSERT INTO campagne (nom_campagne, date_debut, mois_debut, annee_debut, date_fin, mois_fin, annee_fin, financement) VALUES ('France 2017', '2017-04-28', NULL, NULL, '2017-06-30', NULL, NULL, 'PEPS ');
INSERT INTO campagne (nom_campagne, date_debut, mois_debut, annee_debut, date_fin, mois_fin, annee_fin, financement) VALUES ('Aix Les Bains 2016', '2017-03-01', NULL, NULL, '2017-03-31', NULL, NULL, 'PIA');


--
-- TOC entry 4362 (class 0 OID 48458)
-- Dependencies: 207
-- Data for Name: espece; Type: TABLE DATA; Schema: poisson; Owner: createur_savoie
--

INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67778, 'Salmo trutta fario', 'Truite de rivière', 'Salmonidae                                       ');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67854, 'Coregonus albula', 'Corégone blanc', 'Salmonidae                                                  ');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67812, 'Salvelinus alpinus', 'Omble chevalier', 'Salmonidae                                ');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67804, 'Oncorhynchus mykiss', 'Truite arc-en-ciel', 'Salmonidae                 ');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67819, 'Salvelinus namaycush', 'Cristivomer', 'Salmonidae   ');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67759, 'Thymallus thymallus', 'Ombre commun', 'Salmonidae                                  ');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67794, 'Hucho hucho', 'Huchon', 'Salmonidae  ');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67765, 'Salmo salar', 'Saumon atlantique', 'Salmonidae          ');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67111, 'Alburnus alburnus', 'Ablette', 'Cyprinidae');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67466, 'Scardinius erythrophthalmus', 'Rotengle', 'Cyprinidae');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67335, 'Telestes souffia', 'Blageon', 'Cyprinidae');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67404, 'Phoxinus phoxinus', 'Vairon', 'Cyprinidae');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67074, 'Abramis brama', 'Brème commune', 'Cyprinidae');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67203, 'Blicca bjoerkna', 'Brème bordelière', 'Cyprinidae');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (67606, 'Esox lucius', 'Brochet', 'Esocidae');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (69350, 'Perca fluviatilis', 'Perche', 'Percidae');
INSERT INTO espece (cd_nom, nom_scientifique, nom_vernaculaire, famille) VALUES (69354, 'Gymnocephalus cernuus', 'Grémille', 'Percidae');


--
-- TOC entry 4395 (class 0 OID 0)
-- Dependencies: 200
-- Name: id_seq; Type: SEQUENCE SET; Schema: poisson; Owner: postgres
--

SELECT pg_catalog.setval('id_seq', 40, true);


--
-- TOC entry 4372 (class 0 OID 52013)
-- Dependencies: 219
-- Data for Name: mesure; Type: TABLE DATA; Schema: poisson; Owner: createur_savoie
--

INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (1, 1, 67778, 3.5, 10);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (2, 2, 67778, 4, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (3, 3, 67778, 5, 20);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (4, 4, 67778, 0.3, 1);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (5, 5, 67778, 15, 40);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (6, 6, 67778, 20, 45);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (7, 7, 67778, 12.5, 30);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (8, 8, 67778, 2.4, 8);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (9, 9, 67778, 7.5, 19);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (10, 10, 67778, 10, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (11, 1, 67854, 9, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (12, 2, 67854, 7, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (13, 3, 67854, 2.1, 7);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (14, 4, 67854, 3.5, 10);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (15, 5, 67854, 4, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (16, 6, 67854, 5, 20);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (17, 7, 67854, 0.3, 1);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (18, 8, 67854, 15, 40);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (19, 9, 67854, 20, 45);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (20, 10, 67854, 12.5, 30);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (21, 11, 67812, 2.4, 8);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (22, 12, 67812, 7.5, 19);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (23, 13, 67812, 10, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (24, 14, 67812, 9, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (25, 15, 67812, 7, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (26, 16, 67812, 2.1, 7);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (27, 17, 67812, 3.5, 10);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (28, 18, 67812, 4, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (29, 19, 67812, 5, 20);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (30, 20, 67812, 0.3, 1);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (31, 21, 67812, 15, 40);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (32, 22, 67812, 20, 45);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (33, 23, 67812, 12.5, 30);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (34, 7, 67804, 2.4, 8);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (35, 8, 67804, 7.5, 19);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (36, 9, 67804, 10, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (37, 10, 67804, 9, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (38, 11, 67804, 7, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (39, 12, 67804, 2.1, 7);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (40, 13, 67804, 3.5, 10);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (41, 14, 67804, 4, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (42, 20, 67819, 5, 20);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (43, 21, 67819, 0.3, 1);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (44, 22, 67819, 15, 40);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (45, 23, 67819, 20, 45);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (46, 24, 67819, 12.5, 30);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (47, 25, 67819, 2.4, 8);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (48, 26, 67819, 7.5, 19);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (49, 27, 67819, 10, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (50, 28, 67819, 9, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (51, 29, 67819, 7, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (52, 30, 67819, 2.1, 7);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (53, 31, 67819, 3.5, 10);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (54, 32, 67819, 4, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (55, 33, 67819, 5, 20);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (56, 34, 67819, 0.3, 1);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (57, 35, 67819, 15, 40);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (58, 31, 67111, 20, 45);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (59, 32, 67111, 12.5, 30);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (60, 33, 67111, 2.4, 8);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (61, 34, 67111, 7.5, 19);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (62, 35, 67111, 10, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (63, 36, 67111, 9, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (64, 37, 67111, 7, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (65, 38, 67111, 2.1, 7);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (66, 39, 67111, 3.5, 10);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (67, 40, 67111, 4, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (68, 41, 67111, 5, 20);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (69, 42, 67111, 0.3, 1);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (70, 43, 67111, 15, 40);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (71, 40, 67404, 20, 45);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (72, 41, 67404, 12.5, 30);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (73, 42, 67404, 2.4, 8);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (74, 43, 67404, 7.5, 19);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (75, 44, 67404, 10, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (76, 45, 67404, 9, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (77, 46, 67404, 7, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (78, 47, 67404, 2.1, 7);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (79, 48, 67404, 3.5, 10);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (80, 49, 67404, 4, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (81, 50, 67404, 5, 20);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (82, 51, 67404, 0.3, 1);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (83, 52, 67404, 15, 40);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (84, 53, 67404, 20, 45);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (85, 50, 67606, 12.5, 30);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (86, 51, 67606, 2.4, 8);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (87, 52, 67606, 7.5, 19);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (88, 53, 67606, 10, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (89, 54, 67606, 9, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (90, 55, 67606, 7, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (91, 56, 67606, 2.1, 7);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (92, 57, 67606, 3.5, 10);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (93, 58, 67606, 4, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (94, 59, 67606, 5, 20);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (95, 60, 67606, 0.3, 1);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (96, 61, 67606, 15, 40);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (97, 58, 69354, 20, 45);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (98, 59, 69354, 12.5, 30);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (99, 60, 69354, 2.4, 8);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (100, 61, 69354, 7.5, 19);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (101, 62, 69354, 10, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (102, 63, 69354, 9, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (103, 64, 69354, 7, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (104, 65, 69354, 2.1, 7);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (105, 66, 69354, 3.5, 10);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (106, 67, 69354, 4, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (107, 68, 69354, 5, 20);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (108, 69, 69354, 0.3, 1);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (109, 70, 69354, 15, 40);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (110, 71, 69354, 20, 45);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (111, 72, 69354, 12.5, 30);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (112, 73, 69354, 2.4, 8);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (113, 74, 69354, 7.5, 19);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (114, 69, 69350, 9, 25);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (115, 70, 69350, 7, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (116, 71, 69350, 2.1, 7);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (117, 72, 69350, 3.5, 10);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (118, 73, 69350, 4, 15);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (119, 74, 69350, 5, 20);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (120, 1, 69350, 15, 40);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (121, 2, 69350, 20, 45);
INSERT INTO mesure (id_mesure, prelevement, espece, poids, nombre_individu) VALUES (122, 3, 69350, 12.5, 30);


--
-- TOC entry 4396 (class 0 OID 0)
-- Dependencies: 218
-- Name: mesure_id_mesure_seq; Type: SEQUENCE SET; Schema: poisson; Owner: createur_savoie
--

SELECT pg_catalog.setval('mesure_id_mesure_seq', 122, true);


--
-- TOC entry 4363 (class 0 OID 48482)
-- Dependencies: 208
-- Data for Name: methode; Type: TABLE DATA; Schema: poisson; Owner: createur_savoie
--

INSERT INTO methode (nom_methode, description, url) VALUES ('Pêche au chalut', NULL, NULL);
INSERT INTO methode (nom_methode, description, url) VALUES ('Pêche à la ligne', NULL, NULL);
INSERT INTO methode (nom_methode, description, url) VALUES ('Observation en bateau', NULL, NULL);
INSERT INTO methode (nom_methode, description, url) VALUES ('Prélèvement manuel', NULL, NULL);


--
-- TOC entry 4367 (class 0 OID 51685)
-- Dependencies: 214
-- Data for Name: personne; Type: TABLE DATA; Schema: poisson; Owner: createur_savoie
--

INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (1, 'Ahbar', 'Moha', 'ahbar@lapth.cnrs.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (2, 'Bertrand', 'Eric', 'eric.bertrand@cnrs-dir.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (3, 'Bezançon', 'eric', 'eric.bezancon@rmsb.u-bordeaux2.fr', 'Bordeaux 2', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (4, 'Billon', 'Lucille', 'lucille.billon@mnhn.fr', 'MNHN', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (5, 'Blanchard', 'Cyrille', 'cyrille.blanchard@univ-lyon1.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (6, 'Capello', 'Manuela', 'manuela.capello@ird.fr', 'IRD', NULL, 'Enseignant-chercheur / Chercheur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (7, 'Chevallereau', 'Colombe', 'colombe.chevallereau@inra.fr', 'INRA', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (8, 'Debray', 'Bernard', 'bernard.debray@utinam.cnrs.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (9, 'Delbès', 'Marilyne', 'mdelbes@ens.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (10, 'Dessennes', 'cedric', 'cedric.dessennes@ensea.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (11, 'Galliano', 'nicolas', 'nicolas.galliano@dsi.cnrs.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (12, 'Guilet', 'Stéphane', 'stephane.guilet@c2n.upsaclay.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (13, 'Khrouz', 'Naima', 'naima.el.mokhtari@ens-lyon.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (15, 'Lopez Franco', 'Julio Cesar', 'julio.lopez@lmd.polytechnique.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (16, 'Mouquet', 'Nicolas', 'nicolas.mouquet@cnrs.fr', 'CNRS', NULL, 'Enseignant-chercheur / Chercheur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (17, 'Pellier', 'Karine', 'karine.pellier@umontpellier.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (18, 'Pennec', 'Flora', 'pennec@mnhn.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (19, 'Pierson', 'Julie', 'julie.pierson@cnrs.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (21, 'Pressac', 'Jean-Baptiste', 'jean-baptiste.pressac@univ-brest.fr ', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (22, 'Quidoz', 'Marie-Claude', 'Marie-claude.quidoz@cefe.cnrs.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (23, 'Sol', 'Emmanuel', 'emmanuel.sol@lameta.univ-montp1.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (24, 'Theron', 'franck', 'f.benfontein@gmail.com', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (25, 'Thibault', 'Harold', 'harold.thibault@promes.cnrs.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (26, 'Tissier', 'Evelyne', 'evelyne.tissier@univ-tlse2.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (27, 'Yousfi', 'Mehdi', 'mehdi.yousfi@cnrs.fr', 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (14, 'Laborde', 'Jean-Luc', 'laborde@crpp-bordeaux.cnrs.fr', 'bordeaux', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (20, 'Plumejeaud', 'Christine', NULL, 'CNRS', NULL, 'Technicien / Assistant-Ingénieur / Ingénieur');
INSERT INTO personne (id_personne, nom, prenom, courriel, organisme, statut, statut_a_choisir) VALUES (28, 'Plumejeaud', 'Christine', NULL, 'CNRS', NULL, NULL);


--
-- TOC entry 4397 (class 0 OID 0)
-- Dependencies: 213
-- Name: personne_id_personne_seq; Type: SEQUENCE SET; Schema: poisson; Owner: createur_savoie
--

SELECT pg_catalog.setval('personne_id_personne_seq', 28, true);


--
-- TOC entry 4370 (class 0 OID 51928)
-- Dependencies: 217
-- Data for Name: prelevement; Type: TABLE DATA; Schema: poisson; Owner: createur_savoie
--

INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (1, '2013-04-01', 'Lac_Bourget-1', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (2, '2013-04-01', 'Lac_Bourget-2', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (3, '2013-04-01', 'Lac_Bourget-3', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (5, '2013-04-01', 'Lac_Bourget-5', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (6, '2013-04-01', 'Lac_Bourget-6', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (7, '2013-04-01', 'Lac_Bourget-7', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (8, '2013-04-01', 'Lac_Bourget-8', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (9, '2013-04-01', 'Lac_Bourget-9', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (10, '2013-04-01', 'Lac_Bourget-10', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (11, '2013-05-01', 'Lac_Bourget-1', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de pluie');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (12, '2013-05-01', 'Lac_Bourget-2', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de pluie');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (13, '2013-05-01', 'Lac_Bourget-3', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de pluie');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (15, '2013-05-01', 'Lac_Bourget-5', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de pluie');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (16, '2013-05-01', 'Lac_Bourget-6', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de pluie');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (17, '2013-05-01', 'Lac_Bourget-7', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de pluie');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (18, '2013-05-01', 'Lac_Bourget-8', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de pluie');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (19, '2013-05-01', 'Lac_Bourget-9', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de pluie');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (20, '2013-05-01', 'Lac_Bourget-10', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de pluie');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (21, '2013-06-01', 'Lac_Bourget-1', 'Lac Bourget 2013', 'Pêche à la ligne', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (22, '2013-06-01', 'Lac_Bourget-2', 'Lac Bourget 2013', 'Pêche à la ligne', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (23, '2013-06-01', 'Lac_Bourget-3', 'Lac Bourget 2013', 'Pêche à la ligne', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (25, '2013-06-01', 'Lac_Bourget-5', 'Lac Bourget 2013', 'Pêche à la ligne', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (26, '2013-06-01', 'Lac_Bourget-6', 'Lac Bourget 2013', 'Pêche à la ligne', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (27, '2013-06-01', 'Lac_Bourget-7', 'Lac Bourget 2013', 'Pêche à la ligne', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (28, '2013-06-01', 'Lac_Bourget-8', 'Lac Bourget 2013', 'Pêche à la ligne', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (29, '2013-06-01', 'Lac_Bourget-9', 'Lac Bourget 2013', 'Pêche à la ligne', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (30, '2013-06-01', 'Lac_Bourget-10', 'Lac Bourget 2013', 'Pêche à la ligne', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (31, '2010-06-01', 'Lac_Bourget-1', 'Savoie 2010', 'Prélèvement manuel', 'Réalisé un jour de brouillard');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (32, '2010-06-01', 'Lac_Bourget-3', 'Savoie 2010', 'Prélèvement manuel', 'Réalisé un jour de brouillard');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (33, '2010-06-01', 'Lac_Bourget-5', 'Savoie 2010', 'Prélèvement manuel', 'Réalisé un jour de brouillard');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (34, '2010-06-01', 'Lac_Bourget-7', 'Savoie 2010', 'Prélèvement manuel', 'Réalisé un jour de brouillard');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (35, '2010-06-01', 'Lac_Bourget-9', 'Savoie 2010', 'Prélèvement manuel', 'Réalisé un jour de brouillard');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (36, '2010-06-05', 'Lac_Bourget-2', 'Savoie 2010', 'Prélèvement manuel', 'Réalisé un jour où il y avait beaucoup de bateaux sur le lac');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (38, '2010-06-05', 'Lac_Bourget-6', 'Savoie 2010', 'Prélèvement manuel', 'Réalisé un jour où il y avait beaucoup de bateaux sur le lac');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (39, '2010-06-05', 'Lac_Bourget-8', 'Savoie 2010', 'Prélèvement manuel', 'Réalisé un jour où il y avait beaucoup de bateaux sur le lac');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (40, '2010-06-05', 'Lac_Bourget-10', 'Savoie 2010', 'Prélèvement manuel', 'Réalisé un jour où il y avait beaucoup de bateaux sur le lac');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (41, '2017-04-30', 'Lac_Bourget-1', 'France 2017', 'Observation en bateau', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (42, '2017-05-30', 'Lac_Bourget-1', 'France 2017', 'Observation en bateau', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (43, '2017-06-30', 'Lac_Bourget-1', 'France 2017', 'Observation en bateau', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (44, '2017-03-01', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (45, '2017-03-02', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (46, '2017-03-03', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (47, '2017-03-04', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (48, '2017-03-05', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (49, '2017-03-06', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (50, '2017-03-07', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (51, '2017-03-08', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (52, '2017-03-09', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (53, '2017-03-10', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (54, '2017-03-11', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (55, '2017-03-12', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (56, '2017-03-13', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (57, '2017-03-14', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (58, '2017-03-15', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (59, '2017-03-16', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (60, '2017-03-17', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (61, '2017-03-18', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (62, '2017-03-19', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (63, '2017-03-20', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (64, '2017-03-21', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (65, '2017-03-22', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (66, '2017-03-23', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (67, '2017-03-24', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (68, '2017-03-25', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (69, '2017-03-26', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (70, '2017-03-27', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', 'Réalisé un jour où il y avait beaucoup de bateaux sur le lac');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (71, '2017-03-28', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', 'Réalisé un jour où il y avait beaucoup de bateaux sur le lac');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (72, '2017-03-29', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', 'Réalisé un jour où il y avait beaucoup de bateaux sur le lac');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (73, '2017-03-30', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', 'Réalisé un jour où il y avait beaucoup de bateaux sur le lac');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (74, '2017-03-31', 'Lac_Bourget-2', 'Aix Les Bains 2016', 'Pêche au chalut', 'Réalisé un jour où il y avait beaucoup de bateaux sur le lac');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (4, '2013-04-01', 'Lac_Bourget-4', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de grande chaleur');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (14, '2013-05-01', 'Lac_Bourget-4', 'Lac Bourget 2013', 'Pêche à la ligne', 'Réalisé un jour de pluie');
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (24, '2013-06-01', 'Lac_Bourget-4', 'Lac Bourget 2013', 'Pêche à la ligne', NULL);
INSERT INTO prelevement (id_prelevement, date_prelevement, nom_station, nom_campagne, methode_prelevement, caracteristique) VALUES (37, '2010-06-05', 'Lac_Bourget-4', 'Savoie 2010', 'Prélèvement manuel', 'Réalisé un jour où il y avait beaucoup de bateaux sur le lac ');


--
-- TOC entry 4398 (class 0 OID 0)
-- Dependencies: 216
-- Name: prelevement_id_prelevement_seq; Type: SEQUENCE SET; Schema: poisson; Owner: createur_savoie
--

SELECT pg_catalog.setval('prelevement_id_prelevement_seq', 74, true);


--
-- TOC entry 4368 (class 0 OID 51718)
-- Dependencies: 215
-- Data for Name: responsable_campagne; Type: TABLE DATA; Schema: poisson; Owner: createur_savoie
--

INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (22, 'Aix Les Bains 2016');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (13, 'France 2017');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (23, 'France 2017');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (20, 'Lac Bourget 2013');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (5, 'Lac Bourget 2013-2');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (21, 'Lac Bourget 2013-2');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (19, 'Lac Bourget 2013-2');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (2, 'Savoie 2010');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (7, 'Savoie 2010');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (18, 'Savoie 2010');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (19, 'Suivi des Ablettes');
INSERT INTO responsable_campagne (id_personne, nom_campagne) VALUES (24, 'Suivi des Ablettes');


--
-- TOC entry 4365 (class 0 OID 48559)
-- Dependencies: 210
-- Data for Name: station; Type: TABLE DATA; Schema: poisson; Owner: createur_savoie
--

INSERT INTO station (nom_station, longitude, latitude, descriptif, commune, geom_point) VALUES ('Lac_Bourget-2', 5.875453948974609, 45.68334991619661, 'station partie Sud du lac', 'BOURDEAU', '0101000020E61000000000000077801740F7E4920278D74640');
INSERT INTO station (nom_station, longitude, latitude, descriptif, commune, geom_point) VALUES ('Lac_Bourget-3', 5.877857208251953, 45.656239933226416, 'station partie Sud du lac', 'VIVIERS-DU-LAC', '0101000020E610000000000000ED821740B2C48DABFFD34640');
INSERT INTO station (nom_station, longitude, latitude, descriptif, commune, geom_point) VALUES ('Lac_Bourget-4', 5.873050689697266, 45.65168032796973, 'station partie Sud du lac', 'LE BOURGET-DU-LAC', '0101000020E610000000000000017E1740CC09D0426AD34640');
INSERT INTO station (nom_station, longitude, latitude, descriptif, commune, geom_point) VALUES ('Lac_Bourget-5', 5.862407684326172, 45.65935944924319, 'station partie Sud du lac', 'LE BOURGET-DU-LAC', '0101000020E6100000000000001B7317406F67F3E365D44640');
INSERT INTO station (nom_station, longitude, latitude, descriptif, commune, geom_point) VALUES ('Lac_Bourget-6', 5.849704742431641, 45.75621778578767, 'station partie Nord du lac', 'SAINT-PIERRE-DE-CURTILLE', '0101000020E61000000000000019661740484E91BECBE04640');
INSERT INTO station (nom_station, longitude, latitude, descriptif, commune, geom_point) VALUES ('Lac_Bourget-7', 5.832538604736328, 45.79907908975093, 'station partie Nord du lac', 'CHINDRIEUX', '0101000020E61000000000000085541740E8B23E3948E64640');
INSERT INTO station (nom_station, longitude, latitude, descriptif, commune, geom_point) VALUES ('Lac_Bourget-8', 5.850391387939453, 45.79548862509075, 'station partie Nord du lac', 'CHINDRIEUX', '0101000020E610000000000000CD661740698D3E92D2E54640');
INSERT INTO station (nom_station, longitude, latitude, descriptif, commune, geom_point) VALUES ('Lac_Bourget-9', 5.835971832275391, 45.76963045006652, 'station partie Nord du lac', 'SAINT-PIERRE-DE-CURTILLE', '0101000020E610000000000000095817404F85264083E24640');
INSERT INTO station (nom_station, longitude, latitude, descriptif, commune, geom_point) VALUES ('Lac_Bourget-10', 5.867900848388672, 45.760529350967474, 'station partie Nord du lac', 'BRISON-SAINT-INNOCENT', '0101000020E610000000000000BB781740D606990659E14640');
INSERT INTO station (nom_station, longitude, latitude, descriptif, commune, geom_point) VALUES ('Lac_Bourget-1', 5.869578799999999, 45.7296783, 'station partie central du lac', 'BRISON-SAINT-INNOCENT', '0101000020E6100000002E6DDD727A1740EA8C391966DD4640');


--
-- TOC entry 4220 (class 2606 OID 48524)
-- Name: pk_campagne; Type: CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY campagne
    ADD CONSTRAINT pk_campagne PRIMARY KEY (nom_campagne);


--
-- TOC entry 4216 (class 2606 OID 48465)
-- Name: pk_espece; Type: CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY espece
    ADD CONSTRAINT pk_espece PRIMARY KEY (cd_nom);


--
-- TOC entry 4230 (class 2606 OID 52021)
-- Name: pk_mesure; Type: CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY mesure
    ADD CONSTRAINT pk_mesure PRIMARY KEY (id_mesure);


--
-- TOC entry 4218 (class 2606 OID 48489)
-- Name: pk_methode; Type: CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY methode
    ADD CONSTRAINT pk_methode PRIMARY KEY (nom_methode);


--
-- TOC entry 4224 (class 2606 OID 51693)
-- Name: pk_personne; Type: CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY personne
    ADD CONSTRAINT pk_personne PRIMARY KEY (id_personne);


--
-- TOC entry 4228 (class 2606 OID 51936)
-- Name: pk_prelevement; Type: CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY prelevement
    ADD CONSTRAINT pk_prelevement PRIMARY KEY (id_prelevement);


--
-- TOC entry 4226 (class 2606 OID 51725)
-- Name: pk_responsable_campagne; Type: CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY responsable_campagne
    ADD CONSTRAINT pk_responsable_campagne PRIMARY KEY (id_personne, nom_campagne);


--
-- TOC entry 4222 (class 2606 OID 48566)
-- Name: pk_station; Type: CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY station
    ADD CONSTRAINT pk_station PRIMARY KEY (nom_station);


--
-- TOC entry 4234 (class 2606 OID 51942)
-- Name: fk_campagne; Type: FK CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY prelevement
    ADD CONSTRAINT fk_campagne FOREIGN KEY (nom_campagne) REFERENCES campagne(nom_campagne);


--
-- TOC entry 4236 (class 2606 OID 52022)
-- Name: fk_espece; Type: FK CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY mesure
    ADD CONSTRAINT fk_espece FOREIGN KEY (espece) REFERENCES espece(cd_nom);


--
-- TOC entry 4235 (class 2606 OID 51947)
-- Name: fk_methode; Type: FK CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY prelevement
    ADD CONSTRAINT fk_methode FOREIGN KEY (methode_prelevement) REFERENCES methode(nom_methode);


--
-- TOC entry 4237 (class 2606 OID 52027)
-- Name: fk_prelevement; Type: FK CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY mesure
    ADD CONSTRAINT fk_prelevement FOREIGN KEY (prelevement) REFERENCES prelevement(id_prelevement);


--
-- TOC entry 4232 (class 2606 OID 51731)
-- Name: fk_responsable_campagne_id_personne; Type: FK CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY responsable_campagne
    ADD CONSTRAINT fk_responsable_campagne_id_personne FOREIGN KEY (id_personne) REFERENCES personne(id_personne);


--
-- TOC entry 4231 (class 2606 OID 51726)
-- Name: fk_responsable_campagne_nom_campagne; Type: FK CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY responsable_campagne
    ADD CONSTRAINT fk_responsable_campagne_nom_campagne FOREIGN KEY (nom_campagne) REFERENCES campagne(nom_campagne);


--
-- TOC entry 4233 (class 2606 OID 51937)
-- Name: fk_station; Type: FK CONSTRAINT; Schema: poisson; Owner: createur_savoie
--

ALTER TABLE ONLY prelevement
    ADD CONSTRAINT fk_station FOREIGN KEY (nom_station) REFERENCES station(nom_station);


--
-- TOC entry 4377 (class 0 OID 0)
-- Dependencies: 10
-- Name: poisson; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA poisson FROM PUBLIC;
REVOKE ALL ON SCHEMA poisson FROM postgres;
GRANT ALL ON SCHEMA poisson TO postgres;
GRANT ALL ON SCHEMA poisson TO createur_savoie;
GRANT USAGE ON SCHEMA poisson TO lecteur_savoie;


--
-- TOC entry 4378 (class 0 OID 0)
-- Dependencies: 209
-- Name: campagne; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON TABLE campagne FROM PUBLIC;
REVOKE ALL ON TABLE campagne FROM createur_savoie;
GRANT ALL ON TABLE campagne TO createur_savoie;
GRANT SELECT ON TABLE campagne TO lecteur_savoie;


--
-- TOC entry 4381 (class 0 OID 0)
-- Dependencies: 207
-- Name: espece; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON TABLE espece FROM PUBLIC;
REVOKE ALL ON TABLE espece FROM createur_savoie;
GRANT ALL ON TABLE espece TO createur_savoie;
GRANT SELECT ON TABLE espece TO lecteur_savoie;


--
-- TOC entry 4382 (class 0 OID 0)
-- Dependencies: 200
-- Name: id_seq; Type: ACL; Schema: poisson; Owner: postgres
--

REVOKE ALL ON SEQUENCE id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE id_seq FROM postgres;
GRANT ALL ON SEQUENCE id_seq TO postgres;
GRANT ALL ON SEQUENCE id_seq TO lecteur_savoie;


--
-- TOC entry 4383 (class 0 OID 0)
-- Dependencies: 219
-- Name: mesure; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON TABLE mesure FROM PUBLIC;
REVOKE ALL ON TABLE mesure FROM createur_savoie;
GRANT ALL ON TABLE mesure TO createur_savoie;
GRANT SELECT ON TABLE mesure TO lecteur_savoie;


--
-- TOC entry 4385 (class 0 OID 0)
-- Dependencies: 218
-- Name: mesure_id_mesure_seq; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON SEQUENCE mesure_id_mesure_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE mesure_id_mesure_seq FROM createur_savoie;
GRANT ALL ON SEQUENCE mesure_id_mesure_seq TO createur_savoie;
GRANT ALL ON SEQUENCE mesure_id_mesure_seq TO lecteur_savoie;


--
-- TOC entry 4386 (class 0 OID 0)
-- Dependencies: 208
-- Name: methode; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON TABLE methode FROM PUBLIC;
REVOKE ALL ON TABLE methode FROM createur_savoie;
GRANT ALL ON TABLE methode TO createur_savoie;
GRANT SELECT ON TABLE methode TO lecteur_savoie;


--
-- TOC entry 4387 (class 0 OID 0)
-- Dependencies: 214
-- Name: personne; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON TABLE personne FROM PUBLIC;
REVOKE ALL ON TABLE personne FROM createur_savoie;
GRANT ALL ON TABLE personne TO createur_savoie;
GRANT SELECT ON TABLE personne TO lecteur_savoie;


--
-- TOC entry 4389 (class 0 OID 0)
-- Dependencies: 213
-- Name: personne_id_personne_seq; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON SEQUENCE personne_id_personne_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE personne_id_personne_seq FROM createur_savoie;
GRANT ALL ON SEQUENCE personne_id_personne_seq TO createur_savoie;
GRANT ALL ON SEQUENCE personne_id_personne_seq TO lecteur_savoie;


--
-- TOC entry 4390 (class 0 OID 0)
-- Dependencies: 217
-- Name: prelevement; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON TABLE prelevement FROM PUBLIC;
REVOKE ALL ON TABLE prelevement FROM createur_savoie;
GRANT ALL ON TABLE prelevement TO createur_savoie;
GRANT SELECT ON TABLE prelevement TO lecteur_savoie;


--
-- TOC entry 4392 (class 0 OID 0)
-- Dependencies: 216
-- Name: prelevement_id_prelevement_seq; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON SEQUENCE prelevement_id_prelevement_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE prelevement_id_prelevement_seq FROM createur_savoie;
GRANT ALL ON SEQUENCE prelevement_id_prelevement_seq TO createur_savoie;
GRANT ALL ON SEQUENCE prelevement_id_prelevement_seq TO lecteur_savoie;


--
-- TOC entry 4393 (class 0 OID 0)
-- Dependencies: 215
-- Name: responsable_campagne; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON TABLE responsable_campagne FROM PUBLIC;
REVOKE ALL ON TABLE responsable_campagne FROM createur_savoie;
GRANT ALL ON TABLE responsable_campagne TO createur_savoie;
GRANT SELECT ON TABLE responsable_campagne TO lecteur_savoie;


--
-- TOC entry 4394 (class 0 OID 0)
-- Dependencies: 210
-- Name: station; Type: ACL; Schema: poisson; Owner: createur_savoie
--

REVOKE ALL ON TABLE station FROM PUBLIC;
REVOKE ALL ON TABLE station FROM createur_savoie;
GRANT ALL ON TABLE station TO createur_savoie;
GRANT SELECT ON TABLE station TO lecteur_savoie;


-- Completed on 2017-05-05 19:04:15

--
-- PostgreSQL database dump complete
--

