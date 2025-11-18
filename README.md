# `Дипломный практикум в Yandex.Cloud` - `Сулименков Алексей`

- [Цели:](#цели)
- [Этапы выполнения:](#этапы-выполнения)
  - [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
  - [Создание Kubernetes кластера](#создание-kubernetes-кластера)
  - [Создание тестового приложения](#создание-тестового-приложения)
  - [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
  - [Установка и настройка CI/CD](#установка-и-настройка-cicd)
- [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
- [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---

## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---

## Этапы выполнения:

### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
  Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://developer.hashicorp.com/terraform/language/backend) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант: [Terraform Cloud](https://app.terraform.io/)
3. Создайте конфигурацию Terrafrom, используя созданный бакет ранее как бекенд для хранения стейт файла. Конфигурации Terraform для создания сервисного аккаунта и бакета и основной инфраструктуры следует сохранить в разных папках.
4. Создайте VPC с подсетями в разных зонах доступности.
5. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
6. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://developer.hashicorp.com/terraform/language/backend) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий, стейт основной конфигурации сохраняется в бакете или Terraform Cloud
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---

### Ответ

Чуствительные переменные хранятся в backend-config.tfvars

![s3_tf-backend](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/s3_tf-backend.png "s3_tf-backend")
![subnet](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/subnet.png "subnet")

---

### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры. Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
   а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях  
   б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)

Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---

### Ответ

Чуствительные переменные хранятся в backend-config.tfvars. Использовались kubeadm, CNI cilium, для запуска контейнеров CRI-O, с containerd что-то не срослось в YC..

![kubeconf](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/kubeconf.png "kubeconf")
![kubectl_get](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/kubectl_get.png "kubectl_get")

---

### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---

### Ответ

Залил в отдельный репозиторий, потребуется в дальнейшем. https://github.com/biparasite/netology-diplom-nginx-docker.git

![dockerhub](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/dockerhub.png "dockerhub")

---

### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:

1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:

1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

---

### Ответ

Деплой выполнялся с помошью ansible, при создании кластера.

![grafana-1](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/grafana-1.png "grafana-1")
![grafana](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/grafana.png "grafana")

---

### Деплой инфраструктуры в terraform pipeline

1. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:

1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ на 80 порту к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ на 80 порту к тестовому приложению.
5. Atlantis или terraform cloud или ci/cd-terraform

---

### Ответ

![deploy_nginx](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/deploy_nginx.png "deploy_nginx")

---

### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---

### Ответ

Я немного изменил подход, pipeline смотрит в git https://github.com/biparasite/netology-diplom-nginx-docker.git если там происходят изменения, то пересобирает образ и пушит изменения values, для helm чарта в другой git https://github.com/biparasite/netology-diplom-k8s-config.git . Далее в дело вступает argocd (FluxCD - не осилил пока), который мониторит на изменения во втором git и делает sync. Сделано для удобства, если кластер помрет, то с помощью argocd можно развернуть все быстро, без ожидания пушей в основной репозирорий.

<details> <summary>jenkins pipeline</summary>

```bash
pipeline {
    agent any
    triggers {

        pollSCM('* * * * *')  
    }
    environment {
        IMAGE_USER = 'biparasite/'
        IMAGE_NAME = 'nginx_static'  
        TAG = "${env.GIT_COMMIT[0..7]}"
    }
    stages {
        stage('Checkout') {
            steps {
                git(
                    url: 'https://github.com/biparasite/netology-diplom-nginx-docker.git',
                    branch: 'main'
                )
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        def app = docker.build("${IMAGE_USER}${IMAGE_NAME}:${TAG}")
                        app.push()
                    }
                }
            }
        }
        stage('Update GitOps Config') {
            steps {
                script {
                    // --- КОНФИГУРАЦИЯ ---
                    def CONFIG_REPO_URL = 'https://github.com/biparasite/netology-diplom-k8s-config.git' 
                    def GIT_CREDENTIALS_ID = 'github-ssh-key-for-push' 
                    def YAML_PATH = 'nginx/values.yaml'
                    def NEW_IMAGE = "${env.TAG}"
                    def PROJECT_PATH = "${WORKSPACE}/netology-diplom-k8s-config"

                    withCredentials([sshUserPrivateKey(credentialsId: 'github-ssh-key-for-push', keyFileVariable: 'GIT_SSH_KEY_FILE', usernameVariable: 'GIT_USER')]) {
                        sh 'rm -rf netology-diplom-k8s-config'
                        sh "git clone ${CONFIG_REPO_URL}"
                        
                        dir('netology-diplom-k8s-config') {
                            sh "git config user.email 'jenkins@ci.local'"
                            sh "git config user.name 'Jenkins GitOps Updater'"
                            sh "git checkout main" // или любая ветка, за которой следит Argo CD
                            
                            sh "sed -i '' 's/${env.IMAGE_NAME}:.*/${env.IMAGE_NAME}:${NEW_IMAGE}/g' ${PROJECT_PATH}/${YAML_PATH }"                          
                            sh 'git add .'
                            sh "git commit -m 'GitOps: Auto-deploy ${NEW_IMAGE} triggered by Jenkins CI'"
                            
                            sh "git push https://github.com/biparasite/netology-diplom-k8s-config.git HEAD:main"
                        }
                    }
                    echo "✅ GitOps Config обновлен до образа: ${NEW_IMAGE}"
                }
            }
        }
    }
    post {
        success {
            echo 'Пайплайн успешно завершён!'
        }
        failure {
            echo 'Ошибка в пайплайне!'
        }
    }
}


```

</details>

<details> <summary>jenkins pipeline log</summary>

```bash
Started by user unknown or anonymous
Replayed #25
[Pipeline] Start of Pipeline
[Pipeline] node
Running on Jenkins in /Users/biparasite/.jenkins/workspace/neology-diplom
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Declarative: Checkout SCM)
[Pipeline] checkout
Selected Git installation does not exist. Using Default
The recommended git tool is: NONE
No credentials specified
 > git rev-parse --resolve-git-dir /Users/biparasite/.jenkins/workspace/neology-diplom/.git # timeout=10
Fetching changes from the remote Git repository
 > git config remote.origin.url https://github.com/biparasite/netology-diplom-nginx-docker.git # timeout=10
Fetching upstream changes from https://github.com/biparasite/netology-diplom-nginx-docker.git
 > git --version # timeout=10
 > git --version # 'git version 2.50.1 (Apple Git-155)'
 > git fetch --tags --force --progress -- https://github.com/biparasite/netology-diplom-nginx-docker.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse origin/main^{commit} # timeout=10
Checking out Revision 3e61befae6e8d6f92a5e95ef028b2ebd465df9d3 (origin/main)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 3e61befae6e8d6f92a5e95ef028b2ebd465df9d3 # timeout=10
Commit message: "Update Jenkinsfile"
 > git rev-list --no-walk 3e61befae6e8d6f92a5e95ef028b2ebd465df9d3 # timeout=10
[Pipeline] }
[Pipeline] // stage
[Pipeline] withEnv
[Pipeline] {
[Pipeline] withEnv
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Checkout)
[Pipeline] git
Selected Git installation does not exist. Using Default
The recommended git tool is: NONE
No credentials specified
 > git rev-parse --resolve-git-dir /Users/biparasite/.jenkins/workspace/neology-diplom/.git # timeout=10
Fetching changes from the remote Git repository
 > git config remote.origin.url https://github.com/biparasite/netology-diplom-nginx-docker.git # timeout=10
Fetching upstream changes from https://github.com/biparasite/netology-diplom-nginx-docker.git
 > git --version # timeout=10
 > git --version # 'git version 2.50.1 (Apple Git-155)'
 > git fetch --tags --force --progress -- https://github.com/biparasite/netology-diplom-nginx-docker.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse refs/remotes/origin/main^{commit} # timeout=10
Checking out Revision 3e61befae6e8d6f92a5e95ef028b2ebd465df9d3 (refs/remotes/origin/main)
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 3e61befae6e8d6f92a5e95ef028b2ebd465df9d3 # timeout=10
 > git branch -a -v --no-abbrev # timeout=10
 > git branch -D main # timeout=10
 > git checkout -b main 3e61befae6e8d6f92a5e95ef028b2ebd465df9d3 # timeout=10
Commit message: "Update Jenkinsfile"
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Build and Push Docker Image)
[Pipeline] script
[Pipeline] {
[Pipeline] withEnv
[Pipeline] {
[Pipeline] withDockerRegistry
Using the existing docker config file.
Removing blacklisted property: auths
$ docker login -u biparasite -p ******** https://registry.hub.docker.com
WARNING! Using --password via the CLI is insecure. Use --password-stdin.

WARNING! Your credentials are stored unencrypted in '/Users/biparasite/.jenkins/workspace/neology-diplom@tmp/fa764d64-e69f-45f0-820e-c081b32e3e6d/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded
[Pipeline] {
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker build -t biparasite/nginx_static:3e61befa .
#0 building with "default" instance using docker driver

#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 782B done
#1 DONE 0.0s

#2 [internal] load metadata for docker.io/library/nginx:alpine
#2 DONE 0.6s

#3 [internal] load .dockerignore
#3 transferring context: 2B done
#3 DONE 0.0s

#4 [1/4] FROM docker.io/library/nginx:alpine@sha256:b3c656d55d7ad751196f21b7fd2e8d4da9cb430e32f646adcf92441b72f82b14
#4 DONE 0.0s

#5 [internal] load build context
#5 transferring context: 2.55kB done
#5 DONE 0.0s

#6 [2/4] RUN rm /etc/nginx/conf.d/default.conf
#6 CACHED

#7 [3/4] COPY default.conf /etc/nginx/conf.d/
#7 CACHED

#8 [4/4] COPY static/ /usr/share/nginx/html/
#8 CACHED

#9 exporting to image
#9 exporting layers done
#9 writing image sha256:5d852330206321fad64365002c196d2a0cbc31c514fa6bfe3b0a704bc9ad58d6 done
#9 naming to docker.io/biparasite/nginx_static:3e61befa done
#9 DONE 0.0s

View build details: docker-desktop://dashboard/build/default/default/asrrmr6ejybjmcpsi801ez453
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker tag biparasite/nginx_static:3e61befa registry.hub.docker.com/biparasite/nginx_static:3e61befa
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker push registry.hub.docker.com/biparasite/nginx_static:3e61befa
The push refers to repository [registry.hub.docker.com/biparasite/nginx_static]
854ca792c2f2: Preparing
841818dccb93: Preparing
87542d6ebce3: Preparing
4c37c07961d9: Preparing
a199459134dc: Preparing
b0fad68f6a9c: Preparing
930a90aa29ed: Preparing
08ea284afe80: Preparing
e664822438ac: Preparing
9aa3e1fc9021: Preparing
0e64f2360a44: Preparing
08ea284afe80: Waiting
930a90aa29ed: Waiting
b0fad68f6a9c: Waiting
e664822438ac: Waiting
0e64f2360a44: Waiting
9aa3e1fc9021: Waiting
4c37c07961d9: Layer already exists
87542d6ebce3: Layer already exists
854ca792c2f2: Layer already exists
a199459134dc: Layer already exists
841818dccb93: Layer already exists
b0fad68f6a9c: Layer already exists
e664822438ac: Layer already exists
930a90aa29ed: Layer already exists
08ea284afe80: Layer already exists
9aa3e1fc9021: Layer already exists
0e64f2360a44: Layer already exists
3e61befa: digest: sha256:76503eb567c155f633741b98acb62d81e14be019a8a45b2e0766fd77bfe8fc64 size: 2611
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withDockerRegistry
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Update GitOps Config)
[Pipeline] script
[Pipeline] {
[Pipeline] withCredentials
Masking supported pattern matches of $GIT_SSH_KEY_FILE
[Pipeline] {
[Pipeline] sh
+ rm -rf netology-diplom-k8s-config
[Pipeline] sh
+ git clone https://github.com/biparasite/netology-diplom-k8s-config.git
Cloning into 'netology-diplom-k8s-config'...
[Pipeline] dir
Running in /Users/biparasite/.jenkins/workspace/neology-diplom/netology-diplom-k8s-config
[Pipeline] {
[Pipeline] sh
+ git config user.email jenkins@ci.local
[Pipeline] sh
+ git config user.name 'Jenkins GitOps Updater'
[Pipeline] sh
+ git checkout main
Already on 'main'
Your branch is up to date with 'origin/main'.
[Pipeline] sh
+ sed -i '' 's/nginx_static:.*/nginx_static:3e61befa/g' /Users/biparasite/.jenkins/workspace/neology-diplom/netology-diplom-k8s-config/nginx/values.yaml
[Pipeline] sh
+ git add .
[Pipeline] sh
+ git commit -m 'GitOps: Auto-deploy 3e61befa triggered by Jenkins CI'
[main 7f7b4b5] GitOps: Auto-deploy 3e61befa triggered by Jenkins CI
 1 file changed, 1 insertion(+), 1 deletion(-)
[Pipeline] sh
+ git push https://github.com/biparasite/netology-diplom-k8s-config.git HEAD:main
To https://github.com/biparasite/netology-diplom-k8s-config.git
   25137c0..7f7b4b5  HEAD -> main
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // withCredentials
[Pipeline] echo
✅ GitOps Config обновлен до образа: 3e61befa
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Declarative: Post Actions)
[Pipeline] echo
Пайплайн успешно завершён!
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS

```

</details>


![jenkins](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/jenkins.png "jenkins")


### ArgoCD

![argocd-1](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/argocd-1.png "argocd-1")

![argocd](https://github.com/biparasite/devops-diplom-netology/blob/main/pic/argocd.png "argocd")

---

## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)
