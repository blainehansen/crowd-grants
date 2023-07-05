drop schema public cascade;
create schema public;
grant all on schema public to public;
comment on schema public is 'standard public schema';

-- TODO create person things separate from accounts that can own whatever
create table account (
	id uuid primary key default gen_random_uuid(),
	"name" text not null
);



create table proposal_draft (
	id uuid primary key default gen_random_uuid(),
	owner_id uuid not null references account(id)
);

create type proposal_month(
	budget_amount numeric not null,
	"text" text not null
);

create table proposal (
	id uuid primary key default gen_random_uuid(),
	owner_id uuid not null references account(id),
	months proposal_month[] not null
);


create table pledge (
	pledger_id uuid not null references account(id),
	project_id uuid not null references proposal(id),
	amount numeric not null
);

-- create procedure make_pledge(pledger_id uuid, proposal_id uuid, amount numeric)
-- language sql as $$
-- 	insert into pledge (pledger_id, proposal_id, amount) values (pledger_id, proposal_id, amount)
-- $$;


create table project (
	id uuid primary key references proposal(id),
	-- owner_id uuid not null references account(id)???


	-- in_good_standing bool default true
);

create table project_update (
	id uuid primary key default gen_random_uuid(),
	project_id uuid references project(id),
	"text" text not null
);

create table pledge_vote (
	pledger_id uuid not null references account(id),
	project_id uuid not null references proposal(id),
	should_continue bool
);


-- should project continue function
select
	project.id as project_id,

	sum(case pledge_votes.should_continue
		when true then pledge.amount
		when false then -pledge.amount
	end) > 0 as total_should_continue

from
	project
	-- TODO this has to work on proposal ids???
	join pledge on project.id = pledge.project_id
	-- has the effect of not considering any pledge_votes that were accidentally cast by a person who didn't actually pledge
	join pledge_vote using (pledger_id, project_id)
where project.id = project_id;







-- TODO have to authenticate owner_id is the person doing this
create procedure publish_proposal_draft(proposal_draft_id uuid)
language sql as $$

	with
	insert_statement as (
		insert into proposal (id, owner_id)
		select id, owner_id from proposal_draft where id = proposal_draft_id
	)

	delete from proposal_draft where id = proposal_draft_id
$$;


create procedure mark_proposal_funded(proposal_id uuid)
language sql as $$
	insert into project (proposal_id) values (proposal_id)
$$;






-- TESTING

create function u(i text) returns uuid immutable language sql as $$
	select lpad(i, 32, '0')::uuid;
$$;

create function r() returns uuid immutable language sql as $$
	select 'ffffffffffffffffffffffffffffffff'::uuid;
$$;

insert into account (id, "name") values (u('1'), 'leia');

insert into proposal_draft (id, owner_id) values (u('d'), u('1'));

select * from proposal_draft;
select * from proposal;

call publish_proposal_draft(u('d'));

select * from proposal_draft;
select * from proposal;
