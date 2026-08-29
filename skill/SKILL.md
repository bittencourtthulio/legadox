---
name: legadox
description: "Use para qualquer trabalho em projeto legado, sistema antigo, base com anos de mercado, código sem padrão único, área sem cobertura de teste ou módulo que ninguém quer mexer. Use mesmo quando o usuário não disser legado por nome: basta ele descrever uma alteração em sistema que já está em produção cujo comportamento atual precisa ser preservado — corrigir cálculo que clientes já usam, mexer em rotina fiscal, financeira, de folha ou de faturamento, alterar tela antiga, tocar código que ninguém entende, ou pedir cuidado para não quebrar nada. Calcula raio de impacto por evidência, congela o comportamento atual com testes de caracterização, limita o tamanho do diff, proíbe melhoria colateral e exige plano de reversão antes de qualquer alteração."
---

# legadox

legadox é a camada de segurança do método Expx (Exponencial): ela endurece o trabalho da `sprintx` e da `runx` quando o alvo é código legado.

## Princípio central

Em código legado o comportamento atual é o contrato, bugs inclusive, porque existe cliente dependendo do jeito errado há anos. **Nada é alterado antes de estar congelado por teste, e nada é tocado além do que o raio de impacto autorizou.**

## legadox não é um método novo

A `sprintx` continua com as fases F1 a F6. A `runx` continua com os estágios E1 a E5. O legadox **não acrescenta fase nem estágio**: ele muda o RIGOR de cada etapa, nunca a sequência delas.

O gatilho é um arquivo:

```
docs/legado/PERFIL.md existe   →  modo legado ATIVO
                                  sprintx e runx carregam as camadas extras
docs/legado/PERFIL.md ausente  →  tudo se comporta exatamente como hoje
                                  o legadox não interfere em nada
```

Sem `PERFIL.md` não existe modo legado. Se o usuário pedir trabalho legado e o arquivo não existir, a primeira coisa a fazer é gerá-lo (Camada 1, `/legadox-perfil`).

### Nenhuma camada é aplicada por padrão

O peso das camadas é real. Se todas ligassem para trocar a cor de um botão, o time abandonaria o método na primeira semana. Por isso **o raio de impacto é a peça central**: ele mantém o trabalho de baixo risco praticamente igual ao de hoje e concentra o rigor apenas onde o estrago seria real. Cada camada é acionada por faixa de raio, nunca "sempre".

## Estrutura em disco

Tudo que o legadox produz vive em `docs/legado/`, ancorado na raiz do repositório Git mais próxima (o diretório que contém `.git/`); sem `.git` em nenhum ancestral, na raiz do diretório de trabalho atual. Em monorepo, reaproveite o `docs/` da raiz se já existir — nunca crie um `docs/legado/` dentro de um workspace individual sem checar.

```
docs/legado/
  PERFIL.md                    Camada 1 — o mapa do projeto; é o gatilho do modo legado
  LACUNAS.md                   o que não foi possível determinar no PERFIL
  DIVIDA.md                    Camada 6 — inventário de dívida observada, append-only
  raio/<trabalho_id>.md        Camada 2 — um por trabalho
  manual/<trabalho_id>.md      Camada 8 — roteiro de teste manual
  comparacao/<trabalho_id>.md  Camada 9 — antes e depois com dado real
```

`<trabalho_id>` é o mesmo identificador do trabalho na skill irmã: o `<slug-da-feature>` da sprintx ou o `<OC-ID>-<slug>` da runx. Um trabalho, um raio, um nome.

## As 11 camadas

**Camada 1 — Perfil do projeto.** Roda uma vez na adoção e é atualizada sob demanda. Produz o mapa que o projeto nunca teve: stack real lida dos manifestos, pontos de entrada, camadas existentes, comandos reais de build/teste/lint, cobertura medida, padrões conflitantes, zonas de risco e limiares do raio. Nada de invenção: o que não for verificável vira `NÃO DETERMINADO` e entra em `LACUNAS.md`.

**Camada 2 — Raio de impacto.** Calculado antes de qualquer plano, para o conjunto de arquivos que serão tocados. Substitui o "peça permissão por intuição" por evidência coletada. Classifica em BAIXO, MEDIO ou ALTO e é isso que aciona (ou não) as demais camadas.

