/* Original INSERT for ABLASTCLICKINTERSECT# */
/* ========
SELECT  max(s."TransactionTime"), Subscriber_Key_SK   ,nksk.Subscriber_Key    
  FROM ABEnterpriseSubscriber nksk      
INNER JOIN TRGT_7282972_DS_DBO."Members_" m
  ON lower(m."SubscriberKey") = nksk.Subscriber_Key      
INNER JOIN TRGT_7282972_DS_DBO."tblLists" l
  ON l."pkListID" = m."ListID"    AND l."ListName" = 'All Subscribers'    AND lower(m."MemberType_") <> 'deleted'
LEFT OUTER JOIN TRGT_7282972_DS_STATS."Click" s
  ON s."SubscriberID" = m."MemberID_" 
GROUP BY Subscriber_Key_SK, nksk.Subscriber_Key; 
======== */
/* Original INSERT for ABLASTCLICKINTERSECT# */


/* ABLastClick */
/*
MODIFIED DATE: 20161017
MODIFIED BY: Neil Clark (neil.clark@salesforce.com)
DETAILS: Target requires the addition of legacy data from a former provider for 
	click data into their click dimensions. I have modified the script to union
	legacy data with our stats tables into the ABLASTCLICKINTERSECT# staging table
	to account for legacy data in recency buckets.
*/

/* ALTER SESSION SET CURRENT_SCHEMA = TRGT_7282972_AB_C7282972 */

begin dfu_ddl.truncate_table(sys_context('userenv', 'current_schema'), 'ABLASTCLICKINTERSECT'); END; 
/
BEGIN           
SP_CREATETABLE('ABLASTCLICKINTERSECT#', 'MaxTransactionTime TIMESTAMP, Subscriber_Key_SK number, Subscriber_Key VARCHAR2(100)');         
END;         
/  
BEGIN
INSERT /*+ Append Parallel */ INTO ABLASTCLICKINTERSECT#(MaxTransactionTime, Subscriber_Key_SK, Subscriber_Key)    
SELECT 
	TRUNC(MAX(fd.MaxTransactionTime)) MaxTransactionTime
	, fd.Subscriber_Key_SK
	, fd.Subscriber_Key 
FROM
(SELECT /*+ Parallel */ TRUNC(max(click."LAST_CLICK_DATE")) MaxTransactionTime, Subscriber_Key_SK, nksk.Subscriber_Key
	FROM ABEnterpriseSubscriber nksk
INNER JOIN TRGT_7282972_DS_C7282972."ContactHistory" click
	ON LOWER(click."MDM_SEQ_ID") = lower(nksk.Subscriber_Key)
GROUP BY Subscriber_Key_SK, nksk.Subscriber_Key
UNION
SELECT /*+ Parallel */ TRUNC(max(s."TransactionTime")) MaxTransactionTime, Subscriber_Key_SK   ,nksk.Subscriber_Key    
  FROM ABEnterpriseSubscriber nksk      
INNER JOIN TRGT_7282972_DS_DBO."Members_" m
  ON lower(m."SubscriberKey") = nksk.Subscriber_Key      
INNER JOIN TRGT_7282972_DS_DBO."tblLists" l
  ON l."pkListID" = m."ListID"    AND l."ListName" = 'All Subscribers'    AND lower(m."MemberType_") <> 'deleted' 
LEFT OUTER JOIN TRGT_7282972_DS_STATS."Click" s
  ON s."SubscriberID" = m."MemberID_" 
GROUP BY Subscriber_Key_SK, nksk.Subscriber_Key)  fd
GROUP BY fd.Subscriber_Key_SK, fd.Subscriber_Key; 
COMMIT;
END;
/


