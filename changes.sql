-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

ALTER TABLE merchants DROP CONSTRAINT merchants_requires_fkey,
ADD CONSTRAINT merchants_requires_fkey FOREIGN KEY (requires) REFERENCES requirements(name) ON UPDATE CASCADE;
-- VATH
UPDATE requirements SET name='Friendly with the Vath' WHERE name='Neutral with the Vath';
INSERT INTO requirements (name, icon) VALUES ('Trusted with the Vath', 'icons/traits/vath.png');
INSERT INTO requirements (name, icon) VALUES ('Respected with the Vath', 'icons/traits/vath.png');
INSERT INTO requirements (name, icon) VALUES ('Honored with the Vath', 'icons/traits/vath.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Vath', 'icons/traits/vath.png');
INSERT INTO requirements (name, icon) VALUES ('Bloodsworn with the Vath', 'icons/traits/vath.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Vath', 'icons/traits/vath.png');

-- VANU VANU
INSERT INTO requirements (name, icon) VALUES ('Recognized with the Vanu Vanu', 'icons/traits/vanu.png');
INSERT INTO requirements (name, icon) VALUES ('Friendly with the Vanu Vanu', 'icons/traits/vanu.png');
INSERT INTO requirements (name, icon) VALUES ('Trusted with the Vanu Vanu', 'icons/traits/vanu.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Vanu Vanu', 'icons/traits/vanu.png');
INSERT INTO requirements (name, icon) VALUES ('Bloodsworn with the Vanu Vanu', 'icons/traits/vanu.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Vanu Vanu', 'icons/traits/vanu.png');

-- MOOGLES
INSERT INTO requirements (name, icon) VALUES ('Recognized with the Moogles', 'icons/traits/moogles.png');
INSERT INTO requirements (name, icon) VALUES ('Honored with the Moogles', 'icons/traits/moogles.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Moogles', 'icons/traits/moogles.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Moogles', 'icons/traits/moogles.png');

-- ANANTA
UPDATE requirements SET name='Friendly with the Ananta' WHERE name='Neutral with the Ananta';
INSERT INTO requirements (name, icon) VALUES ('Trusted with the Ananta', 'icons/traits/ananta.png');
INSERT INTO requirements (name, icon) VALUES ('Respected with the Ananta', 'icons/traits/ananta.png');
INSERT INTO requirements (name, icon) VALUES ('Honored with the Ananta', 'icons/traits/ananta.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Ananta', 'icons/traits/ananta.png');
INSERT INTO requirements (name, icon) VALUES ('Bloodsworn with the Ananta', 'icons/traits/ananta.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Ananta', 'icons/traits/ananta.png');

-- KOJIN
UPDATE requirements SET name='Friendly with the Kojin' WHERE name='Neutral with the Kojin';
INSERT INTO requirements (name, icon) VALUES ('Trusted with the Kojin', 'icons/traits/kojin.png');
INSERT INTO requirements (name, icon) VALUES ('Respected with the Kojin', 'icons/traits/kojin.png');
INSERT INTO requirements (name, icon) VALUES ('Honored with the Kojin', 'icons/traits/kojin.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Kojin', 'icons/traits/kojin.png');
INSERT INTO requirements (name, icon) VALUES ('Bloodsworn with the Kojin', 'icons/traits/kojin.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Kojin', 'icons/traits/kojin.png');

-- NAMAZU
UPDATE requirements SET name='Friendly with the Namazu' WHERE name='Neutral with the Namazu';
INSERT INTO requirements (name, icon) VALUES ('Trusted with the Namazu', 'icons/traits/namazu.png');
INSERT INTO requirements (name, icon) VALUES ('Respected with the Namazu', 'icons/traits/namazu.png');
INSERT INTO requirements (name, icon) VALUES ('Honored with the Namazu', 'icons/traits/namazu.png');
INSERT INTO requirements (name, icon) VALUES ('Sworn with the Namazu', 'icons/traits/namazu.png');
INSERT INTO requirements (name, icon) VALUES ('Bloodsworn with the Namazu', 'icons/traits/namazu.png');
INSERT INTO requirements (name, icon) VALUES ('Allied with the Namazu', 'icons/traits/namazu.png');

ALTER TABLE merchants DROP CONSTRAINT merchants_requires_fkey,
ADD CONSTRAINT merchants_requires_fkey FOREIGN KEY (requires) REFERENCES requirements(name);

CREATE OR REPLACE FUNCTION ffxiv.get_merchant_sale(
	saleid integer)
    RETURNS json
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
AS $BODY$
    SELECT json_build_object(
        'price', get_merchant_price(merchant_sales),
        'good', get_merchant_good(merchant_sales),
		'requires', get_requirement(requires)
    )
    FROM merchant_sales
    WHERE id = $1;
$BODY$;