# Perfil do projeto — Gestor ERP

> Exemplo preenchido, para servir de referência de qualidade.
> Sistema fictício: ERP de gestão comercial de uma software house, em produção
> desde 2016, com módulos de faturamento, fiscal, estoque e financeiro.

Gerado em: 2026-03-11
Atualizado em: 2026-08-14
Região mapeada: módulos de faturamento e fiscal mapeados por completo. Estoque e financeiro mapeados apenas nos pontos de entrada — ver L-06 em `docs/legado/LACUNAS.md`.

---

## 1. Stack e versões reais

| Item | Versão | Lido de |
|---|---|---|
| PHP | 7.4.33 | `Dockerfile` (imagem `php:7.4-fpm`) |
| Laravel | 6.20.44 | `composer.lock` |
| MySQL | 5.7.38 | `docker-compose.yml` |
| jQuery | 1.12.4 | `public/js/vendor/jquery.min.js` (cabeçalho do arquivo) |
| Bootstrap | 3.3.7 | `composer.json` (pacote de tema) |
| PHPUnit | 8.5.21 | `composer.lock` |
| nfephp-org/sped-nfe | 5.0.28 | `composer.lock` |

Versão travada por: `Dockerfile` fixa `php:7.4-fpm`; não há `.tool-versions`. O ambiente local de dois desenvolvedores roda PHP 8.1 e diverge da produção — ver L-02.

---

## 2. Pontos de entrada

### Rotas HTTP
- `routes/web.php` — 214 rotas; módulos de faturamento, fiscal, estoque, financeiro, cadastros
- `routes/api.php` — 18 rotas; consumidas pelo aplicativo de vendas externo
- `app/Http/Controllers/NotaFiscalController.php` — emissão, cancelamento, carta de correção
- `app/Http/Controllers/FaturamentoController.php` — geração de faturas e duplicatas

### Comandos de CLI
- `app/Console/Commands/ReprocessarNotas.php` — reprocessa notas rejeitadas pela SEFAZ
- `app/Console/Commands/FecharCompetencia.php` — fecha a competência do mês

### Jobs e crons
- `app/Console/Kernel.php` — agendamento central
  - `nfe:consultar-status` — a cada 15 minutos
  - `faturamento:gerar-recorrentes` — diariamente às 02:00
  - `fiscal:apuracao-mensal` — dia 1 de cada mês às 03:00
  - `financeiro:baixa-automatica` — diariamente às 05:00

### Filas e workers
- `app/Jobs/TransmitirNotaFiscal.php` — fila `nfe`, transmissão assíncrona à SEFAZ
- `app/Jobs/EnviarBoleto.php` — fila `financeiro`

### Webhooks recebidos
- `app/Http/Controllers/Webhook/BancoController.php` — retorno de conciliação bancária (CNAB)
- `app/Http/Controllers/Webhook/GatewayController.php` — confirmação de pagamento em cartão

### Integrações de saída
- SEFAZ (emissão e consulta de NF-e) — `app/Services/Fiscal/SefazClient.php`
- Banco (remessa CNAB 240) — `app/Services/Financeiro/RemessaService.php`
- Gateway de pagamento — `app/Services/Financeiro/GatewayClient.php`
- Contabilidade do cliente (exportação mensal em CSV) — `app/Services/Fiscal/ExportadorContabil.php`

---

## 3. Camadas que de fato existem

| Camada | Pasta | O que contém de fato | Seguida consistentemente? |
|---|---|---|---|
| Controllers | `app/Http/Controllers/` | roteamento, validação e — em 31 dos 47 arquivos — regra de negócio | não |
| Services | `app/Services/` | regra de negócio dos módulos fiscal e financeiro | apenas nesses dois módulos; estoque e cadastros não têm service |
| Models (Eloquent) | `app/Models/` | mapeamento e, em 9 arquivos, cálculo em accessors | não — cálculo em model é o padrão mais antigo |
| Repositories | `app/Repositories/` | 4 arquivos, criados em 2021 e nunca expandidos | não — tentativa abandonada |
| Views (Blade) | `resources/views/` | telas; 12 delas com cálculo dentro do template | não |
| Procedures MySQL | `database/procedures/` | 6 procedures; apuração fiscal e fechamento | usadas apenas pelo módulo fiscal |

---

## 4. Comandos reais

