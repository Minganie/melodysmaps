-- pg_dump -F c -f ffxiv20190829.backup ffxiv
-- cd D:\Programmes\Postgres\11\bin
-- cd C:\Program Files\PostgreSQL\11\bin
-- pg_restore.exe -U postgres -d postgres --clean --create D:\Programmes\xampp\htdocs\melodysmaps\ffxiv20190716.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190829.backup

CREATE TABLE quest_action_requirements (
    questlid text references quests(lid),
    action text references requirements(name),
    primary key (questlid, action)
);
GRANT SELECT ON quest_action_requirements TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON quest_action_requirements TO ffxivrw;
