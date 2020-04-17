INSERT INTO immaterials (name, icon) VALUES ('Allagan Tomestone of Allegory', 'https://img.finalfantasyxiv.com/lds/h/v/5hVA8b-7wC0tZCNGBUd1qIwfhk.png');
INSERT INTO immaterials (name, icon) VALUES ('Qitari Compliment', 'https://img.finalfantasyxiv.com/lds/h/x/71DnHjS2z9_95m_WD2AtXDUvy8.png
');
INSERT INTO immaterials (name, icon) VALUES ('Bicolor Gemstone', 'https://img.finalfantasyxiv.com/lds/h/W/kW0wEgCx11OPstDtIobm97N1ps.png');
INSERT INTO beast_tribes (name, currency) VALUES ('Qitari', 'Qitari Compliment');

INSERT INTO requirements (name, icon) VALUES ('Friendly with the Qitari', 'icons/traits/qitari.png'),  ('Trusted with the Qitari', 'icons/traits/qitari.png'),  ('Respected with the Qitari', 'icons/traits/qitari.png'),  ('Honored with the Qitari', 'icons/traits/qitari.png'),  ('Sworn with the Qitari', 'icons/traits/qitari.png'),  ('Bloodsworn with the Qitari', 'icons/traits/qitari.png'),
('Trusted with the Pixies', 'icons/traits/pixies.png'),  ('Respected with the Pixies', 'icons/traits/pixies.png'),  ('Honored with the Pixies', 'icons/traits/pixies.png'),  ('Sworn with the Pixies', 'icons/traits/pixies.png'),  ('Bloodsworn with the Pixies', 'icons/traits/pixies.png');

ALTER TABLE recipes
    ADD COLUMN expert boolean not null default false;