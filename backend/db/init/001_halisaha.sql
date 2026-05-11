--
-- PostgreSQL database dump
--

\restrict eqANb5xri2k8ULunpWRIzwwpvJWibx0UjwwLYpxDkOJe0tWUolyadfojAfOwZqt

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-05-11 20:08:59

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 47617)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5265 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 228 (class 1259 OID 47777)
-- Name: bildirim_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bildirim_tb (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    alici_id uuid,
    baslik character varying(200) NOT NULL,
    mesaj character varying(500) NOT NULL,
    bildirim_tipi character varying(50),
    ilgili_ilan_id uuid,
    okundu_mu boolean DEFAULT false,
    olusturulma_tarihi timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    hedef_id character varying(100),
    aksiyon_id character varying(100)
);


ALTER TABLE public.bildirim_tb OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 47825)
-- Name: giris_gecmisi_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.giris_gecmisi_tb (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    kullanici_id uuid,
    isletme_id uuid,
    kullanici_tipi character varying(20) NOT NULL,
    ip_adresi character varying(50),
    cihaz_bilgisi character varying(255),
    basarili_mi boolean NOT NULL,
    hata_mesaji character varying(255),
    giris_tarihi timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.giris_gecmisi_tb OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 48346)
-- Name: hali_saha_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hali_saha_tb (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    isletme_id uuid NOT NULL,
    saha_adi character varying(200) NOT NULL,
    adres character varying(255) NOT NULL,
    enlem double precision,
    boylam double precision,
    saha_formati character varying(10) NOT NULL,
    saatlik_ucret numeric(10,2) NOT NULL,
    kapali_mi boolean DEFAULT false,
    ozellikler character varying(500),
    puan_ortalamasi numeric(3,2) DEFAULT 0,
    yorum_sayisi integer DEFAULT 0,
    fotograf_url character varying(255),
    aktif_mi boolean DEFAULT true,
    olusturulma_tarihi timestamp with time zone DEFAULT now()
);


ALTER TABLE public.hali_saha_tb OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 47861)
-- Name: hesap_kilitleme_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hesap_kilitleme_tb (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(150) NOT NULL,
    basarisiz_deneme_sayisi integer DEFAULT 0,
    son_basarisiz_deneme timestamp with time zone,
    kilitleme_tarihi timestamp with time zone,
    kilit_bitis_tarihi timestamp with time zone,
    kilitli_mi boolean DEFAULT false
);


ALTER TABLE public.hesap_kilitleme_tb OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 47700)
-- Name: ilan_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ilan_tb (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    olusturan_id uuid NOT NULL,
    is_takim_ilani boolean DEFAULT false,
    ilgili_takim_id uuid,
    eksik_kisi_sayisi integer,
    aranan_mevki character varying(50),
    yas_araligi_min integer,
    yas_araligi_max integer,
    saha_id uuid,
    ozel_konum_adi text,
    mac_saati timestamp with time zone,
    aciklama text,
    ilan_tarihi timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    aktif_mi boolean DEFAULT true,
    ilan_tipi character varying(50),
    rekabet_seviyesi character varying(50)
);


ALTER TABLE public.ilan_tb OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 47644)
-- Name: isletme_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.isletme_tb (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    isletme_adi character varying(200) NOT NULL,
    yetkili_ad_soyad character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    sifre character varying(255) NOT NULL,
    telefon character varying(20) NOT NULL,
    vergi_no character varying(50),
    adres character varying(255),
    onayli_mi boolean DEFAULT false,
    kayit_tarihi timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    konum_enlem double precision,
    konum_boylam double precision,
    son_giris_tarihi timestamp with time zone,
    email_dogrulanmis boolean DEFAULT false,
    hesap_durumu character varying(20) DEFAULT 'AKTIF'::character varying
);


ALTER TABLE public.isletme_tb OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 47728)
-- Name: kullanici_istatistik_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kullanici_istatistik_tb (
    kullanici_id uuid NOT NULL,
    toplam_mac_sayisi integer DEFAULT 0,
    gol_sayisi integer DEFAULT 0,
    asist_sayisi integer DEFAULT 0,
    macin_adami_odulu integer DEFAULT 0,
    disiplin_puani numeric(3,2) DEFAULT 5.00,
    kazanma_orani numeric(5,2) DEFAULT 0.00,
    son_mac_tarihi timestamp with time zone
);


ALTER TABLE public.kullanici_istatistik_tb OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 47762)
-- Name: kullanici_musaitlik_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kullanici_musaitlik_tb (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    kullanici_id uuid,
    tercih_edilen_bolge character varying(100),
    haftanin_gunu integer,
    baslangic_saati time without time zone,
    bitis_saati time without time zone,
    her_saat_uygun boolean DEFAULT false,
    aktif_mi boolean DEFAULT true
);


ALTER TABLE public.kullanici_musaitlik_tb OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 47628)
-- Name: kullanici_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kullanici_tb (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    ad_soyad character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    sifre character varying(255) NOT NULL,
    telefon character varying(20),
    profil_foto_url character varying(255),
    kayit_tarihi timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    aktif_mi boolean DEFAULT true,
    dogum_tarihi date,
    "puan_ortalaması" numeric(3,2) DEFAULT 0.0,
    yorum_sayisi integer DEFAULT 0,
    son_enlem double precision,
    son_boylam double precision,
    son_giris_tarihi timestamp with time zone,
    email_dogrulanmis boolean DEFAULT false,
    hesap_durumu character varying(20) DEFAULT 'AKTIF'::character varying,
    disiplin_puani numeric(4,2) DEFAULT 5.00,
    tercih_edilen_pozisyon character varying(30),
    il character varying(50),
    ilce character varying(50),
    CONSTRAINT puan_araligi_kontrol CHECK ((("puan_ortalaması" >= (0)::numeric) AND ("puan_ortalaması" <= (5)::numeric)))
);


ALTER TABLE public.kullanici_tb OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 48387)
-- Name: mac_katilimci_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mac_katilimci_tb (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    mac_id uuid NOT NULL,
    kullanici_id uuid NOT NULL,
    katilim_durumu character varying(20) DEFAULT 'ONAYLANDI'::character varying NOT NULL,
    katilim_tarihi timestamp with time zone DEFAULT now()
);


ALTER TABLE public.mac_katilimci_tb OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 48365)
-- Name: mac_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mac_tb (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    olusturan_id uuid NOT NULL,
    saha_id uuid,
    mac_basligi character varying(200) NOT NULL,
    mac_tarihi date NOT NULL,
    baslangic_saati time without time zone NOT NULL,
    bitis_saati time without time zone NOT NULL,
    format character varying(10) NOT NULL,
    max_oyuncu_sayisi integer NOT NULL,
    mevcut_oyuncu_sayisi integer DEFAULT 0,
    mac_durumu character varying(20) DEFAULT 'ACIK'::character varying NOT NULL,
    aciklama character varying(500),
    seviye character varying(20) DEFAULT 'KARMA'::character varying,
    ucret_per_kisi numeric(10,2) DEFAULT 0,
    olusturulma_tarihi timestamp with time zone DEFAULT now(),
    min_disiplin_puani numeric(4,2),
    mac_tipi character varying(20) DEFAULT 'NORMAL'::character varying,
    eksik_oyuncu_sayisi integer,
    takim_adi character varying(100),
    rakip_notu character varying(300),
    il character varying(100),
    ilce character varying(100)
);


