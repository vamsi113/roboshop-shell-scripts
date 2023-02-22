LOG_FILE=/tmp/catalogue

source common.sh

echo "setting up nodejs"
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



echo "download catalogue application code"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
StatusCheck $?

cd /home/roboshop

echo "remove old content"
rm -rf catalogue &>>${LOG_FILE}
StatusCheck $?

echo "Extracting catalogue application code"
unzip /tmp/catalogue.zip &>>${LOG_FILE}
StatusCheck $?

mv catalogue-main catalogue
cd /home/roboshop/catalogue

echo "installing nodejs dependancies"
npm install &>>${LOG_FILE}
StatusCheck $?

echo "setup catalogue service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
StatusCheck $?

echo "daemon reload"
systemctl daemon-reload &>>${LOG_FILE}
StatusCheck $?

echo "application starting"
systemctl restart catalogue &>>${LOG_FILE}
StatusCheck $?

echo "application starting at boot level as well"
systemctl enable catalogue &>>${LOG_FILE}
StatusCheck $?