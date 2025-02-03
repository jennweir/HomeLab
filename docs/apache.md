# Apache httpd Server

<https://www.redhat.com/en/blog/install-apache-web-server>

`/etc/httpd/conf/httpd.conf` fedora httpd config file

```bash
sudo chown apache:apache /var/www/html/index.html
sudo chmod 644 /var/www/html/index.html
sudo chown apache:apache /var/www/html
sudo chmod 755 /var/www/html
sudo chcon -Rt httpd_sys_content_t /var/www/html # set the context for Apache-served files
sudo semanage fcontext -a -t httpd_sys_content_t "/var/www/html(/.*)?" # update the SELinux policy so it does not reset the label in the future
sudo restorecon -Rv /var/www/html # restores SELinux labels for files in /var/www/html and fixes access
sudo systemctl restart httpd
```

## transfer files to apache server

`scp test.txt root@helper.homelab.jenniferpweir.com:/var/www/html/`

## current apache Listen port is 8080 and this is set in the fedora httpd config file

be sure to prevent firewall from blocking on those ports

```bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```
