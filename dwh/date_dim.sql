-- The all powerful Date Dimension
-- this will save you a LOT of headache later
-- no tricky logic in every report, and everyone uses the same conventions
-- Gill Staniland January 2026 

drop table if exists sakila_dw.dim_date;

CREATE TABLE IF NOT EXISTS sakila_dw.dim_date  (
    date_key INT NOT NULL ,
    caldate date,
    dayofmonth int,
    dayofyear int,
    dayofweek int,
    weekofyear int,
    dayname varchar(10),
	shortdayname varchar(3),
    monthnumber int,
    monthname varchar(10),
	shortmonthname varchar(3),
    MMMYYYY char(8),
    YYYYMM int,
    calyear    int,
    calquarter tinyint,
    finyear int,
    finperiod int,
    finquarter int,
    lastdayofmonth char(1),
    weekstart date,
    weekend date,
    holiday char(1),
	dayname_ES varchar(20),
	monthname_ES varchar(20),
    PRIMARY KEY(date_key)
) ENGINE=InnoDB ;

delimiter //

DROP PROCEDURE IF EXISTS sakila_dw.datedimbuild;

CREATE PROCEDURE sakila_dw.datedimbuild (p_start_date DATE, p_end_date DATE, p_fin_start_month INT)
begin
	
    DECLARE v_full_date DATE;

    DELETE FROM dim_date;

    SET v_full_date = p_start_date;
    WHILE v_full_date < p_end_date DO

        INSERT INTO sakila_dw.dim_date (
          	date_key,
            caldate ,
            dayofmonth ,
            dayofyear ,
            dayofweek ,
            weekofyear,
            dayname,
			shortdayname,
            monthnumber,
            monthname,
			shortmonthname,
            MMMYYYY,
            YYYYMM,
            calyear,
            calquarter,
            finyear,
    		finperiod,
    		finquarter,
            lastdayofmonth,
            weekstart,
            weekend,
            holiday,
			dayname_ES,
			monthname_ES
        ) VALUES (
        	v_full_date + 0, 					-- converts to YYYYMMDD
            v_full_date,
            DAYOFMONTH(v_full_date),
            DAYOFYEAR(v_full_date),
            WEEKDAY(v_full_date),  				-- not DAYOFWEEK (that function starts on a Sunday)
            WEEKOFYEAR(v_full_date),
            DAYNAME(v_full_date),
			substring(DAYNAME(v_full_date),1,3),
            MONTH(v_full_date),
            MONTHNAME(v_full_date),
			substring(MONTHNAME(v_full_date),1,3),
            concat(substring(MONTHNAME(v_full_date),1,3), ' ', cast(year(v_full_date) as char(4))),
            (YEAR(v_full_date) * 100) + MONTH(v_full_date),
            YEAR(v_full_date),
            QUARTER(v_full_date),
            case 
	            when month(v_full_date) < p_fin_start_month
	            	then year(v_full_date) - 1 else year(v_full_date)
	            end,
	         case 
		         	when month(v_full_date) < p_fin_start_month
		          	then month(v_full_date) + (12 - p_fin_start_month + 1)
		          	else month(v_full_date) - p_fin_start_month +1
		      end,
		      0,
            case 
	            when v_full_date = LAST_DAY(v_full_date) then 'Y' else 'N' end,
		      v_full_date,
		      v_full_date,
            'N',
			'',
			''
        );

        SET v_full_date = DATE_ADD(v_full_date, INTERVAL 1 DAY);
    END WHILE;
	
	-- update the financial quarters
        
     update dim_date
     set finquarter = 
     case 
		 when finperiod in (1,2,3) then 1
		 when finperiod in (4,5,6) then 2
		 when finperiod in (7,8,9) then 3
		 when finperiod in (10,11,12) then 4
     end;
	 
	 -- set the start and end of a week
     
    update sakila_dw.dim_date d
	join
	(select calyear, weekofyear, min(caldate) weekstart, max(caldate) weekend
		from sakila_dw.dim_date dd 
		-- where calyear = 2026
		group by calyear, weekofyear) w 
	on d.calyear = w.calyear and d.weekofyear = w.weekofyear
	set d.weekstart = w.weekstart,
	d.weekend = w.weekend;
     
	 -- set the holiday flag for standard days every year
	 
    update dim_date
	set holiday = 'Y'
	where 
		(monthnumber = 12 and dayofmonth = 25)
	or
		(monthnumber = 1 and dayofmonth =1)
	or
		(monthnumber = 12 and dayofmonth = 26);

END;
//
DELIMITER ;

-- now we run the procedure with the start and end dates, and the month that the financial year starts - in this example it starts in May

call sakila_dw.datedimbuild('2005-01-01','2015-12-31', 5);

-- update special holidays once a year

update sakila_dw.dim_date
	set holiday = 'Y'
