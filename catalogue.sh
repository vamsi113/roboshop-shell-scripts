LOG_FILE=/tmp/catalogue

echo "setting up nodejs"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG_FILE}
if [$? -eq 0]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
fi

echo  "installing nodejs"
yum install nodejs -y &>>${LOG_FILE}
if [$? -eq 0]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
fi

echo "adding Roboshop application User "
useradd roboshop &>>${LOG_FILE}
if [$? -eq 0]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
fi

echo "download catalogue application code"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
if [$? -eq 0]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
fi

cd /home/roboshop

echo "Extracting catalogue application code"
unzip /tmp/catalogue.zip &>>${LOG_FILE}
if [$? -eq 0]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
fi

mv catalogue-main catalogue
cd /home/roboshop/catalogue

echo "installing nodejs dependancies"
npm install &>>${LOG_FILE}
if [$? -eq 0]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
fi

echo "setup catalogue service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
if [$? -eq 0]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
fi
echo "daemon reload"
systemctl daemon-reload &>>${LOG_FILE}
if [$? -eq 0]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
fi

echo "application starting"
systemctl start catalogue &>>${LOG_FILE}
if [$? -eq 0]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
fi

echo "application starting at boot level as well"
systemctl enable catalogue &>>${LOG_FILE}
if [$? -eq 0]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
fi
