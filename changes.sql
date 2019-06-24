-- pg_dump -F c -f ffxiv20190624.backup ffxiv
-- pg_restore.exe -U postgres -d postgres --create D:\Programmes\xampp\htdocs\melodysmaps\ffxivall20190521.backup
-- pg_restore.exe -U postgres -d postgres --clean --create C:\xampp\htdocs\melodysmaps\ffxiv20190624.backup
ALTER DATABASE ffxiv SET search_path TO ffxiv, public;

DROP TABLE IF EXISTS bought_where_payment;
DROP TABLE IF EXISTS bought_where;
DROP TABLE IF EXISTS merchant_prices_list;
DROP TABLE IF EXISTS merchant_goods_list;
DROP TABLE IF EXISTS merchant_sales;
DROP TABLE IF EXISTS merchant_second_tabs;
DROP TABLE IF EXISTS merchant_first_tabs;
DROP TABLE IF EXISTS merchant_currency_tabs;
DROP TABLE IF EXISTS merchant_goods;
DROP TABLE IF EXISTS merchant_prices;
DROP TYPE IF EXISTS merchant_sale_type;
DROP TYPE IF EXISTS merchant_good_type;
DROP TYPE IF EXISTS merchant_price_type;

DROP TRIGGER add_merchant_lid ON ffxiv.merchants;
DROP TRIGGER replace_merchant_lid ON ffxiv.merchants;

CREATE TYPE merchant_sale_type AS ENUM ('Gil', 'Currency', 'Seals', 'Credits');
CREATE TABLE merchant_first_tabs (
    merchant text references merchants(lid),
    type merchant_sale_type not null,
    tab      text,
    PRIMARY KEY (merchant, type, tab)
);
GRANT SELECT ON merchant_first_tabs TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_first_tabs TO ffxivrw;

CREATE TABLE merchant_second_tabs (
    merchant text,
    type merchant_sale_type not null,
    tab      text,
    subtab   text,
    FOREIGN KEY (merchant, type, tab) REFERENCES merchant_first_tabs(merchant, type, tab),
    PRIMARY KEY (merchant, type, tab, subtab)
);
GRANT SELECT ON merchant_second_tabs TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_second_tabs TO ffxivrw;

CREATE TYPE merchant_good_type AS ENUM ('Items', 'Venture', 'Action');
CREATE TYPE merchant_price_type AS ENUM ('Gil', 'Items', 'Tokens and Items', 'Tokens', 'Seals', 'FCC');
CREATE TABLE merchant_sales (
    id SERIAL PRIMARY KEY,
    merchant text references merchants(lid),
    type merchant_sale_type NOT NULL,
    tab text,
    subtab text,
    -- GOOD
    good_type merchant_good_type not null,
    venture int,
    actionName text,
    actionIcon text,
    actionEffect text,
    actionDuration int,
    -- PRICE
    price_type merchant_price_type not null,
    gil int,
    token_name text,
    token_n int,
    seals int,
    rank text references grand_company_ranks(name),
    gc text references grand_companies(name),
    fcc_rank int,
    fcc_credits int,
    
    FOREIGN KEY (merchant, type, tab) REFERENCES merchant_first_tabs(merchant, type, tab),
    FOREIGN KEY (merchant, type, tab, subtab) REFERENCES merchant_second_tabs (merchant, type, tab, subtab)
);
GRANT SELECT ON merchant_sales TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_sales TO ffxivrw;
GRANT USAGE ON merchant_sales_id_seq TO ffxivro;

CREATE TABLE merchant_goods_list (
    merchant_sale int REFERENCES merchant_sales(id) ON DELETE CASCADE,
    item text references items(lid),
    hq boolean,
    n int not null,
    primary key(merchant_sale, item, hq)
);
GRANT SELECT ON merchant_goods_list TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_goods_list TO ffxivrw;

CREATE TABLE merchant_prices_list (
    merchant_sale int REFERENCES merchant_sales(id) ON DELETE CASCADE,
    item text references items(lid),
    hq boolean,
    n int not null,
    primary key(merchant_sale, item, hq)
);
GRANT SELECT ON merchant_prices_list TO ffxivro;
GRANT INSERT, UPDATE, DELETE ON merchant_prices_list TO ffxivrw;

-- get_all_tabs(merchantlid)
-- {
    -- gil: {zero: [sale, sale...]
        -- one: [tab, tab...]
        -- }
    -- currency: []
    -- seals:
    -- credits:
-- }
-- tab= {
    -- name: ""
    -- sales: [sale, sale...]
    -- subtabs: [tab, tab...]
-- }
-- sale= {
    -- good: {item, venture, action}
    -- price: {gil, item, token, itemtoken, fcc}
-- }
with 

these_sales as (
select merchant, tab, subtab, id
from merchant_sales where merchant='a783601ac62' and type='Gil'::merchant_sale_type
),

zero as (
select json_agg(id) as sales
from these_sales
where tab IS NULL AND subtab IS NULL),

twot as (select merchant, tab, subtab, json_agg(id) as sales
from merchant_sales 
where merchant='a783601ac62' and type='Gil'::merchant_sale_type
group by merchant, tab, subtab),
onetwithtwot as (
select tab, json_agg(row_to_json((select x from (select subtab as name, sales)x))) as subtabs
from twot
group by tab
),
alltwithtwot as (
select json_agg(row_to_json((select x from (select tab as name, subtabs)x)))
from onetwithtwot
)
select * from zero
-- get currencies
-- get currency
-- get item merchants
-- get_merchant
-- get merchants