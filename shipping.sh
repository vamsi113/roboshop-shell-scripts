LOG_FILE=/tmp/shipping

source common.sh
JAVA

echo "Install Maven"
yum install maven -y &>>${LOG_FILE}
StatusCheck $?

# useradd roboshop
$ cd /home/roboshop
$ curl -s -L -o /tmp/shipping.zip "https://github.com/roboshop-devops-project/shipping/archive/main.zip"
$ unzip /tmp/shipping.zip
$ mv shipping-main shipping
$ cd shipping
$ mvn clean package
$ mv target/shipping-1.0.jar shipping.jar
# mv /home/roboshop/shipping/systemd.service /etc/systemd/system/shipping.service
# systemctl daemon-reload
# systemctl start shipping
# systemctl enable shipping