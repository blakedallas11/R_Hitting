library(DBI)
library(RSQLite)
library(tidyverse)
library(gitcreds)
library("lattice")
library(ggplot2)
library(ggmap)
options(scipen = 100)
#gitcreds_set()


#create date ranges for the year


date1 = baseballr::scrape_statcast_savant(start_date = '2021-03-28',
                                          end_date = '2021-04-07',player_type = 'pitcher')



db = dbConnect(SQLite(),dbname = "Statcast.sqlite")

#Write the data frame Savant Data into a table in the DB
dbWriteTable(conn = db, name = "StatcastPitching", date1, overwrite = T, row.names = F)





pitching = dbGetQuery(db, "SELECT *
                      FROM webApp
                      LIMIT 10")

print(pitching)




#
# Look at this later but it currently is a way to 
#
webAppTable = dbGetQuery(db, "SELECT game_date, pitch_type , player_name AS Name, events, description, release_speed AS pitch_velocity,
                         zone, des, stand, p_throws, home_team, away_team, type, hit_location, bb_type, balls, strikes,
                         game_year, plate_x AS horizontal_loc, plate_z AS vertical_loc, on_3b, on_2b, on_1b, outs_when_up,
                         inning, inning_topbot, at_bat_number, pitch_name, home_score, away_score
                         FROM StatcastPitching")

dbWriteTable(db, "webApp", webAppTable, overwrite = T, row.names + F)





count = dbGetQuery(db, "SELECT Count()
                   FROM webApp")
print(count)







average_location_by_pitch = dbGetQuery(db, "SELECT pitch_type, avg(horizontal_loc) AS Horizontal,
                                       avg(vertical_loc) AS vertical
                                       FROM webApp
                                       WHERE Name == 'Bauer, Trevor'
                                       GROUP BY pitch_type")
print(average_location_by_pitch)



fastball_Location_Plot_Data = dbGetQuery(db, "SELECT ROUND(horizontal_loc,1) AS H_Loc, ROUND(vertical_loc,1) AS V_Loc
                                         FROM (SELECT horizontal_loc, vertical_loc
                                         FROM webApp
                                         WHERE Name == 'Bauer, Trevor'
                                         AND pitch_type == 'FF')
                                         ORDER BY H_Loc, V_Loc ASC")
print(fastball_Location_Plot_Data)

fastball_Location_Plot_Data%>%
  select(nrow(fastball_Location_Plot_Data))%>%
  filter(H_Loc >= -1, H_Loc <= 1, V_Loc >=1.5, V_Loc<=3.5)



fastball_Heatmap = dbGetQuery(db, "SELECT horizontal_loc, vertical_loc, count()
                              FROM webapp
                              WHERE Name == 'Bauer, Trevor'
                              AND pitch_type == 'FF'")
print(fastball_Heatmap)




plot.new()
# basic scatterplot
plot(fastball_Location_Plot_Data, xlim=c(-4,4), ylim=c(0.75,4.75))
clip(x1=-1,x2=1,y1=0,y2=5)
abline(h = 1.5)
abline(h = 3.5)
clip(x1=-3,x2=5,y1=1.5,y2=3.5)
abline(v = -1)
abline(v = 1)



x <- seq(-2,2,length.out = 20)
y <- seq(-1,4,length.out = 20)
data <- expand.grid(X=x, Y=y)
data$Z <- runif(400, 0, 5)

## Try it out
levelplot(Z ~ X*Y, data=data  ,xlab="X",
          main="")






