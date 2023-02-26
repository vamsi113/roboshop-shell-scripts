LOG_FILE=/tmp/mongodb

source common.sh

echo "setting MongoDB repo"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>$LOG_FILE
StatusCheck $?

echo "installing mongodb repo"
yum install -y mongodb-org &>>$LOG_FILE
StatusCheck $?

echo "updating listener config"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
StatusCheck $?

echo "starting mongodb service"
systemctl enable mongod &>>$LOG_FILE
systemctl restart mongod &>>$LOG_FILE
StatusCheck $?

echo "downloading Mongodb schema"
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>$LOG_FILE


cd /tmp
echo "extracting schema files"
unzip -o mongodb.zip &>>$LOG_FILE
StatusCheck $?


cd mongodb-main

echo "load Catalogue Service Schema"
mongo < catalogue.js &>>$LOG_FILE
StatusCheck $?

echo "Load User Service Schema"
mongo < users.js &>>$LOG_FILE
StatusCheck $?

## Load schema can be done using loops also
#for schema in catalogue.js users.js ; do
#  mongo < ${schema} &>>$LOG_FILE
#done




