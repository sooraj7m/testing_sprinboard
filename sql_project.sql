/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name
FROM country_club.Facilities
WHERE membercost>0
;

/* Q2: How many facilities do not charge a fee to members? */
SELECT count(*)
FROM country_club.Facilities
WHERE membercost=0
;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid, name, membercost, monthlymaintenance
FROM country_club.Facilities
WHERE membercost >0
AND membercost < ( 0.20 * monthlymaintenance )
;

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT *
FROM country_club.Facilities
WHERE facid in (1,5)
;

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT name,
	   monthlymaintenance,
	   case when monthlymaintenance>100 then 'expensive'
	   else 'cheap' end as affordability
FROM country_club.Facilities
;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname, surname
FROM country_club.Members
WHERE  joindate in (select max(joindate) from country_club.Members)
;

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT distinct fac.name, concat(firstname, ' ', surname) as member_name
FROM country_club.Facilities fac
LEFT JOIN country_club.Bookings book
	ON fac.facid=book.facid
LEFT JOIN country_club.Members mem
	ON book.memid=mem.memid
WHERE upper(name) like '%TENNIS COURT%'
ORDER BY member_name
;

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT fac.name as fac_name
	 , book.bookid
	 , concat(mem.firstname, ' ', mem.surname) as member_name
	 , (book.slots* (case when book.memid=0 then fac.guestcost
	   else fac.membercost end)) as totalcost
			
FROM country_club.Bookings book
LEFT JOIN country_club.Facilities fac
	ON book.facid=fac.facid
LEFT JOIN country_club.Members mem
	ON book.memid=mem.memid
WHERE CAST( book.starttime AS DATE )='2012-09-14'
AND (book.slots* (case when book.memid=0 then fac.guestcost
	   else fac.membercost end)) >30
ORDER BY totalcost desc
;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT totals.fac_name, totals.bookid, concat(mem.firstname, ' ', mem.surname) as member_name, totals.totalcost
FROM
(SELECT fac.name as fac_name, 
       book.memid, 
       book.bookid, 
 	   book.starttime,
       book.slots* (case when book.memid=0 then fac.guestcost else fac.membercost end) as totalcost
 FROM country_club.Bookings book
 LEFT JOIN country_club.Facilities fac
	   ON book.facid=fac.facid
WHERE CAST( book.starttime AS DATE )='2012-09-14') totals

LEFT JOIN country_club.Members mem
	ON totals.memid=mem.memid
WHERE totals.totalcost >30
ORDER BY totals.totalcost desc
;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT fac.name as fac_name, sum(book.slots* (case when book.memid=0 then fac.guestcost else fac.membercost end)) as revenue		
FROM country_club.Bookings book
LEFT JOIN country_club.Facilities fac
	ON book.facid=fac.facid
GROUP BY book.facid
HAVING revenue<1000
ORDER BY revenue
;
