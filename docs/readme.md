# Práctica Jenkins

## Crear una imagen de Jenkins

Antes que nada, necesitamos crear una imagen de Jenkins en un contenedor Docker. Esto nos permitirá tener un entorno de Jenkins completamente configurado y listo para ser utilizado de manera consistente y reproducible.

El proceso de creación de la imagen de Jenkins implica la definición de un Dockerfile. Este Dockerfile incluirá las configuraciones 
específicas de Jenkins, como la instalación de plugins, herramientas adicionales y configuraciones del entorno.

El Dockerfile tendrá la siguiente estructura:
```
FROM jenkins/jenkins 
USER root 
RUN apt-get update && apt-get install -y lsb-release 
RUN apt-get update && apt-get install -y --no-install-recommends \
binutils ca-certificates curl git python3 python3-venv python3-pip python3-setuptools python3-wheel python3-dev wget \
&& rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/python3 /usr/bin/python
# Crea el entorno virtual y activa el script de activación
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install docker-py feedparser nosexcover prometheus_client pycobertura pylint pytest pytest-cov requests setuptools sphinx pyinstaller
RUN echo "PATH=${PATH}" >> /etc/environment
# Instala PyInstaller dentro del entorno virtual
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \ 
    https://download.docker.com/linux/debian/gpg 
RUN echo "deb [arch=$(dpkg --print-architecture) \ 
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \ 
    https://download.docker.com/linux/debian \ 
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list 
RUN apt-get update && apt-get install -y docker-ce-cli 
USER jenkins 
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
```
Una vez que tengamos nuestro Dockerfile listo, podemos construir la imagen de Jenkins utilizando el 
comando `docker build . jenkins-blueocean`. Este comando leerá el Dockerfile y generará una imagen Docker 
que contiene Jenkins y todas las personalizaciones que hayamos especificado.

Una vez que la imagen se haya construido con éxito, podemos crear y 
ejecutar contenedores Docker basados en esta imagen utilizando el comando siguiente:
```
docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean
```
Esto iniciará una instancia de Jenkins dentro de un contenedor Docker, listo para ser utilizado.
## Desplegar contenedores con Terraform

Para desplegar los contenedores Docker de Jenkins y Docker-in-Docker (DinD) utilizando Terraform, 
primero necesitamos crear un archivo `main.tf` que contenga la configuración necesaria 
para definir la infraestructura como código.

El archivo `main.tf` contendrá las definiciones de los recursos de Terraform 
necesarios para desplegar los contenedores Docker de Jenkins y DinD. 

Para desplegar contenedores Docker con Terraform, generalmente utilizamos el proveedor [Terraform Docker](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs). 

```terraform

provider "docker" {
  host = "tcp://localhost:2375"
}


resource "docker_container" "docker_in_docker" {
  name  = "docker-in-docker"
  image = "docker:dind"
  privileged = true
  ports {
    internal = 2375
    external = 2375
  }
}


resource "docker_container" "jenkins" {
  name  = "jenkins"
  image = "jenkins:jenkins-blueocean" 
  ports {
    internal = 8080
    external = 8080
  }
  depends_on = [docker_container.docker_in_docker]
}
```
Una vez definida nuestra configuración en `main.tf`, podemos utilizar Terraform para inicializar 
nuestro directorio de trabajo, planificar los cambios y aplicar la configuración para crear nuestros 
recursos de infraestructura. 
Hecho esto, se debería poder ver en el puerto 8080 la imagen de jenkins.

## Creación del Pipeline
Ahora, creamos el pipeline para la aplicación de python en Jenkins. 

**Paso 1**.Entramos en jenkins y seleccionamos `Nueva Tarea`
<div align="center">
  <img src="https://github.com/martaajonees/simple-python-pyinstaller-app/assets/100365874/11e6d3ff-0688-49c9-8185-633b78623b54" alt="Texto alternativo" />
  <p>Figura 1. Creación de nueva tarea </p>
</div>

**Paso 2**.Le ponemos un nombre y seleccionamos el tipo Pipeline
<div align="center">
  <img width = "50%" src="https://github.com/martaajonees/simple-python-pyinstaller-app/assets/100365874/3cf8cf3d-e43d-4041-a5b1-5b6a94ec821f" alt="Texto alternativo" />
  <p>Figura 2. Configuración Pipeline </p>
  </div>

**Paso 3**. Elegimos el el repositorio Git donde se encuentre el jenkinsfile 
<div align="center">
  <img width = "50%" src="https://github.com/martaajonees/simple-python-pyinstaller-app/assets/100365874/22735107-8c40-4337-8258-3f04f96176d2" alt="Texto alternativo" />
  <p>Figura 3. Configuración del entorno Git </p>
  </div>
  
**Paso 4** Lo ejecutamos y vemos que la aplicación ha sido ejecutada con éxito
  <div align="center">
  <img width = "50%" src="https://github.com/martaajonees/simple-python-pyinstaller-app/assets/100365874/eb1bbf0c-1496-4492-922a-225f733634f7" alt="Texto alternativo" />
  <p>Figura 4. Ejecución Pipeline </p>
  </div>