**Camada 3 — Testes de caracterização.** Antes de alterar área sem cobertura, escrever testes que CONGELAM o comportamento de hoje, inclusive o errado. Eles não julgam se está certo: registram o que é. Precisam passar no código atual, sem modificação nenhuma.

**Camada 4 — Ponto de costura.** Onde dá para intervir sem alterar o comportamento em volta. O plano declara onde é, por que ali, o que foi descartado e o que ele isola. Sem ponto de costura viável, o caso sobe para o humano — não vira licença para refatorar.

**Camada 5 — Orçamento de mudança.** Teto declarado por task: máximo de arquivos e de linhas. Quanto MAIOR o risco, MENOR o orçamento. Estourou: quebra a task ou escala. Nunca em silêncio.

**Camada 6 — Proibição de melhoria colateral.** Em arquivo tocado é proibido renomear fora do escopo, reformatar, rodar corretor de estilo, reorganizar imports, atualizar dependência, converter sintaxe antiga ou extrair método não previsto. O que incomodar vai para `DIVIDA.md`. Registro, nunca correção.

**Camada 7 — Plano de reversão por task.** Não basta "reverter o commit": cobre o que o versionador não desfaz — dado já gravado no formato novo, migração aplicada, flag a desligar, cache a invalidar, mensagem já enviada, arquivo já gerado, webhook já disparado. Efeito irreversível obriga aprovação humana, seja qual for o raio.

**Camada 8 — Roteiro de teste manual.** As telas do legado não têm cobertura automática. Casos numerados com pré-condição, passos na interface, resultado esperado observável, dado de teste sugerido e — a seção que todo roteiro esquece — o que observar de colateral nas telas e relatórios vizinhos.

**Camada 9 — Comparação antes e depois com dado real.** Roda o código antigo sobre amostra real, guarda a saída, roda o novo, compara. Reporta total, idênticos, divergentes com exemplos, e por que cada divergência é esperada. Divergência não explicada bloqueia a entrega. A amostra é anonimizada e nunca é commitada.

**Camada 10 — Prova de que o código está vivo.** Antes de gastar esforço num arquivo, confirmar que ele é chamado: grafo de chamadas no mínimo, log ou telemetria quando existir. Evidência de código morto não autoriza remoção — vira achado em `DIVIDA.md`.

**Camada 11 — Perguntas obrigatórias por zona.** Se o trabalho toca zona de risco declarada no `PERFIL.md`, um bloco de perguntas dispara ANTES de qualquer planejamento. É o "pedir permissão" acionado por regra, não por sorte. Sem as respostas, o plano não é gerado.

## Raio de impacto

O raio é calculado para o conjunto de arquivos que o trabalho vai tocar, antes do plano existir.

### Sinais coletados

Cada sinal é coletado com método declarado no arquivo do raio. Sinal que não puder ser coletado conta como **pior caso**, e isso fica escrito.

| Sinal | O que responde |
|---|---|
| Chamadores | quantos chamam direta e indiretamente o que será alterado |
| Telas e rotas | quais dependem do que será alterado |
| Consumo assíncrono | jobs, crons, relatórios e integrações externas que consomem |
| Cobertura | cobertura de teste existente naquela área |
| Zona de risco | qual zona do `PERFIL.md` é tocada, se alguma |
| Churn e idade | frequência de alteração e idade do arquivo, via histórico do versionador |
| Migração | há migração de banco envolvida |
| Dado histórico | o dado gravado é histórico ou imutável |

### Faixas

Limiares padrão, editáveis na seção correspondente do `PERFIL.md`.

| Faixa | Critério |
|---|---|
| **BAIXO** | até 3 chamadores, nenhuma zona de risco, sem migração, e área com cobertura de teste existente |
| **MEDIO** | 4 a 15 chamadores, **ou** cobertura ausente, **ou** consumo por job ou relatório |
| **ALTO** | acima de 15 chamadores, **ou** qualquer zona de risco tocada, **ou** migração de banco, **ou** dado histórico afetado |

Os critérios de BAIXO são conjuntivos (todos precisam valer). Os de MEDIO e ALTO são disjuntivos: um só basta. Na dúvida entre duas faixas, vale a maior.

### O que cada faixa aciona

