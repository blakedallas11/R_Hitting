



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
pitchSequenceHitCountsOnly = dbGetQuery(db, "SELECT COUNT(*) AS 'Hits by pitch sequence'
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



pitchSequenceHitCountsOnly = rbind(pitchSequenceHitCountsOnly,12,13,10)
BABIP_pitchSequence = pitchSequenceHitCountsOnly / pitchSequenceBIPCountsOnly
print(BABIP_pitchSequence)