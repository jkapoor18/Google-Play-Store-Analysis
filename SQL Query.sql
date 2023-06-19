CREATE TABLE Playstore_apps(
App VARCHAR(200),
Category VARCHAR(50),
Rating DECIMAL(2,1),
Reviews INT,
Size DECIMAL(5,1),
Installs INT,
`Type` VARCHAR(20),
Price DECIMAL(5,2),
Content_Rating VARCHAR(50),
Genre_1 VARCHAR(50),
Genre_2 VARCHAR(50),
Last_Updated VARCHAR(50),	
Current_Ver VARCHAR(50),
Android_Ver VARCHAR(50)
);

###Loading the data into the table (Playstore_apps) created
---------------------------------------------
LOAD DATA LOCAL infile
"C:/Users/jyoti/Desktop/JK/ABC.csv"
INTO TABLE Playstore_apps
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
set global local_infile = 1;

SELECT * from playstore_apps;

###Creating the Playstore_reviews table
-----------------------------
CREATE TABLE IF NOT EXISTS Playstore_reviews(
App VARCHAR(100),	
Translated_Review VARCHAR(3000),	
Sentiment VARCHAR(50),
Sentiment_Polarity DECIMAL(4,3),	
Sentiment_Subjectivity DECIMAL(4,3)
);

###Loading the data into the table(Playstore_reviews) created
----------------------------------------------
LOAD DATA LOCAL infile
"C:/Users/jyoti/Desktop/JK/Review.csv"
INTO TABLE Playstore_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Select * from playstore_reviews;

###Getting an overview of the data structure by printing the first 10 rows of both the datasets
SELECT * FROM Playstore_apps LIMIT 10;


-- 1. Which apps have the highest rating in the given available dataset?

SELECT App AS Highest_rated_apps
  FROM (SELECT App,
                         dense_rank() OVER(ORDER BY Rating DESC) AS Ratingwise_rank 
	   FROM Playstore_apps) AS A
 WHERE Ratingwise_rank = 1;
 
 
 -- 2. What are the number of installs and reviews for the above apps? Return the apps with the highest reviews to the top.

SELECT App AS Highest_rated_apps,
            Installs, 
            Reviews 
 FROM (SELECT *,
                        dense_rank() OVER(ORDER BY Rating DESC) AS Ratingwise_rank 
              FROM Playstore_apps) AS A
WHERE Ratingwise_rank = 1 ORDER BY Reviews DESC;

-- 3. Which app has the highest number of reviews? Also, mention the number of reviews and category of the app

SELECT App,
            Reviews,
            Category 
  FROM Playstore_apps 
WHERE Reviews = (SELECT max(Reviews) 
                                FROM Playstore_apps);
                                
-- 4. What is the total amount of revenue generated by the google play store by hosting apps? (Whenever a user buys apps  from the google play store, the amount is considered in the revenue)

SELECT SUM(Price) AS Revenue_generated 
  FROM Playstore_apps;
  
  -- 5. Which Category of google play store apps has the highest number of installs? also, find out the total number of installs for that particular category.

   SELECT Category,
                SUM(installs) AS Total_installs 
      FROM Playstore_apps 
GROUP BY Category 
ORDER BY 2 DESC
       LIMIT 1;
       
-- 6.Which Genre has the most number of published apps?

           WITH cte_max_publishes_apps AS
                    (SELECT Genre_1 
          FROM Playstore_app
  UNION ALL
                    SELECT Genre_2 
                    FROM Playstore_apps 
                    WHERE Genre_2 <> 'Not Applicable')
       SELECT Genre_1,
                   COUNT(*) AS No_of_apps
        FROM Playstore_apps 
 GROUP BY Genre_1 
 ORDER BY 2 DESC
        LIMIT 1;
        
        
-- 7.Provide the list of all games ordered in such a way that the game that has the highest number of installs is displayed on the top(to avoid duplicate results use distinct)

  SELECT DISTINCT App
FROM Playstore_apps
WHERE Category = 'Game'
ORDER BY Installs DESC;



-- 8. Provide the list of apps that can work on android version 4.0.3 and UP.

SELECT App 
  FROM Playstore_apps 
 WHERE Android_Ver LIKE '%4.0.3 and up%';
 
 -- 9. How many apps from the given data set are free? Also, provide the number of paid apps.

       SELECT `Type`,
                   COUNT(*) AS No_of_apps
        FROM Playstore_apps 
 GROUP BY `Type`;


-- 10.Which is the best dating app? (Best dating app is the one having the highest number of Reviews)

SELECT App 
  FROM Playstore_apps 
 WHERE Reviews = ( SELECT MAX(Reviews) 
                                  FROM Playstore_apps 
	                    WHERE Category = 'Dating');
                        
-- 11. Get the number of reviews having positive sentiment and number of reviews having negative sentiment for the app 10 best foods for you and compare them.

SELECT *,
    CASE WHEN No_of_positives > No_of_Negatives THEN 'Positive reviews are more'
        ELSE 'Negative reviews are more'
    END AS Comparison
FROM (
    SELECT App,
        SUM(CASE WHEN Sentiment = 'Positive' THEN 1 ELSE 0 END) AS No_of_positives,
        SUM(CASE WHEN Sentiment = 'Negative' THEN 1 ELSE 0 END) AS No_of_Negatives
    FROM Playstore_reviews
    WHERE App = '10 best foods for you'
    GROUP BY App
) AS reviews_summary;


-- 12.Which comments of ASUS SuperNote have sentiment polarity and sentiment subjectivity both as 1?

SELECT Translated_Review 
  FROM Playstore_reviews 
 WHERE App = 'ASUS SuperNote' 
   AND Sentiment_Polarity = 1 
   AND Sentiment_Subjectivity = 1;
   
   -- 13.Get all the neutral sentiment reviews for the app Abs Training-Burn belly fat 

SELECT Translated_Review 
  FROM Playstore_reviews 
 WHERE App = 'Abs Training-Burn belly fat' 
   AND Sentiment = 'Neutral';
   
   -- 14. Extract all negative sentiment reviews for Adobe Acrobat Reader with their sentiment polarity and sentiment subjectivity

SELECT App,
            Translated_Review,
            Sentiment_polarity,
            Sentiment_subjectivity 
  FROM Playstore_Reviews 
WHERE App = 'Adobe Acrobat Reader' 
   AND Sentiment = 'Negative';




