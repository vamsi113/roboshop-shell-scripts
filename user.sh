LOG_FILE=/tmp/user

source common.sh


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


echo "download user application code"
curl -s -L -o /tmp/user.zip "https://github.com/roboshop-devops-project/user/archive/main.zip" &>>${LOG_FILE}
StatusCheck $?

cd /home/roboshop

echo "remove old content"
rm -rf user &>>${LOG_FILE}
StatusCheck $?

echo "Extracting user application code"
unzip /tmp/user.zip &>>${LOG_FILE}
StatusCheck $?

mv user-main user
cd /home/roboshop/user

echo "installing nodejs dependancies"
npm install &>>${LOG_FILE}
StatusCheck $?

echo "Update SystemD Service File"
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' /home/roboshop/catalogue/systemd.service
StatusCheck $?

echo "setup user service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
StatusCheck $?

echo "daemon reload"
systemctl daemon-reload &>>${LOG_FILE}
StatusCheck $?

echo "user application starting"
systemctl restart catalogue &>>${LOG_FILE}
StatusCheck $?

echo "user application starting at boot level as well"
systemctl enable catalogue &>>${LOG_FILE}
StatusCheck $?