ALTER TABLE public.mac_tb OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 47800)
-- Name: refresh_token_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refresh_token_tb (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    kullanici_id uuid,
    isletme_id uuid,
    kullanici_tipi character varying(20) NOT NULL,
    token_hash character varying(255) NOT NULL,
    cihaz_bilgisi character varying(255),
    ip_adresi character varying(50),
    son_kullanim_tarihi timestamp with time zone,
    olusturulma_tarihi timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    gecerlilik_tarihi timestamp with time zone NOT NULL,
    iptal_edildi_mi boolean DEFAULT false,
    CONSTRAINT chk_kullanici_tipi CHECK (((kullanici_tipi)::text = ANY ((ARRAY['KULLANICI'::character varying, 'ISLETME'::character varying])::text[])))
);


ALTER TABLE public.refresh_token_tb OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 47837)
-- Name: sifre_sifirlama_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sifre_sifirlama_tb (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    kullanici_id uuid,
    isletme_id uuid,
    kullanici_tipi character varying(20) NOT NULL,
    token_hash character varying(255) NOT NULL,
    gecerlilik_tarihi timestamp with time zone NOT NULL,
    kullanildi_mi boolean DEFAULT false,
    olusturulma_tarihi timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    token character varying(255) NOT NULL
);


ALTER TABLE public.sifre_sifirlama_tb OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 48573)
-- Name: takim_ilani_istek_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.takim_ilani_istek_tb (
    id uuid NOT NULL,
    durum character varying(20),
    gonderen_id uuid NOT NULL,
    ilan_id uuid NOT NULL,
    mesaj character varying(500),
    olusturulma_tarihi timestamp(6) with time zone
);


ALTER TABLE public.takim_ilani_istek_tb OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 48410)
-- Name: takim_ilani_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.takim_ilani_tb (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    olusturan_id uuid NOT NULL,
    takim_adi character varying(100) NOT NULL,
    ilan_basligi character varying(200) NOT NULL,
    aciklama character varying(500),
    aranan_pozisyon character varying(50) DEFAULT 'FARKETMEZ'::character varying,
    aranan_oyuncu_sayisi integer DEFAULT 1,
    min_disiplin_puani numeric(4,2),
    seviye character varying(20) DEFAULT 'KARMA'::character varying,
    konum character varying(100),
    ilan_durumu character varying(20) DEFAULT 'AKTIF'::character varying,
    olusturulma_tarihi timestamp with time zone DEFAULT now()
);


ALTER TABLE public.takim_ilani_tb OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 47745)
-- Name: takim_istatistik_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.takim_istatistik_tb (
    takim_id uuid NOT NULL,
    toplam_mac_sayisi integer DEFAULT 0,
    galibiyet_sayisi integer DEFAULT 0,
    beraberlik_sayisi integer DEFAULT 0,
    maglubiyet_sayisi integer DEFAULT 0,
    son_mac_tarihi timestamp with time zone,
    ortalama_aktiflik_puani numeric(3,2) DEFAULT 0.00,
    uygulamaya_son_giris_tarihi timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.takim_istatistik_tb OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 47665)
-- Name: takim_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.takim_tb (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    takim_adi character varying(100) NOT NULL,
    kurucu_id uuid,
    logo_url text,
    kurulus_tarihi timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    puan_ortalamasi numeric(3,2) DEFAULT 0.0,
    oyuncu_ariyor_mu boolean DEFAULT false
);


