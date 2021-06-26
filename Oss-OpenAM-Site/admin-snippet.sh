# hosts
127.0.1.10 dev-admin-portainer.example.com
127.0.1.20 dev-am-lb.example.com
127.0.1.21 dev-am-am1.example.com
127.0.1.22 dev-am-am2.example.com


# admin
# http://dev-admin-portainer.example.com:9000
# http://dev-am-lb.example.com/balancer-manager/
# http://dev-am-am1.example.com:8080/manager
#
# OpenAM
# http://dev-am-am1.example.com:8080/openam
# http://dev-am-am2.example.com:8080/openam
#
# OpenAM-site
# http://dev-am-lb.example.com/openam
# http://dev-am-lb.example.com/openam/XUI/#login/

# run / kill Portainer
docker-compose -f admin-portainer.yml up -d --build
docker-compose -f admin-portainer.yml down

# run / kill LB
docker-compose -f am-lb.yml up -d --build
docker-compose -f am-lb.yml down
docker-compose -f am-lb.yml restart

# run / kill OpenAM (enable JPDA debug)
docker-compose -f am-am1.yml -f openam-debug.yml up -d --build
docker-compose -f am-am1.yml -f openam-debug.yml down
docker-compose -f am-am1.yml -f openam-debug.yml restart
docker volume rm oss-openam-site_am-am1-base-dir

# run / kill OpenAM (enable JPDA debug)
docker-compose -f am-am1.yml -f am-am2.yml -f openam-debug.yml up -d --build
docker-compose -f am-am1.yml -f am-am2.yml -f openam-debug.yml down
docker-compose -f am-am1.yml -f am-am2.yml -f openam-debug.yml restart
docker volume rm oss-openam-site_am-am1-base-dir oss-openam-site_am-am2-base-dir


# download and deploy OpenAM
docker exec -it dev-am-am1 sh -c "curl -L https://github.com/openam-jp/openam/releases/download/14.0.0/openam-14.0.0.war -o /usr/local/tomcat/webapps/openam.war"

# download and deploy OpenAM Java11 compatible module
docker exec -it dev-am-am1 sh -c "mkdir -p /usr/local/tomcat/webapps/openam && curl -L https://github.com/openam-jp/jdk8-compat/releases/download/1.0.0/jdk8-compat-1.0.0.jar -o /usr/local/tomcat/webapps/openam/WEB-INF/lib/jdk8-compat-1.0.0.jar"
docker exec -it dev-am-am2 sh -c "mkdir -p /usr/local/tomcat/webapps/openam && curl -L https://github.com/openam-jp/jdk8-compat/releases/download/1.0.0/jdk8-compat-1.0.0.jar -o /usr/local/tomcat/webapps/openam/WEB-INF/lib/jdk8-compat-1.0.0.jar"

# Pin the contents of the bootstrap.properties file to the correct OpenAM base directory (must be after the initial OpenAM configuration)
docker exec -it dev-am-am1 sh -c "echo 'configuration.dir=/root/openam' > /usr/local/tomcat/webapps/openam/WEB-INF/classes/bootstrap.properties"
docker exec -it dev-am-am2 sh -c "echo 'configuration.dir=/root/openam' > /usr/local/tomcat/webapps/openam/WEB-INF/classes/bootstrap.properties"


# snip
docker logs -f -n 100 dev-am-lb
docker exec -it dev-am-lb sh -c "cat /usr/local/apache2/conf/httpd.conf"

docker exec -it dev-am-am1 /bin/sh
docker exec -it dev-am-am1 sh -c "ls -al /usr/local/tomcat/webapps/"
docker exec -it dev-am-am1 sh -c "ls -al /root/openam/"
docker exec -it dev-am-am1 sh -c "tail -f -n 100 /root/openam/openam/log/* /root/openam/openam/debug/*"
docker exec -it dev-am-am1 sh -c "tail -f -n 100 /usr/local/tomcat/logs/*"
docker exec -it dev-am-am1 sh -c "cat /usr/local/tomcat/server.xml"
