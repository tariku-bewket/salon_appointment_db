#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi

  echo -e "1) color\n2) bridal\n3) hair extensions\n4) massages\n5) facials"

  read SERVICE_ID_SELECTED;

  case $SERVICE_ID_SELECTED in
    1|2|3|4|5) GET_SERVICE $SERVICE_ID_SELECTED ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

GET_SERVICE() {
  local SERVICE_ID_SELECTED=$1

  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'");

  echo "$CUSTOMER_ID"

  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    echo -e "\nWhat time would you like your cut, Fabio?"
    read SERVICE_TIME

    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'");

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED,'$SERVICE_TIME')")

  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'");
    SERVICE_TIME=$($PSQL "SELECT time FROM customers INNER JOIN appointments USING(customer_id) WHERE phone = '$CUSTOMER_PHONE'");
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  
}

MAIN_MENU