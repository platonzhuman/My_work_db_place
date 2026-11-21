-- время
do $$
declare
	d date := '2020-01-01';
begin
	drop table if exists dim_time cascade;

	create table dim_time
	(
		code integer primary key,
		month_start date not null,
		month_end date not null,
		month_name text not null,
		year integer not null,
		quarter_number integer not null,
		quarter_name text not null
	);

	while d <= '2026-12-01' loop
		insert into dim_time(code, month_start, month_end, month_name, year, quarter_number, quarter_name)
		values(
			to_char(d, 'YYYYMM')::int,
			d,
			(d + interval '1 month - 1 day')::date,
			case extract(month from d)::int
				when 1 then 'Январь'
				when 2 then 'Февраль'
				when 3 then 'Март'
				when 4 then 'Апрель'
				when 5 then 'Май'
				when 6 then 'Июнь'
				when 7 then 'Июль'
				when 8 then 'Август'
				when 9 then 'Сентябрь'
				when 10 then 'Октябрь'
				when 11 then 'Ноябрь'
				when 12 then 'Декабрь'
			end,
			extract(year from d)::int,
			extract(quarter from d)::int,
			'Q' || extract(quarter from d)::int
		);

		d := (d + interval '1 month')::date;
	end loop;
end $$;