where 
	caldate in ('2006-04-03', '2006-04-06');  -- these are Easter holidays in some countries.  They change each year.

--  other languages?

-- keep the current setting in a variable
select @@lc_time_names into @default_lang;

		SET lc_time_names = 'es_ES';
		
		update sakila_dw.dim_date
		set 
			dayname_ES = dayname(caldate),
			monthname_ES = monthname(caldate);

-- set back to the current setting
SET lc_time_names = @default_lang;

-- now let's have a look at the data for one month (April 2026)

select * from sakila_dw.dim_date d 
where yyyymm = 200604;

/*

Locale Value	Meaning
ar_AE	Arabic - United Arab Emirates
ar_BH	Arabic - Bahrain
ar_DZ	Arabic - Algeria
ar_EG	Arabic - Egypt
ar_IN	Arabic - India
ar_IQ	Arabic - Iraq
ar_JO	Arabic - Jordan
ar_KW	Arabic - Kuwait
ar_LB	Arabic - Lebanon
ar_LY	Arabic - Libya
ar_MA	Arabic - Morocco
ar_OM	Arabic - Oman
ar_QA	Arabic - Qatar
ar_SA	Arabic - Saudi Arabia
ar_SD	Arabic - Sudan
ar_SY	Arabic - Syria
ar_TN	Arabic - Tunisia
ar_YE	Arabic - Yemen
be_BY	Belarusian - Belarus
bg_BG	Bulgarian - Bulgaria
ca_ES	Catalan - Spain
cs_CZ	Czech - Czech Republic
da_DK	Danish - Denmark
de_AT	German - Austria
de_BE	German - Belgium
de_CH	German - Switzerland
de_DE	German - Germany
de_LU	German - Luxembourg
el_GR	Greek - Greece
en_AU	English - Australia
en_CA	English - Canada
en_GB	English - United Kingdom
en_IN	English - India
en_NZ	English - New Zealand
en_PH	English - Philippines
en_US	English - United States
en_ZA	English - South Africa
en_ZW	English - Zimbabwe
es_AR	Spanish - Argentina
es_BO	Spanish - Bolivia
es_CL	Spanish - Chile
es_CO	Spanish - Colombia
es_CR	Spanish - Costa Rica
es_DO	Spanish - Dominican Republic
es_EC	Spanish - Ecuador
es_ES	Spanish - Spain
es_GT	Spanish - Guatemala
es_HN	Spanish - Honduras
es_MX	Spanish - Mexico
es_NI	Spanish - Nicaragua
es_PA	Spanish - Panama
es_PE	Spanish - Peru
es_PR	Spanish - Puerto Rico
es_PY	Spanish - Paraguay
es_SV	Spanish - El Salvador
es_US	Spanish - United States
es_UY	Spanish - Uruguay
es_VE	Spanish - Venezuela
et_EE	Estonian - Estonia
eu_ES	Basque - Spain
fi_FI	Finnish - Finland
fo_FO	Faroese - Faroe Islands
fr_BE	French - Belgium
fr_CA	French - Canada
fr_CH	French - Switzerland
fr_FR	French - France
fr_LU	French - Luxembourg
gl_ES	Galician - Spain
gu_IN	Gujarati - India
he_IL	Hebrew - Israel
hi_IN	Hindi - India
hr_HR	Croatian - Croatia
hu_HU	Hungarian - Hungary
id_ID	Indonesian - Indonesia
is_IS	Icelandic - Iceland
it_CH	Italian - Switzerland
it_IT	Italian - Italy
ja_JP	Japanese - Japan
ko_KR	Korean - Republic of Korea
lt_LT	Lithuanian - Lithuania
lv_LV	Latvian - Latvia
mk_MK	Macedonian - North Macedonia
mn_MN	Mongolia - Mongolian
ms_MY	Malay - Malaysia
nb_NO	Norwegian(Bokmål) - Norway
nl_BE	Dutch - Belgium
nl_NL	Dutch - The Netherlands
no_NO	Norwegian - Norway
pl_PL	Polish - Poland
pt_BR	Portugese - Brazil
pt_PT	Portugese - Portugal
rm_CH	Romansh - Switzerland
ro_RO	Romanian - Romania
ru_RU	Russian - Russia
ru_UA	Russian - Ukraine
sk_SK	Slovak - Slovakia
sl_SI	Slovenian - Slovenia
sq_AL	Albanian - Albania
sr_RS	Serbian - Serbia
sv_FI	Swedish - Finland
sv_SE	Swedish - Sweden
ta_IN	Tamil - India
te_IN	Telugu - India
th_TH	Thai - Thailand
tr_TR	Turkish - Turkey
uk_UA	Ukrainian - Ukraine
ur_PK	Urdu - Pakistan
vi_VN	Vietnamese - Vietnam
zh_CN	Chinese - China
zh_HK	Chinese - Hong Kong
zh_TW	Chinese - Taiwan

*/