BEGIN
INSERT INTO ABLastClickIntersect (
  ClickDateDiff
  ,Pk
  ,Subscriber_Key_SK
  ,Subscriber_Key
)
SELECT ClickDateDiff, PK, Subscriber_Key_SK, Subscriber_Key FROM (
select /* Last 15 Days */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 1 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) < 16
UNION ALL
select /* Last 10 Months */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 2 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (trunc(MaxTransactionTime,'month') - trunc(trunc(sysdate,'month'))) <= 10
UNION ALL
select /* 16 to 100 Days */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 3 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) BETWEEN 16 AND 100
UNION ALL
select /* 101 to 365 Days */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 4 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) BETWEEN 101 AND 365
UNION ALL
select /* Yesterday */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 5 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) < 2
UNION ALL
select /* Last 7 Days */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 6 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) < 8
UNION ALL
select /* Last 30 Days */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 7 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) < 31
UNION ALL
select /* Last 60 Days */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 8 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) < 61
UNION ALL
select /* Last 90 Days */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 9 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) < 91
UNION ALL
select /* Last 120 Days */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 10 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) < 121
UNION ALL
select /* Last 180 Days */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 11 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) < 181
UNION ALL
select /* Last 365 Days */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 12 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) < 366
UNION ALL
select /* Over 1 Year */
  (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) ClickDateDiff
  , 13 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE (TRUNC(SYSDATE) - TRUNC(MaxTransactionTime)) >= 366
UNION ALL
select /* Over 1 Year */
  NULL ClickDateDiff
  , 13 PK
  , Subscriber_Key_SK
  , Subscriber_Key
  FROM ABLASTCLICKINTERSECT#
  WHERE MaxTransactionTime IS NULL) z;
/*
SELECT IntersectionPK, Subscriber_Key_SK   ,Subscriber_Key   
FROM  (  
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'LAST   7 DAYS') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE (trunc(sysdate)-trunc(MaxTransactionTime)) BETWEEN 0 AND 7      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'LAST  30 DAYS') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE (trunc(sysdate)-trunc(MaxTransactionTime)) BETWEEN 0 AND 30      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'LAST  60 DAYS') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE (trunc(sysdate)-trunc(MaxTransactionTime)) BETWEEN 0 AND 60      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'LAST  90 DAYS') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE (trunc(sysdate)-trunc(MaxTransactionTime)) BETWEEN 0 AND 90      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'LAST 120 DAYS') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE (trunc(sysdate)-trunc(MaxTransactionTime)) BETWEEN 0 AND 120      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'LAST 180 DAYS') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE (trunc(sysdate)-trunc(MaxTransactionTime)) BETWEEN 0 AND 180      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'LAST MONTH') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE trunc(MaxTransactionTime,'month') = trunc(trunc(sysdate,'month')-1,'month')      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'LAST QUARTER') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE trunc(MaxTransactionTime,'Q') = trunc(trunc(sysdate,'Q')-1,'Q')      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'LAST WEEK') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE trunc(MaxTransactionTime,'DAY') = trunc(trunc(sysdate,'DAY')-1,'DAY')       
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'LAST YEAR') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE trunc(MaxTransactionTime,'year') = trunc(trunc(sysdate,'year')-1,'year')       
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'NONE YET') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE MaxTransactionTime IS NULL       
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'THIS MONTH') IntersectionPK
FROM ABLASTCLICKINTERSECT# WHERE trunc(MaxTransactionTime,'month') = trunc(sysdate,'month')      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'THIS QUARTER') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE trunc(MaxTransactionTime,'Q') = trunc(sysdate,'Q')      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'THIS WEEK') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE trunc(MaxTransactionTime,'DAY') = trunc(sysdate,'DAY')      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'THIS YEAR') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE trunc(MaxTransactionTime,'year') = trunc(sysdate,'year')      
UNION ALL       
SELECT Subscriber_Key_SK   ,Subscriber_Key   ,(SELECT to_number(Pk) FROM LKLastClick WHERE UPPER(NAME) = 'YESTERDAY') IntersectionPK    
FROM ABLASTCLICKINTERSECT# WHERE trunc(MaxTransactionTime,'DD') = trunc(sysdate,'DD') - 1  
)*/    
COMMIT;         
END;         
/     
BEGIN           
SP_DELETETABLE('ABLASTCLICKINTERSECT#');         
END;  
/
begin  
  dbms_stats.gather_table_stats(null, 'ABLASTCLICKINTERSECT', degree => dbms_stats.auto_degree);
end;
/
