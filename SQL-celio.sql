select *
from Users

select d.userid,d.date,TimeOnPark,parks,revenue,Transactions
into DailyDataNew
from DailyData d left join (
select userid,date,sum(p.pricevalue) as revenue
from Transactions t join prices p on t.PriceID=p.PriceID
group by UserID,date) a on d.UserID=a.UserID and d.Date=a.Date left join (
select userid,date,count(p.pricevalue) as Transactions
from Transactions t join prices p on t.PriceID=p.PriceID
group by UserID,date) b
on d.UserID=b.UserID and d.date=b.Date

select *
from DailyDataNew


SELECT dd1.userid,date,TimeOnPark,parks,Transactions,mindate,maxdate,revenue1,IsSpenderNew,Seniority,ff.InstallDate,city,platform,numofcars
into usernew
from DailyDataNew dd1 left join (
select a.userid,mindate,maxdate,revenue1
from Users u left join (select u.userid,TRevenue+sum(revenue) as revenue1
from Users u join DailyDataNew d on u.UserID=d.userid
group by u.UserID,TRevenue) a
on u.UserID=a.UserID left join	 (select userid,min(date) as mindate
					from DailyDataNew
					where Transactions is not null
					group by userid
								) b
on u.UserID=b.UserID
left join (select userid,max(date) as maxdate
from DailyDataNew
where Transactions is not null
group by userid)c
on u.UserID=c.UserID) b1
on dd1.userid=b1.userid left join (select userid,case when a=1 then 'yes' else 'no' end as IsSpenderNew 
from
(
select userid,sum(IsSpender) a from
(
select  userid , case when bdika is not null then 1 
else 0 end as IsSpender
from
(select userid ,sum(revenue) as bdika
from DailyDataNew
group by userid
) b
union
select UserID, case when IsSpender='yes' then 1 else 0 end
from Users
) b
group by userid) asa)o on dd1.userid=o.userid left join (select userid,case when daysin between 0 and 730 then '<2 years'
					when daysin between 730 and 1825 then '2-5 years'
					else '5+ years' end as Seniority 
from		
(select UserID,DATEDIFF(day,InstallDate,'2021-12-31') as daysin
from Users) daysq) oi	on dd1.userid=oi.UserID left join (select userid,InstallDate,Country as city,Platform,NumOfCars
															from Users) ff on dd1.userid=ff.UserID




select userid,case when a=1 then 'yes' else 'no' end as IsSpenderNew 
into UserNew 
from
(
select userid,sum(IsSpender) a from
(
select  userid , case when bdika is not null then 1 
else 0 end as IsSpender
from
(select userid ,sum(revenue) as bdika
from DailyDataNew
group by userid) b
union
select UserID, case when IsSpender='yes' then 1 else 0 end
from Users) b
group by userid) asa
select userid,case when daysin between 0 and 730 then '<2 years'
					when daysin between 730 and 1825 then '2-5 years'
					else '5+ years' end
from		
(select UserID,DATEDIFF(day,InstallDate,'2021-12-31') as daysin
from Users) daysq

select *
from UserNew

select *
from DailyDataAll
order by userid

select u.userid,date,TimeOnPark,parks,revenue,Transactions,mindate,maxdate,TRevenue,IsSpenderNew,Seniority,InstallDate,case when ftd is null then 0 else 1 end as ftd,city,platform,NumOfCars
into DailyDataAll 
from UserNew u left join (
select userid,Rank2 as ftd
from 
(select userid, RANK() over (partition by (userid) order by (date))  as 'Rank2',date,Transactions
from DailyDataNew)a
where rank2=1 and Transactions is not null) a
on u.userid=a.userid



select *
from DailyDataAll
order by userid






select c.year,c.month,c.day,c.city,c.Seniority,c.users,c.platform,isnull(ftd,0) as ftd,tim.timeonparkday,g.Transactions,z.parkgperday,y.revenueperday
into excel
from 
(select year(date) as year ,month(date) as month ,day(date) as day,city,Seniority,platform,count (userid)as users
from DailyDataAll 
group by year(date)  ,month(date) ,day(date),city,Seniority,platform) c
left join (select year(a.date) year ,month(a.date) month,day(a.date)day,a.city,a.Seniority,platform,count(rank2) as ftd from (
select da.date, da.userid,da.city,da.Seniority,platform,RANK() over (partition by da.userid order by date )  as 'Rank2'
from DailyDataAll da
where ftd=1) a
where rank2=1
group by year(date)  ,month(date) ,day(date),city,Seniority,platform) t
on  c.year=t.year and c.month=t.month and c.day=t.day and c.city=t.city and c.Seniority=t.Seniority and t.platform=c.platform
left join (
select year(date) year ,month(date) month,day(date)day,city,Seniority,platform, sum(TimeOnPark) as timeonparkday
from DailyDataAll
group by year(date)  ,month(date) ,day(date),city,Seniority,platform) tim
on tim.year=c.year and tim.month=c.month and tim.day=c.day and tim.city=c.city and tim.Seniority=c.Seniority and tim.platform=c.platform left join (select  year(date) year ,month(date) month,day(date)day,city,Seniority,platform, count(Transactions) as Transactions
from DailyDataAll
group by year(date)  ,month(date) ,day(date),city,Seniority,platform) g
on g.day=c.day and g.month=c.month and g.Seniority=c.Seniority and c.year=g.year and c.city=g.city and g.platform=c.platform left join (
select  year(date) year ,month(date) month,day(date)day,city,Seniority,platform, sum(parks) as parkgperday
from DailyDataAll
group by year(date)  ,month(date) ,day(date),city,Seniority,platform) z
on z.day=c.day and z.month=c.month and z.Seniority=c.Seniority and c.year=z.year and c.city=z.city and z.platform=c.platform left join (select  year(date) year ,month(date) month,day(date)day,city,Seniority,platform, sum(cast(trevenue as int)) as revenueperday
from DailyDataAll
group by year(date) ,month(date) ,day(date),city,Seniority,platform) y
on y.day=c.day and y.month=c.month and y.Seniority=c.Seniority and c.year=y.year and c.city=y.city and y.platform=c.platform



SELECT *
FROM EXCEL



#######pre processing a/b test######### 


select d.userid,date,TimeOnPark,parks,Transactions,mindate,maxdate,revenue,IsSpenderNew,Seniority,InstallDate,city,platform,numofcars,COALESCE(testgroup,'control') as testgroup
from DailyDataAll d
left join (
select distinct userid,'test' as testgroup from (
select t.userid
from DailyDataAll d left join testgroup t on d.userid=t.userid) d
where d.userid in(select t.userid
from DailyDataAll d left join testgroup t on d.userid=t.userid)) a
on a.userid=d.userid
where date between '2021-01-05' and '2021-01-18'





