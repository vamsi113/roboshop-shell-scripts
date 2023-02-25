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
APP_PRESETUP(){
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

}
SYSTEMD_SETUP(){
  echo "Update SystemD Service File"
    sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' -e 's/CARTHOST/cart.roboshop.internal/' -e 's/USERHOST/user.roboshop.internal/' -e 's/AMQPHOST/rabbitmq.roboshop.internal/'/home/roboshop/${COMPONENT}/systemd.service
    StatusCheck $?

  echo "setup ${Component} Service"
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
## NodeJS function Dry Code
NODEJS(){
  echo "Setup NodeJS repo"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG_FILE}
  StatusCheck $?

  echo  "installing nodejs"
  yum install nodejs -y &>>${LOG_FILE}
  StatusCheck $?

  APP_PRESETUP


  echo "installing nodejs dependancies"
  npm install &>>${LOG_FILE}
  StatusCheck $?



  SYSTEMD_SETUP


}

JAVA(){
  echo "Install Maven"
  yum install maven -y &>>${LOG_FILE}
  StatusCheck $?

  APP_PRESETUP

  echo "Download Dependancies and Make Packages"
  mvn clean package &>>${LOG_FILE}
  mv target/shipping-1.0.jar shipping.jar &>>${LOG_FILE}
  StatusCheck $?

  SYSTEMD_SETUP

}

PYTHON(){
  echo "Installing Python 3 "
  yum install python36 gcc python3-devel -y &>>${LOG_FILE}
  StatusCheck $?

  APP_PRESETUP

  echo "Installing Pip Requirements "
  pip3 install -r requirements.txt &>>${LOG_FILE}
  StatusCheck $?

  echo "Update Payment Configuration File"
  APP_UID=$(id -u roboshop)
  APP_GID=$(id -g roboshop)
  sed -i -e "/uid/ c uid = ${APP_UID}" -e "/gid/ c gid = ${APP_GID}" /home/roboshop/${COMPONENT}/${COMPONENT}.ini &>>${LOG_FILE}
  StatusCheck $?

  SYSTEMD_SETUP

}