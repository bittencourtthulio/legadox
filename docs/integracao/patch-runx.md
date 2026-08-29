Você vai aplicar o patch do legadox na skill runx. Trabalhe de forma autônoma
até o fim: não faça perguntas, não peça autorização para editar arquivos, não pare
no meio para confirmar nada.

Se encontrar uma ambiguidade, escolha a opção mais conservadora, siga em frente, e
registre a escolha em DECISOES-DA-SKILL.md, na seção de ajuste do legadox.

═══════════════════════════════════════════════════════════════════════
PARTE 1 — O CONTRATO
═══════════════════════════════════════════════════════════════════════

O QUE É O LEGADOX
  Uma camada modificadora que endurece o trabalho de IA em projetos legados.
  Não é um terceiro método. Não acrescenta estágio, não remove estágio, não
  reordena nada. Os cinco estágios da runx continuam sendo E1 a E5, na mesma
  ordem. O que o legadox muda é o RIGOR de cada estágio.

O GATILHO
  Um arquivo: docs/legado/PERFIL.md.
    Existe → modo legado ativo, a runx carrega as camadas extras.
    Não existe → a runx se comporta exatamente como hoje.

  Esta é a regra mais importante deste patch: FORA DO MODO LEGADO, NADA MUDA.
  Um projeto sem PERFIL.md não pode perceber diferença alguma no comportamento
  da runx depois deste patch. Se perceber, o patch está errado.

POR QUE A RUNX É A METADE QUE MAIS SE BENEFICIA
  Ocorrência de manutenção em sistema antigo é, por definição, trabalho em
  legado: o comportamento atual já tem cliente dependendo dele, e a correção
  precisa preservar tudo que não foi reclamado. A regra 8 da runx (escopo
  travado, nada de "já que estou aqui") e a Camada 6 do legadox (proibição de
  melhoria colateral) dizem a mesma coisa; o legadox dá a ela um lugar concreto
  para depositar a tentação, o docs/legado/DIVIDA.md.

O RISCO A MITIGAR
  As camadas do legadox são pesadas. Se todas ligassem para qualquer chamado,
  o time abandonaria o método. Por isso o RAIO DE IMPACTO é a peça central.

  Em raio BAIXO, a runx roda EXATAMENTE como hoje, do E2 ao E5. A única marca
  que o legadox deixa é o arquivo do raio em disco e a faixa citada no relatório.
  Se a sua implementação fizer raio BAIXO acionar caracterização, comparação ou
  aprovação humana, ela está errada e você precisa corrigir.

ONDE MORA A FONTE
  O detalhe operacional de cada camada mora na skill legadox, em
  <skills>/legadox/references/ — onde <skills> e .claude/skills/ no Claude Code
  e .opencode/skills/ no OpenCode. A runx NÃO duplica esse conteúdo:
  ela aponta para ele. O reference que descreve exatamente o que muda em cada
  estágio é 11-integracao-runx.md — leia-o antes de escrever qualquer alteração.

  Se a skill legadox não estiver instalada e o PERFIL.md existir, a runx avisa
  em uma linha que o modo legado foi detectado mas a skill não está disponível,
  e segue o fluxo normal. Nunca invente o conteúdo das camadas.

O VOCABULÁRIO COMPARTILHADO
  trabalho_id  na runx é o <OC-ID>-<slug>, o mesmo nome da pasta da ocorrência.
  raio         docs/legado/raio/<OC-ID>-<slug>.md
  manual       docs/legado/manual/<OC-ID>-<slug>.md
  comparacao   docs/legado/comparacao/<OC-ID>-<slug>.md
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
    a afirmação de que a sequência E1..E5 não muda, só o rigor
    a tabela de faixas do raio e o que cada uma aciona
    o ponteiro para <skills>/legadox/references/11-integracao-runx.md
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
      docs/legado/raio/<OC-ID>-<slug>.md.
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
2.3 — E1 INVESTIGAÇÃO
─────────────────────────────────────────────────────────────────────
  Em references/01-investigacao.md, acrescente um bloco de modo legado que só
  dispara com PERFIL.md presente.

  Em E1.a (base de conhecimento):
    ler o PERFIL.md como fonte de primeira classe da base
    extrair os padrões conflitantes das pastas da ocorrência e registrá-los no
      arquivo de área da base. Atenção ao eixo DINHEIRO quando a ocorrência for
      de cálculo divergente: se o PERFIL registra float para valor monetário,
      essa é frequentemente a causa raiz — e é achado registrado, não corrigido
      de brinde
    rodar a Camada 10 (prova de código vivo) para cada arquivo suspeito,
      seguindo o reference 09 do legadox

  Em E1.b:
    a causa raiz comprovada, ou a análise de impacto, continua exatamente como
      hoje, com a mesma exigência de prova
    a lista de arquivos e módulos impactados de 01-CAUSA-RAIZ.md passa a ser
      também o conjunto de arquivos alvo do raio

  Ao FIM do E1, antes de liberar o E2:
    calcular o raio seguindo o reference 02 do legadox, produzindo
      docs/legado/raio/<OC-ID>-<slug>.md. O E2 não começa sem o raio escrito.
    quando o Sinal 5 indicar zona de risco tocada, disparar as perguntas
      obrigatórias da Camada 11 AINDA NO E1, seguindo o reference 09.
      As respostas entram nas decisões de 01-CAUSA-RAIZ.md.
    em raio ALTO, obter e registrar a aprovação humana, com escopo e riscos.

  Sobre as perguntas: este passa a ser o segundo momento em que a runx pergunta.
  O primeiro é o portão único do E1 (bug sem reprodução). Ambos são exceções
  previstas por regra e ambos acontecem no E1 — nunca durante o E3, onde a runx
  continua não perguntando nada. Deixe isso explícito no texto, para não parecer
  conflito com a regra 13.

