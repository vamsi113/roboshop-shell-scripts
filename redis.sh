LOG_FILE=/tmp/redis

source common.sh

echo "setup yum repo for redis"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>${LOG_FILE}
StatusCheck $?

echo "enabling redis yum modules"
dnf module enable redis:remi-6.2 -y &>>${LOG_FILE}
StatusCheck $?

echo "installing redis"
yum install redis -y &>>${LOG_FILE}
StatusCheck $?

echo "update listener address"
#Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/redis.conf & /etc/redis/redis.conf
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf
StatusCheck $?

echo "enable redis"
systemctl enable redis &>>${LOG_FILE}
StatusCheck $?

echo "starting redis"
systemctl restart redis &>>${LOG_FILE}
StatusCheck $?