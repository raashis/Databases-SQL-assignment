-- question 1
-- here we are simply counting the number of distinct kflyerids to determine the number of people, ans is 1090
SELECT COUNT(DISTINCT KFlyerID) AS kFlyerID
FROM customertbl;

-- question 2
-- we can try trimming the membership type first, cause the error in the data mentioned in the question 
-- is the space at the front of the ' SolitairePPS', and it coming in 2 different rows. so to solve this, 
-- we can simply use TRIM to remove the spaces

-- i didnt put 'distinct' in front of the membership type at first and was confused about what the 
-- question expected from me, then i remembered to put distinct and got the answer of the 4 membership types

SELECT DISTINCT TRIM(MembershipType) AS MEMBERSHIPTYPE
FROM customertbl;

-- qn 3
-- since here 'PPS' is coming as 'PPs', we have to create a case statement where we specifically (not sure if this is a data issue 
-- we are supposed to be facing or not, cause my friends did not get this error. but for ur context, my PPS column was coming as PPs, so i ended up 
-- taking care of this data issue everywhere in the future where membership type was asked, if theres any confusion prof i can show u a screenshot
-- of what i was seeing in class!)
-- change 'PPs' to become 'PPS'. i tried doing the UPPER keyword before, but that made all the membership types 
-- to become uppercased. so i realised thats wrong. 

-- after that i realised that Solitare PPS is coming in 2 different rows again rather than in 1 combined, so i 
-- executed the trim membership type again (which i should have remembered earlier, since that was the point of the 
-- previous question. - so take note of considering this in the future questions)

-- the overall layout of this answer is to basically select membership type, count the number of customers (by 
-- looking at distinct kflyerids) and then grouping them by the membership type

SELECT CASE 
    WHEN MembershipType = 'PPs' THEN 'PPS'
    ELSE TRIM(MembershipType)
  END AS MembershipType, 
  COUNT(DISTINCT kflyerid) AS NumberofCustomers
FROM customertbl
GROUP BY 
CASE 
    WHEN MembershipType = 'PPs' THEN 'PPS'
    ELSE TRIM(MembershipType)
  END;
  
-- question 4
-- had to group by general location and membership type and need to show the total customers, then sum up 
-- the number of female customers and present them (same with male customers)

-- have to remember to do the same case statement with the membership type -> for PPs and for the 
-- trimming for Solitaire PPS

-- since PostalSect is a common column we need to join the tables ON PostalSect

SELECT 
p.GeneralLoc,
CASE WHEN c.MembershipType = 'PPs' THEN 'PPS'
ELSE TRIM(MembershipType)
END AS MembershipType,
COUNT(DISTINCT c.kflyerid) AS TotalCustomers,
SUM(CASE WHEN c.CustGen = 'FEMALE' THEN 1 ELSE 0 END) AS FemaleCustomers,
SUM(CASE WHEN c.CustGen = 'MALE' THEN 1 ELSE 0 END) AS MaleCustomers
FROM customertbl c
JOIN postalsecttbl p ON c.PostalSect = p.PostalSect
GROUP BY
p.GeneralLoc,
CASE WHEN c.MembershipType = 'PPs' THEN 'PPS'
ELSE TRIM(MembershipType)
END;

