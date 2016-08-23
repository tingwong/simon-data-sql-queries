SELECT
pown.id AS 'user_id',
1 AS 'valid_for_owner_rebook_anniversary',
ausit.first_name AS 'sitter_first_name',
CONCAT('https://www.rover.com/members/',psit.slug) AS 'sitter_profile_url_string',
CASE WHEN (cc.service_type = 'overnight-boarding' AND servhome.active = 1 AND servhome.searchable = 1) OR
		  (cc.service_type = 'overnight-traveling' AND servtravel.active = 1 AND servtravel.searchable = 1) OR
		  (cc.service_type = 'dog-walking' AND servwalking.active = 1 AND servwalking.searchable = 1) OR
		  (cc.service_type = 'drop-in' AND servdropin.active = 1 AND servdropin.searchable = 1) OR
		  (cc.service_type = 'doggy-day-care' AND servdaycare.active = 1 AND servdaycare.searchable = 1)
          THEN 1 ELSE 0 END AS 'sitter_still_available',
spr.max_review_added AS 'review_added_date',
(acos(
       (sin(radians(ppl.latitude)) * sin(radians(dgz.latitude))) + (cos(radians(ppl.latitude)) * cos(radians(dgz.latitude)) * cos(radians((dgz.longitude - ppl.longitude))))
     ) * 3959) AS 'distance_owner_to_sitter',
pet.dog_name AS 'dog_name',
spr.max_review_added AS 'review_added_date',
date_format(serv.last_updated_calendar, '%c/%e/%Y') AS 'last_updated_calendar'

FROM people_person pown
JOIN (SELECT poster_id,
	  MAX(spr.id) AS 'max_review_id',
      MAX(spr.added) AS 'max_review_added'
      FROM stays_providerrating spr
      WHERE spr.overall = 5
      GROUP BY poster_id) spr ON spr.poster_id = pown.id

JOIN stays_providerrating spr2 ON spr2.id = spr.max_review_id
JOIN conversations_conversation cc ON cc.requester_id = spr.poster_id
JOIN people_person psit ON psit.id = cc.provider_id
JOIN auth_user ausit ON ausit.id = psit.user_id

JOIN (SELECT provider_id,
	  MAX(last_updated_calendar) AS 'last_updated_calendar'
      FROM services_service serv
      WHERE active = 1 and searchable = 1
      GROUP BY provider_id) serv ON serv.provider_id = psit.id

LEFT JOIN stays_stay stay ON cc.id = stay.conversation_id

LEFT JOIN services_service servhome ON servhome.provider_id = psit.id AND servhome.service_type_id = 1
LEFT JOIN services_service servtravel ON servtravel.provider_id = psit.id AND servtravel.service_type_id = 2
LEFT JOIN services_service servwalking ON servwalking.provider_id = psit.id AND servtravel.service_type_id = 3
LEFT JOIN services_service servdropin ON servdropin.provider_id = psit.id AND servtravel.service_type_id = 4
LEFT JOIN services_service servdaycare ON servdaycare.provider_id = psit.id AND servtravel.service_type_id = 5

LEFT JOIN (SELECT conversation_id,
           pet.name AS 'dog_name'
		   FROM conversations_conversation cc
           JOIN conversations_conversation_pets ccp ON cc.id = ccp.conversation_id
           JOIN pets_pet pet ON pet.id = ccp.pet_id
           WHERE pet.active = 1
           GROUP BY conversation_id) pet ON pet.conversation_id = cc.id

LEFT JOIN people_personlocation ppl ON ppl.person_id = psit.id
LEFT JOIN django_geo_zipcode dgz ON dgz.zip_code = pown.zip_code

WHERE stay.start_date = CURDATE() - INTERVAL 344 DAY 
and pet.dog_name IS NOT NULL

GROUP BY pown.id
