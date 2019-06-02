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
Code:
SELECT name, 
	   membercost
	FROM country_club.Facilities
	WHERE membercost !=0
	

/* Q2: How many facilities do not charge a fee to members? */
Ans:4
Code:
SELECT COUNT(DISTINCT facid) AS facilities_without_charge
	FROM country_club.Facilities
	WHERE membercost=0


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
Code:
SELECT facid, 
       name, 
 	   membercost, 
	   monthlymaintenance
	   FROM country_club.Facilities
	   WHERE membercost!=0 AND membercost<monthlymaintenance*0.2
/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
Code:
SELECT *
	   FROM country_club.Facilities
	   WHERE facid IN (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
Code:
SELECT name,
	   monthlymaintenance,
	   CASE WHEN monthlymaintenance>100 THEN 'expensive' ELSE 'cheap' END AS cost_label
	   FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
Code:
SELECT members.firstname, 
	   members.surname, 
	   members.joindate
       FROM country_club.Members members
       JOIN (
			 SELECT MAX( joindate ) AS maxdate
			 FROM country_club.Members
            ) latest_member 
	   ON members.joindate = latest_member.maxdate

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
Code:
SELECT CONCAT( mem.firstname,  ' ', mem.surname ) AS member_name, 
	   fac.name AS facility_name
				FROM country_club.Bookings book
			JOIN (

					SELECT * 
					FROM country_club.Facilities
						WHERE name LIKE  'tennis%'
					)fac ON fac.facid = book.facid
				JOIN country_club.Members mem ON mem.memid = book.memid
				GROUP BY 1,2
				ORDER BY 1 

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
Code:
SELECT fac.name,
	   CONCAT(mem.firstname,' ',mem.surname) AS member_name,
	   CASE WHEN book.memid=0 THEN book.slots*fac.guestcost ELSE book.slots*fac.membercost END AS cost
	   FROM country_club.Bookings book
	   JOIN country_club.Facilities fac ON fac.facid = book.facid AND book.starttime LIKE '2012-09-14%'
	   JOIN country_club.Members mem ON mem.memid = book.memid
	WHERE (CASE WHEN book.memid=0 THEN book.slots*fac.guestcost ELSE book.slots*fac.membercost END)>30
	ORDER BY cost DESC
	   
			

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
Code:

SELECT bookfac.name,
	   CONCAT(mem.firstname,' ',mem.surname) AS member_name,
	   bookfac.cost
	   FROM country_club.Members mem 
       JOIN (SELECT fac.name, book.memid,
            	   CASE WHEN book.memid=0 THEN book.slots*fac.guestcost ELSE book.slots*fac.membercost END AS cost
            	   FROM country_club.Bookings book
	  			   JOIN country_club.Facilities fac 
            	   ON fac.facid = book.facid
              WHERE book.starttime LIKE '2012-09-14%'

            ) bookfac	
	   ON mem.memid = bookfac.memid
    WHERE bookfac.cost>30
	ORDER BY cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
Code:
SELECT sub2.name,
	   sub2.total_cost
      FROM (
	  	SELECT sub.name,
	  	 	   SUM(sub.cost) as total_cost
				FROM (
  				SELECT fac.name,
	   				   CASE WHEN book.memid=0 THEN book.slots*fac.guestcost ELSE book.slots*fac.membercost END AS cost
	   					FROM country_club.Bookings book
	   					JOIN country_club.Facilities fac ON fac.facid = book.facid 
	   					JOIN country_club.Members mem ON mem.memid = book.memid
            		) sub
                GROUP BY 1
 			) sub2
       WHERE sub2.total_cost<1000
	   ORDER BY sub2.total_cost
