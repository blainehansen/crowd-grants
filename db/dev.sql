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
	initial_amount numeric not null check(initial_amount >= 0),
	monthly_amount numeric not null check(monthly_amount >= 0),
	month_count smallint not null check(month_count >= 0),
	prize_amount numeric not null check(prize_amount >= 0)
);

-- create function project_budget_amount(project project) returns numeric as $$
-- 	select project.initial_amount + (project.monthly_amount * project.month_count)
-- $$ language sql stable;

create function project_funding_requirement(p project) returns numeric as $$
	select p.initial_amount + (p.monthly_amount * p.month_count) + p.prize_amount
$$ language sql stable;

-- create table project_month (
-- 	project_id uuid not null references project(id),
-- 	month_number smallint not null,
-- 	budget_amount numeric not null check(budget_amount >= 0),
-- 	description text not null
-- );

-- create type bad_input_project_month_do_not_use as (
-- 	budget_amount numeric,
-- 	description text
-- );
-- create domain input_project_month as bad_input_project_month_do_not_use
-- not null
-- check ((value).budget_amount is not null and (value).description is not null and (value).budget_amount >= 0);

-- -- TODO only the project owner can do this, and only while in DRAFT phase
-- create function update_project_months(arg_project_id uuid, arg_project_months input_project_month[]) returns void as $$
-- 	delete from project_month where project_id = arg_project_id;

-- 	insert into project_month (project_id, month_number, budget_amount, description)
-- 	select arg_project_id, month_number, budget_amount, description
-- 	from unnest(arg_project_months) with ordinality as m(budget_amount, description, month_number)
-- $$ language sql volatile strict security definer;

create type project_payment_kind as enum('WITH_INITIAL', 'NORMAL_MONTHLY', 'PRIZE');
create table project_payment (
	project_id uuid not null references project(id),
	projected_date date not null,
	primary key (project_id, projected_date),
	amount numeric not null check(amount > 0),
	kind project_payment_kind not null,
	executed_at timestamp default null
);

create unique index project_projected_date_month_unique
on project_payment(project_id, date_trunc('month', projected_date::timestamp));

-- TODO only the system can call this
create procedure begin_project(project_id uuid) as $$
	update project set status = 'FUNDED' where status = 'PROPOSAL' and id = project_id;

	insert into project_payment(project_id, projected_date, amount, kind)
	select
		project_id as project_id,
		(current_date + (interval '1 month' * payment_number)) as projected_date,
		case payment_number
			when 0 then initial_amount + monthly_amount
			when month_count then prize_amount
			else monthly_amount
		end as amount,

		case
			when payment_number = 0 and initial_amount > 0 then 'WITH_INITIAL'::project_payment_kind
			when payment_number = month_count then 'PRIZE'::project_payment_kind
			else 'NORMAL_MONTHLY'::project_payment_kind
		end as kind

	from project, generate_series(0, month_count) as payment_number

	where (case payment_number
		when 0 then initial_amount + monthly_amount
		when month_count then prize_amount
		else monthly_amount
	end) > 0

$$ language sql;

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
	where project_id = p.id and executed_at is null
	order by projected_date asc limit 1
$$ language sql stable;


-- TODO this has to be in concert with actual code executing the payments
create procedure execute_payments() as $$
	update project_payment set executed_at = now()
	from project
	where project_payment.project_id = project.id and project.status = 'FUNDED'
		and executed_at is null and projected_date <= now()
$$ language sql;


-- create procedure execute_payments_dev_unsafe() as $$
-- 	-- project_id, projected_date, amount, kind, executed_at
-- 	with next_payment as (select (p.project_next_payment).project_id, (p.project_next_payment).projected_date from project as p)

-- 	update project_payment set executed_at = now()
-- 	from project join next_payment on project.id = next_payment.project_id
-- 	where project_payment.project_id = project.id and project.status = 'FUNDED'
-- 		and project_payment.executed_at is null and project_payment.projected_date = next_payment.projected_date
-- 		-- and date_trunc('month', projected_date)::date = date_trunc('month', now())::date
-- $$ language sql;



-- create function create_new_draft(owner_id uuid, title text) returns uuid as $$
-- 	insert into project (owner_id, title, status, months, prize_amount)
-- 	values (owner_id, title, 'DRAFT', '{}', 0)
-- 	returning id
-- $$ language sql volatile strict security definer;

-- -- TODO all the status criteria below should probably error if the project isn't in the right state
-- -- TODO only project owner can call this
-- create function publish_draft(project_id uuid) returns void as $$
-- 	update project set status = 'PROPOSAL' where status = 'DRAFT' and id = project_id
-- $$ language sql volatile strict security definer;

-- -- TODO only project owner can call this
-- create function close_project(project_id uuid) returns void as $$
-- 	update project set status = 'CLOSED' where status = 'PROPOSAL' and id = project_id
-- 	-- TODO have to refund pledgers
-- $$ language sql volatile strict security definer;

-- -- TODO only the system can call this
-- create procedure complete_project(project_id uuid) as $$
-- 	update project set status = 'COMPLETE' where status = 'FUNDED' and id = project_id
-- $$ language sql;

-- -- TODO only the system can call this
-- create procedure fail_project(project_id uuid) as $$
-- 	update project set status = 'FAILED' where status = 'FUNDED' and id = project_id
-- $$ language sql;

-- create table project_update (
-- 	id uuid primary key default gen_random_uuid(),
-- 	project_id uuid references project(id),
-- 	"text" text not null
-- );



-- create table pledge (
-- 	pledger_id uuid not null references account(id),
-- 	project_id uuid not null references project(id),
-- 	amount numeric not null
-- );
-- create function make_pledge(pledger_id uuid, project_id uuid, amount numeric) returns void as $$
-- 	insert into pledge (pledger_id, project_id, amount) values (pledger_id, project_id, amount)
-- 	-- TODO this has to be part of a larger flow
-- $$ language sql volatile strict security definer;


