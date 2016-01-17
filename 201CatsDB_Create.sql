CREATE TABLE users (
	id			SERIAL PRIMARY KEY,
	user_name		TEXT UNIQUE,
	fb_login		TEXT UNIQUE
);

CREATE TABLE video (
	id			SERIAL PRIMARY KEY,
	title			TEXT,
	url			TEXT,
	UNIQUE (title, url)
);

CREATE TABLE like_activity (
	liked_datetime		TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	user_id			INTEGER REFERENCES users (id) NOT NULL,
	video_id		INTEGER REFERENCES video (id) NOT NULL,
	UNIQUE (user_id, video_id)
);

CREATE TABLE watch_activity (
	watched_datetime	TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	user_id			INTEGER REFERENCES users (id) NOT NULL,
	video_id		INTEGER REFERENCES video (id) NOT NULL
);

CREATE TABLE sessions (
	id			SERIAL PRIMARY KEY,
	start_time		TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	user_id			INTEGER REFERENCES users (id) NOT NULL
);


CREATE TABLE suggested_content (
	session_id		INTEGER REFERENCES sessions (id) NOT NULL,
	video_id		INTEGER REFERENCES video (id) NOT NULL
);

CREATE TABLE friends (
	subject			INTEGER REFERENCES users (id) NOT NULL,
	object			INTEGER REFERENCES users (id) NOT NULL,
	UNIQUE (subject, object)
);
