# Raio de impacto — OC-2026-0184-arredondamento-icms-nota

> Exemplo preenchido, para servir de referência de qualidade.
> Sistema fictício: Gestor ERP, o mesmo de `PERFIL.exemplo.md`.
> Caso: raio ALTO com zona fiscal tocada e aprovação humana registrada.

Trabalho: OC-2026-0184-arredondamento-icms-nota — Arredondamento do ICMS diverge em um centavo na emissão da nota
Skill irmã: runx
Calculado em: 2026-08-20
Limiares aplicados: `docs/legado/PERFIL.md`, seção 9

---

## Conjunto de arquivos alvo

- `app/Services/Fiscal/CalculoIcms.php` — a função de arredondamento do valor do imposto
- `app/Models/ItemNotaFiscal.php` — o accessor que formata o valor exibido

---

## Sinais coletados

| # | Sinal | Valor | Método de coleta | Coletado ou assumido |
|---|---|---|---|---|
| 1 | Chamadores diretos e indiretos | 23 | `grep -rn "CalculoIcms" --include=*.php .` refinado por `->calcular` e `CalculoIcms::`, mais um nível acima de cada chamador | coletado |
| 2 | Telas e rotas que dependem | 6 | cruzamento dos chamadores com `routes/web.php` e as views que os renderizam | coletado |
| 3 | Jobs, crons, relatórios, integrações | 5 | seção 2 do PERFIL cruzada com os chamadores | coletado |
| 4 | Cobertura de teste na área | parcial | `phpunit --coverage-text --filter Fiscal`: 41% na pasta, mas nenhum teste cobre o arredondamento | coletado |
| 5 | Zona de risco tocada | FISCAL e DADO HISTÓRICO IMUTÁVEL | caminho dos arquivos alvo cruzado com a seção 7 do PERFIL | coletado |
| 6 | Churn e idade | 11 alterações na vida, última em 2022-04-03, criado em 2016-08-30 | `git log --format=%ad --date=short -- app/Services/Fiscal/CalculoIcms.php` | coletado |
| 7 | Migração de banco envolvida | não | nenhuma alteração de schema prevista; `database/migrations/` inalterada | coletado |
| 8 | Dado histórico ou imutável afetado | sim | notas fiscais já emitidas e transmitidas à SEFAZ usam o valor calculado por esta função | coletado |

### Detalhamento dos chamadores (Sinal 1)

| Chamador | Caminho | Direto ou indireto |
|---|---|---|
| `NotaFiscalController::emitir` | `app/Http/Controllers/NotaFiscalController.php:142` | direto |
| `NotaFiscalController::previa` | `app/Http/Controllers/NotaFiscalController.php:207` | direto |
| `ItemNotaFiscal::getValorIcmsAttribute` | `app/Models/ItemNotaFiscal.php:88` | direto |
| `Apuracao::apurarMes` | `app/Services/Fiscal/Apuracao.php:64` | direto |
| `TransmitirNotaFiscal::handle` | `app/Jobs/TransmitirNotaFiscal.php:39` | indireto (via `NotaFiscal::montarXml`) |
| `ExportadorContabil::gerarCsv` | `app/Services/Fiscal/ExportadorContabil.php:51` | indireto (via `Apuracao`) |
| `RelatorioController::fiscalPorPeriodo` | `app/Http/Controllers/RelatorioController.php:319` | indireto |
| `ReprocessarNotas::handle` | `app/Console/Commands/ReprocessarNotas.php:47` | indireto |
| — mais 15 chamadores indiretos, todos partindo dos quatro diretos acima | — | indireto |

### Telas e rotas (Sinal 2) — alimenta o roteiro manual da Camada 8

- Emissão de nota fiscal — `resources/views/fiscal/nota/emitir.blade.php`
- Prévia da nota antes de transmitir — `resources/views/fiscal/nota/previa.blade.php`
- Detalhe da nota emitida — `resources/views/fiscal/nota/detalhe.blade.php`
- Listagem de notas do período — `resources/views/fiscal/nota/index.blade.php`
- Relatório fiscal por período — `resources/views/relatorios/fiscal.blade.php`
- Apuração mensal — `resources/views/fiscal/apuracao.blade.php`

### Consumo assíncrono (Sinal 3) — alimenta a seção de colateral da Camada 8

- `fiscal:apuracao-mensal` — `app/Console/Kernel.php:38` — dia 1 de cada mês às 03:00
- `TransmitirNotaFiscal` (fila `nfe`) — `app/Jobs/TransmitirNotaFiscal.php` — a cada emissão
- Exportação contábil em CSV — `app/Services/Fiscal/ExportadorContabil.php` — mensal, enviada ao contador do cliente
- Relatório fiscal por período — `app/Http/Controllers/RelatorioController.php:319` — sob demanda
- `nfe:consultar-status` — `app/Console/Kernel.php:31` — a cada 15 minutos (lê o valor, não recalcula)

