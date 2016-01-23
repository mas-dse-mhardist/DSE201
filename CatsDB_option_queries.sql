-- OVERALL LIKES
-- Option “Overall Likes”: The Top-10 cat videos are the ones that have collected the highest
-- numbers of likes, overall.
select v.title, v.url, count(video_id) as like_count 
from like_activity la join video v on la.video_id = v.id
group by v.title, v.url
order by like_count desc
limit 10

-- FRIEND LIKES
-- Option “Friend Likes”: The Top-10 cat videos are the ones that have collected the highest 
-- numbers of likes from the friends of X.
-- Friends of X also means that X's likes are not included
SELECT v.title, v.url, count(la.video_id) as video_like_count
FROM video v JOIN like_activity la ON v.id = la.video_id
	JOIN users u ON u.id = la.user_id 
	JOIN friends f ON u.id = f.object AND la.user_id != f.subject
WHERE f.subject = 1
GROUP BY v.title, v.url
ORDER BY video_like_count DESC
LIMIT 10;

-- Option “Friends-of-Friends Likes”: The Top-10 cat videos are the ones that have collected the highest 
-- numbers of likes from friends and friends-of-friends.
-- I'm assuming that even though it is possible for X to be a friend of a friend of him/herself, this is not 
-- the intent.  Intent should be that we get friends of friends that aren't X.

-- Using a subquery
SELECT v.title, count(la.video_id) as video_like_count
FROM like_activity la JOIN video v ON la.video_id = v.id
WHERE la.user_id IN (
	SELECT f1.object
	FROM friends f1 JOIN friends f2 ON f1.object = f2.subject
	WHERE f1.subject = 1
	GROUP BY f1.object)
AND la.user_id != 1
GROUP BY v.title, v.url, la.video_id
ORDER BY video_like_count DESC
LIMIT 10;

-- using count distinct with no subquery
SELECT v.title, count(distinct la.user_id) my_count
FROM friends f1 JOIN friends f2 ON f1.object = f2.subject 
	JOIN like_activity la ON la.user_id = f1.object AND la.user_id != f1.subject
	JOIN video v ON la.video_id = v.id
WHERE f1.subject = 1
GROUP BY v.title
ORDER BY my_count desc
LIMIT 10;

--Option “My kind of cats”: The Top-10 cat videos are the ones that have collected 
-- the most likes from users who have liked at least one cat video that was liked by X.
-- In this case, to me, this seems to answer the question of people like you also
-- liked these other videos.  Again, it doesn't make sense to include the likes from X
-- if we are trying to determine what other people like X liked.
-- Breaking it down:
-- Videos that were liked by X
SELECT video_id
FROM like_activity
WHERE user_id = 1
-- users who have liked at least one cat video liked by X
SELECT DISTINCT user_id
FROM like_activity
WHERE video_id IN (SELECT video_id
		FROM like_activity
		WHERE user_id = 1)
AND user_id != 1
ORDER BY user_id
-- now without subquery
SELECT DISTINCT la2.user_id
FROM like_activity la1 
	JOIN like_activity la2 ON la1.video_id = la2.video_id AND la1.user_id != la2.user_id
WHERE la1.user_id = 1
ORDER BY la2.user_id

-- now top videos that have collected the most likes from users who like at least one cat video liked by X
-- using subquery
SELECT title, count(distinct user_id)
FROM like_activity la JOIN video v ON la.video_id = v.id
WHERE user_id in (SELECT DISTINCT la2.user_id
		FROM like_activity la1 JOIN like_activity la2 ON la1.video_id = la2.video_id AND la1.user_id != la2.user_id
		WHERE la1.user_id = 1)
GROUP BY title
ORDER BY count(title) desc
LIMIT 10

-- without subquery
SELECT v.title, count(distinct la3.user_id)
FROM like_activity la1 JOIN like_activity la2 ON la1.video_id = la2.video_id AND la1.user_id != la2.user_id
	JOIN like_activity la3 ON la2.user_id = la3.user_id
	JOIN video v ON la3.video_id = v.id
WHERE la1.user_id = 1
GROUP BY v.title
ORDER BY count(distinct la3.user_id) DESC


-- Option “My kind of cats – with preference (to cat aficionados that have the same tastes)”: 
-- The Top-10 cat videos are the ones that have collected the highest sum of weighted likes 
-- from every other user Y (i.e., given a cat video, each like on it, is multiplied according to a weight).
-- The weight is the log cosine lc(X,Y) defined as follows: Conceptually, there is a 
-- vector vx for each user Y, including the logged-in user
--X. The vector has as many elements as the number of cat videos. Element i is 1 if Y liked the ith cat 
-- video; it is 0 otherwise. For example, if 201Cats has five cat videos and user 21 liked only the 1st and the 4th, 
-- the v21=<1,0,0,1,0>, i.e., v21[1]=v21[4]=1 and v21[2]= v21[3]=v21[5]=0. Assuming there are N cat videos, the log cosine lc(X, Y) is


