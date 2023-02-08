--                                      @  MANDATORY PROJECT ------ ON THE IG_CLONE DATABASE   @

USE IG_CLONE;   # USE TO ACTIVATE THE DATABSE #
SHOW TABLES;    # TO SEE ALL THE TABLES IN DATABASE #

#Create an ER diagram or draw a schema for the given database?
--  IN ORDER TO MAKE THE ER DIAGRAM GO TO MENU BAR > DATABASE > REVERSE ENGINEER or PRESS CTRL+R > ENTER THE PASSWORD > CHOOSE THE DATABASE 

-- An ER (Entity Relationship) diagram is a graphical representation of 
-- entities and their relationships to each other in a database. The entities are represented as rectangles, and 
-- the relationships between entities are represented as lines connecting the rectangles.

-- ER diagrams are used to model the data and relationships in a database, and they can be used to create a database schema.
-- The schema is a blueprint of how the database should be structured, and
-- it includes information about the entities, attributes, and relationships in the database

-- ER diagrams are a useful tool for database design and modeling, 
-- as they help to visualize the structure of the database and to ensure that the data is properly organized and related to each other.



#We want to reward the user who has been around the longest, Find the 5 oldest users.?

select * from users;

select id,username,created_at   from users
order by created_at asc
limit 5;

# 2 )To understand when to run the ad campaign, figure out the day of the week most users register on???????????????????????????????

SELECT 
     DAYNAME(created_at) AS day,
     count(*) as total
FROM users
GROUP BY day
ORDER BY total DESC
limit 2;


# 
with names as (
select dayname(created_at) as days,id from users
					)
                    
     select  days,count(days) as total from names  
     group by days
     order by total desc
     limit 2;
     
#To target inactive users in an email ad campaign, find the users who have never posted a photo.??????????????????????????????????????
     
select * from hotos;
     
SELECT username,users.id,photos.id
FROM users
LEFT JOIN photos
	ON users.id=photos.user_id   # total every users=100
WHERE photos.id IS NULL
order by users.id;



SELECT username, IFNULL(photos.id,'No posts') as status,users.id
FROM users
LEFT JOIN photos ON photos.user_id=users.id
WHERE photos.id IS NULL;



#Suppose you are running a contest to find out who got the most likes on a photo. Find out who won????????????????????????????????????????
select * from likes;

select photo_id,count(photo_id) as total,photos.user_id,username,image_url from users 
join photos on users.id=photos.user_id
join likes on photos.id=likes.photo_id
group by photo_id
order by total desc
limit 1;



#The investors want to know how many times does the average user post.?????????????????????????????????????????????

  select ((select count(id) from photos)/(select count(id) from users)) as avg;
																			# we consider users who are also not posted any photo 
  
  
  SELECT AVG(post) as avg
FROM ( 
    SELECT username, COUNT(photos.id) as post FROM users
	JOIN photos ON users.id=photos.user_id
    GROUP BY users.username          # we consider users only part of the post
) as t; 
  
  
  
#A brand wants to know which hashtag to use on a post, and find the top 5 most used hashtags.????????????????????????????????

select *from photo_tags;#photo_id,tag_id
select * from tags;#id,tag_name


select t.tag_name,tag_id,count(tag_name) as total from tags t join photo_tags pt
on t.id=pt.tag_id
group by t.tag_name
order by total desc
limit 5;


#To find out if there are bots, find users who have liked every single photo on the site.?????????????????????????????????

select * from users;
select * from likes;

SELECT users.id,username,COUNT(users.id) As total_likes_by_user
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id
HAVING total_likes_by_user = (SELECT COUNT(*) FROM photos);



#To know who the celebrities are, find users who have never commented on a photo.??????????????????????????

select * from users;
select * from comments;

select id,username from users where id not in(select user_id from comments
														group by user_id);
                                                        
                                                        
                                                        
SELECT username,comment_text,users.id
FROM users
LEFT JOIN comments ON users.id = comments.user_id
where comment_text IS NULL
GROUP BY users.id;
                                           
                                           
SELECT username,users.id,ifnull(comment_text,'no comment') as status
FROM users
LEFT JOIN comments ON users.id = comments.user_id
where comment_text IS NULL
GROUP BY users.id;                                          
                                           
                                           

#Now it's time to find both of them together, find the users who have never commented on any photo or have commented on every photo.????



SELECT count(user_id) as count,user_id as comment_user_id,users.id, username,ifnull(comment_text,'no comments') as status
FROM users
LEFT JOIN comments ON users.id = comments.user_id
where comment_text IS NULL
GROUP BY users.id  # no one commented

 union 

select count(user_id) as count,user_id as comment_user_id,users.id, username,ifnull(comment_text,'no comments') as status 
from comments  
join users  on users.id=comments.user_id
group by user_id
having count=(select count(*) from photos);#commented on every photo
#   AND
SELECT count(user_id) as count,user_id as comment_user_id,users.id, username,ifnull(comment_text,'no comments') as status
FROM users
LEFT JOIN comments ON users.id = comments.user_id

GROUP BY users.id
having count=0  # no one commented

 union 

select count(user_id) as count,user_id as comment_user_id,users.id, username,comment_text as status 
from comments  
join users  on users.id=comments.user_id
group by user_id
having count=(select count(*) from photos);#commented on every photo

# AND
select id as user_id,username,(case when id is  null then 'no' else 'commented on every photo'end) as 'observation'
from users where id not in (select user_id from comments group by user_id)
union
select id as user_id,username,(case when id is null then 'no' else 'never commented' end) as 'observation' from users where id in 
(select user_id from comments
group by user_id 
having count(photo_id)=(select count(id) from photos));




-- ------------------------------------------------------------------ THANK YOU --------------------------------------------------------------------------