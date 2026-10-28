-- тип, проверка, метео
do $$
begin
	-- 1. тип список параметров
	begin
		drop type if exists public.parameter_list cascade;
	end;
	commit;

	begin
		create type public.parameter_list as (
			eq_type_id integer,
			height numeric(8, 2),
			temperature numeric(8, 2),
			pressure numeric(8, 2),
			wind_direction numeric(8, 2),
			wind_speed numeric(8, 2),
			drift_range numeric(8, 2)
		);
	end;
	commit;

	-- 2. проверка параметров с CTE
	begin
		drop function if exists public.validate_parameters(public.parameter_list);

		create function public.validate_parameters(p public.parameter_list)
		returns text
		language sql
		stable
		as $body$
			with params(parameter_type_id, value) as (
				values
					(1, (p).height),
					(2, (p).temperature),
					(3, (p).pressure),
					(4, (p).wind_direction),
					(5, (p).wind_speed),
					(6, (p).drift_range)
			)
			select string_agg(r.error_message, '; ' order by v.parameter_type_id)
			from params v
			join public.parameter_validation r
				on r.parameter_type_id = v.parameter_type_id
			where (r.min_value is not null and v.value < r.min_value)
			   or (r.max_value is not null and v.value > r.max_value);
		$body$;
	end;
	commit;

	-- 3. ДДЧЧМ
	begin
		drop function if exists public.meteo_ddchchm(timestamp);

		create function public.meteo_ddchchm(
			p_ts timestamp default localtimestamp
		)
		returns text
		language plpgsql
		as $body$
		begin
			return to_char(p_ts, 'DDHH24')
				|| (extract(minute from p_ts)::integer / 10)::text;
		end
		$body$;
	end;
	commit;

	-- 4. ВВВВ
	begin
		drop function if exists public.meteo_vvvv(numeric);

		create function public.meteo_vvvv(p_height numeric)
		returns text
		language plpgsql
		as $body$
		begin
			if p_height is null then
				return null;
			end if;

			if p_height < 0 then
				return '-' || to_char(abs(p_height), 'FM000');
			end if;

			return to_char(p_height, 'FM0000');
		end
		$body$;
	end;
	commit;

	-- 5. БББТТ
	begin
		drop function if exists public.meteo_bbbtt(numeric, numeric);

		create function public.meteo_bbbtt(
			p_pressure numeric,
			p_temperature numeric
		)
		returns text
		language plpgsql
		as $body$
		declare
			v_dp integer := round(
				p_pressure - (select value from public.meteo_constants where code = 'pressure_base')
			)::integer;
			v_dt integer := round(
				p_temperature
				+ public.interpolate(
					p_temperature,
					public.get_interpolation_type_correction(p_temperature)
				) - (select value from public.meteo_constants where code = 'temperature_base')
			)::integer;
			v_bbb text;
			v_tt text;
		begin
			if v_dp < 0 then
				v_bbb := '5' || to_char(abs(v_dp), 'FM00');
			else
				v_bbb := to_char(v_dp, 'FM000');
			end if;

			if v_dt < 0 then
				v_tt := (50 + abs(v_dt))::text;
			else
				v_tt := to_char(v_dt, 'FM00');
			end if;

			return v_bbb || v_tt;
		end
		$body$;
	end;
	commit;
end $$;
