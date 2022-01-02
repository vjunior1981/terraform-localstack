# terraform + localstack

## TL;DR
- Como utilizar [terraform](https://www.terraform.io/) e [localstack](https://localstack.cloud/) para simular um ambiente AWS e praticar IaC.
---

## Preparando o ambiente:
### asdf:
- [`asdf`](https://asdf-vm.com/) é um gerenciador que permite a instalação de múltiplos plugins (e o melhor, com múltiplas versões).
#### Instalando o `asdf`:
```bash
## instalando asdf com git (universal installer):
[vitorjr@0x564a520a ~]$ git clone https://github.com/asdf-vm/asdf.git \
~/.asdf --branch release-v0.10.0

## se você utiliza bash, adicione essas linhas ao seu ~/.bashrc:
# adiciona ao PATH
[vitorjr@0x564a520a ~]$ echo '# loads asdf
. $HOME/.asdf/asdf.sh' | tee -a ~/.bashrc

# carrega o autocomplete
[vitorjr@0x564a520a ~]$ echo '
# loads asdf autocomplete
. $HOME/.asdf/completions/asdf.bash' | tee -a ~/.bashrc

## se você utiliza zsh e NÃO utiliza um framework para plugins:
# (ex.  oh-my-zsh - https://ohmyz.sh/)
[vitorjr@0x564a520a ~]$ echo '# loads asdf
. $HOME/.asdf/asdf.sh' | tee -a ~/.zshrc

# o autocomplete no zsh difere do bash:
[vitorjr@0x564a520a ~]$ echo "# append completions to fpath
fpath=(\${ASDF_DIR}/completions \$fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit" | tee -a ~/.zshrc

## caso você UTILIZE algum framework para plugins:
# verifique se você tem o plugin do asdf (oh-my-zsh):
[vitorjr@0x564a520a ~]$ ls -la $ZSH/plugins/asdf
total 8
drwxr-xr-x   4 vitorjr staff  128 Apr  1  2021 .
drwxr-xr-x 306 vitorjr staff 9792 Nov 30 13:49 ..
-rw-r--r--   1 vitorjr staff  717 Apr  1  2021 README.md
-rw-r--r--   1 vitorjr staff  562 Apr  1  2021 asdf.plugin.zsh

# caso não utilize oh-my-zsh, ainda assim é possível copiar o plugin aqui:
# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/asdf/asdf.plugin.zsh
# edite seu ~/.zshrc e adicione a entrada dentro da sessão de plugins:
plugins=(
    ...
    asdf
    ...
    )
```
#### Adicionando **plugins** (instalações) ao `asdf`:
- Eu utilizo, hoje, 39 plugins no total. [Lista](https://github.com/asdf-vm/asdf-plugins) de todos disponíveis.
- Vou demonstrar a instalação de dois: [`python`](https://github.com/danhper/asdf-python) (o `localstack` é instalado via `pip`) e [`terraform`](https://github.com/asdf-community/asdf-hashicorp):
```bash
## adicionar o plugin python:
[vitorjr@0x564a520a ~]$ asdf plugin-add python
updating plugin repository...HEAD is now at 071e261 chore: format README.md

## instalar versão desejada do python:
# para ver todas as versões disponíveis execute:
# [vitorjr@0x564a520a ~]$ asdf list all python
[vitorjr@0x564a520a ~]$ asdf install python 3.8.12
python-build 3.8.12 /Users/vitorjr/.asdf/installs/python/3.8.12
python-build: use openssl@1.1 from homebrew
python-build: use readline from homebrew
Downloading Python-3.8.12.tar.xz...
-> https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tar.xz
Installing Python-3.8.12...
python-build: use tcl-tk from homebrew
python-build: use readline from homebrew
python-build: use zlib from xcode sdk
Installed Python-3.8.12 to /Users/vitorjr/.asdf/installs/python/3.8.12

# para tornar essa instalação 'global', ou seja
# será a primeira referência no seu PATH, antes mesmo
# de qualquer instalação do sistema:
[vitorjr@0x564a520a ~]$ asdf global python 3.8.12

# as versões ficam registradas em um arquivo no seu home ~/.
[vitorjr@0x564a520a ~]$ grep python ~/.tool-versions
python 3.8.12

## instalar múltiplas versões de terraform:
# adicionar o plugin terraform:
[vitorjr@0x564a520a ~]$ asdf plugin-add terraform

# instalando a última versão disponível:
[vitorjr@0x564a520a ~]$ asdf install terraform latest
Downloading terraform version 1.1.2 from ...
... output suprimido
Extracting terraform archive

# instalando uma versão específica:
[vitorjr@0x564a520a ~]$ asdf install terraform 0.15.5
Downloading terraform version 0.15.5 from ...
... output suprimido
Extracting terraform archive

# definindo sua versão global (default) de terraform:
[vitorjr@0x564a520a ~]$ asdf global terraform 1.1.2

# verificando a versão atual do terraform e de onde ele está sendo chamado:
[vitorjr@0x564a520a ~]$ terraform --version
Terraform v1.1.2
on darwin_amd64
[vitorjr@0x564a520a ~]$ type -p terraform
terraform is /Users/vitorjr/.asdf/shims/terraform

## alternando entre versões do terraform:
# escopo local: dentro da pasta que você executar esse comando
# a versão do terraform ficará ancorada a ela.
# ex: na pasta /tmp minha versão é 1.1.2 mas na pasta /tmp/teste-versao
# eu gostaria de utilizar a versão antiga do terraform:
[vitorjr@0x564a520a ~]$ cd /tmp
[vitorjr@0x564a520a ~]$ mkdir teste-versao
[vitorjr@0x564a520a ~]$ pwd
/tmp
[vitorjr@0x564a520a ~]$ terraform --version
Terraform v1.1.2
on darwin_amd64
[vitorjr@0x564a520a ~]$ cd teste-versao
[vitorjr@0x564a520a ~]$ asdf local terraform 0.15.5
[vitorjr@0x564a520a ~]$ terraform --version
Terraform v0.15.5
on darwin_amd64

Your version of Terraform is out of date! The latest version
is 1.1.2. You can update by downloading from https://www.terraform.io/downloads.html

# esse controle é feito através de um arquivo criado na pasta:
[vitorjr@0x564a520a ~]$ cat .tool-versions
terraform 0.15.5

# escopo shell atual:
# não importando a pasta que você está, se quiser alterar
# a versão no shell atual, execute: asdf shell terraform <version>:
## para retornar a versão global:
# encerre a sessão ou execute novamente seu shell - bash, zsh, etc...)
[vitorjr@0x564a520a ~]$ terraform --version
Terraform v1.1.2
on darwin_amd64
[vitorjr@0x564a520a ~]$ asdf shell terraform 0.15.5
[vitorjr@0x564a520a ~]$ terraform --version
Terraform v0.15.5
on darwin_amd64
```
### awscli:
- [`awscli`](https://github.com/aws/aws-cli) é a linha de comando para interação com a API AWS.
#### Instalando o `awscli`:
```bash
# instalando a última versão do pip:
[vitorjr@0x564a520a ~]$ which python3
/Users/vitorjr/.asdf/shims/python3
[vitorjr@0x564a520a ~]$ curl -fsSl https://bootstrap.pypa.io/get-pip.py|python3 --
Collecting pip
  Using cached pip-21.3.1-py3-none-any.whl (1.7 MB)
Collecting wheel
  Using cached wheel-0.37.1-py2.py3-none-any.whl (35 kB)
Installing collected packages: wheel, pip
  Attempting uninstall: pip
    Found existing installation: pip 21.1.1
    Uninstalling pip-21.1.1:
      Successfully uninstalled pip-21.1.1
Successfully installed pip-21.3.1 wheel-0.37.1
## atualizando a localização dos pacotes baixados por uma
# instalação asdf:
# esta operação deve ser feita sempre que um pacote de um plugin
# for instalado. ex:
# pip - python
# gem - ruby
# go get - golang
# etc...
[vitorjr@0x564a520a ~]$ asdf reshim python
## instalando o localstack e atualizando a localização do pacote:
[vitorjr@0x564a520a ~]$ pip install awscli
Collecting awscli
... output suprimido
[vitorjr@0x564a520a ~]$ asdf reshim python
# verificando se a instalação está ok:
[vitorjr@0x564a520a ~]$ aws --version
aws-cli/2.4.7 Python/3.9.9 Darwin/21.2.0 source/x86_64 prompt/off
# configurando uma conta local para uso com o localstack:
# (as credenciais podem ser qualquer valor)
# (pode ser alterada a região e formato de output)
[vitorjr@0x564a520a ~]$ aws configure --profile=localstack
AWS Access Key ID [****************tack]: localstack
AWS Secret Access Key [****************tack]: localstack
Default region name [us-west-2]: us-west-2
Default output format [json]: json
```

### localstack:
- [`localstack`](https://localstack.cloud/) é um framework que ajuda no desenvolvimento de aplicações com foco em cloud, simulando um ambiente AWS.
#### Instalando o `localstack` e `awscli-local`:
- Antes de instalar o `localstack` é necessário ter o [docker instalado e rodando](https://docs.docker.com/engine/install/).
- [`awscli-local`](https://github.com/localstack/awscli-local) é um pacote disponibilizado pelo `localstack` para facilitar o uso da 'cloud local'.
```bash
## instalando o localstack e atualizando a localização do pacote:
[vitorjr@0x564a520a ~]$ pip install localstack
Collecting localstack
  Using cached localstack-0.13.2.1-py3-none-any.whl (537 kB)
... output suprimido
[vitorjr@0x564a520a ~]$ pip install awscli-local
Collecting awscli-local
  Using cached awscli_local-0.17-py3-none-any.whl
... output suprimido
[vitorjr@0x564a520a ~]$ asdf reshim python
# verificando se a instalação está ok:
[vitorjr@0x564a520a ~]$ localstack --version
0.13.2.1
[vitorjr@0x564a520a ~]$ awslocal --version
aws-cli/1.22.26 Python/3.8.12 Darwin/21.2.0 botocore/1.23.26
# para facilitar a utilização do localstack e awslocal
# crie alias para ambos utilizarem o perfil criado no awscli.
# coloque essas entradas no seu .bashrc ou .zshrc:
alias awslocal='AWS_PROFILE=localstack awslocal'
alias localstack='AWS_PROFILE=localstack localstack'
```
#### Iniciando o `localstack`:
```bash
# a primeira inicialização pode demorar pois é necessário
# baixar a imagem do docker hub:
[vitorjr@0x564a520a ~]$ localstack start -d

     __                     _______ __             __
    / /   ____  _________ _/ / ___// /_____ ______/ /__
   / /   / __ \/ ___/ __ `/ /\__ \/ __/ __ `/ ___/ //_/
  / /___/ /_/ / /__/ /_/ / /___/ / /_/ /_/ / /__/ ,<
 /_____/\____/\___/\__,_/_//____/\__/\__,_/\___/_/|_|

 💻 LocalStack CLI 0.13.2.1

[12:36:43] starting LocalStack in Docker mode 🐳             localstack.py:115
2022-01-02T12:36:43.777:INFO:bootstrap.py...
           preparing environment                             bootstrap.py:707
           configuring container                             bootstrap.py:715
           starting container                                bootstrap.py:721
[12:36:44] detaching                                         bootstrap.py:725

# verificando o status dos serviços
[vitorjr@0x564a520a ~]$ localstack status services
┏━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━┓
┃ Service                  ┃ Status      ┃
┡━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━━━━━┩
│ acm                      │ ✔ available │
│ apigateway               │ ✔ available │
│ cloudformation           │ ✔ available │
│ cloudwatch               │ ✔ available │
│ config                   │ ✔ available │
│ dynamodb                 │ ✔ available │
│ dynamodbstreams          │ ✔ available │
│ ec2                      │ ✔ running   │
... output suprimido
```

#### Criando a primeira estrutura com o terraform:
- Clone este repositório:
```bash
git clone https://github.com/vjunior1981/terraform-localstack.git
```
- Não esqueça de exportar as variáveis necessárias para garantir o uso do `localstack`:
```bash
# nem todas variáveis aqui são necessárias, no entanto, gosto de exportar para garantir:
[vitorjr@0x564a520a ~]$ cd terraform-localstack
[vitorjr@0x564a520a ~]$ export AWS_DEFAULT_REGION="us-west-2"
[vitorjr@0x564a520a ~]$ export AWS_PROFILE="localstack"
[vitorjr@0x564a520a ~]$ export AWS_ACCESS_KEY_ID=${AWS_PROFILE}
[vitorjr@0x564a520a ~]$ export AWS_SECRET_ACCESS_KEY=${AWS_PROFILE}
[vitorjr@0x564a520a ~]$ export TF_VAR_aws_access_key=${AWS_PROFILE}
[vitorjr@0x564a520a ~]$ export TF_VAR_aws_secret_key=${AWS_PROFILE}
```
- Existe um arquivo nesse repositório chamado `.envrc`, ele é utilizado pelo [`direnv`](https://github.com/asdf-community/asdf-direnv) para carregar as variáveis automaticamente. Se desejar que isso ocorra, instale o `direnv` (pode ser via `asdf`) e verifique a documentação de como utilizar o mesmo.
- Inicialize, formate, valide, planeje e aplique seus arquivos de configuração com o `terraform`:
  - Adicionei o arquivo `.terraform.lock.hcl` ao `.gitignore` apenas nesse repositório.
  - A boa prática é manter esse arquivo versionado, pois ele que controla o lock de versões de providers utilizados.
```bash
[vitorjr@0x564a520a ~]$ cd terraform-example
[vitorjr@0x564a520a ~]$ terraform init
Initializing modules...
... output suprimido
[vitorjr@0x564a520a ~]$ terraform fmt
[vitorjr@0x564a520a ~]$ terraform validate
Success! The configuration is valid.
[vitorjr@0x564a520a ~]$ terraform plan -out=local.tfplan
terraform plan -out=local.tfplan

Terraform used the selected ...
... output suprimido
[vitorjr@0x564a520a ~]$ terraform apply "local.tfplan"
module.vpc.aws_vpc.this[0]: Creating...
... output suprimido
```
- Validando que a estrutura foi criada localmente:
```bash
# com os campos OwnerId retornando "000000000000" sabemos que são recursos locais
[vitorjr@0x564a520a ~]$ awslocal ec2 describe-instances|grep -E '"InstanceId":|"OwnerId":'
                    "InstanceId": "i-f4ddc8482c610ec8d",
                            "OwnerId": "000000000000",
            "OwnerId": "000000000000",
                    "InstanceId": "i-3457355a702152fda",
                            "OwnerId": "000000000000",
            "OwnerId": "000000000000",

[vitorjr@0x564a520a ~]$ awslocal s3 ls
2022-01-02 15:12:48 my-tf-test-bucket
```

### Limpando o ambiete:
- A limpeza do ambiente pode ser feita de duas maneiras:
  - `terraform destroy`
  - `localstack stop` - Ao reiniciar o `localstack` a estrutura não estará presente, pois a mesma é efêmera.

### Mais informações, usabilidade, exemplos:
- Verifique o site do [`localstack`](https://localstack.cloud/) e também o [repositório](çhttps://github.com/localstack/localstack) do pacote.
