LOG_FILE=/tmp/catalogue

ID=$(id -u)
if [ $ID -ne 0 ]; then
  echo "you should run this script as root user or with sudo privileges."
  exit 1
fi

echo "setting up nodejs"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG_FILE}

if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo  "installing nodejs"
yum install nodejs -y &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

id roboshop &>>${LOG_FILE}
if [ $? -ne 0 ]; then
  echo "adding Roboshop application User "
  useradd roboshop &>>${LOG_FILE}
  if [ $? -eq 0 ]; then
    echo Status = SUCCESS
  else
    echo Status = FAILURE
    exit 1
  fi
fi

echo "remove old content"
rm -rf catalogue &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "download catalogue application code"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

cd /home/roboshop

echo "Extracting catalogue application code"
unzip /tmp/catalogue.zip &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

mv catalogue-main catalogue
cd /home/roboshop/catalogue

echo "installing nodejs dependancies"
npm install &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "setup catalogue service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "daemon reload"
systemctl daemon-reload &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "application starting"
systemctl restart catalogue &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "application starting at boot level as well"
systemctl enable catalogue &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi
