#!/bin/bash
yum update -y
yum install wget unzip -y
yum -y install epel-release
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install yum-utils -y
yum-config-manager --enable remi-php72

yum install make gcc libpng-devel -y

yum -y localinstall https://www.linuxglobal.com/static/blog/pdftk-2.02-1.el7.x86_64.rpm

yum install php-cli php-common php-pear php-pdo_pgsql php-fpm php-soap php-ldap php-gd php-mbstring php-mysqlnd php-mcrypt php-zip php-fileinfo php-curl php-xml -y
#yum list installed | grep "php-cli.x86_64" | grep -c "7.2.12-1.el7.remi"
yum install -y php-soap
yum install -y php-ldap
yum install -y php-imap
yum remove -y git*
yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.7-1.x86_64.rpm
yum install -y git


echo "start"
cd /home/$admin_user
mkdir agent
cd agent

echo "Downloading... az agent Release vsts-agent-$agent_dist-$AGENTRELEASE.tar.gz appears to be latest" >> output.log
wget -O agent.tar.gz "https://vstsagentpackage.azureedge.net/agent/$AGENTRELEASE/vsts-agent-$agent_dist-$AGENTRELEASE.tar.gz"
tar zxvf agent.tar.gz
chmod -R 777 .
echo "extracted" >> output.log
./bin/installdependencies.sh
echo "installed dependencies" >> output.log
echo "calling ./config.sh --unattended --url $devops_url --auth pat --token $pat --pool $pool --agent $agent --acceptTeeEula --work ./_work --runAsService" >> output.log
./config.sh --unattended --url $devops_url --auth pat --token $pat --pool $pool --agent $agent --acceptTeeEula --work ./_work --runAsService >> output.log
echo "configuration done" >> output.log
./svc.sh install >> output.log
echo "service installed" >> output.log
./svc.sh start >> output.log
echo "service started" >> output.log
echo "config done" >> output.log
exit 0