─────────────────────────────────────────────────────────────────────
2.4 — E2 PLANO
─────────────────────────────────────────────────────────────────────
  Em references/02-plano.md, acrescente as quatro exigências que valem em raio
  MEDIO ou ALTO:

    a task de caracterização é a PRIMEIRA task da primeira fase. Atenção à
      ordem, porque a runx já tem um teste na primeira posição:

        T-01.01  caracterização — congela o comportamento atual, inclusive o errado
        T-01.02  teste de regressão — reproduz o problema relatado e falha hoje
        T-01.03  o fix

      Os dois testes têm papéis opostos e complementares: a caracterização diz
      "isto o sistema faz e deve continuar fazendo"; a regressão diz "isto o
      sistema faz e precisa parar de fazer". Se um teste de caracterização
      congelou exatamente o comportamento que a regressão quer derrubar, isso é
      declarado na task, com o antes e o depois, e a quebra é intencional e
      autorizada.

    ponto de costura declarado: onde é, por que ali, o que isola, o que NÃO
      cobre, alternativas descartadas. Sem ponto de costura viável, o E2 PARA e
      escala para o humano — nunca autoriza refatoração. Isto reforça a regra 8
      da runx (escopo travado)
    orçamento por task conforme a faixa, declarado no planejamento
    plano de reversão por task: os seis itens do reference 06 do legadox, com
      a classe de reversibilidade

  A regra de proporcionalidade da runx e o orçamento do legadox se encontram
  bem: a runx já manda uma correção de uma linha gerar 1 sprint, 1 fase e 2
  tasks; o orçamento apenas dá o teto verificável do que "uma linha" pode virar.

  Em raio BAIXO, o E2 é exatamente o de hoje.

─────────────────────────────────────────────────────────────────────
2.5 — E3 FIX
─────────────────────────────────────────────────────────────────────
  Em references/03-fix.md, acrescente:

    respeitar o orçamento, medindo o diff antes de concluir cada task; estourou,
      quebra a task ou escala. Sem autorização disponível, registra em
      BLOQUEIOS.md, pula a task e segue — a runx não para para esperar
    proibição de melhoria colateral; o que incomoda vai para DIVIDA.md
    ler o próprio diff antes de concluir, contra o checklist da Camada 6
    a ordem dos testes é obrigatória: caracterização passando antes de qualquer
      alteração

  Acrescente um segundo retorno ao E1, análogo ao que a runx já tem: se um teste
  de caracterização FALHAR contra o código intocado, o E3 para e volta ao E1,
  porque a base de conhecimento está errada sobre o comportamento atual.
  Registre esse retorno em 01-CAUSA-RAIZ.md, como já se faz com o outro.

  Preserve a regra 13: durante o E3 a runx não pergunta nada.

─────────────────────────────────────────────────────────────────────
2.6 — E4 QA
─────────────────────────────────────────────────────────────────────
  Em references/04-qa.md e no TEMPLATE-qa.md, acrescente as verificações do
  modo legado:

    o raio foi calculado e escrito, com os oito sinais e método de coleta
    a faixa corresponde aos sinais, aplicando os limiares do PERFIL
    toda task respeitou o orçamento, ou o excesso está autorizado e registrado
    em MEDIO/ALTO: caracterização foi a primeira task e passou contra o código
      intocado
    em MEDIO/ALTO: toda task tem plano de reversão com os seis itens e classe
    nenhuma alteração colateral no diff — ler o diff inteiro contra o checklist
      da Camada 6
    o diff da suíte de caracterização foi analisado: toda quebra é intencional e
      justificada, ou é regressão
    o roteiro manual existe, com a seção de colateral preenchida

  E, específicas de ALTO:
    perguntas da zona respondidas e registradas antes do plano
    aprovação humana registrada com nome, data, escopo e riscos
    a comparação com dado real foi executada, com ZERO divergências não
      explicadas. Divergência não explicada REPROVA o QA: o veredito volta
      REPROVADO e a ocorrência retorna ao E3 — ou ao E1, se a divergência
      revelar caminho de código não mapeado.

  A Camada 9 também é obrigatória, em qualquer faixa, quando o tipo da
  ocorrência for regra-de-calculo: o tipo já diz que é mudança de cálculo.

  Preserve a regra 10: quem implementa não aprova, e o E4 não corrige nada.

