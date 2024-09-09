#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

num=$((1 + RANDOM % 1000))

echo "Enter your username:"
read username

query="SELECT * FROM users WHERE username = '$username';"
res=$($PSQL "$query")
if [ -z "$res" ]; then
  echo "Welcome, $username! It looks like this is your first time here."
else
  games_played=$(echo "$res" | cut -d '|' -f 2)
  best_game=$(echo "$res" | cut -d '|' -f 3)
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read guess

try=1

while [ 1 ]; do
  # check non-integers
  if ! [[ $guess =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif [ $guess -eq $num ]; then
    echo "You guessed it in $try tries. The secret number was $num. Nice job!"
    break
  elif [ $guess -lt $num ]; then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi

  try=$(($try + 1))
  read guess
done

if [ -z $res ]; then
  query="INSERT INTO users (username, games_played, best_game) VALUES ('$username', 1, $try);"
else
  query="UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $try) WHERE username = '$username';"
fi

_=$($PSQL "$query")