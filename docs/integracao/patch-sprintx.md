Você vai aplicar o patch do legadox na skill sprintx. Trabalhe de forma autônoma
até o fim: não faça perguntas, não peça autorização para editar arquivos, não pare
no meio para confirmar nada.

Se encontrar uma ambiguidade, escolha a opção mais conservadora, siga em frente, e
registre a escolha em DECISOES-DA-SKILL.md, na seção de ajuste do legadox.

═══════════════════════════════════════════════════════════════════════
PARTE 1 — O CONTRATO
═══════════════════════════════════════════════════════════════════════

O QUE É O LEGADOX
  Uma camada modificadora que endurece o trabalho de IA em projetos legados.
  Não é um terceiro método. Não acrescenta fase, não remove fase, não reordena
  nada. As seis fases da sprintx continuam sendo F1 a F6, na mesma ordem.
  O que o legadox muda é o RIGOR de cada fase.

O GATILHO
  Um arquivo: docs/legado/PERFIL.md.
    Existe → modo legado ativo, a sprintx carrega as camadas extras.
    Não existe → a sprintx se comporta exatamente como hoje.

  Esta é a regra mais importante deste patch: FORA DO MODO LEGADO, NADA MUDA.
  Um projeto sem PERFIL.md não pode perceber diferença alguma no comportamento
  da sprintx depois deste patch. Se perceber, o patch está errado.

O RISCO A MITIGAR
  As camadas do legadox são pesadas. Se todas ligassem para qualquer trabalho,
  o time abandonaria o método. Por isso o RAIO DE IMPACTO é a peça central:
  ele mantém o trabalho de baixo risco praticamente igual ao de hoje e concentra
  o peso apenas onde o estrago seria real.

  Em raio BAIXO, a sprintx roda EXATAMENTE como hoje, da F2 à F6. A única marca
  que o legadox deixa é o arquivo do raio em disco. Se a sua implementação fizer
  raio BAIXO acionar caracterização, comparação ou aprovação humana, ela está
  errada e você precisa corrigir.

ONDE MORA A FONTE
  O detalhe operacional de cada camada mora na skill legadox, em
  <skills>/legadox/references/ — onde <skills> e .claude/skills/ no Claude Code
  e .opencode/skills/ no OpenCode. A sprintx NÃO duplica esse conteúdo:
  ela aponta para ele. O reference que descreve exatamente o que muda em cada
  fase é 10-integracao-sprintx.md — leia-o antes de escrever qualquer alteração.

  Se a skill legadox não estiver instalada e o PERFIL.md existir, a sprintx
  avisa em uma linha que o modo legado foi detectado mas a skill não está
  disponível, e segue o fluxo normal. Nunca invente o conteúdo das camadas.

O VOCABULÁRIO COMPARTILHADO
  trabalho_id  na sprintx é o <slug-da-feature>, o mesmo nome da pasta docs/<slug>/.
  raio         docs/legado/raio/<slug-da-feature>.md
  manual       docs/legado/manual/<slug-da-feature>.md
  comparacao   docs/legado/comparacao/<slug-da-feature>.md
  divida       docs/legado/DIVIDA.md
  faixa        BAIXO | MEDIO | ALTO

═══════════════════════════════════════════════════════════════════════
PARTE 2 — O QUE ALTERAR
═══════════════════════════════════════════════════════════════════════

─────────────────────────────────────────────────────────────────────
2.1 — SKILL.md: a seção do modo legado
─────────────────────────────────────────────────────────────────────
  Acrescente ao SKILL.md uma seção curta chamada "Modo legado", depois da
  máquina de estados e antes das regras invioláveis, contendo:

    o gatilho: docs/legado/PERFIL.md existe → modo legado ativo
    a afirmação de que a sequência F1..F6 não muda, só o rigor
    a tabela de faixas do raio e o que cada uma aciona
    o ponteiro para <skills>/legadox/references/10-integracao-sprintx.md
      como fonte do detalhe operacional

  A seção precisa ser curta. Ela informa que o modo existe e para onde ir;
  ela não reproduz o método do legadox.

