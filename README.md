# GENIACS — GenieACS em Docker Compose

Este repositório empacota o **GenieACS** em uma stack Docker Compose com MongoDB, serviços CWMP, NBI, FS e interface web. A estrutura foi corrigida para construir o GenieACS diretamente a partir de `genieacs-master.zip`, separar os processos principais em containers próprios e remover configurações inseguras como credenciais `admin/admin` declaradas em arquivo de ambiente.

A stack detecta automaticamente se a CPU possui suporte a **AVX**. Em máquinas com AVX, ela usa MongoDB 6.0; em máquinas sem AVX, usa MongoDB 4.4. A porta do MongoDB não é exposta no host por padrão, reduzindo a superfície de ataque.

A interface web recebeu uma camada visual customizada em `genieacs-ui-overrides/`, aplicada automaticamente no build da imagem Docker. O redesign mantém as rotas e funcionalidades originais do GenieACS, mas moderniza o layout com tema claro, cartões, navegação em português, tela de login profissional, tabelas mais legíveis e ajustes responsivos inspirados em painéis ACS atuais.

## Como subir em servidor Ubuntu/Debian

Se o servidor ainda não tem Docker instalado, use o instalador. Ele instala dependências, configura o timezone como `America/Bahia`, habilita o Docker e chama o script de subida da stack.

```bash
git clone https://github.com/Br10Consultoria/GENIACS.git
cd GENIACS
sudo chmod +x install.sh scripts/manage.sh
sudo ./install.sh
```

Se o Docker já estiver instalado, não é necessário executar o instalador. Basta usar o script de gerenciamento do projeto.

```bash
git clone https://github.com/Br10Consultoria/GENIACS.git
cd GENIACS
chmod +x scripts/manage.sh
./scripts/manage.sh up
```

Na primeira execução, o script cria automaticamente o arquivo `.env` a partir de `.env.example` e gera um `GENIEACS_UI_JWT_SECRET` forte. Esse arquivo **não deve ser enviado ao Git**, pois contém segredo local.

## URLs e portas padrão

| Serviço | Porta padrão | Exposição padrão | Finalidade |
|---|---:|---|---|
| Interface web | `3000` | `0.0.0.0` | Administração visual do GenieACS |
| CWMP | `7547` | `0.0.0.0` | Comunicação TR-069/CPE |
| FS | `7567` | `0.0.0.0` | Servidor de arquivos do GenieACS |
| NBI | `7557` | `127.0.0.1` | API norte do GenieACS, restrita ao próprio servidor |
| MongoDB | `27017` | Não exposta | Banco interno da stack |

Após subir, acesse a interface web em:

```text
http://IP_DO_SERVIDOR:3000
```

## Atualizar uma instalação existente

Se você já instalou a versão anterior no servidor e quer aplicar a nova interface publicada no GitHub, execute dentro da pasta do projeto:

```bash
cd GENIACS
git pull
./scripts/manage.sh down
./scripts/manage.sh up
```

O comando `up` reconstrói a imagem quando detecta alterações no Dockerfile ou nos arquivos de interface. Se desejar forçar a reconstrução manualmente, use:

```bash
docker compose -f docker-compose.avx.yml build --no-cache genieacs
./scripts/manage.sh up
```

Em servidores sem AVX, troque `docker-compose.avx.yml` por `docker-compose.noavx.yml`.

## Comandos de operação

| Comando | O que faz |
|---|---|
| `./scripts/manage.sh up` | Constrói a imagem e sobe todos os serviços em segundo plano. |
| `./scripts/manage.sh ps` | Mostra containers, portas e estado de saúde. |
| `./scripts/manage.sh logs` | Acompanha os logs em tempo real. |
| `./scripts/manage.sh restart` | Reinicia os serviços sem apagar dados. |
| `./scripts/manage.sh down` | Para a stack sem remover volumes. |
| `./scripts/manage.sh reset` | Remove containers, rede e volumes **somente deste projeto**. |
| `./scripts/manage.sh config` | Renderiza a configuração final do Compose para conferência. |

## Configuração do `.env`

O arquivo `.env` controla portas, binds e segredo JWT. Para ambientes públicos, recomenda-se manter a API NBI ligada apenas em `127.0.0.1` e publicar a interface web atrás de proxy reverso com HTTPS.

```env
TZ=America/Bahia
GENIEACS_UI_JWT_SECRET=valor-gerado-com-openssl-rand-hex-32
UI_BIND=0.0.0.0
UI_PORT=3000
CWMP_BIND=0.0.0.0
CWMP_PORT=7547
FS_BIND=0.0.0.0
FS_PORT=7567
NBI_BIND=127.0.0.1
NBI_PORT=7557
```

Para trocar o segredo JWT manualmente, gere um valor novo com:

```bash
openssl rand -hex 32
```

Depois edite o `.env` e reinicie a stack:

```bash
nano .env
./scripts/manage.sh restart
```

## Principais correções aplicadas

| Área | Antes | Depois |
|---|---|---|
| Build Docker | O Dockerfile da GUI tentava copiar `/gui`, diretório que não existe no ZIP. | A imagem única constrói o GenieACS completo a partir do ZIP e executa CWMP, NBI, FS ou UI conforme o comando do container. |
| Contexto Docker | O backend usava `COPY ../genieacs-master.zip`, inválido quando o contexto era `./genieacs`. | O Compose usa `context: .` e `dockerfile: ./genieacs/Dockerfile`, permitindo copiar corretamente o ZIP. |
| Build do GenieACS | O build falhava porque o código chama comandos Git e o ZIP não contém `.git`. | O Dockerfile cria um repositório Git local temporário, faz commit de snapshot, executa `npm ci` e `npm run build`, e remove `.git` no final. |
| Serviços | CWMP, NBI e FS eram iniciados em background no mesmo container. | Cada serviço roda em container próprio, facilitando logs, restart e healthcheck. |
| Segurança | Havia credenciais `admin/admin` e MongoDB exposto ao host. | Credenciais fracas foram removidas, secret JWT é obrigatório/gerado e MongoDB fica apenas na rede interna. |
| Operação | `reset` executava limpeza global do Docker. | `reset` remove apenas recursos deste projeto. |
| Configuração | Variáveis antigas não eram reconhecidas pelo GenieACS atual. | `config.env` usa variáveis oficiais com prefixo `GENIEACS_`. |
| Interface web | Visual original do GenieACS era técnico, pouco responsivo e sem identidade operacional. | Tema GENIACS com layout claro, menu em português, login moderno, cartões, sombras suaves e responsividade melhorada. |

## Observações de produção

Esta stack deixa o serviço funcional e estruturalmente correto para subir em Docker. Para produção aberta à internet, ainda é recomendável colocar a interface web atrás de um proxy reverso com TLS, restringir as portas por firewall, monitorar logs, criar política de backup do volume `mongo_data` e revisar as permissões de acesso à interface/API conforme a política da empresa.

> O projeto não deve publicar o arquivo `.env`, pois ele contém segredo local. O arquivo `.env.example` existe apenas como modelo seguro.

## Referências

[1]: https://docs.docker.com/compose/ "Docker Compose documentation"
[2]: https://docs.genieacs.com/en/latest/installation-guide.html "GenieACS installation guide"
