drop schema public cascade;
create schema public;
grant all on schema public to public;
comment on schema public is 'standard public schema';

-- TODO create person things separate from accounts that can own whatever
create table account (
	id uuid primary key default gen_random_uuid(),
	"name" text not null
);

create type project_status_enum as enum('DRAFT', 'PROPOSAL', 'CLOSED', 'FUNDED', 'COMPLETE', 'FAILED');
create table project (
	id uuid primary key default gen_random_uuid(),
	owner_id uuid not null references account(id),
	status project_status_enum not null,
	title text not null,
	-- funding_days smallint not null check(funding_days > 0),
	initial_amount numeric not null check(initial_amount >= 0),
	monthly_amount numeric not null check(monthly_amount >= 0),
	month_count smallint not null check(month_count >= 0),
	prize_amount numeric not null check(prize_amount >= 0)
);

create function project_base_funding_requirement(p project) returns numeric as $$
	select p.initial_amount + (p.monthly_amount * p.month_count)
$$ language sql stable;

create function project_funding_requirement(p project) returns numeric as $$
	select p.project_base_funding_requirement + p.prize_amount
$$ language sql stable;

create table project_update (
	id uuid primary key default gen_random_uuid(),
	project_id uuid references project(id),
	"text" text not null
);


create type project_payment_kind as enum('WITH_INITIAL', 'NORMAL_MONTHLY', 'PRIZE');
create table project_payment (
	project_id uuid not null references project(id),
	projected_date date not null,
	primary key (project_id, projected_date),
	amount numeric not null check(amount > 0),
	kind project_payment_kind not null,
	is_last bool not null,
	executed_at timestamp default null
);
create unique index project_projected_date_month_unique
on project_payment(project_id, date_trunc('month', projected_date::timestamp));


create table pledge (
	pledger_id uuid not null references account(id),
	project_id uuid not null references project(id),
	amount numeric not null
);


create table pledge_vote (
	pledger_id uuid not null references account(id),
	project_id uuid not null references project(id),
	primary key (pledger_id, project_id),
	should_continue bool not null
);
create function cast_vote(arg_pledger_id uuid, arg_project_id uuid, arg_should_continue bool) returns void as $$
	insert into pledge_vote (pledger_id, project_id, should_continue) values (arg_pledger_id, arg_project_id, arg_should_continue)
	on conflict (pledger_id, project_id) do
	update set should_continue = arg_should_continue
	where pledge_vote.pledger_id = arg_pledger_id and pledge_vote.project_id = arg_project_id
$$ language sql volatile strict security definer;



create function project_months_passed(p project) returns smallint as $$
	-- TODO consider storing this on the project table and updating when payments are made
	select count(*)
	from project_payment
	where project_id = p.id and executed_at is not null and kind != 'PRIZE'
$$ language sql stable;

create function project_funds_paid(p project) returns numeric as $$
	select sum(amount)
	from project_payment
	where project_id = p.id and executed_at is not null
$$ language sql stable;

create function project_total_pledger_count(p project) returns int as $$
	select count(distinct pledge.pledger_id)
	from pledge
	where pledge.project_id = p.id
$$ language sql stable;

create function project_total_pledged_amount(p project) returns numeric as $$
	select sum(amount)
	from pledge
	where pledge.project_id = p.id
$$ language sql stable;

create function project_actual_prize_amount(p project) returns numeric as $$
	select greatest(p.prize_amount, p.project_total_pledged_amount - p.project_base_funding_requirement)
$$ language sql stable;


create type overall_pledge_vote as (
	weight_in_favor numeric,
	weight_opposed numeric,
	should_continue bool
);
create function project_overall_pledge_vote(p project) returns overall_pledge_vote as $$
	with
	overall_pledge as (
		select pledge.pledger_id as pledger_id, pledge.project_id as project_id, sum(amount) as amount
		from pledge
		where pledge.project_id = p.id
		group by pledge.pledger_id, pledge.project_id
	),
	aggregated as (
		select
			sum(case coalesce(pledge_vote.should_continue, true)
				when true then overall_pledge.amount
				when false then 0
			end) as weight_in_favor,

			sum(case coalesce(pledge_vote.should_continue, true)
				when true then 0
				when false then overall_pledge.amount
			end) as weight_opposed
		from
			overall_pledge
			left join pledge_vote using (pledger_id, project_id)
	)
	select
		weight_in_favor,
		weight_opposed,
		(weight_in_favor - weight_opposed) > 0 as should_continue
	from aggregated
$$ language sql stable;


create function create_new_draft(owner_id uuid, title text) returns uuid as $$
	insert into project (owner_id, title, status, initial_amount, monthly_amount, month_count, prize_amount)
	values (owner_id, title, 'DRAFT', 0, 0, 0, 0)
	returning id
$$ language sql volatile strict security definer;

-- TODO all the status criteria below should probably error if the project isn't in the right state
-- TODO only project owner can call this
create function publish_draft(project_id uuid) returns void as $$
	update project set status = 'PROPOSAL' where status = 'DRAFT' and id = project_id
	-- funding_deadline = current_date + (interval 1 day * funding_days)
$$ language sql volatile strict security definer;

-- TODO only project owner can call this
create function close_project(project_id uuid) returns void as $$
	update project set status = 'CLOSED' where status = 'PROPOSAL' and id = project_id
	-- TODO have to refund pledgers