-- question 5
-- For each general location, on each membership type, display the number of customers who have been members since 2000.
-- One data fault that I took some time in realising is the misspelling of 'memebersSince_y' (which i simply addressed as 
-- putting 'AS MembersSince2000'

-- rest of the data faults are taken care as i have been doing so previously

-- i had thought initially to also count the number of total customers, but when i reread the qn, i commented that 
-- command out (as u can see below)

-- i had put the members since => 2000, but when i read the question again i realised that being member 
-- since 2000 should have an = sign, as => would mean ppl who became members after 2000 would also be included 


SELECT 
p.GeneralLoc,
CASE WHEN c.MembershipType = 'PPs' THEN 'PPS'
ELSE TRIM(MembershipType)
END AS MembershipType,
-- COUNT(DISTINCT c.kflyerid) AS TotalCustomers,
COUNT(CASE WHEN c.MemeberSince_y = '2000' THEN 1 ELSE 0 END) AS MembersSince2000
FROM customertbl c
JOIN postalsecttbl p ON c.PostalSect = p.PostalSect
GROUP BY
p.GeneralLoc,
CASE WHEN c.MembershipType = 'PPs' THEN 'PPS'
ELSE TRIM(MembershipType)
END;

-- question 6
-- need to take down the sum of the distance
-- the more impt note here is that the joining of 3 tables was a bit complicated, the joining of customertbl 
-- and tripstbl was fine as the common column was very obvious, but the joining of tripstbl and desttbl took
--  me some time to understand

-- but of course eventually i figured out that desttbl and tripstbl can be combined with routeID of tripstbl 
-- and destID of desttbl

-- need to also take into account that the trip should be between the years of 2020 and 2022 as stated in the question

-- since we were asked to find the total distance for each membership type, i grouped them by membership type 
-- (and of course needed to take care of the data issues for membership type)

SELECT 
CASE WHEN c.MembershipType = 'PPs' THEN 'PPS'
ELSE TRIM(MembershipType)
END AS MembershipType,
SUM(d.Dist) AS TotalDistance
FROM customertbl c
JOIN tripstbl t ON c.KFlyerID = t.KFlyerID
JOIN desttbl d ON t.routeID = d.DestID
WHERE t.Trip_y BETWEEN '2020' AND '2022'
GROUP BY
CASE WHEN c.MembershipType = 'PPs' THEN 'PPS'
ELSE TRIM(MembershipType)
END;

-- question 7
-- for this question, i couldnt get the required answer by the output shown. i thought it was impt for 
-- season to be in the table, so that we can understand which season the travellers are flying in, since 
-- that is an important aspect of the question. i also included the total distance that person (identified by 
-- kflyerid flew) and the number of trips that person flew shown by TripAmt. i sorted the total distance in descending 
-- order, so that the top travellers come up on top. i tried to rank these top travellers, and tried to show only 
-- the top 2 travellers, using the row number function, then tried to limit the rank to just 2 or lesser, but i 
-- was not successful in doing so. i tried to look up if i am doing something wrong with my syntax of this 
-- row_number function, but i could not find anything wrong. i typed out the AS 'rank' as AS rank before, 
-- and got an error, i tried debugging it and the only way i could return any result was if i returned 
-- rank in quotation marks, as i did below

-- updated: i decided to not work with row_number function, and tried to bring in a limit function, 
-- which i set to be = 2, when i order it to be descending. if i specifically target 
-- the holiday travellers and non-holiday travellers in 2 separate sub queries, which also removes the 'unknown' part 
-- i was getting earlier :)


WITH Holiday AS 
(
  SELECT 
    'Holiday' AS Season,
    t.KFlyerID,
    GROUP_CONCAT(DISTINCT REGEXP_REPLACE(d.AirCode, '\\s+', '') ORDER BY d.AirCode ASC) AS AirCodesVisited,
	COUNT(t.TripID) AS TripAmt,
    SUM(d.dist) AS TotalDistance
  FROM 
    tripstbl t
  JOIN 
    desttbl d ON t.routeID = d.DestID
  WHERE 
   -- i also combined this into 1 where clause, when previously i had put them separately
    REGEXP_REPLACE(d.AirCode, '\\s+', '') NOT IN ('NRT', 'MAN', 'LGW') 
    AND t.Outbound = 1 
    AND t.Trip_m IN (7, 8, 11, 12)
  GROUP BY 
    t.KFlyerID
  ORDER BY 
    TotalDistance DESC
  LIMIT 2
  -- is how i find the top 2 holiday travellers!!!!!
), 
NonHoliday AS 
(
-- then here i look at non holiday travellers
  SELECT 
    'NonHoliday' AS Season,
    t.KFlyerID,
    GROUP_CONCAT(DISTINCT REGEXP_REPLACE(d.AirCode, '\\s+', '') ORDER BY d.AirCode ASC) AS AirCodesVisited,
  COUNT(t.TripID) AS TripAmt,
    SUM(d.dist) AS TotalDistance
  FROM 
    tripstbl t
  JOIN 
    desttbl d ON t.routeID = d.DestID
  WHERE 
    REGEXP_REPLACE(d.AirCode, '\\s+', '') NOT IN ('NRT', 'MAN', 'LGW') 
    AND t.Outbound = 1 
    AND t.Trip_m NOT IN (7, 8, 11, 12)
  GROUP BY 
    t.KFlyerID
  ORDER BY 
    TotalDistance DESC
  LIMIT 2
)
SELECT * FROM Holiday
UNION ALL
SELECT * FROM NonHoliday;


-- question 8

-- i tried considering the convo running into the next day/month/year in the below seen commented out code, but for some reason its not returning
-- any rows

SELECT 
	CASE WHEN c.MembershipType = 'PPs' THEN 'PPS'
	ELSE TRIM(MembershipType)
	END 
AS MembershipType, COUNT(*) AS NumberOfSustainedConvos
  -- we are trying to count the number of sustained conversations 
  
  -- also i am again doing the same set of case statements for membership type's data issues
  
