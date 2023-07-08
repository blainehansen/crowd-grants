drop schema public cascade;
create schema public;
grant all on schema public to public;
comment on schema public is 'standard public schema';

-- TODO create person things separate from accounts that can own whatever
create table account (
	id uuid primary key default gen_random_uuid(),
	"name" text not null
);

create type proposal_month as (
	budget_amount numeric,
	description text
);

create type proposal_status_enum as enum('DRAFT', 'FUNDING', 'FUNDED', 'CLOSED');
create table raw_proposal (
	id uuid primary key default gen_random_uuid(),
	owner_id uuid not null references account(id),
	status proposal_status_enum not null,
	title text not null,
	months proposal_month[] not null,
	prize_amount numeric not null
);

create function raw_proposal_budget_amount(raw_proposal raw_proposal) returns numeric as $$
  select sum(months.budget_amount) from unnest(raw_proposal.months) as months
$$ language sql stable;
comment on function raw_proposal_budget_amount(raw_proposal) IS E'@notNull';

create function raw_proposal_funding_requirement(raw_proposal raw_proposal) returns numeric as $$
  select raw_proposal.raw_proposal_budget_amount + raw_proposal.prize_amount
$$ language sql stable;
comment on function raw_proposal_funding_requirement(raw_proposal) IS E'@notNull';


-- create table proposal_draft (
-- 	id uuid primary key default gen_random_uuid(),
-- 	owner_id uuid not null references account(id),
-- 	title text not null,
-- 	months proposal_month[] not null,
-- 	prize_amount numeric not null
-- );
-- -- create view full_proposal_draft as
-- -- select
-- -- 	proposal_draft.*,
-- -- 	(select sum(months.budget_amount) from unnest(months) as months) as budget_amount,
-- -- 	(select sum(months.budget_amount) from unnest(months) as months) + prize_amount as total_required_amount
-- -- from proposal_draft;

-- create table proposal (
-- 	id uuid primary key default gen_random_uuid(),
-- 	owner_id uuid not null references account(id),
-- 	title text not null,
-- 	months proposal_month[] not null,
-- 	prize_amount numeric not null
-- );
-- create table pledge (
-- 	pledger_id uuid not null references account(id),
-- 	proposal_id uuid not null references proposal(id),
-- 	amount numeric not null
-- );

-- create view full_proposal as
-- select
-- 	proposal.*,
-- 	-- (select sum(months.budget_amount) from unnest(months) as months) as budget_amount
-- 	-- budget_amount + prize_amount as total_required_amount
-- 	sum(pledge.amount) as current_pledged

-- from
-- 	proposal
-- 	join pledge on proposal.id = pledge.proposal_id
-- group by proposal.id;


-- create procedure make_pledge(pledger_id uuid, proposal_id uuid, amount numeric)
-- language sql as $$
-- 	insert into pledge (pledger_id, proposal_id, amount) values (pledger_id, proposal_id, amount)
-- $$;


-- create table project (
-- 	id uuid primary key references proposal(id)
-- 	-- in_good_standing bool default true
-- );
-- create table pledge_vote (
-- 	pledger_id uuid not null references account(id),
-- 	project_id uuid not null references project(id),
-- 	primary key (pledger_id, project_id),
-- 	should_continue bool not null
-- );

-- -- select
-- -- 	coalesce(pledge_vote.should_continue, true)
-- -- from
-- -- 	project
-- -- 	join proposal using (id)
-- -- 	join pledge
-- -- 	left join pledge_vote


-- create view full_project as
-- select
-- 	proposal.*,

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
-- 	join proposal using (id)
-- 	join pledge on proposal.id = pledge.proposal_id
-- 	join pledge_vote on pledge.pledger_id = pledge_vote.pledger_id and pledge.proposal_id = pledge_vote.project_id
-- group by proposal.id;

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
-- -- 	proposal
-- -- 	-- TODO this has to work on proposal ids???
-- -- 	join pledge on project.id = pledge.project_id
-- -- 	-- has the effect of not considering any pledge_votes that were accidentally cast by a person who didn't actually pledge
-- -- 	join pledge_vote using (pledger_id, project_id)
-- -- where project.id = project_id;




-- -- create table project_update (
-- -- 	id uuid primary key default gen_random_uuid(),
-- -- 	project_id uuid references project(id),
-- -- 	"text" text not null
-- -- );

-- create procedure cast_vote(arg_pledger_id uuid, arg_project_id uuid, arg_should_continue bool)
-- language sql as $$

-- 	insert into pledge_vote (pledger_id, project_id, should_continue) values (arg_pledger_id, arg_project_id, arg_should_continue)
-- 	-- on conflict primary key
-- 	on conflict (pledger_id, project_id) do
-- 	update set should_continue = arg_should_continue
-- 	where pledge_vote.pledger_id = arg_pledger_id and pledge_vote.project_id = arg_project_id

-- $$;






-- -- TODO have to authenticate owner_id is the person doing this
-- create procedure publish_proposal_draft(proposal_draft_id uuid)
-- language sql as $$

-- 	with
-- 	insert_statement as (
-- 		insert into proposal
-- 		select * from proposal_draft where id = proposal_draft_id
-- 	)
-- 	delete from proposal_draft where id = proposal_draft_id
-- $$;


-- create procedure mark_proposal_funded(proposal_id uuid)
-- language sql as $$
-- 	insert into project (id) values (proposal_id)
-- 	-- update raw_proposal set status = 'FUNDED' where id = proposal_id
-- $$;






-- -- TESTING

-- create function u(i text) returns uuid immutable language sql as $$
-- 	select lpad(i, 32, '0')::uuid;
-- $$;

-- create function r() returns uuid immutable language sql as $$
-- 	select 'ffffffffffffffffffffffffffffffff'::uuid;
-- $$;

-- insert into account (id, "name") values (u('1'), 'leia');

-- insert into proposal_draft (id, owner_id, title, months, prize_amount) values (
-- 	u('d'), u('1'),
-- 	'leia proposal',
-- 	ARRAY[(2400, 'month1')::proposal_month],
-- 	1000
-- );


-- select * from proposal_draft;
-- select * from full_proposal;

-- call publish_proposal_draft(u('d'));

-- select * from proposal_draft;
-- select * from full_proposal;


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



-- -- select * from proposal;
-- -- select * from pledge;
-- -- select * from pledge_vote;
