LOG_FILE=/tmp/frontend
echo installing Nginx
yum install nginx -y &>>$LOG_FILE
echo Status = $?

echo downloading Nginx web content
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG_FILE
echo Status = $?

cd /usr/share/nginx/html


echo removing old content
rm -rf *  &>>$LOG_FILE
echo status = $?

echo extracting web content
unzip /tmp/frontend.zip &>>$LOG_FILE
mv frontend-main/static/* . &>>$LOG_FILE
echo status =$?

echo moving config file to etc
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE

echo starting Nginx Service
systemctl enable nginx &>>$LOG_FILE
systemctl restart nginx &>>$LOG_FILE
echo status =$?


