-- измерения

-- диапазоны
do $$
begin
	drop table if exists dim_ranges cascade;
	drop sequence if exists seq_dim_ranges;

	create sequence public.seq_dim_ranges;

	create table dim_ranges
	(
		id bigint primary key default nextval('public.seq_dim_ranges'),
		external_id bigint,
		name text,
		factor float,
		date_add timestamp default now()
	);
end $$;


-- категории
do $$
begin
	drop table if exists dim_categories cascade;
	drop sequence if exists seq_dim_categories;

	create sequence public.seq_dim_categories;

	create table dim_categories
	(
		id bigint primary key default nextval('public.seq_dim_categories'),
		external_id bigint,
		name text,
		parent_id bigint,
		date_add timestamp default now()
	);
end $$;


-- поставщики
do $$
begin
	drop table if exists dim_vendors cascade;
	drop sequence if exists seq_dim_vendors;

	create sequence public.seq_dim_vendors;

	create table dim_vendors
	(
		id bigint primary key default nextval('public.seq_dim_vendors'),
		external_id bigint,
		name text,
		parent_id bigint,
		parent_name text,
		date_add timestamp default now()
	);
end $$;


-- товары
do $$
begin
	drop table if exists dim_products cascade;
	drop sequence if exists seq_dim_products;

	create sequence public.seq_dim_products;

	create table dim_products
	(
		id bigint primary key default nextval('public.seq_dim_products'),
		external_id bigint,
		name text,
		category_id bigint,
		vendor_id bigint,
		range_id bigint,
		date_add timestamp default now()
	);
end $$;


-- сотрудники
do $$
begin
	drop table if exists dim_personnel cascade;
	drop sequence if exists seq_dim_personnel;

	create sequence public.seq_dim_personnel;

	create table dim_personnel
	(
		id bigint primary key default nextval('public.seq_dim_personnel'),
		external_id bigint,
		lastname text,
		firstname text,
		securityaccess integer,
		date_add timestamp default now()
	);
end $$;


-- склады
do $$
begin
	drop table if exists dim_storages cascade;
	drop sequence if exists seq_dim_storages;

	create sequence public.seq_dim_storages;

	create table dim_storages
	(
		id bigint primary key default nextval('public.seq_dim_storages'),
		external_id bigint,
		name text,
		address text,
		date_add timestamp default now()
	);

end $$;


-- операции
do $$
begin
	drop table if exists dim_operations cascade;
	drop sequence if exists seq_dim_operations;

	create sequence public.seq_dim_operations;

	create table dim_operations
	(
		id bigint primary key default nextval('public.seq_dim_operations'),
		external_id bigint,
		name text,
		factor integer,
		date_add timestamp default now()
	);
end $$;


-- факты

-- закупка
do $$
begin
	drop table if exists fact_purchase cascade;
	drop sequence if exists seq_fact_purchase;

	create sequence public.seq_fact_purchase;

	create table fact_purchase
	(
		id bigint primary key default nextval('public.seq_fact_purchase'),
		time_code integer not null,
		product_id bigint,
		vendor_id bigint,
		documents integer,
		operations integer,
		qty numeric(14,4),
		amount numeric(14,2),
		date_add timestamp default now()
	);
end $$;


-- продажа
do $$
begin
	drop table if exists fact_sales cascade;
	drop sequence if exists seq_fact_sales;

	create sequence public.seq_fact_sales;

	create table fact_sales
	(
		id bigint primary key default nextval('public.seq_fact_sales'),
		time_code integer not null,
		product_id bigint,
		lines integer,
		receipts integer,
		qty numeric(14,3),
		amount numeric(14,2),
		date_add timestamp default now()
	);
end $$;


-- персонал
do $$
begin
	drop table if exists fact_personnel cascade;
	drop sequence if exists seq_fact_personnel;

	create sequence public.seq_fact_personnel;

	create table fact_personnel
	(
		id bigint primary key default nextval('public.seq_fact_personnel'),
		time_code integer not null,
		person_id bigint,
		sessions integer,
		date_add timestamp default now()
	);
end $$;


-- остатки
do $$
begin
	drop table if exists fact_inventory cascade;
	drop sequence if exists seq_fact_inventory;

	create sequence public.seq_fact_inventory;

	create table fact_inventory
	(
		id bigint primary key default nextval('public.seq_fact_inventory'),
		time_code integer not null,
		product_id bigint,
		storage_id bigint,
		operation_id bigint,
		operations integer,
		qty numeric(14,4),
		amount numeric(14,2),
		date_add timestamp default now()
	);
end $$;
