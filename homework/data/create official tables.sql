CREATE TABLE "user"
(
  user_id serial primary key NOT NULL,
  user_name character varying(50) NOT NULL,
  facebook_id character varying(50) NOT NULL
);

CREATE TABLE video
(
  video_id serial primary key NOT NULL,
  video_name character varying(50) NOT NULL
);

CREATE TABLE login
(
  login_id serial primary key NOT NULL,
  user_id integer references "user" (user_id) NOT NULL,
  "time" timestamp without time zone NOT NULL
);

CREATE TABLE watch
(
  watch_id serial primary key NOT NULL,
  video_id integer references video (video_id) NOT NULL,
  user_id integer references "user" (user_id) NOT NULL,
  "time" timestamp without time zone NOT NULL
);

CREATE TABLE friend
(
  user_id integer references "user" (user_id) NOT NULL,
  friend_id integer references "user" (user_id) NOT NULL
);

CREATE TABLE "likes"
(
  like_id serial primary key NOT NULL,
  user_id integer references "user" (user_id) NOT NULL,
  video_id integer references video (video_id) NOT NULL,
  "time" timestamp without time zone NOT NULL
);

CREATE TABLE suggestion
(
  suggestion_id serial primary key NOT NULL,
  login_id integer references login(login_id) NOT NULL,
  video_id integer references video (video_id) NOT NULL
);