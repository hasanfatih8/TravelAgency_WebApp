/*
	CSE3055 Database Systems
	Project - Step 3
	Travel Agency - Stored Procedures
	150118015 - Hasan Fatih Baþar
	150118042 - Bahadýr Alacan
	150119508 - Mert Saðlam
	150119824 - Zeynep Ferah Akkurt
*/


--1----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
alter Procedure sp_TripPriceDifference
@date1 nvarchar(5), @date2 nvarchar(5)
as 
Begin
	if (not exists(Select * From Booking b Where  DATEPART(year,b.startDate) = @date1) and 
	not exists(Select * From Booking b Where  DATEPART(year,b.StartDate) = @date2))
	begin
		Print 'Trip does not exist!'
	end
	else
	begin
		Select x.Destination,y.totalPrice as SecondYear, x.totalPrice as FirstYear , y.totalPrice-x.totalPrice as PriceDifference
		From 
		(Select b.BookingID, sum(s.price) + t.Price as totalPrice, t.Destination
		From Booking b inner join Trip t on t.TripID = b.TripID inner join Booking_Service bs on bs.BookingID = b.BookingID
		inner join Service s on s.serviceID = bs.ServiceID
		Where   DATEPART(year,b.startDate) = @date1
		Group by b.BookingID, t.Price, t.Destination) x,
	
		(Select b.BookingID, sum(s.price) + t.Price as totalPrice, t.Destination
		From Booking b inner join Trip t on t.TripID = b.TripID inner join Booking_Service bs on bs.BookingID = b.BookingID
		inner join Service s on s.serviceID = bs.ServiceID
		Where   DATEPART(year,b.startDate) =  @date2
		Group by b.BookingID, t.Price, t.Destination) y
		Where x.Destination = y.Destination
	end
End

exec sp_TripPriceDifference '2018' ,'2019'


--2----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

alter Procedure sp_GroupPayment 
@totalPayment int
as
Begin
	If (@totalPayment < 0)
	Begin
		Print 'Invalid price! : Cannot enter a negative value.'
	End	
	Else
	Begin
		Select gi.GroupID, gi.GroupName, sum(p.amount) as TotalPayment
		From Booking b, Customer c, Member m, Group_Info gi, Booking_Group bg, Payment p
		Where c.CustomerID=m.CustomerID and m.GroupID = gi.GroupID and bg.groupID = gi.GroupID and b.BookingID = bg.bookingID and p.BookingID=b.BookingID and p.CustomerID=c.CustomerID
		Group by gi.GroupID, gi.GroupName
		having sum(p.amount) > @totalPayment
	End
End


exec sp_GroupPayment 10000
-- invalid input check
exec sp_GroupPayment -5

--3----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

alter Procedure sp_BookingCount
@bookingCount tinyint
as
begin	
	Select a.CustomerID, a.CustomerName, a.CustomerSurname, count(*) as NumberOfBooking
	From
	(Select c.CustomerID, c.CustomerName, c.CustomerSurname
	From Booking b, Customer c, Member m, Group_Info gi, Booking_Group bg
	Where c.CustomerID=m.CustomerID and m.GroupID = gi.GroupID and bg.groupID = gi.GroupID and b.BookingID = bg.bookingID 
	union all
	Select c.CustomerID, c.CustomerName, c.CustomerSurname
	From Customer c inner join Booking_Customer bc on c.CustomerID = bc.CustomerID inner join Booking b on b.BookingID = bc.BookingID) a
	Group by a.CustomerID, a.CustomerName, a.CustomerSurname
	having count(*) > @bookingCount
end

exec sp_BookingCount 2
-- invalid input check --> no need because tinyint positive

--4----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
alter procedure sp_TripVisa
@destination nvarchar(50)
as
begin
	If (not exists(Select t.TripID From Trip t Where t.Destination=@destination))
	Begin
		--No trip is found
		Print 'Trip does not exist!'
	End		
	Else
	Begin
		Select cv.Visa, count(*) as NumberOfPeople
		From Customer_Visa cv inner join
			(Select distinct(c.CustomerID)
			From
			Customer c,
			(Select c.CustomerID
			From Booking b, Customer c, Member m, Group_Info gi, Booking_Group bg, Trip t
			Where c.CustomerID=m.CustomerID and m.GroupID = gi.GroupID and bg.groupID = gi.GroupID and b.BookingID = bg.bookingID and b.TripID = t.TripID 
			and t.Destination = @destination
			union all
			Select  c.CustomerID
			From Customer c inner join Booking_Customer bc on c.CustomerID = bc.CustomerID inner join Booking b on b.BookingID = bc.BookingID inner join Trip t on t.TripID = b.TripID
			Where t.Destination = @destination)a
			Where c.CustomerID = a.CustomerID)k on cv.CustomerID = k.CustomerID
			Group by cv.Visa
	End
