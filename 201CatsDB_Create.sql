-- I could opt to use the fb_login ONLY as the PRIMARY KEY and the code for the 
-- scope of the project would be fine and probably less redundant.   That just 
-- "feels" wrong.  I choose to use a serial primary key instead. Here's one use-case - 
-- in the future, facebook may not be the only social site that I want to track
-- friends and followers of friends.  What if I wanted to use instagram, twitter, etc
-- social media outlets?  I may want to offer recommendations from friends of
-- friends on instagram as well as facebook.  So, I know this isn't in the homework
-- requirements, but this is why I designed it as such....
CREATE TABLE users (
	id			SERIAL PRIMARY KEY,
	user_name		TEXT NOT NULL UNIQUE,
	fb_login		TEXT NOT NULL UNIQUE
);

-- For this table, I thought that you really have to have a url to display the video,
-- but also thought that a url wasn't going to be readable by the user, and that a title
-- was needed instead.  I included both.  I considered putting NOT NULL contraints on 
-- each the title and the url, but I thought of a case where I could have a null
-- title, because all I really need to show the video is the url.
-- I could have a duplicate url in the table if it had different titles.
-- Regardless of whether or not I need a title or url, I know that the title and url 
-- together should be unique. With them together being unique, I could set it as a primary
-- key, but that would impact performance of queries.
CREATE TABLE video (
	id			SERIAL PRIMARY KEY,
	title			TEXT,
	url			TEXT NOT NULL,
	UNIQUE (title, url)
);

-- The UNIQUE constraint restricts users from liking a video more than once.
-- The NOT NULL for user_id means that in order for the video to be liked
-- the user must be known, and thus have a user_id.
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

-- When a user successfully logs in, that user creates a new session.  This
-- table is named sessions because it is the result of a successful login.
-- I will probably want to track more things in the sessions table like the GUID, 
-- the device the user logged in with, the geolocation info, browser info, etc.
-- Although this wasn’t in the homework assignment definition, I chose to separate
-- this table from the suggested_content table so that this info could also
-- potentially be stored.

CREATE TABLE sessions (
	id			SERIAL PRIMARY KEY,
	start_time		TIMESTAMP WITHOUT TIME ZONE NOT NULL,
	user_id			INTEGER REFERENCES users (id) NOT NULL
);

-- I’m choosing not to put a constraint of 10 videos per session on this table.
-- Yes, this may result in a varying number of videos for the session, but this
-- logic is best placed in the business layer.  If the business direction was 
-- to change, we don’t want to have to change the schema, we want to make 
-- modifications in the business logic layer.  If I were to be EXACT, I would 
-- architect the table using session_id, video1, video2, video3, etc.  That’s 
-- ugly and not flexible.

CREATE TABLE suggested_content (
	session_id		INTEGER REFERENCES sessions (id) NOT NULL,
	video_id		INTEGER REFERENCES video (id) NOT NULL
);


-- Since the homework instructions state that there is some leeway on capturing 
-- redundancy, I made the table symmetric and am going to handle the redundancy
-- in my queries.
-- This table would be the result of mapping the FB friends information to the 
-- users table. 
CREATE TABLE friends (
	subject			INTEGER REFERENCES users (id) NOT NULL,
	object			INTEGER REFERENCES users (id) NOT NULL,
	UNIQUE (subject, object)
);
