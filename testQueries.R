



#get pitch type and count of all pitches thrown where the previous pitch is a 4 seam fastball
previous_FF = dbGetQuery(db, "SELECT pitch_type, COUNT(*) AS '#'
                         FROM ordered_w_prev_pitch
                         WHERE previous_pitch == 'FF'
                         GROUP BY pitch_type")
print(previous_FF)


#get count of occurrences where pitch hit into play and previous pitch was 4 seam fastball
previous_FF_in_play = dbGetQuery(db, "SELECT COUNT(*) AS '#'
                         FROM ordered_w_prev_pitch
                         WHERE previous_pitch == 'FF'
                         AND description == 'hit_into_play'")
print(previous_FF_in_play)


# Query written to figure out what the random pitch types SC, FA, CS, etc. were.
questions = dbGetQuery(db, "SELECT pitch_name, COUNT(pitch_name) as 'Total'
                       FROM ordered_w_prev_pitch
                       WHERE pitch_type == 'SC'
                       GROUP BY pitch_name")
print(questions)


#pitch types of all pitches gone for base hits where fastball was the previous pitch
previous_FF_Hits = dbGetQuery(db, "SELECT pitch_type, COUNT(*) AS '#'
                         FROM ordered_w_prev_pitch
                         WHERE previous_pitch == 'FF'
                         AND (events == 'double'
                         OR events == 'single'
                         OR events == 'triple'
                         OR events == 'home_run')
                         GROUP BY pitch_type")
print(previous_FF_Hits)

#total count of hits when the previous pitch was a fastball
previous_FF_Hits_count = dbGetQuery(db, "SELECT COUNT(*) AS '#'
                         FROM ordered_w_prev_pitch
                         WHERE previous_pitch == 'FF'
                         AND (events == 'double'
                         OR events == 'single'
                         OR events == 'triple'
                         OR events == 'home_run')")
print(previous_FF_Hits_count)

FFBABIP = previous_FF_Hits_count / previous_FF_in_play

print(FFBABIP)


orderedABs_prevPitch %>% slice(1:5)

#Using data frame operators, query the data frame like an SQL query
orderedABs_prevPitch %>%
  select(player_name, events, launch_speed, release_speed) %>%
  filter(events == "home_run", release_speed >= 95) %>%
  group_by(player_name) %>%
  summarise(HR = n(), AvgEV = mean( launch_speed)) %>%
  arrange(desc(HR))

orderedABs_prevPitch %>%
  select(events, description) %>%
  filter(description == "hit_into_play", events == "double", 
         OR ) %>%
  group_by(events) %>%
  summarise(count = n())




#Get all instances of balls in play
BIP_Type = dbGetQuery(db, "SELECT events, COUNT(events)
                      FROM StatcastHitting
                      WHERE description == 'hit_into_play'
                      GROUP BY events
                      ORDER BY events ASC")
print(BIP_Type)


# Total count of balls in play
BIP_Total = dbGetQuery(db, "SELECT COUNT(events) AS 'Balls in Play'
                       FROM StatcastHitting
                       WHERE description == 'hit_into_play'")
print(BIP_Total)


# Total count of hits
HITS = dbGetQuery(db, "SELECT COUNT(events) AS 'Hits'
                  FROM StatcastHitting
                  WHERE description == 'hit_into_play'
                  AND (events == 'single'
                  OR events == 'double'
                  OR events == 'triple'
                  OR events == 'home_run')")
print(HITS)


# Batting average on balls in play
BABIP = HITS / BIP_Total
print(BABIP)


#Query the DB
FFOutcomes = dbSendQuery(conn = db, 
                         "SELECT events, COUNT(events)
    FROM StatcastHitting
    WHERE description == 'hit_into_play' 
    AND pitch_type == 'FF'
    AND (events == 'double'
    OR events == 'single'
    OR events == 'triple'
    OR events == 'home_run')
    GROUP BY events")
#Fetch results from DB Query
dbFetch(FFOutcomes)