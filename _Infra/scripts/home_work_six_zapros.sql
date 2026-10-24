-- запросы

-- 1. список параметров с ошибками
with pack_data as (
	select
		p.id as pack_id,
		p.eq_type_id,
		et.name as eq_type,
		count(par.id) as parameter_count,
		max(par.value) filter (where par.parameter_type_id = 1) as height,
		max(par.value) filter (where par.parameter_type_id = 2) as temperature,
		max(par.value) filter (where par.parameter_type_id = 3) as pressure,
		max(par.value) filter (where par.parameter_type_id = 4) as wind_direction,
		max(par.value) filter (where par.parameter_type_id = 5) as wind_speed,
		max(par.value) filter (where par.parameter_type_id = 6) as drift_range
	from public.packs p
	join public.eq_types et on et.id = p.eq_type_id
	left join public.parametrs par on par.pack_id = p.id
	group by p.id, p.eq_type_id, et.name
),
checked as (
	select
		pd.*,
		public.validate_parameters(
			(pd.eq_type_id, pd.height, pd.temperature, pd.pressure,
			 pd.wind_direction, pd.wind_speed, pd.drift_range)::public.parameter_list
		) as range_errors,
		case
			when pd.parameter_count <> 5
				then 'количество параметров не 5'
		end as count_error
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
	(range_errors is not null or count_error is not null) as "флаг ошибок",
	nullif(concat_ws('; ', range_errors, count_error), '') as "описание ошибки"
from checked
order by pack_id;

-- 2. лучший стрелок
with user_errors as (
	select
		u.id,
		u.full_name,
		count(par.id) filter (
			where (v.min_value is not null and par.value < v.min_value)
			   or (v.max_value is not null and par.value > v.max_value)
		) as errors
	from public.users u
	left join public.packs p on p.user_id = u.id
	left join public.parametrs par on par.pack_id = p.id
	left join public.parameter_validation v
		on v.parameter_type_id = par.parameter_type_id
	group by u.id, u.full_name
)
select
	full_name as "пользователь",
	errors as "количество ошибок"
from user_errors
order by errors, full_name;
