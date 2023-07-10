drop schema public cascade;
create schema public;
grant all on schema public to public;
comment on schema public is 'standard public schema';

-- TODO create person things separate from accounts that can own whatever
create table account (
	id uuid primary key default gen_random_uuid(),
	"name" text not null
);


create type bad_project_month_do_not_use as (
	budget_amount numeric,
	description text
);
create domain project_month as bad_project_month_do_not_use
not null
check((value).budget_amount is not null and (value).description is not null and (value).budget_amount >= 0);


create type project_status_enum as enum('DRAFT', 'PROPOSAL', 'CLOSED', 'FUNDED', 'COMPLETE', 'FAILED');
create table project (
	id uuid primary key default gen_random_uuid(),
	owner_id uuid not null references account(id),
	status project_status_enum not null,
	title text not null,
	months project_month[] not null,
	prize_amount numeric not null check(prize_amount >= 0)
);

create function project_budget_amount(project project) returns numeric as $$
  select sum(months.budget_amount) from unnest(project.months) as months
$$ language sql stable;
comment on function project_budget_amount(project) IS E'@notNull';

create function project_funding_requirement(project project) returns numeric as $$
  select project.project_budget_amount + project.prize_amount
$$ language sql stable;
comment on function project_funding_requirement(project) IS E'@notNull';


create function create_new_draft(owner_id uuid, title text) returns uuid as $$
	insert into project (owner_id, title, status, months, prize_amount)
	values (owner_id, title, 'DRAFT', '{}', 0)
	returning id
$$ language sql volatile strict security definer;

-- TODO all the status criteria below should probably error if the project isn't in the right state
-- TODO only project owner can call this
create function publish_draft(project_id uuid) returns void as $$
	update project set status = 'PROPOSAL' where status = 'DRAFT' and id = project_id
$$ language sql volatile strict security definer;

-- TODO only project owner can call this
create function close_project(project_id uuid) returns void as $$
	update project set status = 'CLOSED' where status = 'PROPOSAL' and id = project_id
	-- TODO have to refund pledgers
$$ language sql volatile strict security definer;

-- TODO only the system can call this
create procedure begin_project(project_id uuid) as $$
	update project set status = 'FUNDED' where status = 'PROPOSAL' and id = project_id
$$ language sql;

-- TODO only the system can call this
create procedure complete_project(project_id uuid) as $$
	update project set status = 'COMPLETE' where status = 'FUNDED' and id = project_id
$$ language sql;

-- TODO only the system can call this
create procedure fail_project(project_id uuid) as $$
	update project set status = 'FAILED' where status = 'FUNDED' and id = project_id
$$ language sql;

create table project_update (
	id uuid primary key default gen_random_uuid(),
	project_id uuid references project(id),
	"text" text not null
);



create table pledge (
	pledger_id uuid not null references account(id),
	project_id uuid not null references project(id),
	amount numeric not null
);
create function make_pledge(pledger_id uuid, project_id uuid, amount numeric) returns void as $$
	insert into pledge (pledger_id, project_id, amount) values (pledger_id, project_id, amount)
	-- TODO this has to be part of a larger flow
$$ language sql volatile strict security definer;


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


create function project_overall_pledger_count(arg_project project) returns int as $$
	select count(distinct pledge.pledger_id)
	from pledge
	where pledge.project_id = arg_project.id
$$ language sql stable;

create function project_overall_pledged_amount(arg_project project) returns numeric as $$
	select sum(amount)
	from pledge
	where pledge.project_id = arg_project.id
$$ language sql stable;



create type overall_pledge_vote as (
	weight_in_favor numeric,
	weight_opposed numeric,
	should_continue bool
);
create function project_overall_pledge_votes(arg_project project) returns overall_pledge_vote as $$
	with
	overall_pledge as (
		select pledge.pledger_id as pledger_id, pledge.project_id as project_id, sum(amount) as amount
		from pledge
		where pledge.project_id = arg_project.id
		group by pledge.pledger_id, pledge.project_id
	)
	select
		sum(case coalesce(pledge_vote.should_continue, true)
			when true then overall_pledge.amount
			when false then 0
		end) as weight_in_favor,

		sum(case coalesce(pledge_vote.should_continue, true)
			when true then 0
			when false then overall_pledge.amount
		end) as weight_opposed,

		sum(case coalesce(pledge_vote.should_continue, true)
			when true then overall_pledge.amount
			when false then -overall_pledge.amount
		end) > 0 as should_continue

	from
		overall_pledge
		left join pledge_vote using (pledger_id, project_id)

$$ language sql stable;



-- create function account_pledged_projects(arg_account account) returns numeric as $$
-- 	select
-- 		project.id,
-- 		project.title,

-- 	from
-- 		project
-- 		join account on
-- 	where pledge.project_id = arg_project.id
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






-- -- TESTING

-- create function u(i text) returns uuid immutable language sql as $$
-- 	select lpad(i, 32, '0')::uuid;
-- $$;

-- create function r() returns uuid immutable language sql as $$
-- 	select 'ffffffffffffffffffffffffffffffff'::uuid;
-- $$;

-- insert into account (id, "name") values (u('1'), 'leia');

-- insert into project_draft (id, owner_id, title, months, prize_amount) values (
-- 	u('d'), u('1'),
-- 	'leia project',
-- 	ARRAY[(2400, 'month1')::project_month],
-- 	1000
-- );


-- select * from project_draft;
-- select * from full_project;

-- call publish_project_draft(u('d'));

-- select * from project_draft;
-- select * from full_project;


-- insert into account (id, "name") values (u('2'), 'u2');
-- insert into account (id, "name") values (u('3'), 'u3');
-- insert into account (id, "name") values (u('4'), 'u4');
-- insert into account (id, "name") values (u('5'), 'u5');
-- insert into account (id, "name") values (u('6'), 'u6');

-- call make_pledge(u('2'), u('d'), 200);
-- call make_pledge(u('2'), u('d'), 200);
-- call make_pledge(u('3'), u('d'), 300);
-- call make_pledge(u('4'), u('d'), 400);
-- call make_pledge(u('5'), u('d'), 500);
-- call make_pledge(u('6'), u('d'), 600);


-- -- call cast_vote(u('2'), u('d'), false);
-- -- call cast_vote(u('2'), u('d'), true);
-- -- call cast_vote(u('5'), u('d'), false);



-- -- select * from project;
-- -- select * from pledge;
-- -- select * from pledge_vote;