end


exec sp_TripVisa 'Africa Tour'
-- invalid input check
exec sp_TripVisa 'China Tour'

--5----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
alter Procedure sp_HotelUsingCount
@count int
as
begin
	If (@count < 0)
	Begin
		Print 'Invalid price! : Cannot enter a negative value.'
	End	
	Else
	Begin
		Select s.serviceID,h.HotelName, count(*) as NumberOfBooking
		From   Booking_Service bs, Service s, Hotel h
		Where  bs.ServiceID = s.serviceID and s.isHotel = 1 and s.serviceID=h.HotelID
		Group by s.serviceID, h.HotelName
		having count(*) >= @count
	End
end

exec sp_HotelUsingCount 3
-- invalid input check
exec sp_HotelUsingCount -3

--6----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- postpone a trip with given date (new start and new end), startdate, tripid
alter Procedure sp_PostponeTrip
	@tripId int,
	@startDate smalldatetime,
	@newSDate smalldatetime, 
	@newEDate smalldatetime
As
Begin
	
	If (not exists(Select t.TripID From Trip t Where t.TripID=@tripId))
	Begin
		--No trip is found
		Print 'Trip does not exist!'
	End		
	Else
	Begin
		Update b	
		Set b.StartDate=@newSDate, b.EndDate=@newEDate
		From Booking b inner join Trip t on b.TripID=t.TripID
		Where b.StartDate=@startDate

	End
End

exec sp_PostponeTrip 4, '2019-05-10', '2019-05-15' ,'2019-05-22'

--7----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--familie/group name, booking id, trip id whose trip started but not ended. (Just groups)
alter Procedure sp_GroupsStillOnTrip

	@SDate smalldatetime, 
	@EDate smalldatetime
As
Begin
	
	If (not exists(Select b.StartDate From Booking b where b.StartDate=@SDate))
	Begin
		Print 'Invalid date! : Trip does not exist.'
	End		
	Else if(not exists(Select b.EndDate From Booking b where b.EndDate<@EDate))
	Begin
		Print 'Invalid date! : Trip does not exist.'
	End
	Else if(not exists(Select b.TripID From Booking b where b.StartDate = @SDate and b.TripID is not null))
	Begin
		Print 'Its not a trip.'
	End
	Else
	Begin
		select gi.GroupName, c.CustomerID, bk.BookingID, bk.StartDate, bk.EndDate, t.TripID
		From Booking bk, Customer c, Member m, Group_Info gi, Booking_Group bg, Trip t
		Where c.CustomerID=m.CustomerID and m.GroupID = gi.GroupID and bg.groupID = gi.GroupID and bk.BookingID = bg.bookingID and t.TripID = bk.tripID and bk.StartDate<=@SDate and bk.EndDate>=@EDate
	End
End

exec sp_GroupsStillOnTrip '2020-01-18' ,'2020-01-19'

--8----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- for a given hotel id, check all reservations of customers for a given time period
alter Procedure sp_checkHotelReservations

	@hotelID int,
	@SDate smalldatetime, 
	@EDate smalldatetime

As
Begin
	
	If (not exists(Select h.HotelID From Hotel h where h.HotelID=@hotelID))
	Begin
		Print 'Invalid id! : Hotel does not exist.'
	End		
	Else
	Begin
		select h.HotelID, h.HotelName, b.BookingID, bc.CustomerID, c.CustomerName, c.CustomerSurname, c.PhoneNumber, b.StartDate, b.EndDate
		From Service s inner join Hotel h on s.serviceID=h.HotelID
				inner join Booking_Service bs on s.serviceID=bs.ServiceID
				inner join Booking b on b.BookingID=bs.BookingID
				inner join Booking_Customer bc on bc.BookingID=b.BookingID
				inner join Customer c on  c.CustomerID=bc.CustomerID	
		Where s.isHotel=1 and h.HotelID=@hotelID
			and b.StartDate>@SDate and b.EndDate<@EDate
		union all
		select h.HotelID, h.HotelName, b.BookingID, c.CustomerID , c.CustomerName, c.CustomerSurname, c.PhoneNumber, b.StartDate, b.EndDate
		From Service s inner join Hotel h on s.serviceID=h.HotelID
				inner join Booking_Service bs on s.serviceID=bs.ServiceID
				inner join Booking b on b.BookingID=bs.BookingID
				inner join Booking_Group bg on bg.BookingID=b.BookingID
				inner join Group_Info g on g.GroupID=bg.GroupID
				inner join Member m on m.GroupID=bg.GroupID, Customer c
		Where s.isHotel=1 and h.HotelID=@hotelID  and c.CustomerID=m.CustomerID
			and b.StartDate>@SDate and b.EndDate<@EDate

	End
