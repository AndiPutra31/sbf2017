-- SQL Manager Lite for PostgreSQL 5.6.2.46690
-- ---------------------------------------
-- Host      : localhost
-- Database  : biis-isef
-- Version   : PostgreSQL 9.5rc1, compiled by Visual C++ build 1800, 64-bit



CREATE SCHEMA participant AUTHORIZATION postgres;
CREATE SCHEMA event AUTHORIZATION postgres;
--
-- Definition for function decrypt (OID = 18170) : 
--
SET search_path = public, pg_catalog;
SET check_function_bodies = false;
CREATE FUNCTION public.decrypt (
  atext character varying
)
RETURNS varchar
AS 
$body$
DECLARE
  RText VARCHAR(50) := '';
  i int;
  n int;
  c char(1);
BEGIN
   n := length(atext);
   for i in 1..n loop
    c := substring(atext, i, 1);
    RText := RText || chr(ascii(c)-i);
  end loop;
  return RText;
END;
$body$
LANGUAGE plpgsql;
--
-- Definition for function encrypt (OID = 18171) : 
--
CREATE FUNCTION public.encrypt (
  atext character varying
)
RETURNS varchar
AS 
$body$
DECLARE
  RText VARCHAR(50) := '';
  i int;
  n int;
  c char(1);
BEGIN
  n := length(atext);
  for i in 1..n loop
    c := substring(atext, i, 1);
    RText := RText || chr(ascii(c)+i);
  end loop;
  return RText;
END;
$body$
LANGUAGE plpgsql;
--
-- Structure for table isef (OID = 18172) : 
--
CREATE TABLE public.isef (
    id bigint NOT NULL,
    registration text,
    name text NOT NULL,
    bod date,
    address text NOT NULL,
    email text NOT NULL,
    phone text NOT NULL,
    business_name text,
    file1 text,
    file2 text,
    file3 text,
    type integer,
    location integer,
    experience text,
    art_name text,
    coor_name text,
    member integer,
    register_time timestamp(0) without time zone DEFAULT now()
)
WITH (oids = false);
--
-- Structure for table isef_location (OID = 18179) : 
--
CREATE TABLE public.isef_location (
    isef_location_id integer NOT NULL,
    isef_location_name text
)
WITH (oids = false);
--
-- Definition for type priority (OID = 18186) : 
--
CREATE TYPE public.priority AS ENUM (
  'low', 'middle', 'high'
);
--
-- Structure for table agenda (OID = 18193) : 
--
CREATE TABLE public.agenda (
    id integer NOT NULL,
    agenda_title text,
    agenda_description text,
    agenda_start timestamp without time zone,
    agenda_finish timestamp without time zone,
    agenda_allday integer,
    agenda_priority priority,
    user_id text,
    creation_date date
)
WITH (oids = false);
--
-- Structure for table agenda_detail (OID = 18199) : 
--
CREATE TABLE public.agenda_detail (
    id integer NOT NULL,
    agenda_id integer,
    agenda_to text
)
WITH (oids = false);
--
-- Definition for view agenda_view (OID = 18205) : 
--
CREATE VIEW public.agenda_view
AS
SELECT agenda.id,
    agenda.agenda_title,
    agenda.agenda_description,
    agenda.agenda_start,
    agenda.agenda_finish,
    agenda.agenda_allday,
    agenda.agenda_priority,
    agenda.user_id,
    agenda.creation_date,
    ARRAY(
    SELECT agenda_detail.agenda_to
    FROM agenda_detail
    WHERE (agenda_detail.agenda_id = agenda.id)
    ) AS agenda_to
FROM agenda;

--
-- Structure for table arsip (OID = 18209) : 
--
CREATE TABLE public.arsip (
    id integer NOT NULL,
    arsip_name text,
    arsip_file text,
    category_arsip_id integer,
    user_id text,
    creation_date date
)
WITH (oids = false);
--
-- Structure for table article_theme (OID = 18217) : 
--
CREATE TABLE public.article_theme (
    article_theme_id bigserial NOT NULL,
    article_theme_name text,
    is_active integer DEFAULT 1
)
WITH (oids = false);
--
-- Structure for table category (OID = 18225) : 
--
CREATE TABLE public.category (
    id integer NOT NULL,
    category_name text
)
WITH (oids = false);
--
-- Structure for table category_arsip (OID = 18231) : 
--
CREATE TABLE public.category_arsip (
    id integer NOT NULL,
    category_name text,
    group_id text
)
WITH (oids = false);
--
-- Definition for view category_arsip_view (OID = 18237) : 
--
CREATE VIEW public.category_arsip_view
AS
SELECT category_arsip.id,
    category_arsip.category_name,
    category_arsip.group_id,
        CASE
            WHEN (category_total.total IS NULL) THEN (0)::bigint
            ELSE category_total.total
        END AS total
FROM (category_arsip
     LEFT JOIN (
    SELECT arsip.category_arsip_id,
            count(*) AS total
    FROM arsip
    GROUP BY arsip.category_arsip_id
    ) category_total ON ((category_total.category_arsip_id = category_arsip.id)));

--
-- Structure for table category_faq (OID = 18241) : 
--
CREATE TABLE public.category_faq (
    id integer NOT NULL,
    category_faq text,
    category_faq_desc text
)
WITH (oids = false);
--
-- Structure for table chat (OID = 18249) : 
--
CREATE TABLE public.chat (
    id bigserial NOT NULL,
    "from" text,
    "to" text,
    message text,
    sent timestamp(0) without time zone DEFAULT now() NOT NULL,
    recd integer DEFAULT 0
)
WITH (oids = false);
--
-- Structure for table comment (OID = 18258) : 
--
CREATE TABLE public.comment (
    id integer NOT NULL,
    post_id integer,
    parent_id integer,
    user_id text,
    comment_description text,
    comment_date timestamp(0) without time zone
)
WITH (oids = false);
--
-- Structure for table employee (OID = 18264) : 
--
CREATE TABLE public.employee (
    id integer NOT NULL,
    company_id integer,
    position_id integer,
    employee_email varchar(200) NOT NULL,
    employee_nid text,
    employee_name text,
    employee_birthday date,
    employee_address text,
    employee_gender integer,
    employee_phone varchar(20),
    employee_approve integer,
    employee_password text,
    employee_status integer,
    confirmation_code varchar(12)
)
WITH (oids = false);
--
-- Definition for view comment_view (OID = 18270) : 
--
CREATE VIEW public.comment_view
AS
SELECT comment.id,
    comment.post_id,
    comment.parent_id,
    comment.user_id,
    comment.comment_description,
    comment.comment_date,
    employee.employee_name
FROM (comment
     LEFT JOIN employee ON (((employee.employee_email)::text = comment.user_id)));

--
-- Structure for table company (OID = 18274) : 
--
CREATE TABLE public.company (
    id integer NOT NULL,
    company_name text,
    prefix_email text
)
WITH (oids = false);
--
-- Structure for table config (OID = 18280) : 
--
CREATE TABLE public.config (
    id integer NOT NULL,
    config_email varchar(60),
    config_message text
)
WITH (oids = false);
--
-- Structure for table employee_group (OID = 18286) : 
--
CREATE TABLE public.employee_group (
    id integer NOT NULL,
    employee_group_name text,
    user_id text,
    creation_date date
)
WITH (oids = false);
--
-- Structure for table employee_group_detail (OID = 18292) : 
--
CREATE TABLE public.employee_group_detail (
    id integer NOT NULL,
    employee_group_id integer,
    employee_id integer
)
WITH (oids = false);
--
-- Definition for view employee_group_view (OID = 18295) : 
--
CREATE VIEW public.employee_group_view
AS
SELECT employee_group.id,
    employee_group.employee_group_name,
    employee_group.user_id,
    employee_group.creation_date,
    ARRAY(
    SELECT employee.employee_email
    FROM (employee_group_detail
             LEFT JOIN employee ON ((employee.id =
                 employee_group_detail.employee_id)))
    WHERE (employee_group.id = employee_group_detail.employee_group_id)
    ) AS employee_email
FROM employee_group;

--
-- Structure for table faq (OID = 18299) : 
--
CREATE TABLE public.faq (
    id integer NOT NULL,
    category_faq_id integer,
    faq_answer text,
    faq_question text
)
WITH (oids = false);
--
-- Structure for table group (OID = 18305) : 
--
CREATE TABLE public."group" (
    id integer NOT NULL,
    group_code varchar(3),
    group_name varchar(30),
    group_description text
)
WITH (oids = false);
--
-- Structure for table media (OID = 18311) : 
--
CREATE TABLE public.media (
    id integer NOT NULL,
    name text,
    url text,
    user_id text
)
WITH (oids = false);
--
-- Structure for table menu (OID = 18317) : 
--
CREATE TABLE public.menu (
    id integer NOT NULL,
    parent_id integer,
    name varchar(50),
    url varchar(100),
    iconcls varchar(100),
    sort integer,
    published integer
)
WITH (oids = false);
--
-- Structure for table participant (OID = 18322) : 
--
CREATE TABLE public.participant (
    participant_id bigserial NOT NULL,
    participant_number text,
    participant_category_id integer NOT NULL,
    participant_type_id integer NOT NULL,
    article_theme_id integer NOT NULL,
    article_tittle text,
    article_file text,
    full_article_file text,
    cv_file text,
    participant_status integer DEFAULT 0,
    creation_date timestamp(0) without time zone,
    confirmation_code text
)
WITH (oids = false);
--
-- Structure for table participant_category (OID = 18332) : 
--
CREATE TABLE public.participant_category (
    participant_category_id bigserial NOT NULL,
    participant_category_name text NOT NULL,
    is_active integer DEFAULT 1
)
WITH (oids = false);
--
-- Structure for table participant_detail (OID = 18342) : 
--
CREATE TABLE public.participant_detail (
    participant_detail_id bigserial NOT NULL,
    participant_id integer,
    participant_detail_name text,
    address text,
    intitution_name text,
    intitution_address text,
    mobile_phone text,
    mail_address text
)
WITH (oids = false);
--
-- Structure for table participant_statuses (OID = 18349) : 
--
CREATE TABLE public.participant_statuses (
    participant_status_id integer NOT NULL,
    participant_status_name text
)
WITH (oids = false);
--
-- Structure for table position (OID = 18355) : 
--
CREATE TABLE public."position" (
    id integer NOT NULL,
    position_title text
)
WITH (oids = false);
--
-- Structure for table post (OID = 18361) : 
--
CREATE TABLE public.post (
    id integer NOT NULL,
    category_id integer,
    thumbnail_id integer,
    post_title text,
    post_content text,
    user_id text,
    creation_date date,
    modifate_date date,
    post_status integer DEFAULT 0
)
WITH (oids = false);
--
-- Definition for view post_view (OID = 18368) : 
--
CREATE VIEW public.post_view
AS
SELECT post.id,
    post.category_id,
    post.thumbnail_id,
    post.post_title,
    post.post_status,
    post.post_content,
    post.user_id,
    post.creation_date,
    post.modifate_date,
    employee.employee_name,
    employee.id AS employee_id,
        CASE
            WHEN (comment.total IS NULL) THEN (0)::bigint
            ELSE comment.total
        END AS total
FROM ((post
     LEFT JOIN (
    SELECT comment_1.post_id,
            count(*) AS total
    FROM comment comment_1
    GROUP BY comment_1.post_id
    ) comment ON ((comment.post_id = post.id)))
     LEFT JOIN employee ON ((post.user_id = (employee.employee_email)::text)));

--
-- Structure for table role (OID = 18373) : 
--
CREATE TABLE public.role (
    id integer NOT NULL,
    menu_id integer,
    group_id integer,
    is_active integer
)
WITH (oids = false);
--
-- Structure for table task (OID = 18376) : 
--
CREATE TABLE public.task (
    task_id integer NOT NULL,
    task_title text,
    task_content text,
    task_for text,
    approve_by text,
    creation_user text,
    creation_date timestamp(0) without time zone,
    modifate_user text,
    modifate_date timestamp(0) without time zone
)
WITH (oids = false);
--
-- Structure for table task_detail (OID = 18382) : 
--
CREATE TABLE public.task_detail (
    task_detail_id integer NOT NULL,
    task_id integer,
    task_for text
)
WITH (oids = false);
--
-- Structure for table task_report (OID = 18388) : 
--
CREATE TABLE public.task_report (
    task_report_id integer NOT NULL,
    task_id integer,
    task_report_content text,
    task_report_status text,
    creation_user text,
    creation_date timestamp(0) without time zone
)
WITH (oids = false);
--
-- Structure for table user (OID = 18394) : 
--
CREATE TABLE public."user" (
    id integer NOT NULL,
    user_id varchar(200) NOT NULL,
    group_id integer,
    passwd text NOT NULL,
    last_active timestamp(0) without time zone
)
WITH (oids = false);
--
-- Structure for table participant (OID = 18544) : 
--
SET search_path = participant, pg_catalog;
CREATE TABLE participant.participant (
    id integer NOT NULL,
    company_id integer,
    event_id integer,
    event_category_id integer,
    event_package_id integer,
    participant_name text,
    participant_address text,
    participant_mobile integer,
    participant_email text,
    "participant_sosmed_FB" text,
    participant_sosmed_twitter text,
    "participant_sosmed_IG" text,
    participant_company text,
    participant_password text,
    status_file integer DEFAULT 0,
    status_payment integer DEFAULT 0,
    creation_time timestamp without time zone,
    creation_user integer,
    last_mod_time timestamp without time zone,
    last_mod_user integer,
    memo_lines1 numeric,
    memo_lines2 text,
    memo_lines3 text,
    memo_lines4 text,
    memo_lines5 text,
    memo_lines6 text,
    memo_lines7 text,
    memo_lines8 text,
    memo_lines9 text,
    memo_lines10 text,
    participant_category text
)
WITH (oids = false);
--
-- Structure for table event (OID = 18597) : 
--
SET search_path = event, pg_catalog;
CREATE TABLE event.event (
    id integer NOT NULL,
    company_id integer,
    event_name text,
    creation_user integer,
    creation_time timestamp without time zone,
    last_mod_time timestamp without time zone,
    last_mod_user integer,
    is_deleted integer DEFAULT 0
)
WITH (oids = false);
--
-- Structure for table event_category (OID = 18606) : 
--
CREATE TABLE event.event_category (
    id integer NOT NULL,
    company_id integer,
    event_id integer,
    category_name text,
    creation_time timestamp without time zone,
    creation_user integer,
    last_mod_time timestamp without time zone,
    last_mod_user integer,
    is_deleted integer DEFAULT 0
)
WITH (oids = false);
--
-- Structure for table event_package (OID = 18615) : 
--
CREATE TABLE event.event_package (
    id integer NOT NULL,
    company_id integer,
    event_category_id integer,
    package_name text,
    package_price numeric,
    creation_time timestamp without time zone,
    creation_user integer,
    last_mod_time timestamp without time zone,
    last_mod_user integer,
    is_deleted integer DEFAULT 0
)
WITH (oids = false);
SET search_path = public, pg_catalog;
--
-- Data for table public.isef (OID = 18172) (LIMIT 0,47)
--
INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (40, '01010004', 'Ariana Nisaa Walker', '1997-10-31', 'Jalan Papa Biru 61, Tulusrejo, Lowokwaru, Malang.', 'icawalker37@gmail.com', '081216879398', NULL, 'assets/upload/01010004/foto_depan.jpg', 'assets/upload/01010004/foto_samping.jpg', 'assets/upload/01010004/foto_close_up.jpg', 1, 1, NULL, NULL, NULL, NULL, NULL);

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (41, '01010005', 'Fitri cahyaning', '1990-07-01', 'Jl raya wonokerso pakisaji no 15 malang', 'Abitubi.a@gmail.com', '081331307122', NULL, 'assets/upload/01010005/foto_depan.jpg', 'assets/upload/01010005/foto_samping.jpg', 'assets/upload/01010005/foto_close_up.jpg', 1, 1, NULL, NULL, NULL, NULL, NULL);

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (49, '01010008', 'Fithri Atika Ulfa', '1996-02-29', 'Jalan Mayjend Panjaitan Dalam No.30 Malang', 'fithriatikaulfa@gmail.com', '089685358722', NULL, 'assets/upload/01010008/foto_depan.jpg', 'assets/upload/01010008/foto_samping.jpg', 'assets/upload/01010008/foto_close_up.jpg', 1, 1, NULL, NULL, NULL, NULL, '2017-09-13 21:35:09');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (60, '01030001', 'Zainul Abidin', '1988-04-15', 'Perumahan Puncak Permata Sengkaling Blok K5 Ds. Sumbersekar Kec. Dau Kab. Malang', 'mysuccess.abidin@gmail.com', '085334956522', 'Jamur Nusantara', 'assets/upload/01030001/Zainul_Abidin_085334956522_dokumen_usaha.pdf', NULL, NULL, 3, 1, NULL, NULL, NULL, NULL, '2017-09-14 22:21:14');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (69, '03010007', 'Maghfiroh Robbaniyah', '1999-12-27', 'Jalan Teratai VIII/170 Kaliwates Jember', 'maghfyroh@gmail.com', '082145470687', NULL, 'assets/upload/03010007/Maghfiroh_Robbaniyah_082145470687_foto_depan.jpg', 'assets/upload/03010007/Maghfiroh_Robbaniyah_082145470687_foto_samping.jpg', 'assets/upload/03010007/Maghfiroh_Robbaniyah_082145470687_foto_close_up.JPG', 1, 3, NULL, NULL, NULL, NULL, '2017-09-15 16:12:42');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (78, '01020003', 'Fairuza Fasya Rahaditsy', '2010-08-19', 'Jl. Belakang Pasar Pakis- Ds. Pakisjajar- Kec. Pakis- Kab. Malang ', 'Giyanfitrotul.umi@gmail.com', '085101626908', NULL, NULL, NULL, NULL, 2, 1, 'Juara 1 lomba pildacil se kecamatan Pakis,  juara 1 lomba pildacil tingkat Tk se kawedana ', NULL, NULL, NULL, '2017-09-17 10:47:06');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (85, '04020002', 'Maulana Salman Alfarisi', '2006-01-28', 'Jln. Raya Mojo dsn. Tempursari Ds. Sukoanyar Kec. Mojo kab. Kediri Rt. 05 Rw. 01', 'imam.mustajib99@gmail.com', '081359944617', NULL, NULL, NULL, NULL, 2, 4, NULL, NULL, NULL, NULL, '2017-09-17 20:24:30');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (86, '02050002', 'jhbb', '2000-07-13', 'jshnsn', 'afifahaziec@yahoo.com', '089661679493', NULL, 'assets/upload/02050002/jhbb_089661679493_foto_karya.jpg', NULL, NULL, 5, 2, NULL, NULL, NULL, NULL, '2017-09-18 09:00:53');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (42, '04010004', 'EMI MUSYAFAAH', '1996-08-29', 'Kelutan Ngronggot Nganjuk', 'syafaelfahrezy@gmail.com', '08563440911', NULL, 'assets/upload/04010004/foto_depan.jpg', 'assets/upload/04010004/foto_samping.jpg', 'assets/upload/04010004/foto_close_up.jpg', 1, 4, NULL, NULL, NULL, NULL, NULL);

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (50, '03010004', 'R.A Putri Ayu Dianisa', '1997-05-10', 'Dusun gilin rt/rw 006/002 randutatah paiton probolinggo', 'putriayudianisa@gmail.com', '082359389458', NULL, 'assets/upload/03010004/foto_depan.jpg', 'assets/upload/03010004/foto_samping.jpg', 'assets/upload/03010004/foto_close_up.jpg', 1, 3, NULL, NULL, NULL, NULL, '2017-09-14 06:55:28');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (58, '02010001', 'Sayyidah Putri', '1997-05-01', 'Jl. Jenggolo I blok D/7 RT 04 RW 01 Pucang Sidoarjo', 'sayyidah.putri.am@gmail.com', '081335600030', NULL, NULL, NULL, NULL, 1, 2, NULL, NULL, NULL, NULL, '2017-09-14 17:44:24');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (61, '02020003', 'SATRIA MAHA DEWA', '2006-06-03', 'JL IRIAN JAYA NO 02 GATOEL MOJOKERTO', 'saktimu_3d@yahoo.co.id', '085707023661', NULL, 'assets/upload/02020003/SATRIA_MAHA_DEWA_085707023661_sertifikat1.jpg', 'assets/upload/02020003/SATRIA_MAHA_DEWA_085707023661_sertifikat2.jpg', NULL, 2, 2, NULL, NULL, NULL, NULL, '2017-09-15 07:29:57');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (64, '04010005', 'SEPTIANES NORA KARTIKA', '1997-09-20', 'PERUMAHAN PERMATA HIJAU BLOK N-4 KEDIRI', 'kartikaanes.ofc@gmail.com', '081331534001', NULL, 'assets/upload/04010005/SEPTIANES_NORA_KARTIKA_081331534001_foto_depan.jpg', 'assets/upload/04010005/SEPTIANES_NORA_KARTIKA_081331534001_foto_samping.jpg', 'assets/upload/04010005/SEPTIANES_NORA_KARTIKA_081331534001_foto_close_up.jpg', 1, 4, NULL, NULL, NULL, NULL, '2017-09-15 11:01:41');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (71, '02010002', 'Dyah Puspitaning Ayu', '1999-11-05', 'Jalan ketintang gng nirwana rt. 12 rw 04 nmr.133 c4 surabaya', 'dyahpuspitaningayu1105@gmail.com', '082335974796', NULL, 'assets/upload/02010002/Dyah_Puspitaning_Ayu_082335974796_foto_depan.jpg', 'assets/upload/02010002/Dyah_Puspitaning_Ayu_082335974796_foto_samping.jpg', 'assets/upload/02010002/Dyah_Puspitaning_Ayu_082335974796_foto_close_up.jpg', 1, 2, NULL, NULL, NULL, NULL, '2017-09-15 21:34:07');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (79, '01010011', 'Trina Septiani', '1995-09-18', 'Jalan Bogor no 24 Malang', 'trina.septiani@gmail.com', '085758162616', NULL, 'assets/upload/01010011/Trina_Septiani_085758162616_foto_depan.JPG', 'assets/upload/01010011/Trina_Septiani_085758162616_foto_samping.JPG', 'assets/upload/01010011/Trina_Septiani_085758162616_foto_close_up.JPG', 1, 1, NULL, NULL, NULL, NULL, '2017-09-17 11:49:36');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (43, '03010001', 'MAULIDIANA SILMI MUAFA', '1998-06-25', 'DUSUN BRINGINSARI JATIMULYO JENGGAWAH', 'maulidiana12@yahoo.co.id', '08123272775', NULL, 'assets/upload/03010001/foto_depan.jpg', 'assets/upload/03010001/foto_samping.jpg', 'assets/upload/03010001/foto_close_up.jpg', 1, 3, NULL, NULL, NULL, NULL, NULL);

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (45, '01040001', 'Nur Muhammad', NULL, 'Sengkaling', 'lainurrohman@yahoo.com', '085645707851', NULL, 'assets/upload/01040001/foto_penampilan.jpg', NULL, NULL, 4, 1, NULL, 'Hadrah Al Banjari', 'Nur Fatih Ahmad', 10, '2017-09-13 10:03:04');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (51, '01020001', 'Ahmad Nur Herrifudin', '2017-09-14', 'SDN MERJOSARI 3 MALANG', 'yuliarsorudi94@gmail.com', '085790433954', NULL, NULL, NULL, NULL, 2, 1, 'JUARA LOMBA PILDACIL SEKOLAHAN', NULL, NULL, NULL, '2017-09-14 08:44:54');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (62, '02020004', 'rabbani al - kayyis', '2011-08-19', 'sawahan templek 3 no. 5', 'asti.sk2@gmail.com', '085334887581', NULL, NULL, NULL, NULL, 2, 2, 'lomba di sekolah', NULL, NULL, NULL, '2017-09-15 07:34:03');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (12, '01010001', 'Nurul Nhafia', '1996-08-25', 'Perum.omacampus A3/16 Dau', 'nhafiaverda@yahoo.co.id', '083835324309', NULL, 'assets/upload/01010001/foto_depan.jpg', 'assets/upload/01010001/foto_samping.jpg', 'assets/upload/01010001/foto_close_up.jpg', 1, 1, NULL, NULL, NULL, NULL, NULL);

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (72, '01040002', 'Fakultas Ekonomi Universitas Islam Malang', NULL, 'Jl. Mayjen Haryono No.193, Dinoyo, Kec. Lowokwaru, Kota Malang, Jawa Timur 65144', 'teguhby95@gmail.com', '082141888625', NULL, 'assets/upload/01040002/Fakultas_Ekonomi_Universitas_Islam_Malang_082141888625_foto_penampilan.jpg', NULL, NULL, 4, 1, NULL, 'Al-banjari', 'Teguh', 10, '2017-09-16 05:30:28');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (80, '04020001', 'Fina Nada Fatimatuz Zahro''', '2006-01-12', 'Ds.Sawentar RT. 01.RW. 02 Kanigoro Blitar', 'gusmuhfadli@gmail.com', '085859984435', NULL, 'assets/upload/04020001/Fina_Nada_Fatimatuz_Zahro''_085859984435_sertifikat1.jpeg', NULL, NULL, 2, 4, NULL, NULL, NULL, NULL, '2017-09-17 14:23:15');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (44, '03010002', 'MAULIDIANA SILMI MUAFA', '1998-06-22', 'DUSUN BRINGINSARI JATIMULYO JENGGAWAH', 'maulidiana12@yahoo.co.id', '081232726775', NULL, 'assets/upload/03010002/foto_depan.jpg', 'assets/upload/03010002/foto_samping.jpg', 'assets/upload/03010002/foto_close_up.jpg', 1, 3, NULL, NULL, NULL, NULL, NULL);

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (46, '01010006', 'Sabrina mufidha', '1995-04-03', 'Perumahan margatama asri F6 Kel. Kanigoro Kec. Kartoharjo', 'sabrina.mufidha95@yahoo.com', '082132612122', NULL, 'assets/upload/01010006/foto_depan.jpg', 'assets/upload/01010006/foto_samping.jpg', 'assets/upload/01010006/foto_close_up.jpg', 1, 1, NULL, NULL, NULL, NULL, '2017-09-13 12:25:05');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (53, '02020001', 'Ayumi Mutia Lovynia', '2009-09-09', 'Puri RT 03 RW 01 Puri Mojokerto', 'ahmad.littlecamelmjk@gmail.com', '085707023661', NULL, 'assets/upload/02020001/sertifikat1.jpg', NULL, NULL, 2, 2, NULL, NULL, NULL, NULL, '2017-09-14 09:48:51');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (52, '03010005', 'MAULIDIANA SILMI MUAFA', '1998-06-25', 'DUSUN BRINGINSARI JATIMULYO JENGGAWAH', 'maulidiana12@yahoo.co.id', '081232726775', NULL, 'assets/upload/03010005/foto_depan.jpeg', 'assets/upload/03010005/foto_samping.jpeg', 'assets/upload/03010005/foto_close_up.jpeg', 1, 3, NULL, NULL, NULL, NULL, '2017-09-14 09:45:24');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (63, '03040001', 'PP AL IMAM', NULL, 'SUMURAN', 'akh.aliwafa@yahoo.co.id', '083847264188', NULL, NULL, NULL, NULL, 4, 3, NULL, 'patrol musical qosidah', 'SYAMSUL ARIFIN', 11, '2017-09-15 08:53:27');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (74, '02020005', 'Resta Ayu', '1999-11-08', 'Mojokerto', 'restayu247@gmail.com', '085748894476', NULL, NULL, NULL, NULL, 2, 2, NULL, NULL, NULL, NULL, '2017-09-16 09:36:11');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (81, '03020002', 'ADELIA NAJWA AULIYA', '2005-11-27', 'Dsn:sumber uling RT:004/RW:002 Desa:pringgowirawan Kec:sumber baru kab:jember', 'adelianajwa94@gmail.com', '6285378316228', NULL, 'assets/upload/03020002/ADELIA_NAJWA_AULIYA_6285378316228_sertifikat1.jpg', 'assets/upload/03020002/ADELIA_NAJWA_AULIYA_6285378316228_sertifikat2.jpg', NULL, 2, 3, NULL, NULL, NULL, NULL, '2017-09-17 14:42:34');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (59, '02020002', 'ZIDAH MUTAMINAH', '2007-06-24', 'Lingk. Kebohan RT.03 RW.08, Kel. Gununggedangan, Kec. Magersari, Kota Mojokerto, Kode Pos 61315', 'nurlailatulfitria93@gmail.com', '085648050748', NULL, 'assets/upload/02020002/ZIDAH_MUTAMINAH_085648050748_sertifikat1.jpg', 'assets/upload/02020002/ZIDAH_MUTAMINAH_085648050748_sertifikat2.jpg', 'assets/upload/02020002/ZIDAH_MUTAMINAH_085648050748_sertifikat3.jpg', 2, 2, NULL, NULL, NULL, NULL, '2017-09-14 20:21:46');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (37, '04010003', 'SEPTIANES NORA KARTIKA', '2017-09-09', 'PERUMAHAN PERMATA HIJAU BLOK N-4 KEDIRI', 'tikaanes96@gmail.com', '081331534001', NULL, 'assets/upload/04010003/foto_depan.jpg', 'assets/upload/04010003/foto_samping.jpg', 'assets/upload/04010003/foto_close_up.jpg', 1, 4, NULL, NULL, NULL, NULL, NULL);

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (66, '01010009', 'Amalia Apriliani', '1996-04-15', 'Jalan Margobasuki no 39, Mulyoagung, Dau, Malang.', 'aapriliani43@gmail.com', '082139742765', NULL, 'assets/upload/01010009/Amalia_Apriliani_082139742765_foto_depan.jpg', 'assets/upload/01010009/Amalia_Apriliani_082139742765_foto_samping.jpg', 'assets/upload/01010009/Amalia_Apriliani_082139742765_foto_close_up.jpg', 1, 1, NULL, NULL, NULL, NULL, '2017-09-15 12:39:24');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (70, '04010007', 'Lutfi Birul Muawanah', '1996-10-16', 'Jl. Kediri-warujayeng - Dsn. Tanjung - Ds. Ngablak - Kec. Banyakan - Kab. Kediri', 'vivi.risdwiantara@yahoo.com', '085853497150', NULL, 'assets/upload/04010007/Lutfi_Birul_Muawanah_085853497150_foto_depan.jpg', 'assets/upload/04010007/Lutfi_Birul_Muawanah_085853497150_foto_samping.jpg', 'assets/upload/04010007/Lutfi_Birul_Muawanah_085853497150_foto_close_up.jpg', 1, 4, NULL, NULL, NULL, NULL, '2017-09-15 19:35:04');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (73, '01020002', 'Aina hafsah', '2018-09-17', 'Jl gadang GG 17 b no 83 RT 05 RW 03 kelurahan gadang kecamatan sukun kotamadya malang', 'muchamad.agus57@gmail.com', '08123227857', NULL, NULL, NULL, NULL, 2, 1, NULL, NULL, NULL, NULL, '2017-09-16 09:03:43');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (75, '01030002', 'Anjani Sekar Arum', '1991-04-12', 'Jl. Brantas Gg.2 No. 3 RT.01 RW.01 Kel. Ngaglik Kec. Batu Kota Batu', 'anjanibatikgaleri@gmail.com', '081334326430', 'Anjanie Batik Galery', NULL, NULL, NULL, 3, 1, NULL, NULL, NULL, NULL, '2017-09-16 10:03:27');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (82, '02050001', 'AMEERA NAWAL A', '2008-08-27', 'NGERING RT 02 RW 04 LEGOK GEMPOL PASURUAN ', 'anas.hafiemusya.ahm@gmail.com', '082330999102', NULL, 'assets/upload/02050001/AMEERA_NAWAL_A_082330999102_foto_karya.jpeg', NULL, NULL, 5, 2, NULL, NULL, NULL, NULL, '2017-09-17 15:30:27');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (47, '03010003', 'Nurul Hidayati', '1998-10-23', 'Puspo Pasuruan', 'nurulbee3439@gmail.com', '085807293718', NULL, 'assets/upload/03010003/foto_depan.jpg', 'assets/upload/03010003/foto_samping.jpg', 'assets/upload/03010003/foto_close_up.jpg', 1, 3, NULL, NULL, NULL, NULL, '2017-09-13 17:51:01');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (65, '03010006', 'Anggie Devi Hariyanti', '1996-12-11', 'Jalan KH Sepuh No 01 Gg Liku-Liku Desa Gentong Kec Gadingrejo Kota Pasuruan', 'Devianggie7@gmail.com', '081234872987', NULL, 'assets/upload/03010006/Anggie_Devi_Hariyanti_081234872987_foto_depan.jpeg', 'assets/upload/03010006/Anggie_Devi_Hariyanti_081234872987_foto_samping.jpeg', 'assets/upload/03010006/Anggie_Devi_Hariyanti_081234872987_foto_close_up.jpg', 1, 3, NULL, NULL, NULL, NULL, '2017-09-15 11:11:06');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (39, '01010003', 'Yurike Dewi Ismawati', '1995-04-14', 'Jalan Kertosariro no.54 Malang', 'yurikedewi34@gmail.com', '085736835386', NULL, 'assets/upload/01010003/foto_depan.jpg', 'assets/upload/01010003/foto_samping.jpg', 'assets/upload/01010003/foto_close_up.jpg', 1, 1, NULL, NULL, NULL, NULL, NULL);

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (67, '04010006', 'Dwi Wahyu Ika Mahardika', '1996-08-16', 'Jl abiyoso ds. Pijeran kec.siman kab. Ponorogo', 'dikamerdeka123@gmail.com', '081353343519', NULL, 'assets/upload/04010006/Dwi_Wahyu_Ika_Mahardika_081353343519_foto_depan.jpg', 'assets/upload/04010006/Dwi_Wahyu_Ika_Mahardika_081353343519_foto_samping.jpg', 'assets/upload/04010006/Dwi_Wahyu_Ika_Mahardika_081353343519_foto_close_up.jpg', 1, 4, NULL, NULL, NULL, NULL, '2017-09-15 13:30:48');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (76, '02010003', 'Rahmalia Rosa Anggraini', '2000-07-04', 'Unggahan Banjaragung Puri Mojokerto ', 'rahmaliarosa04@gmail.com', '085852918782', NULL, 'assets/upload/02010003/Rahmalia_Rosa_Anggraini_085852918782_foto_depan.jpg', 'assets/upload/02010003/Rahmalia_Rosa_Anggraini_085852918782_foto_samping.jpg', 'assets/upload/02010003/Rahmalia_Rosa_Anggraini_085852918782_foto_close_up.jpg', 1, 2, NULL, NULL, NULL, NULL, '2017-09-16 14:31:25');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (83, '03030001', 'AFRIYADI AMIN ', '1995-07-24', 'Jl.kyai mojo kaliwates', 'apriadiamin605@yahoo.com', '082383366437', 'Teh Amin', NULL, NULL, NULL, 3, 3, NULL, NULL, NULL, NULL, '2017-09-17 18:40:40');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (48, '01010007', 'Yurike Dewi Ismawati', '1995-04-14', 'Jalan Kertosariro no.54 Malang', 'yurikedewi34@gmail.com', '085736835386', NULL, 'assets/upload/01010007/foto_depan.jpg', 'assets/upload/01010007/foto_samping.jpg', 'assets/upload/01010007/foto_close_up.jpg', 1, 1, NULL, NULL, NULL, NULL, '2017-09-13 20:40:04');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (68, '01010010', 'Sajidah Ummu Afinah', '1995-06-11', 'Jl. Raya Panglima Sudirman, Ds. Karanggeger RT/RW 09/04, Kec. Pajarakan, Probolinggo.', 'sajidahummuafinah@gmail.com', '083853240957', NULL, 'assets/upload/01010010/Sajidah_Ummu_Afinah_083853240957_foto_depan.JPG', 'assets/upload/01010010/Sajidah_Ummu_Afinah_083853240957_foto_samping.JPG', 'assets/upload/01010010/Sajidah_Ummu_Afinah_083853240957_foto_close_up.jpg', 1, 1, NULL, NULL, NULL, NULL, '2017-09-15 14:27:30');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (38, '01010002', 'Yurike Dewi Ismawati', '1995-04-14', 'Jalan Kertosariro no.54 Malang', 'yurikedewi34@gmail.com', '085736835386', NULL, 'assets/upload/01010002/foto_depan.jpg', 'assets/upload/01010002/foto_samping.jpg', 'assets/upload/01010002/foto_close_up.jpg', 1, 1, NULL, NULL, NULL, NULL, NULL);

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (77, '03020001', 'ADELIA NAJWA AULIYA', '2005-11-27', 'Dsn:sumber uling RT:004/RW:002 Desa:pringgowirawan Kec:sumber baru', 'nilanafis18@gmail.com', '082330107551', NULL, 'assets/upload/03020001/ADELIA_NAJWA_AULIYA_082330107551_sertifikat1.jpg', 'assets/upload/03020001/ADELIA_NAJWA_AULIYA_082330107551_sertifikat2.jpg', NULL, 2, 3, NULL, NULL, NULL, NULL, '2017-09-16 22:29:12');

INSERT INTO isef (id, registration, name, bod, address, email, phone, business_name, file1, file2, file3, type, location, experience, art_name, coor_name, member, register_time)
VALUES (84, '01010012', 'Windi Eka Sari', '1994-01-31', 'Dadapan kulon rt.05/rw.04 Desa Bendosari Kecamatan Pujon Kabupaten Malang', 'Windiekasari@yahoo.com', '081232737066', NULL, 'assets/upload/01010012/Windi_Eka_Sari_081232737066_foto_depan.JPG', 'assets/upload/01010012/Windi_Eka_Sari_081232737066_foto_samping.JPG', 'assets/upload/01010012/Windi_Eka_Sari_081232737066_foto_close_up.JPG', 1, 1, NULL, NULL, NULL, NULL, '2017-09-17 18:52:18');

--
-- Data for table public.isef_location (OID = 18179) (LIMIT 0,4)
--
INSERT INTO isef_location (isef_location_id, isef_location_name)
VALUES (1, 'Malang');

INSERT INTO isef_location (isef_location_id, isef_location_name)
VALUES (2, 'Surabaya');

INSERT INTO isef_location (isef_location_id, isef_location_name)
VALUES (3, 'Jember');

INSERT INTO isef_location (isef_location_id, isef_location_name)
VALUES (4, 'Kediri');

--
-- Data for table public.agenda (OID = 18193) (LIMIT 0,5)
--
INSERT INTO agenda (id, agenda_title, agenda_description, agenda_start, agenda_finish, agenda_allday, agenda_priority, user_id, creation_date)
VALUES (1, 'Meeting At JAE', 'Membahas tentang billing system', '2017-04-28 10:00:00', '2017-04-28 12:00:00', 1, 'low', NULL, NULL);

INSERT INTO agenda (id, agenda_title, agenda_description, agenda_start, agenda_finish, agenda_allday, agenda_priority, user_id, creation_date)
VALUES (2, 'Meeting 2', 'Meeting 2 Wisma Soewarana', '2017-05-05 10:00:00', '2017-05-05 12:00:00', 1, 'high', NULL, NULL);

INSERT INTO agenda (id, agenda_title, agenda_description, agenda_start, agenda_finish, agenda_allday, agenda_priority, user_id, creation_date)
VALUES (3, 'Meeting at CAS', 'Meeting Portal HR', '2017-05-24 10:00:00', '2017-05-24 12:00:00', 0, 'low', 'admin@pt-cas.com', '2017-05-14');

INSERT INTO agenda (id, agenda_title, agenda_description, agenda_start, agenda_finish, agenda_allday, agenda_priority, user_id, creation_date)
VALUES (4, 'Meeting at JAE', 'Membahas billing system dengan vendor BIIS', '2017-05-29 10:00:00', '2017-05-29 12:00:00', 0, 'low', 'admin@pt-cas.com', '2017-05-15');

INSERT INTO agenda (id, agenda_title, agenda_description, agenda_start, agenda_finish, agenda_allday, agenda_priority, user_id, creation_date)
VALUES (5, 'Workshop Tretes', NULL, '2017-05-15 00:00:00', '2017-05-19 00:00:00', 1, 'low', 'admin@pt-cas.com', '2017-05-15');

--
-- Data for table public.agenda_detail (OID = 18199) (LIMIT 0,7)
--
INSERT INTO agenda_detail (id, agenda_id, agenda_to)
VALUES (1, 3, 'admin@pt-cas.com');

INSERT INTO agenda_detail (id, agenda_id, agenda_to)
VALUES (2, 3, 'iwan.setiawan@cas.com');

INSERT INTO agenda_detail (id, agenda_id, agenda_to)
VALUES (3, 3, 'mahesa.putra@pt-cas.com');

INSERT INTO agenda_detail (id, agenda_id, agenda_to)
VALUES (4, 4, 'admin@pt-cas.com');

INSERT INTO agenda_detail (id, agenda_id, agenda_to)
VALUES (5, 4, 'iwan.setiawan@cas.com');

INSERT INTO agenda_detail (id, agenda_id, agenda_to)
VALUES (6, 4, 'mahesa.putra@pt-cas.com');

INSERT INTO agenda_detail (id, agenda_id, agenda_to)
VALUES (7, 5, 'admin@pt-cas.com');

--
-- Data for table public.arsip (OID = 18209) (LIMIT 0,2)
--
INSERT INTO arsip (id, arsip_name, arsip_file, category_arsip_id, user_id, creation_date)
VALUES (2, 'EK Storage - CGK(1).pdf', 'assets/arsip/2/EK Storage - CGK(1).pdf', 2, 'admin@biis.com', '2017-04-20');

INSERT INTO arsip (id, arsip_name, arsip_file, category_arsip_id, user_id, creation_date)
VALUES (3, 'Dokumen Manual Aplikasi Billing System', 'assets/arsip/3/Manual Aplikasi Billing.pdf', 3, 'indah@pt-cas.com', '2017-04-20');

--
-- Data for table public.article_theme (OID = 18217) (LIMIT 0,10)
--
INSERT INTO article_theme (article_theme_id, article_theme_name, is_active)
VALUES (6, 'Mengukur Kemajuan Penggunaan Financial Technology dan Dampaknya terhadap PerekonomianJawa Timur. ', 1);

INSERT INTO article_theme (article_theme_id, article_theme_name, is_active)
VALUES (7, 'Inovasi Sumber-sumber Pembiayaan Pembangunan sebagai Alternatif di tengah Keterbatasan Kapasitas Fiskal Jawa Timur. ', 1);

INSERT INTO article_theme (article_theme_id, article_theme_name, is_active)
VALUES (8, 'Mengukur Dampak Bonus Demografi di Jawa Timur : Sumber Kekuatan Ekonomi atau Potensi Ketimpangan KesejahteraanSpasial?', 1);

INSERT INTO article_theme (article_theme_id, article_theme_name, is_active)
VALUES (9, 'Memanfaatkan Posisi Strategis Jawa Timur sebagai Bagian dari Global Value Chains.', 1);

INSERT INTO article_theme (article_theme_id, article_theme_name, is_active)
VALUES (10, 'Penguatan Peran Ekonomi Syariah Jawa Timur (Upaya dan Evaluasi) : Pendalaman Pasar Keuangan Syariah, Sinergi Model Bisnis Kewirausahaan dan UMKM berbasis Ekonomi Syariah, sertaPenguatanKolaborasi-Koordinasi.', 1);

INSERT INTO article_theme (article_theme_id, article_theme_name, is_active)
VALUES (1, 'Tendensi Proteksionisme Global : Potensi dan Pengukuran Dampaknya terhadap Perekonomian Jawa Timur. ', 1);

INSERT INTO article_theme (article_theme_id, article_theme_name, is_active)
VALUES (2, 'Mewujudkan Jawa Timur sebagai Pusat Agroindustri : Masalah, Tantangan dan Solusinya. ', 1);

INSERT INTO article_theme (article_theme_id, article_theme_name, is_active)
VALUES (3, 'Menilik Kecenderungan Investasi pada Intangible Assets ? Knowledge Based Capital (KBC) Pelaku Usaha Besar di Jawa Timur.', 1);

INSERT INTO article_theme (article_theme_id, article_theme_name, is_active)
VALUES (4, 'Membangun Pariwisata sebagai Mesin Penggerak Perekonomian Jawa Timur. ', 1);

INSERT INTO article_theme (article_theme_id, article_theme_name, is_active)
VALUES (5, 'Deindustrialisasi Prematur : Faktor-faktor Penyebab dan Solusi Peningkatan Daya Saing Sektor Industri Pengolahan Jawa Timur. ', 1);

--
-- Data for table public.category (OID = 18225) (LIMIT 0,3)
--
INSERT INTO category (id, category_name)
VALUES (1, 'HRIS');

INSERT INTO category (id, category_name)
VALUES (2, 'Info Perusahaan');

INSERT INTO category (id, category_name)
VALUES (3, 'Update Knowledge');

--
-- Data for table public.category_arsip (OID = 18231) (LIMIT 0,3)
--
INSERT INTO category_arsip (id, category_name, group_id)
VALUES (2, 'Document Private', '["1"]');

INSERT INTO category_arsip (id, category_name, group_id)
VALUES (1, 'Document Public', '["1","2","3"]');

INSERT INTO category_arsip (id, category_name, group_id)
VALUES (3, 'Document HRIS', '["3"]');

--
-- Data for table public.category_faq (OID = 18241) (LIMIT 0,3)
--
INSERT INTO category_faq (id, category_faq, category_faq_desc)
VALUES (2, NULL, 'Payment');

INSERT INTO category_faq (id, category_faq, category_faq_desc)
VALUES (1, NULL, 'General Questions');

INSERT INTO category_faq (id, category_faq, category_faq_desc)
VALUES (3, NULL, 'Portal HR');

--
-- Data for table public.chat (OID = 18249) (LIMIT 0,14)
--
INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (7, 'admin@pt-cas.com', 'iwan.setiawan@cas.com', 'tes pak iiwan', '2017-05-23 09:37:28', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (9, 'admin@pt-cas.com', 'iwan.setiawan@cas.com', 'tes pak', '2017-05-23 09:38:19', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (10, 'bagusmertha@manajemenit.com', 'iwan.setiawan@cas.com', 'pak iwan', '2017-05-23 09:38:53', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (14, 'admin@pt-cas.com', 'iwan.setiawan@cas.com', 'iya pak iwan..', '2017-05-25 08:04:52', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (2, 'admin@pt-cas.com', 'bagusmertha@manajemenit.com', 'masuk', '2017-05-22 17:42:25', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (4, 'admin@pt-cas.com', 'bagusmertha@manajemenit.com', 'jnj', '2017-05-22 17:43:01', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (5, 'admin@pt-cas.com', 'bagusmertha@manajemenit.com', 'coba', '2017-05-22 17:44:33', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (12, 'admin@pt-cas.com', 'bagusmertha@manajemenit.com', 'iyo jef', '2017-05-23 14:32:50', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (1, 'bagusmertha@manajemenit.com', 'admin@pt-cas.com', 'tes', '2017-05-22 17:42:20', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (3, 'bagusmertha@manajemenit.com', 'admin@pt-cas.com', 'tes', '2017-05-22 17:42:56', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (6, 'bagusmertha@manajemenit.com', 'admin@pt-cas.com', 'tes', '2017-05-23 09:36:02', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (8, 'iwan.setiawan@cas.com', 'admin@pt-cas.com', 'iya', '2017-05-23 09:37:48', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (11, 'bagusmertha@manajemenit.com', 'admin@pt-cas.com', 'tes', '2017-05-23 14:32:40', 1);

INSERT INTO chat (id, "from", "to", message, sent, recd)
VALUES (13, 'iwan.setiawan@cas.com', 'admin@pt-cas.com', 'tes jef', '2017-05-25 08:04:29', 1);

--
-- Data for table public.comment (OID = 18258) (LIMIT 0,5)
--
INSERT INTO comment (id, post_id, parent_id, user_id, comment_description, comment_date)
VALUES (1, 3, 0, 'admin@biis.com', 'Cras sit amet nibh libero, in gravida nulla. Nulla vel metus scelerisque ante sollicitudin commodo. Cras purus odio, vestibulum in vulputate at, tempus viverra turpis. Fusce condimentum nunc ac nisi vulputate fringilla. Donec lacinia congue felis in faucibus.', '2017-04-17 06:24:00');

INSERT INTO comment (id, post_id, parent_id, user_id, comment_description, comment_date)
VALUES (2, 3, 0, 'admin@biis.com', 'We happy? Vincent, we happy?', '2017-04-17 06:32:00');

INSERT INTO comment (id, post_id, parent_id, user_id, comment_description, comment_date)
VALUES (3, 3, 0, 'admin@biis.com', 'Coba Comments', '2017-04-17 06:45:00');

INSERT INTO comment (id, post_id, parent_id, user_id, comment_description, comment_date)
VALUES (4, 3, 0, 'cas@cas.com', 'Coba Comments', '2017-04-17 06:45:00');

INSERT INTO comment (id, post_id, parent_id, user_id, comment_description, comment_date)
VALUES (5, 3, 0, 'iwan.setiawan@cas.com', 'Hey', '2017-04-18 04:54:00');

--
-- Data for table public.employee (OID = 18264) (LIMIT 0,10)
--
INSERT INTO employee (id, company_id, position_id, employee_email, employee_nid, employee_name, employee_birthday, employee_address, employee_gender, employee_phone, employee_approve, employee_password, employee_status, confirmation_code)
VALUES (1, 1, 1, 'info@ejavec.org', NULL, 'Admin Ejavec', '1992-01-13', 'Kediri', 1, NULL, 1, '23456', 1, NULL);

INSERT INTO employee (id, company_id, position_id, employee_email, employee_nid, employee_name, employee_birthday, employee_address, employee_gender, employee_phone, employee_approve, employee_password, employee_status, confirmation_code)
VALUES (2, 3, 1, 'admin@isef.org', '-', 'admin@isef.org', '2017-09-01', '<p>-</p>', 1, '-', 1, NULL, 1, NULL);

INSERT INTO employee (id, company_id, position_id, employee_email, employee_nid, employee_name, employee_birthday, employee_address, employee_gender, employee_phone, employee_approve, employee_password, employee_status, confirmation_code)
VALUES (3, 4, 1, 'coba@sbf.org', '-', 'coba@sbf.org', '2017-09-14', '<p><br></p>', 1, '-', 1, NULL, 1, NULL);

INSERT INTO employee (id, company_id, position_id, employee_email, employee_nid, employee_name, employee_birthday, employee_address, employee_gender, employee_phone, employee_approve, employee_password, employee_status, confirmation_code)
VALUES (4, 4, 1, 'hesoyam@hesoyam.com', '-', 'hesoyam@hesoyam.com', '2017-09-11', '<p><br></p>', 1, '-', 1, NULL, 1, NULL);

INSERT INTO employee (id, company_id, position_id, employee_email, employee_nid, employee_name, employee_birthday, employee_address, employee_gender, employee_phone, employee_approve, employee_password, employee_status, confirmation_code)
VALUES (5, 4, 1, 'percobaan@sbaf.com', '-', 'percobaan@sbaf.com', '2017-09-19', 'nomaden', NULL, '11111', 1, NULL, 1, NULL);

INSERT INTO employee (id, company_id, position_id, employee_email, employee_nid, employee_name, employee_birthday, employee_address, employee_gender, employee_phone, employee_approve, employee_password, employee_status, confirmation_code)
VALUES (6, 4, 1, 'percobaan2@sbaf.com', '-', 'percobaan2@sbaf.com', '2017-09-19', 'nomaden', NULL, '11111', 1, NULL, 1, NULL);

INSERT INTO employee (id, company_id, position_id, employee_email, employee_nid, employee_name, employee_birthday, employee_address, employee_gender, employee_phone, employee_approve, employee_password, employee_status, confirmation_code)
VALUES (7, 4, 1, 'percobaan3@sbaf.com', '-', 'percobaan3@sbaf.com', '2017-09-19', 'nomaden', NULL, '213214', 1, NULL, 1, NULL);

INSERT INTO employee (id, company_id, position_id, employee_email, employee_nid, employee_name, employee_birthday, employee_address, employee_gender, employee_phone, employee_approve, employee_password, employee_status, confirmation_code)
VALUES (8, 4, 1, 'percobaan4@sbaf.com', '-', 'percobaan4@sbaf.com', '2017-09-19', 'nomaden', NULL, '213214', 1, NULL, 1, NULL);

INSERT INTO employee (id, company_id, position_id, employee_email, employee_nid, employee_name, employee_birthday, employee_address, employee_gender, employee_phone, employee_approve, employee_password, employee_status, confirmation_code)
VALUES (9, 4, 1, 'percobaan5@sbaf.com', '-', 'percobaan5@sbaf.com', '2017-09-19', 'nomaden', NULL, '213214', 1, NULL, 1, NULL);

INSERT INTO employee (id, company_id, position_id, employee_email, employee_nid, employee_name, employee_birthday, employee_address, employee_gender, employee_phone, employee_approve, employee_password, employee_status, confirmation_code)
VALUES (10, 4, 1, 'admin@hipmi.or.id', '-', 'admin@hipmi.or.id', '2017-09-11', '<p><br></p>', 1, '-', 1, NULL, 1, NULL);

--
-- Data for table public.company (OID = 18274) (LIMIT 0,4)
--
INSERT INTO company (id, company_name, prefix_email)
VALUES (1, 'EJAVEC', '@ejavec.org');

INSERT INTO company (id, company_name, prefix_email)
VALUES (2, 'ManajemenIT', '@manajemenit.com');

INSERT INTO company (id, company_name, prefix_email)
VALUES (3, 'ISEF', '@isef.org');

INSERT INTO company (id, company_name, prefix_email)
VALUES (4, 'Hipmi Surabaya', '@hipmisurabaya.or.id');

--
-- Data for table public.config (OID = 18280) (LIMIT 0,3)
--
INSERT INTO config (id, config_email, config_message)
VALUES (3, 'info@roadhesoyam.org', '								 								 								 								 								 <table cellspacing="0" cellpadding="0" border="0" align="center" width="600"> <tbody><tr>  <td style="padding: 40px 0 30px 0;font-family: Arial, sans-serif; font-size: 24px;color:black">hehehe</td></tr><tr><td style="padding: 40px 30px 40px 30px;" bgcolor="#ffffff"><table cellspacing="0" cellpadding="0" border="0" width="100%"><tbody><tr><td style="color: #153643; font-family: Arial, sans-serif; font-size: 24px;"><b>Selamat, #name<br></b></td>  </tr>  <tr style="color: #153643; font-family: Arial, sans-serif; font-size: 16px; line-height: 20px;">   <td style="padding: 20px 0 30px 0;"><p>Anda telah terdaftar sebagai peserta dalam ISEF 2017 dengan nomor registrasi <span style="color: rgb(0, 0, 255);">#registration</span>.</p><p><br></p>Ikuti info dan pengumuman penting lainnya tentang ISEF 2017 melalui website https://roadtoisef.org<br><p></p></td>  </tr> </tbody></table></td> </tr> <tr>  <td style="padding: 30px 30px 30px 30px;" bgcolor="#004d83">	 <table cellspacing="0" cellpadding="0" border="0" width="100%"> <tbody><tr>  <td style="color: #ffffff; font-family: Arial, sans-serif; font-size: 14px;" width="75%">Roadtoisef 2017<br></td>  <td align="right"><br></td> </tr></tbody></table>	</td> </tr></tbody></table>                                                                                                                                                                     ');

INSERT INTO config (id, config_email, config_message)
VALUES (2, 'info@roadrunner.org', '								 								 								 								 <table cellspacing="0" cellpadding="0" border="0" align="center" width="600"> <tbody><tr>  <td style="padding: 40px 0 30px 0;font-family: Arial, sans-serif; font-size: 24px;color:black"><img style="width: 448px;" src="http://roadtoisef.org/assets/img/header-email.png"></td></tr><tr><td style="padding: 40px 30px 40px 30px;" bgcolor="#ffffff">mbuh lah</td></tr></tbody></table><table cellspacing="0" cellpadding="0" border="0" align="center" width="600"><tbody><tr><td style="padding: 40px 30px 40px 30px;" bgcolor="#ffffff"><table cellspacing="0" cellpadding="0" border="0" width="100%"><tbody><tr><td style="color: #153643; font-family: Arial, sans-serif; font-size: 24px;"><b>Selamat, #name<br></b></td>  </tr>  <tr style="color: #153643; font-family: Arial, sans-serif; font-size: 16px; line-height: 20px;">   <td style="padding: 20px 0 30px 0;"><p>Anda telah terdaftar sebagai peserta dalam ISEF 2017 dengan nomor registrasi <span style="color: rgb(0, 0, 255);">#registration</span>.</p><p><br></p>Ikuti info dan pengumuman penting lainnya tentang ISEF 2017 melalui website https://roadtoisef.org<br><p></p></td>  </tr> </tbody></table></td> </tr> <tr>  <td style="padding: 30px 30px 30px 30px;" bgcolor="#004d83">	 <table cellspacing="0" cellpadding="0" border="0" width="100%"> <tbody><tr>  <td style="color: #ffffff; font-family: Arial, sans-serif; font-size: 14px;" width="75%">Roadtoisef 2017<br></td>  <td align="right"><br></td> </tr></tbody></table>	</td> </tr></tbody></table>                                                                                                                                    ');

INSERT INTO config (id, config_email, config_message)
VALUES (1, 'akiradesu48@gmail.com', '								 								 								 								 								 								 <table cellspacing="0" cellpadding="0" border="0" align="center" width="600"> <tbody><tr>  <td style="padding: 40px 0 30px 0;font-family: Arial, sans-serif; font-size: 24px;color:black"><img style="width: 448px;" src="http://roadtoisef.org/assets/img/header-email.png"></td></tr><tr><td style="padding: 40px 30px 40px 30px;" bgcolor="#ffffff">heheheegegegee</td></tr></tbody></table><table cellspacing="0" cellpadding="0" border="0" align="center" width="600"><tbody><tr><td style="padding: 40px 30px 40px 30px;" bgcolor="#ffffff"><table cellspacing="0" cellpadding="0" border="0" width="100%"><tbody><tr><td style="color: #153643; font-family: Arial, sans-serif; font-size: 24px;"><b>Selamat, #name<br></b></td>  </tr>  <tr style="color: #153643; font-family: Arial, sans-serif; font-size: 16px; line-height: 20px;">   <td style="padding: 20px 0 30px 0;"><p>Anda telah terdaftar sebagai peserta dalam ISEF 2017 dengan nomor registrasi <span style="color: rgb(0, 0, 255);"><br></span>#registration</p><p><span style="color: rgb(0, 0, 255);">ini </span><a href="http://#link" target="_blank">link</a><span style="color: rgb(0, 0, 255);"><br></span><span style="color: rgb(0, 0, 255);"><br></span>.</p><p><br></p>Ikuti info dan pengumuman penting lainnya tentang ISEF 2017 melalui website https://roadtoisef.org<br><p></p></td>  </tr> </tbody></table></td> </tr> <tr>  <td style="padding: 30px 30px 30px 30px;" bgcolor="#004d83">	 <table cellspacing="0" cellpadding="0" border="0" width="100%"> <tbody><tr>  <td style="color: #ffffff; font-family: Arial, sans-serif; font-size: 14px;" width="75%">Roadtoisef 2017<br></td>  <td align="right"><br></td> </tr></tbody></table>	</td> </tr></tbody></table>                                                                                                                                                                                                      ');

--
-- Data for table public.employee_group (OID = 18286) (LIMIT 0,2)
--
INSERT INTO employee_group (id, employee_group_name, user_id, creation_date)
VALUES (1, 'Kelompok Satu', 'admin@pt-cas.com', '2017-05-10');

INSERT INTO employee_group (id, employee_group_name, user_id, creation_date)
VALUES (2, 'Grup HR', 'admin@pt-cas.com', '2017-05-15');

--
-- Data for table public.employee_group_detail (OID = 18292) (LIMIT 0,5)
--
INSERT INTO employee_group_detail (id, employee_group_id, employee_id)
VALUES (1, 1, 1);

INSERT INTO employee_group_detail (id, employee_group_id, employee_id)
VALUES (2, 1, 3);

INSERT INTO employee_group_detail (id, employee_group_id, employee_id)
VALUES (3, 1, 5);

INSERT INTO employee_group_detail (id, employee_group_id, employee_id)
VALUES (4, 2, 3);

INSERT INTO employee_group_detail (id, employee_group_id, employee_id)
VALUES (5, 2, 5);

--
-- Data for table public.faq (OID = 18299) (LIMIT 0,13)
--
INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (3, 1, '                                            <h5><span style="font-weight: bold;">Cras ac odio faucibus tortor pretium</span></h5>                                            <p>Cras ac odio faucibus tortor pretium tristique in id nisl. Donec libero nisl, hendrerit vel tempus at, posuere vel urna. Nam sed consectetur lectus. Sed sit amet risus dolor. Duis accumsan lorem ac quam egestas pretium.</p>                                            <p>Curabitur finibus nisl ac aliquet mattis. Aliquam convallis bibendum lorem sed lobortis. Cras aliquam urna sed luctus tincidunt.</p>                                            <h5><span style="font-weight: bold;">Nulla ullamcorper</span></h5>                                            <p>In diam turpis, tristique nec cursus in, blandit vel elit. Nulla ullamcorper, ex in ultrices fringilla, nisi sapien hendrerit dolor, in suscipit mauris turpis id erat.</p>                                            <p>Nunc facilisis odio vitae eros rutrum, eget rutrum nulla rhoncus. Etiam laoreet pretium ex ut gravida. In venenatis turpis sit amet volutpat bibendum.</p>', 'Donec libero nisl, hendrerit vel tempus at?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (4, 1, '                                            <h5><span style="font-weight: bold;">Aliquam at ipsum sapien</span></h5>                                            <p>Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Donec adipiscing vehicula tortor dapibus adipiscing.</p>                                            <p>Nullam quis quam massa. Donec vitae metus tortor. Vestibulum vel diam orci. Etiam sollicitudin venenatis justo ut posuere. Etiam facilisis est ut ligula ornare accumsan. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.</p>                                    ', 'Vestibulum vel diam orci?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (5, 1, '<div class="faq-text">
                                            <h5><span style="font-weight: bold;">Pellentesque sagittis pulvinar</span></h5>
                                            <p>Nunc pellentesque 
sagittis pulvinar. Donec et bibendum dolor. Praesent commodo facilisis 
dui, vitae euismod ipsum aliquam gravida. Nulla aliquet fringilla velit 
sit amet dignissim. Sed justo ex, mattis sed venenatis sit amet, varius 
at urna. Donec erat nunc, tempus id tortor vel, consequat pulvinar nisl.
 Donec sed felis in erat malesuada tincidunt pulvinar in lorem.</p>
                                            <p>Etiam rutrum, leo ut 
molestie hendrerit, quam elit semper nunc, eget ullamcorper sem ligula a
 nisl. Phasellus aliquam efficitur elit sed ullamcorper. Quisque 
porttitor ac turpis quis sodales.</p>
                                            <h5><span style="font-weight: bold;">Hendrerit luctus</span></h5>
                                            <p>Nulla dapibus turpis 
ornare est hendrerit luctus. Nam id turpis sapien. Quisque non fermentum
 nisl. In sagittis nibh non dolor condimentum sodales.</p>
                                        </div>', 'Nam id turpis sapien?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (2, 1, '                                         <h5><span style="font-weight: bold;">Pellentesque sagittis pulvinar</span></h5>                                            <p>Nunc pellentesque sagittis pulvinar. Donec et bibendum dolor. Praesent commodo facilisis dui, vitae euismod ipsum aliquam gravida. Nulla aliquet fringilla velit sit amet dignissim. Sed justo ex, mattis sed venenatis sit amet, varius at urna. Donec erat nunc, tempus id tortor vel, consequat pulvinar nisl. Donec sed felis in erat malesuada tincidunt pulvinar in lorem.</p>                                            <p>Etiam rutrum, leo ut molestie hendrerit, quam elit semper nunc, eget ullamcorper sem ligula a nisl. Phasellus aliquam efficitur elit sed ullamcorper. Quisque porttitor ac turpis quis sodales.</p>                                            <h5><span style="font-weight: bold;">Hendrerit luctus</span></h5>                                            <p>Nulla dapibus turpis ornare est hendrerit luctus. Nam id turpis sapien. Quisque non fermentum nisl. In sagittis nibh non dolor condimentum sodales.</p>                                      ', 'Nunc pellentesque sagittis pulvinar?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (6, 1, '                                            <h5><span style="font-weight: bold;">Cras ac odio faucibus tortor pretium</span></h5>                                            <p>Cras ac odio faucibus tortor pretium tristique in id nisl. Donec libero nisl, hendrerit vel tempus at, posuere vel urna. Nam sed consectetur lectus. Sed sit amet risus dolor. Duis accumsan lorem ac quam egestas pretium.</p>                                            <p>Curabitur finibus nisl ac aliquet mattis. Aliquam convallis bibendum lorem sed lobortis. Cras aliquam urna sed luctus tincidunt.</p>                                            <h5><span style="font-weight: bold;">Nulla ullamcorper</span></h5>                                            <p>In diam turpis, tristique nec cursus in, blandit vel elit. Nulla ullamcorper, ex in ultrices fringilla, nisi sapien hendrerit dolor, in suscipit mauris turpis id erat.</p>                                            <p>Nunc facilisis odio vitae eros rutrum, eget rutrum nulla rhoncus. Etiam laoreet pretium ex ut gravida. In venenatis turpis sit amet volutpat bibendum.</p>                                     ', 'Nulla ullamcorper, ex in ultrices fringilla?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (7, 2, '                                            <h5><span style="font-weight: bold;">Aliquam at ipsum sapien</span></h5>                                            <p>Maecenas risus sapien, sollicitudin quis nisl vehicula, sagittis venenatis elit. Cras at turpis vestibulum mauris gravida commodo. Fusce tellus metus, eleifend vel ultrices quis, fermentum ut justo. Ut hendrerit ante sed rutrum sagittis. Nam ac nulla posuere, mattis risus nec, sagittis purus. Praesent in justo rhoncus, molestie velit laoreet, viverra sem.</p>                                            <p>Sed sit amet lacus sem. Sed vel fermentum mi, sit amet hendrerit purus. Duis nec posuere dolor. Fusce sed faucibus turpis, a cursus nunc.</p>                                   ', 'Cras at turpis vestibulum mauris gravida commodo?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (1, 1, '                                            <h5><span style="font-weight: bold;">Aliquam at ipsum sapien</span></h5>                                            <p>Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Donec adipiscing vehicula tortor dapibus adipiscing.</p>                                            <p>Nullam quis quam massa. Donec vitae metus tortor. Vestibulum vel diam orci. Etiam sollicitudin venenatis justo ut posuere. Etiam facilisis est ut ligula ornare accumsan. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.</p>                                        ', 'How to aliquam at ipsum sapien?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (12, 2, '                                            <h5><span style="font-weight: bold;">Cras ac odio faucibus tortor pretium</span></h5>                                            <p>Cras ac odio faucibus tortor pretium tristique in id nisl. Donec libero nisl, hendrerit vel tempus at, posuere vel urna. Nam sed consectetur lectus. Sed sit amet risus dolor. Duis accumsan lorem ac quam egestas pretium.</p>                                            <p>Curabitur finibus nisl ac aliquet mattis. Aliquam convallis bibendum lorem sed lobortis. Cras aliquam urna sed luctus tincidunt.</p>                                            <h5><span style="font-weight: bold;">Nulla ullamcorper</span></h5>                                            <p>In diam turpis, tristique nec cursus in, blandit vel elit. Nulla ullamcorper, ex in ultrices fringilla, nisi sapien hendrerit dolor, in suscipit mauris turpis id erat.</p>                                            <p>Nunc facilisis odio vitae eros rutrum, eget rutrum nulla rhoncus. Etiam laoreet pretium ex ut gravida. In venenatis turpis sit amet volutpat bibendum.</p>                                     ', 'Nulla ullamcorper, ex in ultrices fringilla?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (10, 2, '                                            <h5><span style="font-weight: bold;">Aliquam at ipsum sapien</span></h5>                                            <p>Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Donec adipiscing vehicula tortor dapibus adipiscing.</p>                                            <p>Nullam quis quam massa. Donec vitae metus tortor. Vestibulum vel diam orci. Etiam sollicitudin venenatis justo ut posuere. Etiam facilisis est ut ligula ornare accumsan. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.</p>', 'Vestibulum vel diam orci?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (9, 2, '                                            <h5><span style="font-weight: bold;">Cras ac odio faucibus tortor pretium</span></h5>                                            <p>Cras ac odio faucibus tortor pretium tristique in id nisl. Donec libero nisl, hendrerit vel tempus at, posuere vel urna. Nam sed consectetur lectus. Sed sit amet risus dolor. Duis accumsan lorem ac quam egestas pretium.</p>                                            <p>Curabitur finibus nisl ac aliquet mattis. Aliquam convallis bibendum lorem sed lobortis. Cras aliquam urna sed luctus tincidunt.</p>                                            <h5><span style="font-weight: bold;">Nulla ullamcorper</span></h5>                                            <p>In diam turpis, tristique nec cursus in, blandit vel elit. Nulla ullamcorper, ex in ultrices fringilla, nisi sapien hendrerit dolor, in suscipit mauris turpis id erat.</p>                                            <p>Nunc facilisis odio vitae eros rutrum, eget rutrum nulla rhoncus. Etiam laoreet pretium ex ut gravida. In venenatis turpis sit amet volutpat bibendum.</p>', 'Donec libero nisl, hendrerit vel tempus at?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (11, 2, '                                            <h5><span style="font-weight: bold;">Pellentesque sagittis pulvinar</span></h5>                                            <p>Nunc pellentesque sagittis pulvinar. Donec et bibendum dolor. Praesent commodo facilisis dui, vitae euismod ipsum aliquam gravida. Nulla aliquet fringilla velit sit amet dignissim. Sed justo ex, mattis sed venenatis sit amet, varius at urna. Donec erat nunc, tempus id tortor vel, consequat pulvinar nisl. Donec sed felis in erat malesuada tincidunt pulvinar in lorem.</p>                                            <p>Etiam rutrum, leo ut molestie hendrerit, quam elit semper nunc, eget ullamcorper sem ligula a nisl. Phasellus aliquam efficitur elit sed ullamcorper. Quisque porttitor ac turpis quis sodales.</p>                                            <h5><span style="font-weight: bold;">Hendrerit luctus</span></h5>                                            <p>Nulla dapibus turpis ornare est hendrerit luctus. Nam id turpis sapien. Quisque non fermentum nisl. In sagittis nibh non dolor condimentum sodales.</p>', 'Nam id turpis sapien?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (8, 2, '                                            <h5><span style="font-weight: bold;">Pellentesque sagittis pulvinar</span></h5>                                            <p>Nunc pellentesque sagittis pulvinar. Donec et bibendum dolor. Praesent commodo facilisis dui, vitae euismod ipsum aliquam gravida. Nulla aliquet fringilla velit sit amet dignissim. Sed justo ex, mattis sed venenatis sit amet, varius at urna. Donec erat nunc, tempus id tortor vel, consequat pulvinar nisl. Donec sed felis in erat malesuada tincidunt pulvinar in lorem.</p>                                            <p>Etiam rutrum, leo ut molestie hendrerit, quam elit semper nunc, eget ullamcorper sem ligula a nisl. Phasellus aliquam efficitur elit sed ullamcorper. Quisque porttitor ac turpis quis sodales.</p>                                            <h5><span style="font-weight: bold;">Hendrerit luctus</span></h5>                                            <p>Nulla dapibus turpis ornare est hendrerit luctus. Nam id turpis sapien. Quisque non fermentum nisl. In sagittis nibh non dolor condimentum sodales.</p>', ' Nunc pellentesque sagittis pulvinar?');

INSERT INTO faq (id, category_faq_id, faq_answer, faq_question)
VALUES (13, 3, '<p>1. Cek di menu data pegawai apakah masih ada user yang menggunakan email tersebut?</p><p>2. Jika masih ada, hapus data user tersebut.</p><p>3. Coba lakukan resgitrasi ulang dengan email tersebut</p>', 'User telah dihapus namun email tetap tidak bisa digunakan untuk registrasi user baru?');

--
-- Data for table public."group" (OID = 18305) (LIMIT 0,4)
--
INSERT INTO "group" (id, group_code, group_name, group_description)
VALUES (1, '900', 'Super Administator', 'Group For Super Administrator');

INSERT INTO "group" (id, group_code, group_name, group_description)
VALUES (2, '100', 'Administrator', 'Administrator');

INSERT INTO "group" (id, group_code, group_name, group_description)
VALUES (3, '200', 'Employee', 'Employee');

INSERT INTO "group" (id, group_code, group_name, group_description)
VALUES (4, '300', 'User', 'User');

--
-- Data for table public.media (OID = 18311) (LIMIT 0,7)
--
INSERT INTO media (id, name, url, user_id)
VALUES (5, 'eloghseet pt pjb ptgu gresik 1.jpg', 'assets/img/media/indah@pt-cas.com/5.jpg', 'indah@pt-cas.com');

INSERT INTO media (id, name, url, user_id)
VALUES (1, 'Tes.jpg', 'assets/img/media/admin@biis.com/1.jpg', 'admin@pt-cas.com');

INSERT INTO media (id, name, url, user_id)
VALUES (2, 'Muz05.jpg', 'assets/img/media/admin@biis.com/2.jpg', 'admin@pt-cas.com');

INSERT INTO media (id, name, url, user_id)
VALUES (3, 'Nokia-N900-Smartphone-32-GB.png', 'assets/img/media/admin@biis.com/3.jpg', 'admin@pt-cas.com');

INSERT INTO media (id, name, url, user_id)
VALUES (4, 'Sony-Ericsson-C510a-Cyber-shot.png', 'assets/img/media/admin@biis.com/4.jpg', 'admin@pt-cas.com');

INSERT INTO media (id, name, url, user_id)
VALUES (6, 'home-head.jpg', 'assets/img/media/bagusmertha@manajemenit.com/6.jpg', 'bagusmertha@manajemenit.com');

INSERT INTO media (id, name, url, user_id)
VALUES (7, 'JAS-Airport-Services-handle-hajj-flight-in-HLP-and-SUB-696x446.jpg', 'assets/img/media/bagusmertha@manajemenit.com/7.jpg', 'bagusmertha@manajemenit.com');

--
-- Data for table public.menu (OID = 18317) (LIMIT 0,27)
--
INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (1, 0, 'Home', 'home', 'fa fa-home', 1, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (19, 18, 'Company', 'data/company', 'fa fa-building-o', 1, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (0, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (29, 25, 'Category', 'arsip/category', 'fa fa-list', 3, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (33, 18, 'Group', 'data/group', 'fa fa-users', 4, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (10, 4, 'Profil', 'system/profil', 'fa fa-user', 1, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (11, 4, 'Group', 'system/group', 'fa fa-users', 2, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (12, 4, 'User', 'system/user', 'fa fa-user', 3, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (14, 4, 'Submenu', 'system/submenu', 'fa fa-list', 5, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (13, 4, 'Menu', 'system/menu', 'fa fa-list', 4, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (15, 4, 'Privilege', 'system/privilege', 'fa fa-shield', 6, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (5, 2, 'Employee', 'employee/employee', 'fa fa-user', 5, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (4, 0, 'System', 'system', 'fa fa-cogs', 100, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (39, 38, 'Peserta', 'ejavec/participant', 'fa fa-user', 39, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (43, 38, 'Proses Peserta', 'ejavec/participant/proses', 'fa fa-hand-o-right', 40, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (40, 38, 'Sub Tema', 'ejavec/articleTheme', 'fa fa-list', 41, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (41, 38, 'Kategori Peserta', 'ejavec/participantCategory', 'fa fa-list', 42, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (42, 38, 'Detail Peserta', 'ejavec/participantDetail', 'fa fa-users', 43, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (2, 0, 'Employee', 'employee', 'fa fa-users', 2, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (18, 0, 'Data', 'data', 'fa fa-list', 5, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (53, 0, 'Pembayaran', 'sbf/pembayaran', 'fa fa-money', 53, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (54, 0, 'Notif', 'notif', 'fa fa-envelope', 54, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (34, 54, 'Validasi Email', 'system/general', 'fa fa-envelope', 7, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (51, 54, 'Notif Pembayaran User', 'system/emailLink', 'fa fa-envelope', 51, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (52, 54, 'Tagihan', 'system/emailTagihan', 'fa fa-envelope', 52, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (44, 0, 'Peserta', 'sbf/participant', 'fa fa-user', 3, 1);

INSERT INTO menu (id, parent_id, name, url, iconcls, sort, published)
VALUES (55, 0, 'Approval', 'post/post/approve', 'fa fa-check', 2, 1);

--
-- Data for table public.participant (OID = 18322) (LIMIT 0,214)
--
INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (10, '1721010010', 2, 1, 1, 'Standarisasi pengukuran kinerja  penyelenggara transportasi massal PT. KAI (Persero) dengan menggunakan metode Balance Scorecard dalam rangka tercapainya Tujuan Strategis Perusahaan Negara', 'assets/pendaftaran_artikel/10/Abstrak_AbstractPT KAIBalancescorecard.docx', NULL, 'assets/pendaftaran_artikel/10/CV_CV Mahsina2017.pdf', 2, '2017-07-05 10:59:43', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (11, '1722090011', 2, 2, 9, 'PERAN UMKM DALAM MEMPOSISIKAN PRODUK KHAS DAERAH SEBAGAI BAGIAN GLOBAL VALUE CHAINS PENINGKATAN DAYA SAING EKONOMI: KAJIAN UMKM DI KABUPATEN JOMBANG', 'assets/pendaftaran_artikel/11/Abstrak_Wiwik Maryati_Universitas Pesantren Tinggi Darul Ulum (Unipdu)_Non Mahasiswa (Umum)_Sub Tema 9.docx', NULL, 'assets/pendaftaran_artikel/11/CV_Curriculum Vitae_Wiwik Maryati_Unipdu_Ejavec 2017.docx', 2, '2017-07-09 10:55:00', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (13, '1722080013', 2, 2, 8, 'Kesenjangan Pembangunan Ekonomi Antar Kabupaten/Kota Di Provinsi Jawa Timur', 'assets/pendaftaran_artikel/13/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/13/CV_CV.docx', 2, '2017-07-10 06:01:14', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (5, '1721020005', 2, 1, 2, 'ANALISIS POTENSI DAERAH DAN PENYUSUNAN MODEL BISNIS DALAM MENDUKUNG PENGEMBANGAN INDUSTRI AGROWISATA BERBASIS BIOTEKNOLOGI  DI DESA BUNCITAN KABUPATEN SIDOARJO PROVINSI JAWA TIMUR ', 'assets/pendaftaran_artikel/5/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/5/CV_CV (agus sucipto).doc', 0, '2017-06-14 06:28:08', 'XSK2cVNsz5qd');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (6, '1721020006', 2, 1, 2, 'ANALISIS POTENSI DAERAH DAN PENYUSUNAN MODEL BISNIS DALAM MENDUKUNG PENGEMBANGAN INDUSTRI AGROWISATA BERBASIS BIOTEKNOLOGI  DI DESA BUNCITAN KABUPATEN SIDOARJO PROVINSI JAWA TIMUR ', 'assets/pendaftaran_artikel/6/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/6/CV_CV (agus sucipto).doc', 4, '2017-06-14 06:36:04', 'CiqKAwa2MR6z7Ga7qan~Fsi00fzreBVi28Ckkf1Fgj7Pjc8GYHLEldl6sqDDn3kgKXrKiQ0RZ5TsLu8acwDumA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (22, '1722100022', 2, 2, 10, 'Integrasi Zakat dan Wakaf sebagai Instrumen inti Usaha Mikro Kecil Menengah di Jawa Timur: Ekstensi Skema PUSYAR (Pembiayaan Usaha Syariah) Kota Mojokerto', 'assets/pendaftaran_artikel/22/Abstrak_abstract Integrasi Zakat dan Wakaf sebagai Instrumen inti Usaha Mikro Kecil Menengah di Jawa Timur.docx', NULL, 'assets/pendaftaran_artikel/22/CV_CV Raditya[23].docx', 4, '2017-07-16 09:56:37', 'GgiIbb~OQcv1I35WXtfHTmJXQDovEjHPJqEfGIKcGuVmqn3qVj~qc1K400A87S1Tr03HM3IvK5RY31YO7k9.GA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (14, '1722060014', 2, 2, 6, 'Penggunaan Teknologi Informasi, Kemudahan, dan Fitur Layanan Terhadap Minat Nasabah Dalam Menggunakan Internet Banking (Studi Pada Bank Syariah Mandiri)', 'assets/pendaftaran_artikel/14/Abstrak_Abstrak Ejavec.docx', NULL, 'assets/pendaftaran_artikel/14/CV_CV Endah Tri Wahyuningtyas, SE, MA.doc', 2, '2017-07-12 03:45:30', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (15, '1721040015', 2, 1, 4, 'ANALISIS FENOMENOLOGI : PEMBANGUNAN FASILITAS SEKTOR PARIWISATA MENAMBAH DAYA TARIK WISATAWAN ', 'assets/pendaftaran_artikel/15/Abstrak_pariwisata kabupaten malang.doc', NULL, 'assets/pendaftaran_artikel/15/CV_DRH DEWI.doc', 2, '2017-07-12 09:42:53', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (16, '1712080016', 1, 2, 8, 'MODEL PEMANFAATAN BONUS DEMOGRAFI MELALUI PENINGKTAN INDEKS PEMBANGUNAN MANUSIA (IPM) PADA DIMENSI PENDIDIKAN, KESEHATAN DAN PENGELUARAN DI PROVINSI JAWA TIMUR', 'assets/pendaftaran_artikel/16/Abstrak_Abstrak - Ahmad Fajri - Subtema 8.docx', NULL, 'assets/pendaftaran_artikel/16/CV_CV Ahmad Fajri.docx', 2, '2017-07-12 22:37:49', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (9, '1722040009', 2, 2, 4, 'PERAN MASYARAKAT DALAM PENGELOLAAN EKOMINAWISATA PULAU LUMPUR SIDOARJO', 'assets/pendaftaran_artikel/9/Abstrak_EJAVEC2017_Prasenja_Sugiyanti.docx', NULL, 'assets/pendaftaran_artikel/9/CV_CV Yanelis Prasenja.pdf', 2, '2017-07-05 05:32:58', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (2, '170202040002', 2, 2, 4, 'Pembangunan Yang Terintergrasi: Tantangan Dan Strategi Dalam Meningkatkan Potensi Kepariwisataan Sebagai Mesin Penggerak Perekonomian Di Jawa Timur', 'assets/pendaftaran_artikel/2/Abstrak_Pembangunan Yang Terintergrasi.docx', NULL, 'assets/pendaftaran_artikel/2/CV_Curriculum Vitae.docx', 2, '2017-06-06 13:33:34', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (17, '1712040017', 1, 2, 4, 'Skema 4G Sabagai Upaya Optimalisasi Perekonomian Jawa Timur Melalui Sektor Pariwisata', 'assets/pendaftaran_artikel/17/Abstrak_Skema 4G Sabagai Upaya Optimalisasi Perekonomian Jawa Timur Melalui Sektor Pariwisata.pdf', NULL, 'assets/pendaftaran_artikel/17/CV_biodata.pdf', 2, '2017-07-13 05:48:31', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (19, '1722060019', 2, 2, 6, 'Penggunaan Teknologi Informasi, Kemudahan, dan Fitur Layanan Terhadap Minat Nasabah Dalam Menggunakan Internet Banking (Studi Pada Bank Syariah Mandiri)', 'assets/pendaftaran_artikel/19/Abstrak_Abstrak Ejavec.docx', NULL, 'assets/pendaftaran_artikel/19/CV_CV Heni & Endah.doc', 2, '2017-07-14 05:22:48', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (18, '1722040018', 2, 2, 4, 'MEMBANGUN PARIWISATA HALAL  DALAM RANGKA MENGAKSELARASI PERTUMBUHAN EKONOMI JATIM: SUATU TINJAUAN KONSEP DI BROMO TENGGER', 'assets/pendaftaran_artikel/18/Abstrak_Abstraksi-1.docx', NULL, 'assets/pendaftaran_artikel/18/CV_MARTALENI CV- 17 Mei 2017.doc', 0, '2017-07-13 07:17:17', '8bu1fRuYgzLF');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (20, '1712080020', 1, 2, 8, 'Bonus Demografi Sebagai Sumber Kekuatan Ekonomi  Melalui Optimalisasi Jumlah dan Kegiatan UKM Kerajinan di Jawa Timur', 'assets/pendaftaran_artikel/20/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/20/CV_Curriculum Vitae.docx', 2, '2017-07-15 10:27:56', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (21, '1721040021', 2, 1, 4, 'Ada apa dengan Pariwisata, Information and Communication technologies (ICTs) dan Generasi Y? : Review Peluang Pendapatan Ekonomi Daerah di Jawa Timur', 'assets/pendaftaran_artikel/21/Abstrak_Economics Review.pdf', NULL, 'assets/pendaftaran_artikel/21/CV_CV.pdf', 2, '2017-07-16 09:40:43', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (23, '1711040023', 1, 1, 4, 'Strategi Pengembangan Pariwisata Jawa Timur  sebagai Wisata Ekonomi Kreatif', 'assets/pendaftaran_artikel/23/Abstrak_ABSTRAKSI EJAV 2017.docx', NULL, 'assets/pendaftaran_artikel/23/CV_CV EJAVEC 2017.docx', 2, '2017-07-17 06:35:35', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (8, '1721090008', 2, 1, 9, 'Industri Perhiasan di Jawa Timur Dalam Perspektif Global Value Chain', 'assets/pendaftaran_artikel/8/Abstrak_pranakusuma sudhana-abstrak-ejavec2017.pdf', NULL, 'assets/pendaftaran_artikel/8/CV_2017CV-id-akademik.pdf', 4, '2017-07-04 11:34:46', 'pjDBupUiFVwDNH8uyQFoPOLSUwXCLxzTj6v4u.auoyMd98zSu48x7unTSzQNvq7kd1TsGysEu6M3ZFuiYmkZIw--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (25, '1712030025', 1, 2, 3, 'PENERAPAN INTEGRATED REPORTING SEBAGAI UPAYA PERUSAHAAN DALAM MENDUKUNG SUSTAINABLE DEVELOPMENT GOALS', 'assets/pendaftaran_artikel/25/Abstrak_Abstrak.pdf', NULL, 'assets/pendaftaran_artikel/25/CV_DAFTAR RIWAYAT HIDUP.pdf', 0, '2017-07-17 11:15:08', 'lwpbPnizfbkC');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (3, '170202040003', 2, 2, 4, 'Pembangunan Yang Terintergrasi: Tantangan Dan Strategi Dalam Meningkatkan Potensi Kepariwisataan Sebagai Mesin Penggerak Perekonomian Di Jawa Timur', 'assets/pendaftaran_artikel/3/Abstrak_Pembangunan Yang Terintergrasi.docx', NULL, 'assets/pendaftaran_artikel/3/CV_Curriculum Vitae.docx', 2, '2017-06-06 13:38:38', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (7, '1711040007', 1, 1, 4, '(THE GOLDEN RELIC OF EAST JAVA)  MENGGAGAS PARIWISATA PENINGGALAN SEJARAH DI JAWA TIMUR SEBAGAI ALTERNATIF PENINGKAT PEREKONOMIAN DAERAH', 'assets/pendaftaran_artikel/7/Abstrak_ABSTRAK BI.docx', NULL, 'assets/pendaftaran_artikel/7/CV_CV.doc', 2, '2017-06-16 11:46:16', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (36, '1712020036', 1, 2, 2, 'Penguatan Agroindustri Padi sebagai  Akselerasi Pertumbuhan Ekonomi dan Penurunan Kemiskinan di Jawa Timur: Pendekatan Vector Autoregression (VAR)', 'assets/pendaftaran_artikel/36/Abstrak_Abstrak_Fendi Indra, Silvia Nindi_Idn_Eng.docx', NULL, 'assets/pendaftaran_artikel/36/CV_CV Peserta.docx', 4, '2017-07-18 18:02:38', 'KOl.b53fCXmGfd5vcUz.SzbBGmo7Jf6h01GTT8SsyfGjlWFLkkaIVgqa7p7sS2Aa~DFX~HxpWKlLUEnIw1k0Lg--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (27, '1712030027', 1, 2, 3, 'PENERAPAN INTEGRATED REPORTING SEBAGAI UPAYA PERUSAHAAN DALAM MENDUKUNG SUSTAINABLE DEVELOPMENT GOALS', 'assets/pendaftaran_artikel/27/Abstrak_Abstrak.pdf', NULL, 'assets/pendaftaran_artikel/27/CV_DAFTAR RIWAYAT HIDUP.pdf', 0, '2017-07-17 11:57:11', 'sGG7YxZjFcMH');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (29, '1712030029', 1, 2, 3, 'PENERAPAN INTEGRATED REPORTING SEBAGAI UPAYA PERUSAHAAN DALAM MENDUKUNG SUSTAINABLE DEVELOPMENT GOALS', 'assets/pendaftaran_artikel/29/Abstrak_Abstrak.pdf', NULL, 'assets/pendaftaran_artikel/29/CV_', 0, '2017-07-18 01:35:58', 'QkjTbEurefGS');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (30, '1712030030', 1, 2, 3, 'PENERAPAN INTEGRATED REPORTING SEBAGAI UPAYA PERUSAHAAN DALAM MENDUKUNG SUSTAINABLE DEVELOPMENT GOALS', 'assets/pendaftaran_artikel/30/Abstrak_Abstrak.pdf', NULL, 'assets/pendaftaran_artikel/30/CV_DAFTAR RIWAYAT HIDUP.pdf', 0, '2017-07-18 01:38:01', 'OOHPcvOZ9hKc');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (31, '1721050031', 2, 1, 5, 'POTENSI DAN STRATEGI JAWA TIMUR MENGANGKAT JAMU/OBAT TRADISIONAL DENGAN KEARIFAN LOKAL BERDAYA SAING ', 'assets/pendaftaran_artikel/31/Abstrak_POTENSI DAN STRATEGI JAWA TIMUR MENGANGKAT JAMU.pdf', NULL, 'assets/pendaftaran_artikel/31/CV_BIODATA Dr.Endang Purwaningsih, SH.MHum.MKn, Juli 2017.pdf', 0, '2017-07-18 04:57:02', 'U1oLXDeJDMjz');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (34, '1721080034', 2, 1, 8, 'MAMPUKAH ANGKATAN KERJA MENJADI SUMBER PERTUMBUHAN DAN KESEJAHTERAAN DI JAWA TIMUR? ', 'assets/pendaftaran_artikel/34/Abstrak_Abstraksi EJAVEC 2017 pdf - Ris Yuwono YN.pdf', NULL, 'assets/pendaftaran_artikel/34/CV_CV Ejavec2017 pdf.pdf', 4, '2017-07-18 12:33:54', 'O9v1lsc~3vETtoGkBzY44D7z~k4a9ED5ZwdwoHI38N3KVC6z.YNZwI.ZL6W5cGZfw9ef.N7IIcO8mmVx87Dq.A--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (42, '1721050042', 2, 1, 5, 'Indonesia?s productivity growth: Evidence of industrialization or deindustrialization in the Java Island?', 'assets/pendaftaran_artikel/42/Abstrak_Indonesian Productivity Growth.docx', NULL, 'assets/pendaftaran_artikel/42/CV_2017_CV Miguel Esquivias developed_.pdf', 4, '2017-07-19 17:09:47', 'yVlbFwxhbwgGiqiYDan0sYwKEdkQirTHMIXIda.vOOg6QlDbCTmCbxIzBCUWUGeaDZz9EJU53qIEV1ygOuvJFQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (38, '1721020038', 2, 1, 2, 'Menelusuri Model Pembangunan Ekonomi Keluarga Dalam Rangka Mewujudkan Kemandirian Desa', 'assets/pendaftaran_artikel/38/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/38/CV_CURRICULUM VITAE.docx', 2, '2017-07-19 10:06:28', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (35, '1722020035', 2, 2, 2, 'TEKNIK PEMANEN AIR HUJAN (RAIN WATER HARVESTING) SEBAGAI ALTERNATIF PENYEDIAAN AIR BERSIH DI WILAYAH DESA SEMBAYAT-GRESIK', 'assets/pendaftaran_artikel/35/Abstrak_TEKNIK PEMANENAN AIR HUJAN-EJAVEC2017.pdf', NULL, 'assets/pendaftaran_artikel/35/CV_CV file Rofiqoh-Niswah.pdf', 2, '2017-07-18 15:19:50', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (39, '1711020039', 1, 1, 2, 'Strategi Samudera Biru bagi Bangkalan', 'assets/pendaftaran_artikel/39/Abstrak_blue ocean abstrak.docx', NULL, 'assets/pendaftaran_artikel/39/CV_CV.docx', 2, '2017-07-19 12:51:48', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (40, '1711040040', 1, 1, 4, 'AGROWISATA BERBASIS USAHA TANI TERPADU, SEBAGAI GERBANG PERTUMBUHAN EKONOMI MASYARAKAT DESA DALAM MENYONGSONG BONUS DEMOGRAI 2020 - 2030', 'assets/pendaftaran_artikel/40/Abstrak_AGROWISATA BERBASIS USAHA TANI TERPADU.pdf', NULL, 'assets/pendaftaran_artikel/40/CV_CURICULUM VITAE PESERTA UNIVERSITAS DARUSSALAM GONTOR.pdf', 2, '2017-07-19 15:33:18', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (37, '1721020037', 2, 1, 2, 'Analisa Peran BMT dalam Pembangunan Pertanian', 'assets/pendaftaran_artikel/37/Abstrak_Analisa Peran Baitul Maal wa Tamwil.pdf', NULL, 'assets/pendaftaran_artikel/37/CV_CURRICULUM VITAE SRI CAHYANING UMI SALAMA.pdf', 4, '2017-07-18 18:21:34', 'SEZlXMaN5aU2djTtIb3pd.nZ7FvjPJnpJCI.mSQ6SyJjIeFMNdCZjAR5dY0ZbriOzKILg5Tz4Uz4Waxrw1uV5w--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (26, '1721060026', 2, 1, 6, 'Tingkat Efisiensi Usaha Mikro Kecil (UMK) dalam Penggunaan Kredit Program Pemerintah untuk Mengurangi Kemsikinan di Jawa Timur', 'assets/pendaftaran_artikel/26/Abstrak_abstrak ejavec.docx', NULL, 'assets/pendaftaran_artikel/26/CV_CV_Atik Purmiyati.doc', 4, '2017-07-17 11:15:11', 'ly.feKbt38Cv8yyZPSV4TD4jSv5lGIPYIHmhEikUPlYpa0fBMhEmVLRbKFIXhZvAVQglyLtWv871c.B.2RgtXQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (43, '1721040043', 2, 1, 4, 'MENGGAGAS PARIWISATA MADURA BERBASIS KEARIFAN LOKAL   (Pentingnya Membangun Kepariwisataan Daerah Berbasis Nilai Sosial Kultural Lokal Ditinjau Dari Perspektif Sosiologi)', 'assets/pendaftaran_artikel/43/Abstrak_INITIATING OF MADURA TOURISM BASED ON THE LOCAL WISDOM.docx', NULL, 'assets/pendaftaran_artikel/43/CV_CV ABD HANNAN. Indonesia.docx', 0, '2017-07-19 17:11:59', '7CCMfTSftDXv');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (28, '1712080028', 1, 2, 8, 'The Effect of Regional Real Revenue, General Allocation Fund and Revenue Sharing Fund with Moderation of Economic Growth In Capital Expenditure At The Distric/City in The Province of East Java.', 'assets/pendaftaran_artikel/28/Abstrak_Abstrak Kinerja Jawa Timur.pdf', NULL, 'assets/pendaftaran_artikel/28/CV_Curiculum Vitae Seminar Ejavec.pdf', 4, '2017-07-17 14:32:38', 'SSQsEq~1hnk.UmVvJPIwQOXYHX.LWClyyuI7AknjmG.kQbYV5RQegJg3G.jwYG0a5bcyhYvhpz3DlBFnghKUUA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (44, '1721040044', 2, 1, 4, 'MENGGAGAS PARIWISATA MADURA BERBASIS KEARIFAN LOKAL   (Pentingnya Membangun Kepariwisataan Daerah Berbasis Nilai Sosial Kultural Lokal Ditinjau Dari Perspektif Sosiologi)', 'assets/pendaftaran_artikel/44/Abstrak_INITIATING OF MADURA TOURISM BASED ON THE LOCAL WISDOM.docx', NULL, 'assets/pendaftaran_artikel/44/CV_CV ABD HANNAN. Indonesia.docx', 0, '2017-07-19 17:33:48', '2zoFaguQeUYx');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (45, '1721040045', 2, 1, 4, 'AKSELERASI WISATA SYARIAH TINGKATKAN PERKEONOMIAN JAWA TIMUR', 'assets/pendaftaran_artikel/45/Abstrak_Abstrak akselerasi wisata syariah tingkatkan perekonomian jawa timur olh suharyono soemarwoto Ejavec2017 bilingual.doc', NULL, 'assets/pendaftaran_artikel/45/CV_suharyono soemarwoto1.doc', 0, '2017-07-19 17:54:22', 'Gj5FzQ4d0t6L');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (46, '1721040046', 2, 1, 4, 'AKSELERASI WISATA SYARIAH TINGKATKAN PEREKONOMIAN JAWA TIMUR', 'assets/pendaftaran_artikel/46/Abstrak_Abstrak akselerasi wisata syariah tingkatkan perekonomian jawa timur olh suharyono soemarwoto Ejavec2017 bilingual.doc', NULL, 'assets/pendaftaran_artikel/46/CV_suharyono soemarwoto1.doc', 0, '2017-07-19 18:16:15', 'gFCk4xqA1RJa');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (47, '1721040047', 2, 1, 4, 'Sektor Pariwisata dan Pengurangan Ketimpangan Pendapatan Regional: Bukti Di Provinsi Jawa Timur', 'assets/pendaftaran_artikel/47/Abstrak_SEKTOR PARIWISATA DAN PENGURANGAN KETIMPANGAN PENDAPATAN.docx', NULL, 'assets/pendaftaran_artikel/47/CV_Curriculum vitae Gigih AIMS.docx', 0, '2017-07-19 22:37:30', 'MKXRaM12OYaC');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (32, '1722020032', 2, 2, 2, 'Mengembangkan Agroindustri Jawa Timur: Pendekatan Metode Analytic Network Process (ANP)', 'assets/pendaftaran_artikel/32/Abstrak_ABSTRAK for EJAVEC.docx', NULL, 'assets/pendaftaran_artikel/32/CV_CV AAM SLAMET 2016 Update.pdf', 4, '2017-07-18 07:40:07', 'hNArLjZLcz0k6wwNPBw~rbJREj6LGgGqF47tc14j2o2pgCi9~zu.8Llf9oV16Ko9GGkQ8xGjiYg~cPDxjsY0XA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (48, '1721040048', 2, 1, 4, 'Sektor Pariwisata dan Pengurangan Ketimpangan Pendapatan Regional: Bukti Di Provinsi Jawa Timur', 'assets/pendaftaran_artikel/48/Abstrak_SEKTOR PARIWISATA DAN PENGURANGAN KETIMPANGAN PENDAPATAN.docx', NULL, 'assets/pendaftaran_artikel/48/CV_Curriculum vitae Gigih AIMS.docx', 4, '2017-07-19 22:49:47', 'I8rP1TopninmM3o9uD2VpYUstW8B.R~3t.iM4sMGI4UiIbSVa7k49o1q2YSzRIhc7ZhH1UEw5YJq5us.6QttLg--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (49, '1721020049', 2, 1, 2, 'Upaya Peningkatan Daya Saing Global  Provinsi Jawa Timur Sebagai Pusat Agro industri Melalui Pemberdayaan Industri Kecil Menengah (IKM)  Yang Kreatif dan Inovatif Secara Berkelanjutan', 'assets/pendaftaran_artikel/49/Abstrak_Abstract EJAVEC 2017 (Dr.Sri Muljaningsih,SE,MSP).docx', NULL, 'assets/pendaftaran_artikel/49/CV_CV Sri Muljaningsih (2017).docx', 0, '2017-07-20 02:45:13', 'v717iyxBc4Sh');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (52, '1712010052', 1, 2, 1, 'APLIKASI TRADE FAIRS MELALUI TRADE MOVEMENT LAW UNTUK PROTEKSI PERDAGANGAN INTERNASIONAL JAWA TIMUR', 'assets/pendaftaran_artikel/52/Abstrak_APLIKASI TRADE FAIRS MELALUI TRADE MOVEMENT LAW UNTUK PROTEKSI PERDAGANGAN INTERNASIONAL JAWA TIMUR.pdf', NULL, 'assets/pendaftaran_artikel/52/CV_CURRICULUM VITAE.pdf', 0, '2017-07-20 05:41:54', 'lXwEMdiwId9M');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (54, '1722040054', 2, 2, 4, 'Development Strategies of Rural Tourism in East Java to enhance local economic', 'assets/pendaftaran_artikel/54/Abstrak_Development Strategies of Rural Tourism in East Java to enhance local economic.pdf', NULL, 'assets/pendaftaran_artikel/54/CV_CV---Nizar.jpg', 2, '2017-07-20 06:09:11', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (57, '1721020057', 2, 1, 2, 'PERANCANGAN INTERNATIONAL DURIO FORESTRY DALAM RANGKA PENINGKATAN PERTUMBUHAN EKONOMI  PROVINSI JAWA TIMUR (Studi Pada Desa Sawahan, Kecamatan Watulimo, Kabupaten Trenggalek)', 'assets/pendaftaran_artikel/57/Abstrak_Abstrak Ratnawaty.doc', NULL, 'assets/pendaftaran_artikel/57/CV_CV RATNAWATY.doc', 2, '2017-07-20 15:51:08', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (53, '1711100053', 1, 1, 10, 'INOVASI PENGOLAHAN PETAI MENJADI MILKSHAKE PETAI DALAM UPAYA PENGUATAN PRODUKSI LOKAL DI JAWA TIMUR UNTUK MENINGKATKAN BISNIS UMKM BERBASIS EKONOMI SYARIAH ', 'assets/pendaftaran_artikel/53/Abstrak_EJAVEC_INOVASI PENGOLAHAN PETAI MENJADI MILKSHAKE PETAI DALAM UPAYA PENGUATAN PRODUKSI LOKAL DI JAWA TIMUR UNTUK MENINGKATKAN BISNIS UMKM BERBASIS EKONOMI SYARIAH.pdf', NULL, 'assets/pendaftaran_artikel/53/CV_CV_TOMMY TANU WIJAYA.pdf', 2, '2017-07-20 05:46:11', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (56, '1721020056', 2, 1, 2, 'PERANCANGAN INTERNATIONAL DURIO FORESTRY DALAM RANGKA PENINGKATAN PERTUMBUHAN EKONOMI  PROVINSI JAWA TIMUR (Studi Pada Desa Sawahan, Kecamatan Watulimo, Kabupaten Trenggalek)', 'assets/pendaftaran_artikel/56/Abstrak_Abstrak Ratnawaty.doc', NULL, 'assets/pendaftaran_artikel/56/CV_CV RATNAWATY.doc', 0, '2017-07-20 15:44:50', 'OvyQAZo5c8PI');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (63, '1722100063', 2, 2, 10, 'DAMPAK INFLASI, DANA PIHAK KETIGA DAN CAPITAL ADEQUACY RATIO (CAR)TERHADAP PENYALURAN KREDIT UMKM DI JAWA TIMUR', 'assets/pendaftaran_artikel/63/Abstrak_ABSTRAK-EJAVEC 2017.docx', NULL, 'assets/pendaftaran_artikel/63/CV_DAFTAR RIWAYAT HIDUP-irwantoro.docx', 2, '2017-07-20 20:39:30', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (61, '1722040061', 2, 2, 4, 'Identifikasi Klaster Ekowisata sebagai Upaya Peningkatan Daya Saing Global Taman Nasional Baluran', 'assets/pendaftaran_artikel/61/Abstrak_Abstraksi ID & EN - Identifikasi Klaster Ekowisata sebagai Upaya Peningkatan Daya Saing Global Taman Nasional Baluran.pdf', NULL, 'assets/pendaftaran_artikel/61/CV_CV - RISMA RESTYANA PUTRI & AHMAD ROSYIDI SYAHID.pdf', 4, '2017-07-20 18:36:00', 'AjQuBnDFLH~rnDxxNYKwpYRWntoLk4w4oXP5gRqdYzPS4JQoCVFKnjh6WxEUwwSHlGcpzaE1MZ~JyYpYkw2GUw--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (60, '1721100060', 2, 1, 10, 'Improvisasi Bank Syariah Dalam Rangka Meningkatkan Motivasi Pengusaha Muda', 'assets/pendaftaran_artikel/60/Abstrak_Improvisasi Bank Syariah an Suharto.pdf', NULL, 'assets/pendaftaran_artikel/60/CV_Identitas Diri Suharto.pdf', 0, '2017-07-20 18:23:16', 'JfuVWtCUMyrE');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (55, '1722020055', 2, 2, 2, 'POTENSI PENGEMBANGAN AGROINDUSTRI OLAHAN BUAH NAGA DI DESA BANGOREJO KABUPATEN BANYUWANGI ', 'assets/pendaftaran_artikel/55/Abstrak_ABSTRAK-Dani Setiawan.doc', NULL, 'assets/pendaftaran_artikel/55/CV_CURICULUM VITAE_.doc', 4, '2017-07-20 08:51:14', '4bn2ht1hRW7dd1YmfcTsqtGyUtUSwOA8BEeeJYz0WZMW7urzTuLwVu2.nLDYKI1MddC84SohVpyE5Wd0A.NiBA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (62, '1711070062', 1, 1, 7, 'I-Com (Iwak Comunity): Konsep Sosio Ekonomi Pembangunan Dengan Optimasi Potensi Perikanan berbasis komunitas', 'assets/pendaftaran_artikel/62/Abstrak_Rifan habibi_Universitas Brawijaya_ I-Com.pdf', NULL, 'assets/pendaftaran_artikel/62/CV_CV Rif''an Habibi.pdf', 0, '2017-07-20 20:02:24', 'JNrT5uQ3b2Ca');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (65, '1721060065', 2, 1, 6, 'Peran dan Potensi Ancaman Pembayaran Elektronik Dalam Mewujudkan Masyarakat Tanpa Uang Tunai: Sebuah Kerangka Konseptual', 'assets/pendaftaran_artikel/65/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/65/CV_CV shofwan001.doc', 2, '2017-07-21 00:35:30', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (64, '1721100064', 2, 1, 10, 'Model Griya Pengasuhan dan Pengembangan Anak (GPPA) sebagai Wadah Pembentukan Generasi Penerus Bangsa', 'assets/pendaftaran_artikel/64/Abstrak_Model Griya Pengasuhan dan Pengembangan Anak.docx', NULL, 'assets/pendaftaran_artikel/64/CV_2017 CV.docx', 0, '2017-07-20 22:32:51', '4ScGUJ6VmaOC');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (66, '1711040066', 1, 1, 4, 'Strategi Provinsi Jawa Timur menjadikan Sektor Pariwisata Sebagai Pengerak Ekonomi', 'assets/pendaftaran_artikel/66/Abstrak_Abstrak Oleh Giyanto - DIM 15 FEB Unair.pdf', NULL, 'assets/pendaftaran_artikel/66/CV_CV Giyanto DIM 15 FEB Unair.pdf', 0, '2017-07-21 00:37:28', 'GPTBaFL5oNB8');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (67, '1721100067', 2, 1, 10, 'Sinergi Model Bisnis Kewirausahaan dan UMKM berbasis Ekonomi Syariah pada Lembaga Keuangan Mikro Syariah dalam rangka memperbaiki kondisi Perekonomian Ummat', 'assets/pendaftaran_artikel/67/Abstrak_EJAVEC_2017.docx', NULL, 'assets/pendaftaran_artikel/67/CV_CV_umum.docx', 0, '2017-07-21 02:16:30', 'kIreOLTeKOq3');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (68, '1712040068', 1, 2, 4, 'KONSEP WISATA HALAL BERBASIS PEMBANGUNAN EKONOMI LOKAL DI PULAU MADURA', 'assets/pendaftaran_artikel/68/Abstrak_KONSEP WISATA HALAL BERBASIS PEMBANGUNAN EKONOMI LOKAL DI PULAU MADURA.pdf', NULL, 'assets/pendaftaran_artikel/68/CV_Curriculum Vitae.pdf', 0, '2017-07-21 02:27:39', 'hZ2hZMPTUsqz');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (69, '1712040069', 1, 2, 4, ' Potensi Wisata Air Terjun Daerah Malang sebagai Penggerak Pertumbuhan Ekonomi Jawa Timur', 'assets/pendaftaran_artikel/69/Abstrak_Potensi Wisata Air Terjun Daerah Malang sebagai Penggerak Pertumbuhan Ekonomi Jawa Timur.pdf', NULL, 'assets/pendaftaran_artikel/69/CV_CV.pdf', 0, '2017-07-21 02:34:57', '61KQYC6BFy9W');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (51, '1721020051', 2, 1, 2, 'Potensi dan Strategi Pengembangan Agroindustri Gula Kelapa di Kab. Lumajanga Jawa Timur', 'assets/pendaftaran_artikel/51/Abstrak_ABSTRAK ERNANI H (UNIGA MALANG).docx', 'assets/pendaftaran_artikel/51/Full_FULL PAPER EJAVEC (Prof. Dr. Ernani H, SE.,MS.doc', 'assets/pendaftaran_artikel/51/CV_BIODATA ERNANI HADIYATI.docx', 5, '2017-07-20 03:23:18', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (74, '1721100074', 2, 1, 10, 'UMKM Productive Card: Model Penguatan Peran UMKM di Jawa Timur oleh Perusahaan Modal Ventura Syariah Melalui Derivasi Pembiayaan Berkelanjutan dan Business Partnership ', 'assets/pendaftaran_artikel/74/Abstrak_eJAVEC_Abstrak_Rifaldi Majid.pdf', NULL, 'assets/pendaftaran_artikel/74/CV_Curriculum Vitae Rifaldi Majid.pdf', 2, '2017-07-21 04:02:02', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (82, '1721010082', 2, 1, 1, 'EFEK TENDENSI PROTEKSIONISME GLOBAL TERHADAP PERTUMBUHAN EKONOMI JAWA TIMUR', 'assets/pendaftaran_artikel/82/Abstrak_ABSTRAK.pdf', NULL, 'assets/pendaftaran_artikel/82/CV_CV.docx', 4, '2017-07-21 06:34:33', 'ZMUS788Tj314KPCZJhVkuaizI3b7PnnydHf1ni6siqxepdoyCX.24SLNKmnVUDfxmxjDG8eVUoFLIkHDFpvtlg--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (73, '1721070073', 2, 1, 7, 'MODAL VENTURE SEBAGAI ALTERNATIF INOVASI SUMBER PEMBIAYAAN PEMBANGUNAN UNTUK PENINGKATAN DAYA SAING GLOBAL JAWA TIMUR', 'assets/pendaftaran_artikel/73/Abstrak_MODAL VENTURA.H.SETYORINI.docx', NULL, 'assets/pendaftaran_artikel/73/CV_CURRICULUM VITAE.docx', 0, '2017-07-21 03:55:36', 'eV4iw73ypgtp');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (70, '1712020070', 1, 2, 2, 'Mendorong Pertumbuhan Agroindustri Jawa Timur dengan Sinergitas Baznas dan Badan Litbang Pertanian sebagai Sumber Modal dan Pendampingan Terhadap Petani', 'assets/pendaftaran_artikel/70/Abstrak_Mendorong Pertumbuhan Agroindustri Jawa Timur dengan Sinergitas Baznas dan Badan Litbang Pertanian sebagai Sumber Modal dan Pendampingan Terhadap Petani.docx', NULL, 'assets/pendaftaran_artikel/70/CV_Curicullum Vitate (CV).docx', 2, '2017-07-21 03:08:08', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (75, '1721060075', 2, 1, 6, 'PEMETAAN POTENSI KEBUTUHAN TEKNOLOGI TEPAT GUNA PETERNAK SAPI DI WILAYAH KECAMATAN PUDAK KABUPATEN PONOROGO', 'assets/pendaftaran_artikel/75/Abstrak_Abstrak.pdf', NULL, 'assets/pendaftaran_artikel/75/CV_CV.pdf', 2, '2017-07-21 05:29:22', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (76, '1722040076', 2, 2, 4, 'Dampak Pengembangan Tempat Wisata Alam Gumuk Sapu Angin terhadap Pendapatan Masyarakat', 'assets/pendaftaran_artikel/76/Abstrak_Dampak Pengembangan Wisata Alam Gumuk Sapu Angin Terhadap Pendapatan Masyarakat.doc', NULL, 'assets/pendaftaran_artikel/76/CV_CV EDI MURDIYANTO & AGUS ATHORI.doc', 2, '2017-07-21 05:48:49', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (77, '1722060077', 2, 2, 6, 'STRATEGI FINANCIAL LITERACY  & FINANCIAL INCLUSION SEBAGAI TRIGGER PERTUMBUHAN EKONOMI MASYARAKAT INDUSTRI KAWASAN WISATA GIRI KABUPATEN GRESIK JAWA TIMUR', 'assets/pendaftaran_artikel/77/Abstrak_STRATEGI FINANCIAL LITERACY & FINANCIAL INCLUSION.pdf', NULL, 'assets/pendaftaran_artikel/77/CV_Biodata Tim Peserta.pdf', 2, '2017-07-21 05:59:31', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (80, '1722040080', 2, 2, 4, 'MINIMALISASI SAMPAH WISATAWAN ; PENERAPAN MINIMARKET SAMPAH DI TEMPAT WISATA SEBAGAI SARANA EDUKASI DAN PENINGKATAN PEREKONOMIAN MASYARAKAT LOKAL (Studi Kasus : Pantai Bangsring dan Pantai Boom Kabupaten Banyuwangi)', 'assets/pendaftaran_artikel/80/Abstrak_Abstrak Tri_Cahyono, Anas_Nur, Dwi_Ardy.docx', NULL, 'assets/pendaftaran_artikel/80/CV_CV Tri Cahyono.doc', 2, '2017-07-21 06:14:14', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (78, '1721100078', 2, 1, 10, 'Competitive Condition of Islamic And Conventional Rural Bank In East Java Province, Indonesia', 'assets/pendaftaran_artikel/78/Abstrak_Madha Adi_ Abstrak.pdf', NULL, 'assets/pendaftaran_artikel/78/CV_Madha Adi_CV.pdf', 4, '2017-07-21 06:10:15', 'nWjcpcY4qikpRl8LjSgHhCQZAonMQhQjQuvHM7KMoS5yt1g5eoJyTbtuLgWR92E.B5FiB0sGKnu..otROG0e.A--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (72, '1721050072', 2, 1, 5, 'Analisis Determinan Ekspor Komoditas Manufaktur Jawa Timur Sebagai Sumber Pertumbuhan Ekonomi', 'assets/pendaftaran_artikel/72/Abstrak_eJAVEC2017 KPw BI Jawa Timur.pdf', NULL, 'assets/pendaftaran_artikel/72/CV_CV Devis.pdf', 4, '2017-07-21 03:48:25', 'TNWeqa4q.enxeQudgd99jj.M8IdHRtyL0kD7Cl1BRdstxkcx5vlxolEzxhnvU9sfJ8OqmytFVse8QtmmISofDQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (83, '1721010083', 2, 1, 1, 'EFEK TENDENSI PROTEKSIONISME GLOBAL TERHADAP PERTUMBUHAN EKONOMI JAWA TIMUR', 'assets/pendaftaran_artikel/83/Abstrak_ABSTRAK.pdf', NULL, 'assets/pendaftaran_artikel/83/CV_CV.docx', 2, '2017-07-21 06:39:47', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (81, '1722040081', 2, 2, 4, 'IMPLEMENTASI SINERGI PENTAHELIX DALAM PENGEMBANGAN POTENSI PARIWISATA DI JAWA TIMUR DENGAN TUJUAN MENGGERAKKAN PEREKONOMIAN DOMESTIK  ', 'assets/pendaftaran_artikel/81/Abstrak_abstrak kirim.docx', NULL, 'assets/pendaftaran_artikel/81/CV_cv-Handy Aribowo.pdf', 2, '2017-07-21 06:15:06', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (84, '1722020084', 2, 2, 2, 'STUDI FENOMENA RESILIENSI SRATEGI RANTAI PASOK UMKM SEKTOR MAKANAN DAN MINUMAN DI PROVINSI JAWA TIMUR', 'assets/pendaftaran_artikel/84/Abstrak_Abstrak_LiliaPascaRiani_UNPGRIKediri.docx', NULL, 'assets/pendaftaran_artikel/84/CV_CV.docx', 2, '2017-07-21 07:11:13', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (85, '1721010085', 2, 1, 1, 'PERLINDUNGAN HUKUM ATAS HKI BAGI UMKM DI JAWA TIMUR UNTUK BERSAING DI ERA MASYARAKAT EKONOMI ASEAN', 'assets/pendaftaran_artikel/85/Abstrak_ABSTRAK.docx', NULL, 'assets/pendaftaran_artikel/85/CV_BIODATA FARIDA.docx', 2, '2017-07-21 07:28:42', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (87, '1711040087', 1, 1, 4, 'Membangun Layanan Informasi Pariwisata Secara Kreatif dan Modern di Jawa Timur', 'assets/pendaftaran_artikel/87/Abstrak_Membangun Layanan Informasi Pariwisata Secara Kreatif dan Modern di Jawa Timur.pdf', NULL, 'assets/pendaftaran_artikel/87/CV_cv kthrndnr.jpg', 2, '2017-07-21 08:22:45', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (88, '1721070088', 2, 1, 7, 'MODAL VENTURE SEBAGAI ALTERNATIF INOVASI SUMBER PEMBIAYAAN PEMBANGUNAN UNTUK PENINGKATAN DAYA SAING GLOBAL JAWA TIMUR', 'assets/pendaftaran_artikel/88/Abstrak_MODAL VENTURA.H.SETYORINI.docx', NULL, 'assets/pendaftaran_artikel/88/CV_CURRICULUM VITAE.docx', 2, '2017-07-21 08:34:53', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (89, '1722070089', 2, 2, 7, 'BANK MASJID, Potensi Masjid Sebagai Sumber Pendanaan Alternatif Berbasis Startup Teknologi', 'assets/pendaftaran_artikel/89/Abstrak_abstrak in&en_BANK MASJID.pdf', NULL, 'assets/pendaftaran_artikel/89/CV_CV_firsty & febby.pdf', 0, '2017-07-21 08:36:51', 'wsan29UMbQdb');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (90, '1722070090', 2, 2, 7, 'BANK MASJID, Potensi Masjid Sebagai Sumber Pendanaan Alternatif Berbasis Startup Teknologi', 'assets/pendaftaran_artikel/90/Abstrak_abstrak in&en_BANK MASJID.pdf', NULL, 'assets/pendaftaran_artikel/90/CV_CV_firsty & febby.pdf', 2, '2017-07-21 08:48:53', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (86, '1722020086', 2, 2, 2, 'EKSISTENSI MODAL SOSIAL DAN PERAN PEMERINTAH DESA DALAM PENGEMBANGAN AGROINDUSTRI DI JAWA TIMUR (Studi Kasus di Desa Adat Ngadas, Kabupaten Malang)', 'assets/pendaftaran_artikel/86/Abstrak_Abstrak - Dwi Ardy & Alfi ML.docx', NULL, 'assets/pendaftaran_artikel/86/CV_BIODATA Ardy & Alfi.docx', 4, '2017-07-21 07:39:33', 'vk90WsYiSzUXLvEoVCYYCRpmM.NQJZxxniWh3bdbH5umSMJjIzeuvVLfevO30FYywQIBywnpIR3~6XWTmLWtqQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (91, '1722040091', 2, 2, 4, 'STRATEGI PENGEMBANGAN PARIWISATA JAWA TIMUR SEBAGAI SEKTOR UNGGULAN PERTUMBUHAN EKONOMI YANG BERKELANJUTAN.', 'assets/pendaftaran_artikel/91/Abstrak_paper ejavec 1.doc', NULL, 'assets/pendaftaran_artikel/91/CV_CV- Alif Endy P New 1.doc', 0, '2017-07-21 08:52:47', 'Yr3EJ8U7pMSu');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (71, '1712020071', 1, 2, 2, 'UPAYA STRATEGIS KONSEP LOCAL FISHING INDUSTRY SYSTEM (LFIS) BERBASIS TEKNOLOGI MELALUI PENDEKATAN EKONOMI REGIONAL  DALAM MEMAKSIMALKAN POTENSI PERIKANAN DARAT BUDIDAYA DI KABUPATEN LAMONGAN', 'assets/pendaftaran_artikel/71/Abstrak_ABSTRAK Arik Syifaul K.doc', NULL, 'assets/pendaftaran_artikel/71/CV_CV Arik Syifaul Khofifah.doc', 4, '2017-07-21 03:18:40', 'GRTl109vrwurVz2LIWvF0ckE5RZ~FDHsiEwOjV1TrHkxAxy7RJ8NKqwA~de6h36vBNd~muyBp7BGUK2dLBTGWw--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (94, '1722070094', 2, 2, 7, 'Pemberdayaan Ormas sebagai langkah Collaborative Governance dalam mendukung pembiayaan pembangunan', 'assets/pendaftaran_artikel/94/Abstrak_Pemberdayaan Ormas sebagai langkah Collaborative Governance dalam proses pembangunan.pdf', NULL, 'assets/pendaftaran_artikel/94/CV_CV Swastika Maya dan Kriswibowo.pdf', 2, '2017-07-21 09:42:18', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (97, '1712020097', 1, 2, 2, '?Optimalisasi Air Pohon Siwalan menjadi ASIAN (Air Sirup Siwalan) sebagai Sumber Ekonomi Baru Kabupaten Tuban?', 'assets/pendaftaran_artikel/97/Abstrak_ABSTRAK EJAVEC 2017.pdf', NULL, 'assets/pendaftaran_artikel/97/CV_CV TIM.pdf', 2, '2017-07-21 09:58:00', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (96, '1722080096', 2, 2, 8, 'Pentahelix''s Role on the Demographic Bonus Impact as a Fundamental Aspect of New Economic Strength and Increased Competitiveness', 'assets/pendaftaran_artikel/96/Abstrak_Bonus demografi. susyadi & h.setyorini.docx', NULL, 'assets/pendaftaran_artikel/96/CV_CURRICULUM VITAE.docx', 1, '2017-07-21 09:45:28', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (99, '1721050099', 2, 1, 5, 'DAMPAK INDUSTRI MANUFAKTUR MAKLOON TERHADAP PENINGKATAN EKSPOR NETO DI JAWA TIMUR (PERIODE 2015M1 ? 2017M4)', 'assets/pendaftaran_artikel/99/Abstrak_P5.docx', NULL, 'assets/pendaftaran_artikel/99/CV_curriculum vitae 2016 baru lagi.docx', 2, '2017-07-21 10:00:08', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (100, '1711100100', 1, 1, 10, 'PENGUATAN PEMBIAYAAN LEMBAGA KEUANGAN SYARIAH MELALUI KEBIJAKAN RESTRUKTURISASI NILAI KOLEKTIBILITAS', 'assets/pendaftaran_artikel/100/Abstrak_PENGUATAN PEMBIAYAAN LEMBAGA KEUANGAN SYARIAH MELALUI KEBIJAKAN RESTRUKTURISASI NILAI KOLEKTIBILITAS.docx', NULL, 'assets/pendaftaran_artikel/100/CV_CV.docx', 2, '2017-07-21 10:03:04', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (112, '1721060112', 2, 1, 6, 'Identifikasi Potensi Kecamatan dalam Rangka Implementasi Layangan Keuangan Digital di Jawa Timur', 'assets/pendaftaran_artikel/112/Abstrak_Abstrak ejavec_Ratna Indrayanti.docx', NULL, 'assets/pendaftaran_artikel/112/CV_CV_Ratna Indrayanti_2017.docx', 4, '2017-07-21 11:34:18', 'dFh15O9DkwMcDSYktBvQYcuK1q~JO3ghm3Qlxr9KvcYVN9tvqqCPDKAYETB9DSN34IILdECdIn0k3E5ecz5dtg--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (101, '1721100101', 2, 1, 10, 'Improvisasi Bank Syariah Dalam Rangka Meningkatkan Motivasi Pengusaha Muda', 'assets/pendaftaran_artikel/101/Abstrak_Improvisasi Bank Syariah an Suharto.pdf', NULL, 'assets/pendaftaran_artikel/101/CV_Identitas Diri Suharto.pdf', 0, '2017-07-21 10:15:02', 'HT8u0oECohMH');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (102, '1721050102', 2, 1, 5, 'ANALISIS FAKTOR DALAM MENINGKATKAN DAYA SAING UMKM BERBASIS INDUSTRI PENGOLAHAN DI JAWA TIMUR', 'assets/pendaftaran_artikel/102/Abstrak_abstrak.docx', NULL, 'assets/pendaftaran_artikel/102/CV_CV Aisyah.doc', 2, '2017-07-21 10:20:35', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (103, '1721070103', 2, 1, 7, 'DAMPAK FDI, ODA, INVESTASI TETAP TERHADAP PDRB DI JAWA TIMUR (PERIODE 2007Q1 ? 2016Q4)', 'assets/pendaftaran_artikel/103/Abstrak_P7.docx', NULL, 'assets/pendaftaran_artikel/103/CV_curriculum vitae 2016 baru lagi.docx', 2, '2017-07-21 10:30:02', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (105, '1721010105', 2, 1, 1, 'PENGARUH NILAI TUKAR RUPIAH TERHADAP PEREKONOMIAN INDONESIA (PERIODE 2006Q1 ? 2015Q2)', 'assets/pendaftaran_artikel/105/Abstrak_P1.docx', NULL, 'assets/pendaftaran_artikel/105/CV_curriculum vitae 2016 baru lagi.docx', 2, '2017-07-21 10:43:39', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (114, '1722070114', 2, 2, 7, 'Penerapan Alternatif Sumber Pembiayaan Pembangunan Mandiri Pemerintah Provinsi Jawa Timur dengan Public Private Partnership dan Pengembangan Instrumen Keuangan Daerah. ', 'assets/pendaftaran_artikel/114/Abstrak_ejavec 2017.pdf', NULL, 'assets/pendaftaran_artikel/114/CV_CV Gabungan.pdf', 4, '2017-07-21 12:03:07', 'WaZ9v~mxt3VHcb9vQMZzp.oDuhv2GYpPl2Uu6wtA.tHOfeCJMPgpNDSfnmP2Ws62IRnOIBMPmZyaQ7Ok47f7fA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (106, '1721100106', 2, 1, 10, 'MENINGKATKAN KEMANDIRIAN PETANI DENGAN KONSEP BAGI HASIL', 'assets/pendaftaran_artikel/106/Abstrak_MENINGKATKAN KEMANDIRIAN PETANI DENGAN KONSEP BAGI HASIL.docx', NULL, 'assets/pendaftaran_artikel/106/CV_CV Vina.docx', 2, '2017-07-21 11:01:40', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (109, '1721070109', 2, 1, 7, 'Kemandirian Fiskal dan Kontribusinya Terhadap Peningkatan Kesejahteraan: Studi Panel Kota/Kabupaten Jawa Timur', 'assets/pendaftaran_artikel/109/Abstrak_EJACEV 2017 (Mohtar).docx', NULL, 'assets/pendaftaran_artikel/109/CV_CV Mohtar 2017.docx', 2, '2017-07-21 11:28:38', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (107, '1722080107', 2, 2, 8, 'Perubahan Struktur Umur Penduduk dan Tabungan Domestik Dalam Era Transisi Demografi di Indonesia', 'assets/pendaftaran_artikel/107/Abstrak_abstract-ejavec-2017.docx', NULL, 'assets/pendaftaran_artikel/107/CV_cv-achmad sjafii-mei-2017.doc', 0, '2017-07-21 11:05:58', 'L5YhRMV6lGi7');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (108, '1721060108', 2, 1, 6, 'Peran dan Potensi Ancaman Pembayaran Elektronik Dalam Mewujudkan Masyarakat Tanpa Uang Tunai: Sebuah Kerangka Konseptual', 'assets/pendaftaran_artikel/108/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/108/CV_CV shofwan001.doc', 0, '2017-07-21 11:28:22', 'zzzxl2N8CaLe');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (110, '1721060110', 2, 1, 6, 'Identifikasi Potensi Kecamatan dalam Rangka Implementasi Layangan Keuangan Digital di Jawa Timur', 'assets/pendaftaran_artikel/110/Abstrak_Abstrak ejavec_Ratna Indrayanti.docx', NULL, 'assets/pendaftaran_artikel/110/CV_CV_Ratna Indrayanti_2017.docx', 0, '2017-07-21 11:29:41', 'M24wTnX3r5nU');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (134, '1722050134', 2, 2, 5, 'PENERAPANA BUDAYA GOTONG ROYONG PADA SISTEM PENGENDALIAN MANAJEMEN SENTRA INDUSTRI TAHU', 'assets/pendaftaran_artikel/134/Abstrak_Artikel-Ubay.doc', NULL, 'assets/pendaftaran_artikel/134/CV_CV.doc', 2, '2017-07-21 14:42:46', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (111, '1721100111', 2, 1, 10, 'Optimalisasi Wakaf Produktif sebagai Alternatif Pengembangan  Pasar Modal Syariah pada UMKM Jawa Timur', 'assets/pendaftaran_artikel/111/Abstrak_ejavec 2017.docx', NULL, 'assets/pendaftaran_artikel/111/CV_CV uswah.docx', 0, '2017-07-21 11:33:17', '7qhpGcuhNMUe');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (93, '1721100093', 2, 1, 10, 'Kontribusi Bank Syariah Terhadap Pembagunan Ekonomi di Jawa Timur ', 'assets/pendaftaran_artikel/93/Abstrak_KONTRIBUSI  PERBANKAN SYARIAH  TERHADAP PEMBANGUNAN EKONOMI DI JAWA TIMUR.docx', NULL, 'assets/pendaftaran_artikel/93/CV_CV DOSEN EKO FAJAR C UNTUK UNAIR PUSAT 2017.docx', 2, '2017-07-21 09:28:26', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (136, '1721020136', 2, 1, 2, 'Mewujudkan Jawa Timur sebagai Pusat Agroindustri, Mungkinkah?', 'assets/pendaftaran_artikel/136/Abstrak_00 ABSTAK EJAVEC 2017.doc', NULL, 'assets/pendaftaran_artikel/136/CV_01 BIODATA JUNAEDI.doc', 2, '2017-07-21 14:49:16', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (138, '1711070138', 1, 1, 7, 'Penerapan Pajak Karbon Di Jawa Timur Menggunakan New CGE Model', 'assets/pendaftaran_artikel/138/Abstrak_ejavec.docx', NULL, 'assets/pendaftaran_artikel/138/CV_Curriculum vitae.docx', 4, '2017-07-21 14:55:20', 'Gl5~AWe~iYJrua8zr4WFHIu5GtGKq6779mFep3LDCFHGV7Kc0oLiqDMbWR4xtPe9Qi0I2nLCW6lPtMWlHt2s6w--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (95, '1721090095', 2, 1, 9, 'ANALISIS POTENSI EKONOMI KABUPATEN DAN KOTA DI PROVINSI  JAWA TIMUR', 'assets/pendaftaran_artikel/95/Abstrak_ABSTRAK.docx', NULL, 'assets/pendaftaran_artikel/95/CV_CV.doc', 4, '2017-07-21 09:44:59', 'vi3t0l4kV9phVNRIGyR6tkJzJT3zSDJSQCwrUG4hkiN28~CejvXy.oUm0sGc01IG62y0eXt1UUTdcvTh26o0gg--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (115, '1722070115', 2, 2, 7, 'SUMBER-SUMBER PEMBIAYAAN PEMBANGUNAN YANG KENTAL KEINDONESIAAN SEBAGAI ALTERNATIF UNGGULAN DI TENGAH KETERBATASAN KAPASITAS FISKAL JAWA TIMUR', 'assets/pendaftaran_artikel/115/Abstrak_SUMBER-SUMBER PEMBIAYAAN PEMBANGUNAN YANG KENTAL KEINDONESIAAN SEBAGAI ALTERNATIF UNGGULAN DI TENGAH KETERBATASAN KAPASITAS FISKAL JAWA TIMUR.doc', NULL, 'assets/pendaftaran_artikel/115/CV_Biodata Ketua - 1.doc', 0, '2017-07-21 12:10:16', 'ocgH5SGI3RF6');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (133, '1722010133', 2, 2, 1, 'Studi Empiris Spillovers Effect Amerika Serikat Terhadap Pertumbuhan Ekonomi Jawa Timur', 'assets/pendaftaran_artikel/133/Abstrak_Manuscript_Panji_Fhawaid_Studi Empiris Spillovers Effect Amerika Serikat Terhadap Pertumbuhan Ekonomi Jawa Timur.docx', NULL, 'assets/pendaftaran_artikel/133/CV_Curriculum Vitae.docx', 4, '2017-07-21 14:41:39', 'Lukk4aUDeTzrNkO7FthpA7n8RijQnKG63qA2OKP9m4QQe.t6Q0iXvIHNUxthIAlXNHlk4GKigqyN3XQJsHvCKQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (118, '1722020118', 2, 2, 2, 'MEMBUMIKAN RENCANA JAWA TIMUR SEBAGAI PUSAT AGRO INDUSTRI', 'assets/pendaftaran_artikel/118/Abstrak_MEMBUMIKAN RENCANA JAWA TIMUR SEBAGAI PUSAT AGRO INDUSTRI.doc', NULL, 'assets/pendaftaran_artikel/118/CV_Biodata Ketua - 2.doc', 0, '2017-07-21 12:14:11', 'e2S3hb9Ept5f');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (119, '1721070119', 2, 1, 7, 'Public Spending Innovations to Accelerate Economic and Social Infrastructures Development  for the Global Competitiveness of East Java', 'assets/pendaftaran_artikel/119/Abstrak_[Anton A Fatah - EJAVEC2017] Public Spending Innovations to Accelerate Economic and Social Infrastructures Development East Java.pdf', NULL, 'assets/pendaftaran_artikel/119/CV_Anton Abdul Fatah _Resume[March2017].pdf', 2, '2017-07-21 12:18:24', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (120, '1722010120', 2, 2, 1, 'PENYUSUNAN ALAT SIMULASI MENGUKUR POTENSI DAMPAK PROTEKSIONISME GLOBAL TERHADAP PEREKONOMIAN JAWA TIMUR', 'assets/pendaftaran_artikel/120/Abstrak_PENYUSUNAN ALAT SIMULASI MENGUKUR POTENSI DAMPAK PERFEKSIONISME GLOBAL TERHADAP PEREKONOMIAN JAWA TIMUR.doc', NULL, 'assets/pendaftaran_artikel/120/CV_Biodata Ketua - 3.doc', 0, '2017-07-21 12:18:47', '7PWJ6o6ezPji');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (121, '1712040121', 1, 2, 4, 'Pariwisata Taman Hiburan Berbasis Kartun dan Animasi Indonesia di Surabaya sebagai Sumber Pertumbuhan Ekonomi Baru Jawa Timur dalam menghadapi Daya Saing Global', 'assets/pendaftaran_artikel/121/Abstrak_Abstrak LKTI Ejavec 2017.pdf', NULL, 'assets/pendaftaran_artikel/121/CV_CV Ejavec.pdf', 2, '2017-07-21 12:25:11', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (125, '1722040125', 2, 2, 4, 'Membangun Financial Inclusion Di Sektor Pariwisata Sebagai Roda Penggerak Pertumbuhan Ekonomi Jawa Timur', 'assets/pendaftaran_artikel/125/Abstrak_Abstrak Paper BI.pdf', NULL, 'assets/pendaftaran_artikel/125/CV_Curriculum Vitae - DEH New-2.pdf', 2, '2017-07-21 13:04:23', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (122, '1722070122', 2, 2, 7, 'EARLY MORNING SYSTEM MENJAGA KEEFISIENSIAN SUMBER-SUMBER PEMBIAYAAN PEMBANGUNAN', 'assets/pendaftaran_artikel/122/Abstrak_EARLY MORNING SYSTEM MENJAGA KEEFISIENSIAN SUMBER-SUMBER PEMBIAYAAN PEMBANGUNAN.doc', NULL, 'assets/pendaftaran_artikel/122/CV_Biodata Ketua - 4.doc', 0, '2017-07-21 12:28:54', 'uncTUQoE4k1l');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (124, '1722100124', 2, 2, 10, 'ZERO NON PERFORMANCE FINANCIAL, SUATU SISTEM MENJAGA SUMBER-SUMBER DAYA PEMBANGUNAN DARI KETIDAK EFISIENAN', 'assets/pendaftaran_artikel/124/Abstrak_ZERO NON PERFORMANCE FINANCIAL, SUATU SISTEM MENJAGA SUMBER-SUMBER DAYA PEMBANGUNAN DARI KETIDAK EFISIENAN.doc', NULL, 'assets/pendaftaran_artikel/124/CV_Biodata Ketua - 5.doc', 0, '2017-07-21 12:36:07', 'p0QSqiRT1Z9Q');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (126, '1712100126', 1, 2, 10, 'BMT?LINGSEBAGAI SOLUSI UNTUK PENGEMBANGAN SEKTOR PERTANIAN JATIM GUNA MENINGKATKAN DAYA SAING GLOBAL ', 'assets/pendaftaran_artikel/126/Abstrak_ABSTRAK INDONESIA -INGGRIS.docx', NULL, 'assets/pendaftaran_artikel/126/CV_CV.docx', 0, '2017-07-21 13:35:22', 'tJxLGyucYbNO');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (128, '1722040128', 2, 2, 4, 'PENGEMBANGAN WISATA KEPULAUAN KAB. SUMENEP UNTUK MENINGKATKAN PEREKONOMIAN MASYARAKAT KEPULAUAN', 'assets/pendaftaran_artikel/128/Abstrak_abstrak astri furqani dan fatah firdaus.docx', NULL, 'assets/pendaftaran_artikel/128/CV_CV Astri Furqani dan Fatah Firdaus.docx', 2, '2017-07-21 14:01:45', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (127, '1722020127', 2, 2, 2, 'Integrated Community Agroindustry System (ICAS): Desa sebagai Basis Bisnis Integratif menuju Ketahanan Pangan Negeri', 'assets/pendaftaran_artikel/127/Abstrak_INTEGRATED COMMUNITY AGROINDUSTRY SYSTEM.docx', NULL, 'assets/pendaftaran_artikel/127/CV_CV Ikhwan Safa''at dan Yayum Kumai.doc', 0, '2017-07-21 13:51:38', 'l5djkEqPeNjU');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (130, '1722040130', 2, 2, 4, 'Membangun Layanan Informasi Pariwisata Secara Kreatif dan Modern di Jawa Timur', 'assets/pendaftaran_artikel/130/Abstrak_Membangun Layanan Informasi Pariwisata Secara Kreatif dan Modern di Jawa Timur 2.pdf', NULL, 'assets/pendaftaran_artikel/130/CV_cvfinal.zip', 2, '2017-07-21 14:23:20', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (129, '1711070129', 1, 1, 7, 'Penerapan Pajak Karbon Di Jawa Timur Menggunakan New CGE Model', 'assets/pendaftaran_artikel/129/Abstrak_ejavec.docx', NULL, 'assets/pendaftaran_artikel/129/CV_Curriculum vitae.docx', 0, '2017-07-21 14:17:41', 'dw6pCDqVcOxI');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (131, '1721020131', 2, 1, 2, 'Mewujudkan Jawa Timur sebagai Pusat Agroindustri, Mungkinkah?', 'assets/pendaftaran_artikel/131/Abstrak_00 ABSTAK EJAVEC 2017.doc', NULL, 'assets/pendaftaran_artikel/131/CV_', 0, '2017-07-21 14:25:41', 'wJxFEE6UQb9T');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (132, '1722080132', 2, 2, 8, 'THE EFFECTIVENESS OF ?DEMOGRAPHIC BONUS? IN EAST JAVA', 'assets/pendaftaran_artikel/132/Abstrak_Ariz Aprilia_Panji Tirta Nirwana Putra_THE EFFECTIVENESS OF ?DEMOGRAPHIC BONUS? IN EAST JAVA.docx', NULL, 'assets/pendaftaran_artikel/132/CV_Curriculum Vitae _Ariz Aprilia_Panji Tirta Nirwana Putra.doc', 4, '2017-07-21 14:38:58', 'iRkaCQnhTmhKyYssaUK~crSO21hMTEGBGq4X9ub0RLeuxROy~3HmDMtOK8QnWGNP9kChEdgtpy0Q19WA6GNlPg--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (113, '1721070113', 2, 1, 7, 'Public Spending Innovations to Accelerate Economic and Social Infrastructures Development for the Global Competitiveness of East Java', 'assets/pendaftaran_artikel/113/Abstrak_[Anton A Fatah - EJAVEC2017] Public Spending Innovations to Accelerate Economic and Social Infrastructures Development East Java.pdf', NULL, 'assets/pendaftaran_artikel/113/CV_Anton Abdul Fatah _Resume[March2017].pdf', 2, '2017-07-21 12:02:29', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (135, '1711080135', 1, 1, 8, 'ANALISIS DEMPAK BONUS DEMOGRAFI TERHADAP  PERTUMBUHAN EKONOMI DAN KETIMPANGAN KESEJAHTERAAN SPASIAL DI JAWA TIMUR', 'assets/pendaftaran_artikel/135/Abstrak_Absrakt-8.docx', NULL, 'assets/pendaftaran_artikel/135/CV_CV.docx', 2, '2017-07-21 14:42:59', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (116, '1722070116', 2, 2, 7, 'Corporate Social Responsibility (CSR), Dapatkah Menjadi Solusi Keterbatasan Fiskal Jawa Timur?', 'assets/pendaftaran_artikel/116/Abstrak_abstraksi Nurareni + Arina.docx', NULL, 'assets/pendaftaran_artikel/116/CV_CV Nurareni + Arina.docx', 2, '2017-07-21 12:11:52', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (123, '1722040123', 2, 2, 4, 'PROGRAM TEROBOSAN INDUSTRI PARIWISATA JAWA TIMUR UNTUK MENJADI MESIN PENGGERAK EKONOMI', 'assets/pendaftaran_artikel/123/Abstrak_Program Terobosan Industry Pariwisata Jawa Timur Untuk Menjadi Mesin Penggerak Ekonomi.doc', NULL, 'assets/pendaftaran_artikel/123/CV_Biodata Ketua - 6.doc', 2, '2017-07-21 12:32:29', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (141, '1721040141', 2, 1, 4, 'SUMENEP TOURISM AS THE NEXT INCOME GENERATOR FOR EAST JAVA PROVINCE: OPPORTUNITIES AND CHALLENGES', 'assets/pendaftaran_artikel/141/Abstrak_EJAVEC 2017-CHWP.doc', NULL, 'assets/pendaftaran_artikel/141/CV_CV ENGLISH.doc', 2, '2017-07-21 15:01:45', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (143, '1722080143', 2, 2, 8, 'THE EFFECTIVENESS OF ?DEMOGRAPHIC BONUS? IN EAST JAVA', 'assets/pendaftaran_artikel/143/Abstrak_Ariz Aprilia_Panji Tirta Nirwana Putra_THE EFFECTIVENESS OF ?DEMOGRAPHIC BONUS? IN EAST JAVA.docx', NULL, 'assets/pendaftaran_artikel/143/CV_Curriculum Vitae _Ariz Aprilia_Panji Tirta Nirwana Putra.doc', 2, '2017-07-21 15:02:33', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (144, '1712100144', 1, 2, 10, 'Memprioritaskan Kinerja Integrasi Keuangan Mikro Syariah  Untuk Pengembangan Ekowisata Minapolitan di Jawa Timur', 'assets/pendaftaran_artikel/144/Abstrak_Memprioritaskan Kinerja Integrasi Keuangan Mikro Syariah.docx', NULL, 'assets/pendaftaran_artikel/144/CV_CURRICULUM VITAE.docx', 4, '2017-07-21 15:03:19', 'updnKNZ5Gw80zm5FR8n0TAi5uI8bbUrHr6hz1yDfdslmkMTG397qfjSys1IqZDkQ1qLd2TJlkujXjuZ8Xscjjg--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (142, '1722020142', 2, 2, 2, 'Learn from failure! Potential of mocaf flour industry as agroindustry in East Java', 'assets/pendaftaran_artikel/142/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/142/CV_CV 2.docx', 2, '2017-07-21 15:02:04', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (148, '1712080148', 1, 2, 8, 'Sebuah Analisis Sosiologi Pembangunan: Melihat Peluang dan Tantangan Bonus Demografi di Provinsi Jawa Timur', 'assets/pendaftaran_artikel/148/Abstrak_Bonus Demografi.docx', NULL, 'assets/pendaftaran_artikel/148/CV_CV_ok.doc', 2, '2017-07-21 15:27:32', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (147, '1712080147', 1, 2, 8, 'ANALISIS PERUBAHAN LABOR SUPPLY TERHADAP PERTUMBUHAN EKONOMI ERA BONUS DEMOGRAFI DI JAWA TIMUR', 'assets/pendaftaran_artikel/147/Abstrak_ABSTRAK.docx', NULL, 'assets/pendaftaran_artikel/147/CV_CV  gabungan.docx', 4, '2017-07-21 15:25:12', 'KNqxrlbxgIsreGhKsFcPRhXULeib4e5YgjCPD2c78bFqGKNRyKAFnMxI.nlS3NuDQhjTTVEXM4CGdEbzD3XPcA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (149, '1711040149', 1, 1, 4, 'East Java Halal Tourism Outlook : Analisis Potensi dan Strategi Pengembangan Pariwisata Halal Jawa Timur ', 'assets/pendaftaran_artikel/149/Abstrak_Abstrak - Muhammad Mufli - UB.docx', NULL, 'assets/pendaftaran_artikel/149/CV_CV-MUHAMMAD MUFLI.pdf', 4, '2017-07-21 15:34:57', 'cKWHrlRRzw280vZiso3g3upWjhP.g8j9g9Dzu2sac~n.3pt.sfiOzyYaqhTRwp5HSIpm3UXNO.0BEXMntTYatQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (150, '1721030150', 2, 1, 3, 'East Java Growth Dynamics: Need More Physical Capital or Quality of Labor? The Case of Manufacturing Sector', 'assets/pendaftaran_artikel/150/Abstrak_East Java Growth Dynamics.docx', NULL, 'assets/pendaftaran_artikel/150/CV_CV_1.pdf', 4, '2017-07-21 15:40:00', 'GicIdmHN4hnY3zBJKGhFt374i9cOE40v7pWfhj71ctysRdyIGsInkfjqun.ziaBrnCo.ckwsdeGtnzqjkLu7lQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (151, '1721070151', 2, 1, 7, 'Peta Sektor dan Impact  CSR Perbankan Sebagai Referensi  Perencanaan  Daya Saing Sumber Daya Manusia', 'assets/pendaftaran_artikel/151/Abstrak_EJAVEC2017-Abstrak-Lindiawati.doc', NULL, 'assets/pendaftaran_artikel/151/CV_20170721-CV Lindiawati-EJAVEC2017.doc', 2, '2017-07-21 15:41:58', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (152, '1722050152', 2, 2, 5, 'Reputasi Lingkungan Hidup Usaha Mikro Kecil Dan Menengah (UMKM): Sebuah Sumber Baru Pertumbuhan Ekonomi di Jawa Timur', 'assets/pendaftaran_artikel/152/Abstrak_reputasi lingkungan abstraksi.rtf', NULL, 'assets/pendaftaran_artikel/152/CV_CV bertiga.docx', 2, '2017-07-21 15:56:43', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (154, '1721040154', 2, 1, 4, 'MENGGAGAS PARIWISATA MADURA BERBASIS KEARIFAN LOKAL   (Pentingnya Membangun Kepariwisataan Daerah Berbasis Nilai Sosial Kultural Lokal Ditinjau Dari Perspektif Sosiologi)', 'assets/pendaftaran_artikel/154/Abstrak_INITIATING OF MADURA TOURISM BASED ON THE LOCAL WISDOM.docx', NULL, 'assets/pendaftaran_artikel/154/CV_CV ABD HANNAN. Indonesia.docx', 2, '2017-07-21 16:04:37', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (156, '1711050156', 1, 1, 5, 'PERAN INVESTASI, MODAL MANUSIA DAN PRODUKTIFITAS TENAGA KERJA DALAM PERLUASAN DAN PENINGKATAN DAYA SAING  GLOBAL PADA INDUSTRI PENGOLAHAN DI JAWA TIMUR', 'assets/pendaftaran_artikel/156/Abstrak_Abstrak Fitri Rusdianasari.docx', NULL, 'assets/pendaftaran_artikel/156/CV_CURRICULUM VITAE_Fitri Rusdianasari.docx', 2, '2017-07-21 16:36:33', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (155, '1721070155', 2, 1, 7, 'Peta Sektor dan Impact  CSR Perbankan Sebagai Referensi  Perencanaan  Daya Saing Sumber Daya Manusia', 'assets/pendaftaran_artikel/155/Abstrak_EJAVEC2017-Abstrak-Lindiawati.doc', NULL, 'assets/pendaftaran_artikel/155/CV_20170721-CV Lindiawati-EJAVEC2017.doc', 0, '2017-07-21 16:14:55', 'i29NWyhr8EX8');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (140, '1722060140', 2, 2, 6, 'Credit Card Fraud Detection System Using  Support Vector Machine  And SMS Gateway', 'assets/pendaftaran_artikel/140/Abstrak_ABSTRAK_INDONESIA_EJAVEC2017_RUDY PRIETNO.rar', NULL, 'assets/pendaftaran_artikel/140/CV_CV_PESERTA_ABSTRAK_INDONESIA_EJAVEC2017_RUDY PRIETNO.rar', 2, '2017-07-21 14:59:59', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (157, '1722040157', 2, 2, 4, 'KEBUDAYAAN LOKAL SEBAGAI ASET TIDAK BERWUJUD KABUPATEN BANYUWANGI', 'assets/pendaftaran_artikel/157/Abstrak_ABSTRAK---KEBUDAYAAN LOKAL SEBAGAI ASET TAK BERWUJUD KABUPATEN BANYUWANGI.doc', NULL, 'assets/pendaftaran_artikel/157/CV_CV.doc', 2, '2017-07-21 16:49:21', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (158, '1711070158', 1, 1, 7, 'OPTIMALISASI DANA DESA SEBAGAI SUMBER DANA ALTERNATIF UNTUK PEMBIAYAAN PEMBANGUNAN JAWA TIMUR', 'assets/pendaftaran_artikel/158/Abstrak_OPTIMALISASI DANA DESA SEBAGAI SUMBER DANA ALTERNATIF UNTUK PEMBIAYAAN PEMBANGUNAN  JAWA TIMUR.pdf', NULL, 'assets/pendaftaran_artikel/158/CV_CV brian.docx', 2, '2017-07-21 16:57:01', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (146, '1712060146', 1, 2, 6, 'Analisis Model Peer to Peer (P2P) Lending sebagai Strategi Pengembangan Ternak Sapi Potong Lokal Pamekasan', 'assets/pendaftaran_artikel/146/Abstrak_Abstrak (Indonesia dan english)Analisis Model Peer to Peer.pdf', NULL, 'assets/pendaftaran_artikel/146/CV_CV Rizqatus Sholehah dan Yunita Ayunil Husna.pdf', 4, '2017-07-21 15:15:10', 'Zy11A6wtJgL5BTMJbFlNJI7hjDdOL4djvgOjWIftO5u0PjXU6JwGWWPswK77dXJj1jWXB7~YcNhd2BD03yjlWw--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (145, '1721070145', 2, 1, 7, 'Analysis of Financial Performance and Alternative Source of Financing in Implementation Local Autonomy (Study at The Local Government of Malang City)', 'assets/pendaftaran_artikel/145/Abstrak_Abstract for Ejavec 2017.docx', NULL, 'assets/pendaftaran_artikel/145/CV_Biodataku.doc', 2, '2017-07-21 15:10:58', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (137, '1722020137', 2, 2, 2, 'Learn from failure! Potential of mocaf flour industry as agroindustry in East Java', 'assets/pendaftaran_artikel/137/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/137/CV_CV 2.docx', 2, '2017-07-21 14:52:26', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (139, '1721040139', 2, 1, 4, 'Penguatan Sosial Ekonomi Jawa Timur melalui Reorientasi Strategi Pengelolaan Destinasi Halal Internasional', 'assets/pendaftaran_artikel/139/Abstrak_Penguatan Sosial Ekonomi Jawa Timur melalui Reorientasi Strategi Pengelolaan Destinasi Halal Internasional.docx', NULL, 'assets/pendaftaran_artikel/139/CV_cv Fajar Surya Ari Anggara new(1).pdf', 2, '2017-07-21 14:55:39', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (159, '1712090159', 1, 2, 9, 'Analisis Global Value Chains dalam Peningkatan Kinerja dan Daya Saing Global Industri Pengolahan Hasil Perikanan Jawa Timur: Studi Kasus UKM Pengolahan Hasil Perikanan se-Gerbangkertosusila, Jawa Timur', 'assets/pendaftaran_artikel/159/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/159/CV_CV PESERTA.docx', 2, '2017-07-21 17:03:30', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (162, '1712100162', 1, 2, 10, 'Kampung Jatim: Pengoptimalan Potensi Lokal Daerah Melalui Pembiayaan Berbasis Crowdfunding Syariah Guna Meingkatkan Daya Saing UMKM di Jawa Timur', 'assets/pendaftaran_artikel/162/Abstrak_Kampung Jatim.pdf', NULL, 'assets/pendaftaran_artikel/162/CV_Biodata Kelompok.pdf', 0, '2017-07-21 17:10:16', '0H0ODMabo3Pj');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (163, '1721020163', 2, 1, 2, 'MEWUJUDKAN JAWA TIMUR SEBAGAI PUSAT AGROINDUSTRI : BAGAIMANA MASALAH, TANTANGAN DAN SOLUSINYA?', 'assets/pendaftaran_artikel/163/Abstrak_Abstraksi Nurul Izzati S.docx', NULL, 'assets/pendaftaran_artikel/163/CV_CV Nurul Izzati S.pdf', 0, '2017-07-21 17:10:45', '9SDZceFCy0Ts');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (165, '1721020165', 2, 1, 2, 'MEWUJUDKAN JAWA TIMUR SEBAGAI PUSAT AGROINDUSTRI : BAGAIMANA MASALAH, TANTANGAN DAN SOLUSINYA?', 'assets/pendaftaran_artikel/165/Abstrak_Abstraksi Nurul Izzati S.docx', NULL, 'assets/pendaftaran_artikel/165/CV_CV Nurul Izzati S.pdf', 0, '2017-07-21 17:14:11', 'lTjwKkE7jX0p');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (168, '1712040168', 1, 2, 4, 'Peran Moda Transportasi Kereta Api dalam Pemerataan Pembangunan Pariwisata dan Ekonomi Jawa Timur: Pelajaran dari Swiss dan Jepang', 'assets/pendaftaran_artikel/168/Abstrak_Abstrak EJAVEC 2017.pdf', NULL, 'assets/pendaftaran_artikel/168/CV_BramAdimasWasito CV.pdf', 0, '2017-07-21 17:41:28', 'Y433aPDHIsJG');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (167, '1722060167', 2, 2, 6, 'Peer-to-Peer Lending in Surabaya: How it drives regional economy?', 'assets/pendaftaran_artikel/167/Abstrak_P2PL in Surabaya - how it drives regional economy.pdf', NULL, 'assets/pendaftaran_artikel/167/CV_Resume - Galih dan Raka.pdf', 4, '2017-07-21 17:39:44', '~hzHe2VswtUIbG1o9e~6Y118QHxrAF2mTUrTgVoK.rsEx3sJT.PbGKg0SljDXqZdb0.JhF~kCESpV5bf7imYFQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (169, '1712040169', 1, 2, 4, 'ANALISIS NEXUS SEKTOR PARIWISATA DAN PERTUMBUHAN EKONOMI DI JAWA TIMUR: PENDEKATAN PANEL VECTOR AUTO REGRESSIVE (PVAR)', 'assets/pendaftaran_artikel/169/Abstrak_ABSTRAK EJAVEC PDF.pdf', NULL, 'assets/pendaftaran_artikel/169/CV_CV DILA DAN RINA.pdf', 4, '2017-07-21 17:44:47', '9zfWsoO428dVHlJwZHZU1lxDRxuna3rvkNUcyKlFQHzJLFD1kf~o3qNFATA2dmaXmjXDR8hCXwy9s0XWjuz4hw--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (180, '1712050180', 1, 2, 5, 'PENGARUH HORIZONTAL SPILLOVERS TERHADAP TOTAL FACTOR PRODUCTIVITY PADA INDUSTRI MANUFAKTUR DI JAWA TIMUR : LEVINSOHN-PETRIN DAN TOBIT REGRESION', 'assets/pendaftaran_artikel/180/Abstrak_ABSTRAK_EJAVEC2017_UNAIR_NEYSA_HORIZONTAL SPILLOVER.docx', NULL, 'assets/pendaftaran_artikel/180/CV_CV. EJAVEC NEYSA FEBRI ANNE.pdf', 4, '2017-07-21 18:15:56', 'QKmPLbyHpBpZ71OQEJtYTLYENFXFgh9ygKouh2QuzErYhy0v.mkIO.gbRTBrcnYiMtur0tUSIEGdiODRac2wPg--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (171, '1722040171', 2, 2, 4, 'ANALISIS STRATEGI PENGEMBANGAN AGROWISATA BELIMBING KARANGASARI DI KOTA BLITAR', 'assets/pendaftaran_artikel/171/Abstrak_STRATEGI PENGEMBANGAN AGROWISATA  BELIMBING KARANGASARI KOTA BLITAR edit.docx', NULL, 'assets/pendaftaran_artikel/171/CV_EJAVEC.zip', 2, '2017-07-21 17:59:03', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (172, '1721040172', 2, 1, 4, 'Eksplorasi Strategi Branding Regional Jawa Timur Berbasis Potensi Pariwisata Daerah', 'assets/pendaftaran_artikel/172/Abstrak_Abstrak.pdf', NULL, 'assets/pendaftaran_artikel/172/CV_CV Nurul Asiah.pdf', 0, '2017-07-21 18:02:24', '8u8odBBcTJ1h');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (174, '1711040174', 1, 1, 4, 'Potensi Sektor Pariwisata Terhadap Perekonomian Jawa Timur: Analisis Input-Output', 'assets/pendaftaran_artikel/174/Abstrak_ejavec.docx', NULL, 'assets/pendaftaran_artikel/174/CV_CV - Yuda Andika darmawan.pdf', 0, '2017-07-21 18:02:58', 'cc9LNAs7Zk3O');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (173, '1721070173', 2, 1, 7, 'Inovasi Pembiayaan Pembangunan Infrastruktur Di Jawa Timur  / (Innovation of Infrastructure Development Financing In East Java) ', 'assets/pendaftaran_artikel/173/Abstrak_Abstrak_Ida_Inovasi Pembiayaan Pembangunan Infrastruktur Di Jawa Timur.docx', NULL, 'assets/pendaftaran_artikel/173/CV_CV_Ida-Alqurnia_Mei_2017.docx', 2, '2017-07-21 18:02:41', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (175, '1711040175', 1, 1, 4, 'Peningkatan Perekonomian Kelompok Tani di Desa Songgon Kabupaten Banyuwangi Melalui Diversifikasi Produk Olahan Buah Naga', 'assets/pendaftaran_artikel/175/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/175/CV_CV Mia Silvia Rahman.docx', 2, '2017-07-21 18:03:22', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (177, '1721060177', 2, 1, 6, 'Potensi Teknologi Finansial Islami dan Dampaknya Untuk Mewujudkan Ekonomi Cerdas Jawa Timur', 'assets/pendaftaran_artikel/177/Abstrak_Potensi Islamic Financial Technology dan Dampaknya Dalam Mewujudkan Smart Econom.pdf', NULL, 'assets/pendaftaran_artikel/177/CV_cv Fajar Surya Ari Anggara new(1).pdf', 2, '2017-07-21 18:12:40', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (178, '1722040178', 2, 2, 4, 'Pengembangan Desa Inovasi Sektor Pariwisata di Jawa Timur', 'assets/pendaftaran_artikel/178/Abstrak_Abstrak Desa Inovasi.doc', NULL, 'assets/pendaftaran_artikel/178/CV_DAFTAR RIWAYAT   HIDUP-irwantoro.docx', 2, '2017-07-21 18:14:16', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (170, '1712020170', 1, 2, 2, 'Jawa Timur Agropolis Center: Upaya dan Tantangan Pusat Pengembangan Agrikultur', 'assets/pendaftaran_artikel/170/Abstrak_Ejavec4_Sandy Irawan.pdf', NULL, 'assets/pendaftaran_artikel/170/CV_Identitas Diri.docx', 2, '2017-07-21 17:57:12', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (179, '1711090179', 1, 1, 9, 'The Empowerment of Women Workers: Participation Dolly?s Women in Global Value Chains', 'assets/pendaftaran_artikel/179/Abstrak_EJAVEC-Ing-LINDA.docx', NULL, 'assets/pendaftaran_artikel/179/CV_CV EVAJEC.docx', 2, '2017-07-21 18:15:04', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (176, '1712040176', 1, 2, 4, 'Peran Moda Transportasi Kereta Api dalam Pemerataan Pembangunan Pariwisata dan Ekonomi Jawa Timur: Pelajaran dari Swiss dan Jepang', 'assets/pendaftaran_artikel/176/Abstrak_Abstrak EJAVEC 2017.pdf', NULL, 'assets/pendaftaran_artikel/176/CV_CV EJAVEC 2017.pdf', 2, '2017-07-21 18:06:50', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (161, '1712100161', 1, 2, 10, 'Mudharabah Linked Waqf dalam Aplikasi Smartphone Guna Mengakselerasi Permodalan, Lahan Usaha, Penjualan dan Teknologi Produk UMKM di Jawa Timur', 'assets/pendaftaran_artikel/161/Abstrak_Abstrak ejavect_Faqih Adam_Univrsitas Pendidikan Indonesia Bandung.pdf', NULL, 'assets/pendaftaran_artikel/161/CV_Identitas Diri.pdf', 4, '2017-07-21 17:09:36', '5RZUgK06joNAmw9HY5Ot7tNz8GqIURnia704PgF0WJzlUqasY2cIfdmvJdzLNrx6ZYHw0bjBg7NWeFLZ7OEX0w--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (153, '1712090153', 1, 2, 9, 'PENINGKATAN DAYA SAING KOPERASI PERTANIAN BERBASIS GLOBAL VALUE CHAIN (GVC) DI WILAYAH STRATEGIS JAWA TIMUR', 'assets/pendaftaran_artikel/153/Abstrak_ABSTRAK EJAVEC 2017_PENINGKATAN DAYA SAING KOPERASI PERTANIAN BERBASIS GLOBAL VALUE CHAIN_TEMA 9_FELIA DAN SHELLA_UNIVERSITAS JEMBER.docx', NULL, 'assets/pendaftaran_artikel/153/CV_CV Felia dan Shella_PENINGKATAN DAYA SAING KOPERASI PERTANIAN BERBASIS GLOBAL VALUE CHAIN (GVC) DI WILAYAH STRATEGIS_Universitas Jember.docx', 2, '2017-07-21 15:57:06', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (160, '1712080160', 1, 2, 8, 'Analisis Pemanfaatan Bonus Demografi dalam Pemerataan Potensi Industri Lokal di Setiap Wilayah Jawa Timur', 'assets/pendaftaran_artikel/160/Abstrak_ABSTRAK_UNESA_2017.pdf', NULL, 'assets/pendaftaran_artikel/160/CV_CV_TIM_UNESA_EJAVEC_2017.pdf', 2, '2017-07-21 17:08:01', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (164, '1712100164', 1, 2, 10, 'MUSLIMPRENEUR CURRICULUM : MODEL AKSELERASI SAUDAGAR MUSLIM MENUJU JAWA TIMUR PUSAT PENGEMBANGAN EKONOMI SYARIAH ', 'assets/pendaftaran_artikel/164/Abstrak_ABSTRAK.docx', NULL, 'assets/pendaftaran_artikel/164/CV_CURRICULUM VITAE.pdf', 2, '2017-07-21 17:11:55', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (182, '1712100182', 1, 2, 10, 'Integrasi bisnis peer to peer lending dan pemanfaatan wakaf tunai dalam penguatan UMKM dan start-up', 'assets/pendaftaran_artikel/182/Abstrak_EjavecEnglish&Indonesia.docx', NULL, 'assets/pendaftaran_artikel/182/CV_CVZakka.docx', 4, '2017-07-21 18:18:34', 'SHx4BrfxneDIPX2yrPzXTRhr5udvYb82oyuqBjMUw3q0Lsicy0P29EenB0VUCNAz6prc~LUSbrbo8.yeuPMY0A--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (183, '1711020183', 1, 1, 2, 'Peningkatan Perekonomian Kelompok Tani di Desa Songgon Kabupaten Banyuwangi Melalui Diversifikasi Produk Olahan Buah Naga', 'assets/pendaftaran_artikel/183/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/183/CV_CV Mia Silvia Rahman.docx', 0, '2017-07-21 18:20:02', '05g7I9JkCwbS');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (184, '1711040184', 1, 1, 4, 'PERANAN SEKTOR PARIWISATA TERHADAP PEREKONOMIAN PROVINSI JAWA TIMUR (PENDEKATAN MODEL INPUT-OUTPUT)', 'assets/pendaftaran_artikel/184/Abstrak_ABSTRAK_EJAVEC_EKA ANDRI KURNIAWAN.docx', NULL, 'assets/pendaftaran_artikel/184/CV_(Andri) Curriculum Vitae.rtf', 0, '2017-07-21 18:20:37', 'EwrpTpQVsl65');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (200, '1711040200', 1, 1, 4, 'SEEJAVA (Smart Electronic East Java) Tourism Card: Sebuah Inovasi Layanan untuk Meningkatkan Pariwisata di Jawa Timur', 'assets/pendaftaran_artikel/200/Abstrak_Abstrak_Hidayatur Rohman_Universitas Airlangga_SEEJAVA Tourism Card.pdf', NULL, 'assets/pendaftaran_artikel/200/CV_CV_HIDAYATUR ROHMAN_UNIVERSITAS AIRLANGGA.pdf', 2, '2017-07-21 18:58:50', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (192, '1722080192', 2, 2, 8, 'KETIMPANGAN KESEJAHTERAAN DAN BONUS DEMOGRAFI DI JAWA TIMUR: PENDEKATAN OVERLAPPING GENARATIONS (OLG) MODEL', 'assets/pendaftaran_artikel/192/Abstrak_Abstrak_KETIMPANGAN KESEJAHTERAAN DAN BONUS DEMOGRAFI DI JAWA TIMUR PENDEKATAN OVERLAPPING GENARATIONS (OLG) MODEL.pdf', NULL, 'assets/pendaftaran_artikel/192/CV_Curriculum Vitae.pdf', 4, '2017-07-21 18:37:18', 'XQQZ9.5xH6kusWXkn4yWXg7X7D8ecW4HAJHk1x28Sp1yGGrmz7t5hOaL9whdi7yJqR7LaWQ3qXnCqRQqgIa9Og--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (187, '1721020187', 2, 1, 2, 'TANTANGAN MENGGALI POTENSI WISATA EDUKASI DI KAMPUNG COKLAT KABUPATEN BLITAR', 'assets/pendaftaran_artikel/187/Abstrak_TANTANGAN MENGGALI POTENSI WISATA EDUKASI DI KAMPUNG COKLAT KABUPATEN BLITAR.docx', NULL, 'assets/pendaftaran_artikel/187/CV_CURRICULUM VITAE - Inda Fresti.docx', 4, '2017-07-21 18:26:47', '~0Ve~BO3c9sPv7g2ZYd~1d9dyMPNXzpU2fUvV8FxXjpp9dWajRNrwQlLoUafxRppdjV3ZTyTbHsXUSqRKtZ8Aw--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (189, '1712050189', 1, 2, 5, 'PENGARUH HORIZONTAL SPILLOVERS TERHADAP TOTAL FACTOR PRODUCTIVITY PADA INDUSTRI MANUFAKTUR DI JAWA TIMUR : LEVINSOHN-PETRIN DAN TOBIT REGRESION', 'assets/pendaftaran_artikel/189/Abstrak_ABSTRAK_EJAVEC2017_UNAIR_NEYSA_HORIZONTAL SPILLOVER.docx', NULL, 'assets/pendaftaran_artikel/189/CV_CV. EJAVEC NEYSA FEBRI ANNE.pdf', 0, '2017-07-21 18:34:55', 'bUtBvtlkLoFY');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (181, '1712020181', 1, 2, 2, 'STRATEGI PEMASARAN KOMODITAS GABAH KERING DI KABUPATEN BAYUWANGI MELALUI KEBIJAKAN PASAR MONOPOLI', 'assets/pendaftaran_artikel/181/Abstrak_Bayu Aji_Ahmad Fajri_Politeknik Negeri Semarang_IND-ENG.pdf', NULL, 'assets/pendaftaran_artikel/181/CV_Curricullum Vitae.pdf', 2, '2017-07-21 18:16:03', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (191, '1712010191', 1, 2, 1, 'Analisis Arah Ekonomi Jawa Timur Pada Era Integrasi Ekonomi dan Pasar Persaingan Global', 'assets/pendaftaran_artikel/191/Abstrak_ABSTRACT_Feri_Ejavec2017.docx', NULL, 'assets/pendaftaran_artikel/191/CV_CV Feri Dwi R dan Angga Erlando.pdf', 4, '2017-07-21 18:36:46', '3qDY4krGIeEEqCqH6s5Ka.CIqSEfPaJe~TGJJAnWiDIabkJeRYLEINZ3FppAhfVQH5CbT1A0ByduEOLPlBsoZQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (193, '1722070193', 2, 2, 7, 'Peningkatan Dramatis PAD Jawa Timur Melalui Perusahaan Daerah Pengolah Limbah dan Energi (PDPLE)', 'assets/pendaftaran_artikel/193/Abstrak_Abstract for EJAVEC 2017.doc', NULL, 'assets/pendaftaran_artikel/193/CV_CV donny FIX.docx', 0, '2017-07-21 18:46:26', 'sWz7CAN8qFut');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (186, '1722040186', 2, 2, 4, 'ANALISIS STRATEGI KEBIJAKAN PENGEMBANGAN SEKTOR PARIWISATA BERDASARKAN PELUANG DAN POTENSI INVESTASI SEBAGAI PENYOKONG PEREKONOMIAN JAWA TIMUR', 'assets/pendaftaran_artikel/186/Abstrak_ABSTRAK INDONESIA dan INGGRIS.pdf', NULL, 'assets/pendaftaran_artikel/186/CV_CV TIM.pdf', 2, '2017-07-21 18:24:11', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (204, '1712100204', 1, 2, 10, 'Optimalisasi Kinerja Satuan Tugas Akselerasi Ekonomi Syariah (SATU AKSES) dalam rangka penguatan ekonomi syariah di Jawa Timur', 'assets/pendaftaran_artikel/204/Abstrak_EJAVEC2017_ABSTRAK_Arinda Dewi Nur Aini_UNAIR_085733531383.pdf', NULL, 'assets/pendaftaran_artikel/204/CV_Curriculum Vitae (CV) Simpel Formal (2).docx', 2, '2017-07-21 19:07:40', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (188, '1722090188', 2, 2, 9, 'Optimizing the Role of AEC to Support the Global Value Chain of Industry  in East Java', 'assets/pendaftaran_artikel/188/Abstrak_EJAVEC-Abstract-Optimizing the Role of AEC to Support the Global Value Chain of Industry in East Java.docx', NULL, 'assets/pendaftaran_artikel/188/CV_CV Darwis MA dan Achmad Fawaid H-English-EJAVEC.doc', 4, '2017-07-21 18:34:08', '6ELEl8oCNZiNpb.sHnH3SqwOgeHcsq8XKeGEeFXi2oiNgF~Y4PfcWG3oe6PqRWuQspkn2h8gaP9NkjPeGZQS9g--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (198, '1712040198', 1, 2, 4, 'Dampak Sustainable Tourism pada Kualitas Hidup Masyarakat di Lingkungan Destinasi Wisata Jawa Timur', 'assets/pendaftaran_artikel/198/Abstrak_abstract.docx', NULL, 'assets/pendaftaran_artikel/198/CV_Curiculum vitae.doc', 0, '2017-07-21 18:54:20', 'Ivm2RCAsyaaU');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (194, '1712050194', 1, 2, 5, 'Strategi Reindustrialisasi Pengembangan Sektor Industri Pengolahan Jawa Timur Melalui Incubator Learning', 'assets/pendaftaran_artikel/194/Abstrak_abstrak jurnal ejavec.pdf', NULL, 'assets/pendaftaran_artikel/194/CV_BIODATA PESERTA.pdf', 4, '2017-07-21 18:48:58', 'yVmUT2N~PSCnhAI3auDniI6fDf~bNCF.OhaEC5NEvrBkazo6VxNvtbdGMGP5dfeB~W1g3gH8NPBCOZ0iNnhJcQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (203, '1721090203', 2, 1, 9, 'Penguatan Daya Saing Daerah dalam Meningkatkan Partisipasi GVC (Global Value Chain)  (Studi Kasus pada Pemerintah Provinsi Jawa Timur)', 'assets/pendaftaran_artikel/203/Abstrak_Abstract for Ejavec 2 2017.docx', NULL, 'assets/pendaftaran_artikel/203/CV_Biodataku.doc', 2, '2017-07-21 19:05:55', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (202, '1711040202', 1, 1, 4, 'akses traveller sebagai gerbang pembuka wisata tapal kuda', 'assets/pendaftaran_artikel/202/Abstrak_ABSTRAKSI.docx', NULL, 'assets/pendaftaran_artikel/202/CV_CV Raihan Dzakwan-1.docx', 2, '2017-07-21 18:59:50', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (201, '1722060201', 2, 2, 6, 'Measuring the advancement of the financial technology adoption in East Java:  Case Study in Surabaya', 'assets/pendaftaran_artikel/201/Abstrak_EJAVEC 2017.pdf', NULL, 'assets/pendaftaran_artikel/201/CV_Resume Raka - Annisa - Faruq.pdf', 2, '2017-07-21 18:59:28', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (197, '1721080197', 2, 1, 8, 'The Strategy to Overcome Spatial Inequality and Alleviate Poverty in East Java: An Inclusive Growth Approach', 'assets/pendaftaran_artikel/197/Abstrak_Abstrak Andiga.docx', NULL, 'assets/pendaftaran_artikel/197/CV_CV Andiga.docx', 4, '2017-07-21 18:53:40', 'oRFvnQ3dJ4XVEhDzROC2HCH~IIziHsKY4fY8do7xTjuAWgD.NNj3quK7cLFt0NuVwPQq9jPSY3mgOfEVfBjV~g--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (195, '1721080195', 2, 1, 8, 'Bonus Demografi di Jawa Timur: Sumber Kekuatan Ekonomi Daerah ataukah  Pemicu Ketidakmerataan Kesejahteraan?', 'assets/pendaftaran_artikel/195/Abstrak_devanto_ejavec.docx', NULL, 'assets/pendaftaran_artikel/195/CV_C.V.-Devanto-1.doc', 4, '2017-07-21 18:50:15', 'zsvZNw1JBrBNqW3wTTU9G1vsvmpK2TC74HwJdaKruM0o4c9B4Zy1ktoOEOtKbL2HYdGsFONk~lp9cjQe1O2ozA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (185, '1711040185', 1, 1, 4, 'PERANAN SEKTOR PARIWISATA TERHADAP PEREKONOMIAN PROVINSI JAWA TIMUR (PENDEKATAN MODEL INPUT-OUTPUT)', 'assets/pendaftaran_artikel/185/Abstrak_ABSTRAK_EJAVEC_EKA ANDRI KURNIAWAN.docx', NULL, 'assets/pendaftaran_artikel/185/CV_(Andri) Curriculum Vitae.rtf', 4, '2017-07-21 18:23:23', '5ch9AQm3YIWAjb3u.E6RYU8JGCzh85a3VdVTAK77SBoLuPcBZrciU14gOTy36oNf2FWLlj4ihKrWHBcLK.VVqg--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (209, '1711100209', 1, 1, 10, 'Optimalisasi Peran Perbankan Syariah dalam Sektor Peranian di Jawa Timur', 'assets/pendaftaran_artikel/209/Abstrak_Abstrak_Listiono.pdf', NULL, 'assets/pendaftaran_artikel/209/CV_CV. Listiono.pdf', 2, '2017-07-22 02:34:03', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (41, '1712020041', 1, 2, 2, 'Penuntasan Masalah Agroindustri Melalui Sistem Economic Social Provisioning Process untuk Menjadikan Jawa Timur sebagai Pusat Agroindustri di Indonesia', 'assets/pendaftaran_artikel/41/Abstrak_Penuntasan Masalah Agroindustri Melalui Sistem Economic Social Provisioning Process untuk Menjadikan Jawa Timur sebagai Pusat Agroindustri di Indonesia-1.pdf', NULL, 'assets/pendaftaran_artikel/41/CV_CV.doc', 4, '2017-07-19 16:47:51', 'wsvitounY2qvVnE4pdGz6FC50SxhpJ2xqv~SDdNN6kO.TE.fJQjUvF~rt5QqpIMn~x29pbbhtxrDsyMCHMQsVA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (207, '1722060207', 2, 2, 6, 'Implikasi e-Money Terhadap Kesejahteraan Jawa Timur Menurut Perspektif Islam', 'assets/pendaftaran_artikel/207/Abstrak_abstract Yuli Utami for ejavec 2017.pdf', NULL, 'assets/pendaftaran_artikel/207/CV_CURRICULUM VITAE DITA YULI FATIN.pdf', 0, '2017-07-21 22:48:09', 'OwX1cvAkOll8');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (208, '1721070208', 2, 1, 7, 'SKEMA PINJAMAN DAERAH SEBAGAI ALTERNATIF SUMBER PEMBIAYAAN PEMBANGUNAN INFRASTRUKTUR  DI JAWA TIMUR', 'assets/pendaftaran_artikel/208/Abstrak_Abstrac-Fitria N.Anggraeni.docx', NULL, 'assets/pendaftaran_artikel/208/CV_Fitria Nur Anggraeni CV.pdf', 2, '2017-07-21 23:21:09', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (199, '1711040199', 1, 1, 4, 'membagun pariwisata sebagai mesin penggerak ekonomi jawa imur', 'assets/pendaftaran_artikel/199/Abstrak_Membangun Prawisata Sebagai Mesin Pengerak Perekonomian Jawa Timur.docx', NULL, 'assets/pendaftaran_artikel/199/CV_Biodata Anggota Pelaksanan asnawir.docx', 2, '2017-07-21 18:57:15', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (210, '1722040210', 2, 2, 4, 'Analisis Dampak Multiplier Ekonomi Sektor Pariwisata Dalam Perekonomian Provinsi Jawa Timur Dengan Pendekatan Input Output', 'assets/pendaftaran_artikel/210/Abstrak_Abstrak.docx', NULL, 'assets/pendaftaran_artikel/210/CV_Curriculum Vitae.docx', 2, '2017-07-22 03:08:47', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (212, '1722050212', 2, 2, 5, 'PENERAPANA BUDAYA GOTONG ROYONG PADA SISTEM PENGENDALIAN MANAJEMEN SENTRA INDUSTRI TAHU', 'assets/pendaftaran_artikel/212/Abstrak_Artikel-Ubay.doc', NULL, 'assets/pendaftaran_artikel/212/CV_CV Okta.docx', 0, '2017-07-22 06:53:54', 'weoZ3WhMQxcJ');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (213, '1722050213', 2, 2, 5, 'PENERAPANA BUDAYA GOTONG ROYONG PADA SISTEM PENGENDALIAN MANAJEMEN SENTRA INDUSTRI TAHU', 'assets/pendaftaran_artikel/213/Abstrak_Artikel-Ubay.doc', NULL, 'assets/pendaftaran_artikel/213/CV_CV Okta.docx', 0, '2017-07-22 07:55:49', '9LeqRTIvkujg');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (214, '1721040214', 2, 1, 4, 'POTENSI PARIWISATA  HALAL DALAM UPAYA MENINGKATKAN PEREKONOMIAN RAKYAT: SEBUAH EKPLORASI UNTUK PROVINSI JAWA TIMUR', 'assets/pendaftaran_artikel/214/Abstrak_EJAVEC-UNAIR_ABSTRACT_MARSDENIA.docx', NULL, 'assets/pendaftaran_artikel/214/CV_CV__MARSDENIA_ejavec_22 JULI 2017.docx', 0, '2017-07-22 09:48:46', 'UBJtcOwy6jwj');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (59, '1712040059', 1, 2, 4, 'PENGEMBANGAN POTENSI PARIWISATA SEBAGAI LEADING SECTOR PEREKONOMIAN JAWA TIMUR: PENDEKATAN ERROR CORRECTION MODEL (ECM)', 'assets/pendaftaran_artikel/59/Abstrak_EJAVEC_Harris Eka Sidharta & Anggi Puspa Pertiwi.docx', NULL, 'assets/pendaftaran_artikel/59/CV_Curiculum Vitae.docx', 4, '2017-07-20 18:16:23', 'ZoQSLIhwV5fOGcOF6.HmJ6.vdXAGe.wAqqBt8DVV0HHLBQjohT8Dx2DgAs.75WQpNLNm35aJ1UCHCAgn7dqvew--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (215, '1711010215', 1, 1, 1, 'Blaba', 'assets/pendaftaran_artikel/215/Abstrak_iifcapitalflowsuserguide.pdf', NULL, 'assets/pendaftaran_artikel/215/CV_iifcapitalflowsuserguide.pdf', 0, '2017-07-23 13:40:09', 'lpWBxqS0Igqe');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (211, '1721100211', 2, 1, 10, 'Optimalisasi Peran Perbankan Syariah dalam Sektor Peranian di Jawa Timur', 'assets/pendaftaran_artikel/211/Abstrak_Abstrak_Listiono.pdf', NULL, 'assets/pendaftaran_artikel/211/CV_CV. Listiono.pdf', 2, '2017-07-22 03:09:21', NULL);

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (79, '1712070079', 1, 2, 7, 'Potensi Inovasi Pembiayaan Ekonomi Kreatif  di Kawasan Madura Berbasis Village Sharia Investment System sebagai Penopang Ekonomi Baru Jawa Timur', 'assets/pendaftaran_artikel/79/Abstrak_Abstrak_Herman Palani, Handoko_Universitas Gadjah Mada.pdf', NULL, 'assets/pendaftaran_artikel/79/CV_CV_Herman Palani, Handoko.pdf', 4, '2017-07-21 06:13:43', 'd2FBDmcama8C.8FtF.unTHjuw1VbP8Ayi.kJt0J.KZ~ODve82VqvqdvuHppHflwI0tVfMHA7kEn~1jjgLKbl0A--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (12, '1711050012', 1, 1, 5, 'OnCom Berbasis Quadruple Helix : Solusi Inovatif Peningkatan Daya Saing Industri Pengolahan Jawa Timur', 'assets/pendaftaran_artikel/12/Abstrak_Nur Septiani_Universitas Negeri Surabaya.docx', NULL, 'assets/pendaftaran_artikel/12/CV_CURRICULUM VITAE.docx', 4, '2017-07-09 15:51:02', 'T1dxeXC.H7Qin~LXPfEhLLILpDMie5xClvkpZUG.Xg1JP5NazDsEAmiorcdVT30nJkGXXJm67vxCj0yhS9qLmg--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (33, '1712080033', 1, 2, 8, 'Bonus Demografi di Jawa Timur: Berkah atau Bencana?', 'assets/pendaftaran_artikel/33/Abstrak_EJAVEC_Bonus Demografi di Jawa Timur - Berkah atau Bencana.docx', NULL, 'assets/pendaftaran_artikel/33/CV_EJavec_Curriculum Vitae.docx', 4, '2017-07-18 11:07:00', 'fcd0BWJF.KIha2kN7wFlWSSZfij1f8fqVMZmZ9GL0q9XgPOmj4XjHb0Mj4u8qCfhH21jQBVNqzMQICJlVKvJ4w--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (58, '1711080058', 1, 1, 8, 'Optimizing Demographic Dividend in Perspective of Return on Education in East Java: To School, to Work, or to Entrepreneur?', 'assets/pendaftaran_artikel/58/Abstrak_R.DIMAS BAGAS HERLAMBANG - UNIVERSITAS AIRLANGGA.pdf', NULL, 'assets/pendaftaran_artikel/58/CV_R. DIMAS BAGAS HERLAMBANG - UNIVERSITAS AIRLANGGA.pdf', 4, '2017-07-20 17:48:36', '9s9neFzECoEvix0l7jNeGHsnWO.0aUOWBbd9cVDFs7ZFckNM3BJareXF6AQjLCNR6623.3c67DZ7SJqSULiq4A--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (98, '1722080098', 2, 2, 8, 'Analisis Bonus Demografi dan Pertumbuhan Ekonomi Jawa Timur', 'assets/pendaftaran_artikel/98/Abstrak_1 abstrak demografi for ejavec.pdf', NULL, 'assets/pendaftaran_artikel/98/CV_cv penulis.pdf', 4, '2017-07-21 10:00:02', 'SQfNxK3Z0AoQ~TQMRLKYOTPYenlvIg4y2q5HA4rfkr2zYPxs7YtmHWOrIxp0QQQwt1uKL5QxKqCa2NgmfpKifQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (104, '1722020104', 2, 2, 2, 'THE IMPACT OF SUPPLY CHAIN STRATEGY ON FIRM PERFORMANCE  THE MODERATING ROLE OF COMPETITIVE STRATEGY (Study on Coffee Processing Firm in East Java)', 'assets/pendaftaran_artikel/104/Abstrak_ABSTRAKSI MABY BAFS.pdf', NULL, 'assets/pendaftaran_artikel/104/CV_CV BAFS  2017.pdf', 4, '2017-07-21 10:34:52', 'ctU3PzXxG6qaGieP41WZDaEHXJRHCan~ZeyPdvWYh2n58uBvtUHcWA~lc8eNuFG4O6pfNQrdZAArXAh6GRqHWQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (205, '1712040205', 1, 2, 4, 'Dampak Sustainable Tourism pada Kualitas Hidup Masyarakat di Lingkungan Destinasi Wisata Jawa Timur', 'assets/pendaftaran_artikel/205/Abstrak_abstract.docx', NULL, 'assets/pendaftaran_artikel/205/CV_Curiculum vitae.doc', 4, '2017-07-21 19:08:22', '01SIorexgZkmQZtJQfx8hMIm4YLJS1AjJ.b~7rYmyGlXIHPxIUo.6RUvlnXuA8YFQcb5AWuyPaAn81yitneSDA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (117, '1721040117', 2, 1, 4, 'THE NEXUS BETWEEN TOURISM, FINANCIAL DEVELOPMENT, AND ECONOMIC GROWTH IN EAST JAVA', 'assets/pendaftaran_artikel/117/Abstrak_Ariz Aprilia_The Nexus Between Tourism, Financial Development, and Economic Growth in East Java.docx', NULL, 'assets/pendaftaran_artikel/117/CV_Curriculum Vitae - Ariz Aprilia.doc', 4, '2017-07-21 12:13:04', 'gvKhOVfv8boGRfbqzsJTIi4JxNoaPYzHGzPK7SrOv3.UTzbg8FAHOAWirkEnsvVQIF9La9NOHGbfNJ6~dP~Dew--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (166, '1722070166', 2, 2, 7, 'STUDI KAUSALITAS  DAN DAMPAK ALOKASI KREDIT PERBANKAN TERHADAP PERTUMBUHAN EKONOMI DI JAWA TIMUR', 'assets/pendaftaran_artikel/166/Abstrak_Abstrak EJAVEC 2017_Fitri Rudiana_Nofita Wulansari_Ida Alqurnia_STUDI KAUSALITAS  DAN DAMPAK ALOKASI KREDIT PERBANKAN TERHADAP PERTUMBUHAN EKONOMI DI JAWA TIMUR_.docx', NULL, 'assets/pendaftaran_artikel/166/CV_CV_FItri Rusdiana_Nofita Wulansari_Ida Alqurnia.docx', 4, '2017-07-21 17:37:59', 'UjHeUJLJqShpcLdzjBm.Y772HydI4PBbwQqLJM7pJzqr1JYUVxD9WPAbC~juhK~Mx2AgISTOV2PwrXjIWXfHzQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (190, '1721050190', 2, 1, 5, 'DETERMINAN EFISIENSI TEKNIS DAN TOTAL FACTOR PRODUCTIVITY CHANGE INDUSTRI MANUFAKTUR DI JAWA TIMUR: UPAYA PENINGKATAN KINERJA DAN DAYA SAING INDUSTRI', 'assets/pendaftaran_artikel/190/Abstrak_ABSTRAK EJAVEC_IMROATUL A.docx', NULL, 'assets/pendaftaran_artikel/190/CV_Imroatul_Amaliyah_resume.pdf', 4, '2017-07-21 18:36:43', 'KXsMwe1WfwjpubCDDSxSP7huEOYZekw3IQPdU2qYV5~cQegxhueOvEaO6X2YWHdpr4ezn.Suqq5iCn~dZ53xFw--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (206, '1722090206', 2, 2, 9, 'POTENSI USAHA MANUFAKTUR Di JAWA TIMUR SEBAGAI PENGUAT EKONOMI DALAM GLOBAL VALUE CHANGE', 'assets/pendaftaran_artikel/206/Abstrak_POTENSI USAHA MANUFAKTUR Di JAWA TIMUR SEBAGAI PENGUAT EKONOMI DALAM GLOBAL VALUE CHANGE_Ati dan Badara.docx', NULL, 'assets/pendaftaran_artikel/206/CV_Curriculum Vitae.docx', 4, '2017-07-21 19:19:44', 'malKAKPaoOYnP0biAs5ubzHPENlR1iKxg5p3gQi~f890z7gD9S5rIKIfSA4YF9tq2sZtJz50SDi2l.83RNqG.A--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (216, '1711010216', 1, 1, 1, 'Tes Percobaan BIIS', 'assets/pendaftaran_artikel/216/Abstrak_BIIS abtrak.txt', NULL, 'assets/pendaftaran_artikel/216/CV_BIIS CV Peserta.txt', 2, '2017-08-02 08:32:36', '2XZ~j5rNqVq5tV82lM9dBNtvSwHTpIQgR0B6n.8VoIL.gaq5KUaSar6oprZl408AhI.fwttFVPN3RBEcSjCSUw--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (92, '1721040092', 2, 1, 4, 'Pembangunan industri pariwisata berbasis masyarakat di Jawa Timur. Sebuah Studi tentang Social Capital sebagai sustainable resources', 'assets/pendaftaran_artikel/92/Abstrak_Pembangunan industri pariwisata berbasis masyarakat di Jawa Timur. Sebuah Studi tentang Social Capital sebagai sustainable resources.pdf', NULL, 'assets/pendaftaran_artikel/92/CV_CV ARIMURTI KRISWIBOWO SIP Juli 2017.pdf', 4, '2017-07-21 09:22:24', 'IJ312e0VpYwfRUK6rIVYU6690qz5PLqnnmxudxXEfH.jQtfkbMUNzfUThE6m2Sbg~Ir.AI2pU8Ywqf999K1tcw--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (196, '1712040196', 1, 2, 4, 'Strategi Pengembangan Pariwisata Jawa Timur sebagai Alternatif Sumber Pertumbuhan Ekonomi', 'assets/pendaftaran_artikel/196/Abstrak_Abstrak_Ind and Eng_Abraham Risyad_Universitas Indonesia.docx', NULL, 'assets/pendaftaran_artikel/196/CV_Daftar Riwayat Hidup Peserta (Abraham, Faizal, Kurniawati).docx', 4, '2017-07-21 18:52:44', 'O1JbWBeDr9sd2JRV37IuPFWaY9qt3wFWHihxIk69wxr2zr.dftILYvN.65uzSB1hNtZIFcl3K3cU10EUKCCLDA--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (24, '1721040024', 2, 1, 4, 'CHANGE FOR  ECO-TOURISM BY TOURISM CARD: CONCEPTS AND APPLICATIONS (TRENGGALEK, EAST JAVA)', 'assets/pendaftaran_artikel/24/Abstrak_BISMILLAH, FIX_PAPER SHERLY_EJAVEC_2017.docx', NULL, 'assets/pendaftaran_artikel/24/CV_BISMILLAH, CV SHERLY_EJAVEC 2017.docx', 4, '2017-07-17 10:58:12', 'lqrnOSY0fR6~uTEQXh6jfF1EEG.7BshHxEuxwPdmAZNS9zpp~EVBu2T9SQ~J0YExETaFpkiP.h8SVmc6z9.EnQ--');

INSERT INTO participant (participant_id, participant_number, participant_category_id, participant_type_id, article_theme_id, article_tittle, article_file, full_article_file, cv_file, participant_status, creation_date, confirmation_code)
VALUES (50, '1721020050', 2, 1, 2, 'Upaya Peningkatan Daya Saing Global  Provinsi Jawa Timur Sebagai Pusat Agro industri Melalui Pemberdayaan Industri Kecil Menengah (IKM)  Yang Kreatif dan Inovatif Secara Berkelanjutan', 'assets/pendaftaran_artikel/50/Abstrak_Abstract EJAVEC 2017 (Dr.Sri Muljaningsih,SE,MSP).docx', NULL, 'assets/pendaftaran_artikel/50/CV_CV Sri Muljaningsih (2017).docx', 4, '2017-07-20 03:13:00', 'juI2umGT8qlj5GdFwXJe7sI8qKG1wu2qsxcnZPuCHAp4s6NtKz6nKQ0mahBnaJFeYx4G6YZsSm2XFVug4lmbjA--');

--
-- Data for table public.participant_category (OID = 18332) (LIMIT 0,2)
--
INSERT INTO participant_category (participant_category_id, participant_category_name, is_active)
VALUES (1, 'Mahasiswa', 1);

INSERT INTO participant_category (participant_category_id, participant_category_name, is_active)
VALUES (2, 'Umum', 1);

--
-- Data for table public.participant_detail (OID = 18342) (LIMIT 0,351)
--
INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (10, 1, 'Indah Desira', 'Perak', 'Unair', 'Jojoran', '081212126359', 'marketing@manajemenit.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (11, 1, 'Bagus Mertha P', 'Perak', 'ITS', 'Keputih', '08564802448', 'bagusmertha@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (12, 2, 'Uun Dwi Al Muddatstsir', 'jalan karangmenjangan gang 6 no 45b surabaya', 'universitas airlangga', 'jalan airlangga', '085361836393', 'uundwi@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (13, 2, 'Early Ridho Kismawadi', 'jalan peutua bayeun lr telkom no 112 langsa, aceh', 'IAIN zawiyah cotkalla langsa', 'desa meurandeh', '085276005811', 'kismawadi@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (14, 3, 'Uun Dwi Al Muddatstsir, SE', 'jalan karangmenjangan gang 6 no 45b surabaya', 'universitas airlangga', 'jalan airlangga', '085361836393', 'uundwi@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (15, 3, 'Early Ridho Kismawadi', 'jalan peutua bayeun lr telkom no 112 langsa', 'iain zawiyah cotkalla langsa', 'desa meurandeh', '085276005811', 'kismawadi@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (18, 4, 'biis percobaan', '', '', '', '087', 'fakhrurrozi23@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (19, 5, 'Agus Sucipto', 'Jl. Kalianyar V RT 010 RW 03 No. 22 Jakarta Barat 11310', 'Badan Pengkajian dan Penerapan Teknologi', 'Gedung Pusat Inovasi dan Bisnis Teknologi (Gd. Manajemen) no. 720 Lt. 2, Kawasan PUSPIPTEK, Tangerang Selatan 15413', '081285958733', 'agus.sucipto@bppt.go.id / mr.agussucipto@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (20, 6, 'Agus Sucipto', 'Jl. Kalianyar V RT 010 RW 03 No. 22 Jakarta Barat 11310', 'Badan Pengkajian dan Penerapan Teknologi', 'Gedung Pusat Inovasi dan Bisnis Teknologi (Gd. Manajemen) No. 720 Lt. 2 Kawasan PUSPIPTEK, Tangerang Selatan 15413', '081285958733', 'agus.sucipto@bppt.go.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (21, 7, 'RENALDY ADITYA CANDRA WARDANA', 'Dsn. Kedung Gagak, Ds. Mlirip, Kec Jetis, Kab. Mojokerto, Jawa Timur', 'UNIVERSITAS NEGERI MALANG', 'Jl. Semarang No.5, Sumbersari, Kec. Lowokwaru, Kota Malang, Jawa Timur ', '085791646597', 'renaldy980@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (22, 8, 'Pranakusuma Sudhana', 'Perum Vila Valensia PA 2 No. 3, Surabaya', 'Universitas Widya Kartika', 'Jl. Sutorejo Prima Utara II/1, Surabaya', '081233724600', 'prana@widyakartika.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (23, 9, 'Yanelis Prasenja', 'Jl. Manggarai Selatan II, Blok K, No. 177, Rt 015/10, Kelurahan Manggarai, Kecamatan Tebet, Jakarta Selatan', 'Universitas Indonesia', 'Kampus UI Salemba - Gedung C (FKG) Lt. 5 dan 6
Jl. Salemba Raya No. 4 - Jakarta Pusat 10430', '087826061983', 'prasenja@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (24, 9, 'Yanti Sugiyanti', 'Jalan Pangeran Kejaksan, Gang Melati 4, No 4, Rt 05/03, Sumber Cirebon, 45611', 'Universitas Negeri Jakarta', 'Gedung M, Kampus A, Universitas Negeri Jakarta, Jl. Rawamangun Muka, Jakarta Timur', '087784302083/089660134433', 'yanti.s86@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (25, 10, 'Mahsina', 'Jl. A. Yani 114 Surabaya', 'Universitas Bhayangkara Surabaya', 'Fakultas Ekonomi Jl. A. Yani 114 Surabaya', '082115522262', 'mahsina_se@hotmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (26, 11, 'Wiwik Maryati, S.Sos M.S.M', 'Kompleks Ponpes Darul Ulum Peterongan Jombang Tromol Pos 10', 'Universitas Pesantren Tinggi Darul Ulum (Unipdu)', 'Kompleks Ponpes Darul Ulum Peterongan Jombang Tromol Pos 10', '081330054231', 'wima08@ymail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (27, 11, 'Abid Datul Mukhoyaroh, S.Sos M.Si', 'Kompleks Ponpes Darul Ulum Peterongan Jombang Tromol Pos 10', 'Universitas Pesantren Tinggi Darul Ulum (Unipdu)', 'Kompleks Ponpes Darul Ulum Peterongan Jombang Tromol Pos 10', '085655930099', 'jeng_abite@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (28, 12, 'Nur Septiani', 'Desa Purwodadi Kecamatan Purwoasri Kabupaten Kediri, RT. 01 RW. 02', 'Universitas Negeri Surabaya', 'Jalan Ketintang Baru XII No. 34, Ketintang, Gayungan, Kota Surabaya', '082299830086', 'nur.septiani.pluto@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (29, 13, 'Ahmad Rizani, S.HI., S.E., M.Eng., M.Ec.Dev.', 'Fakultas Ekonomi Jalan Amal Lama No 1, Kel. Pantai Amal, Kec. Tarakan Timur, Kota Tarakan, Kalimantan Utara', 'Universitas Borneo Tarakan', 'Jalan Amal Lama No 1, Kel. Pantai Amal, Kec. Tarakan Timur, Kota Tarakan, Kalimantan Utara', '085228632277', 'ahmadrizani@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (30, 13, 'Dr. Witri Yuliawati, S.E., M.Si.', 'Fakultas Ekonomi Jalan Amal Lama No 1, Kel. Pantai Amal, Kec. Tarakan Timur, Kota Tarakan, Kalimantan Utara', 'Universitas Borneo Tarakan', 'Jalan Amal Lama No 1, Kel. Pantai Amal, Kec. Tarakan Timur, Kota Tarakan, Kalimantan Utara', '082159793599', 'witriyuliawati75@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (31, 14, 'Heni Agustina', 'Jl amirmachmud gang 9 ni. 40 gunung anyar surabaya', 'Universitas Nahdlatul Ulama Surabaya', 'Jl Amirmachmud Gang 9 no. 40 gunung anyar surabaya', '081331070634', 'heni@unusa.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (32, 14, 'Endah Tri Wahyuningtyas', 'Gayungan I/17 A Surabaya', 'Universitas Nahdlatul Ulama Surabaya', 'Jl Jemursari No. 51-57', '0318289013 / 081913525444', 'endahtri@unusa.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (33, 15, 'DEWI NOOR FATIKHAH ROKHIMAKHUMULLAH', 'JL. RAYA DERMO RT.05 RW.01 MULYOAGUNG DAU KABUPATEN MALANG 65151', 'UNIVERSITAS NEGERI MALANG', 'JL. SEMARANG NO.5 MALANG', '081249898305', 'dewinoorfatikhah@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (34, 16, 'Ahmad Fajri', 'Jl. Baskoro Raya No 43 Pesantren Annur Tembalang, Semarang Jawa Tengah', 'Politeknik Negeri Semarang', 'Jl. Prof. Soedharto SH Tembalang Semarang Jawa Tengah', '089650472898', 'fajriahmad13@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (35, 16, 'Iwan Budiyono', 'Jl. Gemah Pedurungan, Semarang Jawa Tengah', 'Politeknik Negeri Semarang', 'Jl. Prof. Soedharto SH Tembalang Semarang Jawa Tengah', '+6281326080864', 'gusone84@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (36, 17, 'Zulfikar Steifani Prayoga', 'Jl. Jatisari Gg. Melati, Pepelegi, Waru - Sidoarjo', 'Universitas Narotama', 'Jl. Arief Rachman Hakim No. 51', '082333671155', 'Zsp01041998@gmail.com  ');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (37, 17, 'Firman Ardiansyah', 'Jl. Donorejo No. 12, Sembayat, Manyar - Gresik', 'Universitas Narotama', 'Jl. Arief Rachman Hakim No. 51 ', '081357831263', 'Firman.ardiansyah1997@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (38, 18, 'Dr. Martaleni, S.e.,m.M', 'jln Joyo Grand kav.depag III no 25-Merjosari-Malang', 'Universitas Gajayana- Malang', 'Jln Merto Joyo Blok L Merjosari-Malang', '081334193651', 'martalenikulin@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (39, 18, 'DR. HJ. UMROTUL KHASANAH, M.SI. ', 'Vila Bukit Tidar A1/21 Merjosari Malang 6514 JATIM', 'Universitas Islam Negeri (UIN) Maliki Malang', 'Jl. Gajayana 50 Dinoyo Malang 65144 Jawa Timur', '082264179167', 'umrotul_kh@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (40, 19, 'Heni Agustina', 'Jl Amirmachmud Gang 9 no. 40 gunung anyar surabaya', 'Universitas Nahdlatul Ulama Surabaya', 'Jl Jemursari No. 51-57', '081331070634', 'heniagustina93@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (41, 19, 'Endah Tri Wahyuningtyas', 'Gayungan I/ 17 A Surabaya', 'Universitas Nahdlatul Ulama Surabaya', 'Jl Jemursari No. 51-57', '081913525444', 'endahtri@unusa.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (42, 20, 'Nur Farida', 'Jl. Jawa 4 No. 6', 'Universitas Jember', 'Jl. Kalimantan No. 37 Jember', '082331494130', 'nurfarida2591@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (43, 20, 'Livia Ayu Putriana Dewi ', 'Jl Jawa', 'Universitas Jember', 'Jl. Kalimantan No. 37 Jember', '085730757464', 'liviaayu04@gmil.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (44, 21, 'Retno Pusalia', 'jalan Kedungtarukan Baru IVC No. 9 kelurahan Mojo, Gubeng, Surabaya', 'Universitas Airlangga', 'jalan Airlangga 4 - 6 Surabaya
Fakultas Ekonomi dan Bisnis', '082337935306', 'pusaliaretno@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (45, 22, 'Raditya Sukmana', 'Jl Airlangga 4, Departemen Ekonomi Syariah, Fakultas Ekonom dan Bisnis, Universitas Airlanggai ', 'Universitas Airlangga', 'Jl Airlangga 4, Departemen Ekonomi Syariah, Fakultas Ekonom dan Bisnis, Universitas Airlanggai ', '087854216776', 'raditya-s@feb.unair.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (88, 52, 'Fitriana Novi Ekacahyanti', 'Jl. Mayjend Panjaitan Gang 17 A No. 88C, Kelurahan Penanggungan, Klojen, Malang, 65113', 'Universitas Brawijaya ', 'Jalan Veteran, Malang, Jawa Timur 65145', '085704170354', 'fitriananovi1802@gmail.com ');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (46, 22, 'Imam Wahyudi Indrawan', 'Jl Airlangga 4, Departemen Ekonomi Syariah, Fakultas Ekonom dan Bisnis, Universitas Airlanggai ', 'Universitas Airlangga', 'Jl Airlangga 4, Departemen Ekonomi Syariah, Fakultas Ekonom dan Bisnis, Universitas Airlanggai ', '0857-3950-4492', 'imamindra58@gmail.com ');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (47, 23, 'Imroatu Choiroh Masula', 'Nginden Gang II No 97 B, Surabaya', 'Universitas 17 Agusus 1945 Surabaya', 'Jl. Semolowaru No 45 Surabaya', '082234597748', 'imrow_an@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (48, 24, 'Sherlinda Octa Yuniarsa', 'Fakultas Ekonomi dan Bisnis', 'Universitas Brawijaya', 'Jalan Veteran', '082233996617', 'sherlindaocta@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (49, 25, 'RIRIN SUHESTI', 'JL. K.H. AHMAD DAHLAN NO. 39, BADEKAN, BANTUL, YOGYAKARTA', 'UNIVERSITAS AHMAD DAHLAN', 'JL. KAPAS NO. 9, SEMAKI, UMBULHARJO, YOGYAKARTA', '089647453519', 'suhestiririn2@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (50, 25, 'FITRIANI NURJANAH', 'JL. JANTURAN NO. 397, UMBULHARJO IV, YOGYAKARTA', 'UNIVERSITAS AHMAD DAHLAN', 'JL. KAPAS NO. 9, SEMAKI, UMBULHARJO, YOGYAKARTA', '085377828096', 'fitrianinurjanah7@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (51, 26, 'Atik Purmiyati', 'Bumi Suko Indah C 1-41 Rt.41 Rw.11 Sidoarjo', 'Universitas Airlangga', 'Jl. Airlangga No. 4-6 Gubeng Surabaya', '085855250240', 'a.purmiyati@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (52, 27, 'RIRIN SUHESTI', 'JL. K.H. AHMAD DAHLAN NO. 39, BADEGAN, BANTUL, YOGYAKARTA', 'UNIVERSITAS AHMAD DAHLAN', 'JL. KAPAS NO. 9, SEMAKI, UMBULHARJO, YOGYAKARTA', '089647453519', 'suhestiririn2@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (53, 27, 'FITRIANI NURJANAH', 'JL. JANTURAN NO. 397, UMBULHARJO IV, YOGYAKARTA', 'UNIVERSITS AHMAD DAHLAN', 'JL. KAPAS NO. 9, SEMAKI, UMBULHARJO, YOGYAKARTA', '085377828096', 'fitrianinurjanah7@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (54, 28, 'Puspita Sari Surya Prabawati', 'Jalan Lisman Gg. Buntu 4 No. 42 Bojonegoro', 'Universitas Wijaya Kusuma Surabaya', 'Dukuh Kupang XXV/54 Surabaya', '081331084275', 'puspitaprabawati39@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (55, 28, 'Eva Wany', 'Pondok Wage Indah II Blok FF No 22 Aloha Sidoarjo', 'Universitas Wijaya Kusuma Surabaya', 'Dukuh Kupang XXV / 54 Surabaya', '0852 32030676', 'Evawany.winarto@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (56, 29, 'RIRIN SUHESTI', 'JL. K.H. AHMAD DAHLAN NO. 39, BADEGAN, BANTUL, YOGYAKARTA', 'UNIVERSITAS AHMAD DAHLAN', 'JL. KAPAS NO. 9, SEMAKI, UMBULHARJO, YOGYAKARTA', '089647453519', 'suhestiririn2@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (57, 29, 'FITRIANI NURJANAH', 'JL. JANTURAN NO. 397, UMBULHARJO, YOGYAKARTA', 'UNIVERSITAS AHMAD DAHLAN', 'JL. KAPAS NO. 9, SEMAKI, UMBULHARJO, YOGYAKARTA', '085377828096', 'fitrianinurjanah47@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (58, 30, 'RIRIN SUHESTI', 'JL. K.H. AHMAD DAHLAN NO. 39, BADEGAN, BANTUL, YOGYAKARTA', 'UNIVERSITAS AHMAD DAHLAN', 'JL. KAPAS NO. 9, SEMAKI, UMBULHARJO, YOGYAKARTA', '089647453519', 'suhestiririn2@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (59, 30, 'FITRIANI NURJANAH', 'JL. JANTURAN NO. 397, UMBULHARJO, YOGYAKARTA', 'UNIVERSITAS AHMAD DAHLAN', 'JL. KAPAS NO. 9, SEMAKI, UMBULHARJO, YOGYAKARTA', '085377828096', 'fitrianinurjanah47@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (60, 31, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (61, 32, 'Aam Slamet Rusydiana', 'Perumahan Graha Arradea Blok N No. 9 RT 02 RW 12', 'SMART Consulting', 'Perumahan Graha Arradea Blok N No. 9 RT 02 RW 12', '087770574884', 'aamsmart@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (62, 32, 'Taufiq Nugroho', 'Perum Cilebut Bogor', 'Universitas Airlangga', 'Perum Cilebut Bogor', '085656367269', 'taufiknugroho614@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (63, 33, 'Wahyudi', 'RT 001 RW 007 Des Kertosari Kec Pakusari Kab Jember', 'University of Jember', 'Jl Kalimantan No 37 Kampus Tegal Boto', '082245670393', 'wahyudi333paksi@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (64, 33, 'Iis Dwi Permatasari', 'Ds Kilensari RT 02 RW 01 Kec Panarukan, Situbondo', 'University of Jember', 'Jl Kalimantan No 37 Kampus Tegal Boto', '082334305070', 'iisdwips20@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (65, 34, 'RIS YUWONO YUDO NUGROHO', 'PERUM TALOON PERMAI BLOK L NO 14. 
DESA KAMAL, KEC. KAMAL. BANGKALAN 69162', 'UNIVERSITAS TRUNOJOYO MADURA', 'JL RAYA TELANG. PO BOX 2 GILI ANYAR. 
KEC. KAMAL. BANGKALAN 69162', '08155055046', 'risyuwono@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (66, 35, 'SITI NUR INDAH ROFIQOH', 'Jalan raya Bungah nomer 18 Bungah Gresik Jatim', 'Institut Agama Islam Qomaruddin', 'Jalan Raya Bungah Nomer 1 Bungah Gresik', '08563483910', 'fiqoh_moslem@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (67, 35, 'Niswatun Hasanah', 'Sidokumpul Bungah Gresik', 'Institut Agama Islam Qomaruddin', 'Jalan raya Bungah Nomer 1 Bungah Gresik', '085643629009', 'neezwah_86@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (68, 36, 'Fendi Indra Sujianto', 'Jalan Kalimantan 4 Blok C Nomor 76 Sumbersari Jember', 'Universitas Jember', 'Jalan Kalimantan No. 37, Kampus Tegalboto, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', '082234428737', 'fendiindra17@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (69, 36, 'Silvia Nindi Arista', 'Jalan Jawa 4 Nomor 6C', 'Universitas Jember', 'Jalan Kalimantan No. 37, Kampus Tegalboto, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', '085704801915', 'silvianindi88@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (70, 37, 'Sri Cahyaning Umi Salama', 'Ds. Kedungsari Dsn. Kedungsari RT. 03, RW. 02, Kecamatan Kemlagi, Kabupaten Mojokerto', 'Universitas Indonesia', 'Kampus Universitas Indonesia Salemba
Gedung IASTH, Lantai 4
Jl. Salemba Raya No. 4 Jakarta 10430', '085706059405', 's.c.umisalama@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (71, 38, 'Nikmatul Masruroh', 'Jl. Jumat No.08 Karangmluwo Mangli Kaliwates Jember', 'IAIN Jember', 'Jl. Mataram No.01 Kaliwates Jember', '081 332 326 125', 'nikmatul.masruroh82@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (72, 39, 'Anggun Anita Sari', 'Star Safira Regency B1/6 Sukodono Sidoarjo 61258', 'UNAIR', 'Jl. Airlangga 4-6, Surabaya 60286', '087851296981', 'anjunmoyish@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (73, 40, 'Imron Agung Khoirudin', 'Jl. Raya Siman Km. 6, Siman, Demangan, Kec. Ponorogo, Kabupaten Ponorogo, Jawa Timur', 'Universitas Darussalam Gontor', 'Jl. Raya Siman Km. 6, Siman, Demangan, Kec. Ponorogo, Kabupaten Ponorogo, Jawa Timur', '081215514501', 'khoirudin.97za@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (74, 41, 'Indra Febrianto', 'Jalan Ir Soekarno Gondek Mojowarno Jombang', 'Universitas Negeri Malang', 'Jl. Semarang No.5, Sumbersari, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145', '085854243416', 'indrafebrianto31@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (75, 41, 'Erfin Nur Listiayani', 'Banyuwangi', 'Universitas Negeri Malang', 'Jl. Semarang No.5, Sumbersari, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145', '085791670948', 'erfin_nurlistiyani@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (76, 42, 'miguel angel esquivias padilla', 'Jl WR Supratman 65. Surabaya. ', 'Universitas Airlangga', 'Jl Airlangga 4-6. Surabaya', '+6285231129100', 'esquivias.miguel@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (77, 43, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (78, 44, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (79, 45, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (80, 46, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (81, 47, 'Gigih Prihantono', 'Keputih IIIB No 52', 'Airlangga', 'Jl. Airlangga No 4 Surabaya', '085730877745', 'gigih.prihantono@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (82, 48, 'Gigih Prihantono', 'Keputih IIIB No 52 Surabaya', 'Universitas Airlangga', 'Airlangga 4 Surabaya', '085730877745', 'gigih.prihantono@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (83, 49, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (86, 52, 'Miya Nurohmah', 'Jl. Mayjend Panjaitan Gang 17 A No. 88C, Kelurahan Penanggungan, Klojen, Malang, 65113', 'Universitas Brawijaya', 'Jalan Veteran, Malang, Jawa Timur 65145', '085645608604', 'miya.nur.rohmah@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (87, 52, 'Hanna Indi DIan Yunita', 'Jl. Mayjend Panjaitan Gang 17 A No. 88C, Kelurahan Penanggungan, Klojen, Malang, 65113', 'Universitas Brawijaya ', 'Jalan Veteran, Malang, Jawa Timur 65145', '085731052550', 'hannaindi11@gmail.com ');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (343, 205, 'Eka Wahyu Utami', 'Jl.Jawa IIB No.22', 'Universitas Jember', 'Jl,Kalimantan No.37', '081231692744', 'ekawahyu295@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (89, 53, 'TOMMY TANU WIJAYA', 'JL.WARTA NO 7 BANDUNG 40273', 'STKIP SILIWANGI BANDUNG', 'JL.TERUSAN JEND.SUDIRMAN CIMAHI 40526', '087825204424', 'tanuwijayat@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (90, 54, 'Nizar Amir', 'Jl Perlis Utara No 31 Surabaya', 'East Java Exchange Center in Tianjin China', 'Jl Margerejo Indah Block C No 420 - 421 Surabaya', '08175137376', 'nizaramr@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (91, 54, 'Jasper Ho', '2/FL No 47, Minzu Road, Hebei District Tianjin, China', 'East Java Exchange Center in Tianjin China', 'Jl Margerejo Indah Block C No 420 - 421 Surabaya', '+8613902051437 / +6287861701689', 'jasper@eastjava.com.cn');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (92, 55, 'Dani Setiawan', 'Jl. Kalimantan 1 No 62', 'Universitas Jember', 'Jl. Kalimantan 37 Kampus Tegalboto Jember', '083895314747', 'danisetiawansp@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (93, 55, 'Ahmad Haris Hasanuddin Slamet', 'Perum Kebonsari Indah D18 Jember', 'Universitas Jember', 'Jl. Kalimantan 37 Kampus Tegalboto Jember', '082141072144', 'haris.hasanuddin94@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (94, 56, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (95, 57, 'Ratnawaty', 'Jl. Raya Gandusari No. 04 Rt. 18 Rw.06 dusun jatirejo desa/kec.gandusari
Jl. karang menjangan no. 35 A', 'Universitas Airlangga', 'Departemen Akuntansi
Fakultas Ekonomi dan Bisnis
Jl. Airlangga No.4, Airlangga, Gubeng, Kota SBY, Jawa Timur 60286', '081333954403', 'ratnatrenggalek@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (96, 58, 'R. Dimas Bagas Herlambang', 'Perum. Pantai Mentari blok W. no. Surabaya', 'Universitas Airlangga', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Kota SBY, Jawa Timur 60115, Indonesia', '+6287852313159', 'r.dimas.bagas.herlambang-2014@feb.unair.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (97, 59, 'Harris Eka Sidharta', 'Jalan Kalimantan IV Blok C No. 78, Sumbersari, Kabupaten Jember, Jawa Timur', 'Universitas Jember', 'Jalan Kalimantan No. 37, Kampus Tegalboto, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', '08993603729', 'haarys17@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (98, 59, 'Anggi Puspa Pertiwi', 'Jalan Brantas XXC No. 249, Sumbersari, Kabupaten Jember, Jawa Timur', 'Universitas Jember', 'Jalan Kalimantan No. 37, Kampus Tegalboto, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', '087755812558', 'anggipuspapertiwi@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (99, 60, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (100, 61, 'Risma Restyana Putri', 'Dusun Bansari, Rt 02 Rw 04, Desa Kepek. Kecamatan Wonosari, Kabupaten Gunungkidul, DIY', 'Sekolah Tinggi Pariwisata AMPTA Yogyakarta', 'Jl. Laksda Adisucipto KM 6, Desa Caturtunggal, Kec. Depok, Kab. Sleman, Provinsi DIY, 55281', '+621391425759', 'rismareatyana@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (101, 61, 'Ahmad Rosyidi Syahid', 'Jl. Nologaten, Gang Kenari, No. 229, Nologaten, Desa Caturtunggal, Kec. Depok, Kab. Sleman, Provinsi DIY', 'Sekolah Tinggi Pariwisata AMPTA Yogyakarta', 'Jl. Laksda Adisucipto KM 6, Desa Caturtunggal, Kec. Depok, Kab. Sleman, Provinsi DIY, 55281', '+6285764315999', 'syahidsunarno@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (102, 62, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (103, 63, 'ANGGRAENI RAHMASARI', 'PURI INDAH BLOK C-29 PANDUGO TIMUR RUNGKUT SURABAYA', 'UNIVERSITAS BHAYANGKARA SURABAYA', 'JL.A.YANI NO.114 SURABAYA', '081703569117', 'anggraenirahmasari@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (104, 63, 'IRWANTORO', 'PURI INDAH BLOK C 29 PANDUGO TIMUR RUNGKUT SURABAYA', 'BADAN LITBANG PROVINSI JAWA TIMUR', 'JL.GAYUNG KEBONSARI NO.56 SURABAYA', '081931591310', 'irwanlitbangjatim@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (105, 64, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (106, 65, 'Shofwan', 'Jl. Taman Raden Intan Kav. 197 Arjosari Blimbing Malang 65126', 'Universitas Brawijaya', 'Jl. Veteran Malang', '081235781697', 'shofwan1705@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (107, 66, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (108, 67, 'Ana Toni Roby Candra Yudha, S.EI, M.SEI', 'Medayu Utara Gang 23, Nomor. 41-A
Kel. Medokan Ayu; Kec. Rungkut, Surabaya
60295', 'UIN Sunan Ampel Surabaya', 'Jl. A Yani 117, Surabaya', '085645205571', 'anatoniroby@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (109, 68, 'Nurul Aini', 'Dusun Cangkring Malang, Desa Sidomulyo RT/RW 001/005, Kecamatan Megaluh, Kabupaten Jombang', 'Universitas Trunojoyo Madura', 'Jl Raya Telang, Kecamatan Kamal, Kabupaten Bangkalan.', '085607354397', 'nurulaini.shofwani@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (110, 68, 'Eko Wahyudi ', 'JL Hasyim Asy''ari, RT 3 RW 6, Desa Talangsuko, kecamatan Turen, Kabupaten Malang. ', 'Universitas Trubojoyo Madura', 'Jl Raya Telang, Kecamatan Kamal, Kabupaten Bangkalan', '085549008809', 'ekowahyudi050696@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (111, 69, 'Eko Wahyudi', 'Jl Hasyim Asy?ari RT 3 RW 6, Desa Talangsuko, Kecamatan Turen, Kabupaten Malang', 'Universitas Trunojoyo Madura', 'Jl RayaTelang, Kecamatan Kamal, Kabupaten Bangkalan', '085549008809', 'ekowahyudi050696@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (112, 69, 'Nurul Aini', 'Dusun Cangkring Malang, Desa Sidomulyo RT/RW 001/005, Kecamatan Megaluh, Kabupaten Jombang', 'Universitas Trunojoyo Madura', 'Jl Raya Telang, Kecamatan Kamal, Kabupaten Bangkalan', '085607354397', 'nurulaini.shofwani@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (113, 70, 'Dede Yusup Indaryan', 'Krapyak Kulon Rt 12 Panggung Harjo, Sewon, Bantul, Yogyakarta 55188', 'Universitas Muhammadiyah Yogyakarta', 'Jl. Lingkar Selatan, Kasihan, Tamantirto, Bantul, Tamantirto, Kasihan, Yogya, Daerah Istimewa Yogyakarta  55183', '085702443711', 'deyusindaryan@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (114, 70, 'Siti Eliyana', 'Ngebel Rt 06/Rw 07 Tamantirto, Kasihan, Bantul, Yogyakarta 55183', 'Universitas Muhammadiyah Yogyakarta', 'Jl. Lingkar Selatan, Kasihan, Tamantirto, Bantul, Tamantirto, Kasihan, Yogya, Daerah Istimewa Yogyakarta  55183', '08382342445', 'sitieliyana79@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (115, 71, 'ARIK SYIFAUL KHOFIFAH', 'RT 03 RW 01 Desa Tiremenggal Dukun Gresik', 'UNIVERSITAS INDONESIA', 'Kampus UI Baru Pondok Cina Depok', '085755934150', 'ericksyifaul@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (116, 71, 'LEON ALVINDA PUTRA', 'Solo baru sektor 3, RT 02/04 Dukuh Sontoyudan, Desa Medegondo, Kec. Grogol Kabupaten Sukoharjo', 'UNIVERSITAS INDONESIA', 'Kampus UI Baru Pondok Cina Depok', '087836422215', 'leonputra@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (117, 71, 'EKA FASIKHA', 'RT 02 RW 01 No 41 Desa Wanakaya Gunungjati Cirebon', 'UNIVERSITAS INDONESIA', 'Kampus UI Baru Pondok Cina Depok', '083823931836', 'ekafasikha@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (118, 72, 'MOCHAMAD DEVIS SUSADIKA, M.SE', 'Jl. Jendral Sudirman Gang VII No. 22 Desa Larangan, Kecamatan Candi, Kabupaten Sidoarjo', 'Biro Administrasi Perekonomian', 'Jl. Pahlawan No. 110 Surabaya', '08563546667', 'devis.roekojatim@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (119, 73, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (120, 74, 'Rifaldi Majid', 'Jl. Cempaka Putih Tengah XII No. 17 Jakarta Pusat', 'Majelis Upaya Kesehatan Islam Seluruh Indonesia (MUKISI)', 'Jl. Cempaka Putih Tengah VI/2A, Jakarta Pusat', '085343245314', 'rifaldimajid@gmail.com ');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (121, 75, 'Rochmat Aldy Purnomo', 'Jalan Pramuka nomor 45 (depan perpustakaan IAIN Ponorogo) Ponorogo', 'Universitas Muhammadiyah Ponorogo', 'Jalan Budi Utomo Nomor 10 Ponorogo / akademik@umpo.ac.id', '085298254709', 'rochmataldy93@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (122, 76, 'Edi Murdiyanto,SH.,MM', 'Jl. Ayani No. 07 Rt. 04 Rw.01 Desa Kesamben Kec Kesamben Kabupaten Blitar', 'Universitas Islam Kediri', 'Jl. Sersan Suharmaji No. 38 Manisrenggo Kec. Kota Kediri, Kediri Jawa Timur 64128', '082234243601', 'edimurdiyanto2000@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (123, 76, 'Agus Athori,SE,.MM', 'Jl. Anyelir No.60 Rt.09 Rw. 14 Tulungrejo Pare Kediri', 'Universitas Islam Kadiri', 'Jl. Sersan Suharmaji No. 38 Manisrenggo Kec. Kota Kediri, Kediri Jawa Timur 64128', '081330205437', 'athoriagus@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (124, 77, 'TRI RATNAWATI', 'Perum. YKP Blok MA IM No.24 Rungkut Surabaya', 'Universitas 17 Agustus 1945 Surabaya', 'Jl. Semolowaru 45 Surabaya', '08123260627', 'tri.wdhidayat@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (341, 204, 'Kholifatunahdliyah', 'Jalan Karang Menjangan 3', 'Universitas Airlangga', 'Jalan Airlangga 4-6 Surabaya', '085732132683', 'kholifatun.nahdia09@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (125, 77, 'FATMA ROHMASARI', 'Jl. Bratang Gede 3-i No. 16 Surabaya', 'Universitas 17 Agustus 1945 Banyuwangi', 'Jl. Laksda Adi Sucipto, Taman Baru, Kecamatan Banyuwangi, Kabupaten Banyuwangi - Jawa Timur ', '081231146630', 'fatma_rsari@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (126, 77, 'I NYOMAN LOKAJAYA', 'Jl. Semolowaru 45 Surabaya', 'Universitas 17 Agustus 1945 Surabaya', 'Jl. Semolowaru 45 Surabaya', '081330184345', 'nyomanlokajaya@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (127, 78, 'Madha Adi Ivantri', 'Jalan Kuningan Blok F/17 Karangmalang-Catur Tunggal, Depok Sleman, 55281', 'Sekolah Pascasarjana Universitas Gadjah Mada', 'l. Teknika Utara, Pogung, Sleman, Yogyakarta, 55281', '082233663190', 'madha_adi@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (128, 79, 'Herman Palani', 'Asrama PPSDMS, Jl. Kaliurang No.45, Sinduharjo, Ngaglik, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55581', 'Universitas Gadjah Mada', 'Bulaksumur, Caturtunggal, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281', '081315512508', 'herman.palani@mail.ugm.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (129, 79, 'Handoko', ' Jl.Kopi, Desa Ngoran, RT.03/03, Kecamatan Nglegok, Kab. Blitar, Jawa Timur.', 'Universitas Gadjah Mada', 'Bulaksumur, Caturtunggal, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281', '082233889248', 'Handokokoko18@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (130, 80, 'Tri Cahyono', 'Jl Aries Munandar 3/840A', 'Universitas Brawijaya', 'Jl Aries Munandar 3/840A', '85646530316', 'cahyoo2007@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (131, 80, 'Anas Nurhidayah', 'Jl. MT Haryono 165 Malang, 65145', 'Universitas Brawijaya', 'Jl. MT Haryono 165 Malang, 65145', '87755892372', 'anasnurhidayah@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (132, 80, 'Dwi Ardy Sugiyono', 'Jl. MT Haryono 165 Malang, 65145', 'Universitas Brawijaya', 'Jl. Mt Haryono 165 Malang, 65145', '81233912699', 'dwi.ardys@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (133, 81, 'Handy Aribowo', 'Jalan Ikan Kerapu No.25 Tambak Rejo Indah Waru Sidoarjo', 'STIE IBMT Surabaya', 'Jalan Raya Kupang Baru No.8', '087853134449', 'handy_wita@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (134, 81, 'Alexander Wirapraja', 'citraraya vila taman telaga II blok TJ9 no 15', 'STIE IBMT SURABAYA', 'raya kupang baru no 8', '085648580815', 'awirapraja85@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (135, 81, 'YUDITHIA DIAN PUTRA', 'Jl. MERPATI 87 B', 'STIE IBMT SURABAYA', 'Jl. RAYA KUPANG BARU 8 SURABAYA', '081233991087', 'dith87@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (136, 82, 'Ronald Tehupuring', 'Klebengan F4.B
Yogyakarta', 'Universitas Gadjah Mada', 'Jln. Nusantara Bulaksumur 
Kampus UGM, Yogyakarta 55281', '085254069295', 'ronaldtehupuring@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (137, 83, 'Ronald Tehupuring', 'Klebengan F4B
Yogyakarta', 'Universitas Gadjah Mada', 'Jln. Nusantara Bulaksumur 
Kampus UGM, Yogyakarta 55281', '085254069295', 'tehupuringronald@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (138, 84, 'Dr. Lilia Pasca Riani, M.Sc.', 'Jl. Gereja No. 12 RT 01 RW 02 Desa Wonoasri 
Kecamatan Grogol Kabupaten Kediri', 'Universitas Nusantara PGRI Kediri', 'Jl. KH. Achmad Dahlan No. 76 Mojoroto
Kota Kediri', '081335522632', 'liliapasca@unpkediri.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (139, 85, 'FARIDA STYANINGRUM, S.Pd., M.Pd', 'TLOBONG RT 02 RW 09 SIDOHARJO, POLANHARJO, KLATEN 57474', 'UNIVERSITAS PGRI MADIUN', 'JL. SETIA BUDI NO 85 MADIUN', '085642131511', 'styaningrumfarida@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (140, 86, 'Dwi Ardy Sugiono, SE', 'Desa Watugolong 14/06 Kec. Krian, Kab Sidoarjo ', 'Universitas Brawijaya Malang', 'Jalan Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145', '081233912699', 'dwi.ardys@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (141, 86, 'Alfi Muflikhah Lestari, SE', 'Jalan Veteran 6 B Malang', 'Universitas Brawijaya Malang', 'Jalan Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145', '085649419958', 'alfie.tary@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (142, 87, 'KATHERIN DAINAR', 'JALAN ANGGRAINI V/26 PERUMAHAN KBN NO 26,KECAMATAN MOJOROTO, KOTA KEDIRI, JAWA TIMUR', 'POLITEKNIK NEGERI MALANG', 'Jl. Soekarno Hatta Malang No.9, Jatimulyo, Kec. Lowokwaru, Kota Malang, Jawa Timur', '085649026810', 'katherindaniar@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (143, 87, 'Sasi Utami', 'JALAN ANGGRAINI V/26 PERUMAHAN KBN NO 26,KECAMATAN MOJOROTO, KOTA KEDIRI, JAWA TIMUR', 'Universitas Kadiri', ' Jl. Selomangleng No. 1,  Mojoroto, Kota Kediri, Jawa Timur', '082141437585', 'sasiutami@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (144, 88, 'Haryati Setyorini', 'IEU - Surabaya
Jl. Raya dukuh Kupang No 157 Surabaya', 'STIE- IEU', 'Jl. Raya Dukuh Kupang 157 Surabaya', '031 5619577/ 08123210350', 'setyo_ieu@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (145, 89, 'Firsty Dzanurrahmana Zein', 'Pucangan 3 / 113 E Surabaya 60282', 'Universitas Airlangga', 'Airlangga 4-6 Surabaya', '082233351766', 'firstydzanurrahmana@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (146, 89, 'Febby Rahmatullah Masruchin', 'Padmosusastro 102 B Surabaya 60241', 'Institut Teknologi Sepuluh Nopember Surabaya', 'Kampus ITS Sukolilo Surabaya 60111', '081334735968', 'febbyrahmatullah@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (147, 90, 'Febby Rahmatullah Masruchin', 'Padmosusastro 102 B Surabaya 60241', 'Institut Teknologi Sepuluh Nopember Surabaya', 'Kampus ITS Sukolilo Surabaya 60111', '081334735968', 'febbyrahmatullah@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (148, 90, 'Firsty Dzanurrahmana Zein', 'Pucangan 3 / 113 E Surabaya 60282', 'Universitas Airlangga', 'Airlangga 4-6 Surabaya 60285', '082233351766', 'firstydzanurrahmana@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (149, 91, 'ALIF ENDY PAMUJI', 'Rt. 02 Rw.03 Menampu- Gumukmas-Jember', 'UIN Sunan Ampel Surabaya', 'Jalan. A Yani 117 Surabaya', '085646852345/085257785188', 'alifugm@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (150, 91, 'ANA TONI ROBY CANDRA YUDHA', 'Jl. Medayu Utara Gang 23/ No.41-A, Kelurahan Medokan Ayu, Kecamatan Rungkut,Surabaya
60295', 'UIN Sunan Ampel Surabaya', 'Jalan. A. Yani 117 Surabaya', '085645205571', 'anatoniroby@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (151, 92, 'Arimurti Kriswibowo S.IP', 'Jl.Lesanpura no.498 Teluk Purwokerto', 'Mahasiswa Pascasarjana MIA, Universitas Jenderal Soedirman Purwokerto', 'Jl.Prof. Dr. H. R. Boenyamin Purwokerto 53122', '087838404858', 'arimurti.kriswibowo@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (152, 93, 'Eko Fajar Cahyono ', 'Departemen Ekonomi Syariah 
Fakultas Ekonomi dan Bisnis 
Universitas Airlangga
Jalan Airlangga Nomer 4 Gubeng 
Surabaya ', 'Universitas Airlangga ', 'Jalam Airlangga Nomer 4 Gubeng Surabaya ', '085645454959', 'ekofajarc@feb.unair.ac.id ');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (153, 94, 'Swastika Maya Pramesti S.H.', 'Jl.Lesanpura no.498 Teluk Purwokerto, Jawa Tengah', 'Universitas Gadjah Mada', 'Jl.Sosio Yustisia no 1 Bulaksumur, Sleman', '085526003331', 'mamezti@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (154, 94, 'Arimurti Kriswibowo S.IP', 'Jl.Lesanpura no.498 Teluk Purwokerto, Jawa Tengah', 'Magister Ilmu Administrasi, Universitas Jenderal Soedirman', 'Jl.HR Bunyamin Purwokerto 53122', '087838404858', 'arimurti.kriswibowo@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (156, 96, 'Susyadi', 'IEU - SURABAYA
Jl. Raya Dukuh Kupang 157 SURABAYA', 'STIE - IEU SURABAYA', 'Jl. Raya Dukuh Kupang 157 SURABAYA', '031 5629577 / 081313799899', 'susyadi@ieu.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (157, 96, 'Haryati Setyorini', 'IEU Surabaya
Jl. Raya Dukuh Kupang 157 Surabaya', 'STIE - IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 Surabaya', '031 5619577 / 08123210350', 'setyo_ieu@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (158, 97, 'ARIF KATHON SUBHEKTI', 'Jl. Karangmenjangan gang 8 buntu nomor 2 Surabaya

', 'UNIVERSITAS AIRLANGGA', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Kota SBY, Jawa Timur 60115, Indonesia', '085707815814', 'arifkathonsubhekti@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (159, 97, 'MUTIARA RAMADHANI PUTRI', 'Jl. Karangwismo I no. 05, Surabaya', 'UNIVERSITAS AIRLANGGA', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Kota SBY, Jawa Timur 60115, Indonesia', '0812-3570-1771', 'mutiararamadhanip@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (160, 97, 'TRYAS SUKMANING SAKTI', 'Jl. Gubeng Airlangga V No. 24B', 'UNIVERSITAS AIRLANGGA', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Kota SBY, Jawa Timur 60115, Indonesia', '085 746 206 296', 'tryassukma@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (161, 98, 'Amirusholihin', 'Jl. Pandega Asih III blok F no.2 , kec. Depok, kab. Sleman Yogyakarta', 'Universitas Gadjah Mada', 'Jl. Sosio Humaniora No.1, Caturtunggal, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281, Indonesia', '085755303027', 'amirusolihin@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (162, 98, 'Listiono', 'Lab Mini Banking Fakultas Agama Islam UMY, Jl. Lingkar Selatan, Tamantirto, Kasihan, Bantul, Yogyakarta', 'Universitas Gadjah Mada', 'Jl. Sosio Humaniora No.1, Caturtunggal, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281, Indonesia', '081325390349', 'listio.tl@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (163, 99, 'MOHAMAD MUHDLOR ABIDIN', 'JANGKUNGAN 1/27', 'UNIVERSITAS AIRLANGGA', 'JL. MULYOREJO SURABAYA', '085936179698', 'MMUHDLORA@GMAIL.COM');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (164, 100, 'Arzakul Nur Kholis', 'dusun mojosari RT 02 RW 01 KEC. Kepanjen KAB. Malang', 'Universitas Negeri Malang', 'Jl. Semarang 5 Malang 65145 Jawa Timur Indonesia', '089608229858', 'Arzakul295@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (165, 101, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (166, 102, 'Aisyah Aminy', 'Jl. Sunan Prapen II AC No.6 Gresik', 'Dinas Koperasi, UKM Provinsi Jawa Timur', 'Jl. Raya Bandara Juanda No.22 Sidoarjo', '082233024692', 'aisyah.pns@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (167, 103, 'MOHAMAD MUHDLOR ABIDIN', 'JANGKUNGAN 1/27', 'UNIVERSITAS AIRLANGGA', 'JL. MULYOREJO SURABAYA', '085936179698', 'MMUHDLORA@GMAIL.COM');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (168, 104, 'Mohamad Ary Budi Yuwono', 'Komp. Joglo Baru Blok B1
Jakarta Barat, DKI Jakarta', 'Universitas Mercu Buana Jakarta dan Universitas Padjadjaran Bandung', 'Jl. Meruya Selatan, Jakarta Barat', '08161405011', 'ary_yuwono@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (169, 104, 'Baby Amelia Fransesca S', 'Komp. Legok Permai Blok G1/C11, Legok
Kabupaten Tangerang, Prov. Banten', 'Universitas Padjadjaran, Bandung', 'Jl. Dipati Ukur no 34 Bandung, Jawa Barat', '08151606565', 'babyafs@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (170, 105, 'MOHAMAD MUHDLOR ABIDIN', 'JANGKUNGAN 1/27', 'UNIVERSITAS AIRLANGGA', 'JL. MULYOREJO SURABAYA', '085936179698', 'MMUHDLORA@GMAIL.COM');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (171, 106, 'Vina Septiana Permatasari', 'Jalan Bronggalan II no 19 (207)', 'Sekolah Pascasarjana Universitas Airlangga', 'Jalan Airlangga no 4 Surabaya', '083851919319', 'vina.septiana.p@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (172, 107, 'Achmad Sjafii', 'FEB ', 'Airlangga', 'Jl. Airlangga', '08563631236; 081331060014', 'achmadsjafii@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (173, 107, 'Doris Padmini selvaratnam', 'Fakulti Ekonomi dan Pengurusan', 'Univ.Kebangsaan Malaysia', 'FEP-UKM, Bangi selangor', '+60196682726', 'dorisrobbert@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (174, 107, 'Fikriya Shofiyah', '', '', '', '+6285732355828', 'f.shofi@ymail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (175, 108, 'Shofwan', 'Jl. Taman Raden Intan Kav. 197 Arjosari Blimbing Malang 65126', 'Universitas Brawijaya', 'Jl. Veteran Malang', '081235781697', 'shofwan1705@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (176, 109, 'Mohtar Rasyid', 'Jl. K. Lemah Duwur 30 A Bangkalan 69112', 'Universitas Trunojoyo Madura', 'Jl, Raya Telang PO BOX 2 Kamal', '08563475958', 'mohtar.rasyid@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (177, 110, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (178, 111, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (179, 112, 'Ratna Indrayanti', 'Lembaga Demografi FEB UI, Gedung Nathanael Iskandar Lt 2&3, Kampus UI Depok', 'Lembaga Demografi FEB UI', 'Gedung Nathanael Iskandar Lt 2&3, Kampus UI Depok', '08121649457', 'ratna.indrayanti@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (180, 113, 'Anton Abdul Fatah, SAB., MPA.', 'Jalan Aster I No. 2 RT 03 RW 14 Jayaraga, Tarogong Kidul, Garut, Jawa Barat, Indonesia, 44151', 'University of Kentucky, USA', '140 Patterson Drive, Lexington, KY, 40506, USA', '081931445984', 'anton.fatah@uky.edu');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (181, 114, 'Bernad Mahardika Sandjojo', 'Sutorejo Prima Selatan PE 2', '', '', '085299981817', 'bernad.yasa@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (182, 114, 'Made Gitanadya Ayu Aryani', 'Bendul Merisi Utara I No 8', '', '', '08114320904', 'mgitanadya@ymail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (183, 115, 'INDRA SANTOSA, MM', 'Jl. Raya Dukuh Kupang 157 B 60255, Surabaya', 'Sekolah TInggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B 60255, Surabaya', '0315665654/088803210309 ', 'indra.santosa@ieu.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (184, 115, 'Ir. S. Haryo Santosa, SE, MM', 'Jl. Raya Dukuh Kupang 157 B 60255, Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B 60255, Surabaya', '0315665654/ 08121725246', 'haryo.santosa@ieu.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (185, 116, 'Nurareni Widi Astuti', '', 'Bappeda Prov. Jawa Timur', 'Jl Pahlawan no. 102-108 Surabaya', '08123044890', 'renny_box@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (186, 116, 'Arina Nur Fauziyah', '', 'Dinas Koperasi dan UKM Prov Jawa Timur', 'Jl Raya Bandara Juanda no. 22 Sidoarjo', '081216174704', 'fauziyah.arin@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (187, 117, 'ARIZ APRILIA', 'Fakultas Ekonomika dan Bisnis, Universitas Gadjah Mada
Alamat: Jln. Nusantara Bulaksumur Kampus UGM, Yogyakarta 55281, Indonesia', 'Universitas Gadjah Mada', 'Fakultas Ekonomika dan Bisnis, Universitas Gadjah Mada
Alamat: Jln. Nusantara Bulaksumur Kampus UGM, Yogyakarta 55281, Indonesia', '085608630785', 'arizapril50@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (188, 118, 'Ir. S. Haryo Santosa, SE, MM', 'Jl. Raya Dukuh Kupang 157 B Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B Surabaya', '0315665654 / 08121725246', 'haryo.santosa@ieu.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (189, 118, 'Ika Meigawati, MM', 'Jl. Raya Dukuh Kupang 157 B Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B Surabaya', '0315665654/0818378763', 'waterbabyjanuseel@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (190, 119, 'ANTON ABDUL FATAH, SAB., MPA.', 'Jalan Aster I No. 2 RT 03 RW 14, Jayaraga, Tarogong Kidul, Garut, Jawa Barat, Indonesia, 44151', 'University of Kentucky, USA', '140 Patterson Dr, Lexington, KY 40506, USA', '081931445984', 'anton.fatah@uky.edu');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (191, 120, 'Dr. H. Setyorini, MM', 'Jl. Raya Dukuh Kupang 157 B Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B Surabaya', '0315665654 / 081-232-10350', 'setyo_ieu@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (192, 120, 'Ir. S. Haryo Santosa, SE, MM', 'Jl. Raya Dukuh Kupang 157 B Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B Surabaya', '0315665654/08121725246', 'haryo.santosa@ieu.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (193, 121, 'Hansen Tandra', 'Jalan Siam No 166', 'Universitas Tanjungpura', 'Jl. Prof. Dr. H. Hadari Nawawi, Bansir Laut, Pontianak Tenggara, Bansir Laut, Pontianak Tenggara, Kota Pontianak, Kalimantan Barat ', '087819461239', 'hansentandra7@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (194, 121, 'Gristia Aldilla', 'Jalan Karet Komplek Surya Kencana 1 Blok E No 9', 'Universitas Tanjungpura', 'Jl. Prof. Dr. H. Hadari Nawawi, Bansir Laut, Pontianak Tenggara, Bansir Laut, Pontianak Tenggara, Kota Pontianak, Kalimantan Barat', '089693443983', 'gristiaaldilla@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (195, 122, 'Indra Santosa, MM', 'Jl. Raya Dukuh Kupang 157 B Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B Surabaya', '0315665654 ', 'indra.santosa@ieu.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (196, 122, 'Susyadi, SE, MM', 'Jl. Raya Dukuh Kupang 157 B Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B Surabaya', '0315665654 ', 'susyadi@ieu.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (197, 123, 'Ir. S. Haryo Santosa, SE, MM', 'Jl. Raya Dukuh Kupang 157 B Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B Surabaya', '0315665654 /', 'haryo.santosa@ieu.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (198, 123, 'Indra Santosa, MM', 'Jl. Raya Dukuh Kupang 157 B Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B Surabaya', '0315665654 ', 'indra.santosa@ieu.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (199, 124, 'Indra Santosa, MM', 'Jl. Raya Dukuh Kupang 157 B Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B Surabaya', '0315665654 / 088803210309', 'indra.santosa@ieu.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (200, 124, 'Tuty Haryanti, MM, MPd', 'Jl. Raya Dukuh Kupang 157 B Surabaya', 'Sekolah Tinggi Ilmu Ekonomi IEU Surabaya', 'Jl. Raya Dukuh Kupang 157 B Surabaya', '0315665654 / 081330235806', 'tutyhariyanti1978@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (201, 125, 'Didik Eko D', 'Jl. Basuki Rahmad No. 98 - 104 Surabaya', 'PT Bank Pembangunan Daerah Jawa Timur Tbk', 'PT Bank Pembangunan Daerah Jawa Timur Tbk', '031-5310090 ext 416/08179396879', 'didik_eko@bankjatim.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (202, 125, 'Catur Adi Prasetya', 'Jl. Basuki Rahmad No. 98 - 104 Surabaya', 'PT Bank Pembangunan Daerah Jawa Timur Tbk', '', '031-5310090 ext 201/08170471308', 'caturadi1322@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (203, 125, 'Ita Sucihati', 'Jl. Basuki Rahmad No. 98 - 104 Surabaya', 'PT Bank Pembangunan Daerah Jawa Timur Tbk', 'PT Bank Pembangunan Daerah Jawa Timur Tbk', '031-5310090 ext 201/ 085655803499', 'sucihatiita@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (204, 126, 'Yayu Yuliana', 'Dsn. Cibareubeu rt/rw 02/08 Ds. Sukamanah, Kec. Jatinunggal  Kab.Sumedang,  Jawa Barat ', 'Universitas Pendidikan Indonesia', 'Jln. Setiabudhi No. 229 Bandung', '083825971528', 'ayuyyliana@student.upi.edu');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (205, 126, 'Anisa Putri Utami', 'Dsn. Cipaku Girang rt/rw 03/04  Cipaku, Kce. Cipaku Kab.Ciamis,  Jawa Barat ', 'Universitas Pendidikan Indonesia', 'Jln. Setiabudhi No. 229 Bandung', '085962613092', 'anisaputriutm@student.upi.edu');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (206, 126, 'Adelia Novianti', 'Cilimus rt/rw 02/08 Kel. Isola, Kec. Sukasari  Kab.Bandung,  Jawa Barat ', 'Universitas Pendidikan Indonesi', 'Jln. Setiabudhi No. 229 Bandung', '0895334709894', 'adelianovianti@student.upi.edu');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (207, 127, 'Ikhwan Safa''at', 'Gg. Mbah Malim No. 21, Rt.01/Rw.04, Kiaracondong, Bandung Jawa Barat.', 'Institut Pertanian Bogor', 'Jl. Kamper, Bogor, Indonesia', '08117305638', 'ikhwansafaat@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (208, 127, 'Yayum Kumai', 'Gang.Untung, Desa Sukorejo, Kecamatan Bojonegoro, Kabupaten Bojonegoro, Jawa Timur', 'Universitas Gadjah Mada', 'Bulaksumur, Kecamatan Sleman, DIY', '081214264813', 'yayumkumai@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (209, 128, 'Astri Furqani, SE, M.Ak', 'Jl. Antariksa No. 20 Desa Pabian Kec. Kota Kab. Sumenep', 'Universitas Wiraraja Sumenep', 'Jl Raya Sumenep Pamekasan Km. 5 Desa Patean Kab. Sumenep', '081912253703', 'as3oke_dech@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (210, 128, 'Fatah Firdaus, ST', 'jl. Antariksa No. 20 Desa Pabian Kec. Kota Kab. Sumenep', 'Universitas Trunojoyo Madura', 'Jl Raya Telang, Kec. Kamal, Bangkalan, Telang, Kamal, Madura, Jawa Timur', '08179301317', 'firdha_caem@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (211, 129, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (212, 130, 'Katherin Daniar', 'Jalan Anggraini V/26 Perum KBN, Desa Sukorame, Kecamata Mojoroto, Kota Kediri', 'POLITEKNIK NEGERI MALANG', 'Jl. Soekarno-Hatta No.9, Jatimulyo, Kec. Lowokwaru, Kota Malang, Jawa Timur', '085649026810', 'katherindaniar@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (213, 130, 'Rizqi Khoirunisa', 'Jalan MT. Hariyono no 485 Kota Malang, Jawa Timur', 'POLITEKNIK NEGERI MALANG', 'Jl. Soekarno-Hatta No.9, Jatimulyo, Kec. Lowokwaru, Kota Malang, Jawa Timur', '081519494335', 'khoirunisarizqi@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (214, 130, 'Desya Annisa Putri Hardianto', 'Perum. Pondok Mutiara blok I no 6,Kota Malang, Jawa Timur', 'POLITEKNIK NEGERI MALANG', 'Jl. Soekarno-Hatta No.9, Jatimulyo, Kec. Lowokwaru, Kota Malang, Jawa Timur', '081233020974', 'desyannsa@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (215, 131, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (216, 132, 'ARIZ APRILIA', 'Jln. Nusantara Bulaksumur Kampus UGM, Yogyakarta 55281, Indonesia', 'UNIVERSITAS GADJAH MADA', 'Jln. Nusantara Bulaksumur Kampus UGM, Yogyakarta 55281, Indonesia', '085608630785', 'arizapril50@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (217, 132, 'PANJI TIRTA NIRWANA PUTRA', 'Jalan Kalimantan No. 37, Kampus Tegalboto, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', 'UNIVERSITAS JEMBER', 'Jalan Kalimantan No. 37, Kampus Tegalboto, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', '085649324341', 'panjitirta63@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (218, 133, 'Panji Tirta Nirwana Putra', 'Jurusan Ilmu Ekonomi dan Studi Pembangunan, Fakultas Ekonomi dan Bisnis, Universitas Jember, Indonesia Alamat: Jl. Kalimantan No. 37, Jember, Jawa Timur, Indonesia ? Kode Pos (68121), Tel. (+62)85649324341, e-mail: panjitirta63@gmail.com', 'Universitas Jember', 'Jl. Kalimantan No. 37, Jember, Jawa Timur, Indonesia ? Kode Pos (68121)', '085649324341', 'panjitirta63@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (219, 133, 'Achmad Fawaid Hasan', 'Jurusan Ilmu Ekonomi dan Studi Pembangunan, Fakultas Ekonomi dan Bisnis, Universitas Jember, Indonesia Alamat: Jl. Kalimantan No. 37, Jember, Jawa Timur, Indonesia ? Kode Pos (68121), Tel. (+62)85649324341, e-mail: panjitirta63@gmail.com', 'Jl. Kalimantan No. 37, Jember, Jawa Timur, Indonesia ? Kode Pos (68121)', 'Universitas Jember', '082302330055', 'fawaidunej@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (220, 134, 'Moh. Ubaidillah', 'Jl. Cemapaka no. 19 RT/RW 01/03 Mangkujayan Magetan', 'Universitas PGRI Madiun', 'Jl. Setia Budi no. 85 madiun', '085200470384', 'moh.ubaidillah8181@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (221, 135, 'ABDULRAHMAN TARESH A.', '', 'UNAIR. FEB', '', '081249179929', 'abdt713@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (222, 136, 'JUNAEDI', 'Gedung Pascasarjana Universitas Darul ''Ulum Jombang
Jl. Presiden Abdurahman Wahid 29 A Jombang', 'Universitas Darul ''Ulum Jombang', 'Gedung Pascasarjana Universitas Darul ''Ulum Jombang
Jl. Presiden Abdurahman Wahid 29 A Jombang', '08121367354', 'jun_pus@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (223, 137, 'Ir. Yan Suhirmanto, M.H', 'Citra Harmoni Kav A1 / 55 Taman Sidoarjo Jawa Timur', 'Universitas Airlangga', 'Jl. Airlangga 4-6 Surabaya', '0811305915', 'yansuhirmanto@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (224, 137, 'Handryan Erwan Ering', 'Lingkungan Kedungsari RT 1 / III Kelurahan Gunung Gedangan, Kecamatan Magersari - Kota Mojokerto', 'Universitas Airlangga', 'Jl. Airlangga 4-6 Surabaya', '08124577185', 'Handryan@bjtiport.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (225, 137, 'Zakaria Rachman', 'Jl. Karang Klumprik Selatan 4 / 20 Surabaya', 'Universitas Airlangga', 'Jl. Airlangga 4-6 Surabaya', '082230669944', 'zakaria.rachman05@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (227, 139, 'Fajar Surya Ari Anggara', 'Jl. Raya Siman Km 6 Kecamatan Siman Ponorogo Jawa Timur', 'Universitas Darussalam Gontor', 'Jl. Raya Siman Km 6 Kecamatan Siman Km 6 Ponorogo Jawa Timur', '081252433422', 'fajarsurya@unida.gontor.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (228, 140, 'Rudy Prietno', 'Jl. Kapten P Tandean Kav 12-14 A, Jakarta 12790', 'Dokter Data', 'Jl. Kaliurang Km 13, Gang Besi Sleman, Yogyakarta.', '081226179310', 'prietnorudy@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (229, 140, 'Mohhamad Aprialdi Rizky Pratama ', 'jl danau sembuluh C1A, Malang 65139', 'Institut Teknologi Sepuluh Nopember', 'Kampus ITS, Jalan Raya ITS, Keputih, Sukolilo, Keputih, Surabaya, Kota SBY, Jawa Timur 60117', '+62 812 3184 3784', 'mohammad.aprialdi@hotmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (230, 141, 'Chyntia Heru Woro Prastiwi, S.IP., M.Pd', 'Jalan Sersan Kusman Gg. Baru No. 5 Bojonegoro', 'IKIP PGRI Bojonegoro', 'Jalan Panglima Polim No. 46 Bojonegoro', '- / 081230070400', 'chwphi@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (231, 142, 'Zakaria Rachman', 'Jl. Karang Klumprik Selatan 4/20 Surabaya', 'Universitas Airlangga', 'Jl. Airlangga 4-6 Surabaya', '082230669944', 'zakaria.rachman05@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (232, 142, 'Handryan Erwan Ering', 'Lingkungan kedungsari  RT I/III kelurahan Gunung gedangan , Kecamatan Magersari ? Kota Mojokerto', 'Universitas Airlangga', 'Jl. Airlangga 4-6 Surabaya', '08124577185', 'handryan@bjtiport.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (233, 142, 'Ir. Yan Suhirmanto, M.H.', 'Citra Harmoni Kav A1/55 Taman Sidoarjo, Jawa Timur', 'Universitas Airlangga', 'Jl. Airlangga 4-6 Surabaya', '0811305915', 'yansuhirmanto@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (342, 205, 'Sinta Wulandari', 'Jl.Bangka Raya No.23', 'Universitas Jember', 'Jl.Kalimantan No.37', '083841798880', 'shinta.wd611@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (234, 143, 'Ariz Aprilia', 'Kaliurang Street KM 5.6 Gang Pandega Duta 2 No. 3b, Sleman, Daerah Istimewa Yogyakarta', 'Universitas Gadjah Mada', 'Jl. Nusantara Bulaksumur, Caturtunggal, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281', '085608630785', 'arizapril50@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (235, 143, 'Panji Tirta Nirwana Putra', 'Jurusan Ilmu Ekonomi dan Studi Pembangunan, Fakultas Ekonomi dan Bisnis, Universitas Jember, Indonesia Alamat: Jl. Kalimantan No. 37, Jember, Jawa Timur, Indonesia ? Kode Pos (68121)', 'Universitas Jember', 'Jurusan Ilmu Ekonomi dan Studi Pembangunan, Fakultas Ekonomi dan Bisnis, Universitas Jember, Indonesia Alamat: Jl. Kalimantan No. 37, Jember, Jawa Timur, Indonesia ? Kode Pos (68121)', '085649324341', 'panjitirta63@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (236, 144, 'Ridan Muhtadi', 'Jl. Seruni Gg 02 No 08 Pamekasan', 'Sekolah Pascasarjana, Universitas Airlangga', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Surabaya, Indonesia 60115', '085330148666', 'ridanmuhtadi@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (237, 144, 'Moh. Arifin', 'Jl Kardu Desa Jaddih Socah Bangkalan', 'Sekolah Pascasarjana, Universitas Airlangga', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Surabaya, Indonesia 60115', '085707830306', 'arifin.dzulqornaen@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (238, 145, 'Rendra Kurnia Wardana', 'Jl. Danau Sarangan Atas F6-A25, Kelurahan Sawojajar, Kecamatan Kedungkandang, Kota Malang 65139', 'Universitas Padjadjaran', 'Jl. Dipati Ukur No. 46
Bandung - 40132', '081235401632', 'valerindra230989@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (239, 146, 'Rizqatus Sholehah', 'Simo Gunung 1/16, Surabaya', 'Universitas Airlangga', 'Jl. Airlangga No. 4, Surabaya ', '085236835625', 'rizqatuss@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (240, 146, 'Yunita A''yunil Husna', 'Gubeng Kertajaya VII I No. 08, Surabaya', 'Universitas Airlangga', 'Jl. Airlangga No. 4, Surabaya ', '089531580423', 'yunitahusna19@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (241, 147, 'Asshaumi Perdani Soedyatmika', 'Jl. Sinar Pelangi 482 Semarang 482', 'Universitas Airlangga', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Airlangga, Gubeng, Kota SBY, Jawa Timur 60115', '081216766674', 'asshaumiperdani96@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (242, 147, 'Rizal Restu Nugroho', 'Jl. Ki Mangun Sarkoro No.4, Trenggalek', 'Universitas Airlangga', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Airlangga, Gubeng, Kota SBY, Jawa Timur 60115', '085731043513', 'rizal.restu@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (243, 147, 'Yusuf Aji Wibisono', 'Jl. Mawar No.2B, Mangkujayan, Magetan', 'Universitas Airlangga', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Airlangga, Gubeng, Kota SBY, Jawa Timur 60115', '085748882006', 'yusuf.aji@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (244, 148, 'Munari Kustanto', 'Jl. Kemuning Asri BX-1, Wisma Tropodo, Waru-Sidoarjo', 'Magister Sosiologi FISIP Universitas Airlangga -- Bappeda Kabupaten Sidoarjo', 'Jl. Airlangga 4-6 Surabaya -- Jl. Sultan Agung No. 13 Sidoarjo', '08175051352', 'munarikustanto@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (245, 148, 'Hafizah Awalia', 'RT. 03 RW. 08 Lingk. Tiang Enam, Kelurahan Kuang, Kecamatan Taliwang - Sumbawa Barat', 'Magister Sosiologi FISIP Universitas Airlangga', 'Jl. Airlangga 4-6 Surabaya', '087863864632', 'hafizahawalia030392@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (246, 149, 'Muhammad Mufli', 'Jl Kertopamuji No 10 Malang ', 'Universitas Brawijaya', 'Jl Veteran Malang', '082337777044', 'mufli.ub@gmail.com ');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (247, 150, 'Rifai Afin', 'Jalan Simo Gunung 1 No 18 A Surabaya', 'Universitas Trunojoyo Madura', 'Jalan Raya Telang PO BOX 2 Kamal, Bangkalan, MAdura', '6281938650018', 'rifaiafin22@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (248, 151, 'Lindiawati', 'Bendul Merisi Permai H2 Surabaya', 'STIE Perbanas Surabaya ', 'Jl. Nginden Semolo 34-36 Surabaya', '031-8434104/ 0817385144', 'lindi@perbanas.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (249, 152, 'Dr. Nurul Badriyah, SE., ME.', 'Graha Dewata Estate MM7/22 Malang', 'Universitas Brawijaya Malang', 'Jl, MT Haryono 165 Malang 65145', '081335261753', 'akademiknurul@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (250, 152, 'Dra. Marlina Ekawaty, MSi., Ph.D', 'Puri Cempaka Putih I C/6 Malang', 'Universitas Brawijaya Malang', 'Jl. MT Haryono 165 Malang 65145', '085646625700', 'marlina_ekawaty@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (251, 152, 'Shofwan, SE., MSi.', 'Jl. Taman Raden Intan Kav 197 Malang', 'Universitas Brawijaya Malang', 'Jl. MT Haryono 165 Malang 65145', '+62 81235781697', 'shofwan1705@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (252, 153, 'Felia Novianti', 'RT/RW : 02/05, Dusun Rampaksari, Desa Tugusari, Kec. Bangsalsari - Jember', 'Universitas Jember', 'Jalan Kalimantan No. 37, Kampus Tegalboto, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', '085746676432', 'felia.novianti26@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (253, 153, 'Shella Elly Sritrisniawati', 'Alamat	Jalan Nias II No. 11 Sumbersari, JEMBER', 'Universitas Jember', 'Jalan Kalimantan No. 37, Kampus Tegalboto, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', '081216063207', 'shellasritrisniawati@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (254, 154, 'Abd Hannan', 'Ds. Palengaan Daja, Kecamatan Palengaan, Kabupaten Pamekasan', 'Universitas Airlangga', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Airlangga, Gubeng, Kota SBY, Jawa Timur 60115, Indonesia', '081703803541', 'hannan.taufiqi@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (255, 155, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (256, 156, 'Fitri Rusdianasari', '', 'Universitas Jember', 'Jl. Kalimantan No. 37, Jember, Jawa Timur, Indonesia - Kode Pos (68121)', '085 257 559 012', 'fitrirusdiana14@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (257, 157, 'A.A GDE SATIA UTAMA', 'Airlangga 4-6', 'UNIVERSITAS AIRLANGGA', 'Airlangga 4-6', '0817339278', 'gde.agung@feb.unair.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (258, 157, 'Pending Puji', 'Jalan Wijaya Kusuma No 113 Giri, Banyuwangi', 'Universitas Airlangga', 'Jalan Wijaya Kusuma No 113, Giri, Banyuwangi', '085730533120', 'pendingpuji01@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (259, 158, 'Brian Bachrul Wiranusa', 'Jalan MT Haryono Gang 17 No 61A, Lowokwaru, Kota Malang', 'Universitas Brawijaya', 'Jurusan Manajemen, Fakultas Ekonomi dan Bisnis
Jalan Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145, Indonesia', '089617020751', 'brianwiranusa@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (260, 159, 'Nanda Marga Retna Cindy Pujiharto', 'Jl. Dharmawangsa 8, no 18, Sby', 'Universitas Airlangga', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Airlangga, Gubeng, Kota SBY, Jawa Timur', '083849159774', 'nanmarcp@gmail.com ');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (261, 159, 'Mochammad Bachrul Ulum Fanani', 'Desa Sambibulu Kecamatan Taman', 'Universitas Airlangga', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Airlangga, Gubeng, Kota SBY, Jawa Timur', '083832170984', 'mochbachrul@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (262, 159, 'Muhammad Ruliszar', 'Jl. Ampel Kesumba Pasar no. 21 Surabaya', 'Universitas Airlangga', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Airlangga, Gubeng, Kota SBY, Jawa Timur', '082245316003', 'muhammadruliszar23@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (263, 160, 'Nila Hiliyah Yusuf', 'Jl Wonosari VII No. 3 Surabaya', 'Universitas Negeri Surabaya', 'Jl. Ketintang Surabaya', '081230582747', 'nila25hiliyah@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (264, 160, 'Dewi Siti Sendari', 'Kalilom Lor Indah Melati 1/50A Surabaya', 'Universitas Negeri Surabaya', 'Jl. Ketintang Surabaya', '082331143136', 'dewisitisendari@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (265, 160, 'Nisak Nur Fadillah', 'Jlopo Tebel Bareng Jombang', 'Universitas Negeri Surabaya', 'Jl. Ketintang Surabaya', '089667734530', 'nisakazura@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (266, 161, 'Faqih Adam', 'Asrama Beasiswa Pemimpin Bnagsa Jalan Manteron No.18 RT04 RW08 Kel. Sukaluyu Kec. Cibeunying Kaler Bandung 40123', 'Universitas Pendidikan Indonesia', 'Jl. Setiabudi No. 229 Gd. FPIPS, UPI, Isola, Sukasari, Sukasari Bandung, Jawa Barat 40154', '088218929004', 'faqihadam88@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (267, 161, 'Egi Rahman', 'Kp. Griya Sukasari RT 001/018 Ds. Ciwidey Kec. Ciwidey Kab. Bandung
', 'Universitas Pendidikan Indonesia', 'Jl. Setiabudi No. 229 Gd. FPIPS, UPI, Isola, Sukasari, Sukasari Bandung, Jawa Barat 40154', '081932489247', 'egirahman@student.upi.edu');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (268, 161, 'sandy Irawan', 'Jl. Gegersuni No 84 A. gegerkalong Girang Bandung', 'Universitas Pendidikan Indonesia', 'Jl. Setiabudi No. 229 Gd. FPIPS, UPI, Isola, Sukasari, Sukasari Bandung, Jawa Barat 40154', '0881224035026', 'sirawan304@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (269, 162, 'Umi Thoifah Amalia', 'JL. Kusuma Wijaya, Ds. Mandung,
Kec. Wedung, Kab. Demak
', 'Universitas Negeri Semarang', 'Kampus Sekaran Gunungpati, Semarang', '08976373080', 'umithoifahamalia@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (270, 162, 'Dian Handayani', 'Rt 04/03 , Kradenan Village, Mrebet, Purbalingga, Central Java', 'Universitas Negeri Semarang', 'Sekaran Gunungpati, Semarang', '085743073748', 'dian_handayani36@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (271, 162, 'Wiji Astuti', 'Boyolali', 'Universitas Negeri Semarang', 'Sekaran Gunungpati, Semarang', '085325015234', 'Wijiastuti327@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (272, 163, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (273, 164, 'Wahyuningsari ', 'Jl. Gadung RT 06 RW 01 Ds. Kalen Kec. Kedungpring, Lamongan', 'Universitas Negeri Surabaya', 'Jl. Ketintang Surabaya', '085606402587', 'wahyuniekis@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (274, 164, 'Demara Hediana Dewi', 'Jl. Baratakaya 9/30 Surabaya', 'Jl. Ketintang Surabaya', 'Universitas Negeri Surabaya', '081252352030', 'demaradewi@mhs.unesa.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (275, 165, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (276, 166, 'Fitri Rusdiana', 'Jl. Kalimantan 37, Jember 68121, East Java, Indonesia', 'Universitas Jember ', 'Jl. Kalimantan 37, Jember 68121, East Java, Indonesia', '085257559012', 'fitrirusdiana14@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (277, 166, 'Nofita Wulansari ', 'Jl. Kalimantan 37, Jember 68121, East Java, Indonesia', 'Universitas Jember', 'Jl. Kalimantan 37, Jember 68121, East Java, Indonesia', '081231117740', 'nofita.wulansari.94@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (278, 166, 'Ida Alqurnia', 'Jl. Kalimantan 37, Jember 68121, East Java, Indonesia', 'Universitas Jember', 'Jl. Kalimantan 37, Jember 68121, East Java, Indonesia', '085732706918', 'ida.alqurnia14@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (279, 167, 'Galih Satria Mahardhika', 'Jl. Taman Kirana Surya Blok K6 No. 23, Kecamatan Solear, Kabupaten Tangerang, Banten (15730)', 'Universitas Padjadjaran', 'Jl. Raya Bandung Sumedang, Hegarmanah, Jatinangor, Kabupaten Sumedang, Jawa Barat (45363)', '085718001706', 'mahardhika.satriagalih@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (280, 167, 'Raka Achmad Inggis', 'Jl. Hasan Saputra 1 No.6, Turangga, Kota Bandung', 'Institut Teknologi Bandung', 'Jl. Ganesha No. 10, Kota Bandung', '081386789106', 'raka.achmad@sbm-itb.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (281, 168, 'Bram Adimas Wasito', 'Jl. Diponegoro No. 98 Blok C-24
Denpasar, Bali 80113', 'Universitas Surabaya', 'Jl. Raya Kalirungkut
Surabaya 60293', '081337670728', 'bramadimas@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (282, 168, 'Nikolas Wiarya Putra', '', 'Universitas Surabaya', 'Jl. Raya Kalirungkut', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (283, 169, 'Fara Dila Sandy', 'Jalan Jawa IIB No.22 Sumbersari Jember', 'Universitas Jember', 'Jl. Kalimantan No. 37', '08990537626', 'Faradilasandy9@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (284, 169, 'Rina Rosalina', 'Jalan Jawa VII No.1 Sumbersari Jember', 'Universitas Jember', 'Jl. Kalimantan No. 37', '089697824629', 'Rina.rosalina163@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (285, 170, 'Sandy Irawan', 'Jl Sersan Surip 169 A RT 03 RW 03 Kelurahan Ledeng, Desa Sukasari', 'Universitas Pendidikan Indonesia', 'Jl. Setiabudi No. 229 Gd. FPIPS, UPI, Isola, Sukasari, Sukasari Bandung, Jawa Barat 40154', '081224035026', 'sirawan304@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (286, 170, 'Egi Rahman', 'Kp. Griya Sukasari RT 001/018 Ds. Ciwidey Kec. Ciwidey Kab. Bandung
', 'Universitas Pendidikan Indonesia', 'Jl. Setiabudi No. 229 Gd. FPIPS, UPI, Isola, Sukasari, Sukasari Bandung, Jawa Barat 40154', '081932489247', 'egirahman@student.upi.edu');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (287, 170, 'Faqih Adam', 'Asrama Beasiswa Pemimpin Bnagsa Jalan Manteron No.18 RT04 RW08 Kel. Sukaluyu Kec. Cibeunying Kaler Bandung 40123', 'Universitas Pendidikan Indonesia', 'Jl. Setiabudi No. 229 Gd. FPIPS, UPI, Isola, Sukasari, Sukasari Bandung, Jawa Barat 40154', '088218929004', 'Faqihadam88@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (288, 171, 'INDA FRESTI PUSPITASARI, S.PD', 'JL. KALIURANG KM 5 Gg. SITISONYA NO. 65C RT. 011 RW. 057 BAREK, SINDUADI, MLATI, SLEMAN-YOGYAKARTA', 'UNIVERSITAS GADJAH MADA', 'JL. NUSANTARA BULAKSUMUR KAMPUS UGM YOGYAKARTA 55281', '081335218335', 'indafresti@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (289, 171, 'ARIZ APRILIA, SE', 'JL. Kaliurang KM 5.6 Gang Pandega Duta 2 No. 3b, Sleman, Daerah Istimewa Yogyakarta', 'UNIVERSITAS GADJAH MADA', 'JL. NUSANTARA BULAKSUMUR KAMPUS UGM YOGYAKARTA 55281', '085608630785', 'arizapril50@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (290, 172, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (291, 173, 'Ida Alqurnia', 'Jl. Kalimantan 37 Jember 68121- Jawa Timur, Indonesia ? Kode Pos (68121).  ', 'Universitas Jember', 'Jl. Kalimantan 37 Jember 68121- Jawa Timur, Indonesia ? Kode Pos (68121). ', '81330795525', 'ida.alqurnia14@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (292, 174, 'Yuda Andika Darmawan', 'Jl. Masjid Al Farouq 42, Kos Griya Abyaz, Kukusan, Beji, Depok, Jawa Barat (16425)', 'Universitas Indonesia', 'Kampus Universits Indonesia Depok', '081280817605', 'yudaandikadarmawan@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (293, 175, 'Mia Silvia Rahman', 'Dusun Kasengan RT/RW 002/002 Desa Kasengan Kec. Krejengan Kab. Probolinggo Jawa Timur', 'Universitas Jember', 'Jl. Kalimantan 37 Kampus Tegal Boto Jember 68121 Telp. (0331) 321784 Fax. (0331) 321784', '082338439519', 'miasilvia25@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (294, 176, 'Bram Adimas Wasito', 'Jl. Diponegoro No. 98 C-24 Denpasar, Bali 80113', 'Universitas Surabaya', 'Jl. Raya Kalirungkut Surabaya 60293', '081337670728', 'bramadimas@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (295, 176, 'Nikolas Wiarya Putra', 'Jl. Letjen Mappaoudang No. 62 Makassar, Sulawesi Selatan 90223', 'Universitas Surabaya', 'Jl. Raya Kalirungkut Surabaya 60293', '082319191319', 'nikolaswiaryaputra@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (296, 177, 'Fajar Surya Ari Anggara M.M.', 'Jl. Raya Siman Km 6 Kecamatan Siman Universitas Darussalam Gontor Ponorogo', 'Universitas Darussalam Gontor', 'Jl. Raya Siman Km 6 Kecamatan Siman Universitas Darussalam Gontor Ponorogo', '081252433422', 'fajarsurya@unida.gontor.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (297, 178, 'Irwantoro', 'Jl. Pandugo Timur VIII/29 Surabaya ', 'Balitbang Provinsi Jawa Timur', 'Jl. Gayung Kebonsari 56 Surabaya', '081931591310', 'irwanlitbangjatim@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (298, 178, 'Anggraeni Rahmasari', 'Pandugo Timur VIII/29 Surabaya', 'Universitas Bhayangkara Surabaya', 'Jl. A. Yani 114 Surabaya', '081703569117', 'anggraenirahmasari@yahoo.co.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (299, 179, 'lutfiyah alindah', 'perum Bluru Permai U-22, Sidoarjo', 'UIN Sunan Kalijaga', '', '085648125882', 'a_lindah@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (300, 180, 'Neysa Febri Anne Pribadi', 'Mulyosari Central Park DA/29, surabaya', 'Universitas Airlangga', 'Universitas Negeri Jl. Airlangga No. 4 - 6, Airlangga, Gubeng ', '082231555870', 'neysannef@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (301, 180, 'Denny Tuasela', 'Pondok Sidokare Indah Aw 15', 'Universitas Airlangga Surabaya', 'Universitas Negeri Jl. Airlangga No. 4 - 6, Airlangga, Gubeng ', '081331546567', 'dennytuasela91@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (302, 181, 'Bayu Aji', 'Lingkungan Ngempon RT 1/V Kecamatan Bergas Kabupaten Semarang', 'Politeknik Negeri Semarang', 'Jalan Prof. Sudharto Tembalang Kota Semarang', '082226009462', 'bayuaji2426@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (303, 181, 'Ahmad Fajri', 'Jl. Baskoro Raya Pesantren An-Nur Tembalang Semarang', 'Politeknik Negeri Semarang', 'Jalan Prof. Sudharto Tembalang Kota Semarang', '082226009462', 'fajriahmad13@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (304, 182, 'Zakka Farisy B', 'Keputih Surabaya', 'UNAIR', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Airlangga, Gubeng, Kota SBY, Jawa Timur 60115', '081246562062', 'zakkafarisy@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (305, 182, 'Virga Dwi Efendi', 'Denpasar, Bali', 'UNAIR', 'Jl. Airlangga No. 4 - 6, Airlangga, Gubeng, Airlangga, Gubeng, Kota SBY, Jawa Timur 60115', '082144623121', 'virgadwiefendi22@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (306, 183, 'Mia Silvia Rahman', 'Dusun Kasengan RT/RW 002/002 Desa Kasengan Kec. Krejengan Kab. Probolinggo Jawa Timur', 'Universitas Jember', 'Jl. Kalimantan 37 Kampus Tegal Boto Jember 68121 Telp. (0331) 321784 Fax. (0331) 321784', '082338439519', 'miasilvia25@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (307, 184, 'EKA ANDRI KURNIAWAN', 'KALIAJIR LOR RT 01 RW 11, KALITIRTO, BERBAH, SLEMAN, DAERAH ISTIMEWA YOGYAKARTA', 'UNIVERSITAS ISLAM NEGERI SUNAN KALIJAGA YOGYAKARTA', 'JALAN MARSDA ADISUCIPTO YOGYAKARTA', '+62 821 3394 9075', 'andrikurniawan930@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (308, 185, 'EKA ANDRI KURNIAWAN', 'KALIAJIR LOR RT 01 RW 11, KALITIRTO, BERBAH, SLEMAN, DAERAH ISTIMEWA YOGYAKARTA', 'UNIVERSITAS ISLAM NEGERI SUNAN KALIJAGA YOGYAKARTA', 'JALAN MARSDA ADISUCIPTO YOGYAKARTA', '+62 821 3394 9075', 'andrikurniawan930@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (309, 186, 'Prakuta Wijaya', 'Jl. Jojoran 1 No 48 Surabaya', 'Dinas Penanaman Modal dan Pelayanan Terpadu Satu Pintu Kota Surabaya', 'Jl. Tunjungan 1-3 lt.3 (ex siola) surabaya', '083849101004', 'prakuta.wijaya.se@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (310, 186, 'Haras Gary ', 'Jl. Karangmenjangan I no 28', 'Dinas Penanaman Modal dan Pelayanan Terpadu Satu Pintu Kota Surabaya', 'Jl. Tunjungan 1-3 lt.3 (ex siola) surabaya', '087856247771', 'garyharas@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (311, 186, 'Kurnia Hijriya Agustin', 'Jl. Bratang Gede 6 E/49 Surabaya', 'Dinas Penanaman Modal dan Pelayanan Terpadu Satu Pintu Kota Surabaya', 'Jl. Tunjungan 1-3 lt.3 (ex siola) surabaya', '089612026989', 'niakurniaagustin@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (312, 187, 'INDA FRESTI PUSPITASARI, S.PD', 'JL. MANGGAR NO. 92 SUKOREJO, KOTA BLITAR, JAWA TIMUR 66121', 'UNIVERSITAS GADJAH MADA', 'JL. NUSANTARA BULAKSUMUR KAMPUS UGM YOGYAKARTA 55281', '081335218335', 'indafresti@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (313, 188, 'Darwis Muhammad Ahrori', 'Jalan KH. Abd. Syukur, Karang Tengah, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', 'Universitas Jember', 'Jalan Kalimantan No. 37, Kampus Tegalboto, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', '+6281233841026', 'ahrorid@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (314, 188, 'Achmad Fawaid Hasan', 'Jl. Cendana Curah Cabe RT/RW 002/ 004, Gambirono, Bangsalsari, Kabupaten Jember ', 'Universitas Jember', 'Jalan Kalimantan No. 37, Kampus Tegalboto, Sumbersari, Jember, Kabupaten Jember, Jawa Timur 68121', '+6282302330055', 'fawaid@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (315, 189, 'Denny Tuasela', 'Pondok Sidokare Indah AW 15, sidoarjo', 'Universitas Airlangga', 'Universitas Negeri
Jl. Airlangga No. 4 - 6, Airlangga, Gubeng ', '081331546567', 'dennytuasela@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (316, 189, 'Neysa Febri Anne Pribadi', 'Mulyosari Central Park DA/29, surabaya', 'univeristas airlangga', 'Universitas Negeri Jl. Airlangga No. 4 - 6, Airlangga, Gubeng ', '082231555870', 'neysannef@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (317, 190, 'Imroatul Amaliyah, S.E.', 'Jl.Wonorejo Selatan Kav.20', 'Central of Political Economic and Business Research', 'Jl. Airlangga No.4-6 ', '081235746762', 'imroatulamalia@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (318, 191, 'Feri Dwi Riyanto', 'Jl. Candi Telaga Wangi No.54, Mojolangu, Malang', 'Universitas Brawijaya', 'Jalan Veteran, Ketawanggede, Kec. Lowokwaru, Kota Malang, Jawa Timur 65145', '081335183792', 'feri.riyan@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (319, 191, 'Angga Erlando', 'DUSUN SEDAN RT 05 RW 34 NO 98B, KELURAHAN SARIHARJO, KEC. NGAGLIK YOGYAKARTA', 'Universitas Gajahmada', 'Bulaksumur, Caturtunggal, Kec. Depok, Kabupaten Sleman, Daerah Istimewa Yogyakarta 55281', '08986638505', 'erlandogo@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (320, 192, 'Badara Shofi Dana', 'Jl. S. Parman gang mahoni No.2, Sumbersari, Jember, Jawa Timur', 'Universitas Negeri Jember', 'Jl. Kalimantan No. 37, Jember, Jawa Timur,', '085746513746', 'badara.dana@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (321, 192, 'Ati Musaiyaroh', 'Jl. S. Parman gang mahoni No.2, Sumbersari, Jember, Jawa Timur', 'Universitas Negeri Jember', 'Jl. Kalimantan No. 37, Jember, Jawa Timur,', '085735803010', 'aty.musaiya94@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (322, 193, 'Donny Rianda Abadi', 'Perum Taman Pondok Jati BE-12 A, Sidoarjo', 'Magister Manajemen Universitas Airlangga', 'Jalan Airlangga no 3-5 Surabaya', '081235316142', 'donnirianda91@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (323, 193, 'Zakaria Rachman', 'Wiyung', 'Magister Manajemen Universitas Airlangga', 'Jl. Airlangga no 3-5 Surabaya', '082230669944', 'zakaria.rachman05@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (324, 194, 'Iis Farida Sholihah', 'Jalan Jawa IIB No.22 Sumbersari, Jember', 'Universitas Jember', 'Jalan Kalimantan No.37 Sumbersari, Jember', '082334564642', 'iisfarida1@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (325, 194, 'Suci Arvilia', 'Jalan Jawa 8 No.24A Jember', 'Universitas Jember', 'Jalan Kalimantan No.37 Sumbersari, Jember', '085655744862', 'suciarvilia1126@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (326, 195, 'Devanto Shasta Pratomo', 'Jl. Mayjen Haryono 165 Malang', 'FEB Universitas Brawijaya', 'Jl, Mayjen Haryono 165, Malang', '0811365331', 'dede_gsu02@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (327, 196, 'Abraham Risyad Al Faruqi', 'Cinere Residence Blok H4 No.1 Meruyung, Depok, Jawa Barat.', 'Fakultas Ekonomi dan Bisnis Universitas Indonesia', 'Jalan Prof. Dr. Sumitro Djojohadikusumo Kampus UI Depok, Jawa Barat 16424 Indonesia', '081314360364', 'abraham.risyad@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (328, 196, 'Faizal Rahmanto Moeis', 'Jl. Kecapi II No. 56 Jagakarsa, Jakarta Selatan', 'Fakultas Ekonomi dan Bisnis Universitas Indonesia', 'Jalan Prof. Dr. Sumitro Djojohadikusumo Kampus UI Depok, Jawa Barat 16424 Indonesia', '081807397904', 'faizal_moeis@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (329, 196, 'Kurniawati Yuli Ashari', 'Dusun Klumprit RT 01, RW 01, Desa Surojoyo, Kecamatan Candimulyo, Kabupaten Magelang, Jawa Tengah, 16191', 'Fakultas Ekonomi Universitas Indonesia', 'Jalan Prof. Dr. Sumitro Djojohadikusumo Kampus UI Depok, Jawa Barat 16424 Indonesia', '085878666935', 'kurniawati.yuli.ashari@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (331, 198, 'Eka Wahyu Utami', 'Jl. Jawa IIB No.22', 'Universitas Jember', 'Jl.Kalimantan No.32', '081231692744', 'ekawahyu295@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (332, 198, 'Sinta Wulandari', 'Jl,Bangka Raya No.23', 'Universitas Jember', 'Jl,Kalimantan No.37', '083841798880', 'shinta.wd611@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (333, 199, 'Muhammad Asnawir', 'Jl. Raya Siman, Demangan, Kec.Ponorogo, Kabupaten Ponorogo, Jawa Timur', 'Universitas Darussalam Gontor Ponorogo', 'Jl. Raya Siman, Demangan, Kec.Ponorogo, Kabupaten Ponorogo, Jawa Timur', '081232292447', 'asnawir690@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (334, 200, 'HIDAYATUR ROHMAN', 'Griya Kost Vury Kamar 219, Jalan Jojoran Baru 34-38 Mojo, Kec. Gubeng, Kota Surabaya 60285', 'Universitas Airlangga', 'Jalan Dharmawangsa Dalam Selatan, Surabaya', '082337335034', 'hidayatur.rohman-2015@fh.unair.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (335, 201, 'Raka Achmad Inggis', 'Jalan Hasan Saputra 1 No. 6, Kelurahan Turangga, Kecamatan Lengkong, Kota Bandung', 'Institut Teknologi Bandung', 'Jalan Ganesha No. 10', '081386789106', 'raka.achmad@sbm-itb.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (336, 201, 'Annisa Rizkia Syaputri', 'Jalan Suryani Dalam Nomor 19 RT 001/002 Kelurahan Warung Muncang, Kecamatan Bandung Kulon, Kota Bandung', 'Institut Teknologi Bandung', 'Jalan Ganesha No. 10 Bandung', '082117937336', 'annisa.rizkia@sbm-itb.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (337, 201, 'Muhammad Faruq Al Hadid', 'Jalan Cisitu Lama Gang 3 No.29 Bandung', 'Institut Teknologi Bandung', 'Jalan Ganesha No.10 ', '085263906751', 'muhammad.faruq@sbm-itb.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (338, 202, 'Raihan Dzakwan Amajid', 'Jl. Kalijudan 10 no. 29 Surabaya', 'Universitas Airlangga', 'Jl. Airlangga no. 4-6 Surabaya', '082231544901', 'raihand1996@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (339, 203, 'Rendra Kurnia Wardana', 'Jalan Danau Sarangan Atas F6-A25, kelurahan Sawojajar, Kec. Kedungkandang, Kota Malang 65139', 'Universitas Padjadjaran', 'Jalan Dipati Ukur no. 46, Bandung 40132', '081235401632', 'valerindra230989@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (340, 204, 'Arinda Dewi Nur Aini', 'Demak Jaya IX/37 Surabaya', 'Universitas Airlangga', 'Jalan Airlangga 4-6 Surabaya', '085733531383', 'arindarindaa@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (344, 206, 'Ati Musaiyaroh', 'Jl. S. Parman gang Mahoni, Sumbersari, Jember', 'Universitas Jember', 'Jl. Kalimantan No. 37, Jember, Jawa Timur, Indonesia ? Kode Pos (68121),', '085735803010', 'aty.musaiya94@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (345, 206, 'Badara Shofi Dana', 'Jl. S. Parman Gang Mahoni No 2, Sumbersari, jember', '', '', '(+62)85746513746', 'badara.dana@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (346, 207, 'Widita Kurniasari', 'yuliutami@umy.ac.id', 'Universitas Airlangga/Universitas Trunojoyo', 'Gd. Pascasarjana Universitas Airlangga 4, lt.1 Jl. Airlangga Surabaya', '082139763376', 'widita81.wk@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (347, 207, 'Yuli Utami', 'yuliutami@umy.ac.id', 'Universitas Airlangga/Universitas Muhammadiyah Yogyakarta', 'Gd. Pascasarjana Universitas Airlangga 4, lt.1 Jl. Airlangga Surabaya', '085729989054', 'yuli.utami-2015@pasca.unair.ac.id / yuliutami@umy.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (348, 207, 'Fatin Fadhilah Hasib', 'yuliutami@umy.ac.id', 'Universitas Airlangga/Universitas Airlangga', 'Gd. Pascasarjana Universitas Airlangga 4, lt.1 Jl. Airlangga Surabaya', '081235443538', 'fatin.fadhila@feb.unair.ac.id');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (349, 208, 'Fitria Nur Anggraeni', 'Jambu lor RT 03 RW 01 Kecamatan Jambu', 'Universitas Negeri Semarang', 'Jambu lor RT 03 RW 01 Kecamatan Jambu', '085640550311', 'fitria.aang@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (350, 209, 'Listiono', 'Lab Mini Banking 
Ruang F. 06 Lt. 2 Fakultas Agama Islam Universtias Muhammadiyah Yogyakarta
Jl, Lingkar Selatan, Tamnatirto, Kasihan Bantul', 'Universitas Gadjah Mada', 'Jl. Nusantara, Kampus UGM, Bulaksumur, Yogyakarta 55281', '081325390349', 'listio.tl@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (351, 210, 'Yosua Artha Lubero Simanjuntak', 'Mutiara Citra Asri A4/9 Candi, Sidoarjo, Jawa Timur', 'Universitas Airlangga Surabaya', 'Jl. Airlangga No.4, Airlangga, Gubeng, Surabaya, Jawa Timur', '087702837702', 'yosua.artha@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (352, 210, 'Shafira Dinar Rizqi', 'Jl. Gubeng Kertajaya XIII Blok B No. 3, Surabaya', 'Universitas Airlangga Surabaya', 'Jl. Airlangga No.4, Airlangga, Gubeng, Surabaya, Jawa Timur', '082257673306', 'shafiradinarrizqi@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (353, 210, 'Bayu Ardiansyah', 'Jl. Kalianak Barat No. 11 Surabaya', 'Universitas Airlangga Surabaya', 'Jl. Airlangga No.4, Airlangga, Gubeng, Surabaya, Jawa Timur', '081235961633', 'bayu.ardhiansyah-2014@feb.unair.ac.id	');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (354, 211, 'Listiono', 'Lab Mini Banking
Gedung F.06 lt.2 Fakultas Agama Islam, UMY
Jl. Lingkar Selatan, Tamantirto, Kasihan, Bantul.', 'Universitas Gadjah Mada', 'Kampus UGM, Bulaksumur, Yogyakarta', '081325390349', 'listio.tl@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (355, 212, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (356, 212, 'Okta Herriyadi', 'Perum. Grand Saphire Jl. MT. Haryono Ponorogo
', 'Pemerintahan Kabupaten Ponorogo', 'Jl. Aloon aloon no. 9 Gd Graha Krida It 7 Ponorogo', '085854822591', 'okta_herriyadi@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (357, 213, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (358, 213, 'Okta Herriyadi', 'Perum. Grand Saphire Jl. MT. Haryono', 'Pemerintahan Kabupaten Ponorogo', 'Jl. Aloon aloon no. 9 Gd Graha Krida It 7 Ponorogo', '085854822591', 'okta_herriyadi@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (359, 214, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (360, 215, '', '', '', '', '', '');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (361, 216, 'Fakhrur Rozi', '', '', '', '085733016040', 'fakhrurrozi23@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (362, 216, 'Fakhur Rozi', '', '', '', '085733016040', 'fakhrurrozi23@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (226, 138, 'Chitara Rizka Noviyanti', '', '4.Universitas Jember Fakultas Ekonomi dan Bisnis', '', '085233848592', 'chitararizka@gmail.com
');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (155, 95, 'Rika Puspa Ayu, S.Psi, MM', 'Jl. Embun pagi no 121 Kel.Tangkerang Labuai Pekanbaru Kota', '', 'Jl. Embun pagi no 121 Kel.Tangkerang Labuai Pekanbaru Kota', '081214419963', 'rikapuspaayu@gmail.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (84, 50, 'Dr.Sri  Muljaningsih, SE,MSP', 'Perum. Griya Santa B.110. Kota Malang', '', '', '081333107874', 'ningsih2006@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (85, 51, 'Prof. Dr. Ernani Hadiyati, S.E., M.S ', '', '', '', '08123584748', 'ernani_hadiyati@yahoo.com');

INSERT INTO participant_detail (participant_detail_id, participant_id, participant_detail_name, address, intitution_name, intitution_address, mobile_phone, mail_address)
VALUES (330, 197, 'Andiga Kusuma Nur Ichsan, S.E.', '', '', '', '62 878 5152 2549', 'andiga.kni@gmail.com');

--
-- Data for table public.participant_statuses (OID = 18349) (LIMIT 0,9)
--
INSERT INTO participant_statuses (participant_status_id, participant_status_name)
VALUES (0, 'Belum Memverifikasi');

INSERT INTO participant_statuses (participant_status_id, participant_status_name)
VALUES (1, 'Terdaftar');

INSERT INTO participant_statuses (participant_status_id, participant_status_name)
VALUES (2, 'Tolak');

INSERT INTO participant_statuses (participant_status_id, participant_status_name)
VALUES (3, 'Terima');

INSERT INTO participant_statuses (participant_status_id, participant_status_name)
VALUES (5, 'Full Paper Diterima');

INSERT INTO participant_statuses (participant_status_id, participant_status_name)
VALUES (6, 'Undangan Terkirim');

INSERT INTO participant_statuses (participant_status_id, participant_status_name)
VALUES (7, 'Tidak Hadir');

INSERT INTO participant_statuses (participant_status_id, participant_status_name)
VALUES (8, 'Hadir');

INSERT INTO participant_statuses (participant_status_id, participant_status_name)
VALUES (4, 'Pengumuman Lolos Terkirim');

--
-- Data for table public."position" (OID = 18355) (LIMIT 0,1)
--
INSERT INTO "position" (id, position_title)
VALUES (1, 'Administrator');

--
-- Data for table public.post (OID = 18361) (LIMIT 0,5)
--
INSERT INTO post (id, category_id, thumbnail_id, post_title, post_content, user_id, creation_date, modifate_date, post_status)
VALUES (1, 1, 2, 'Membuat Tes Post', '<h4>Also subhearder available too</h4>
<p><span style="font-weight: bold;">Lorem ipsum dolor sit amet</span>, consectetur adipiscing elit. Ut vel consequat massa. <span style="color: rgb(99, 0, 0); font-weight: bold;">Aliquam augue odio, vulputate non tempus et, sollicitudin in magna</span>.
 Sed dignissim, tellus sagittis varius vestibulum, erat sapien varius 
dolor, non elementum sem velit ut nunc. Sed gravida vehicula ipsum, sit 
amet auctor nunc ultricies et. <a href="http://#">Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</a> <span style="font-style: italic;">Morbi dapibus massa faucibus</span>,
 euismod augue non, facilisis odio. In blandit consectetur nibh, eu 
venenatis ligula condimentum sed. Nullam magna velit, eleifend ut 
tincidunt sit amet, sagittis id ligula. Aenean eget metus auctor, 
fringilla nunc in, lacinia nisi. Suspendisse potenti. Suspendisse vel 
vulputate lectus.</p>
<blockquote><span style="text-decoration: underline;">
    Cras posuere scelerisque faucibus</span>. Fusce consectetur elit at 
nisi accumsan rutrum. Sed quis risus vel purus hendrerit mattis. In hac 
habitasse platea dictumst. Morbi volutpat justo in nunc tincidunt, sed 
auctor dui ullamcorper. <span style="color: rgb(41, 82, 24);">Praesent eleifend adipiscing nisi</span>. <a href="http://#">Aliquam mi elit, cursus nec posuere vel, varius in tortor</a>. Nullam fermentum nunc felis, sed varius ante auctor et.
</blockquote>
<p>Curabitur urna neque, pharetra vel felis commodo, dictum bibendum odio.<a href="http://#"> Suspendisse mauris augue</a>,
 volutpat vel augue in, pellentesque semper turpis. Donec congue, magna 
quis condimentum facilisis, dolor mauris suscipit enim, eu aliquam risus
 elit vel diam.</p>
                                

                                                                     ', 'admin@pt-cas.com', '2017-04-16', NULL, 1);

INSERT INTO post (id, category_id, thumbnail_id, post_title, post_content, user_id, creation_date, modifate_date, post_status)
VALUES (3, 1, 2, 'Outer Space', '<div class="post-text">                                                                                        <p><strong>Outer space</strong>, or simply space, is the void that exists between celestial bodies, including the Earth. It is not completely empty, but consists of a hard vacuum containing a low density of particles: predominantly a plasma of hydrogen and helium.</p>                                            <img src="http://119.235.252.86/cas-portal-hr/assets/img/media/admin@biis.com/2.jpg" class="img-text post-image" style="height: 199.55px;">                                            <p>There is no firm boundary where space begins. However the K?rm?n line, at an altitude of 100 km (62 mi) above sea level, is conventionally used as the start of outer space in space treaties and for aerospace records keeping. The framework for international space law was established by the Outer Space Treaty, which was passed by the United Nations in 1967. This treaty precludes any claims of national sovereignty and permits all states to freely explore outer space. In 1979, the Moon Treaty made the surfaces of objects such as planets, as well as the orbital space around these bodies, the jurisdiction of the international community. Despite the drafting of UN resolutions for the peaceful uses of outer space, anti-satellite weapons have been tested in Earth orbit.</p>                                            <p><strong>Humans began</strong> the physical exploration of space during the 20th century with the advent of high-altitude balloon flights, followed by manned rocket launches. Earth orbit was first achieved by Yuri Gagarin of the Soviet Union in 1961 and unmanned spacecraft have since reached all of the known planets in the Solar System. Due to the high cost of getting into space, manned spaceflight has been limited to low Earth orbit and the Moon. In August 2012, Voyager 1 became the first man-made spacecraft to enter interstellar space.</p>                                            <p>Outer space represents a challenging environment for human exploration because of the dual hazards of vacuum and radiation. <a>Microgravity</a> also has a negative effect on human physiology that causes both muscle atrophy and bone loss. In addition to solving all of these health and environmental issues, humans will also need to find a way to significantly reduce the cost of getting into space if they want to become a space faring civilization. Proposed concepts for doing this are non-rocket spacelaunch, momentum exchange tethers and space elevators.</p>                                            <h4>Discovery</h4>                                            <p>In 350 BC, <i>Greek philosopher Aristotle</i> suggested that nature abhors a vacuum, a principle that became known as the horror vacui. This concept built upon a 5th-century BC ontological argument by the Greek philosopher Parmenides, who denied the possible existence of a void in space.[8] Based on this idea that a vacuum could not exist, in the West it was widely held for many centuries that space could not be empty. As late as the 17th century, the French philosopher Ren? Descartes argued that the entirety of space must be filled.</p>                                            <p>In ancient China, there were various schools of thought concerning the nature of the heavens, some of which bear a resemblance to the modern understanding. In the 2nd century, astronomer Zhang Heng became convinced that space must be infinite, extending well beyond the mechanism that supported the Sun and the stars. The surviving books of the Hs?an Yeh school said that the heavens were boundless, "empty and void of substance". Likewise, the "sun, moon, and the company of stars float in the empty space, moving or standing still".</p>                                            <h4>Formation and state</h4>                                            <p>According to the Big Bang theory, the Universe originated in an extremely hot and dense state about 13.8 billion years ago and began expanding rapidly. About 380,000 years later the Universe had cooled sufficiently to allow protons and electrons to combine and form hydrogen?the so-called recombination epoch. When this happened, matter and energy became decoupled, allowing photons to travel freely through space. The matter that remained following the initial expansion has since undergone gravitational collapse to create stars, galaxies and other astronomical objects, leaving behind a deep vacuum that forms what is now called outer space. As light has a finite velocity, this theory also constrains the size of the directly observable Universe. This leaves open the question as to whether the Universe is finite or infinite.</p>                                            <h4>See also</h4>                                            <ul><li><a>Portal icon</a></li><li><a>Astronomy portal</a></li><li><a>Portal icon</a></li><li><a>Space portal</a></li><li><a>Portal icon</a></li><li><a>Spaceflight portal</a></li><li><a>Earth''s location in the universe</a></li><li><a>Human outpost</a></li></ul>                                        </div>', 'admin@pt-cas.com', '2017-04-16', NULL, 1);

INSERT INTO post (id, category_id, thumbnail_id, post_title, post_content, user_id, creation_date, modifate_date, post_status)
VALUES (4, 2, 5, 'Dokumentasi Kegiatan Proyek', '<p>Berikut adalah dokumentasi kegiatan proyek aplikasi E-Logsheet di PT PJB UP Gresik</p><p><br></p>', 'indah@pt-cas.com', '2017-04-20', NULL, 1);

INSERT INTO post (id, category_id, thumbnail_id, post_title, post_content, user_id, creation_date, modifate_date, post_status)
VALUES (2, 2, 3, 'Membuat Tes Post Dua', '<h4>Also subhearder available too</h4>
<p><span style="font-weight: bold;">Lorem ipsum dolor sit amet</span>, consectetur adipiscing elit. Ut vel consequat massa. <span style="color: rgb(99, 0, 0); font-weight: bold;">Aliquam augue odio, vulputate non tempus et, sollicitudin in magna</span>.
 Sed dignissim, tellus sagittis varius vestibulum, erat sapien varius 
dolor, non elementum sem velit ut nunc. Sed gravida vehicula ipsum, sit 
amet auctor nunc ultricies et. <a href="http://#">Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.</a> <span style="font-style: italic;">Morbi dapibus massa faucibus</span>,
 euismod augue non, facilisis odio. In blandit consectetur nibh, eu 
venenatis ligula condimentum sed. Nullam magna velit, eleifend ut 
tincidunt sit amet, sagittis id ligula. Aenean eget metus auctor, 
fringilla nunc in, lacinia nisi. Suspendisse potenti. Suspendisse vel 
vulputate lectus.</p>
<blockquote><span style="text-decoration: underline;">
    Cras posuere scelerisque faucibus</span>. Fusce consectetur elit at 
nisi accumsan rutrum. Sed quis risus vel purus hendrerit mattis. In hac 
habitasse platea dictumst. Morbi volutpat justo in nunc tincidunt, sed 
auctor dui ullamcorper. <span style="color: rgb(41, 82, 24);">Praesent eleifend adipiscing nisi</span>. <a href="http://#">Aliquam mi elit, cursus nec posuere vel, varius in tortor</a>. Nullam fermentum nunc felis, sed varius ante auctor et.
</blockquote>
<p>Curabitur urna neque, pharetra vel felis commodo, dictum bibendum odio.<a href="http://#"> Suspendisse mauris augue</a>,
 volutpat vel augue in, pellentesque semper turpis. Donec congue, magna 
quis condimentum facilisis, dolor mauris suscipit enim, eu aliquam risus
 elit vel diam.</p>
                                

                                                                     ', 'admin@pt-cas.com', '2017-04-16', NULL, 1);

INSERT INTO post (id, category_id, thumbnail_id, post_title, post_content, user_id, creation_date, modifate_date, post_status)
VALUES (5, 2, 7, 'JAS Airport Services handle hajj flight in HLP and SUB', '<p>JAS Airport Services regularly appointed by Saudi Arabian Airlines to
 handle their hajj flight at Jakarta Halim Perdanakusuma Airport (HLP) 
and Surabaya Juanda International Airport (SUB).</p>
<p><img src="http://cas.manajemenit.com/wp-content/uploads/2017/03/JAS-Airport-Services-handle-hajj-flight-in-HLP-and-SUB-696x446.jpg" alt="http://cas.manajemenit.com/wp-content/uploads/2017/03/JAS-Airport-Services-handle-hajj-flight-in-HLP-and-SUB-696x446.jpg" style="width: 218.475px; height: 140px; float: left;"></p><p>Using B747-400 aircraft JAS will handle Hajj Flight Phase I ( 
Pilgrims Departure) 1 September ? 26 September) and Phase II (Pilgrims 
Arrival) 10 October ? 5 November 2014.</p>                                 ', 'bagusmertha@manajemenit.com', '2017-05-15', NULL, 1);

--
-- Data for table public.role (OID = 18373) (LIMIT 0,104)
--
INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (200, 53, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (48, 1, 3, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (46, 10, 3, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (44, 4, 3, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (21, 4, 2, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (201, 53, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (45, 5, 3, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (49, 2, 3, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (50, 18, 3, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (27, 10, 2, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (96, 34, 2, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (29, 1, 2, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (207, 55, 2, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (203, 54, 2, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (126, 44, 2, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (199, 53, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (82, 29, 3, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (81, 29, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (97, 34, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (41, 13, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (42, 14, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (43, 15, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (47, 11, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (53, 19, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (55, 12, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (94, 33, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (36, 18, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (38, 19, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (112, 39, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (115, 40, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (118, 41, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (121, 42, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (124, 43, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (127, 44, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (16, 13, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (17, 14, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (18, 15, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (20, 2, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (22, 5, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (28, 11, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (30, 12, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (93, 33, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (111, 39, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (114, 40, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (117, 41, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (120, 42, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (208, 55, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (209, 55, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (123, 43, 2, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (1, 2, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (11, 1, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (116, 41, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (95, 34, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (35, 18, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (37, 19, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (3, 4, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (9, 10, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (10, 11, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (12, 12, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (13, 13, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (204, 54, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (14, 14, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (205, 54, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (15, 15, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (4, 5, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (92, 33, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (202, 54, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (206, 55, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (125, 44, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (198, 53, 1, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (122, 43, 1, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (80, 29, 1, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (113, 40, 1, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (110, 39, 1, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (119, 42, 1, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (146, 1, 4, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (159, 10, 4, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (147, 19, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (191, 51, 2, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (195, 52, 2, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (154, 29, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (190, 51, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (194, 52, 1, 1);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (158, 33, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (160, 11, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (161, 12, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (162, 14, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (163, 13, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (164, 15, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (168, 5, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (173, 4, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (174, 39, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (175, 43, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (176, 40, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (177, 41, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (178, 42, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (179, 44, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (187, 2, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (188, 18, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (189, 34, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (192, 51, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (193, 51, 4, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (196, 52, 3, 0);

INSERT INTO role (id, menu_id, group_id, is_active)
VALUES (197, 52, 4, 0);

--
-- Data for table public.task (OID = 18376) (LIMIT 0,12)
--
INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (1, 'Meeting 2', 'Test meeting 2', '', 'iwan.setiawan@cas.com', 'admin@pt-cas.com', '2017-05-10 12:29:43', 'admin@pt-cas.com', '2017-05-10 12:29:43');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (2, 'Meeting 2', 'Test meeting 2', 'bagusmertha@gmail.com', 'iwan.setiawan@cas.com', 'admin@pt-cas.com', '2017-05-10 12:29:43', 'admin@pt-cas.com', '2017-05-10 12:29:43');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (3, 'Meeting 3', 'Test meeting 3', 'admin@pt-cas.com', 'iwan.setiawan@cas.com', 'admin@pt-cas.com', '2017-05-10 12:30:11', 'admin@pt-cas.com', '2017-05-10 12:30:11');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (4, 'Meeting 3', 'Test meeting 3', 'jefry.rendra@gmail.com', 'iwan.setiawan@cas.com', 'admin@pt-cas.com', '2017-05-10 12:30:12', 'admin@pt-cas.com', '2017-05-10 12:30:12');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (5, 'Review Portal HR', '<p>Tolong direview progres dari Portal HR.</p><p>Hasilnya dikirim ke email saya</p>', 'mahesa.putra@pt-cas.com', 'iwan.setiawan@cas.com', 'admin@pt-cas.com', '2017-05-15 04:34:33', 'admin@pt-cas.com', '2017-05-15 04:34:33');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (6, 'Review Tambaham Billing System', '<p>Siapkan user requirement untuk aplikasi tambahan billing system. Diharapkan selesai minggu ini ya.<br></p>', 'bagusmertha@manajemenit.com', 'iwan.setiawan@cas.com', 'iwan.setiawan@cas.com', '2017-05-15 04:41:29', 'iwan.setiawan@cas.com', '2017-05-15 04:41:29');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (7, 'Review Tambaham Billing System', '<p>Siapkan user requirement untuk aplikasi tambahan billing system. Diharapkan selesai minggu ini ya.<br></p>', 'bagusmertha@gmail.com', 'iwan.setiawan@cas.com', 'iwan.setiawan@cas.com', '2017-05-15 04:41:29', 'iwan.setiawan@cas.com', '2017-05-15 04:41:29');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (8, 'Review Tambaham Billing System', '<p>Siapkan user requirement untuk aplikasi tambahan billing system. Diharapkan selesai minggu ini ya.<br></p>', 'admin@pt-cas.com', 'iwan.setiawan@cas.com', 'iwan.setiawan@cas.com', '2017-05-15 04:41:29', 'iwan.setiawan@cas.com', '2017-05-15 04:41:29');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (9, 'Review Tambaham Billing System', '<p>Siapkan user requirement untuk aplikasi tambahan billing system. Diharapkan selesai minggu ini ya.<br></p>', 'jefry.rendra@gmail.com', 'iwan.setiawan@cas.com', 'iwan.setiawan@cas.com', '2017-05-15 04:41:29', 'iwan.setiawan@cas.com', '2017-05-15 04:41:29');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (10, 'Review Tambaham Billing System', '<p>Siapkan user requirement untuk aplikasi tambahan billing system. Diharapkan selesai minggu ini ya.<br></p>', 'mahesa.putra@pt-cas.com', 'iwan.setiawan@cas.com', 'iwan.setiawan@cas.com', '2017-05-15 04:41:29', 'iwan.setiawan@cas.com', '2017-05-15 04:41:29');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (11, 'Test', 'test', 'admin@pt-cas.com', 'admin@pt-cas.com', 'admin@pt-cas.com', '2017-05-15 08:10:11', 'admin@pt-cas.com', '2017-05-15 08:10:11');

INSERT INTO task (task_id, task_title, task_content, task_for, approve_by, creation_user, creation_date, modifate_user, modifate_date)
VALUES (12, 'ddddd', '                                 ', NULL, 'mahesa.putra@pt-cas.com', 'admin@pt-cas.com', '2017-05-15 10:19:57', 'admin@pt-cas.com', '2017-05-15 10:19:57');

--
-- Data for table public.task_detail (OID = 18382) (LIMIT 0,2)
--
INSERT INTO task_detail (task_detail_id, task_id, task_for)
VALUES (1, 12, 'iwan.setiawan@cas.com');

INSERT INTO task_detail (task_detail_id, task_id, task_for)
VALUES (2, 12, 'mahesa.putra@pt-cas.com');

--
-- Data for table public.task_report (OID = 18388) (LIMIT 0,10)
--
INSERT INTO task_report (task_report_id, task_id, task_report_content, task_report_status, creation_user, creation_date)
VALUES (1, 3, '<p>Sudah selesai</p>', 'Progress', 'admin@pt-cas.com', '2017-05-10 12:30:56');

INSERT INTO task_report (task_report_id, task_id, task_report_content, task_report_status, creation_user, creation_date)
VALUES (2, 3, '<p>Test complete</p>', 'Complete', 'admin@pt-cas.com', '2017-05-10 12:31:34');

INSERT INTO task_report (task_report_id, task_id, task_report_content, task_report_status, creation_user, creation_date)
VALUES (3, 3, '<p><br></p>', 'Finish', 'iwan.setiawan@cas.com', '2017-05-10 12:34:30');

INSERT INTO task_report (task_report_id, task_id, task_report_content, task_report_status, creation_user, creation_date)
VALUES (4, 10, '<p>Sedang dalam proses menunggu hasil feedback vendor.</p>', 'Progress', 'mahesa.putra@pt-cas.com', '2017-05-15 04:42:20');

INSERT INTO task_report (task_report_id, task_id, task_report_content, task_report_status, creation_user, creation_date)
VALUES (5, 5, '<p>Dokumen sedang disiapkan</p>', 'Progress', 'mahesa.putra@pt-cas.com', '2017-05-15 04:44:40');

INSERT INTO task_report (task_report_id, task_id, task_report_content, task_report_status, creation_user, creation_date)
VALUES (6, 10, '<p>Sudah selesai dan sudah dikirim laporannya by email</p>', 'Complete', 'mahesa.putra@pt-cas.com', '2017-05-15 04:50:30');

INSERT INTO task_report (task_report_id, task_id, task_report_content, task_report_status, creation_user, creation_date)
VALUES (7, 8, '<p><br></p>', 'Progress', 'admin@pt-cas.com', '2017-05-15 08:08:06');

INSERT INTO task_report (task_report_id, task_id, task_report_content, task_report_status, creation_user, creation_date)
VALUES (8, 8, '<p><br></p>', 'New', 'admin@pt-cas.com', '2017-05-15 08:08:24');

INSERT INTO task_report (task_report_id, task_id, task_report_content, task_report_status, creation_user, creation_date)
VALUES (9, 8, '<p><br></p>', 'Progress', 'admin@pt-cas.com', '2017-05-15 08:08:47');

INSERT INTO task_report (task_report_id, task_id, task_report_content, task_report_status, creation_user, creation_date)
VALUES (10, 8, '<p><br></p>', 'Complete', 'admin@pt-cas.com', '2017-05-15 08:09:12');

--
-- Data for table public."user" (OID = 18394) (LIMIT 0,3)
--
INSERT INTO "user" (id, user_id, group_id, passwd, last_active)
VALUES (1, 'info@ejavec.org', 1, '23456', '2017-09-09 14:31:39');

INSERT INTO "user" (id, user_id, group_id, passwd, last_active)
VALUES (2, 'admin@isef.org', 1, '23456', '2017-09-20 09:57:05');

INSERT INTO "user" (id, user_id, group_id, passwd, last_active)
VALUES (3, 'admin@hipmi.or.id', 2, '23456', '2017-09-20 09:31:18');

SET search_path = participant, pg_catalog;
--
-- Data for table participant.participant (OID = 18544) (LIMIT 0,6)
--
INSERT INTO participant (id, company_id, event_id, event_category_id, event_package_id, participant_name, participant_address, participant_mobile, participant_email, "participant_sosmed_FB", participant_sosmed_twitter, "participant_sosmed_IG", participant_company, participant_password, status_file, status_payment, creation_time, creation_user, last_mod_time, last_mod_user, memo_lines1, memo_lines2, memo_lines3, memo_lines4, memo_lines5, memo_lines6, memo_lines7, memo_lines8, memo_lines9, memo_lines10, participant_category)
VALUES (0, 1, 1, 1, 1, 'coba ya', 'nomaden', 11111, 'percobaan@sbaf.com', NULL, NULL, NULL, NULL, NULL, 0, 0, '2017-09-19 05:57:56', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO participant (id, company_id, event_id, event_category_id, event_package_id, participant_name, participant_address, participant_mobile, participant_email, "participant_sosmed_FB", participant_sosmed_twitter, "participant_sosmed_IG", participant_company, participant_password, status_file, status_payment, creation_time, creation_user, last_mod_time, last_mod_user, memo_lines1, memo_lines2, memo_lines3, memo_lines4, memo_lines5, memo_lines6, memo_lines7, memo_lines8, memo_lines9, memo_lines10, participant_category)
VALUES (1, 1, 1, 1, 1, 'coba ya', 'nomaden', 11111, 'percobaan2@sbaf.com', NULL, NULL, NULL, NULL, NULL, 0, 0, '2017-09-19 06:03:51', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO participant (id, company_id, event_id, event_category_id, event_package_id, participant_name, participant_address, participant_mobile, participant_email, "participant_sosmed_FB", participant_sosmed_twitter, "participant_sosmed_IG", participant_company, participant_password, status_file, status_payment, creation_time, creation_user, last_mod_time, last_mod_user, memo_lines1, memo_lines2, memo_lines3, memo_lines4, memo_lines5, memo_lines6, memo_lines7, memo_lines8, memo_lines9, memo_lines10, participant_category)
VALUES (2, 1, 1, 1, 1, 'coba ya', 'nomaden', 213214, 'percobaan3@sbaf.com', NULL, NULL, NULL, NULL, '11111', 0, 0, '2017-09-19 06:06:14', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO participant (id, company_id, event_id, event_category_id, event_package_id, participant_name, participant_address, participant_mobile, participant_email, "participant_sosmed_FB", participant_sosmed_twitter, "participant_sosmed_IG", participant_company, participant_password, status_file, status_payment, creation_time, creation_user, last_mod_time, last_mod_user, memo_lines1, memo_lines2, memo_lines3, memo_lines4, memo_lines5, memo_lines6, memo_lines7, memo_lines8, memo_lines9, memo_lines10, participant_category)
VALUES (3, 1, 1, 1, 1, 'coba ya', 'nomaden', 213214, 'percobaan4@sbaf.com', NULL, NULL, NULL, NULL, '11111', 0, 0, '2017-09-19 06:11:10', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO participant (id, company_id, event_id, event_category_id, event_package_id, participant_name, participant_address, participant_mobile, participant_email, "participant_sosmed_FB", participant_sosmed_twitter, "participant_sosmed_IG", participant_company, participant_password, status_file, status_payment, creation_time, creation_user, last_mod_time, last_mod_user, memo_lines1, memo_lines2, memo_lines3, memo_lines4, memo_lines5, memo_lines6, memo_lines7, memo_lines8, memo_lines9, memo_lines10, participant_category)
VALUES (4, 1, 1, 1, 1, 'coba ya', 'nomaden', 213214, 'percobaan5@sbaf.com', NULL, NULL, NULL, NULL, '11111', 0, 0, '2017-09-19 07:09:20', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO participant (id, company_id, event_id, event_category_id, event_package_id, participant_name, participant_address, participant_mobile, participant_email, "participant_sosmed_FB", participant_sosmed_twitter, "participant_sosmed_IG", participant_company, participant_password, status_file, status_payment, creation_time, creation_user, last_mod_time, last_mod_user, memo_lines1, memo_lines2, memo_lines3, memo_lines4, memo_lines5, memo_lines6, memo_lines7, memo_lines8, memo_lines9, memo_lines10, participant_category)
VALUES (5, 1, 1, 1, 1, 'coba lagi ya', 'nomaden', 213214, 'andiputra3107@gmail.com', NULL, NULL, NULL, NULL, '11111', 0, 0, '2017-09-19 10:34:37', 1, NULL, NULL, NULL, 'MTUwNTgxMDA3Nw==', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

SET search_path = event, pg_catalog;
--
-- Definition for index isef_pkey (OID = 18401) : 
--
SET search_path = public, pg_catalog;
ALTER TABLE ONLY isef
    ADD CONSTRAINT isef_pkey
    PRIMARY KEY (id);
--
-- Definition for index isef_registration_key (OID = 18403) : 
--
ALTER TABLE ONLY isef
    ADD CONSTRAINT isef_registration_key
    UNIQUE (registration);
--
-- Definition for index isef_location_pkey (OID = 18405) : 
--
ALTER TABLE ONLY isef_location
    ADD CONSTRAINT isef_location_pkey
    PRIMARY KEY (isef_location_id);
--
-- Definition for index agenda_detail_pkey (OID = 18407) : 
--
ALTER TABLE ONLY agenda_detail
    ADD CONSTRAINT agenda_detail_pkey
    PRIMARY KEY (id);
--
-- Definition for index agenda_pkey (OID = 18409) : 
--
ALTER TABLE ONLY agenda
    ADD CONSTRAINT agenda_pkey
    PRIMARY KEY (id);
--
-- Definition for index arsip_pkey (OID = 18411) : 
--
ALTER TABLE ONLY arsip
    ADD CONSTRAINT arsip_pkey
    PRIMARY KEY (id);
--
-- Definition for index article_theme_pkey (OID = 18413) : 
--
ALTER TABLE ONLY article_theme
    ADD CONSTRAINT article_theme_pkey
    PRIMARY KEY (article_theme_id);
--
-- Definition for index category_arsip_pkey (OID = 18415) : 
--
ALTER TABLE ONLY category_arsip
    ADD CONSTRAINT category_arsip_pkey
    PRIMARY KEY (id);
--
-- Definition for index category_faq_table_pkey (OID = 18417) : 
--
ALTER TABLE ONLY category_faq
    ADD CONSTRAINT category_faq_table_pkey
    PRIMARY KEY (id);
--
-- Definition for index category_pkey (OID = 18419) : 
--
ALTER TABLE ONLY category
    ADD CONSTRAINT category_pkey
    PRIMARY KEY (id);
--
-- Definition for index chat_pkey (OID = 18421) : 
--
ALTER TABLE ONLY chat
    ADD CONSTRAINT chat_pkey
    PRIMARY KEY (id);
--
-- Definition for index comment_pkey (OID = 18423) : 
--
ALTER TABLE ONLY comment
    ADD CONSTRAINT comment_pkey
    PRIMARY KEY (id);
--
-- Definition for index company_pkey (OID = 18425) : 
--
ALTER TABLE ONLY company
    ADD CONSTRAINT company_pkey
    PRIMARY KEY (id);
--
-- Definition for index config_pkey (OID = 18427) : 
--
ALTER TABLE ONLY config
    ADD CONSTRAINT config_pkey
    PRIMARY KEY (id);
--
-- Definition for index employee_group_detail_idx (OID = 18429) : 
--
ALTER TABLE ONLY employee_group_detail
    ADD CONSTRAINT employee_group_detail_idx
    UNIQUE (employee_group_id, employee_id);
--
-- Definition for index employee_group_detail_pkey (OID = 18431) : 
--
ALTER TABLE ONLY employee_group_detail
    ADD CONSTRAINT employee_group_detail_pkey
    PRIMARY KEY (id);
--
-- Definition for index employee_group_pkey (OID = 18433) : 
--
ALTER TABLE ONLY employee_group
    ADD CONSTRAINT employee_group_pkey
    PRIMARY KEY (id);
--
-- Definition for index employee_idx (OID = 18435) : 
--
ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_idx
    UNIQUE (employee_email);
--
-- Definition for index employee_pkey (OID = 18437) : 
--
ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_pkey
    PRIMARY KEY (id);
--
-- Definition for index faq_pkey (OID = 18439) : 
--
ALTER TABLE ONLY faq
    ADD CONSTRAINT faq_pkey
    PRIMARY KEY (id);
--
-- Definition for index group_bgsw022_idx (OID = 18441) : 
--
ALTER TABLE ONLY "group"
    ADD CONSTRAINT group_bgsw022_idx
    UNIQUE (group_code);
--
-- Definition for index group_bgsw022_pkey (OID = 18443) : 
--
ALTER TABLE ONLY "group"
    ADD CONSTRAINT group_bgsw022_pkey
    PRIMARY KEY (id);
--
-- Definition for index media_pkey (OID = 18445) : 
--
ALTER TABLE ONLY media
    ADD CONSTRAINT media_pkey
    PRIMARY KEY (id);
--
-- Definition for index menu_pkey (OID = 18447) : 
--
ALTER TABLE ONLY menu
    ADD CONSTRAINT menu_pkey
    PRIMARY KEY (id);
--
-- Definition for index participant_category_pkey (OID = 18449) : 
--
ALTER TABLE ONLY participant_category
    ADD CONSTRAINT participant_category_pkey
    PRIMARY KEY (participant_category_id);
--
-- Definition for index participant_detail_pkey (OID = 18451) : 
--
ALTER TABLE ONLY participant_detail
    ADD CONSTRAINT participant_detail_pkey
    PRIMARY KEY (participant_detail_id);
--
-- Definition for index participant_pkey (OID = 18453) : 
--
ALTER TABLE ONLY participant
    ADD CONSTRAINT participant_pkey
    PRIMARY KEY (participant_id);
--
-- Definition for index participant_statuses_pkey (OID = 18455) : 
--
ALTER TABLE ONLY participant_statuses
    ADD CONSTRAINT participant_statuses_pkey
    PRIMARY KEY (participant_status_id);
--
-- Definition for index position_pkey (OID = 18457) : 
--
ALTER TABLE ONLY "position"
    ADD CONSTRAINT position_pkey
    PRIMARY KEY (id);
--
-- Definition for index post_pkey (OID = 18459) : 
--
ALTER TABLE ONLY post
    ADD CONSTRAINT post_pkey
    PRIMARY KEY (id);
--
-- Definition for index role_pkey (OID = 18461) : 
--
ALTER TABLE ONLY role
    ADD CONSTRAINT role_pkey
    PRIMARY KEY (id);
--
-- Definition for index task_detail_pkey (OID = 18463) : 
--
ALTER TABLE ONLY task_detail
    ADD CONSTRAINT task_detail_pkey
    PRIMARY KEY (task_detail_id);
--
-- Definition for index task_idx (OID = 18465) : 
--
ALTER TABLE ONLY task
    ADD CONSTRAINT task_idx
    UNIQUE (task_title, task_for);
--
-- Definition for index task_pkey (OID = 18467) : 
--
ALTER TABLE ONLY task
    ADD CONSTRAINT task_pkey
    PRIMARY KEY (task_id);
--
-- Definition for index task_report_pkey (OID = 18469) : 
--
ALTER TABLE ONLY task_report
    ADD CONSTRAINT task_report_pkey
    PRIMARY KEY (task_report_id);
--
-- Definition for index user_idx1 (OID = 18471) : 
--
ALTER TABLE ONLY "user"
    ADD CONSTRAINT user_idx1
    UNIQUE (user_id);
--
-- Definition for index user_pkey (OID = 18473) : 
--
ALTER TABLE ONLY "user"
    ADD CONSTRAINT user_pkey
    PRIMARY KEY (id);
--
-- Definition for index agenda_detail_fk (OID = 18475) : 
--
ALTER TABLE ONLY agenda_detail
    ADD CONSTRAINT agenda_detail_fk
    FOREIGN KEY (agenda_id) REFERENCES agenda(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Definition for index arsip_fk (OID = 18480) : 
--
ALTER TABLE ONLY arsip
    ADD CONSTRAINT arsip_fk
    FOREIGN KEY (category_arsip_id) REFERENCES category_arsip(id) ON UPDATE CASCADE ON DELETE RESTRICT;
--
-- Definition for index employee_fk (OID = 18485) : 
--
ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_fk
    FOREIGN KEY (company_id) REFERENCES company(id) ON UPDATE CASCADE ON DELETE RESTRICT;
--
-- Definition for index employee_fk1 (OID = 18490) : 
--
ALTER TABLE ONLY employee
    ADD CONSTRAINT employee_fk1
    FOREIGN KEY (position_id) REFERENCES "position"(id) ON UPDATE CASCADE ON DELETE RESTRICT;
--
-- Definition for index employee_group_detail_fk (OID = 18495) : 
--
ALTER TABLE ONLY employee_group_detail
    ADD CONSTRAINT employee_group_detail_fk
    FOREIGN KEY (employee_group_id) REFERENCES "group"(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Definition for index faq_fk (OID = 18500) : 
--
ALTER TABLE ONLY faq
    ADD CONSTRAINT faq_fk
    FOREIGN KEY (category_faq_id) REFERENCES category_faq(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Definition for index role_fk (OID = 18505) : 
--
ALTER TABLE ONLY role
    ADD CONSTRAINT role_fk
    FOREIGN KEY (menu_id) REFERENCES menu(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Definition for index role_fk1 (OID = 18510) : 
--
ALTER TABLE ONLY role
    ADD CONSTRAINT role_fk1
    FOREIGN KEY (group_id) REFERENCES "group"(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Definition for index task_detail_fk (OID = 18515) : 
--
ALTER TABLE ONLY task_detail
    ADD CONSTRAINT task_detail_fk
    FOREIGN KEY (task_id) REFERENCES task(task_id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Definition for index task_report_fk (OID = 18520) : 
--
ALTER TABLE ONLY task_report
    ADD CONSTRAINT task_report_fk
    FOREIGN KEY (task_id) REFERENCES task(task_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
--
-- Definition for index user_fk (OID = 18525) : 
--
ALTER TABLE ONLY "user"
    ADD CONSTRAINT user_fk
    FOREIGN KEY (group_id) REFERENCES "group"(id) ON UPDATE CASCADE ON DELETE CASCADE;
--
-- Definition for index participant_pkey (OID = 18552) : 
--
SET search_path = participant, pg_catalog;
ALTER TABLE ONLY participant
    ADD CONSTRAINT participant_pkey
    PRIMARY KEY (id);
--
-- Definition for index event_pkey (OID = 18604) : 
--
SET search_path = event, pg_catalog;
ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey
    PRIMARY KEY (id);
--
-- Definition for index event_category_pkey (OID = 18613) : 
--
ALTER TABLE ONLY event_category
    ADD CONSTRAINT event_category_pkey
    PRIMARY KEY (id);
--
-- Definition for index event_package_pkey (OID = 18622) : 
--
ALTER TABLE ONLY event_package
    ADD CONSTRAINT event_package_pkey
    PRIMARY KEY (id);
--
-- Data for sequence public.article_theme_article_theme_id_seq (OID = 18215)
--
SET search_path = public, pg_catalog;
SELECT pg_catalog.setval('article_theme_article_theme_id_seq', 2, true);
--
-- Data for sequence public.chat_id_seq (OID = 18247)
--
SELECT pg_catalog.setval('chat_id_seq', 14, true);
--
-- Data for sequence public.participant_participant_id_seq (OID = 18320)
--
SELECT pg_catalog.setval('participant_participant_id_seq', 1, false);
--
-- Data for sequence public.participant_category_participant_category_id_seq (OID = 18330)
--
SELECT pg_catalog.setval('participant_category_participant_category_id_seq', 2, true);
--
-- Data for sequence public.participant_detail_participant_detail_id_seq (OID = 18340)
--
SELECT pg_catalog.setval('participant_detail_participant_detail_id_seq', 362, true);
--
-- Comments
--
COMMENT ON SCHEMA public IS 'standard public schema';
SET search_path = participant, pg_catalog;
COMMENT ON COLUMN participant.participant.memo_lines1 IS 'ini buat bill dll';
