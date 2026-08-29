<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/banner-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/banner-light.svg">
  <img alt="legadox — a camada de seguranca do metodo Expx" src="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/banner-light.svg" width="100%">
</picture>

<p>
  <img alt="harness: Claude Code" src="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/badge-claude.svg">
  <img alt="harness: OpenCode" src="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/badge-opencode.svg">
  <img alt="11 camadas" src="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/badge-camadas.svg">
  <img alt="raio BAIXO MEDIO ALTO" src="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/badge-raio.svg">
  <img alt="docs pt-BR" src="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/badge-lang.svg">
  <img alt="licenca MIT" src="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/badge-license.svg">
</p>

<strong>A camada de segurança do método Expx</strong> — o conjunto de regras que impede a IA<br>
de quebrar sistemas antigos que já estão rodando, para <a href="https://claude.com/claude-code">Claude Code</a> e <a href="https://opencode.ai">OpenCode</a>.

</div>

Quando você pede a um agente de IA para mexer num sistema com dez anos de estrada, ele mexe. Rápido, confiante, e frequentemente em quarenta arquivos que ninguém pediu para tocar. O `legadox` mede o risco de cada alteração antes que ela aconteça, congela o comportamento atual com testes, limita o tamanho do que pode ser mudado, e exige aprovação humana onde o estrago seria real. Onde o risco é baixo, ele sai do caminho e o trabalho corre como sempre correu.

> **Em código legado o comportamento atual é o contrato, bugs inclusive**, porque existe cliente dependendo do jeito errado há anos.
> Nada é alterado antes de estar congelado por teste, e nada é tocado além do que o raio de impacto autorizou.

---

## O ecossistema Expx

