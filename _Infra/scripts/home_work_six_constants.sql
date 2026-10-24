-- правила и константы
do $$
begin
	-- 1. правила проверки параметров
	begin
		drop table if exists public.parameter_validation;
		drop sequence if exists public.seq_parameter_validation;
	end;
	commit;

	begin
		create table public.parameter_validation (
			id integer not null,
			parameter_type_id integer not null references public.parameter_types (id),
			min_value numeric,
			max_value numeric,
			error_message text not null
		);

		create sequence public.seq_parameter_validation;
		alter table public.parameter_validation
			alter column id set default nextval('public.seq_parameter_validation');

		alter table public.parameter_validation
			add primary key (id);

		alter table public.parameter_validation
			add constraint uq_parameter_validation_type unique (parameter_type_id);

		insert into public.parameter_validation
			(parameter_type_id, min_value, max_value, error_message)
		values
			(1, null, null, 'высота метеопоста = целое число'),
			(2, -58, 58, 'температура диапазоном от -58 до 58 + один знак после запятой!'),
			(3, 500, 900, 'давление целое число от 500 до 900'),
			(4, 0, 59, 'направление ветра целое число от 0 до 59'),
			(5, 0, 15, 'скорость ветра целое число от 0 до 15'),
			(6, 0, 150, 'дальность сноса пуль целое число от 0 до 150');
	end;
	commit;

	-- 2. константы метео
	begin
		drop table if exists public.meteo_constants;
		drop sequence if exists public.seq_meteo_constants;
	end;
	commit;

	begin
		create table public.meteo_constants (
			id integer not null,
			code text not null,
			value numeric not null,
			description text
		);

		create sequence public.seq_meteo_constants;
		alter table public.meteo_constants
			alter column id set default nextval('public.seq_meteo_constants');

		alter table public.meteo_constants
			add primary key (id);

		alter table public.meteo_constants
			add constraint uq_meteo_constants_code unique (code);

		insert into public.meteo_constants (code, value, description)
		values
			('pressure_base', 750, 'табличное наземное давление, мм рт. ст.'),
			('temperature_base', 15.9, 'табличная наземная виртуальная температура, *C');
	end;
	commit;
end $$;
