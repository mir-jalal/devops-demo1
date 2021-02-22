#!/usr/bin/env bash

echo "systemd provisioning"

cat > /etc/systemd/system/petclinic.service <<EOF
#!/usr/bin/env bash

[Unit]
Description=Petclinic Java Spring Boot

[Service]
User=demo_user
WorkingDirectory=/home/vagrant/demo1
Environment="MYSQL_PASS=$1"
Environment="MYSQL_URL=jdbc:mysql://db:3306/$2"
Environment="MYSQL_USER=$3"
ExecStart=/home/vagrant/petclinic.sh
SuccessExitStatus=143
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

EOF

cat > /home/vagrant/petclinic.sh <<EOF
#!/usr/bin/env bash
response=\$(mysql -u "$2" -h '192.168.23.10' -p"$1" -e "select 'serverup'")

if [[ "\${response}" == *"serverup"* ]];
then
  echo "Mysql is up"
  /bin/java -Xms128m -Xmx256m -Dspring.profiles.active=mysql -jar /home/vagrant/demo1/target/spring-petclinic-2.3.1.BUILD-SNAPSHOT.jar
else
  echo "Mysql is down"
  /bin/java -Xms128m -Xmx256m -jar /home/vagrant/demo1/target/spring-petclinic-2.3.1.BUILD-SNAPSHOT.jar
fi

EOF

sudo chown demo_user:demo_user /home/vagrant/petclinic.sh
sudo chmod +x /home/vagrant/petclinic.sh

sudo systemctl daemon-reload
sudo systemctl enable petclinic.service
sudo systemctl start petclinic

