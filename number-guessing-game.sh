#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

COUNTER=0

USER_INPUT() {
  echo "Enter your username:"
  read USERNAME

  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  if [[ -z $GAMES_PLAYED ]]
  then 
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_INTO_USERS=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, -1)")
  else 
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  SECRET_NUMBER=$((1 + RANDOM % 1000))
  echo "Guess the secret number between 1 and 1000:"
  PLAY_GAME $SECRET_NUMBER $USERNAME
}



PLAY_GAME() {
  read GUESS

  if [[ ! $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    PLAY_GAME $1 $2

  elif [[ $1 -eq $GUESS ]]
  then 
    COUNTER=$((COUNTER + 1))
    UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $COUNTER WHERE best_game < 0 OR (username='$2' AND best_game > $COUNTER)")
    UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$2'")
    echo "You guessed it in $COUNTER tries. The secret number was $1. Nice job!"


  elif [[ $1 -gt $GUESS ]]
  then
    echo "It's higher than that, guess again:"
    COUNTER=$((COUNTER + 1))
    PLAY_GAME $1 $2

  elif [[ $1 -lt $GUESS ]]
  then
    echo "It's lower than that, guess again:"
    COUNTER=$((COUNTER + 1))
    PLAY_GAME $1 $2
  fi
}


# main calls to functions 
USER_INPUT