─────────────────────────────────────────────────────────────────────
2.7 — E5 RELATÓRIO
─────────────────────────────────────────────────────────────────────
  Em references/05-relatorio.md, TEMPLATE-relatorio-tecnico.md,
  TEMPLATE-relatorio-uso.md e TEMPLATE-INDICE.md, acrescente:

  No relatório técnico:
    raio de impacto: a faixa, o sinal que a determinou, e o link relativo
    o que foi congelado por caracterização: quantos casos, o que cobrem, e os
      comportamentos surpreendentes descobertos — o item mais valioso para quem
      ler isso daqui a dois anos
    o diff da caracterização, com a task que autorizou cada mudança
    ponto de costura escolhido, com o que ele não cobre
    plano de reversão consolidado, com a classe da entrega como um todo
    comparação com dado real, quando houve: totais e padrões de divergência com
      o impacto conhecido. Nunca dado identificável
    achados registrados em DIVIDA.md durante o trabalho, com link relativo

  No relatório de uso, em linguagem de negócio:
    o que mudou de comportamento, incluindo o que deixou de acontecer
    quem é afetado e como — se a comparação encontrou registros antigos que
      passam a exibir valor diferente, isso é informação de negócio
    o roteiro de teste manual, com link relativo, como o que precisa ser
      executado antes do aceite
    como reverter, em linguagem de operação: o que acontece se precisar voltar
      atrás, quanto tempo leva, e o que não se desfaz

  No INDICE.md:
    a linha da ocorrência ganha a faixa do raio junto ao tipo, para que uma
    listagem simples mostre o histórico de risco do sistema ao longo do tempo.

─────────────────────────────────────────────────────────────────────
2.8 — O que NÃO alterar
─────────────────────────────────────────────────────────────────────
  Não altere a máquina de estados nem a detecção de estágio pelo disco.
  Não altere o contrato da task, da fase e da sprint, nem os tipos de ocorrência.
  Não altere o contrato expx-schema v1 do frontmatter.
  Não altere o contrato de entrada da ocorrência nem o portão único do E1.
  Não altere o comportamento de nenhum estágio quando PERFIL.md não existir.
  Não duplique o conteúdo dos references do legadox dentro da runx.
  Não crie estágio novo nem comando novo.

═══════════════════════════════════════════════════════════════════════
PARTE 3 — VERIFICAÇÃO ANTES DE ENCERRAR
═══════════════════════════════════════════════════════════════════════

  1. Simule um projeto SEM docs/legado/PERFIL.md e percorra os cinco estágios.
     Confirme que nada mudou em relação ao comportamento anterior ao patch.
     Qualquer diferença é defeito.
  2. Simule uma ocorrência de raio BAIXO ("corrigir o texto de um rótulo na tela
     de login"). Confirme que a runx calcula e registra o raio e NÃO aciona
     caracterização, ponto de costura, reversão, roteiro manual, comparação nem
     aprovação humana. Se acionar, corrija.
  3. Simule uma ocorrência de tipo regra-de-calculo tocando zona fiscal.
     Confirme que o E1 dispara as perguntas obrigatórias, que o E2 não gera plano
     sem as respostas, que a caracterização vem ANTES do teste de regressão, e
     que o E4 exige a comparação com dado real.
  4. Simule a ausência de ponto de costura viável e confirme que o E2 escala para
     o humano em vez de autorizar refatoração.
  5. Simule uma task que estoura o orçamento durante o E3 e confirme que ela é
     quebrada, escalada, ou registrada em BLOQUEIOS.md e pulada — nunca estourada
     em silêncio, e nunca com o E3 parando para perguntar.
  6. Simule um teste de caracterização que falha contra o código intocado e
     confirme o retorno ao E1.
  7. Confirme que o E4 reprova quando há divergência não explicada na comparação.
  8. Grep por caminho absoluto em tudo que você escreveu.
  9. Grep pelos textos de exemplo dos templates do legadox, para garantir que
     nenhum vazou para os arquivos de instrução da runx.
 10. Confirme que nenhum reference do legadox foi copiado para dentro da runx:
     a runx aponta, não duplica.

═══════════════════════════════════════════════════════════════════════
ENTREGA
═══════════════════════════════════════════════════════════════════════

Ao terminar, mostre:
  - os arquivos alterados, com o que mudou em cada um, em uma linha
  - a seção "Modo legado" do SKILL.md, tal como ficou escrita
  - as regras invioláveis acrescentadas, tal como ficaram escritas
  - a ordem final das primeiras tasks do E2 no modo legado
  - o resultado das simulações 1 a 7 da PARTE 3, resumido
  - as decisões registradas em DECISOES-DA-SKILL.md