### Leitura do churn (Sinal 6)

Área congelada: 11 alterações em dez anos, nenhuma desde 2022. Ninguém do time atual escreveu este código. O histórico mostra três correções distintas no mesmo trecho de arredondamento (2017, 2019 e 2022), o que indica comportamento sutil e já disputado — sinal de que a regra atual foi ajustada para atender casos específicos que podem não estar documentados.

---

## FAIXA: ALTO

Determinada por: Sinal 5 — zona FISCAL e zona DADO HISTÓRICO IMUTÁVEL tocadas. O Sinal 8 (dado histórico afetado) e o Sinal 1 (23 chamadores) confirmariam ALTO independentemente.

---

## Camadas acionadas

| Camada | Acionada | Onde vive o artefato |
|---|---|---|
| 2 Raio de impacto | sim | este arquivo |
| 6 Proibição de melhoria colateral | sim | `docs/legado/DIVIDA.md` |
| 10 Prova de código vivo | sim | seção abaixo |
| 3 Testes de caracterização | sim | `tests/Caracterizacao/Fiscal/CalculoIcmsTest.php` |
| 4 Ponto de costura | sim | seção abaixo |
| 5 Orçamento de mudança | 2 arquivos, 40 linhas | plano em `docs/manutencao/OC-2026-0184-arredondamento-icms-nota/sprint-01/tasks.md` |
| 7 Plano de reversão | sim | seção abaixo |
| 8 Roteiro de teste manual | sim | `docs/legado/manual/OC-2026-0184-arredondamento-icms-nota.md` |
| 9 Comparação com dado real | sim | `docs/legado/comparacao/OC-2026-0184-arredondamento-icms-nota.md` |
| 11 Perguntas obrigatórias da zona | sim | seção abaixo |
| Feature flag ou chave de desligamento | sim | `FISCAL_ICMS_ARREDONDAMENTO_NOVO` |
| Aprovação humana explícita | sim | seção abaixo |

---

## Prova de código vivo (Camada 10)

| Alvo | Resultado | Evidência | Método |
|---|---|---|---|
| `app/Services/Fiscal/CalculoIcms.php` | VIVO | cadeia `NotaFiscalController::emitir` → rota `POST /fiscal/nota` (ponto de entrada declarado na seção 2 do PERFIL); 1.847 execuções no log de aplicação nos últimos 30 dias | grep de chamadores + consulta ao log |
| `app/Models/ItemNotaFiscal.php` | VIVO | accessor invocado em 4 das 6 views do Sinal 2 | grep nas views Blade |

---

## Zona de risco e perguntas obrigatórias (Camada 11)

Zona tocada: FISCAL e DADO HISTÓRICO IMUTÁVEL
Validador (do PERFIL.md): contador responsável do cliente, com aval do gerente de produto
Perguntas respondidas em: 2026-08-21 por: Contador responsável (cliente) e gerente de produto

1. Quem valida esta mudança antes de ir para produção: o contador responsável valida o cálculo; o gerente de produto autoriza a subida.
2. Existe impacto fiscal, contratual ou regulatório: sim. O valor do ICMS consta no XML transmitido à SEFAZ e na apuração mensal entregue como obrigação acessória.
3. Existe dado histórico que muda de interpretação: sim. Notas emitidas desde 2016 usaram a regra atual. Elas **não serão recalculadas** — a mudança vale apenas para notas emitidas a partir da entrega.
4. É preciso avisar cliente, e com quanta antecedência: sim, 15 dias corridos, por comunicado formal aos 30 clientes que conferem o imposto em planilha própria.
5. Existe janela de manutenção obrigatória: sim. A subida só pode ocorrer entre os dias 5 e 25 do mês, fora do período de apuração e de fechamento.
6. Existe processo manual do time que depende do comportamento atual: **sim, e este foi o achado mais importante da investigação.** 30 clientes mantêm planilha de conferência construída sobre o valor arredondado pela regra atual. Corrigir o cálculo sem aviso quebra a conferência deles mesmo com o código correto.

Perguntas específicas da zona FISCAL:
- Qual competência é afetada, e ela já está encerrada: apenas competências futuras. A entrega não altera competência encerrada.
- Existe documento fiscal já transmitido com o valor da regra antiga: sim, todos os anteriores à entrega. Não serão retificados.
- A obrigação acessória do período já foi entregue: sim, até a competência 07/2026.
- A mudança exige retificação de documento já emitido: não. Decisão registrada: o passado permanece como está.
- Há alteração de regime tributário de algum cliente envolvida: não.