End

exec sp_checkHotelReservations 34, '2017-07-05', '2017-08-01'

--9----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- customer hangi yurtdýþý triplere katýlabilir pasaport süresi dolmadan

alter Procedure sp_AbroadTripsForCustomer

	@cId bigint
As
Begin

	If (not exists(Select c.CustomerID From Customer c where c.CustomerID=@cId))
	Begin
		Print 'Invalid customer id! : Customer does not exist.'
	End
	Else if(not exists(select p.ExpireDate
					   from Passport p where p.CustomerID=@cId))
	Begin
		Print 'Customer does not have a passport data! : Passport does not exist.'
	End
	Else
	Begin
		
		Declare @CusExpirePassDate smalldatetime
		Set @CusExpirePassDate = (select p.ExpireDate
							  from Customer c inner join Passport p on c.CustomerID=p.CustomerID
							  where c.CustomerID=@cId)
			
		select  c.CustomerID, c.CustomerName, @CusExpirePassDate ExpireDate, abrTrip.StartDate, abrTrip.EndDate , abrTrip.TripID, abrTrip.StartLocation, abrTrip.Destination
		from Customer c,(select b.BookingID, t.TripID, b.StartDate, b.EndDate, t.StartLocation, t.Destination
						 From Booking b inner join Trip t on b.TripID=t.TripID
						 where t.isAbroad=1) abrTrip
		where abrTrip.EndDate<@CusExpirePassDate and c.CustomerID=@cId
		order by abrTrip.StartDate
	End
End

exec sp_AbroadTripsForCustomer 15245818778
exec sp_AbroadTripsForCustomer 93734154736

--customer olmayan
exec sp_AbroadTripsForCustomer 1111
--customer olup pasaportu olmayan
exec sp_AbroadTripsForCustomer 29154887688



--10---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
alter Procedure sp_findNumberOfEachServices
	@tripId int,
	@startDate smalldatetime
As
Begin
	
	If (not exists(Select t.TripID From Trip t Where t.TripID=@tripId))
	Begin
		--NC: no trip is found
		Print 'Trip does not exist!'
	End		
	Else
	Begin
		if(not exists(select b.StartDate
					   from Booking b where b.StartDate=@startDate))
		Begin
			Print 'Invalid start date! : There is no trip on given date.'
		End
		Else
		Begin
		
			select b.BookingID, t.TripID, t.StartLocation, t.Destination,
						isnull(hs1.NoOfHotelsBooked,0) NoOfHotelsBooked, isnull(fs2.NoOfFlightsBooked,0) NoOfFlightsBooked , isnull(cs3.NoOCarsBooked,0) NoOCarsBooked
			from Booking b inner join Trip t on t.TripID=b.TripID
					left outer join (select count(*) NoOfHotelsBooked, b.BookingID
								from Booking b inner join Trip t on t.TripID=b.TripID
										inner join Booking_Service bs on bs.BookingID=b.BookingID
										inner join Service s on s.serviceID=bs.ServiceID
								where s.isHotel=1
								Group by s.isHotel, b.BookingID) hs1 on hs1.BookingID=b.BookingID
					left outer join (select count(*) NoOfFlightsBooked, b.BookingID
								from Booking b inner join Trip t on t.TripID=b.TripID
										inner join Booking_Service bs on bs.BookingID=b.BookingID
										inner join Service s on s.serviceID=bs.ServiceID
								where s.isFlight=1
								Group by s.isFlight, b.BookingID) fs2 on b.BookingID=fs2.BookingID
					left outer join (select count(*) NoOCarsBooked, b.BookingID
								from Booking b inner join Trip t on t.TripID=b.TripID
										inner join Booking_Service bs on bs.BookingID=b.BookingID
										inner join Service s on s.serviceID=bs.ServiceID
								where s.isCar=1
								Group by s.isCar, b.BookingID) cs3 on cs3.BookingID=b.BookingID
			where t.TripID=@tripId and b.StartDate=@startDate

		End
	End
End

exec sp_findNumberOfEachServices 2, '2019-01-15'
exec sp_findNumberOfEachServices 3, '2018-01-20'
-- invalid date check
exec sp_findNumberOfEachServices 3, '2025-01-20'
-- invalid trip id check
exec sp_findNumberOfEachServices 83, '2018-01-20'
