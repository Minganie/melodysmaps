-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

ALTER TABLE cbh_fish_weathers 
	DROP CONSTRAINT cbh_fish_weathers_weather_fkey, 
	ADD CONSTRAINT cbh_fish_weathers_weather_fkey FOREIGN KEY (weather) REFERENCES weather (name) ON UPDATE CASCADE;
ALTER TABLE sightseeing_weather
	DROP CONSTRAINT sightseeing_weather_weather_fkey,
	ADD CONSTRAINT sightseeing_weather_weather_fkey FOREIGN KEY (weather) REFERENCES weather(name) ON UPDATE CASCADE;
ALTER TABLE weather_gathering
	DROP CONSTRAINT weather_gathering_weather_fkey,
	ADD CONSTRAINT weather_gathering_weather_fkey FOREIGN KEY (weather) REFERENCES weather(name) ON UPDATE CASCADE;

UPDATE weather SET name='Blizzards' WHERE name='Blizzard';