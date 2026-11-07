-- запросы

-- 1. список параметров с ошибками
with pack_data as (
	select
		p.id as pack_id,
		p.eq_type_id,
		et.name as eq_type,
		h.value as height,
		t.value as temperature,
		pr.value as pressure,
		wd.value as wind_direction,
		ws.value as wind_speed,
		dr.value as drift_range
	from public.packs p
	join public.eq_types et on et.id = p.eq_type_id
	left join public.parametrs h on h.pack_id = p.id and h.parameter_type_id = 1
	left join public.parametrs t on t.pack_id = p.id and t.parameter_type_id = 2
	left join public.parametrs pr on pr.pack_id = p.id and pr.parameter_type_id = 3
	left join public.parametrs wd on wd.pack_id = p.id and wd.parameter_type_id = 4
	left join public.parametrs ws on ws.pack_id = p.id and ws.parameter_type_id = 5
	left join public.parametrs dr on dr.pack_id = p.id and dr.parameter_type_id = 6
),
checked as (
	select
		pd.*,
		public.validate_parameters(
			(pd.eq_type_id, pd.height, pd.temperature, pd.pressure,
			 pd.wind_direction, pd.wind_speed, pd.drift_range)::public.parameter_list
		) as range_errors
	from pack_data pd
)
select
	pack_id as "N*",
	eq_type as "тип оборудования",
	height as "высота метеопоста",
	temperature as "температура",
	pressure as "давление",
	wind_direction as "направление ветра",
	wind_speed as "скорость ветра",
	drift_range as "дальность сноса пуль",
	(range_errors is not null) as "флаг ошибок",
	range_errors as "описание ошибки"
from checked
order by pack_id;

-- 2. лучший стрелок
with pack_data as (
	select
		p.id as pack_id,
		p.user_id,
		p.eq_type_id,
		h.value as height,
		t.value as temperature,
		pr.value as pressure,
		wd.value as wind_direction,
		ws.value as wind_speed,
		dr.value as drift_range
	from public.packs p
	left join public.parametrs h on h.pack_id = p.id and h.parameter_type_id = 1
	left join public.parametrs t on t.pack_id = p.id and t.parameter_type_id = 2
	left join public.parametrs pr on pr.pack_id = p.id and pr.parameter_type_id = 3
	left join public.parametrs wd on wd.pack_id = p.id and wd.parameter_type_id = 4
	left join public.parametrs ws on ws.pack_id = p.id and ws.parameter_type_id = 5
	left join public.parametrs dr on dr.pack_id = p.id and dr.parameter_type_id = 6
),
checked as (
	select
		pd.*,
		public.validate_parameters(
			(pd.eq_type_id, pd.height, pd.temperature, pd.pressure,
			 pd.wind_direction, pd.wind_speed, pd.drift_range)::public.parameter_list
		) as errors
	from pack_data pd
),
user_errors as (
	select
		u.id,
		u.full_name,
		count(c.errors) as errors
	from public.users u
	left join checked c on c.user_id = u.id
	group by u.id, u.full_name
)
select
	full_name as "пользователь",
	errors as "количество ошибок"
from user_errors
order by errors, full_name;
