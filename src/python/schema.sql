drop table if exists songs;
create table songs (
	songId integer primary key autoincrement,
	title string not null,
	artist string null,
	desc string null
);
drop table if exists lights;
create table lights (
	lightId integer primary key autoincrement,
	desc string not null,
	songId integer null,
	sequence string  null
);
drop table if exeists channels;
CREATE TABLE channels (
 id integer primary key autoincrement,
 vals string
);