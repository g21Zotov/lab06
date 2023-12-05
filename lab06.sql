drop schema if exists lab06 cascade;

create schema lab06;

create sequence sq_items_id;

create table items(
	id integer not null default nextval('sq_items_id'),
	name varchar(50) not null,
	value integer not null,
	image varchar(30) not null
);

alter table items add constraint pk_items_id primary key (id);

Insert into items (name, value, image) values
('apple', 23, 'Apelsin.png'),
('lemon', 23, 'Limon.png');

Select * from items;

