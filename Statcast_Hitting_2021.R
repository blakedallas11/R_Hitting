#install.packages('RSQLite')
#install.packages("DBI")
#install.packages("tidyverse")
#install.packages("gitcreds")

library(DBI)
library(RSQLite)
library(tidyverse)
library(gitcreds)

gitcreds_set()


#create date ranges for the year


date1 = baseballr::scrape_statcast_savant(start_date = '2021-03-28',
                                               end_date = '2021-04-07',player_type = 'batter')

date2 = baseballr::scrape_statcast_savant(start_date = '2021-04-08',
                                               end_date = '2021-04-15',player_type = 'batter')

date3 = baseballr::scrape_statcast_savant(start_date = '2021-04-16',
                                               end_date = '2021-04-22',player_type = 'batter')

date4 = baseballr::scrape_statcast_savant(start_date = '2021-04-23',
                                               end_date = '2021-04-29',player_type = 'batter')

date5 = baseballr::scrape_statcast_savant(start_date = '2021-04-30',
                                               end_date = '2021-05-06',player_type = 'batter')

date6 = baseballr::scrape_statcast_savant(start_date = '2021-05-07',
                                               end_date = '2021-05-13',player_type = 'batter')

date7 = baseballr::scrape_statcast_savant(start_date = '2021-05-14',
                                               end_date = '2021-05-20',player_type = 'batter')

date8 = baseballr::scrape_statcast_savant(start_date = '2021-05-21',
                                               end_date = '2021-05-27',player_type = 'batter')

date9 = baseballr::scrape_statcast_savant(start_date = '2021-05-28',
                                               end_date = '2021-06-03',player_type = 'batter')

date10 = baseballr::scrape_statcast_savant(start_date = '2021-06-04',
                                               end_date = '2021-06-10',player_type = 'batter')

date11 = baseballr::scrape_statcast_savant(start_date = '2021-06-11',
                                               end_date = '2021-06-17',player_type = 'batter')

date12 = baseballr::scrape_statcast_savant(start_date = '2021-06-18',
                                               end_date = '2021-06-24',player_type = 'batter')

date13 = baseballr::scrape_statcast_savant(start_date = '2021-06-25',
                                               end_date = '2021-07-01',player_type = 'batter')

date14 = baseballr::scrape_statcast_savant(start_date = '2021-07-02',
                                               end_date = '2021-07-08',player_type = 'batter')

date15 = baseballr::scrape_statcast_savant(start_date = '2021-07-09',
                                               end_date = '2021-07-15',player_type = 'batter')

date16 = baseballr::scrape_statcast_savant(start_date = '2021-07-16',
                                               end_date = '2021-07-22',player_type = 'batter')

date17 = baseballr::scrape_statcast_savant(start_date = '2021-07-23',
                                               end_date = '2021-07-29',player_type = 'batter')

date18 = baseballr::scrape_statcast_savant(start_date = '2021-07-30',
                                               end_date = '2021-08-05',player_type = 'batter')

date19 = baseballr::scrape_statcast_savant(start_date = '2021-08-06',
                                               end_date = '2021-08-12',player_type = 'batter')

date20 = baseballr::scrape_statcast_savant(start_date = '2021-08-13',
                                               end_date = '2021-08-19',player_type = 'batter')

date21 = baseballr::scrape_statcast_savant(start_date = '2021-08-20',
                                               end_date = '2021-08-26',player_type = 'batter')

date22 = baseballr::scrape_statcast_savant(start_date = '2021-08-27',
                                               end_date = '2021-09-02',player_type = 'batter')

date23 = baseballr::scrape_statcast_savant(start_date = '2021-09-03',
                                               end_date = '2021-09-09',player_type = 'batter')

date24 = baseballr::scrape_statcast_savant(start_date = '2021-09-10',
                                               end_date = '2021-09-16',player_type = 'batter')

