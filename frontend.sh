LOG_FILE=/tmp/frontend

source common.sh

echo installing Nginx
yum install nginx -y &>>$LOG_FILE
StatusCheck $?

echo downloading Nginx web content
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG_FILE
StatusCheck $?

cd /usr/share/nginx/html


echo removing old content
rm -rf *  &>>$LOG_FILE
StatusCheck $?

echo extracting web content
unzip /tmp/frontend.zip &>>$LOG_FILE
mv frontend-main/static/* . &>>$LOG_FILE
StatusCheck $?


echo "moving config file to etc"
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE

echo "Updating frontend config file"
sed -i -e '/catalogue/ s/localhost/catalogue.roboshop.internal/' -e '/user/ s/localhost/user.roboshop.internal/' -e '/cart/ s/localhost/cart.roboshop.internal/' -e '/shipping/ s/localhost/shipping.roboshop.internal/' -e '/payment/ s/localhost/payment.roboshop.internal/' /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
StatusCheck $?

#for component in catalogue user cart payment shipping ; do
# sed -i -e "/${component}/ s/localhost/${component}.roboshop.internal/" /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
#done

echo starting Nginx Service
systemctl enable nginx &>>$LOG_FILE
systemctl restart nginx &>>$LOG_FILE
StatusCheck $?