ALTER TABLE public.takim_tb OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 47682)
-- Name: takim_uyeleri_tb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.takim_uyeleri_tb (
    takim_id uuid NOT NULL,
    kullanici_id uuid NOT NULL,
    katilma_tarihi timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.takim_uyeleri_tb OWNER TO postgres;

--
-- TOC entry 5250 (class 0 OID 47777)
-- Dependencies: 228
-- Data for Name: bildirim_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bildirim_tb (id, alici_id, baslik, mesaj, bildirim_tipi, ilgili_ilan_id, okundu_mu, olusturulma_tarihi, hedef_id, aksiyon_id) FROM stdin;
0d50e658-895f-47bc-b4b5-e5c943a6c4f4	aae2b022-931e-4f77-af18-7b8ea67848e6	Yakınında Yeni Maç!	Merkez bölgesinde yeni bir maç oluşturuldu: deneme maci	YAKIN_MAC	\N	f	2026-04-26 17:02:07.864034+03	b4a278d3-3f30-446a-ae8d-b2547c046d16	\N
\.


--
-- TOC entry 5252 (class 0 OID 47825)
-- Dependencies: 230
-- Data for Name: giris_gecmisi_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.giris_gecmisi_tb (id, kullanici_id, isletme_id, kullanici_tipi, ip_adresi, cihaz_bilgisi, basarili_mi, hata_mesaji, giris_tarihi) FROM stdin;
5ec22012-a604-4f74-b291-804fb1e4be07	66716cdb-7c38-4623-9c4b-041d242275e9	\N	KULLANICI	127.0.0.1	test	t	\N	2026-04-14 22:53:12.802066+03
9154ed91-3f1b-433e-a1c5-668513140cf6	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-14 22:57:51.281481+03
088c76cf-7a48-45e6-b851-79a4c68f13f6	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-14 23:01:36.578924+03
23499a85-2a10-4858-aef4-932238038bd9	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-15 19:43:09.592908+03
0ad3db1a-b082-49e0-b129-b70129e6153d	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-15 20:07:37.073344+03
6dacb866-8356-4a18-b55b-6114ad75c0d4	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-15 20:18:18.036984+03
81a32986-985c-4246-9da7-7c7adff424c4	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-15 20:19:00.529266+03
d1bbf9ca-238c-44ad-84cc-a8bc19933a95	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-15 20:20:21.255447+03
368b2e2f-77d8-49e2-b518-4de0080c69c9	aae2b022-931e-4f77-af18-7b8ea67848e6	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-21 15:27:14.707724+03
5d822953-6dae-4fb5-9b6d-95b5825e9494	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-24 17:01:55.558107+03
5fda90a8-c298-4faf-9d37-153641dda83b	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-26 14:21:49.455095+03
15d9f00b-3378-41bb-801b-326ec0ef73ac	aae2b022-931e-4f77-af18-7b8ea67848e6	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-26 14:58:26.933848+03
365b69ed-2c16-43b2-81d8-f980cc4c2cc4	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	127.0.0.1	Flutter Mobile App	t	\N	2026-04-26 14:59:56.520904+03
\.


--
-- TOC entry 5255 (class 0 OID 48346)
-- Dependencies: 233
-- Data for Name: hali_saha_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hali_saha_tb (id, isletme_id, saha_adi, adres, enlem, boylam, saha_formati, saatlik_ucret, kapali_mi, ozellikler, puan_ortalamasi, yorum_sayisi, fotograf_url, aktif_mi, olusturulma_tarihi) FROM stdin;
\.


--
-- TOC entry 5254 (class 0 OID 47861)
-- Dependencies: 232
-- Data for Name: hesap_kilitleme_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hesap_kilitleme_tb (id, email, basarisiz_deneme_sayisi, son_basarisiz_deneme, kilitleme_tarihi, kilit_bitis_tarihi, kilitli_mi) FROM stdin;
\.


--
-- TOC entry 5246 (class 0 OID 47700)
-- Dependencies: 224
-- Data for Name: ilan_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ilan_tb (id, olusturan_id, is_takim_ilani, ilgili_takim_id, eksik_kisi_sayisi, aranan_mevki, yas_araligi_min, yas_araligi_max, saha_id, ozel_konum_adi, mac_saati, aciklama, ilan_tarihi, aktif_mi, ilan_tipi, rekabet_seviyesi) FROM stdin;
\.


--
-- TOC entry 5243 (class 0 OID 47644)
-- Dependencies: 221
-- Data for Name: isletme_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.isletme_tb (id, isletme_adi, yetkili_ad_soyad, email, sifre, telefon, vergi_no, adres, onayli_mi, kayit_tarihi, konum_enlem, konum_boylam, son_giris_tarihi, email_dogrulanmis, hesap_durumu) FROM stdin;
\.


--
-- TOC entry 5247 (class 0 OID 47728)
-- Dependencies: 225
-- Data for Name: kullanici_istatistik_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kullanici_istatistik_tb (kullanici_id, toplam_mac_sayisi, gol_sayisi, asist_sayisi, macin_adami_odulu, disiplin_puani, kazanma_orani, son_mac_tarihi) FROM stdin;
\.


--
-- TOC entry 5249 (class 0 OID 47762)
-- Dependencies: 227
-- Data for Name: kullanici_musaitlik_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kullanici_musaitlik_tb (id, kullanici_id, tercih_edilen_bolge, haftanin_gunu, baslangic_saati, bitis_saati, her_saat_uygun, aktif_mi) FROM stdin;
\.


--
-- TOC entry 5242 (class 0 OID 47628)
-- Dependencies: 220
-- Data for Name: kullanici_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kullanici_tb (id, ad_soyad, email, sifre, telefon, profil_foto_url, kayit_tarihi, aktif_mi, dogum_tarihi, "puan_ortalaması", yorum_sayisi, son_enlem, son_boylam, son_giris_tarihi, email_dogrulanmis, hesap_durumu, disiplin_puani, tercih_edilen_pozisyon, il, ilce) FROM stdin;
66716cdb-7c38-4623-9c4b-041d242275e9	Test Kullanici	test@test.com	$2a$12$/gXuomvrs13gr3hbSm2Lp.EWPiO5s7zdK.a3.Osiyaq8w0kOtwQhi	05551234567	\N	2026-04-14 22:53:12.757878+03	t	\N	0.00	0	\N	\N	2026-04-14 22:53:12.757878+03	f	AKTIF	5.00	\N	\N	\N
aae2b022-931e-4f77-af18-7b8ea67848e6	Yasin gulsen	yasingulsen81@gmail.com	$2a$12$GmeBm5WMV1tCaIgpErcFruoI.qVgHmqxtqoPJ5F4GJT97J5nBwDaa	\N	\N	2026-04-21 15:27:14.706728+03	t	\N	0.00	0	\N	\N	2026-04-26 14:58:26.932038+03	f	AKTIF	5.00	\N	Sivas	Merkez
8a90a469-7682-40f5-b086-52947f2f58a7	Arif boyraz	mariftr60@gmail.com	$2a$12$PqB4SlHSfr7mexfs3kmda.KtH2G0PwpF52XicHVhqgQjf73FHmAB2	05526963260	\N	2026-04-14 22:57:51.280481+03	t	2003-02-10	0.00	0	\N	\N	2026-04-26 14:59:56.520904+03	f	AKTIF	5.00	DEFANS	Sivas	Merkez
\.


--
-- TOC entry 5257 (class 0 OID 48387)
-- Dependencies: 235
-- Data for Name: mac_katilimci_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mac_katilimci_tb (id, mac_id, kullanici_id, katilim_durumu, katilim_tarihi) FROM stdin;
afb3e5d0-e599-4782-b842-5303e21b9530	fe413e8c-2e5c-4c15-9cef-4ca8760f8210	8a90a469-7682-40f5-b086-52947f2f58a7	ONAYLANDI	2026-04-20 19:55:19.94436+03
94f51c1e-41ee-41bb-be5e-8246914025ae	8b1c925c-2790-43e4-ac8e-008e78771236	8a90a469-7682-40f5-b086-52947f2f58a7	ONAYLANDI	2026-04-21 12:35:42.618246+03
d0b4cbfb-528d-4a06-b82e-0659a2249e1c	a7f92c4e-8226-44ae-a26e-7b5544ced67d	8a90a469-7682-40f5-b086-52947f2f58a7	ONAYLANDI	2026-04-26 14:05:53.928423+03
3a835f74-0fbc-4783-aea4-d685df28211f	b4a278d3-3f30-446a-ae8d-b2547c046d16	8a90a469-7682-40f5-b086-52947f2f58a7	ONAYLANDI	2026-04-26 17:02:07.865037+03
\.


--
-- TOC entry 5256 (class 0 OID 48365)
-- Dependencies: 234
-- Data for Name: mac_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mac_tb (id, olusturan_id, saha_id, mac_basligi, mac_tarihi, baslangic_saati, bitis_saati, format, max_oyuncu_sayisi, mevcut_oyuncu_sayisi, mac_durumu, aciklama, seviye, ucret_per_kisi, olusturulma_tarihi, min_disiplin_puani, mac_tipi, eksik_oyuncu_sayisi, takim_adi, rakip_notu, il, ilce) FROM stdin;
8b1c925c-2790-43e4-ac8e-008e78771236	8a90a469-7682-40f5-b086-52947f2f58a7	\N	oyuncu lazm	2026-04-22	20:00:00	21:00:00	10v10	20	1	ACIK	gerek oyuncular gelsin dalgamza bakalm	ILERI	199.00	2026-04-21 12:35:42.61725+03	4.00	EKSIK_OYUNCU	2	tokatspor	\N	\N	\N
fe413e8c-2e5c-4c15-9cef-4ca8760f8210	8a90a469-7682-40f5-b086-52947f2f58a7	\N	takmmza bir oyuncu lazm	2026-04-24	21:00:00	21:00:00	11v11	22	1	ACIK	\N	ORTA	0.00	2026-04-20 19:55:19.94436+03	\N	EKSIK_OYUNCU	1	\N	\N	Sivas	Merkez
a7f92c4e-8226-44ae-a26e-7b5544ced67d	8a90a469-7682-40f5-b086-52947f2f58a7	\N	mac ilan	2026-04-29	20:00:00	21:00:00	7v7	14	1	ACIK	\N	KARMA	0.00	2026-04-26 14:05:53.918861+03	4.00	NORMAL	\N	\N	\N	Sivas	Merkez
b4a278d3-3f30-446a-ae8d-b2547c046d16	8a90a469-7682-40f5-b086-52947f2f58a7	\N	deneme maci	2026-04-28	20:00:00	21:00:00	10v10	20	1	ACIK	ilk gelen mac alr	KARMA	50.00	2026-04-26 17:02:07.846528+03	5.00	NORMAL	\N	\N	\N	Sivas	Merkez
\.


--
-- TOC entry 5251 (class 0 OID 47800)
-- Dependencies: 229
-- Data for Name: refresh_token_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refresh_token_tb (id, kullanici_id, isletme_id, kullanici_tipi, token_hash, cihaz_bilgisi, ip_adresi, son_kullanim_tarihi, olusturulma_tarihi, gecerlilik_tarihi, iptal_edildi_mi) FROM stdin;
2f02dea7-9151-44b1-a75b-8f203995937b	66716cdb-7c38-4623-9c4b-041d242275e9	\N	KULLANICI	wOCtTyLZIV0lOYtlpjHbjlX75G3TfeXN_xiMNecFO7M	test	127.0.0.1	\N	2026-04-14 22:53:12.946938+03	2026-05-14 22:53:12.946938+03	f
6f734d0a-65ed-4b7d-be1f-5885ed3532d9	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	soyoo2VdpntJ-TfU9YxaMNckyWskLOAbS-eM-lodxIM	Flutter Mobile App	127.0.0.1	\N	2026-04-14 22:57:51.325945+03	2026-05-14 22:57:51.325945+03	t
b4094785-625d-4b0e-b8ef-a534067a0680	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	-WWBptcvIPS-ue9gJ0ZxvK7r_gGQpxhDO6jxcPi9nlQ	Flutter Mobile App	127.0.0.1	\N	2026-04-14 23:01:36.619959+03	2026-05-14 23:01:36.619959+03	t
cf686701-6ea9-4581-b04f-8146482ca2e3	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	-5RU9I8RAtklAJmoI_OioIc8SH0UGuEjCNIzNGuFE9E	Flutter Mobile App	127.0.0.1	\N	2026-04-15 20:00:10.396843+03	2026-05-15 20:00:10.396843+03	f
bf0d4b66-517d-4094-9ed1-67919c89a4f4	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	Vpfnw5nWDImqvwJXmtyDVde34clcdHnPFEZEhH0ZFiQ	Flutter Mobile App	127.0.0.1	\N	2026-04-15 19:43:09.719532+03	2026-05-15 19:43:09.719532+03	t
ae3fac28-16a6-40f4-8cbb-57cdddcbb294	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	vT5nJ0BSpl5UbDMWwWwmFPpW-sUiKyq4jnDXD8nj8VQ	Flutter Mobile App	127.0.0.1	\N	2026-04-15 20:07:37.096525+03	2026-05-15 20:07:37.096525+03	t
ba8fd5bf-33a0-4ba2-8837-7fac575429a2	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	_Rh_Qh3ik46eR7r9n9SSKbUrZCQkHqhpS8kv0fD2FsM	Flutter Mobile App	127.0.0.1	\N	2026-04-15 20:18:18.050015+03	2026-07-14 20:18:18.050015+03	t
1be8511e-3013-4754-be7c-747da9542da0	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	8FN6JYq-FobegBN4t8Ihnl8b2VsSGVV6NKqZMcWdL1A	Flutter Mobile App	127.0.0.1	\N	2026-04-15 20:19:00.540094+03	2026-05-15 20:19:00.540094+03	t
61b43da7-1955-4cc8-8a8b-27adccb32b76	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	oeDDrLEDnZfgfqGH8PksG53RkiKzbcypEzu5bY26GX4	Flutter Mobile App	127.0.0.1	\N	2026-04-20 19:23:29.685731+03	2026-05-20 19:23:29.685731+03	f
6c63b933-a064-4cc6-85ba-da67d2df095e	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	1sO3TU1OwYRyYNp-ajcWeX0jRk2pqTTJIQ20R57g1ug	Flutter Mobile App	127.0.0.1	\N	2026-04-20 19:23:29.654655+03	2026-05-20 19:23:29.654655+03	f
fe913832-8e53-4482-99d2-224c7a7960c6	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	NyRlxxLvlKE8AkAy6Dv4Wd3ivzUn556G-BbxJWe66YY	Flutter Mobile App	127.0.0.1	\N	2026-04-21 12:32:29.884846+03	2026-05-21 12:32:29.885861+03	f
d423e133-b096-4b4a-a3df-9ffe6f61bf75	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	edOgyVyJEnL8ZhcXHq2SwC7rVMZ6Wt6UJFHtxPTfIao	Flutter Mobile App	127.0.0.1	\N	2026-04-21 12:32:29.941459+03	2026-05-21 12:32:29.941459+03	f
689b92c3-4805-40d6-839b-894b1e0b5f33	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	GK_kRqhGXDeFPeeEDl2Kaguvc_TTpaEsADT_KvmpTlY	Flutter Mobile App	127.0.0.1	\N	2026-04-15 20:20:21.276241+03	2026-07-14 20:20:21.27726+03	t
46f3bbc4-b836-425c-8f40-6008ba277d7e	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	0uMp-WsCRRQ6BdZ0LK2UJAJ-WFYbLsDlUyzUF-aZu08	Flutter Mobile App	127.0.0.1	\N	2026-04-20 19:49:03.861333+03	2026-05-20 19:49:03.861333+03	f
db9235a7-99da-46f6-bc75-982010f74b9d	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	008UzhSyTwSqPBTrUGNBZ4sdrFmB7fRdweeSEl7I8Ck	Flutter Mobile App	127.0.0.1	\N	2026-04-20 19:49:03.843989+03	2026-05-20 19:49:03.843989+03	f
83372380-892a-4f3b-8cab-25be5a51a5a6	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	tFueWdV6BMfL_zK3rOSeGuKgklLqs3hCosFoso7iQaQ	Flutter Mobile App	127.0.0.1	\N	2026-04-21 13:52:11.021277+03	2026-05-21 13:52:11.021277+03	t
b607aa8e-34af-4f3a-be63-c10216b6b137	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	GzldRmj-inepH_Vxag02DAhtkP2eP10G9UkqBHSpt7Y	Flutter Mobile App	127.0.0.1	\N	2026-04-20 19:23:29.652651+03	2026-05-20 19:23:29.652651+03	t
82e28b0e-ca16-4078-bd03-2cabdfa91eee	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	jo9BgRqBT1qO2yQq4L6wlSaYDe9DwuWIJh90zuZFZnc	Flutter Mobile App	127.0.0.1	\N	2026-04-20 20:17:13.324392+03	2026-05-20 20:17:13.324392+03	f
6c3fc2f1-2526-4dbd-9789-f468c6a1d910	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	OokDSlQ3SV62XO5KDie7IYEkjJ4uQXWdQ4-YfNp9mAA	Flutter Mobile App	127.0.0.1	\N	2026-04-20 20:17:13.355551+03	2026-05-20 20:17:13.355551+03	f
2b98be2d-30b7-4aca-b0e8-3136ab68fcdb	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	2DVAYUjemIgr82AUmJB_1fWv9Sq71LKjDodgBXsKjzA	Flutter Mobile App	127.0.0.1	\N	2026-04-21 11:43:39.501215+03	2026-05-21 11:43:39.501215+03	t
f5517d78-7ea0-4ee3-91ce-0278b73e528a	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	DRXI9oQMOIerL1RF1npqORRh3rZuTh3ycq2cYbgBi5o	Flutter Mobile App	127.0.0.1	\N	2026-04-20 19:49:03.843989+03	2026-05-20 19:49:03.843989+03	t
1a2b448b-c270-44ad-83c8-da339d579c2c	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	nUz5lS7Bn2luDFWhPnicmFweuAfcu4ljNN4wzy84TEc	Flutter Mobile App	127.0.0.1	\N	2026-04-20 20:37:58.940367+03	2026-05-20 20:37:58.940367+03	f
724d291c-2373-4213-813d-55e69868c834	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	U1Vd7DhgyjQPVuQI9IotnMgawn0lQt0FHRauHPVvuYI	Flutter Mobile App	127.0.0.1	\N	2026-04-20 20:37:58.940367+03	2026-05-20 20:37:58.940367+03	f
dc7d5615-f0ea-415c-9934-5420f9aa6067	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	3K7-DalXITuLkq6ybTgBpAABu0MZFh79T_TTTzs3nbA	Flutter Mobile App	127.0.0.1	\N	2026-04-21 12:53:27.966118+03	2026-05-21 12:53:27.966118+03	f
7662e81e-3381-4f5c-83c4-f5a785569022	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	zYOGdeewzxzQO6hjS-ajsn2XMylmQCEfaZ7S7DVKI6E	Flutter Mobile App	127.0.0.1	\N	2026-04-20 20:17:13.324392+03	2026-05-20 20:17:13.324392+03	t
8108b6a5-64f8-4027-bef7-2d5d55551556	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	rCSnLFjFnWOaJ9hKqhoeQxyEwYTaRJ6U5uzd8lT57qs	Flutter Mobile App	127.0.0.1	\N	2026-04-21 11:43:39.502215+03	2026-05-21 11:43:39.502215+03	f
ea2f2817-f9bc-4a90-8c61-cb15025f55bc	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	qMfNlYHAs1tHkjGOzWFpSaGY9XLIi5GEJuqkC8NWfgM	Flutter Mobile App	127.0.0.1	\N	2026-04-21 11:43:39.503216+03	2026-05-21 11:43:39.503216+03	f
4f1725fd-1150-4d7b-a484-693eac0208c2	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	IYymuf1gP0YSptv1bF2cW7T0QeeGY7yZx5okL7SRuhk	Flutter Mobile App	127.0.0.1	\N	2026-04-21 12:53:27.918887+03	2026-05-21 12:53:27.918887+03	f
0fddb68d-8059-42d7-9b8b-62d5e99328d3	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	FiUmGpcuBAugU8Rg0_EvqsVNaHFJAr-GCnBewtFIGmk	Flutter Mobile App	127.0.0.1	\N	2026-04-21 14:40:50.769966+03	2026-05-21 14:40:50.769966+03	f
518ff473-c4be-4671-9dff-10114b737380	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	UR7veNj0reziI1374NwmIEvBIKDoqprsSUSpBTRbXMU	Flutter Mobile App	127.0.0.1	\N	2026-04-20 20:37:58.994844+03	2026-05-20 20:37:58.994844+03	t
5781c06e-f6ba-423a-8fb6-3c2d960fd292	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	ysqwqJGabHiK7LmjyV8A1Rgb87HtnHr63a-a7r_NG3c	Flutter Mobile App	127.0.0.1	\N	2026-04-21 12:32:30.090102+03	2026-05-21 12:32:30.090102+03	t
e41ca5c3-f178-4c0e-ab33-320bc21155b4	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	2t5oXW1oC3sGozoeFuGUhQqWqS5nvshOgEwN_1wwDcU	Flutter Mobile App	127.0.0.1	\N	2026-04-21 13:52:11.002732+03	2026-05-21 13:52:11.002732+03	f
4bd0aabd-cfb9-416d-aa61-d8b654b9f99f	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	3RPnJdSZoyZtbkmT4g_v9harqb88V3GpiRC5iWqkWiE	Flutter Mobile App	127.0.0.1	\N	2026-04-21 13:52:11.004743+03	2026-05-21 13:52:11.004743+03	f
a5c7e202-fea3-4ec8-ac3a-dfbc22f6f92e	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	MffTDSZfFOYqjaalqPlFcwlnUZ97FEzgV0oaNrmqto8	Flutter Mobile App	127.0.0.1	\N	2026-04-21 14:40:50.767966+03	2026-05-21 14:40:50.767966+03	f
0224fd31-88fe-48b5-924f-a76884a8c8f8	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	bwS8KcWOqlv8QiR91wgSFE3eWeRyis_BZX0uPvB1aMY	Flutter Mobile App	127.0.0.1	\N	2026-04-21 14:57:04.011536+03	2026-05-21 14:57:04.011536+03	f
c7d40e3d-86ba-4493-8565-92c062cf0f3c	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	HrqSTubdt4HWJzOjr3xsAq7wUyYWvXRlWpfrJxEo0gY	Flutter Mobile App	127.0.0.1	\N	2026-04-21 12:53:27.91689+03	2026-05-21 12:53:27.91689+03	t
311ad26f-e697-42d2-887e-27e7bd98ef65	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	E8jpZYRQ0iUT50R6zMwhtJFNoAH__5E6h0UIIxdkIIo	Flutter Mobile App	127.0.0.1	\N	2026-04-21 14:57:03.98027+03	2026-05-21 14:57:03.98027+03	f
dc306729-2f95-42a2-a486-387a882331da	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	yUeqpuUwjsYKk_EiIK353HxPz2PSMoR7S23qM4GZsYQ	Flutter Mobile App	127.0.0.1	\N	2026-04-21 14:20:25.865775+03	2026-05-21 14:20:25.865775+03	t
20b25af2-9515-43ce-85c9-3cdec9e6bcc2	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	ewgioeNnY_ZRu0ogtrCE9u2cO0fXtETyEEI4wPFSvvw	Flutter Mobile App	127.0.0.1	\N	2026-04-21 14:40:50.791531+03	2026-05-21 14:40:50.791531+03	t
1f154f5f-ee04-4012-ae66-527980aace04	aae2b022-931e-4f77-af18-7b8ea67848e6	\N	KULLANICI	JahiI3xYg6Rjm0hf8EkEyTuZO6j8PpgW41EUGqzJvqc	Flutter Mobile App	127.0.0.1	\N	2026-04-24 16:48:22.367996+03	2026-05-24 16:48:22.367996+03	f
e9ac60c9-753f-4c69-9025-b3d49dc2b7bc	aae2b022-931e-4f77-af18-7b8ea67848e6	\N	KULLANICI	o09I6fxXt2U7DkfyFgdYfWKWJ-KV9fRc_iGM3z0oWZQ	Flutter Mobile App	127.0.0.1	\N	2026-04-24 16:48:22.367996+03	2026-05-24 16:48:22.367996+03	f
a3c412d0-0df9-43fa-9728-4d977b8594b7	aae2b022-931e-4f77-af18-7b8ea67848e6	\N	KULLANICI	qp53s00gpraqnVlXSAwgOEaX9eoRifdyRcvIe4fQiqs	Flutter Mobile App	127.0.0.1	\N	2026-04-24 16:48:22.415638+03	2026-05-24 16:48:22.415638+03	f
1ce5d2f6-8057-4584-a8d8-20d262e0425c	aae2b022-931e-4f77-af18-7b8ea67848e6	\N	KULLANICI	bXt77x5O-VU1ln7AgexyWsDKZ7eY1PUvgYyaeyMfyRY	Flutter Mobile App	127.0.0.1	\N	2026-04-21 15:27:14.958193+03	2026-05-21 15:27:14.958193+03	t
678fc02c-e5e8-42f7-b264-d4be99dc8644	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	6r3IcXL1H8kkVhaXTCKUqzG7hdYLrsKU7doG1aWV-IA	Flutter Mobile App	127.0.0.1	\N	2026-04-24 17:01:55.73234+03	2026-07-23 17:01:55.73234+03	t
cfe5c1ce-2d95-47eb-82ef-687717d325a8	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	ksQabQsIKJpi_9VTYuQqfzmwWebQwXg5t-nxZ3DW7QQ	Flutter Mobile App	127.0.0.1	\N	2026-04-24 17:33:04.887882+03	2026-05-24 17:33:04.887882+03	t
7b0f23de-10a5-42ff-b0df-d201838de9bc	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	8dpKnBvaKtsPWOzJHy84g-EbPqXEUiT5wRilc1TFyAk	Flutter Mobile App	127.0.0.1	\N	2026-04-24 18:11:18.259957+03	2026-05-24 18:11:18.259957+03	t
3325834d-d058-4a98-9e4f-a1e0a5c0a3a0	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	ja4PxK9DfMGtrQhaUFCzhj6L3l-TRKPh8CGg8izlN60	Flutter Mobile App	127.0.0.1	\N	2026-04-24 18:27:23.325923+03	2026-05-24 18:27:23.325923+03	t
a4ddc052-bb09-4c47-80be-5254572322c8	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	nljAlHyTwTJKMj7AbkSj7rJtqIHiZOmDL1Y7RVSSlHY	Flutter Mobile App	127.0.0.1	\N	2026-04-26 13:11:16.225679+03	2026-05-26 13:11:16.225679+03	t
11154974-bf78-40de-a733-16fce7d21b91	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	ia-E2xbhlmvmmTT9pCZU_8V8L07ybr98sGxWRMKiJ3A	Flutter Mobile App	127.0.0.1	\N	2026-04-26 14:02:17.779891+03	2026-05-26 14:02:17.779891+03	f
3a568f2d-7c92-456a-b109-80126ecdc53e	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	HUnFW5UN7_EmRDwf3MUqioqqChDQARUKcR0Uu--0SzM	Flutter Mobile App	127.0.0.1	\N	2026-04-26 13:45:28.487999+03	2026-05-26 13:45:28.487999+03	t
3961c9e9-ad64-41d5-b8ff-87328a13f101	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	g2FfKHsfkRqHlD7uW0-QOn2WlK1NC-4sqCJjBECAHZ4	Flutter Mobile App	127.0.0.1	\N	2026-04-26 14:21:49.829578+03	2026-07-25 14:21:49.829578+03	t
53ad3deb-8140-445b-8563-6253c17bef0f	aae2b022-931e-4f77-af18-7b8ea67848e6	\N	KULLANICI	GD_PyN-Ag0WdR3EAZxJ0qO2NK2DDrOGDnhJ8-qQvjaY	Flutter Mobile App	127.0.0.1	\N	2026-04-26 14:58:27.673309+03	2026-05-26 14:58:27.674325+03	t
f0522468-c5a9-47c3-9334-418e3f23b5ef	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	XusnXLLLnTDPTrTXwjXmijHXCitVn5vOkgqF-7vNhzk	Flutter Mobile App	127.0.0.1	\N	2026-04-26 14:59:56.585265+03	2026-05-26 14:59:56.585265+03	t
575ddc37-63d9-433b-a2b6-96966af81ba9	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	_mkXhUhQW46RNKG-WlMXJoJ4yyOQw1IOOAFgNvwgq3k	Flutter Mobile App	127.0.0.1	\N	2026-04-26 15:18:36.725653+03	2026-05-26 15:18:36.725653+03	t
62bd766c-d39f-4f58-9fad-0f77b79017b3	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	6NGpMLXkKZn7AS-3NbiG8ku-jfncdmXOaEQzxChTIIk	Flutter Mobile App	127.0.0.1	\N	2026-04-26 16:38:00.629222+03	2026-05-26 16:38:00.629222+03	t
04d3c32a-f097-4b88-9165-633208b286e6	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	qLAnwkuP38pOuRBg8ln4iwbtlzTaSOp2aV8k7n4OG_o	Flutter Mobile App	127.0.0.1	\N	2026-04-26 16:54:48.892921+03	2026-05-26 16:54:48.892921+03	t
3d2cd061-8a8f-4d35-b6af-5c26e4020d8b	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	FkxgUX7udPIy9B-I571UpDnvsuC4Mqg0V3TTMawFVBI	Flutter Mobile App	127.0.0.1	\N	2026-05-11 19:52:32.58859+03	2026-06-10 19:52:32.58859+03	f
84c8a47d-1257-44a1-956a-1150dfe25454	8a90a469-7682-40f5-b086-52947f2f58a7	\N	KULLANICI	DoqucQ8tD77rWgk-bnJo-lOjr7xZzvsB826BmaONpHY	Flutter Mobile App	127.0.0.1	\N	2026-05-11 19:22:20.902634+03	2026-06-10 19:22:20.903631+03	t
\.


--
-- TOC entry 5253 (class 0 OID 47837)
-- Dependencies: 231
-- Data for Name: sifre_sifirlama_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sifre_sifirlama_tb (id, kullanici_id, isletme_id, kullanici_tipi, token_hash, gecerlilik_tarihi, kullanildi_mi, olusturulma_tarihi, token) FROM stdin;
\.


--
-- TOC entry 5259 (class 0 OID 48573)
-- Dependencies: 237
-- Data for Name: takim_ilani_istek_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.takim_ilani_istek_tb (id, durum, gonderen_id, ilan_id, mesaj, olusturulma_tarihi) FROM stdin;
2b2fb197-865c-4af2-99e4-d4c910c3c2e5	BEKLEMEDE	aae2b022-931e-4f77-af18-7b8ea67848e6	05341f87-4c7e-4ab1-808d-58d982f35411	05352944741	2026-04-26 14:59:20.360612+03
\.


--
-- TOC entry 5258 (class 0 OID 48410)
-- Dependencies: 236
-- Data for Name: takim_ilani_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.takim_ilani_tb (id, olusturan_id, takim_adi, ilan_basligi, aciklama, aranan_pozisyon, aranan_oyuncu_sayisi, min_disiplin_puani, seviye, konum, ilan_durumu, olusturulma_tarihi) FROM stdin;
05341f87-4c7e-4ab1-808d-58d982f35411	8a90a469-7682-40f5-b086-52947f2f58a7	trabzonspor	forvetr aryoruz	\N	FORVET	1	3.00	KARMA	Sivas / Merkez	AKTIF	2026-04-26 14:02:18.228147+03
a99774c8-e0d1-46b8-ae8b-78bdffe5efef	8a90a469-7682-40f5-b086-52947f2f58a7	fenerbahe	yasin	\N	KALECI	1	3.00	ORTA	Sivas / Merkez	AKTIF	2026-04-24 18:28:06.456674+03
\.


--
-- TOC entry 5248 (class 0 OID 47745)
-- Dependencies: 226
-- Data for Name: takim_istatistik_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.takim_istatistik_tb (takim_id, toplam_mac_sayisi, galibiyet_sayisi, beraberlik_sayisi, maglubiyet_sayisi, son_mac_tarihi, ortalama_aktiflik_puani, uygulamaya_son_giris_tarihi) FROM stdin;
\.


--
-- TOC entry 5244 (class 0 OID 47665)
-- Dependencies: 222
-- Data for Name: takim_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.takim_tb (id, takim_adi, kurucu_id, logo_url, kurulus_tarihi, puan_ortalamasi, oyuncu_ariyor_mu) FROM stdin;
\.


--
-- TOC entry 5245 (class 0 OID 47682)
-- Dependencies: 223
-- Data for Name: takim_uyeleri_tb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.takim_uyeleri_tb (takim_id, kullanici_id, katilma_tarihi) FROM stdin;
\.


--
-- TOC entry 5033 (class 2606 OID 47789)
-- Name: bildirim_tb bildirim_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bildirim_tb
    ADD CONSTRAINT bildirim_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5040 (class 2606 OID 47836)
-- Name: giris_gecmisi_tb giris_gecmisi_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.giris_gecmisi_tb
    ADD CONSTRAINT giris_gecmisi_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5049 (class 2606 OID 48364)
-- Name: hali_saha_tb hali_saha_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hali_saha_tb
    ADD CONSTRAINT hali_saha_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5046 (class 2606 OID 47870)
-- Name: hesap_kilitleme_tb hesap_kilitleme_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hesap_kilitleme_tb
    ADD CONSTRAINT hesap_kilitleme_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5025 (class 2606 OID 47712)
-- Name: ilan_tb ilan_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilan_tb
    ADD CONSTRAINT ilan_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5017 (class 2606 OID 47661)
-- Name: isletme_tb isletme_tb_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.isletme_tb
    ADD CONSTRAINT isletme_tb_email_key UNIQUE (email);


--
-- TOC entry 5019 (class 2606 OID 47659)
-- Name: isletme_tb isletme_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.isletme_tb
    ADD CONSTRAINT isletme_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5027 (class 2606 OID 47739)
-- Name: kullanici_istatistik_tb kullanici_istatistik_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici_istatistik_tb
    ADD CONSTRAINT kullanici_istatistik_tb_pkey PRIMARY KEY (kullanici_id);


--
-- TOC entry 5031 (class 2606 OID 47770)
-- Name: kullanici_musaitlik_tb kullanici_musaitlik_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici_musaitlik_tb
    ADD CONSTRAINT kullanici_musaitlik_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5012 (class 2606 OID 47643)
-- Name: kullanici_tb kullanici_tb_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici_tb
    ADD CONSTRAINT kullanici_tb_email_key UNIQUE (email);


--
-- TOC entry 5014 (class 2606 OID 47641)
-- Name: kullanici_tb kullanici_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici_tb
    ADD CONSTRAINT kullanici_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5061 (class 2606 OID 48400)
-- Name: mac_katilimci_tb mac_katilimci_tb_mac_id_kullanici_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mac_katilimci_tb
    ADD CONSTRAINT mac_katilimci_tb_mac_id_kullanici_id_key UNIQUE (mac_id, kullanici_id);


--
-- TOC entry 5063 (class 2606 OID 48398)
-- Name: mac_katilimci_tb mac_katilimci_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mac_katilimci_tb
    ADD CONSTRAINT mac_katilimci_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5057 (class 2606 OID 48386)
-- Name: mac_tb mac_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mac_tb
    ADD CONSTRAINT mac_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5038 (class 2606 OID 47814)
-- Name: refresh_token_tb refresh_token_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_token_tb
    ADD CONSTRAINT refresh_token_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5044 (class 2606 OID 47850)
-- Name: sifre_sifirlama_tb sifre_sifirlama_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sifre_sifirlama_tb
    ADD CONSTRAINT sifre_sifirlama_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5071 (class 2606 OID 48582)
-- Name: takim_ilani_istek_tb takim_ilani_istek_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_ilani_istek_tb
    ADD CONSTRAINT takim_ilani_istek_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5069 (class 2606 OID 48426)
-- Name: takim_ilani_tb takim_ilani_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_ilani_tb
    ADD CONSTRAINT takim_ilani_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5029 (class 2606 OID 47756)
-- Name: takim_istatistik_tb takim_istatistik_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_istatistik_tb
    ADD CONSTRAINT takim_istatistik_tb_pkey PRIMARY KEY (takim_id);


--
-- TOC entry 5021 (class 2606 OID 47676)
-- Name: takim_tb takim_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_tb
    ADD CONSTRAINT takim_tb_pkey PRIMARY KEY (id);


--
-- TOC entry 5023 (class 2606 OID 47689)
-- Name: takim_uyeleri_tb takim_uyeleri_tb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_uyeleri_tb
    ADD CONSTRAINT takim_uyeleri_tb_pkey PRIMARY KEY (takim_id, kullanici_id);


--
-- TOC entry 5065 (class 2606 OID 48534)
-- Name: mac_katilimci_tb ukq6rqwiqh37i2lb176fw61ptad; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mac_katilimci_tb
    ADD CONSTRAINT ukq6rqwiqh37i2lb176fw61ptad UNIQUE (mac_id, kullanici_id);


--
-- TOC entry 5041 (class 1259 OID 48437)
-- Name: idx_giris_gecmisi_isletme; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_giris_gecmisi_isletme ON public.giris_gecmisi_tb USING btree (isletme_id);


--
-- TOC entry 5042 (class 1259 OID 48436)
-- Name: idx_giris_gecmisi_kullanici; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_giris_gecmisi_kullanici ON public.giris_gecmisi_tb USING btree (kullanici_id);


--
-- TOC entry 5050 (class 1259 OID 48402)
-- Name: idx_hali_saha_aktif; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hali_saha_aktif ON public.hali_saha_tb USING btree (aktif_mi);


--
-- TOC entry 5051 (class 1259 OID 48401)
-- Name: idx_hali_saha_isletme; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hali_saha_isletme ON public.hali_saha_tb USING btree (isletme_id);


--
-- TOC entry 5047 (class 1259 OID 48438)
-- Name: idx_hesap_kilitleme_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hesap_kilitleme_email ON public.hesap_kilitleme_tb USING btree (email);


--
-- TOC entry 5015 (class 1259 OID 48432)
-- Name: idx_isletme_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_isletme_email ON public.isletme_tb USING btree (email);


--
-- TOC entry 5009 (class 1259 OID 48431)
-- Name: idx_kullanici_aktif; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kullanici_aktif ON public.kullanici_tb USING btree (aktif_mi);


--
-- TOC entry 5010 (class 1259 OID 48430)
-- Name: idx_kullanici_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_kullanici_email ON public.kullanici_tb USING btree (email);


--
-- TOC entry 5052 (class 1259 OID 48403)
-- Name: idx_mac_durum_tarih; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mac_durum_tarih ON public.mac_tb USING btree (mac_durumu, mac_tarihi);


--
-- TOC entry 5058 (class 1259 OID 48407)
-- Name: idx_mac_katilimci_kullanici; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mac_katilimci_kullanici ON public.mac_katilimci_tb USING btree (kullanici_id);


--
-- TOC entry 5059 (class 1259 OID 48406)
-- Name: idx_mac_katilimci_mac; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mac_katilimci_mac ON public.mac_katilimci_tb USING btree (mac_id);


--
-- TOC entry 5053 (class 1259 OID 48404)
-- Name: idx_mac_olusturan; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mac_olusturan ON public.mac_tb USING btree (olusturan_id);


--
-- TOC entry 5054 (class 1259 OID 48405)
-- Name: idx_mac_saha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mac_saha ON public.mac_tb USING btree (saha_id);


--
-- TOC entry 5055 (class 1259 OID 48427)
-- Name: idx_mac_tipi; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mac_tipi ON public.mac_tb USING btree (mac_tipi);


--
-- TOC entry 5034 (class 1259 OID 48517)
-- Name: idx_refresh_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_token_hash ON public.refresh_token_tb USING btree (token_hash);


--
-- TOC entry 5035 (class 1259 OID 48434)
-- Name: idx_refresh_token_isletme; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_token_isletme ON public.refresh_token_tb USING btree (isletme_id);


--
-- TOC entry 5036 (class 1259 OID 48433)
-- Name: idx_refresh_token_kullanici; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_refresh_token_kullanici ON public.refresh_token_tb USING btree (kullanici_id);


--
-- TOC entry 5066 (class 1259 OID 48428)
-- Name: idx_takim_ilani_durumu; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_takim_ilani_durumu ON public.takim_ilani_tb USING btree (ilan_durumu);


--
-- TOC entry 5067 (class 1259 OID 48429)
-- Name: idx_takim_ilani_olusturan; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_takim_ilani_olusturan ON public.takim_ilani_tb USING btree (olusturan_id);


--
-- TOC entry 5081 (class 2606 OID 47790)
-- Name: bildirim_tb bildirim_tb_alici_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bildirim_tb
    ADD CONSTRAINT bildirim_tb_alici_id_fkey FOREIGN KEY (alici_id) REFERENCES public.kullanici_tb(id) ON DELETE CASCADE;


--
-- TOC entry 5082 (class 2606 OID 47795)
-- Name: bildirim_tb bildirim_tb_ilgili_ilan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bildirim_tb
    ADD CONSTRAINT bildirim_tb_ilgili_ilan_id_fkey FOREIGN KEY (ilgili_ilan_id) REFERENCES public.ilan_tb(id);


--
-- TOC entry 5088 (class 2606 OID 48555)
-- Name: mac_tb fk3cfjjeesxlj35m0uxc8u4q9bs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mac_tb
    ADD CONSTRAINT fk3cfjjeesxlj35m0uxc8u4q9bs FOREIGN KEY (saha_id) REFERENCES public.hali_saha_tb(id);


--
-- TOC entry 5089 (class 2606 OID 48550)
-- Name: mac_tb fk531bgsqkw8juq94rtaytmu98x; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mac_tb
    ADD CONSTRAINT fk531bgsqkw8juq94rtaytmu98x FOREIGN KEY (olusturan_id) REFERENCES public.kullanici_tb(id);


--
-- TOC entry 5083 (class 2606 OID 47820)
-- Name: refresh_token_tb fk_refresh_isletme; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_token_tb
    ADD CONSTRAINT fk_refresh_isletme FOREIGN KEY (isletme_id) REFERENCES public.isletme_tb(id) ON DELETE CASCADE;


--
-- TOC entry 5084 (class 2606 OID 47815)
-- Name: refresh_token_tb fk_refresh_kullanici; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refresh_token_tb
    ADD CONSTRAINT fk_refresh_kullanici FOREIGN KEY (kullanici_id) REFERENCES public.kullanici_tb(id) ON DELETE CASCADE;


--
-- TOC entry 5085 (class 2606 OID 47856)
-- Name: sifre_sifirlama_tb fk_sifre_isletme; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sifre_sifirlama_tb
    ADD CONSTRAINT fk_sifre_isletme FOREIGN KEY (isletme_id) REFERENCES public.isletme_tb(id) ON DELETE CASCADE;


--
-- TOC entry 5086 (class 2606 OID 47851)
-- Name: sifre_sifirlama_tb fk_sifre_kullanici; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sifre_sifirlama_tb
    ADD CONSTRAINT fk_sifre_kullanici FOREIGN KEY (kullanici_id) REFERENCES public.kullanici_tb(id) ON DELETE CASCADE;


--
-- TOC entry 5093 (class 2606 OID 48588)
-- Name: takim_ilani_istek_tb fkacrmh84n5m2g4apu19bmp30ej; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_ilani_istek_tb
    ADD CONSTRAINT fkacrmh84n5m2g4apu19bmp30ej FOREIGN KEY (ilan_id) REFERENCES public.takim_ilani_tb(id);


--
-- TOC entry 5094 (class 2606 OID 48583)
-- Name: takim_ilani_istek_tb fkd0homjvr0khg2ivl71akx90kl; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_ilani_istek_tb
    ADD CONSTRAINT fkd0homjvr0khg2ivl71akx90kl FOREIGN KEY (gonderen_id) REFERENCES public.kullanici_tb(id);


--
-- TOC entry 5092 (class 2606 OID 48560)
-- Name: takim_ilani_tb fkfadq9ya5s8yrrqkkj68vw3lk2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_ilani_tb
    ADD CONSTRAINT fkfadq9ya5s8yrrqkkj68vw3lk2 FOREIGN KEY (olusturan_id) REFERENCES public.kullanici_tb(id);


--
-- TOC entry 5087 (class 2606 OID 48535)
-- Name: hali_saha_tb fknvdbxbg5jx4k7g8txkj1ex9ac; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hali_saha_tb
    ADD CONSTRAINT fknvdbxbg5jx4k7g8txkj1ex9ac FOREIGN KEY (isletme_id) REFERENCES public.isletme_tb(id);


--
-- TOC entry 5090 (class 2606 OID 48540)
-- Name: mac_katilimci_tb fkst34bcbvgoco7ccodlymik8wu; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mac_katilimci_tb
    ADD CONSTRAINT fkst34bcbvgoco7ccodlymik8wu FOREIGN KEY (kullanici_id) REFERENCES public.kullanici_tb(id);


--
-- TOC entry 5091 (class 2606 OID 48545)
-- Name: mac_katilimci_tb fkt7h15discxpg4mijkh08775iw; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mac_katilimci_tb
    ADD CONSTRAINT fkt7h15discxpg4mijkh08775iw FOREIGN KEY (mac_id) REFERENCES public.mac_tb(id);


--
-- TOC entry 5075 (class 2606 OID 47718)
-- Name: ilan_tb ilan_tb_ilgili_takim_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilan_tb
    ADD CONSTRAINT ilan_tb_ilgili_takim_id_fkey FOREIGN KEY (ilgili_takim_id) REFERENCES public.takim_tb(id);


--
-- TOC entry 5076 (class 2606 OID 47713)
-- Name: ilan_tb ilan_tb_olusturan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilan_tb
    ADD CONSTRAINT ilan_tb_olusturan_id_fkey FOREIGN KEY (olusturan_id) REFERENCES public.kullanici_tb(id);


--
-- TOC entry 5077 (class 2606 OID 47723)
-- Name: ilan_tb ilan_tb_saha_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ilan_tb
    ADD CONSTRAINT ilan_tb_saha_id_fkey FOREIGN KEY (saha_id) REFERENCES public.isletme_tb(id);


--
-- TOC entry 5078 (class 2606 OID 47740)
-- Name: kullanici_istatistik_tb kullanici_istatistik_tb_kullanici_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici_istatistik_tb
    ADD CONSTRAINT kullanici_istatistik_tb_kullanici_id_fkey FOREIGN KEY (kullanici_id) REFERENCES public.kullanici_tb(id) ON DELETE CASCADE;


--
-- TOC entry 5080 (class 2606 OID 47771)
-- Name: kullanici_musaitlik_tb kullanici_musaitlik_tb_kullanici_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kullanici_musaitlik_tb
    ADD CONSTRAINT kullanici_musaitlik_tb_kullanici_id_fkey FOREIGN KEY (kullanici_id) REFERENCES public.kullanici_tb(id) ON DELETE CASCADE;


--
-- TOC entry 5079 (class 2606 OID 47757)
-- Name: takim_istatistik_tb takim_istatistik_tb_takim_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_istatistik_tb
    ADD CONSTRAINT takim_istatistik_tb_takim_id_fkey FOREIGN KEY (takim_id) REFERENCES public.takim_tb(id) ON DELETE CASCADE;


--
-- TOC entry 5072 (class 2606 OID 47677)
-- Name: takim_tb takim_tb_kurucu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_tb
    ADD CONSTRAINT takim_tb_kurucu_id_fkey FOREIGN KEY (kurucu_id) REFERENCES public.kullanici_tb(id);


--
-- TOC entry 5073 (class 2606 OID 47695)
-- Name: takim_uyeleri_tb takim_uyeleri_tb_kullanici_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_uyeleri_tb
    ADD CONSTRAINT takim_uyeleri_tb_kullanici_id_fkey FOREIGN KEY (kullanici_id) REFERENCES public.kullanici_tb(id) ON DELETE CASCADE;


--
-- TOC entry 5074 (class 2606 OID 47690)
-- Name: takim_uyeleri_tb takim_uyeleri_tb_takim_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.takim_uyeleri_tb
    ADD CONSTRAINT takim_uyeleri_tb_takim_id_fkey FOREIGN KEY (takim_id) REFERENCES public.takim_tb(id) ON DELETE CASCADE;


-- Completed on 2026-05-11 20:08:59

--
-- PostgreSQL database dump complete
--

\unrestrict eqANb5xri2k8ULunpWRIzwwpvJWibx0UjwwLYpxDkOJe0tWUolyadfojAfOwZqt

