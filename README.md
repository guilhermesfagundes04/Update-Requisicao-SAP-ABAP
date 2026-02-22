# Update-Requisicao-SAP-ABAP

**Objetivo** 

Programa para atualizar quantidade da requisição. Irá listar as requisições conforme a seleção, permitindo alterar a quantidade. Após a edição, através de um botão, irá atualizar as requisições via BAPI. 

**Detalhamento** 

**Processos** 

    * Criar uma função – Nome: ZFM<iniciais>_SBUPD_REQ 
          * Receber Parâmetro único 
              * EBAN-BANFN (requisição) 
              * EBAN-BNFPO (item requisição)
              * Nova Quantidade 

Retornar Parâmetro único 

Resultado (char, 200) 

Regra 

Executar BAPI ‘BAPI_PR_CHANGE’ para modificar a quantidade. Se houver erro, concatenar os retornos de erro na mesma mensagem. Se não, retornar ‘Sucesso’. 

Criar um relatório ALV (report) – Nome: ZR<iniciais>_SBUPDATE_REQ 

Opções de seleção:  

Data Solicitação (EBAN-BADAT) – Obrigatório 

Requisição (EBAN-BANFN) 

Material (EBAN-MATNR) 

Regra:  

Tabelas EBAN (Requisição Compra), MARA (material), MAKT (descrições materiais),  

Buscas: 

EBAN (com os filtros de data, requisição e material) 

MARA (a partir da tabela EBAN, utilizando o campo MATNR) 

MAKT (a partir da tabela MARA, utilizando o campo MATNR como chave principal e campo SPRAS = sy-langu). 

Funcionalidade 

Checkbox para seleção de linhas 

Campo “Qtd Nova” Editável. 

Quando este campo for modificado e diferente de EBAN-MENGE e >= 0, deve automaticamente marcar o checkbox. Caso seja igual, desmarcar. 

Adicionar botão na barra de tarefas do ALV com o label: “Modificar requisições”. 

Quando clicado neste botão, irá verificar as linhas com o ckeckbox marcado (linhas selecionadas) e executar a FM ZFM<iniciais>_SBUPD_REQ para modificar a quantidade, armazenar resultado para exibição de log. 

Após a gravação, exibir novo ALV com o log, contendo o uma coluna de ícones sinalizando erro, sucesso ou alerta. 

Validações 

Se requisição estiver marcada pra eliminar (EBAN-LOEKZ = ‘X’), e tentar modificar a quantidade, deve mostrar no log “Requisição eliminada. Não é possível modificar” e não efetuar atualização, sinalizando alerta. 

Se alguma linha estiver marcada para edição, porém a coluna “Qtd Nova” = 0 ou EBAN-MENGE, não atualizar exibindo “Quantidade <0 ou igual a atual>. Não é possível modificar”, sinalizando com alerta. 

Exibição Principal 

Checkbox 

EBAN-BANFN (requisição) 

EBAN-BNFPO (item requisição) 

EBAN-BADAT (data solicitação) 

EBAN-LOEKZ (requisição eliminado) 

EBAN-MATNR (material) 

MAKT-MAKTX (desc. Material) 

EBAN-AFNAM (requisitante) 

EBAN-MENGE (quantidade) 

Qtd Nova. 

EBAN-MEINS (unidade medida) 

Exibição Log 

Ícone (Erro, Alerta, Sucesso) 

EBAN-BANFN (requisição) 

EBAN-BNFPO (item requisição) 

EBAN-BADAT (data requisição) 

EBAN-MATNR (material) 

Quantidade Nova 

Quantidade Anterior 

Resultado 