$$ language sql volatile strict security definer;


-- TODO only the system can call this
create procedure begin_project(project_id uuid) as $$

	insert into project_payment(project_id, projected_date, amount, kind, is_last)
	select
		project_id as project_id,
		(current_date + (interval '1 month' * payment_number)) as projected_date,
		case payment_number
			when 0 then initial_amount + monthly_amount
			when month_count then project.project_actual_prize_amount
			else monthly_amount
		end as amount,

		case
			when payment_number = 0 and initial_amount > 0 then 'WITH_INITIAL'::project_payment_kind
			when payment_number = month_count then 'PRIZE'::project_payment_kind
			else 'NORMAL_MONTHLY'::project_payment_kind
		end as kind,

		payment_number = (case project.project_actual_prize_amount <= 0
 			when true then month_count - 1
 			else month_count
 		end) as is_last

	from project, generate_series(0, month_count) as payment_number

	where (case payment_number
		when 0 then initial_amount + monthly_amount
		when month_count then project.project_actual_prize_amount
		else monthly_amount
	end) > 0;

	update project set status = 'FUNDED' where id = project_id;
$$ language sql;


create function make_pledge(pledger_id uuid, project_id uuid, amount numeric) returns void as $$
	declare funding_requirement_reached bool;
	begin
		insert into pledge (pledger_id, project_id, amount) values (pledger_id, project_id, amount);

		select project.project_total_pledged_amount >= project.project_funding_requirement
		into funding_requirement_reached
		from project
		where id = project_id;

		if funding_requirement_reached then
			call begin_project(project_id);
		end if;
	-- TODO this has to be part of a larger flow
	end;
$$ language plpgsql volatile strict security definer;


-- TODO use this to perform assertions about correctness
-- select
-- 	id,
-- 	sum(payment_amount) as actual,
-- 	project_funding_requirement() initial_amount + (monthly_amount * month_count) + prize_amount as expected
-- from expected_payments
-- group by id, (initial_amount + (monthly_amount * month_count) + prize_amount)

create function project_next_payment(p project) returns project_payment as $$
	select project_payment.*
	from project_payment
	where project_id = p.id and p.status = 'FUNDED' and executed_at is null
	order by projected_date asc limit 1
$$ language sql stable;


-- TODO this has to be in concert with actual code executing the payments
create procedure execute_payments() as $$
	with
	funded_project as (
		select
			id as project_id,
			(project.project_overall_pledge_vote).should_continue as should_continue,
			case
				when not (project.project_overall_pledge_vote).should_continue then 'FAILED'::project_status_enum
				-- TODO this is more complicated, if multiple payments are executed then the next one won't be the is_last one
				-- this would be more robust if it didn't use next_payment, but instead simply asked if *all* payments are in the past, and so will be executed
				when (project.project_next_payment).is_last then 'COMPLETE'::project_status_enum
				else null
			end as new_status
		from project
		where status = 'FUNDED'
	),

	payment_update as (
		update project_payment set executed_at = now()
		from funded_project
		where funded_project.project_id = project_payment.project_id
			and executed_at is null and projected_date <= now()
			and funded_project.should_continue
	)
	update project set status = funded_project.new_status
	from funded_project where project.id = funded_project.project_id and funded_project.new_status is not null
$$ language sql;

-- create view payments_to_execute as
-- need an order by window statement
-- select project.project_next_payment
-- from project
-- where

-- create procedure execute_payments_dev_unsafe() as $$
-- 	-- project_id, projected_date, amount, kind, executed_at
-- 	with next_payment as (select (p.project_next_payment).project_id, (p.project_next_payment).projected_date from project as p)

-- 	update project_payment set executed_at = now()
-- 	from project join next_payment on project.id = next_payment.project_id
-- 	where project_payment.project_id = project.id and project.status = 'FUNDED'
-- 		and project_payment.executed_at is null and project_payment.projected_date = next_payment.projected_date
-- 		-- and date_trunc('month', projected_date)::date = date_trunc('month', now())::date
-- $$ language sql;










-- TESTING

create function u(i text) returns uuid immutable language sql as $$
	select lpad(i, 32, '0')::uuid;
$$;

create function r() returns uuid immutable language sql as $$
	select 'ffffffffffffffffffffffffffffffff'::uuid;
$$;

insert into account (id, "name") values (u('1'), 'leia');
insert into account (id, "name") values (u('2'), 'han');


-- insert into project (id, owner_id, title, status, months, prize_amount) values (
insert into project (id, owner_id, title, status, initial_amount, monthly_amount, month_count, prize_amount) values (
	u('d'), u('1'), 'leia project', 'FUNDED',
	1000, 2000, 10, 100
);

select make_pledge(u('2'), u('d'), 1000 + (2000 * 10) + 200);

update project_payment set projected_date = (projected_date - interval '6 month');
-- update project_payment set executed_at = now() where not is_last;

call execute_payments();
select projected_date, amount, kind, is_last, executed_at from project_payment order by projected_date;
select title, status from project;

select cast_vote(u('2'), u('d'), false);

call execute_payments();
select projected_date, amount, kind, is_last, executed_at from project_payment order by projected_date;
select title, status from project;

call execute_payments();
select projected_date, amount, kind, is_last, executed_at from project_payment order by projected_date;
select title, status from project;
