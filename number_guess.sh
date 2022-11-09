#!/bin/bash

echo "Enter your username:"

read USER_NAME

PSQL="psql -X --username=freecodecamp --dbname=number_guess --no-align --tuples-only -c"

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")

if [[ ! -z $USER_ID ]]
then
  # if user exist
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")

  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took 2 guesses."
else
  echo "Welcome, $USER_NAME! It looks like this is your first time here."

  # insert new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")

fi

echo "Guess the secret number between 1 and 1000:"
NUMBER_TO_GUESS=$(($RANDOM%5))

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(secret_number,guess_taken,game_completed,user_id) VALUES ($NUMBER_TO_GUESS,0,false,$USER_ID)")

CURRENT_GAME_ID=$($PSQL "SELECT MAX(game_id) FROM games")

CURRENT_GUESS=1001

GUESS_TAKEN=0

while [[ $CURRENT_GUESS -ne $NUMBER_TO_GUESS ]]
do
  read CURRENT_GUESS

  GUESS_TAKEN=$(( $GUESS_TAKEN + 1 ));
  
  INCREMENT_GUESS_RESULT=$($PSQL "UPDATE games SET guess_taken=$GUESS_TAKEN WHERE game_id=$CURRENT_GAME_ID")
  INCREMENT_GUESS_RESULT=$($PSQL "UPDATE games SET last_guess=$CURRENT_GUESS WHERE game_id=$CURRENT_GAME_ID")

  if [[ -z $CURRENT_GUESS ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ ! $CURRENT_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $CURRENT_GUESS -lt $NUMBER_TO_GUESS ]]
  then 
    echo "It's higher than that, guess again:"
  elif [[ $CURRENT_GUESS -gt $NUMBER_TO_GUESS ]]
  then 
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESS_TAKEN tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
    COMPLETE_GAME_RESULT=$($PSQL "UPDATE games SET game_completed=true WHERE game_id=$CURRENT_GAME_ID")
  fi
done