Perguntas específicas da zona DADO HISTÓRICO IMUTÁVEL:
- A mudança reinterpreta registro de competência já encerrada: não. A nova regra só se aplica a notas emitidas após a entrega.
- É necessário reprocessar competências anteriores: não.

Restrições que estas respostas impõem ao plano:
- A nova regra vale apenas para notas emitidas a partir da data de entrega; o cálculo de notas já emitidas permanece intocado. Isto exige que a decisão de qual regra aplicar considere a data de emissão da nota.
- A subida acontece entre os dias 5 e 25, fora do período de apuração.
- O comunicado aos 30 clientes sai 15 dias antes da subida.
- A feature flag precisa permitir voltar à regra antiga sem novo deploy.

---

## Ponto de costura (Camada 4)

Ponto de costura escolhido: `app/Services/Fiscal/CalculoIcms.php:74` — o método privado `arredondar(float $valor): float`, único ponto onde o arredondamento acontece.
Por que ali: os 23 chamadores atravessam este método sem exceção, confirmado pelo Sinal 1; a alteração fica contida em um arquivo; e o comportamento em volta está congelado pelos 34 casos de caracterização.
O que isola: a regra de arredondamento, sem tocar a fórmula de base de cálculo nem a montagem do XML.
O que NÃO cobre: as 6 procedures em `database/procedures/`, que fazem seu próprio arredondamento em SQL na apuração mensal. A apuração continuará arredondando pela regra antiga, o que produz divergência de centavo entre a nota e a apuração. **Isto é uma segunda task, planejada e declarada, não um efeito descoberto depois** — ver T-01.05.

Alternativas descartadas:
- `NotaFiscalController::emitir` — cobriria a tela de emissão, mas não o job de transmissão nem a apuração. Meia correção, exatamente o padrão que gera divergência entre tela e relatório.
- `ItemNotaFiscal::getValorIcmsAttribute` — alteraria apenas a exibição, não o valor gravado nem o transmitido à SEFAZ. Esconderia o problema em vez de corrigi-lo.
- Nova classe `CalculoIcmsV2` com troca por injeção — exigiria alterar o registro no container e todos os pontos de instanciação (`new` direto é o dialeto desta pasta, conforme a seção 6 do PERFIL): 9 arquivos, muito acima do orçamento de 2.

---

## Caracterização (Camada 3)

Casos congelados: 34
Onde vivem: `tests/Caracterizacao/Fiscal/CalculoIcmsTest.php`
Comportamentos surpreendentes observados:
- O método trunca na segunda casa em vez de arredondar: `10.005` resulta em `10.00`, não `10.01`. É exatamente a causa da ocorrência, e estava congelado como comportamento vigente antes de qualquer alteração.
- Para base de cálculo negativa (devolução), o método retorna o valor sem truncar. Nenhum teste cobria isso e ninguém do time conhecia o desvio.
- Valores acima de `999999.99` perdem precisão por conversão implícita para `float`, conforme o eixo "dinheiro" da seção 6 do PERFIL. Registrado em `DIVIDA.md` como D-03; **não corrigido nesta ocorrência**, por estar fora do escopo travado.

---

## Reversão consolidada (Camada 7)

Classe da entrega como um todo (a pior entre as tasks): REVERSÍVEL COM PERDA
Efeitos que não se desfazem: notas transmitidas à SEFAZ entre a subida e a reversão permanecem com o valor calculado pela regra nova. A reversão do código não retifica documento já transmitido; a contenção é identificar essas notas pela data de emissão e tratá-las junto ao contador.

---

## Aprovação humana (regra 9)

Aprovado por: Gerente de produto, com validação técnica do contador responsável do cliente
Data: 2026-08-22
O que foi aprovado: alterar o arredondamento do ICMS de truncamento para arredondamento meio para cima, apenas em notas emitidas a partir da entrega, protegido por feature flag, sem retificar documento já emitido.
Riscos declarados no momento da aprovação:
- 30 clientes mantêm planilha de conferência sobre o valor antigo; comunicado formal sai 15 dias antes.
- A apuração mensal continuará arredondando pela regra antiga até que a T-01.05 entregue as procedures, o que produz divergência de centavo entre nota e apuração nesse intervalo.
- Notas transmitidas entre a subida e uma eventual reversão não são retificáveis pelo código.
- A comparação com dado real indicou 1.240 notas do exercício anterior que exibiriam valor diferente caso fossem recalculadas; a decisão registrada é não recalculá-las.

---

## Histórico de recálculo

| Data | Motivo do recálculo | Faixa anterior | Faixa nova |
|---|---|---|---|
| 2026-08-20 | cálculo inicial | — | ALTO |
| 2026-08-25 | as procedures de apuração entraram no escopo como T-01.05, acrescentando `database/procedures/apuracao_icms.sql` ao conjunto alvo | ALTO | ALTO (inalterada; a zona fiscal já a determinava) |
