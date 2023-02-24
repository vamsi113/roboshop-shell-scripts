LOG_FILE=/tmp/mysql
source common.sh

echo "Setting UP MYSQL Repo File"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>$LOG_FILE
StatusCheck $?


echo "Disable MYSQL Default Module to Enable 5.7 MYSQL"
dnf module disable mysql -y &>>$LOG_FILE
StatusCheck $?


echo "Install MYSQL"
yum install mysql-community-server -y &>>$LOG_FILE
StatusCheck $?

echo "Enabling MYSQL Service"
systemctl enable mysqld &>>$LOG_FILE
StatusCheck $?

echo "Satarting MYSQL Service"
systemctl restart mysqld &>>$LOG_FILE
StatusCheck $?

echo "Storing Default password"
DEFAULT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}') &>>$LOG_FILE
StatusCheck $?

### storing changed password
echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${ROBOSHOP_MYSQL_PASSWORD}'); FLUSH PRIVILEGES;" > /tmp/root-pass.sql

echo "show databases;" | mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD} &>>$LOG_FILE
if [ $? -ne 0 ]; then
  echo "Changing mysql default  Root Password"

  mysql --connect-expired-password -uroot -p${DEFAULT_PASSWORD} < /tmp/root-pass.sql &>>$LOG_FILE
  StatusCheck $?
fi
# uninstall plugin validate_password;
echo "show plugins" | mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD} 2>>$LOG_FILE | grep validate_password &>>$LOG_FILE
if [ $? -eq 0 ]; then
  echo "uninstall password validation plugin"
  echo "uninstall plugin validate_password;" | mysql -uroot -p${ROBOSHOP_MYSQL_PASSWORD} &>>$LOG_FILE
  StatusCheck $?
fi



echo "Download Schema"
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>$LOG_FILE
StatusCheck $?

cd /tmp
#echo "remove old content"
#rm -rf * &>>${LOG_FILE}
#StatusCheck $?

echo "Extract Schema"
unzip mysql.zip &>>$LOG_FILE
StatusCheck $?

echo "Load Schema"
cd mysql-main
mysql -u root -p${ROBOSHOP_MYSQL_PASSWORD} <shipping.sql &>>$LOG_FILE
StatusCheck $?

