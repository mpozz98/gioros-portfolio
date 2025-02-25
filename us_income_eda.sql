SELECT * 
FROM us_household_income;

SELECT *
FROM ushousehold_statistics;

/* Για δευκολυνση εχω δημιουργησει ενα view (us_both) που περιεχει τους δυο πινακες ενωμενους με inner join,
καθως και καποια φιλτρα για την καλυτερη αναλυση τους.
Επισης εχω δημιουργησει ενα δυναμικο stored procedure (stats) που δεχεται input ενα column, ομαδοποιει βασει αυτου
και επιστρεφει καποιους δεικτες στους οποιους βασιζεται η παρακατω αναλυση.*/


/* Αφαιρω την τιμη 300000 απο τον median(παρατηρηται σε μεγαλη συχνοτητα και με ακριβεια στο νουμερο), για να αποφυγω την αλλιωση των αποτελεσματων.
   Δεν παιρνω την πρωτοβουλια να διαγραψω αυτες τις τιμες. */

SELECT count(*) ,
count(*) /(SELECT count(*) FROM us_household_income) AS percentage
FROM us_household_income inc
JOIN ushousehold_statistics st
ON inc.id = st.id
WHERE median = 300000 
;

SELECT 
    inc.State_Name, 
    COUNT(CASE WHEN st.median = 300000 THEN 1 END) AS count_median_300k, 
    COUNT(*) AS total_count,
    COUNT(CASE WHEN st.median = 300000 THEN 1 END) / COUNT(*) AS percentage_of_total
FROM us_household_income inc
JOIN ushousehold_statistics st ON inc.id = st.id
GROUP BY inc.State_Name
ORDER BY percentage_of_total DESC;


/*Αρχικα βλεπουμε καποια στατιστικα για τις ΗΠΑ και το Puerto Rico*/

SELECT IF(inc.State_Name <> 'Puerto Rico', 'USA', 'Puerto Rico') AS Country,
	avg(mean), avg(Median), avg(Stdev),
	avg(stdev)/avg(mean) as CV, 
	3*(avg(mean) - avg(Median)) / AVG(stdev) as pearson, COUNT(*)
FROM us_household_income inc
JOIN ushousehold_statistics st
ON inc.id = st.id
WHERE median <> 300000
GROUP BY Country
;

 
# Κανω αναλυση σε επιπεδο πολιτειας, προσθετωντας συντελεστη μεταβλητοτητας (CV) και pearson skewness.
/* Αφαιρω την τιμη 300000 απο τον median, καθως και το puerto rico  */

CALL stats('State_name');


/* Παρατηρω οτι ο δεικτης Pearson ειναι παντα θετικος (οχι σε μεγαλα ποσα ωστοσο)
και συμπεραινω οτι υπαρχουν καποιες περιοχες σε καθε πολιτεια(outliers) που θα αυξησουν τον μ.ο.
	Στη συνεχεια θα ηθελα να εξετασω κατα ποσο o μεσος ορος εισοδηματος, συσχετιζεται 
με την μεταβλητοτητα των τιμως και την υπαρξη outliers.*/
 
SELECT quarters,
	avg(mean), avg(Median), avg(Stdev),
	avg(stdev)/avg(mean) as CV, 
	3*(avg(mean) - avg(Median)) / AVG(stdev) as pearson, 
    (SELECT avg(mean) FROM us_both) AS US_mean
    FROM(
SELECT *, NTILE(4) OVER(ORDER BY (mean) DESC) AS quarters
FROM us_both
) AS quarter_table
GROUP BY quarters;
 
 
SELECT State_Name, 
	avg(stdev)/avg(mean) as CV, 
	3*(avg(mean) - avg(Median)) / AVG(stdev) as pearson, 
    IF (avg(mean) > (SELECT avg(mean) FROM ushousehold_statistics), 'high', 'low') AS Income
FROM us_both 
GROUP BY 1
ORDER BY 2 DESC
;


/* Θα παρατηρήσω οτι οι περιοχες με χαμηλο μ.ο εισοδηματος τεινουν να εχουν μεγαλυτερο CV και pearson,
ενω το αντιθετο συμβαινει στα υψηλα εισοδηματα. */


-- αναλυση βασει περιοχων
/*Εδω θελω να δω το μεγεθος που αντιστοιχει σε καθε τυπο περιοχης καθως και τα στατιστικα για το εισοδημα του.
 Εχοντας ταξινομησει τον καθε τυπο απο το μεγαλυτερο στο μικροτερο, στο τελικο μου query κανω συγκριση των τιμων 
 διαδοχικα (σε σχεση με το αμεσως μικροτερο) */

CALL stats('Type');

