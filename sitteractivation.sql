SELECT au.email AS 'Email Address',
au.first_name AS 'First Name',
serv.min_search_date
CASE WHEN cc.id IS NOT NULL THEN 1 ELSE 0 END AS 'sitter_had_convo', 
CASE WHEN cc2.provider_id IS NOT NULL THEN 1 ELSE 0 END AS 'sitter_had_booking',
CASE WHEN cbsa_code IN (11980, 19740, 12420, 29820, 26420, 42660, 19100, 31100, 37100, 41740, 31080, 40140, 42060, 38900, 36740, 27260, 45300, 46060, 38060,12420, 42660, 19740, 29820) THEN 1 ELSE 0 END AS 'premier_flag'

FROM auth_user au
JOIN people_person p ON p.user_id = au.id
JOIN people_personlocation ppl ON ppl.person_id = p.id
JOIN metrics_combinedstatisticalarea mcsa ON mcsa.zip_code = ppl.zip
LEFT JOIN conversations_conversation cc ON cc.provider_id = p.id

JOIN (SELECT provider_id, 
	  MIN(searchable_date) AS 'min_search_date' 
      FROM services_service 
      WHERE active = 1
      AND searchable = 1
      GROUP BY provider_id) serv ON serv.provider_id = p.id

LEFT JOIN (SELECT provider_id
FROM conversations_conversation 
WHERE has_stay = 1
GROUP BY provider_id) cc2 ON cc2.provider_id = cc.provider_id

GROUP BY au.email

