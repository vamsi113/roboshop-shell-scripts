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

## NodeJS function Dry Code
NODEJS(){
  echo "Setup NodeJS repo"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG_FILE}
  StatusCheck $?

  echo  "installing nodejs"
  yum install nodejs -y &>>${LOG_FILE}
  StatusCheck $?

  id roboshop &>>${LOG_FILE}
  if [ $? -ne 0 ]; then
    echo "adding Roboshop application User "
    useradd roboshop &>>${LOG_FILE}
    StatusCheck $?
  fi


  echo "download ${COMPONENT} application code"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
  StatusCheck $?

  cd /home/roboshop

  echo "remove old content"
  rm -rf ${COMPONENT} &>>${LOG_FILE}
  StatusCheck $?

  echo "Extracting ${COMPONENT} application code"
  unzip /tmp/${COMPONENT}.zip &>>${LOG_FILE}
  StatusCheck $?

  mv ${COMPONENT}-main ${COMPONENT}
  cd /home/roboshop/${COMPONENT}

  echo "installing nodejs dependancies"
  npm install &>>${LOG_FILE}
  StatusCheck $?

  echo "Update SystemD Service File"
  sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal' /home/roboshop/${COMPONENT}/systemd.service
  StatusCheck $?

  echo "setup user service"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
  StatusCheck $?

  echo "daemon reload"
  systemctl daemon-reload &>>${LOG_FILE}
  StatusCheck $?

  echo "user application starting"
  systemctl restart ${COMPONENT} &>>${LOG_FILE}
  StatusCheck $?

  echo "user application starting at boot level as well"
  systemctl enable ${COMPONENT} &>>${LOG_FILE}
  StatusCheck $?
}