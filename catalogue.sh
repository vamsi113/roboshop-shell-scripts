LOG_FILE=/tmp/catalogue

echo "setting up nodejs"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG_FILE}
echo Status = $?

echo  "installing nodejs"
yum install nodejs -y &>>${LOG_FILE}
echo status =$?

echo "adding Roboshop application User "
useradd roboshop &>>${LOG_FILE}
echo status =$?

echo "download catalogue application code"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
echo status =$?

cd /home/roboshop

echo "Extracting catalogue application code"
unzip /tmp/catalogue.zip &>>${LOG_FILE}
echo status =$?

mv catalogue-main catalogue
cd /home/roboshop/catalogue

echo "installing nodejs dependancies"
npm install &>>${LOG_FILE}
echo status =$?

echo "setup catalogue service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
echo status =$?

echo "daemon reload"
systemctl daemon-reload &>>${LOG_FILE}
echo status =$?

echo "application starting"
systemctl start catalogue &>>${LOG_FILE}
echo status =$?

echo "application starting at boot level as well"
systemctl enable catalogue &>>${LOG_FILE}
echo status =$?
