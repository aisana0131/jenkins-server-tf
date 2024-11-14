#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Hello World ! I am very happy to code in Terraform ! </h1> " > /var/www/html/index.html
echo "<img src="https://opensenselabs.com/sites/default/files/inline-images/terraform.png" alt="Image description" />" >> /var/www/html/index.html