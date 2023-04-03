#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
     # get winner team_id
     WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

     # get opponent team_id
     OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

     if [[ -z $WINNER_TEAM_ID ]]
     then
       # insert winning team
       INSERT_WINNER_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

       if [[ $INSERT_WINNER_TEAM == "INSERT 0 1" ]]
       then
         echo Inserted into teams, $WINNER
       fi

       # get new winning team id
       WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

     fi

     if [[ -z $OPPONENT_TEAM_ID ]]
     then 
       # insert team
       INSERT_OPPONENT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
       if [[ $INSERT_OPPONENT_TEAM == "INSERT 0 1" ]]
       then
         echo Inserted into teams, $OPPONENT
       fi

       # get new opponent team id
       OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
     fi   

     # Get the game ID  WINNER OPPONENT
     GAME_ID=$($PSQL "SELECT game_id FROM games WHERE round='$ROUND' AND winner_id=$WINNER_TEAM_ID AND opponent_id=$OPPONENT_TEAM_ID")

     # game id not found 
     if [[ -z $GAME_ID ]]
     then
        INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_TEAM_ID, $OPPONENT_TEAM_ID )")

        if [[ $INSERT_GAME == "INSERT 0 1" ]]
        then
          echo Inserted into games, $ROUND : $WINNER_TEAM_ID : $OPPONENT_TEAM_ID
        fi
     fi

  fi
done