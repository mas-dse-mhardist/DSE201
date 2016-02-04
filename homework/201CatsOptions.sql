-- OVERALL LIKES
-- Option “Overall Likes”: The Top-10 cat videos are the ones that have collected the highest
-- numbers of likes, overall.
SELECT v.video_id, v.video_name
FROM likes la JOIN video v ON la.video_id = v.video_id
GROUP BY v.video_id, v.video_name
ORDER BY count(la.user_id) DESC, v.video_id
LIMIT 10;


-- FRIEND LIKES
-- Option “Friend Likes”: The Top-10 cat videos are the ones that have collected the highest 
-- numbers of likes from the friends of X.
-- I am assuming to get friends likes even if it is a video that X also liked
-- I've commented out the line that would remove friend X's likes, but since the user cannot be a friend
-- to  him or herself, this is moot.
SELECT user_id, count(friend_id) as friend_count
FROM friend
GROUP BY user_id
ORDER BY count(friend_id) DESC
-- user_id 168 has the most friends, she has 27 friends, we'll be using this user throughout this script as X

--the friends of user X
SELECT friend_id
FROM friend
WHERE user_id = 168

--using a subquery to get the videos liked by friends of 168
SELECT v.video_id, v.video_name --, count(la.user_id) as like_count 
FROM likes la JOIN video v ON la.video_id = v.video_id
WHERE la.user_id IN (SELECT friend_id
			FROM friend
			WHERE user_id = 168)
-- AND la.user_id != 168
GROUP BY v.video_id, v.video_name
ORDER BY count(la.user_id) DESC, v.video_id
LIMIT 10;

-- same without subquery
SELECT v.video_id, v.video_name --, count(la.user_id) as like_count 
FROM likes la JOIN video v ON v.video_id = la.video_id
	JOIN users u ON u.user_id = la.user_id 
	JOIN friend f ON la.user_id = f.friend_id AND la.user_id != f.user_id
WHERE f.user_id = 168
GROUP BY v.video_id, v.video_name
ORDER BY count(la.user_id) DESC,  v.video_id
LIMIT 10;

-- Option “Friends-of-Friends Likes”: The Top-10 cat videos are the ones that have collected the highest 
-- numbers of likes from friends and friends-of-friends.
-- I'm assuming that even though it is possible for X to be a friend of a friend of him/herself, this is not 
-- the intent.  Intent should be that we get friends of friends that aren't X.

-- This query gets the friends of friends AND friends
SELECT f2.friend_id -- friend of friends
FROM friend f1 JOIN friend f2 ON f1.friend_id = f2.user_id
WHERE f1.user_id = 168
AND f2.user_id != 168
GROUP BY f2.friend_id
UNION
SELECT friend_id -- friends
FROM friend
WHERE user_id = 168
;

--using a subquery to get the likes from friends of friends
SELECT v.video_id, v.video_name --, count(la.user_id) as like_count 
FROM likes la JOIN video v ON la.video_id = v.video_id
WHERE la.user_id IN (SELECT f2.friend_id -- friend of friends
			FROM friend f1 JOIN friend f2 ON f1.friend_id = f2.user_id
			WHERE f1.user_id = 168
			AND f2.user_id != 168
			GROUP BY f2.friend_id
			UNION
			SELECT friend_id -- friends
			FROM friend
			WHERE user_id = 168)
-- AND la.user_id != 168
GROUP BY v.video_id, v.video_name
ORDER BY count(la.user_id)  DESC, v.video_id
LIMIT 10;


SELECT v.video_id, v.video_name --, count(la.user_id) as like_count 
FROM video v JOIN likes la ON v.video_id = la.video_id
WHERE la.user_id IN (SELECT f2.friend_id
			FROM friend f1 JOIN friend f2 ON f1.friend_id = f2.user_id
			WHERE f1.user_id = 168
			AND f2.user_id != 168
			GROUP BY f2.friend_id
			UNION
			SELECT friend_id
			FROM friend
			WHERE user_id = 168
		)
