ID=$(id -u)
if [ $ID -ne 0 ]; then
  echo "you should run this script as root user or with sudo privileges."
  exit 1
fi

## maintaing dry-code using functions
StatusCheck() {
  if [ $1 -eq 0 ]; then
    echo -e Status = "\e[32mSUCCESS\e[0m"
  else
    echo -e Status = "\e[32mFAILURE\e[0m"
    exit 1
  fi
}