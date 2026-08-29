# Roteiro de teste manual — OC-2026-0184-arredondamento-icms-nota

> Exemplo preenchido, para servir de referência de qualidade.
> Sistema fictício: Gestor ERP, o mesmo de `PERFIL.exemplo.md`.
> Roteiro do trabalho descrito em `raio.exemplo.md`.

Trabalho: OC-2026-0184-arredondamento-icms-nota — Arredondamento do ICMS diverge em um centavo na emissão da nota
Faixa do raio: ALTO
O que mudou, em uma linha: o valor do ICMS passa a ser arredondado meio para cima em vez de truncado na segunda casa, apenas em notas emitidas a partir desta entrega.
Gerado em: 2026-08-27

---

## Preparação única

Ambiente onde executar: homologação, com base restaurada e anonimizada. Nunca produção.
Perfil de acesso necessário: Faturamento (emissão de nota) e Fiscal (apuração e relatórios).
Configuração que precisa estar ligada: a chave `FISCAL_ICMS_ARREDONDAMENTO_NOVO` deve estar **ligada** para os casos 1 a 5, e **desligada** para o caso 8.
Antes de começar, confirme que: existe pelo menos um cliente cadastrado com regime tributário Normal, um produto com alíquota de ICMS de 18%, e pelo menos uma nota emitida antes da data desta entrega.

---

## Caso 1 — O imposto passa a arredondar para cima quando a terceira casa é 5

**Pré-condição**
- Cliente com regime tributário Normal cadastrado.
- Produto com alíquota de ICMS de 18% cadastrado.
- A chave de arredondamento novo está ligada.

**Passos**
1. Acesse Faturamento no menu lateral.
2. Clique em Nova nota fiscal.
3. Selecione o cliente de teste.
4. Adicione o produto de teste com quantidade 1 e valor unitário 55,58.
5. Clique em Calcular.

**Resultado esperado**
O campo Valor do ICMS exibe **R$ 10,01**.
Antes desta entrega o mesmo lançamento exibia R$ 10,00.

**O que observar de colateral**
- Telas vizinhas: na Prévia da nota, antes de transmitir, o valor exibido é o mesmo R$ 10,01 da tela de emissão. Os dois não podem divergir.
- Relatórios: o Relatório fiscal por período, filtrado pelo dia de hoje, soma este mesmo valor.
- Jobs e rotinas: a apuração mensal roda no dia 1 às 03:00. **Neste intervalo ela ainda usa a regra antiga** — a divergência de um centavo entre nota e apuração é conhecida e esperada até a entrega da task das procedures. Conferir no dia 1 seguinte e confirmar que a divergência é de exatamente um centavo por nota afetada, e não maior.
- Integrações: o XML transmitido à SEFAZ precisa conter o mesmo R$ 10,01 exibido na tela. Conferir no Detalhe da nota, aba XML.
- Dado antigo: nenhuma nota emitida antes desta entrega pode ter seu valor alterado. Ver Caso 7.

**Dado de teste sugerido**
Cliente "Comércio Modelo Ltda" (fictício), regime Normal. Produto "Item de teste 001", alíquota 18%, quantidade 1, valor unitário 55,58.

Bloqueante: sim — se falhar, não sobe
Janela: executável a qualquer momento

---

## Caso 2 — O imposto continua arredondando para baixo quando a terceira casa é menor que 5

**Pré-condição**
- As mesmas do Caso 1.

**Passos**
1. Acesse Faturamento no menu lateral.
2. Clique em Nova nota fiscal.
3. Selecione o cliente de teste.
4. Adicione o produto de teste com quantidade 1 e valor unitário 55,57.
5. Clique em Calcular.

**Resultado esperado**
O campo Valor do ICMS exibe **R$ 10,00**.
Este valor é igual ao de antes da entrega: a mudança não pode afetar este caso.

**O que observar de colateral**
- Telas vizinhas: a Prévia exibe o mesmo valor.
- Relatórios: o Relatório fiscal por período soma o mesmo valor de antes para lançamentos equivalentes.
- Jobs e rotinas: nenhuma divergência esperada neste caso, porque o valor não mudou.
- Integrações: XML com o mesmo valor da tela.
- Dado antigo: nada a observar; este caso não altera comportamento.

