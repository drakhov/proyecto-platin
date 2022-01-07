#!/bin/bash
main_class=$1
final_name=$2
properties=$3
deploy_type=$4

[ -z "$main_class" ] && { echo "Failed: MAIN_CLASS EMPTY"; exit 1; }
[ -z "$final_name" ] && { echo "Failed: FINAL_NAME EMPTY"; exit 1; }
[ -z "$final_name" ] && { echo "Failed: PROPERTIES EMPTY"; exit 1; }
[ -z "$final_name" ] && { echo "Failed: DEPLOY_TYPE EMPTY"; exit 1; }

proyect_path="$HOME/backend/BackendPlatin/platin"
steps=("install_os_dependency" "build_artifact" "deploy_service")
jar_name=""
jar_path=""
service_name="platin-$deploy_type-$final_name.service"
jar_rename="$final_name.jar"
deploy_path="/opt/deploys/platin/$deploy_type"

deploy_build_abs_path=$deploy_path/$jar_rename
config_path="$deploy_path/config"
sudo mkdir $deploy_path -p
sudo mkdir $config_path -p
sudo touch $config_path/$properties

echo "***********************************************************"
echo "Starting bash scripts deploy.sh"
echo "$main_class"
echo "$final_name"
echo "current scripts expect to run ${steps[@]} steps succefully"
echo "***********************************************************"

install_os_dependency() {
  echo "Installing os dependency"
  sudo apt update -y && { echo "Successful: OS UPDATE"; } || { echo "Failed: OS UPDATE"; exit 1; }
  echo "Installing default-jdk"
  sudo apt-get install default-jdk -y && { echo "Successful: install of defaul-jdk"; } || { echo "Failed: install default-jdk"; exit 1; }
  if [[ -z $JAVA_HOME ]]; then
    echo "Setup JAVA_HOME Enviroment variable"
    javapath=`which java`
    echo "JAVA_HOME=/usr" >> /etc/environment
    source /etc/environment
    echo $javapath  
  fi
  echo "JAVA COMPLETE INSTALL CURRENT PATH: $JAVA_HOME"
  sudo apt install maven -y && { echo "Successful: install of maven"; } || { echo "Failed: install maven"; exit 1; }
  echo "SUCCESSFUL OS DEPENDENCY INSTALLED"
}

build_artifact() {
  echo "ARTIFACT BUILDING STARTED"
  #cd $proyect_path && git pull && { echo "Successful: GIT PULL"; } || { echo "Failed: GIT PULL"; exit 1; }
  cd $proyect_path && cp pom.xml.tmpl ./pom.xml
  sleep 3
  sed -i -e "s|###MAIN_CLASS###|$main_class|g" $proyect_path/pom.xml
  sleep 1
  sed -i -e "s|###FINAL_NAME###|$final_name|g" $proyect_path/pom.xml
  cd $proyect_path && mvn clean package -DskipTests && { echo "Successful: BUILDING JAR FILE"; } || { echo "Failed: BUILDING JAR FILE"; exit 1; }
  jar_name=`ls ./target | grep '.jar' | head -1`
  jar_path=`cd ./target && echo $PWD`
  echo "SUCCESSFUL ARTIFACT BUILD"
  echo "ARTIFACT NAME: $jar_name"
  echo "ARTIFACT ABSOLUTE PATH: $jar_path"
}

create_application_service() { 
  echo "APPLICATION SERVICE CREATED STARTED"
  sudo bash -c 'cat > /etc/systemd/system/'"$service_name" << EOF
      [Unit]
      Description=$service_name
      Wants=network.target
      After=network.target

      [Service]
      Restart=on-failure
      RestartSec=20s
      WorkingDirectory=$deploy_path
      ExecStart=${JAVA_HOME}/bin/java -jar $jar_rename --spring.config.location=$config_path/$properties
      ExecReload=/bin/kill -HUP $MAINPID
      KillSignal=SIGINT
      [Install]
      WantedBy=multi-user.target
EOF
  sudo systemctl enable $service_name
  sudo bash -c 'cat /etc/systemd/system/'"$service_name"
}

deploy_service() {
  echo "APPLICATION DEPLOY STARTED"
  if [ ! -f "/etc/systemd/system/$service_name" ]; then
    create_application_service
  fi
  if [ -f "$deploy_build_abs_path" ]; then
    echo "DELETE DEPLOY SYMLINK:  $deploy_build_abs_path"
    sudo rm $deploy_build_abs_path
  fi
  echo "COPY FILE JAR: $jar_path/$jar_name -> $deploy_build_abs_path"
  #echo "CREATE NEW SYMLINK: $jar_path/$jar_name -> $deploy_build_abs_path"
  #sudo ln -sf "$jar_path/$jar_name" $deploy_build_abs_path
  sudo cp $jar_path/$jar_name $deploy_build_abs_path
  echo "RESTARTING SERVICE: $service_name"
  #sudo systemctl restart $service_name
}

for i in "${steps[@]}" 
do
  echo "RUNNING STEP ($i)"
  if [ $i == "install_os_dependency" ]; then
    install_os_dependency
  elif [ $i == "build_artifact" ]; then
    build_artifact
  else
    deploy_service
  fi
  echo "***********************************************************"
done
