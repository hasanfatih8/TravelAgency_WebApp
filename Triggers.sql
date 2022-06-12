/*
	CSE3055 Database Systems
	Project - Step 3
	Travel Agency - Triggers
	150118015 - Hasan Fatih Baþar
	150118042 - Bahadýr Alacan
	150119508 - Mert Saðlam
	150119824 - Zeynep Ferah Akkurt
*/


alter Trigger trg_updateBookingPrice --for booking_service
on Booking_Service
after insert,delete,update
as 
begin
	Update b
	Set b.TotalPrice = b.TotalPrice + s.Price 
	From Booking b inner join inserted i on b.bookingID = i.BookingID inner join Service s on s.serviceID = i.ServiceID

	Update b
	Set b.TotalPrice = b.TotalPrice - s.Price 
	From Booking b inner join deleted i on b.bookingID = i.BookingID inner join Service s on s.serviceID = i.ServiceID
end



create Trigger trg_updateBookingPrice2 --for trip
on Trip
after insert,delete,update
as 
begin
	Update b
	Set b.TotalPrice = b.TotalPrice + i.Price
	From Booking b inner join inserted i on b.TripID = i.TripID

	Update b
	Set b.TotalPrice = b.TotalPrice - i.Price
	From Booking b inner join deleted i on b.TripID = i.TripID
end


create Trigger trg_updateBookingPrice3 --for service
on Service
after insert,delete,update
as 
begin
	Update b
	Set b.TotalPrice = b.TotalPrice + i.Price
	From Booking_Service bs inner join inserted i on bs.serviceID = i.serviceId inner join Booking b on b.bookingID = bs.bookingID

	Update b
	Set b.TotalPrice = b.TotalPrice - i.Price
	From Booking_Service bs inner join deleted i on bs.serviceID = i.serviceId inner join Booking b on b.bookingID = bs.bookingID
end






