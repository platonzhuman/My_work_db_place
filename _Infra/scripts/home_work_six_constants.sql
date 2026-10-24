-- правила и константы

-- 1. правила проверки параметров
create table if not exists public.parameter_validation (
	parameter_type_id int primary key references public.parameter_types (id),
	min_value numeric,
	max_value numeric,
	scale smallint not null default 0,
	error_message text not null
);

insert into public.parameter_validation
	(parameter_type_id, min_value, max_value, scale, error_message)
values
	(1, null, null, 0, 'высота метеопоста = целое число'),
	(2, -58, 58, 1, 'температура диапазоном от -58 до 58 + один знак после запятой!'),
	(3, 500, 900, 0, 'давление целое число от 500 до 900'),
	(4, 0, 59, 0, 'направление ветра целое число от 0 до 59'),
	(5, 0, 15, 0, 'скорость ветра целое число от 0 до 15'),
	(6, 0, 150, 0, 'дальность сноса пуль целое число от 0 до 150')
on conflict (parameter_type_id) do update
set min_value = excluded.min_value,
	max_value = excluded.max_value,
	scale = excluded.scale,
	error_message = excluded.error_message;

-- 2. константы метео
create table if not exists public.meteo_constants (
	code text primary key,
	value numeric not null,
	description text
);

insert into public.meteo_constants (code, value, description)
values
	('pressure_base', 750, 'Табличное наземное давление, мм рт. ст.'),
	('temperature_base', 15.9, 'Табличная наземная виртуальная температура, °C')
on conflict (code) do update
set value = excluded.value,
	description = excluded.description;