─────────────────────────────────────────────────────────────────────
2.2 — SKILL.md: as regras invioláveis do modo legado
─────────────────────────────────────────────────────────────────────
  Acrescente à lista de regras invioláveis um bloco marcado como válido
  APENAS no modo legado, mantendo a numeração existente e continuando a
  partir dela. As regras a acrescentar, uma por linha:

    Nenhum plano é gerado sem o raio de impacto calculado e escrito em
      docs/legado/raio/<slug-da-feature>.md.
    A faixa do raio é calculada por sinais, nunca escolhida por sensação;
      sinal não coletável conta como pior caso e isso fica registrado.
    Em raio MEDIO ou ALTO, nada é alterado antes de existir teste de
      caracterização passando no código atual.
    Nenhuma melhoria colateral; o que incomoda vai para docs/legado/DIVIDA.md.
    O orçamento de mudança por task não é estourado em silêncio.
    Toda task de raio MEDIO ou ALTO declara como se reverte, inclusive os
      efeitos que o versionador não desfaz.
    Zona de risco tocada obriga as perguntas da zona respondidas antes do plano.
    Raio ALTO obriga aprovação humana explícita e registrada.
    Código morto identificado não é removido: vira achado.
    Dado real usado em comparação é anonimizado e nunca é commitado.

  Cada uma precisa deixar explícito que só vale com PERFIL.md presente.

─────────────────────────────────────────────────────────────────────
2.3 — F1 INGESTÃO
─────────────────────────────────────────────────────────────────────
  Em references/01-ingestao.md, acrescente um bloco de modo legado que só
  dispara com PERFIL.md presente, mandando:

    ler o PERFIL.md como fonte de primeira classe da base
    extrair os padrões conflitantes das pastas que a feature vai tocar e
      registrá-los no arquivo de base da área
    rodar a Camada 10 (prova de código vivo) para cada arquivo alvo,
      seguindo o reference 09 do legadox
    declarar explicitamente o conjunto de arquivos alvo, que é a entrada
      do cálculo do raio

  E, ao FIM da F1, antes de liberar a F2: calcular o raio seguindo o
  reference 02 do legadox, produzindo docs/legado/raio/<slug>.md.
  A F2 não começa sem o raio escrito.

  Este é o único ponto novo no fluxo, e ele não é uma fase: é um cálculo
  no fim da F1.

─────────────────────────────────────────────────────────────────────
2.4 — F2 DESCOBERTA
─────────────────────────────────────────────────────────────────────
  Em references/02-descoberta.md, acrescente:

    quando o Sinal 5 do raio indicar zona de risco tocada, as perguntas
      obrigatórias da Camada 11 são feitas ANTES de qualquer outra pergunta
      da F2, seguindo o reference 09 do legadox
    as respostas entram em 00-DECISOES.md como decisões numeradas e são
      referenciadas na seção de zona do arquivo do raio
    sem elas, a F3 não gera plano
    em raio ALTO, a F2 é também onde a aprovação humana é obtida e registrada,
      com escopo e riscos declarados

  Preserve a regra da sprintx de perguntar em blocos de no máximo cinco
  perguntas: as seis da Camada 11 entram como dois blocos.

  Sem zona tocada, a F2 acontece exatamente como hoje.

─────────────────────────────────────────────────────────────────────
2.5 — F3 PLANO
─────────────────────────────────────────────────────────────────────
  Em references/03-plano.md, acrescente as quatro exigências que valem em
  raio MEDIO ou ALTO:

    a task de caracterização é a PRIMEIRA task da primeira fase, antes de
      qualquer task de alteração, com critério de aceite binário: os testes
      passam contra o código atual sem nenhuma alteração em código de produção
    ponto de costura declarado: onde é, por que ali, o que isola, o que NÃO
      cobre, alternativas descartadas. Sem ponto de costura viável, a F3 PARA
      e escala para o humano — nunca autoriza refatoração
    orçamento por task: arquivos e linhas máximos conforme a faixa, declarado
      no planejamento e não descoberto na execução
    plano de reversão por task: os seis itens do reference 06 do legadox,
      com a classe de reversibilidade

  Acrescente também um segundo critério de granularidade: além de "os dois
  testes cabem em uma frase cada", vale "a task cabe no orçamento da faixa".
  Task que não cabe é quebrada na F3, não na execução.

  Em raio BAIXO, a F3 é exatamente a de hoje.

─────────────────────────────────────────────────────────────────────
2.6 — F4 ORQUESTRADOR
─────────────────────────────────────────────────────────────────────
  Em references/04-orquestrador.md e no TEMPLATE-ORQUESTRADOR.md, acrescente:

    uma linha de cabeçalho com a faixa e o caminho relativo do arquivo do raio
    em MEDIO ou ALTO, a task de caracterização aparece no caminho crítico:
      nenhuma task de alteração é executada antes dela, inclusive as
      marcadas como paralelizáveis

  O paralelismo declarado entre tasks de alteração continua valendo; o que a
  caracterização impõe é um portão sequencial antes de todas elas.

