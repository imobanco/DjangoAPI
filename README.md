# DjangoAPI
Esse repositório é um exercício para praticar conceitos de API utilizando Django DRF.

O projeto consistirá em um gerenciador de notas (memos).

> Utilizar Evernote e Google Keep como referências

# Requisitos De Domínio
## Usuários
Deverá existir a entidade `Usuario` contendo dados para autenticação (login e senha).

Haverão multiplos usuários utilizando a plataforma. 

Considerando a GLPD, os dados dos usuários não devem ser visualizados por outros usuários!

### Bonus
Permitir fazer autenticação com redes sociais. Por exemplo, fazer login com Google por!

## Notas
Deverá existir a entidade `Nota` contento o texto da nota!

Cada usuário poderá cadastrar suas notas como públicas ou privadas.
Dessa forma fornecendo um meio de pesquisar por "minhas notas" e "notas públicas"!

### Bonus
Permitir que usuários compartilhem notas particulares com outros usuários. Tendo controle sobre permissão de:
- leitura apenas
- leitura e edição

# Requisitos Técnicos
## API
Fornecer uma API com métodos de interação que possibilite a criação de um frontend para usufruir de TODOS os recursos necessários para a utilização do projeto.

## Banco de Dados
Utilizar PostgreSQL

## Containers
Utilizar Podman para rodar o projeto

## Arquitetura do projeto
Utilizar a arquitetura convencional do DRF