| Ação | Comando | Fonte |
|---|---|---|
| build | `docker-compose build` | `README.md` |
| teste (suíte inteira) | `./vendor/bin/phpunit` | `composer.json`, script `test` |
| teste de um arquivo só | `./vendor/bin/phpunit --filter <NomeDoTeste> tests/<caminho>` | documentação do PHPUnit 8 |
| lint | `./vendor/bin/php-cs-fixer fix --dry-run` | `.php-cs-fixer.php` (existe, mas não roda no CI) |
| execução local | `docker-compose up -d` | `README.md` |
| migração de banco | `php artisan migrate` | `composer.json`, script `post-update-cmd` |

O pipeline em `.gitlab-ci.yml` roda apenas `./vendor/bin/phpunit --testsuite=Unit` — a suíte de integração não roda no CI desde 2023.

---

## 5. Cobertura de teste verdadeira

Método de medição: `./vendor/bin/phpunit --coverage-text` com Xdebug, executado em 2026-03-11.
Suíte executável neste ambiente: parcialmente — a suíte `Unit` roda; a suíte `Feature` falha em 34 dos 51 testes por dependência de banco não provisionado.

Cobertura global: 22%

| Pasta | Cobertura | Observação |
|---|---|---|
| `app/Services/Fiscal/` | 41% | a melhor do projeto; concentrada no cálculo de ICMS |
| `app/Services/Financeiro/` | 18% | nenhum teste na geração de remessa CNAB |
| `app/Http/Controllers/` | 4% | as 31 controllers com regra de negócio estão descobertas |
| `app/Models/` | 9% | os accessors com cálculo não têm teste |
| `database/procedures/` | 0% | procedures não são exercitadas por nenhum teste |

---

## 6. Padrões conflitantes

| Eixo | Dialeto encontrado | Onde vive | Segue este ao mexer ali |
|---|---|---|---|
| acesso a dados | Eloquent | `app/Models/`, controllers novas | sim |
| acesso a dados | Query Builder | `app/Services/Financeiro/` | sim, nesta pasta |
| acesso a dados | SQL cru em string | `app/Http/Controllers/RelatorioController.php` | sim, nesta pasta — não converta para Eloquent |
| acesso a dados | Stored procedure | `database/procedures/`, chamadas de `app/Services/Fiscal/Apuracao.php` | sim — a apuração depende delas |
| tratamento de erro | Exception + handler central | `app/Services/` | sim |
| tratamento de erro | retorno `false` e `null` silencioso | `app/Models/`, controllers antigas | sim, nesta pasta — mudar a forma de erro muda o comportamento da tela |
| validação | Form Request | controllers criadas após 2020 | sim |
| validação | `Validator::make` inline | controllers anteriores a 2020 | sim, nesta pasta |
| validação | apenas no banco (constraint) | `database/procedures/` | sim |
| injeção de dependência | container do Laravel | `app/Services/Fiscal/` | sim |
| injeção de dependência | `new` direto | `app/Services/Financeiro/`, `app/Models/` | sim, nesta pasta |
| injeção de dependência | facade estática | controllers antigas | sim, nesta pasta |
| data e hora | `Carbon`, gravado em `datetime`, fuso `America/Sao_Paulo` | maior parte do projeto | sim |
| data e hora | `date('Y-m-d')` puro, sem fuso explícito | `app/Services/Financeiro/RemessaService.php` | **atenção**: a remessa depende do formato atual; não converta para Carbon |
| dinheiro | `decimal(15,2)` no banco, `float` em PHP | `app/Services/Fiscal/` | sim — ver o achado D-03 em `DIVIDA.md` |
| dinheiro | inteiro em centavos | `app/Services/Financeiro/GatewayClient.php` | sim, nesta pasta |
| nomenclatura e idioma | português nos models e tabelas | todo o projeto | sim |
| nomenclatura e idioma | inglês nos services criados após 2021 | `app/Services/Fiscal/` | sim, nesta pasta |
| estilo de teste | PHPUnit com `setUp` e fixtures em array | `tests/Unit/` | sim |
| estilo de teste | PHPUnit com factories | `tests/Feature/` | sim, nesta pasta |

Critério de desempate quando duas formas convivem na mesma pasta: a mais recente por histórico do versionador, verificada com `git log`.

---

## 7. Zonas de risco

### Zona: FISCAL

Pastas e arquivos que a compõem:
- `app/Services/Fiscal/`
- `app/Http/Controllers/NotaFiscalController.php`
- `app/Models/NotaFiscal.php`
- `app/Models/ItemNotaFiscal.php`
- `app/Jobs/TransmitirNotaFiscal.php`
- `database/procedures/apuracao_icms.sql`
- `database/procedures/apuracao_pis_cofins.sql`

