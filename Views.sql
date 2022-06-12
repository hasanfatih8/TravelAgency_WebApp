/*
	CSE3055 Database Systems
	Project - Step 3
	Travel Agency - Views
	150118015 - Hasan Fatih Baþar
	150118042 - Bahadýr Alacan
	150119508 - Mert Saðlam
	150119824 - Zeynep Ferah Akkurt
*/

--1----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

alter View Group_Alone_Booking_Customer_AllPayment as
Select c.CustomerID, c.CustomerName, c.CustomerSurname,groupBook.totalPayment + aloneBook.totalPayment as TotalPayment
From Customer c inner join
(Select c.CustomerID, sum(p.amount) totalPayment
From Booking b, Customer c, Member m, Group_Info gi, Booking_Group bg, Payment p
Where c.CustomerID=m.CustomerID and m.GroupID = gi.GroupID and bg.groupID = gi.GroupID and b.BookingID = bg.bookingID and p.BookingID=b.BookingID and
p.CustomerID=c.CustomerID
Group by c.CustomerID)groupBook on c.CustomerID = groupBook.CustomerID inner join
(Select  c.CustomerID, sum(p.amount) totalPayment
From Customer c inner join Booking_Customer bc on c.CustomerID = bc.CustomerID inner join Booking b on b.BookingID = bc.BookingID inner join Payment p on
p.CustomerID = c.CustomerID and p.BookingID=b.BookingID
Group by c.CustomerID) aloneBook on
groupBook.CustomerID = aloneBook.CustomerID

--2----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

alter View Average_Customer_Age_Trip as
Select a.Destination,avg(a.age * 1.0) as AverageAge
From
(Select t.TripID,t.Destination, c.Age
From Booking b, Customer c, Member m, Group_Info gi, Booking_Group bg, Trip t
Where c.CustomerID=m.CustomerID and m.GroupID = gi.GroupID and bg.groupID = gi.GroupID and b.BookingID = bg.bookingID and t.TripID = b.TripID 
union all
Select  t.TripID, t.Destination ,c.Age
From Customer c inner join Booking_Customer bc on c.CustomerID = bc.CustomerID inner join Booking b on b.BookingID = bc.BookingID inner join Trip t on t.TripID=b.TripID) a
Group by a.Destination

--3----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

alter View Payment_Not_Finished as
Select c.CustomerID, b.BookingID, b.TotalPrice, sum(p.amount) AmountPaid
From Booking b, Customer c, Member m, Group_Info gi, Booking_Group bg, Payment p
Where c.CustomerID=m.CustomerID and m.GroupID = gi.GroupID and bg.groupID = gi.GroupID and b.BookingID = bg.bookingID and p.BookingID=b.BookingID and p.CustomerID=c.CustomerID
Group by c.CustomerID, b.TotalPrice, b.BookingID
having sum(p.amount) < b.TotalPrice
union all
Select  c.CustomerID, b.BookingID, b.TotalPrice, sum(p.amount) AmountPaid
From Customer c inner join Booking_Customer bc on c.CustomerID = bc.CustomerID inner join Booking b on b.BookingID = bc.BookingID inner join Payment p on p.BookingID=b.BookingID
and p.CustomerID=c.CustomerID
Group by c.CustomerID, b.TotalPrice, b.BookingID
having sum(p.amount) < b.TotalPrice
			

--4----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

alter View Not_Started_Booking as
Select c.CustomerID, b.BookingID
From Booking b, Customer c, Member m, Group_Info gi, Booking_Group bg
Where c.CustomerID=m.CustomerID and m.GroupID = gi.GroupID and bg.groupID = gi.GroupID and b.BookingID = bg.bookingID and b.StartDate > getdate()
union all
Select  c.CustomerID, b.BookingID
From Customer c inner join Booking_Customer bc on c.CustomerID = bc.CustomerID inner join Booking b on b.BookingID = bc.BookingID 
Where b.StartDate > getdate()
			
			
--5----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

alter View Abroad_Trip_Customer_Vaccination as 
Select vc.VaccinationCard, count(*) as Number
From Customer_Vaccination_Card vc inner join
(Select distinct(c.CustomerID)
From Customer c,
(Select c.CustomerID
From Booking b, Customer c, Member m, Group_Info gi, Booking_Group bg, Trip t
Where c.CustomerID=m.CustomerID and m.GroupID = gi.GroupID and bg.groupID = gi.GroupID and b.BookingID = bg.bookingID and t.TripID = b.TripID and t.isAbroad = 1
union all
Select   c.CustomerID
From Customer c inner join Booking_Customer bc on c.CustomerID = bc.CustomerID inner join Booking b on b.BookingID = bc.BookingID inner join Trip t on t.TripID=b.TripID
Where t.isAbroad = 1)a
Where c.CustomerID = a.CustomerID)k on vc.CustomerID = k.CustomerID
Group by vc.VaccinationCard		