--Basic:
--Which tracks appeared in the most playlists? how many playlist did they appear in?
SELECT tracks.Name, COUNT(*) FROM playlist_track
JOIN tracks on playlist_track.TrackId = tracks.TrackId
GROUP BY playlist_track.TrackId
ORDER BY 2 DESC;
--Which track generated the most revenue? which album? which genre?
SELECT tracks.Name, SUM(invoice_items.UnitPrice), albums.Title, genres.Name FROM invoice_items
JOIN tracks ON invoice_items.TrackId = tracks.TrackId
JOIN albums ON albums.AlbumId = tracks.AlbumId
JOIN genres ON genres.GenreId = tracks.GenreId
GROUP BY invoice_items.TrackId
ORDER BY 2 DESC;
--Which countries have the highest sales revenue? What percent of total revenue does each country make up?
SELECT 
	invoices.BillingCountry, 
	SUM(invoices.Total),
	SUM(invoices.Total)*100/(SELECT SUM(invoices.Total) FROM invoices) as Percent  
FROM invoices
GROUP BY 1
ORDER BY 2 DESC;
--How many customers did each employee support
SELECT employees.FirstName, employees.LastName, count(*) FROM customers
JOIN employees ON employees.EmployeeId = customers.SupportRepId
GROUP BY employees.EmployeeId;
--What is the average revenue for each sale,What is their total sale?
SELECT AVG(invoices.Total),SUM(invoices.Total) FROM invoices;
--Intermediate:
--Do longer or shorter length albums tend to generate more revenue?
WITH album_sell as (SELECT Count(DISTINCT tracks.TrackId) as lengthz, SUM(invoice_items.UnitPrice) as Revenue, albums.Title FROM tracks
JOIN albums on tracks.AlbumId = albums.AlbumId
LEFT JOIN invoice_items on tracks.TrackId = invoice_items.TrackId
GROUP BY albums.AlbumId)
SELECT count(*) AS 'Number of Albums',lengthz AS 'Album_Length', round(AVG(Revenue),2) as 'Mean Revenue' from album_sell
GROUP BY Album_Length
ORDER BY 3 DESC;
--Is the number of times a track appear in any playlist a good indicator of sales?
WITH appp AS(SELECT count(*) totl,TrackId from playlist_track
GROUP BY TrackId),
rev AS (SELECT Sum(UnitPrice) AS totl,TrackId from invoice_items
GROUP BY TrackId)
SELECT avg(rev.totl), appp.totl from appp
LEFT JOIN rev ON rev.TrackId = appp.TrackId
GROUP BY appp.totl;
--Advanced:How much revenue is generated each year, and what is its percent change 20 from the previous year?
WITH yearly as (SELECT strftime('%Y',InvoiceDate) AS YEAR, sum(total) AS TOTAL FROM invoices
GROUP BY 1)
SELECT yearly.YEAR, yearly.TOTAL, round((yearly.TOTAL - sum(invoices.total))*100/sum(invoices.total),2) AS 'Percentage Change from last year' FROM yearly
LEFT JOIN invoices on CAST(yearly.YEAR AS INTEGER)-1 = CAST(strftime('%Y',invoices.InvoiceDate) AS INTEGER)
GROUP BY strftime('%Y',invoices.InvoiceDate);