FROM (
  SELECT 
    f.UserID, 
    f.ChatID, Date_d, Date_m, Date_y, Time_hh
    
--     -- created ChatTimestamp to see at what specific point of time that chat message was sent 
--     TIMESTAMP(CONCAT(f.Date_y, '-', f.Date_m, '-', TRIM(f.Date_d), ' ', f.Time_hh, ':00:00')) AS ChatTimestamp,
--     -- TRIM(f.Date_d) to remove leading spaces
--     LEAD(TIMESTAMP(CONCAT(f.Date_y, '-', f.Date_m, '-', TRIM(f.Date_d), ' ', f.Time_hh, ':00:00')))
--       OVER (PARTITION BY f.UserID ORDER BY f.Date_y, f.Date_m, f.Date_d, f.Time_hh) AS NextChatTimestamp,

--     -- figured out when the next chat happened 
--     TRIM(f.Date_d) AS CurrentDay,
--     f.Date_m AS CurrentMonth,
--         f.Date_y AS CurrentYear,
--       -- now im gonna consider the edge cases of what happens if a conversation starts at lets say 8:59PM and carries onto to 9:01PM (NextChatDay)
--       LEAD(TRIM(f.Date_d)) OVER (PARTITION BY f.UserID ORDER BY f.Date_y, f.Date_m, TRIM(f.Date_d), f.Time_hh) AS NextChatDay,
--       -- then if a convo starts on the last day of the month and carries onto the next month's 1st day
--       LEAD(f.Date_m) OVER (PARTITION BY f.UserID ORDER BY f.Date_y, f.Date_m, TRIM(f.Date_d), f.Time_hh) AS NextChatMonth,
--       -- then if a convo starts on 31st dec 2023 and carries onto 1st jan 2024
-- 	 LEAD(f.Date_y) OVER (PARTITION BY f.UserID ORDER BY f.Date_y, f.Date_m, TRIM(f.Date_d), f.Time_hh) AS NextChatYear,
--        f.Time_hh AS CurrentHour
  FROM fulllogtbl f
  WHERE f.ChatID IS NOT NULL
  AND TRIM(f.Date_d) REGEXP '^[0-9]+$'
  AND f.ChatID != '10000'
) sc
-- named this subquery as sc (sustained convo) to make things easier
-- need to remove NULL values of the chat id

-- below is just joining the 2 tables since we are dealing with more than 1 in this qn, the common table is the 
-- userID and KFlyerID
JOIN customertbl c ON sc.UserID = c.KFlyerID


-- WHERE sc.NextChatTimestamp IS NOT NULL
--   AND (
--     -- we consider the case of it being in the adjacent hour
--     (DATE(sc.ChatTimestamp) = DATE(sc.NextChatTimestamp) 
--      AND TIMESTAMPDIFF(HOUR, sc.ChatTimestamp, sc.NextChatTimestamp) = 1)

--     -- adjacent day
--     OR (HOUR(sc.ChatTimestamp) = 23 
--         AND sc.NextChatYear = sc.CurrentYear 
--         AND sc.NextChatMonth = sc.CurrentMonth 
--         AND sc.NextChatDay = CAST(sc.CurrentDay AS UNSIGNED) + 1 
--         AND HOUR(sc.NextChatTimestamp) = 0)
--     
--     -- adjacent month
--     OR (sc.CurrentMonth <> sc.NextChatMonth 
--         AND sc.NextChatDay = 1 
--         AND CAST(sc.CurrentDay AS UNSIGNED) = LAST_DAY(DATE(CONCAT(sc.CurrentYear, '-', sc.CurrentMonth, '-01'))) 
--         AND sc.CurrentHour = 23 AND HOUR(sc.NextChatTimestamp) = 0)
--         
--     -- adjacent year
-- 	OR (sc.CurrentMonth = 12 AND CAST(sc.CurrentDay AS UNSIGNED) = 31 
--         AND sc.NextChatMonth = 1 AND sc.NextChatDay = 1 
--         AND sc.CurrentHour = 23 AND HOUR(sc.NextChatTimestamp) = 0)
-- ) 

-- then i grp by membership type (as specified in the qn) and returned the number of sustained convos 
-- (with the highest number at the top)
GROUP BY c.membershipType
ORDER BY NumberOfSustainedConvos DESC;

-- question 9

WITH AvEmotion AS (
    SELECT 
        f.UserID,
        AVG(f.Joy) AS avgJoy,
        AVG(f.Anger) AS avgAnger,
        AVG(f.Disgust) AS avgDisgust,
        AVG(f.Surprise) AS avgSurprise,
        AVG(f.Fear) AS avgFear,
        AVG(f.Sadness) AS avgSadness,
        AVG(f.Contempt) AS avgContempt,
        AVG(f.Sentimentality) AS avgSentimentality,
        AVG(f.Confusion) AS avgConfusion
    FROM 
        fulllogTBL f
    GROUP BY 
        f.UserID
),

-- made a common table expression for the average of each emotion (according to the i of the suggested logic), and i grouped it
-- by userid (so i can generate a list of the userids, and all their corresponding emotions)