-- create table pledge_vote (
-- 	pledger_id uuid not null references account(id),
-- 	project_id uuid not null references project(id),
-- 	primary key (pledger_id, project_id),
-- 	should_continue bool not null
-- );
-- create function cast_vote(arg_pledger_id uuid, arg_project_id uuid, arg_should_continue bool) returns void as $$
-- 	insert into pledge_vote (pledger_id, project_id, should_continue) values (arg_pledger_id, arg_project_id, arg_should_continue)
-- 	on conflict (pledger_id, project_id) do
-- 	update set should_continue = arg_should_continue
-- 	where pledge_vote.pledger_id = arg_pledger_id and pledge_vote.project_id = arg_project_id
-- $$ language sql volatile strict security definer;


-- create function project_overall_pledger_count(p project) returns int as $$
-- 	select count(distinct pledge.pledger_id)
-- 	from pledge
-- 	where pledge.project_id = p.id
-- $$ language sql stable;

-- create function project_overall_pledged_amount(p project) returns numeric as $$
-- 	select sum(amount)
-- 	from pledge
-- 	where pledge.project_id = p.id
-- $$ language sql stable;



-- create type overall_pledge_vote as (
-- 	weight_in_favor numeric,
-- 	weight_opposed numeric,
-- 	should_continue bool
-- );
-- create function project_overall_pledge_votes(p project) returns overall_pledge_vote as $$
-- 	with
-- 	overall_pledge as (
-- 		select pledge.pledger_id as pledger_id, pledge.project_id as project_id, sum(amount) as amount
-- 		from pledge
-- 		where pledge.project_id = p.id
-- 		group by pledge.pledger_id, pledge.project_id
-- 	)
-- 	select
-- 		sum(case coalesce(pledge_vote.should_continue, true)
-- 			when true then overall_pledge.amount
-- 			when false then 0
-- 		end) as weight_in_favor,

-- 		sum(case coalesce(pledge_vote.should_continue, true)
-- 			when true then 0
-- 			when false then overall_pledge.amount
-- 		end) as weight_opposed,

-- 		sum(case coalesce(pledge_vote.should_continue, true)
-- 			when true then overall_pledge.amount
-- 			when false then -overall_pledge.amount
-- 		end) > 0 as should_continue

-- 	from
-- 		overall_pledge
-- 		left join pledge_vote using (pledger_id, project_id)

-- $$ language sql stable;













-- create function account_pledged_projects(arg_account account) returns numeric as $$
-- 	select
-- 		project.id,
-- 		project.title,

-- 	from
-- 		project
-- 		join account on
-- 	where pledge.project_id = p.id
-- $$ language sql stable;







-- create view full_project as
-- select
-- 	project.*,

-- 	sum(case pledge_vote.should_continue
-- 		when true then pledge.amount
-- 		when false then 0
-- 	end) as current_weight_should_continue,

-- 	sum(case pledge_vote.should_continue
-- 		when true then 0
-- 		when false then pledge.amount
-- 	end) as current_weight_should_not_continue,

-- 	sum(case pledge_vote.should_continue
-- 		when true then pledge.amount
-- 		when false then -pledge.amount
-- 	end) > 0 as current_should_continue


-- from
-- 	project
-- 	join project using (id)
-- 	join pledge on project.id = pledge.project_id
-- 	join pledge_vote on pledge.pledger_id = pledge_vote.pledger_id and pledge.project_id = pledge_vote.project_id
-- group by project.id;

-- -- -- should project continue function
-- -- select
-- -- 	project.id as project_id,

-- -- 	case pledge_votes.should_continue
-- -- 		when true then pledge.amount
-- -- 		when false then -pledge.amount
-- -- 	end

-- -- 	-- sum(case pledge_votes.should_continue
-- -- 	-- 	when true then pledge.amount
-- -- 	-- 	when false then -pledge.amount
-- -- 	-- end) total_,

-- -- 	-- sum(case pledge_votes.should_continue
-- -- 	-- 	when true then pledge.amount
-- -- 	-- 	when false then -pledge.amount
-- -- 	-- end) > 0 as total_should_continue

-- -- from
-- -- 	project
-- -- 	-- TODO this has to work on project ids???
-- -- 	join pledge on project.id = pledge.project_id
-- -- 	-- has the effect of not considering any pledge_votes that were accidentally cast by a person who didn't actually pledge
-- -- 	join pledge_vote using (pledger_id, project_id)
-- -- where project.id = project_id;






-- TESTING

create function u(i text) returns uuid immutable language sql as $$
	select lpad(i, 32, '0')::uuid;
$$;

create function r() returns uuid immutable language sql as $$
	select 'ffffffffffffffffffffffffffffffff'::uuid;
$$;

insert into account (id, "name") values (u('1'), 'leia');

-- insert into project (id, owner_id, title, status, months, prize_amount) values (
insert into project (id, owner_id, title, status, initial_amount, monthly_amount, month_count, prize_amount) values (
	u('d'), u('1'), 'leia project', 'FUNDED',
	1000, 2000, 10, 0
);

call begin_project(u('d'));

select projected_date, amount, kind, executed_at from project_payment order by projected_date;
call execute_payments();
select projected_date, amount, kind, executed_at from project_payment order by projected_date;
call execute_payments();
select projected_date, amount, kind, executed_at from project_payment order by projected_date;
call execute_payments();
select projected_date, amount, kind, executed_at from project_payment order by projected_date;
call execute_payments();
select projected_date, amount, kind, executed_at from project_payment order by projected_date;