**Dado de teste sugerido**
O mesmo cliente e produto do Caso 1, com valor unitário 55,57.

Bloqueante: sim — se falhar, não sobe
Janela: executável a qualquer momento

---

## Caso 3 — Devolução com base de cálculo negativa

**Pré-condição**
- Uma nota de venda emitida e transmitida, do cliente de teste.
- A chave de arredondamento novo está ligada.

**Passos**
1. Acesse Faturamento no menu lateral.
2. Localize a nota de venda do cliente de teste e abra o Detalhe.
3. Clique em Gerar devolução.
4. Confirme a quantidade total.
5. Clique em Calcular.

**Resultado esperado**
O campo Valor do ICMS exibe o valor negativo correspondente, com duas casas decimais, arredondado pela mesma regra da venda.

> Este caso existe porque a caracterização revelou que a regra antiga **não truncava** valores negativos. Confirme com o contador responsável qual é o valor correto esperado antes de dar o caso por aprovado.

**O que observar de colateral**
- Telas vizinhas: o Detalhe da nota de devolução exibe o mesmo valor da tela de emissão.
- Relatórios: o Relatório fiscal por período subtrai este valor corretamente do total do dia.
- Jobs e rotinas: a apuração mensal do dia 1 precisa considerar a devolução; conferir no dia seguinte.
- Integrações: XML da devolução com o mesmo valor.
- Dado antigo: devoluções emitidas antes da entrega permanecem com o valor original.

**Dado de teste sugerido**
Devolução total da nota criada no Caso 1.

Bloqueante: sim — se falhar, não sobe
Janela: executável a qualquer momento

---

## Caso 4 — Nota com múltiplos itens e alíquotas diferentes

**Pré-condição**
- Dois produtos cadastrados, um com alíquota de 18% e outro de 12%.
- A chave de arredondamento novo está ligada.

**Passos**
1. Acesse Faturamento no menu lateral.
2. Clique em Nova nota fiscal.
3. Selecione o cliente de teste.
4. Adicione o produto de 18% com quantidade 1 e valor unitário 55,58.
5. Adicione o produto de 12% com quantidade 3 e valor unitário 33,47.
6. Clique em Calcular.

**Resultado esperado**
Cada item exibe seu ICMS arredondado individualmente, e o total do ICMS da nota é a **soma dos valores já arredondados por item**, não o arredondamento da soma. Confirme que o total exibido é exatamente a soma das linhas.

**O que observar de colateral**
- Telas vizinhas: a Listagem de notas do período exibe, na coluna de imposto, o mesmo total do Detalhe.
- Relatórios: o Relatório fiscal por período traz o mesmo total.
- Jobs e rotinas: a apuração soma os itens; conferir no dia 1.
- Integrações: o XML traz o valor por item e o total; ambos precisam bater com a tela.
- Dado antigo: nada a observar.

**Dado de teste sugerido**
Produtos "Item de teste 001" (18%) e "Item de teste 002" (12%), com os valores acima.

Bloqueante: sim — se falhar, não sobe
Janela: executável a qualquer momento

---

## Caso 5 — Transmissão à SEFAZ com o valor novo

**Pré-condição**
- A nota do Caso 1, calculada e não transmitida.
- Ambiente de homologação da SEFAZ configurado.

**Passos**
1. Abra a nota do Caso 1.
2. Clique em Transmitir.
3. Aguarde o retorno do status.
4. Abra a aba XML no Detalhe da nota.

**Resultado esperado**
A nota é autorizada, e o XML contém o valor R$ 10,01 no campo de ICMS do item — o mesmo exibido na tela.

**O que observar de colateral**
- Telas vizinhas: o Detalhe da nota exibe status Autorizada e o mesmo valor.
- Relatórios: a nota autorizada aparece no Relatório fiscal por período com o valor novo.
- Jobs e rotinas: a rotina de consulta de status roda a cada 15 minutos e não pode alterar o valor; conferir 30 minutos depois que o valor permanece R$ 10,01.
- Integrações: a exportação contábil em CSV do mês precisa conter este valor; gerar a exportação e conferir a linha.
- Dado antigo: nada a observar.

**Dado de teste sugerido**
A nota criada no Caso 1.

Bloqueante: sim — se falhar, não sobe
Janela: executável a qualquer momento