date25 = baseballr::scrape_statcast_savant(start_date = '2021-09-17',
                                               end_date = '2021-09-23',player_type = 'batter')

date26 = baseballr::scrape_statcast_savant(start_date = '2021-09-24',
                                               end_date = '2021-09-29',player_type = 'batter')

date27 = baseballr::scrape_statcast_savant(start_date = '2021-09-30',
                                           end_date = '2021-10-03',player_type = 'batter')

#date27 = baseballr::scrape_statcast_savant(start_date = '09-30-2021',
                                               #end_date = '10-03-2021',player_type = 'batter')


#Bind all weekly data frames into one large data frame
SavantData = rbind(date1, date2, date3, date4, date5, date6, date7, date8, date9, date10,
                   date11, date12, date13, date14, date15, date16, date17, date18, date19, date20,
                   date21, date22, date23, date24, date25, date26, date27)

#Remove all useless data frames once stored in SavantData
remove(date1, date2, date3, date4, date5, date6, date7, date8, date9, date10,
       date11, date12, date13, date14, date15, date16, date17, date18, date19, date20,
       date21, date22, date23, date24, date25, date26, date27)


#Create an SQLite database
db = dbConnect(SQLite(),dbname = "Statcast.sqlite")

#Write the data frame SavantData into a table in the DB
dbWriteTable(conn = db, name = "StatcastHitting", SavantData, overwrite = T, row.names = F)


#Write data to new table ordered in sequential order
Ordered_at_bats = dbGetQuery(db, "SELECT * 
                            FROM StatcastHitting
                            ORDER BY game_pk,
                             at_bat_number ASC,
                             pitch_number ASC")

dbWriteTable(db, name = "ordered_at_bats", Ordered_at_bats, overwrite = T, row.names = F)


#Get the previous pitch as 'LAG' attached to all pitches. May write an insert column for this Query to make 
# subsequent queries less complicated
FF_Hits = dbGetQuery(conn = db, 
                         "SELECT *, LAG (pitch_type, 1) OVER (
        PARTITION BY game_pk,
        at_bat_number
        ORDER BY pitch_number
    ) AS 'previous_pitch'
    FROM ordered_at_bats")
#Fetch results from DB Query
print(FF_Hits)

remove(Ordered_at_bats)


# Create new table where the previous pitch is another column in the data
dbWriteTable(db, name = "ordered_w_prev_pitch", FF_Hits, overwrite = T, row.names = F)


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

# All realistic combinations of 2 pitch sequences minus genaric reads, <NA>'s, and uncommon pitch types
prev_pitch_curr_pitch_types = dbGetQuery(db, "SELECT previous_pitch, pitch_type, COUNT(*) AS 'Occurances'
                                         FROM ordered_w_prev_pitch
                                         WHERE previous_pitch != '<NA>'
                                         AND pitch_type != '<NA>'
                                         AND pitch_type != 'CS'
                                         AND pitch_type != 'FA'
                                         AND pitch_type != 'KN'
                                         AND pitch_type != 'EP'
                                         AND previous_pitch != 'CS'
                                         AND previous_pitch != 'FA'
                                         AND previous_pitch != 'KN'
                                         AND previous_pitch != 'EP'
                                         GROUP BY pitch_type, previous_pitch")
print(prev_pitch_curr_pitch_types)

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


SavantData %>% slice(1:5)

#Using data frame operators, query the data frame like an SQL query
SavantData %>%
     select(player_name, events, launch_speed, release_speed) %>%
     filter(events == "home_run", release_speed >= 95) %>%
     group_by(player_name) %>%
     summarise(HR = n(), AvgEV = mean( launch_speed)) %>%
     arrange(desc(HR))

SavantData %>%
    select(events, description) %>%
    filter(description == "hit_into_play", events == "double", 
           OR ) %>%
    group_by(events) %>%
    summarise(count = n())

remove(SavantData)


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




dbDisconnect(db)