Quem valida uma mudança aqui: contador responsável do cliente, com aval do gerente de produto. Nenhuma mudança fiscal sobe sem os dois.

Perguntas obrigatórias adicionais desta zona, além das seis mínimas da Camada 11:
1. Qual competência é afetada, e ela já está encerrada?
2. Existe documento fiscal já transmitido à SEFAZ com o valor calculado pela regra antiga?
3. A obrigação acessória do período já foi entregue?
4. A mudança exige retificação de documento já emitido? Quantos?
5. Há alteração de regime tributário de algum cliente envolvida?

### Zona: FINANCEIRO E INTEGRAÇÃO BANCÁRIA

Pastas e arquivos que a compõem:
- `app/Services/Financeiro/`
- `app/Jobs/EnviarBoleto.php`
- `app/Http/Controllers/Webhook/BancoController.php`
- `app/Http/Controllers/Webhook/GatewayController.php`

Quem valida uma mudança aqui: gerente financeiro do cliente.

Perguntas obrigatórias adicionais desta zona:
1. O layout da remessa CNAB muda? O banco precisa homologar de novo?
2. Existe boleto já registrado no banco com o valor calculado pela regra antiga?
3. A mudança afeta conciliação de retorno já processado?

### Zona: DADO HISTÓRICO IMUTÁVEL

Pastas e arquivos que a compõem:
- `app/Models/MovimentoContabil.php`
- `app/Models/CompetenciaFechada.php`
- `app/Services/Fiscal/Apuracao.php`
- `database/procedures/fechar_competencia.sql`

Quem valida uma mudança aqui: contador responsável do cliente.

Perguntas obrigatórias adicionais desta zona:
1. A mudança reinterpreta registro de competência já encerrada?
2. É necessário reprocessar competências anteriores? Quantas?

### Zona: AUTENTICAÇÃO E PERMISSÃO

Pastas e arquivos que a compõem:
- `app/Http/Middleware/Autorizacao.php`
- `app/Models/Perfil.php`
- `app/Models/Permissao.php`

Quem valida uma mudança aqui: NÃO DETERMINADO — ver L-01 em `docs/legado/LACUNAS.md`.

Perguntas obrigatórias adicionais desta zona:
1. A mudança amplia o acesso de algum perfil existente?
2. Existe perfil de cliente externo afetado?

---

## 8. Áreas suspeitas de código morto

| Área | Sinal que levantou a suspeita | Última alteração |
|---|---|---|
| `app/Repositories/` | nenhuma referência às 4 classes fora dos próprios arquivos | 2021-06-14 |
| `app/Http/Controllers/ImportacaoLegadoController.php` | rota comentada em `routes/web.php:188` | 2018-02-09 |
| `app/Services/Fiscal/CalculoIssAntigo.php` | nenhum chamador; substituído por `CalculoIss.php` em 2022 | 2022-04-03 |
| `resources/views/relatorios/dre-v1.blade.php` | view não referenciada por nenhuma controller | 2019-11-22 |

Nenhum destes foi removido. Todos estão registrados em `docs/legado/DIVIDA.md`, seção de código morto suspeito.

---

## 9. Limiares do raio de impacto

### Faixas

```
BAIXO  até 3 chamadores, nenhuma zona de risco, sem migração,
       área com cobertura de teste existente, sem dado histórico afetado
MEDIO  4 a 15 chamadores, ou cobertura parcial ou ausente,
       ou consumo por job, cron, relatório ou integração
ALTO   acima de 15 chamadores, ou qualquer zona de risco tocada,
       ou migração de banco, ou dado histórico ou imutável afetado
```

### Orçamento de mudança por task

```
BAIXO  até 5 arquivos, até 150 linhas
MEDIO  até 3 arquivos, até 80 linhas
ALTO   até 2 arquivos, até 40 linhas
```

### Histórico de edição dos limiares

| Data | Quem editou | O que mudou | Motivo |
|---|---|---|---|
| 2026-08-14 | Gerente de engenharia | MEDIO passou de "10 a 15 chamadores" para "4 a 15" | Três incidentes em 2026 vieram de alterações com 5 a 8 chamadores classificadas como BAIXO; o limiar estava frouxo para a realidade de acoplamento deste projeto |
