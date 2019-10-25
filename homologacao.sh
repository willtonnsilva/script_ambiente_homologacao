#!/bin/bash

serve1="/home/desenvolvimento/servers/1-apache-tomcat-8.5.20"
serve2="/home/desenvolvimento/servers/2-apache-tomcat-8.5.20"
client="/home/desenvolvimento/servers/3-apache-tomcat-8.5.20"
activeMQ="/home/desenvolvimento/servers/apache-activemq-5.5.1/bin/"
serverSelected=$serve1

if [ $# -lt 1 ]; then
   echo "Erro, necessário informar branch para deploy!"
   exit 1
fi

if [ $2 -eq 2 ]
	then
	echo "Conectando ao servidor 2 $serve2 " 
		serverSelected=$server2
	else
		echo "Conectando ao servidor 1 $serve1"
fi

echo "Servidor escolhido com sucesso: $serverSelected" 

echo
	echo "################################################################"
	echo "##                                                            ##"
	echo "##   shutdown no servidor selecionado e apagando pasta ROOT.  ##"
	echo "##                                                            ##"
	echo "################################################################"
echo 

cd
cd $serverSelected/bin

if ! ./shutdown.sh

then 
	echo "Não foi possivel parar o serviço atual do servidor $serverSelected"
	exit 1
fi
	echo "Serviço parado com sucesso"


cd ..
cd webapps/

if ! rm -rf ROOT

then 
	echo "Não foi possivel apagar pasta ROOT do servidor $serverSelected"
	exit 1
fi
	echo "Pasta ROOT do $serverSelected apagado com sucesso"


propertiesBanco=$3

if [ ${#propertiesBanco} -ne 0 ]
then
	
	echo
		echo "###########################################################"
		echo "##                                                       ##"
		echo "##    Alterando configuracoes.properties do banco        ##"
		echo "##                                                       ##"
		echo "###########################################################"
	echo 

	cd ..
	cd syspdvweb_install/
	sed -i 's/syspdvweb.jdbc.username=.*/syspdvweb.jdbc.username='$3'/' configuracoes.properties
	echo "Banco utilizado $3"
else
	echo "configurações de banco não foram alteradas"
fi

echo
	echo "###########################################################"
	echo "##                                                       ##"
	echo "##    Subindo ambiente de homologação do SysPDVWeb.      ##"
	echo "##                                                       ##"
	echo "###########################################################"
echo 

cd
cd $HOME/workspace/syspdvweb/

git checkout master

git pull

echo
	echo "###########################################"
	echo "##                                       ##"
	echo "##    Mudando para a branch escolhida.   ##"
	echo "##                                       ##"
	echo "###########################################"
echo

git checkout $1

if ! git pull origin $1

then 
	echo "Não foi possivel atualizar a branch"
	exit 1
fi
	echo "Atualizacao feita com sucesso"

echo
	echo "###########################################"
	echo "##                                       ##"
	echo "##    Gerando war da branch.             ##"
	echo "##                                       ##"
	echo "###########################################"
echo

if ! ant war
then	
	echo " Não foi possivel gerar o War do SysPDVWeb"
	exit 1
fi
	echo "War do SysPDVWeb gerado com sucesso"

echo
	echo "###################################################################"
	echo "##                                                               ##"
	echo "##    Copiando o arquivo War para a pasta do tomcat.             ##"
	echo "##                                                               ##"
	echo "###################################################################"
echo

cd target/war

if ! cp SysPDVWeb.war $serverSelected/webapps/ROOT.war
then 
	echo " Não foi possivel mover o arquivo para o servidor  $serverSelected"
	exit 1
fi
  echo " arquivo movido com sucesso para o tomcat $serverSelected"

echo
	echo "###################################################################"
	echo "##                                                               ##"
	echo "##            Gerando war do SysPDVWebClient.                    ##"
	echo "##                                                               ##"
	echo "###################################################################"
echo

cd ..
cd ..
cd SysPDVWebClient/

if ! ant war
then	
	echo " Não foi possivel gerar o WAR do SysPDVWebClient"
	exit 1
fi
	echo "War do SysPDVWebClient gerado com sucesso"

cd target/war

if ! cp SysPDVWebClient.war $client/webapps/
then 
	echo " Não foi possivel mover o arquivo para o server do SysPDVWebClient "
	exit 1
fi
  echo " Arquivo movido com sucesso para o tomcat do SysPDVWebClient "

echo
	echo "###################################################################"
	echo "##                                                               ##"
	echo "##            Iniciando o tomcat SysPDVWeb                       ##"
	echo "##                                                               ##"
	echo "###################################################################"
echo

cd
cd $serverSelected/bin

if ! ./startup.sh
then 
	echo " Não foi possivel iniciar o tomcat SysPDVWeb selecionado $serverSelected"
	exit 1
fi
  echo " tomcat $serverSelected iniciado com sucesso"

# echo
# 	echo "###################################################################"
# 	echo "##                                                               ##"
# 	echo "##            Iniciando o tomcat SysPDVWebClient                 ##"
# 	echo "##                                                               ##"
# 	echo "###################################################################"
# echo

# cd
# cd $client

# if ! ./startup.sh
# then 
# 	echo " Não foi possivel iniciar o tomcat SysPDVWebClient"
# 	exit 1
# fi
#   echo " tomcat do SysPDVWeb iniciado com sucesso"

echo
	echo "###################################################################"
	echo "##                                                               ##"
	echo "##                    Iniciando o activeMQ                       ##"
	echo "##                                                               ##"
	echo "###################################################################"
echo

cd
cd $activeMQ

if ! java -jar run.jar start
then 
	echo " Não foi possivel iniciar o tomcat ActiveMQ"
	exit 1
fi
  echo " tomcat do ActiveMQ iniciado com sucesso"