─────────────────────────────────────────────────────────────────────
2.7 — F5 AUDITORIA
─────────────────────────────────────────────────────────────────────
  Em references/05-auditoria.md, acrescente as verificações do modo legado,
  todas de severidade ALTA (que, pela regra da sprintx, mandam voltar à F3):

    o raio foi calculado e escrito, com os oito sinais e método de coleta
    a faixa corresponde aos sinais, aplicando os limiares do PERFIL
    toda task declara orçamento, e nenhuma o excede sem autorização registrada
    em MEDIO/ALTO: caracterização é a primeira task e o ponto de costura está
      declarado com "o que não cobre" preenchido
    em MEDIO/ALTO: toda task tem plano de reversão com os seis itens e classe
    em ALTO: perguntas da zona respondidas e registradas antes do plano
    em ALTO: aprovação humana registrada com nome, data, escopo e riscos
    em ALTO: a comparação com dado real está prevista, com amostra e critério

  E, em qualquer faixa: nenhuma task planeja melhoria colateral (renomeação
  fora de escopo, reformatação, atualização de dependência, remoção de código
  morto). Task assim é achado ALTA.

  Preserve a regra: o auditor só aponta, nunca corrige.

─────────────────────────────────────────────────────────────────────
2.8 — F6 EXECUÇÃO
─────────────────────────────────────────────────────────────────────
  Em references/06-execucao.md, acrescente:

  Durante cada task:
    respeitar o orçamento, medindo o diff antes de concluir; estourou, quebra
      a task ou escala, nunca em silêncio. Sem autorização disponível, registra
      em 00-BLOQUEIOS.md, pula a task e segue — a regra de nunca parar continua
    proibição de melhoria colateral; o que incomoda vai para DIVIDA.md
    ler o próprio diff antes de concluir, contra o checklist da Camada 6

  Ao fim, em MEDIO ou ALTO:
    rodar a suíte de caracterização e analisar o diff dela: cada teste que
      passou a falhar é mudança intencional com a task que a autoriza citada,
      ou é regressão que se corrige no código, nunca no teste
    gerar o roteiro de teste manual em docs/legado/manual/<slug>.md

  Em ALTO, ou em qualquer mudança de cálculo ou regra de negócio:
    executar a comparação com dado real, produzindo
      docs/legado/comparacao/<slug>.md. Divergência não explicada BLOQUEIA a
      entrega: a feature não é dada por concluída.

─────────────────────────────────────────────────────────────────────
2.9 — O que NÃO alterar
─────────────────────────────────────────────────────────────────────
  Não altere a máquina de estados nem a detecção de fase pelo disco.
  Não altere o contrato da task, da fase e da sprint.
  Não altere o contrato expx-schema v1 do frontmatter.
  Não altere o comportamento de nenhuma fase quando PERFIL.md não existir.
  Não duplique o conteúdo dos references do legadox dentro da sprintx.
  Não crie fase nova, estágio novo, nem comando novo.

═══════════════════════════════════════════════════════════════════════
PARTE 3 — VERIFICAÇÃO ANTES DE ENCERRAR
═══════════════════════════════════════════════════════════════════════

  1. Simule um projeto SEM docs/legado/PERFIL.md e percorra as seis fases.
     Confirme que nada mudou em relação ao comportamento anterior ao patch.
     Qualquer diferença é defeito.
  2. Simule um trabalho de raio BAIXO ("corrigir o texto de um rótulo na tela
     de login"). Confirme que a sprintx calcula e registra o raio e NÃO aciona
     caracterização, ponto de costura, reversão, roteiro manual, comparação
     nem aprovação humana. Se acionar, corrija.
  3. Simule um trabalho de raio ALTO que toca zona fiscal. Confirme que a F2
     dispara as perguntas obrigatórias ANTES de qualquer outra pergunta, que a
     F3 não gera plano sem as respostas, que a caracterização é a primeira task,
     e que a F6 executa a comparação com dado real.
  4. Simule a ausência de ponto de costura viável e confirme que a F3 escala
     para o humano em vez de autorizar refatoração.
  5. Simule uma task que estoura o orçamento e confirme que a F6 quebra a task
     ou escala, e nunca estoura em silêncio.
  6. Confirme que a F5 tem as oito verificações novas e que todas são ALTA.
  7. Grep por caminho absoluto em tudo que você escreveu.
  8. Grep pelos textos de exemplo dos templates do legadox, para garantir que
     nenhum vazou para os arquivos de instrução da sprintx.
  9. Confirme que nenhum reference do legadox foi copiado para dentro da
     sprintx: a sprintx aponta, não duplica.

═══════════════════════════════════════════════════════════════════════
ENTREGA
═══════════════════════════════════════════════════════════════════════

Ao terminar, mostre:
  - os arquivos alterados, com o que mudou em cada um, em uma linha
  - a seção "Modo legado" do SKILL.md, tal como ficou escrita
  - as regras invioláveis acrescentadas, tal como ficaram escritas
  - o resultado das simulações 1 a 5 da PARTE 3, resumido
  - as decisões registradas em DECISOES-DA-SKILL.md