| | BAIXO | MEDIO | ALTO |
|---|:---:|:---:|:---:|
| Raio registrado (Camada 2) | sim | sim | sim |
| Prova de código vivo (Camada 10) | sim | sim | sim |
| Proibição de colateral (Camada 6) | sim | sim | sim |
| Testes de caracterização (Camada 3) | não | sim | sim |
| Ponto de costura (Camada 4) | não | sim | sim |
| Orçamento por task (Camada 5) | 5 arq / 150 linhas | 3 arq / 80 linhas | 2 arq / 40 linhas |
| Plano de reversão (Camada 7) | não | sim | sim |
| Roteiro de teste manual (Camada 8) | não | sim | sim |
| Plano aprovado antes do código | não | sim | sim |
| Perguntas da zona (Camada 11) | não | se tocar zona | sim |
| Comparação com dado real (Camada 9) | não | não | sim |
| Feature flag ou chave de desligamento | não | não | sim |
| Aprovação humana explícita e registrada | não | não | sim |

Em **BAIXO** o legadox registra o raio e sai do caminho: o fluxo da sprintx ou da runx segue como hoje, sem camadas extras. A Camada 6 e a Camada 10 valem em toda faixa porque não custam etapa nova — a 6 é uma proibição, a 10 é uma verificação que a ingestão já faz.

A Camada 9 também é obrigatória, independentemente da faixa, em **qualquer mudança de cálculo ou de regra de negócio**.

## Regras invioláveis

1. Sem `docs/legado/PERFIL.md` não existe modo legado. A primeira coisa é gerá-lo.
2. Nenhum plano é gerado sem o raio de impacto calculado e escrito em `docs/legado/raio/<trabalho_id>.md`.
3. A faixa do raio é calculada por sinais, nunca escolhida por sensação. Sinal não coletável conta como pior caso, e isso fica registrado.
4. Em raio MEDIO ou ALTO, nada é alterado antes de existir teste de caracterização passando no código atual.
5. Nenhuma melhoria colateral. O que incomoda vai para `docs/legado/DIVIDA.md`.
6. O orçamento de mudança por task não é estourado em silêncio.
7. Toda task de raio MEDIO ou ALTO declara como se reverte, inclusive os efeitos que o versionador não desfaz.
8. Zona de risco tocada obriga as perguntas da zona respondidas antes do plano.
9. Raio ALTO obriga aprovação humana explícita e registrada.
10. Código morto identificado não é removido: vira achado.
11. Dado real usado em comparação é anonimizado e nunca é commitado.
12. O legadox não substitui a sprintx nem a runx: ele os endurece.

Regra transversal: use sempre caminhos relativos; nunca escreva caminho absoluto em nenhum artefato.

## Camadas → arquivos da skill

| Camada | Roteiro operacional | Templates usados |
|---|---|---|
| 1 Perfil do projeto | `references/01-perfil.md` | `assets/TEMPLATE-PERFIL.md`, `assets/TEMPLATE-LACUNAS.md` |
| 2 Raio de impacto | `references/02-raio-de-impacto.md` | `assets/TEMPLATE-raio.md` |
| 3 Testes de caracterização | `references/03-caracterizacao.md` | `assets/TEMPLATE-caracterizacao.md` |
| 4 Ponto de costura | `references/04-ponto-de-costura.md` | — |
| 5 Orçamento · 6 Colateral | `references/05-orcamento-e-colateral.md` | `assets/TEMPLATE-DIVIDA.md` |
| 7 Plano de reversão | `references/06-reversao.md` | `assets/TEMPLATE-reversao.md` |
| 8 Roteiro de teste manual | `references/07-teste-manual.md` | `assets/TEMPLATE-teste-manual.md` |
| 9 Comparação com dado real | `references/08-comparacao-real.md` | `assets/TEMPLATE-comparacao.md` |
| 10 Prova de código vivo | `references/02-raio-de-impacto.md` (sinal de chamadores) e `references/09-zonas-e-perguntas.md` | — |
| 11 Zonas e perguntas | `references/09-zonas-e-perguntas.md` | — |
| Integração com a sprintx | `references/10-integracao-sprintx.md` | — |
| Integração com a runx | `references/11-integracao-runx.md` | — |

Os caminhos acima são relativos à raiz desta skill. O detalhe operacional de cada camada mora exclusivamente no reference correspondente; leia-o apenas quando a camada for acionada pela faixa do raio.
