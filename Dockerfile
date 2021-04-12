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
    vim \
    telnet \
    net-tools \
    rsyslog
RUN systemctl enable rsyslog
RUN yum -y --enablerepo=extras install epel-release
RUN yum -y install ssmtp --enablerepo=epel

# Configure MailHog
RUN curl -Lsf 'https://storage.googleapis.com/golang/go1.15.6.linux-amd64.tar.gz' | tar -C '/usr/local' -xvzf -
ENV PATH /usr/local/go/bin:$PATH
RUN go get github.com/mailhog/mhsendmail
RUN cp /root/go/bin/mhsendmail /usr/bin/mhsendmail

# copy and enable service file
#COPY ["./kestrel-helloapp.service", "/etc/systemd/system/"]
#RUN sudo systemctl enable kestrel-helloapp.service

# Fully qualified domain name configuration on localhost.
RUN echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf
RUN echo "include /etc/httpd/conf/vhosts/*.conf" >> /etc/httpd/conf/httpd.conf

RUN echo "LoadModule proxy_module modules/mod_proxy.so" >> /etc/httpd/conf/httpd.conf
RUN echo "LoadModule proxy_http_module modules/mod_proxy_http.so" >> /etc/httpd/conf/httpd.conf

# Configuration postfix
RUN echo "mailhub=mailhog:1025" >> /etc/ssmtp/ssmtp.conf
RUN echo "hostname=$(hostname -f)" >> /etc/ssmtp/ssmtp.conf
RUN echo "FromLineOverride=yes" >> /etc/ssmtp/ssmtp.conf
#Send email test
#RUN echo test | ssmtp -v username@somedomain.com

#RUN
#RUN ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' 
#RUN ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
#RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N ''
#RUN sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
#RUN sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config

COPY ./default.conf /etc/httpd/conf/vhosts/

# start apache
CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["/usr/sbin/httpd"]