WITH type_sizes( Type, AVG_Land, AVG_Water, total_area, size_number) AS
(
SELECT Type, AVG(ALand), AVG(AWater), AVG(ALand) + AVG(AWater) as total_area,
RANK() OVER(ORDER BY AVG(ALand) + AVG(AWater)) AS size_number
FROM us_both
GROUP BY 1
HAVING count(type) > 100
ORDER BY 2 DESC
),
type_stats (Type, mean, median, stdev, CV, pearson, counts) AS
(
SELECT Type, avg(mean), avg(Median), avg(Stdev), avg(stdev)/avg(mean) as CV,  
3*(avg(mean) - avg(Median)) / AVG(stdev) as pearson , count(*)
FROM us_both
GROUP BY 1
HAVING count(type) > 100
ORDER BY 2 DESC
)
SELECT si.type, 
	mean, (mean - LEAD(mean) OVER(order by size_number DESC)) AS mean_diff_next_smaller,
	CV, (CV - LEAD(CV) OVER(order by size_number DESC)) AS CV_diff_next_smaller
FROM type_sizes si JOIN type_stats st
	ON si.type = st.type
    ;
/* Ωστοσο δεν παρατηρω καποια συσχετιση του μεγεθους της περιοχης με τους δεικτες εισοδηματος.
Ξανακάνω εξέταση αυτη τη φορα χωριζοντας τις περιοχες σε 4 ισοποσες υποομαδες βασει συνολικου μεγεθους. */

SELECT quarter ,AVG(MEAN),AVG(Stdev), AVG(ALand + AWater) AS total_area
FROM(
SELECT *, NTILE(4) OVER(ORDER BY (ALand + Awater) DESC) AS quarter
FROM us_both
) AS quarter_table
GROUP BY quarter;



/* Σε αυτο το σημειο ομαδοποιω τα δεδομενα μου βασει τα Census Bureau Regions */
CREATE TABLE region_stats
SELECT *,
CASE 
	WHEN Lat BETWEEN 38 AND 47.5 AND LON BETWEEN -80 AND -66.9 THEN 'Northeast'
    WHEN Lat BETWEEN 36 AND 49 AND LON BETWEEN -104.1 AND -80 THEN 'Midwest'
    WHEN Lat BETWEEN 24.5 AND 38 AND LON BETWEEN -106 AND -75 THEN 'South'
    WHEN (Lat BETWEEN 31 AND 49 AND LON BETWEEN -125 AND -104) OR State_ab = 'AK' OR State_ab = 'HI' THEN 'West'
END AS region
FROM us_both;



SELECT region , 
	avg(mean), avg(Median), avg(Stdev),
	avg(stdev)/avg(mean) as CV, 
	3*(avg(mean) - avg(Median)) / AVG(stdev) as pearson, 
    (SELECT avg(mean) FROM us_both) as us_avg
FROM
region_stats
WHERE median <> 300000 AND region IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC ;

/* Βλεπουμε οτι οι περιοχες της βορειοανατολικης και δυτικης αμερικης εχουν εμφανως μεγαλυτερα εισοδηματα, 
ενω οι περιοχες του νοτου και του midwest περαν του χαμηλοτερου εισοδηματος εχουν και μεγαλυτερες διακυμανσεις στις τιμες τους.*/



/*Συμπερασματικα :
	Οι ΗΠΑ εμφανιζουν μ.ο εισοδηματος λιγο κατω απο $65.000 ετησιως. Υπαρχει σχετικα υψηλη μεταβλητοτητα στα εισοδηματα (CV = 0.73),
    ενω εχουμε μια ελαφρια δεξια ασσυμετρια στην κατανομη (pearson = 0.69).
	Ο μεσος ορος εισοδηματος με την σχετικη μεταβλητοτητα παρουσιαζουν αντιθετη σχεση, 
    δειχνοντας οτι οι φτωχότερες ομάδες έχουν μεγαλύτερες ανισότητες μεταξύ τους.
    Σε σχεση με τον 'τυπο' τις περιοχης υπαρχουν καποιες μικρες σχετικα διαφορες στα μεσα εισοδηματα (borough = $69000 ενω town = $53.700)
    ωστοσο δεν προκυπτει καποια σχεση του μεγεθους τις περιοχης με το εισοδημα της.
    Τελος πιο ευπορες περιοχες δειχνουν να βρισκονται στην βορειοανατολικα, (εχοντας και τις 5 απο τις 6 περιοχες με τον μεγαλυτερο μεσο μισθο).
    με μ.ο $75.000.
    Δευτερη με μικρη διαφορα ειναι η δυση ($70.000), ενω το midwest και ο νοτος βρισκονται αρκετα πιο πισω $59.500 και $57.700 αντιστοιχα.
    */
    
    
    