---

## Caso 6 — Exportação contábil mantém o layout

**Pré-condição**
- Pelo menos uma nota emitida antes da entrega e uma emitida depois, no mesmo mês.

**Passos**
1. Acesse Fiscal no menu lateral.
2. Clique em Exportação contábil.
3. Selecione o mês corrente.
4. Clique em Gerar arquivo.
5. Abra o arquivo gerado.

**Resultado esperado**
O arquivo tem o mesmo layout de antes: mesma quantidade de colunas, mesma ordem, mesmo separador e mesmo formato de número com duas casas decimais. As notas antigas trazem o valor original; as novas, o valor pela regra nova.

**O que observar de colateral**
- Telas vizinhas: nenhuma.
- Relatórios: os totais do arquivo batem com o Relatório fiscal por período do mesmo mês.
- Jobs e rotinas: esta exportação é a que vai para o contador do cliente; qualquer mudança de layout quebra o processo dele.
- Integrações: conferir a quantidade de linhas contra a quantidade de notas do período.
- Dado antigo: as linhas de notas antigas precisam estar idênticas às de uma exportação gerada antes da entrega. Compare os dois arquivos.

**Dado de teste sugerido**
Mês corrente da base de homologação.

Bloqueante: sim — se falhar, não sobe
Janela: executável a qualquer momento

---

## Caso 7 — Registro antigo continua exibindo o valor de antes

> Caso obrigatório: a mudança toca cálculo. Em legado é aqui que a regressão aparece —
> o novo funciona e o histórico quebra.

**Pré-condição**
- Uma nota emitida antes da data desta entrega, com valor de ICMS conhecido e anotado.

**Passos**
1. Acesse Faturamento no menu lateral.
2. Clique em Listagem de notas.
3. Filtre por um período anterior à data da entrega.
4. Abra o Detalhe de uma nota conhecida.

**Resultado esperado**
O valor do ICMS exibido é **exatamente o mesmo** anotado antes da entrega. Nenhuma nota anterior à entrega pode ter seu valor alterado.

**O que observar de colateral**
- Telas vizinhas: a Listagem exibe o mesmo valor do Detalhe.
- Relatórios: o Relatório fiscal do período anterior fecha com o mesmo total de antes da entrega. Compare com um relatório gerado antes.
- Jobs e rotinas: a apuração de competência já encerrada não pode ser alterada.
- Integrações: o XML já transmitido permanece intocado.
- Dado antigo: este caso É a verificação do dado antigo.

**Dado de teste sugerido**
Uma nota de competência anterior, com valor anotado antes da subida.

Bloqueante: sim — se falhar, não sobe
Janela: executável a qualquer momento

---

## Caso 8 — A chave desligada restaura o comportamento anterior

**Pré-condição**
- A chave `FISCAL_ICMS_ARREDONDAMENTO_NOVO` **desligada**.
- Solicite ao responsável pelo ambiente que desligue a chave antes deste caso.

**Passos**
1. Acesse Faturamento no menu lateral.
2. Clique em Nova nota fiscal.
3. Selecione o cliente de teste.
4. Adicione o produto de teste com quantidade 1 e valor unitário 55,58.
5. Clique em Calcular.

**Resultado esperado**
O campo Valor do ICMS exibe **R$ 10,00** — o comportamento anterior à entrega, restaurado sem novo deploy.

**O que observar de colateral**
- Telas vizinhas: a Prévia exibe o mesmo R$ 10,00.
- Relatórios: o Relatório fiscal do dia soma o valor antigo.
- Jobs e rotinas: a transmissão precisa levar o valor antigo ao XML.
- Integrações: XML com R$ 10,00.
- Dado antigo: notas emitidas com a chave ligada permanecem com o valor novo — a chave não recalcula o passado. Este é o efeito que a reversão não desfaz.

**Dado de teste sugerido**
O mesmo lançamento do Caso 1.

Bloqueante: sim — se falhar, a entrega não sobe, porque a reversão sem deploy é condição da aprovação
Janela: executável a qualquer momento

---

## Registro do resultado

| Caso | Executado por | Data | Resultado | Observação |
|---|---|---|---|---|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |
| 4 | | | | |
| 5 | | | | |
| 6 | | | | |
| 7 | | | | |
| 8 | | | | |
