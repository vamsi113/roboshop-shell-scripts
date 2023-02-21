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


## problems:
#Ensured the script should run only if it is a root user/sudo previleges.
#if a ny command is a failure then i need to stop the script there and then.
#rather than printing 0 and 1 or  something i printed success or failure