AND la.user_id != 168
GROUP BY v.video_id, v.video_name
ORDER BY count(la.user_id)  DESC,  v.video_id
LIMIT 10;


--Option “My kind of cats”: The Top-10 cat videos are the ones that have collected 
-- the most likes from users who have liked at least one cat video that was liked by X.
-- In this case, to me, this seems to answer the question of people like you also
-- liked these other videos.  Again, it doesn't make sense to include the likes from X
-- if we are trying to determine what other people like X liked.
-- Breaking it down:
-- Videos that were liked by X
SELECT video_id
FROM likes
WHERE user_id = 168

-- users who have liked at least one cat video liked by X
SELECT user_id
FROM likes
WHERE video_id IN (SELECT video_id
		FROM likes
		WHERE user_id = 168)
AND user_id != 168
GROUP BY user_id
ORDER BY user_id

-- now without subquery
SELECT la2.user_id
FROM likes la1 JOIN likes la2 
		ON la1.video_id = la2.video_id 
		AND la1.user_id != la2.user_id
WHERE la1.user_id = 168
GROUP BY la2.user_id
ORDER BY la2.user_id

-- now top videos that have collected the most likes from users who like at least one cat video liked by X
-- using subquery
SELECT v.video_id, v.video_name --, count(la.user_id) as like_count 
FROM likes la JOIN video v ON la.video_id = v.video_id
WHERE la.user_id IN (SELECT la2.user_id
			FROM likes la1 JOIN likes la2 
					ON la1.video_id = la2.video_id 
					AND la1.user_id != la2.user_id
			WHERE la1.user_id = 168
			GROUP BY la2.user_id)
-- AND la.user_id != 168
GROUP BY v.video_id, v.video_name
ORDER BY count(la.user_id)  DESC, v.video_id
LIMIT 10;

-- without subquery
SELECT v.video_id, v.video_name --,  count(distinct la3.user_id) as like_count
FROM likes la1 JOIN likes la2 ON la1.video_id = la2.video_id AND la1.user_id != la2.user_id
	JOIN likes la3 ON la2.user_id = la3.user_id
	JOIN video v ON la3.video_id = v.video_id
WHERE la1.user_id = 168
GROUP BY v.video_id, v.video_name
ORDER BY count(la3.user_id)  DESC,  v.video_id
LIMIT 10

-- Option “My kind of cats – with preference (to cat aficionados that have the same tastes)”: 
-- The Top-10 cat videos are the ones that have collected the highest sum of weighted likes 
-- from every other user Y (i.e., given a cat video, each like on it, is multiplied according to a weight).
-- The weight is the log cosine lc(X,Y) defined as follows: Conceptually, there is a 
-- vector vx for each user Y, including the logged-in user
--X. The vector has as many elements as the number of cat videos. Element i is 1 if Y liked the ith cat 
-- video; it is 0 otherwise. For example, if 201Cats has five cat videos and user 21 liked only the 1st and the 4th, 
-- the v21=<1,0,0,1,0>, i.e., v21[1]=v21[4]=1 and v21[2]= v21[3]=v21[5]=0. Assuming there are N cat videos, the log cosine lc(X, Y) is

-- For every user Y you will have a lc weighting
-- that weighting will be used to apply a factor to the video_count for each video_id and user_id
-- which would be 1 for any person likes all of the videos that X likes.  Otherwise it is less than one

-- Videos liked by X
SELECT video_id
FROM likes
WHERE user_id = 168
ORDER BY video_id

-- The count of videos liked by both X and all users Y
SELECT yl.user_id, xl.user_id, count(xl.video_id) similiar_like_count
FROM likes xl JOIN likes yl
ON xl.video_id = yl.video_id
WHERE xl.user_id = 168
AND yl.user_id !=168
GROUP BY yl.user_id,  xl.user_id

-- Even though all return 1 as the intersection of X and Y likes
-- lets continue by adding one and taking the log to assess the
-- lc for each Y given X is subject
SELECT yl.user_id, log(1+count(xl.video_id)) lc
FROM likes xl JOIN likes yl
ON xl.video_id = yl.video_id
WHERE xl.user_id = 168
AND yl.user_id !=168
GROUP BY yl.user_id