ModifiedMiles AS (
    SELECT 
        t.KFlyerID,
        SUM(d.Dist * t.EliteMilesMod) AS modifiedMiles
    FROM 
        tripsTBL t
    JOIN 
        destTBL d ON t.routeID = d.DestID
    GROUP BY 
        t.KFlyerID
),

-- found the modified miles with the formula given in ii, and also grouped it by every customer here (by kflyer id)

CustomerMetrics AS (
    SELECT 
    
    -- first, i will combine the modifiled miles and the average emotions (iii)
        m.KFlyerID,
        m.modifiedMiles,
        e.avgJoy,
        e.avgAnger,
        e.avgDisgust,
        e.avgFear,
        e.avgSadness,
        e.avgContempt,
        e.avgSentimentality,
        e.avgConfusion,
        -- then below i will find the averages of each emotion (iv) and log it simultaneously (v)
        -- i did a NULLIF to prevent division with 0 which would cause the query to fail
        LOG(NULLIF(e.avgJoy, 0)) / LOG(NULLIF(m.modifiedMiles, 0)) AS PositiveEmotionsRatio,
        LOG(NULLIF((e.avgAnger + e.avgDisgust + e.avgFear + e.avgSadness) / 4, 0)) / LOG(NULLIF(m.modifiedMiles, 0)) AS NegativeEmotionsRatio,  
        LOG(NULLIF(e.avgSentimentality, 0)) / LOG(NULLIF(m.modifiedMiles, 0)) AS SentimentalityRatio,
        LOG(NULLIF(e.avgConfusion, 0)) / LOG(NULLIF(m.modifiedMiles, 0)) AS ConfusionRatio
    FROM 
        AvEmotion e  
    JOIN 
        ModifiedMiles m ON e.UserID = m.KFlyerID  
)

-- just found the number of happy, upset, sentimental and confused customers by using the count function, as asked to do so in vi, 
-- also performed union on them as asked in vii
SELECT 'Happy Customers' AS CustomerType, COUNT(*) AS CustomerCount
FROM CustomerMetrics
WHERE 
    PositiveEmotionsRatio > NegativeEmotionsRatio 
    AND PositiveEmotionsRatio > SentimentalityRatio 
    AND PositiveEmotionsRatio > ConfusionRatio

UNION ALL

SELECT 'Upset Customers', COUNT(*)
FROM CustomerMetrics
WHERE 
    NegativeEmotionsRatio > PositiveEmotionsRatio 
    AND NegativeEmotionsRatio > SentimentalityRatio 
    AND NegativeEmotionsRatio > ConfusionRatio

UNION ALL

SELECT 'Sentimental Customers', COUNT(*)
FROM CustomerMetrics
WHERE 
    SentimentalityRatio > PositiveEmotionsRatio 
    AND SentimentalityRatio > NegativeEmotionsRatio 
    AND SentimentalityRatio > ConfusionRatio

UNION ALL

SELECT 'Confused Customers', COUNT(*)
FROM CustomerMetrics
WHERE 
    ConfusionRatio > PositiveEmotionsRatio 
    AND ConfusionRatio > NegativeEmotionsRatio 
    AND ConfusionRatio > SentimentalityRatio;



-- question 10!

-- trying to check for non null content here

SELECT 
    COUNT(*) AS NonEmptyContentCount
FROM 
    FulllogTBL
WHERE 
    Content IS NOT NULL AND Content <> '';

-- if the count is more than 0 (i.e. we are not dealing with a completely null data) we can go to the next statement

-- here i am tryna figure out which soundex string is the most frequent one

WITH MostFrequentSoundex AS (
    SELECT 
        SUBSTRING(SOUNDEX(Content), -4) AS SoundexString,  -- here i am trying to get the last 4 characters of the string, as talked abt in the qn
        COUNT(*) AS Frequency 
    FROM 
        FulllogTBL
    WHERE 
        Content IS NOT NULL AND Content <> ''  
    GROUP BY 
        SoundexString
    ORDER BY 
        Frequency DESC -- to place the most frequent one on top
    LIMIT 1  -- since i only need the most frequent one
)

-- SELECT 
--     SoundexString,
--     Frequency
-- FROM 
--     MostFrequentSoundex;
-- above is a test to see which soundexstring i am getting and at what frequency (1423, 160 respectively), had done this for debugging


SELECT 
    * FROM    FulllogTBL f
  WHERE 
    SOUNDEX(Content) LIKE CONCAT('%', (SELECT SoundexString FROM MostFrequentSoundex), '%')   -- Display records with the content containing the identified soundex string
ORDER BY ChatID;  -- here i am looking for the soundex string, anywhere in the Content column
    -- where before this string and after this string can be any number as was shown in %1423% in the qn (i was a bit confused that we have to find 
    -- the most frequent soundex string only in the rightmost 4 characters, but upon rereading the qn i understood that the soundex string
    -- could be anywhere)