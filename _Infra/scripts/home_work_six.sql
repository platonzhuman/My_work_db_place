-- тип, проверка, метео

-- 1. тип список параметров
drop type if exists public.parameter_list cascade;

create type public.parameter_list as (
	eq_type_id integer,
	height numeric(8, 2),
	temperature numeric(8, 2),
	pressure numeric(8, 2),
	wind_direction numeric(8, 2),
	wind_speed numeric(8, 2),
	drift_range numeric(8, 2)
);

-- 2. проверка параметров
create or replace function public.validate_parameters(p public.parameter_list)
returns text
language sql
stable
as $body$
	select nullif(string_agg(r.error_message, '; '), '')
	from (
		values
			(1, p.height),
			(2, p.temperature),
			(3, p.pressure),
			(4, p.wind_direction),
			(5, p.wind_speed),
			(6, p.drift_range)
	) v(parameter_type_id, value)
	join public.parameter_validation r
		on r.parameter_type_id = v.parameter_type_id
	-- проверяем выход за диапазон
	where (r.min_value is not null and v.value < r.min_value)
	   or (r.max_value is not null and v.value > r.max_value);
$body$;

-- 3. ДДЧЧМ
create or replace function public.meteo_ddchchm(
	p_ts timestamp default localtimestamp
)
returns text
language sql
stable
as $body$
	select to_char(p_ts, 'DDHH24')
		|| (extract(minute from p_ts)::integer / 10)::text;
$body$;

-- 4. ВВВВ
create or replace function public.meteo_vvvv(p_height numeric)
returns text
language sql
immutable
as $body$
	select case
		when p_height is null then null
		when p_height < 0
			then '-' || lpad(abs(p_height)::integer::text, 3, '0')
		else lpad(p_height::integer::text, 4, '0')
	end;
$body$;

-- 5. БББТТ
create or replace function public.meteo_bbbtt(
	p_pressure numeric,
	p_temperature numeric
)
returns text
language plpgsql
stable
as $body$
declare
	v_pressure_base numeric;
	v_temperature_base numeric;
	v_delta_p integer;
	v_delta_t integer;
	v_bbb text;
	v_tt text;
	v_point public.interpolation_type;
begin
	if p_pressure is null or p_temperature is null then
		return null;
	end if;

	select value into v_pressure_base
	from public.meteo_constants
	where code = 'pressure_base';

	select value into v_temperature_base
	from public.meteo_constants
	where code = 'temperature_base';

	if v_pressure_base is null or v_temperature_base is null then
		raise exception
			'В meteo_constants не найдены значения';
	end if;

	v_delta_p := round(p_pressure - v_pressure_base)::integer;

	v_point := public.get_interpolation_type_correction(p_temperature);
	v_delta_t := round(
		p_temperature
		+ public.interpolate(p_temperature, v_point)
		- v_temperature_base
	)::integer;

	v_bbb := case
		when v_delta_p < 0
			then '5' || lpad(abs(v_delta_p)::text, 2, '0')
		else lpad(v_delta_p::text, 3, '0')
	end;

	v_tt := case
		when v_delta_t < 0
			then (50 + abs(v_delta_t))::text
		else lpad(v_delta_t::text, 2, '0')
	end;

	return v_bbb || v_tt;
end
$body$;
