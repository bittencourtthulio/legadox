# Instruções do agente — modo legado

Este projeto pode estar sob **modo legado**. O gatilho é um arquivo:

```
docs/legado/PERFIL.md existe   →  modo legado ATIVO
docs/legado/PERFIL.md ausente  →  nada disto se aplica
```

**Antes de qualquer alteração de código, verifique se `docs/legado/PERFIL.md` existe.**

Se existir, acione a skill `legadox` antes de tocar em qualquer arquivo — antes de planejar, antes de editar, antes de corrigir o que parece óbvio. A skill vive em `.claude/skills/legadox/` no Claude Code e em `.opencode/skills/legadox/` no OpenCode; o instalador materializa as duas a partir da mesma fonte.

Se não existir, trabalhe normalmente. O legadox não interfere em nada.

## Por que isso existe

Em código legado o comportamento atual é o contrato, bugs inclusive, porque existe cliente dependendo do jeito errado há anos. Nada é alterado antes de estar congelado por teste, e nada é tocado além do que o raio de impacto autorizou.

## O que o legadox faz

Não é um método novo. É uma camada que endurece as skills `sprintx` (features, fases F1 a F6) e `runx` (manutenção, estágios E1 a E5). A sequência de fases não muda; muda o rigor de cada uma.

O peso é proporcional ao risco. O **raio de impacto** é calculado por evidência antes de qualquer plano, e é ele que decide o que é acionado:

- **BAIXO** — o raio é registrado e o fluxo segue como hoje, sem camada extra.
- **MEDIO** — testes de caracterização, ponto de costura, orçamento por task, plano de reversão, roteiro de teste manual.
- **ALTO** — tudo do MEDIO, mais perguntas obrigatórias da zona antes do plano, comparação com dado real, feature flag e aprovação humana registrada.

## Regras invioláveis

1. Sem `docs/legado/PERFIL.md` não existe modo legado. A primeira coisa é gerá-lo.
2. Nenhum plano é gerado sem o raio de impacto calculado e escrito.
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

## Proibições que valem em qualquer faixa, inclusive BAIXO

Em arquivo tocado, é proibido: renomear fora do escopo, reformatar, rodar corretor automático de estilo, reorganizar imports, atualizar dependência, converter sintaxe antiga, extrair método não previsto no plano, remover código morto ou comentado, e "aproveitar e corrigir" outro problema percebido.

Um diff de 400 linhas de formatação esconde as 3 que importam, e revisão humana é a única defesa que sobra em legado.

O que você identificar como problema vai para `docs/legado/DIVIDA.md`: arquivo, o que foi visto, por que incomoda, risco de mexer. Registro, nunca correção.

## Hooks: as regras são mecânicas, não lembradas

Se o modo legado estiver ativo, parte destas regras é verificada por hook — script que o harness executa, não o modelo. Duas consequências práticas:

- **Nenhum hook roda em raio BAIXO.** Trabalho de baixo risco não sente atrito nenhum.
- **Dois hooks bloqueiam de verdade**, e não adianta insistir: escrita em zona de risco sem as perguntas respondidas, e implementação em raio ALTO sem aprovação humana registrada. Quando um deles barra, a mensagem diz o que fazer — o caminho é cumprir a etapa, nunca contornar o hook.

Os demais (`raio-antes-do-plano`, `caracterizacao-antes`, `orcamento-de-mudanca`, `reversao-declarada`, `sem-colateral`) nascem em modo aviso: registram e explicam, sem barrar. Aviso de hook não é ruído — é a regra dizendo que algo saiu do método.

Nunca edite os hooks para se livrar de um bloqueio. Se um hook está errado, isso é um achado: registre e diga ao usuário.

## Agentes

Duas partes do método rodam em agente próprio, com escrita restrita:

- **`cartografo`** — gera o `PERFIL.md` e prova que o código está vivo. Escreve só em `docs/legado/`.
- **`avaliador-de-raio`** — calcula o raio de impacto. Escreve só em `docs/legado/raio/`.

O `avaliador-de-raio` é separado de propósito: quem implementa tem interesse em raio baixo, porque raio alto dá mais trabalho. Não calcule o raio você mesmo quando o agente estiver disponível.

## Comandos

| Comando | O que faz |
|---|---|
| `/legadox` | roteador: verifica o modo legado e mostra o que falta no trabalho atual |
| `/legadox-perfil` | gera ou atualiza o `PERFIL.md` |
| `/legadox-raio` | calcula o raio de impacto de um trabalho |
| `/legadox-caracterizar` | escreve os testes de caracterização |
| `/legadox-manual` | gera o roteiro de teste manual |
| `/legadox-divida` | consulta e acrescenta ao `DIVIDA.md` |
