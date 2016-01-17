insert into users (user_name, fb_login) values ('claire','cbhardisty');


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
-- friends of X
-- subject == 1 is X
select v.title, v.url, count(la.video_id) as video_like_count
from like_activity la join video v on la.video_id = v.id
where user_id in ( select u.id
			from friends f join users u on f.object = u.id
			where subject = 1)
group by v.title, v.url
order by video_like_count desc
limit 10

--Option “Friends-of-Friends Likes”: The Top-10 cat videos are the ones that have collected the highest 
-- numbers of likes from friends and friends-of-friends.
-- first get friends of friends
select u.id
from friends f join users u on f.object = u.id
where subject = 1


--Option “My kind of cats”: The Top-10 cat videos are the ones that have collected 
-- the most likes from users who have liked at least one cat video that was liked by X.
--Option “My kind of cats – with preference (to cat aficionados that have the same tastes)”: The Top-10 cat videos are the ones that have collected the highest sum of weighted likes from every other user Y (i.e., given a cat video, each like on it, is multiplied according to a weight).The weight is the log cosine lc(X,Y) defined as follows: Conceptually, there is a vector vx for each user Y, including the logged-in user
--X. The vector has as many elements as the number of cat videos. Element i is 1 if Y liked the ith cat video; it is 0 otherwise. For example, if 201Cats has five cat videos and user 21 liked only the 1st and the 4th, the v21=<1,0,0,1,0>, i.e., v21[1]=v21[4]=1 and v21[2]= v21[3]=v21[5]=0. Assuming there are N cat videos, the log cosine lc(X, Y) is
