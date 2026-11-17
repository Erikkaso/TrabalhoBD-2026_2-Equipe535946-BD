# Trabalho Final – Banco de Dados 2026.2

Controle de biblioteca acadêmica – UFC Sobral, Engenharia da Computação.

**Equipe 535946**

| Membro | Matrícula |
|---|---|
| Giovanna dos Santos Marques | 536930 |
| Iarley Cavalcante Tavares Balreira | 535946 |
| Pedro Eric Carneiro | 538121 |

## Etapa 1

- `modelagem/equipe535946.mwb`: modelo do MySQL Workbench
- `scripts/01_criacao.sql`: criação do banco `equipe535946`
- `scripts/02_povoamento.sql`: povoamento

```bash
mysql -u root -p < scripts/01_criacao.sql
mysql -u root -p < scripts/02_povoamento.sql
```

MySQL 5.7 ou superior.

## Acessos

| Nível | Usuário | Senha |
|---|---|---|
| Administrador | `Admin` | `Root` |
| Bibliotecário | `bibliotecario` | `Biblioteca` |
| Usuário | `usuario` | `Usuario` |