-- Now for each user Y, we can weight their likes and adjust the likes table
-- accordingly with weightings:
SELECT la.user_id, la.video_id, COALESCE(1+w.lc,1) as weighted
FROM likes la LEFT OUTER JOIN (SELECT yl.user_id, log(1+count(xl.video_id)) lc
			FROM likes xl JOIN likes yl
			ON xl.video_id = yl.video_id
			WHERE xl.user_id = 168
			AND yl.user_id !=168
			GROUP BY yl.user_id) w
		ON la.user_id = w.user_id
WHERE la.user_id != 168

-- Now calculate top 10 from this revised like table:
SELECT v.video_id, v.video_name, sum(lr.weighted) as revised_like_count 
FROM (SELECT la.user_id, la.video_id, COALESCE(1+w.lc,1) as weighted
	FROM likes la LEFT OUTER JOIN (SELECT yl.user_id, log(1+count(xl.video_id)) lc
				FROM likes xl JOIN likes yl
				ON xl.video_id = yl.video_id
				WHERE xl.user_id = 168
				AND yl.user_id !=168
				GROUP BY yl.user_id) w
			ON la.user_id = w.user_id
	WHERE la.user_id != 168) lr 
JOIN video v ON lr.video_id = v.video_id
GROUP BY v.video_id, v.video_name
ORDER BY revised_like_count DESC, v.video_id
LIMIT 10;

-- Perhaps we should try, instead of adding the lc weighting to the existing like_count
-- for each video, just using the lc. In that case, the query for the revised like
-- table would be:
SELECT la.user_id, la.video_id, COALESCE(lc,0) as weighted
FROM likes la LEFT OUTER JOIN (SELECT yl.user_id, log(1+count(xl.video_id)) lc
			FROM likes xl JOIN likes yl
			ON xl.video_id = yl.video_id
			WHERE xl.user_id = 168
			AND yl.user_id !=168
			GROUP BY yl.user_id) w
		ON la.user_id = w.user_id
WHERE la.user_id != 168

-- and the resulting top 10 "My kind of cats" would be:
SELECT v.video_id, v.video_name, sum(lr.weighted) as revised_like_count 
FROM (SELECT la.user_id, la.video_id, COALESCE(w.lc,0) as weighted
	FROM likes la LEFT OUTER JOIN (SELECT yl.user_id, log(1+count(xl.video_id)) lc
				FROM likes xl JOIN likes yl
				ON xl.video_id = yl.video_id
				WHERE xl.user_id = 168
				AND yl.user_id !=168
				GROUP BY yl.user_id) w
			ON la.user_id = w.user_id
	WHERE la.user_id != 168) lr 
JOIN video v ON lr.video_id = v.video_id
GROUP BY v.video_id, v.video_name
ORDER BY revised_like_count DESC, v.video_id
LIMIT 10;


-- I think this answer is more reasonable as it serves as a better recommender/suggestor of videos
-- that doesn't isolate the suggestions to just people like X....it weights the like_count, but doesn't
-- exclude videos when they are popular...

-- and for the win...
SELECT v.video_id, v.video_name --, sum(lr.weighted) as revised_like_count 
FROM (SELECT la.user_id, la.video_id, COALESCE(1+w.lc,1) as weighted
	FROM likes la LEFT OUTER JOIN (SELECT yl.user_id, log(1+count(xl.video_id)) lc
				FROM likes xl JOIN likes yl
				ON xl.video_id = yl.video_id
				WHERE xl.user_id = 168
				AND yl.user_id !=168
				GROUP BY yl.user_id) w
			ON la.user_id = w.user_id
	WHERE la.user_id != 168) lr 
JOIN video v ON lr.video_id = v.video_id
GROUP BY v.video_id, v.video_name
ORDER BY sum(lr.weighted) DESC, v.video_id
LIMIT 10;
