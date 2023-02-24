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

echo Start MYSQL Service""
systemctl enable mysqld &>>$LOG_FILE
systemctl restart mysqld &>>$LOG_FILE
StatusCheck $?

echo "Storing Temporary Pssword"
DEFAULT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}') &>>$LOG_FILE
StatusCheck $?

### storing changed password
echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${ROBOSHOP_MYSQL_PASSWORD}'); FLUSH PRIVILEGES;" > /tmp/root-pass.sql

echo "Changing mysql default  Root Password"
mysql -uroot -p${DEFAULT_PASSWORD} < /tmp/root-pass.sql &>>$LOG_FILE
StatusCheck $?


# mysql -uroot -pRoboShop@1
# uninstall plugin validate_password;
# curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
# curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
# cd /tmp
# unzip mysql.zip
# cd mysql-main
# mysql -u root -pRoboShop@1 <shipping.sql