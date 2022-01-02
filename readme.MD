# terraform + localstack

## TL;DR
- Como utilizar [terraform](https://www.terraform.io/) e [localstack](https://localstack.cloud/) para simular um ambiente AWS e praticar IaC.
---

## Preparando o ambiente:
### asdf:
- [`asdf`](https://asdf-vm.com/) é um gerenciador que permite a instalacão de múltiplos plugins (e o melhor, com múltiplas versões).
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
