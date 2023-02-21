echo installing Nginx
yum install nginx -y &>>/tmp/frontend
echo Status = $?

echo downloading Nginx web content
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>/tmp/frontend
echo Status = $?

cd /usr/share/nginx/html

echo removing old content
rm -rf *  &>>/tmp/frontend
echo status = $?

echo extracting web content
unzip /tmp/frontend.zip &>>/tmp/frontend
mv frontend-main/static/* . &>>/tmp/frontend
echo status =$?

echo moving config file to etc
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>/tmp/frontend

echo starting Nginx Service
systemctl enable nginx &>>/tmp/frontend
systemctl restart nginx &>>/tmp/frontend
echo status =$?


## problems i faced