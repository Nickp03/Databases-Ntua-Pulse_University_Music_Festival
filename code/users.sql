CREATE USER 'admin'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;