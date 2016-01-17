-- OVERALL LIKES
select v.title, count(video_id) as like_count 
from like_activity la join video v on la.video_id = v.id
group by v.title
order by like_count desc
limit 1

-- FRIEND LIKES

select object
from friends
where subject = 1;

select video_id
from like_activity
where user_id in ( select object
		from friends
		where subject = 1)

select v.title, count(video_id) as like_count
from like_activity la join video v on la.video_id = v.id
group by v.title
order by like_count desc
limit 1