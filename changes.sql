DROP VIEW vzones;
CREATE VIEW ffxiv.vzones
AS
WITH z AS (
    SELECT
        z.gid,
        z.name,
        z.code,
        CASE
            WHEN s.geom IS NULL THEN z.geom
            ELSE s.geom
        END AS geom,
        z.a,
        z.b,
        z.e,
        z.f,
        CASE
            WHEN s.geom IS NULL THEN st_xmin(z.geom::box3d)
            ELSE st_xmin(s.geom::box3d)
        END AS c,
        CASE
            WHEN s.geom IS NULL THEN st_xmax(z.geom::box3d)
            ELSE st_xmax(s.geom::box3d)
        END AS d,
        CASE
            WHEN s.geom IS NULL THEN st_ymin(z.geom::box3d)
            ELSE st_ymin(s.geom::box3d)
        END AS h,
        CASE
            WHEN s.geom IS NULL THEN st_ymax(z.geom::box3d)
            ELSE st_ymax(s.geom::box3d)
        END AS g
    FROM zones z
        LEFT JOIN zones_square s ON z.name = s.zone
), zz as (
    SELECT
        gid, name, code, geom, a, b, c, d, e, f, g, h,
        (d - c)::double precision / (b - a)::double precision AS mxge,
        (b - a)::double precision / (d - c)::double precision AS mxeg,
        (h - g)::double precision / (f - e)::double precision AS myge,
        (e - f)::double precision / (g - h)::double precision AS myeg
    FROM z
)
SELECT
    gid, name, code, geom, a, b, c, d, e, f, g, h,
    mxge,
    (c-mxge*a) as nxge,
    mxeg,
    (a-mxeg*c) as nxeg,
    myge,
    (g-myge*e) as nyge,
    myeg,
    (f-myeg*h) as nyeg
FROM zz;
   
GRANT SELECT ON TABLE ffxiv.vzones TO ffxivro;

DROP VIEW all_zones;
CREATE VIEW ffxiv.all_zones
 AS
WITH iz AS (
SELECT name,
    code,
    geom,
    a,
    b,
    e,
    f,
    st_xmin(geom::box3d) AS c,
    st_xmax(geom::box3d) AS d,
    st_ymin(geom::box3d) AS h,
    st_ymax(geom::box3d) AS g
FROM invis_zones
), izz AS (
    SELECT name, code, geom, a, b, c, d, e, f, g, h,
        (d - c)::double precision / (b - a)::double precision AS mxge,
        (b - a)::double precision / (d - c)::double precision AS mxeg,
        (h - g)::double precision / (f - e)::double precision AS myge,
        (e - f)::double precision / (g - h)::double precision AS myeg
    FROM iz
), izzz AS (
    SELECT
        name, code, geom, a, b, c, d, e, f, g, h,
        mxge,
        (c-mxge*a) as nxge,
        mxeg,
        (a-mxeg*c) as nxeg,
        myge,
        (g-myge*e) as nyge,
        myeg,
        (f-myeg*h) as nyeg
    FROM izz
)
SELECT
    name, code, geom, a, b, c, d, e, f, g, h, 
    mxge, 
    mxeg, 
    myge, 
    myeg, 
    nxge, 
    nxeg, 
    nyge, 
    nyeg
FROM izzz

UNION

SELECT
    name, code, geom, a, b, c, d, e, f, g, h, 
    mxge, 
    mxeg, 
    myge, 
    myeg, 
    nxge, 
    nxeg, 
    nyge, 
    nyeg
FROM vzones;
   
GRANT SELECT ON TABLE ffxiv.all_zones TO ffxivro;