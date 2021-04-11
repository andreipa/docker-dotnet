FROM centos:7
# install sudo and dotnet sdk
RUN yum install sudo -y
RUN sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
RUN yum install epel-release -y
RUN yum install dnf -y
RUN sudo dnf install dotnet-sdk-3.1 -y

# copy app files over
#COPY ["./publish/", "/var/www/helloapp/publish/"]

# install apache and enable it
RUN sudo yum -y install httpd mod_ssl
RUN systemctl enable httpd.service
RUN yum install initscripts -y
RUN sudo service httpd configtest

# Install important libraries
RUN yum install -y \
    git \
    mailx \
    postfix \
    vim \
    telnet \
    rsyslog
RUN systemctl enable postfix.service
RUN systemctl enable rsyslog

# Configure MailHog
RUN curl -Lsf 'https://storage.googleapis.com/golang/go1.15.6.linux-amd64.tar.gz' | tar -C '/usr/local' -xvzf -
ENV PATH /usr/local/go/bin:$PATH
RUN go get github.com/mailhog/mhsendmail
RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail
RUN mkfifo /var/spool/postfix/public/pickup

# copy and enable service file
#COPY ["./kestrel-helloapp.service", "/etc/systemd/system/"]
#RUN sudo systemctl enable kestrel-helloapp.service

# Fully qualified domain name configuration on localhost.
RUN echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf

RUN echo "include /etc/httpd/conf/vhosts/*.conf" >> /etc/httpd/conf/httpd.conf

# Configuration postfix
#RUN echo "myhostname = localhost" >> /etc/postfix/main.cf
#RUN echo "relayhost = 127.0.0.1:1025" >> /etc/postfix/main.cf
#RUN echo "default_transport = smtp" >> /etc/postfix/main.cf
#RUN echo "inet_interfaces = 127.0.0.1" >> /etc/postfix/main.cf
#RUN echo "inet_protocols = ipv4" >> /etc/postfix/main.cf

RUN mail -s "This is the subject" somebody@example.com <<< 'This is the message'

# start apache
CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["/usr/sbin/httpd"]