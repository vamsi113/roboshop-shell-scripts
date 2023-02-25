COMPONENT=rabbitmq

LOG_FILE=/tmp/${COMPONENT}
source common.sh

echo "Setup Erlang Repos for RabbitMQ"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>${LOG_FILE}
StatusCheck $?

echo "Installing Erlang"
# yum install erlang -y &>>${LOG_FILE}
StatusCheck $?

echo "Setup RabbitMQ Repo"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG_FILE}
StatusCheck $?

echo "Installing RabbitMQ Server"
yum install rabbitmq-server -y &>>${LOG_FILE}
StatusCheck $?

echo "Enabling and starting RabbitMQ Server"
systemctl enable rabbitmq-server &>>${LOG_FILE}
systemctl start rabbitmq-server &>>${LOG_FILE}
StatusCheck $?

echo rabbitmqctl list_users | grep roboshop &>>${LOG_FILE}
if [ $? -ne 0 ]; then
  echo "Add Application User in RabbitMQ"
  rabbitmqctl add_user roboshop roboshop123 &>>${LOG_FILE}
  StatusCheck $?
fi



echo "Add Application User tags in RabbitmQ"
rabbitmqctl set_user_tags roboshop administrator &>>${LOG_FILE}
StatusCheck $?

echo "Set Permissions to roboshop user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG_FILE}
StatusCheck $?