O método Expx é um conjunto de skills que se compõem, instaladas e mantidas pelo CLI [`expxdev`](https://github.com/bittencourtthulio/expxdev).

| Peça | Papel | Relação com o `legadox` |
|---|---|---|
| **[expxdev](https://github.com/bittencourtthulio/expxdev)** | o CLI: instala, atualiza e diagnostica o ecossistema, e sobe o painel de operação | é quem instala esta skill (`npx expxdev init`) |
| **[sprintx](https://github.com/bittencourtthulio/sprintx)** | **Build** — feature nova, F1…F6 | o legadox endurece cada uma das seis fases |
| **[runx](https://github.com/bittencourtthulio/runx)** | **Run** — ocorrência em produção, E1…E5 | o legadox endurece cada um dos cinco estágios |
| **legadox** *(este repositório)* | **camada** de segurança para código legado | — |
| **[stackx](https://github.com/bittencourtthulio/stackx)** | **camada** de convenções do repositório | o cartucho de migração dele alimenta o cálculo de raio; em área legada, quem manda é o `PERFIL.md` |
| **[mergex](https://github.com/bittencourtthulio/mergex)** | entrega: branch, commit por task, PR e pacote de QA | raio, caracterização, reversão e dívida alimentam o portão, a classificação de atenção e o PR |

**Camadas** (`legadox`, `stackx`) sozinhas não fazem nada — elas modificam o comportamento da `sprintx` e da `runx`. Sem `docs/legado/PERFIL.md`, nada muda: as irmãs se comportam como se comportariam sem esta skill.

Detalhes do ecossistema inteiro no [README do expxdev](https://github.com/bittencourtthulio/expxdev).

---

## O problema

Um sistema de faturamento em produção há oito anos arredonda o imposto para baixo. Está errado. Está errado desde 2018, e trinta clientes já construíram suas planilhas de conferência em cima desse valor errado. Quando alguém pede a um agente de IA para "corrigir o arredondamento do imposto", ele lê o código, entende a regra, corrige — e de quebra renomeia três variáveis mal nomeadas, reorganiza os imports, atualiza uma chamada depreciada e formata o arquivo inteiro. O diff tem 380 linhas. As 4 que importam estão perdidas no meio. Ninguém revisa 380 linhas com atenção. A mudança sobe, e na virada do mês o relatório fiscal de trinta clientes não bate mais com a planilha deles.

Nada nesse cenário exige um modelo ruim. Exige apenas um modelo prestativo trabalhando sem as restrições que um desenvolvedor experiente aplicaria por instinto: descobrir quem mais depende disso, congelar o comportamento antes de mexer, manter o diff pequeno o bastante para ser revisado, e perguntar a um humano antes de mudar um número que sai em documento fiscal.

---

## Camada modificadora, não método novo

`legadox` **não é um terceiro método**. A [`sprintx`](https://github.com/bittencourtthulio/sprintx) continua com suas seis fases, a [`runx`](https://github.com/bittencourtthulio/runx) continua com seus cinco estágios. O que muda é o **rigor** de cada etapa, nunca a sequência.

O gatilho é um arquivo.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/gatilho-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/gatilho-light.svg">
  <img alt="O gatilho do modo legado: o arquivo docs/legado/PERFIL.md" src="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/gatilho-light.svg" width="100%">
</picture>

Sem `PERFIL.md`, o legadox não existe. Com ele, cada trabalho passa por um cálculo de risco antes de virar plano — e é esse cálculo que decide quanto peso aplicar.

### As três skills do método Expx

| | **sprintx** (Build) | **runx** (Run) | **legadox** (Safety) |
|---|---|---|---|
| **Gatilho** | feature nova, planejada do zero | ocorrência num sistema em produção | o arquivo `docs/legado/PERFIL.md` |
| **Papel** | planeja e executa | investiga e corrige | endurece as outras duas |
| **Estágios** | F1…F6 | E1…E5 | nenhum próprio — modifica os das irmãs |
| **Saída** | a feature entregue | a ocorrência encerrada | o risco medido e contido |

---

## O raio de impacto

É a peça central, e existe para que o método **não seja pesado onde não precisa ser**. A maioria dos trabalhos cai em BAIXO e roda exatamente como rodava antes.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/raio-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/raio-light.svg">
  <img alt="O raio de impacto: os oito sinais, as tres faixas e o que cada uma aciona" src="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/raio-light.svg" width="100%">
</picture>

**Faixas** — limiares padrão, editáveis pelo time no próprio `PERFIL.md`:

| Faixa | Critério |
|---|---|
| **BAIXO** | até 3 chamadores, nenhuma zona de risco, sem migração, e área com cobertura de teste existente |
| **MEDIO** | 4 a 15 chamadores, **ou** cobertura ausente, **ou** consumo por job ou relatório |
| **ALTO** | acima de 15 chamadores, **ou** qualquer zona de risco tocada, **ou** migração de banco, **ou** dado histórico afetado |

**O que cada faixa aciona:**

| | BAIXO | MEDIO | ALTO |
|---|:---:|:---:|:---:|
| Raio registrado | sim | sim | sim |
| Proibição de melhoria colateral | sim | sim | sim |
| Prova de que o código está vivo | sim | sim | sim |
| Testes de caracterização | não | sim | sim |
| Ponto de costura declarado | não | sim | sim |
| Orçamento por task | 5 arquivos / 150 linhas | 3 arquivos / 80 linhas | 2 arquivos / 40 linhas |
| Plano de reversão | não | sim | sim |
| Roteiro de teste manual | não | sim | sim |
| Perguntas obrigatórias da zona | não | se tocar zona | sim |
| Comparação com dado real | não | não | sim |
| Feature flag | não | não | sim |
| Aprovação humana registrada | não | não | sim |

Repare na inversão do orçamento: **quanto maior o risco, menor o diff permitido.** Onde o estrago seria maior, a mudança precisa caber inteira na cabeça de um revisor.

A faixa **nunca é escolhida por sensação** — é calculada pelos sinais. E sinal que não pôde ser coletado conta como pior caso, com o motivo registrado.

---

## As 11 camadas

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/camadas-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/camadas-light.svg">
  <img alt="As 11 camadas do legadox e a faixa de raio que aciona cada uma" src="https://raw.githubusercontent.com/bittencourtthulio/legadox/main/.github/assets/camadas-light.svg" width="100%">
</picture>

| # | Camada | O que faz |
|---|---|---|
| 1 | [Perfil do projeto](.claude/skills/legadox/references/01-perfil.md) | mapeia stack, entradas, comandos, cobertura medida, padrões conflitantes e zonas de risco |
| 2 | [Raio de impacto](.claude/skills/legadox/references/02-raio-de-impacto.md) | calcula o risco por evidência antes de qualquer plano |
| 3 | [Testes de caracterização](.claude/skills/legadox/references/03-caracterizacao.md) | congela o comportamento atual, inclusive o errado, antes de alterar |
| 4 | [Ponto de costura](.claude/skills/legadox/references/04-ponto-de-costura.md) | acha onde intervir sem alterar o comportamento em volta |
| 5 | [Orçamento de mudança](.claude/skills/legadox/references/05-orcamento-e-colateral.md) | teto de arquivos e linhas por task, declarado antes de executar |
| 6 | [Proibição de melhoria colateral](.claude/skills/legadox/references/05-orcamento-e-colateral.md) | nada de brinde no diff; o que incomoda vira inventário de dívida |
| 7 | [Plano de reversão](.claude/skills/legadox/references/06-reversao.md) | como desfazer, inclusive o que o versionador não desfaz |
| 8 | [Roteiro de teste manual](.claude/skills/legadox/references/07-teste-manual.md) | passo a passo para uma pessoa validar na tela, com o colateral |
| 9 | [Comparação com dado real](.claude/skills/legadox/references/08-comparacao-real.md) | roda antes e depois sobre amostra anonimizada e explica cada divergência |
| 10 | [Prova de que o código está vivo](.claude/skills/legadox/references/09-zonas-e-perguntas.md) | confirma que o arquivo é chamado antes de gastar esforço nele |
| 11 | [Perguntas obrigatórias por zona](.claude/skills/legadox/references/09-zonas-e-perguntas.md) | dispara perguntas por regra quando o trabalho toca área sensível |

---

## Instalação

O instalador monta a estrutura **dos dois harnesses de uma vez**:

```bash
git clone https://github.com/bittencourtthulio/legadox.git
cd legadox
./install.sh
```

Isso cria `.claude/` **e** `.opencode/` no projeto atual, mais o `AGENTS.md` na raiz. Para deixar disponível em todos os seus projetos:

```bash
./install.sh --global
```

### Opções

| Flag | Efeito |
|---|---|
| *(nenhuma)* | instala nos dois harnesses, no projeto atual |
| `--global` | instala no diretório global do usuário, não no projeto |
| `--claude` | só Claude Code |
| `--opencode` | só OpenCode |
| `--force` | sobrescreve instalação existente sem perguntar |
| `--dry-run` | mostra o que faria, sem escrever nada |

As flags combinam: `./install.sh --global --opencode` instala só o OpenCode, só no global.

Sem `--force`, o instalador **nunca sobrescreve calado**: pergunta no modo interativo e pula quando não há terminal (CI). Rodar duas vezes é seguro.

### Instalação manual

O repositório já publica as árvores no formato de cada harness, então instalar é copiar árvore para árvore:

```bash
# Claude Code
cp -r .claude/skills/legadox   .claude/skills/legadox
cp -r .claude/hooks/legadox    .claude/hooks/legadox
cp    .claude/agents/*.md      .claude/agents/
cp    .claude/commands/*.md    .claude/commands/

# OpenCode
cp -r .opencode/skills/legadox .opencode/skills/legadox
cp -r .opencode/hooks/legadox  .opencode/hooks/legadox
cp    .opencode/agents/*.md    .opencode/agents/
cp    .opencode/commands/*.md  .opencode/commands/
cp    .opencode/plugin/legadox.js .opencode/plugin/
```

No Claude Code os hooks precisam ser **registrados** no seu `.claude/settings.json`: copie o bloco `hooks` de `.claude/settings.json` deste repositório para o seu, preservando o que já existe. No OpenCode não há esse passo — o `plugin/legadox.js` é carregado sozinho.

Copie também o `AGENTS.md` para a raiz do projeto: é por ele que o agente do OpenCode sabe que deve acionar a skill.

O `install.sh` faz tudo isso, e o merge do `settings.json` com backup — é bem menos trabalhoso.

Reinicie a sessão do seu harness para a skill ser carregada.

---

## Primeiros passos

**1. Gere o perfil.**

```
/legadox-perfil
```

Ele lê os manifestos, mapeia os pontos de entrada, mede a cobertura de verdade, cataloga os padrões conflitantes que convivem no projeto e procura as zonas de risco. O que não for verificável vira `NÃO DETERMINADO` e entra em `docs/legado/LACUNAS.md` — nunca uma suposição plausível.

**2. Revise o `PERFIL.md`.** Este passo é seu, não da IA. Confirme as zonas de risco, corrija quem valida cada uma, ajuste os limiares do raio se o padrão não servir ao seu projeto. Este arquivo é a base de todo o resto.

**3. Trabalhe normalmente** com a `sprintx` ou a `runx`. A partir da existência do `PERFIL.md`, elas passam a calcular o raio e aplicar as camadas correspondentes sozinhas. Você não precisa lembrar de acionar o legadox.

### Comandos

| Comando | O que faz |
|---|---|
| `/legadox` | roteador: verifica o modo legado e mostra o que falta no trabalho atual |
| `/legadox-perfil` | **Camada 1** — gera ou atualiza o `PERFIL.md` |
| `/legadox-raio` | **Camada 2** — calcula o raio de impacto de um trabalho |
| `/legadox-caracterizar` | **Camada 3** — escreve os testes de caracterização |
| `/legadox-manual` | **Camada 8** — gera o roteiro de teste manual |
| `/legadox-divida` | **Camada 6** — consulta e acrescenta ao `DIVIDA.md` |

---

## Integração com sprintx e runx

O legadox entrega duas coisas: as skills que produzem os artefatos, e os **patches** que ensinam as skills irmãs a mudar de comportamento quando o `PERFIL.md` existe.

- [`docs/integracao/patch-sprintx.md`](docs/integracao/patch-sprintx.md) — cole no repositório da sprintx
- [`docs/integracao/patch-runx.md`](docs/integracao/patch-runx.md) — cole no repositório da runx

Cada patch é um prompt autônomo. Ele detecta o `PERFIL.md`, carrega as referências do legadox quando presente, aplica as mudanças de fase, acrescenta as regras invioláveis correspondentes, e **não altera nada do comportamento fora do modo legado**.

O detalhe do que muda em cada fase está em [integração com a sprintx](.claude/skills/legadox/references/10-integracao-sprintx.md) e [integração com a runx](.claude/skills/legadox/references/11-integracao-runx.md).

---

## Estrutura em disco

Tudo que o legadox produz vive em `docs/legado/`:

```
docs/legado/
  PERFIL.md                    Camada 1 — o mapa; é o gatilho do modo legado
  LACUNAS.md                   o que não foi possível determinar
  DIVIDA.md                    Camada 6 — inventário de dívida, append-only
  raio/<trabalho_id>.md        Camada 2 — um por trabalho
  manual/<trabalho_id>.md      Camada 8 — roteiro de teste manual
  comparacao/<trabalho_id>.md  Camada 9 — antes e depois com dado real
```

`<trabalho_id>` é o mesmo identificador do trabalho na skill irmã: o `<slug-da-feature>` da sprintx ou o `<OC-ID>-<slug>` da runx. Um trabalho, um raio, um nome.

---

## As 12 regras invioláveis

1. Sem `docs/legado/PERFIL.md` não existe modo legado. A primeira coisa é gerá-lo.
2. Nenhum plano é gerado sem o raio de impacto calculado e escrito.
3. A faixa do raio é calculada por sinais, nunca escolhida por sensação. Sinal não coletável conta como pior caso, e isso fica registrado.
4. Em raio MEDIO ou ALTO, nada é alterado antes de existir teste de caracterização passando no código atual.
5. Nenhuma melhoria colateral. O que incomoda vai para `DIVIDA.md`.
6. O orçamento de mudança por task não é estourado em silêncio.
7. Toda task de raio MEDIO ou ALTO declara como se reverte, inclusive os efeitos que o versionador não desfaz.
8. Zona de risco tocada obriga as perguntas da zona respondidas antes do plano.
9. Raio ALTO obriga aprovação humana explícita e registrada.
10. Código morto identificado não é removido: vira achado.
11. Dado real usado em comparação é anonimizado e nunca é commitado.
12. O legadox não substitui a sprintx nem a runx: ele os endurece.

---

## O que o legadox NÃO faz

- **Não refatora.** Nunca. Se não há ponto de costura viável, ele escala para um humano em vez de reestruturar o módulo por conta própria.
- **Não moderniza.** Não atualiza dependência, não converte sintaxe antiga, não migra framework. Sistema antigo que funciona continua antigo.
- **Não remove código morto.** Identifica, registra, e deixa lá. Remover código morto em legado é uma mudança com raio próprio e merece seu próprio trabalho.
- **Não substitui revisão humana.** O objetivo do orçamento de mudança é justamente manter o diff pequeno o bastante para que uma pessoa consiga revisá-lo de verdade.
- **Não torna seguro o que é irreversível.** Nota fiscal emitida, e-mail enviado, remessa transmitida: nada disso volta. O legadox obriga a declarar o efeito e a pedir aprovação humana; ele não desfaz o que não se desfaz.
- **Não mede nada que você não medir.** A cobertura registrada no perfil é a que a ferramenta do seu projeto reportou. Se a suíte não roda, ele escreve que não roda.

---

## Exemplo

Pedido: *"corrigir a regra de cálculo do imposto na emissão da nota"*.

O legadox calcula o raio antes de qualquer plano:

```
Sinal 1  Chamadores ................ 23  (grep + analise de chamadores)
Sinal 3  Consumo assincrono ........ job de fechamento mensal, remessa contabil
Sinal 4  Cobertura ................. ausente
Sinal 5  Zona de risco ............. FISCAL — src/fiscal/, src/nota/
Sinal 7  Migracao .................. nao
Sinal 8  Dado historico ............ sim, notas ja emitidas

FAIXA: ALTO — determinada pelo Sinal 5 (zona fiscal tocada)
```

E então **para**, antes de escrever qualquer plano, porque a zona fiscal dispara as perguntas obrigatórias:

```
1. Quem valida esta mudanca antes de ir para producao?
2. Existe impacto fiscal, contratual ou regulatorio?
3. Existe dado historico que muda de interpretacao?
4. E preciso avisar cliente, e com quanta antecedencia?
5. Existe janela de manutencao obrigatoria?
6. Existe processo manual do time que depende do comportamento atual?
```

A pergunta 6 costuma ser a que muda tudo: se trinta clientes conferem o imposto numa planilha construída sobre o valor atual, corrigir o cálculo sem avisar quebra o processo deles mesmo com o código certo.

Respondidas as perguntas e registrada a aprovação humana, o trabalho segue com caracterização, ponto de costura, orçamento de 2 arquivos e 40 linhas, plano de reversão, roteiro de teste manual, feature flag e comparação com dado real. E a comparação revela o que ninguém previu: **1.240 notas do exercício anterior passam a exibir um centavo a menos.** Esse número, que não apareceria em teste nenhum, é o que faz o humano decidir.

Já o pedido *"corrigir o texto de um rótulo na tela de login"* dá 1 chamador, nenhuma zona, sem migração, área com cobertura: **BAIXO**. O legadox registra o raio, escreve "nenhuma camada adicional acionada" e sai do caminho. Sem caracterização, sem comparação, sem aprovação. É esse contraste que faz o método sobreviver ao uso diário.

Exemplos completos e preenchidos, de um ERP fictício com módulo fiscal, ficam em [`exemplos/`](exemplos/): um [`PERFIL.md`](exemplos/PERFIL.exemplo.md), um [raio ALTO com aprovação registrada](exemplos/raio.exemplo.md) e um [roteiro de teste manual](exemplos/teste-manual.exemplo.md).

---

## Hooks: as camadas que não dependem de o modelo lembrar

As doze regras acima são instruções — e instrução é coisa que o modelo pode esquecer numa execução longa, justamente quando o trabalho é grande e o risco é maior. Hook é script determinístico: roda sempre, porque quem executa é o harness, não o modelo.

| Hook | Camada | O que faz |
|---|---|---|
| `zona-de-risco.sh` | 11 | **barra** escrita em zona de risco declarada enquanto as perguntas obrigatórias daquela zona não estiverem respondidas |
| `aprovacao-em-raio-alto.sh` | — | **barra** implementação em raio ALTO sem aprovação humana registrada |
| `caracterizacao-antes.sh` | 3 | em raio MÉDIO ou ALTO, avisa ao alterar arquivo que não consta da lista de caracterizados |
| `orcamento-de-mudanca.sh` | 5 | conta arquivos e linhas já alterados na task e avisa ao estourar o teto da faixa |
| `raio-antes-do-plano.sh` | 2 | avisa quando um plano é escrito sem o raio calculado |
| `reversao-declarada.sh` | 7 | em raio MÉDIO ou ALTO, barra `status: concluida` sem plano de reversão preenchido |
| `sem-colateral.sh` | 6 | detecta o diff que é só formatação, renomeação ou reorganização de import, e manda para o `DIVIDA.md` |

**A doutrina do ecossistema é que todo hook de método nasce em modo `aviso`**, e só vira bloqueio depois de semanas sem falso positivo — hook que dá falso positivo é desinstalado, e junto com ele vão os que funcionavam. O `legadox` é o único repositório com **duas exceções deliberadas**: `zona-de-risco` e `aprovacao-em-raio-alto` nascem em `bloqueio`. O motivo está escrito no cabeçalho de cada um, e é o mesmo do resto da skill: nota fiscal emitida não volta.

O modo de cada hook vive em `.expx/hooks.json`, com os padrões em `hooks/modos.padrao.json`.

## Agentes

Dois subagentes rodam em contexto próprio — e são os únicos do ecossistema com permissão de escrita, porque produzem artefato:

| Agente | Camada | Papel |
|---|---|---|
| `cartografo` | 1 e 10 | monta o `PERFIL.md`, que é o gatilho do modo legado, e prova que o código alvo está vivo; o que não for verificável vira `NÃO DETERMINADO` |
| `avaliador-de-raio` | 2 | coleta os oito sinais por evidência e classifica a faixa; sinal não coletável conta como pior caso, e isso fica escrito |

## O rastro de eventos

Os sete hooks gravam num arquivo append-only, uma linha JSON por evento, seguindo o contrato `expx-eventos` v1:

```
docs/eventos/<trabalho_id>.jsonl
```

É o que o **painel de operação** (`npx expxdev panel`) lê para mostrar o que aconteceu e quando — inclusive cada `regra_violada` e cada `acao_bloqueada`. É também o dado que diz quais hooks já rodaram tempo suficiente em modo aviso para serem promovidos a bloqueio.

---

## Estrutura do repositório

A fonte é **neutra de harness**: um único conjunto de arquivos, que o instalador materializa nos dois formatos.

```
skill/                        fonte única da skill
  SKILL.md                    identidade, camadas, raio, regras invioláveis
  DECISOES-DA-SKILL.md        decisões de construção, com o porquê de cada uma
  references/
    01-perfil.md              Camada 1 — o mapa do projeto
    02-raio-de-impacto.md     Camada 2 — os oito sinais e as faixas
    03-caracterizacao.md      Camada 3 — congelar o comportamento atual
    04-ponto-de-costura.md    Camada 4 — onde intervir
    05-orcamento-e-colateral.md   Camadas 5 e 6 — o tamanho do diff
    06-reversao.md            Camada 7 — como se desfaz
    07-teste-manual.md        Camada 8 — o roteiro para uma pessoa
    08-comparacao-real.md     Camada 9 — antes e depois com dado real
    09-zonas-e-perguntas.md   Camadas 10 e 11 — código vivo e perguntas
    10-integracao-sprintx.md  o que muda em cada fase da sprintx
    11-integracao-runx.md     o que muda em cada estágio da runx
  assets/
    TEMPLATE-*.md             8 templates preenchíveis
commands/                     os 6 comandos, válidos nos dois harnesses
agents/                       os 2 subagentes: cartografo e avaliador-de-raio
hooks/
  hooks.json                  o registro dos hooks no harness
  modos.padrao.json           o modo padrão de cada hook (aviso ou bloqueio)
  *.sh                        os 7 hooks das camadas
  comum/                      biblioteca comum: faixa do raio, rastro, permitir/avisar
  opencode/legadox.js         ponte que traduz os eventos do OpenCode e invoca os mesmos .sh
docs/integracao/              os patches para colar na sprintx e na runx
exemplos/                     artefatos preenchidos de um ERP fictício
install.sh                    instalador para Claude Code + OpenCode
AGENTS.md                     instruções de modo legado para o agente
```

O `SKILL.md` é a porta de entrada e fica abaixo de 200 linhas. O detalhe operacional de cada camada mora no `reference` correspondente, lido **só quando a camada é acionada pela faixa do raio** — mantendo o contexto enxuto.

---

## Licença

MIT

---

## Como contribuir

O legadox é um conjunto de instruções, não um programa: contribuir é melhorar texto operacional.

O que ajuda mais:

- **Limiares que não funcionaram no seu projeto.** Se BAIXO ficou frouxo ou ALTO ficou paranoico na sua base, o número e o contexto valem mais que a opinião.
- **Zonas de risco que faltam** na lista que a Camada 1 procura ativamente.
- **Casos em que uma camada atrapalhou** sem proteger nada. O maior risco deste projeto é virar burocracia, e esse relato é o antídoto.
- **Padrões conflitantes de stacks** que a Camada 1 ainda não sabe procurar.

Abra uma issue descrevendo o caso concreto antes de mandar um PR grande. Mudança em regra inviolável precisa de justificativa forte: são doze, e a força delas vem de não terem exceção.

---

<div align="center">
<sub>Parte do método <strong>Expx</strong> ·
<a href="https://github.com/bittencourtthulio/expxdev">expxdev</a> ·
<a href="https://github.com/bittencourtthulio/sprintx">sprintx</a> ·
<a href="https://github.com/bittencourtthulio/runx">runx</a> ·
legadox ·
<a href="https://github.com/bittencourtthulio/stackx">stackx</a> ·
<a href="https://github.com/bittencourtthulio/mergex">mergex</a></sub>
</div>
