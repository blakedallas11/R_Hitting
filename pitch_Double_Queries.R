
EVbyPitchTypeWPrevPitch = dbGetQuery(db, "SELECT previous_pitch, pitch_type, ROUND(AVG(launch_speed),1) AS 'AVG_EV_W_PREV', ROUND(AVG(launch_angle),1) AS 'AVG_LA_W_PREV'
                           FROM ordered_w_prev_pitch
                           WHERE description == 'hit_into_play'
                           AND previous_pitch != '<NA>'
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
print(EVbyPitchTypeWPrevPitch)

dbWriteTable(db, "EVbyPrevPitchPitchType", EVbyPitchTypeWPrevPitch,overwrite = T, row.names = F)

EVbyPitchType = dbGetQuery(db, "SELECT pitch_type, ROUND(AVG(launch_speed),1) AS 'AVG_EV', ROUND(AVG(launch_angle),1) AS 'AVG_LA'
                           FROM ordered_w_prev_pitch
                           WHERE description == 'hit_into_play'
                           AND pitch_type != '<NA>'
                           AND pitch_type != 'CS'
                           AND pitch_type != 'FA'
                           AND pitch_type != 'KN'
                           AND pitch_type != 'EP'
                           GROUP BY pitch_type")
print(EVbyPitchType)

dbWriteTable(db, "EVbyPitchType", EVbyPitchType, overwrite = T, row.names = F)


#Gets prev pitch, curr pitch, avg ev with prev pitch, avg ev of curr pitch and the difference between the pitch ev and sequenced
#ev. This can help us understand pitch sequencing and it's effect on how hard the ball is hit.
EVtwoColumns = dbGetQuery(db, "SELECT  EVbyPrevPitchPitchType.previous_pitch, EVbyPrevPitchPitchType.pitch_type, EVbyPrevPitchPitchType.AVG_EV_W_PREV,
                          EVbyPitchType.AVG_EV, EVbyPrevPitchPitchType.AVG_EV_W_PREV - EVbyPitchType.AVG_EV AS 'difference'
                          FROM EVbyPrevPitchPitchType 
                          INNER JOIN EVbyPitchType ON EVbyPrevPitchPitchType.pitch_type = EVbyPitchType.pitch_type
                          ORDER BY difference ASC")
print(EVtwoColumns)



#Plot 1
#####

EVandLA = dbGetQuery(db, "SELECT  EVbyPrevPitchPitchType.previous_pitch, EVbyPrevPitchPitchType.pitch_type, EVbyPrevPitchPitchType.AVG_EV_W_PREV,
                          EVbyPitchType.AVG_EV, EVbyPrevPitchPitchType.AVG_EV_W_PREV - EVbyPitchType.AVG_EV AS 'EV_difference', 
                          EVbyPrevPitchPitchType.AVG_LA_W_PREV,
                          EVbyPitchType.AVG_LA, EVbyPrevPitchPitchType.AVG_LA_W_PREV - EVbyPitchType.AVG_LA AS 'LA_difference'
                          FROM EVbyPrevPitchPitchType 
                          INNER JOIN EVbyPitchType ON EVbyPrevPitchPitchType.pitch_type = EVbyPitchType.pitch_type
                          ORDER BY EV_difference ASC")
print(EVandLA)

#This is how you print a certain column of an R dataframe
print(EVandLA$previous_pitch)

#Set the outlier range to take out the top two changes in launch angle that were down in the -30 and lower range and messing
# with the plot
yout = EVandLA$LA_difference < -10

# the function that calculates the linear regression for the trend line on the plot
linearRegressionLine = lm(EVandLA$LA_difference[!yout] ~ EVandLA$EV_difference[!yout], EVandLA)

#Plot the two axes from the data frame created by the query above
plot(EVandLA$EV_difference[!yout],EVandLA$LA_difference[!yout],type = "o")

#put the trendline on the plot
lines(EVandLA$EV_difference[!yout],predict(linearRegressionLine))

#print the y intercept and the slope of the trend line
print(coef(linearRegressionLine))






######



# All realistic combinations of 2 pitch sequences minus generic reads, <NA>'s, and uncommon pitch types
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


#pitch sequences that ended up in balls in play
prev_pitch_curr_pitch_types_BIP = dbGetQuery(db, "SELECT previous_pitch, pitch_type, COUNT(*) AS 'Balls in Play'
                                         FROM ordered_w_prev_pitch
                                         WHERE description == 'hit_into_play'
                                         AND previous_pitch != '<NA>'
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
print(prev_pitch_curr_pitch_types_BIP)


pitchSequenceBIPCountsOnly = dbGetQuery(db, "SELECT COUNT(*) AS 'Balls in Play'
                                         FROM ordered_w_prev_pitch
                                         WHERE description == 'hit_into_play'
                                         AND previous_pitch != '<NA>'
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
print(pitchSequenceBIPCountsOnly)



#Fix this to return the same rows as the Balls in play query
#Maybe Join the two queries or use a complex one to get both numbers in the same query
#then try to use an R mathematical function to divide the two numbers in each row and get a
# batting average for balls in play
pitchSequenceHitCountsOnly = dbGetQuery(db, "SELECT previous_pitch, pitch_type, COUNT(*) AS 'Hits by pitch sequence'
                                         FROM ordered_w_prev_pitch
                                         WHERE description == 'hit_into_play'
                                         AND (events == 'double'
                                         OR events == 'single'
                                         OR events == 'triple'
                                         OR events == 'home_run')
                                         AND previous_pitch != '<NA>'
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
print(pitchSequenceHitCountsOnly)

