* Faço meu formulário de busca (SELECTS) começar sempre do macro pro micro. *
FORM zf_busca.

  SELECT banfn, bnfpo, badat, loekz, matnr, afnam, menge, meins "SELECIONO esses atributos
    FROM eban                                                   "DA TABELA eban
    INTO CORRESPONDING FIELDS OF TABLE @gt_eban                 "EM CAMPOS CORRESPONDENTES DA TABELA gt_eban
    WHERE badat IN @s_badat                                     "ONDE badat está EM seleção s_badat
      AND banfn IN @s_banfn                                     "E banfn está EM seleção s_banfn
      AND matnr IN @s_matnr.                                    "E matnr está EM seleção s_matnr.

  IF sy-subrc IS INITIAL.                                       "SE sy-subrc É INICIAL (valor padrão = 0).

    SELECT matnr                                                "SELECIONO esses atributos
      FROM mara                                                 "DA TABELA mara
      INTO CORRESPONDING FIELDS OF TABLE @gt_mara               "EM CAMPOS CORRESPONDENTES DA TABELA gt_mara
      FOR ALL ENTRIES IN @gt_eban                               "PARA TODAS AS ENTRADAS EM gt_eban
      WHERE matnr EQ @gt_eban-matnr.                            "ONDE matnr IGUAL A gt_eban-matnr.

    SELECT matnr, spras, maktx                                  "SELECIONO ESSES ATRIBUTOS
      FROM makt                                                 "DA TABELA makt
      INTO CORRESPONDING FIELDS OF TABLE @gt_makt               "EM CAMPOS CORRESPONDENTES DA TABELA gt_makt
      FOR ALL ENTRIES IN @gt_mara                               "PARA TODAS AS ENTRADAS EM gt_mara
      WHERE matnr EQ @gt_mara-matnr                             "ONDE matnr IGUAL A gt_mara-matnr
        AND spras EQ @sy-langu.                                 "E spras IGUAL A sy-langu.

  ENDIF.                                                        "Fim do IF (sy-subrc).

  PERFORM zf_ordenacao.                                         "EXECUTAR FORM zf_ordenacao.

ENDFORM.                                                        "Fim do FORM zf_busca.

* Faço meu formulário de ordenação (SORT). *
FORM zf_ordenacao.

  SORT: gt_eban BY banfn, "ORDENAR tabela gt_eban POR esse campo em ordem CRESCENTE.
        gt_mara BY matnr, "ORDENAR tabela gt_mara POR esse campo em ordem CRESCENTE.
        gt_makt BY matnr. "ORDENAR tabela gt_makt POR esse campo em ordem CRESCENTE.

ENDFORM. "Fim do FORM zf_ordenacao.

* Faço meu formulário de tratamento (LÓGICA). *
FORM zf_tratamento.

  FREE gt_saida.                                          "LIMPAR tabela interna global gt_saida.

* Criação dos meus FIELD-SYMBOLS (SÍMBOLOS DE CAMPO). *
  FIELD-SYMBOLS: <fs_saida> TYPE ty_saida,
                 <fs_eban>  TYPE ty_eban,
                 <fs_mara>  TYPE ty_mara,
                 <fs_makt>  TYPE ty_makt.

  LOOP AT gt_eban ASSIGNING <fs_eban>.                    "LAÇO EM gt_eban ATRIBUINDO fs_eban (do macro pro micro).

    APPEND INITIAL LINE TO gt_saida ASSIGNING <fs_saida>. "ANEXAR NA LINHA INICIAL A gt_saida ATRIBUINDO fs_saida.
    <fs_saida>-banfn = <fs_eban>-banfn.                   "fs_saida-banfn IGUAL fs_eban-banfn (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NA TELA).
    <fs_saida>-bnfpo = <fs_eban>-bnfpo.                   "fs_saida-bnfpo IGUAL fs_eban-bnfpo (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NA TELA).
    <fs_saida>-badat = <fs_eban>-badat.                   "fs_saida-badat IGUAL fs_eban-badat (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NA TELA).
    <fs_saida>-loekz = <fs_eban>-loekz.                   "fs_saida-loekz IGUAL fs_eban-loekz (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NA TELA).
    <fs_saida>-matnr = <fs_eban>-matnr.                   "fs_saida-matnr IGUAL fs_eban-matnr (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NA TELA).
    <fs_saida>-afnam = <fs_eban>-afnam.                   "fs_saida-afnam IGUAL fs_eban-afnam (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NA TELA).
    <fs_saida>-menge = <fs_eban>-menge.                   "fs_saida-menge IGUAL fs_eban-menge (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NA TELA).
    <fs_saida>-meins = <fs_eban>-meins.                   "fs_saida-meins IGUAL fs_eban-meins (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NA TELA).

* Leitura da tabela gt_mara ATRIBUINDO field-symbol fs_mara COM CHAVE matnr IGUAL a fs_eban-matnr em PESQUISA BINÁRIA. *
    READ TABLE gt_mara ASSIGNING <fs_mara>
                       WITH KEY matnr = <fs_eban>-matnr
                       BINARY SEARCH.
    IF sy-subrc IS INITIAL.                               "SE sy-subrc É INICIAL (valor padrão = 0).
* Leitura da tabela gt_makt ATRIBUINDO field-symbol fs_makt COM CHAVE matnr IGUAL a fs_mara-matnr em PESQUISA BINÁRIA. *
      READ TABLE gt_makt ASSIGNING <fs_makt>
                         WITH KEY matnr = <fs_mara>-matnr
                         BINARY SEARCH.
      IF sy-subrc IS INITIAL.                             "SE sy-subrc É INICIAL (valor padrão = 0).
        <fs_saida>-maktx = <fs_makt>-maktx.               "fs_saida-maktx IGUAL fs_makt-maktx (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NA TELA).
      ENDIF.                                              "Fim do IF (sy-subrc).
    ENDIF.                                                "Fim do IF (sy-subrc principal).

  ENDLOOP.                                                "Fim do LOOP.

ENDFORM.                                                  "Fim do FORM zf_tratamento.

* Faço meu formulário de requisições modificadas. *
FORM zf_modificados.

* Declaração da variável local para utilizar no FORM. *
  DATA: lv_result TYPE c LENGTH 200.

* Criação dos meus FIELD-SYMBOLS (SÍMBOLOS DE CAMPO). *
  FIELD-SYMBOLS: <fs_saida> TYPE ty_saida,
                 <fs_log>   TYPE ty_log.

  LOOP AT gt_saida ASSIGNING <fs_saida>.                                                "LAÇO EM gt_saida ATRIBUINDO fs_saida.

    IF <fs_saida>-checkbox <> 'X'.                                                      "SE fs_saida-checkbox FOR DIFERENTE DE 'X'.
      CONTINUE.                                                                         "CONTINUE (pula a próxima iteração do LOOP).
    ENDIF.                                                                              "Fim do IF (checkbox).

    APPEND INITIAL LINE TO gt_log ASSIGNING <fs_log>.                                   "ANEXAR NA LINHA INICIAL A gt_log ATRIBUINDO fs_log.

    <fs_log>-badat        = <fs_saida>-badat.                                           "fs_log-badat        IGUAL fs_saida-badat    (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NO LOG).
    <fs_log>-banfn        = <fs_saida>-banfn.                                           "fs_log-banfn        IGUAL fs_saida-banfn    (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NO LOG).
    <fs_log>-bnfpo        = <fs_saida>-bnfpo.                                           "fs_log-bnfpo        IGUAL fs_saida-bnfpo    (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NO LOG).
    <fs_log>-matnr        = <fs_saida>-matnr.                                           "fs_log-matnr        IGUAL fs_saida-matnr    (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NO LOG).
    <fs_log>-qtd_anterior = <fs_saida>-menge.                                           "fs_log-qtd_anterior IGUAL fs_saida-menge    (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NO LOG).
    <fs_log>-qtd_nova     = <fs_saida>-qtd_nova.                                        "fs_log-qtd_nova     IGUAL fs_saida-qtd_nova (ATRIBUINDO AO MEU FIELD-SYMBOL DE SAÍDA O QUE QUERO EXIBIR NO LOG).

    IF <fs_saida>-loekz = 'X'.                                                          "SE fs_saida-loekz FOR IGUAL A 'X'.
      <fs_log>-resultado = 'Requisição eliminada. Não é possível modificar'.            "fs_log-resultado IGUAL A STRING DE REQUISIÇÃO ELIMINADA.
      <fs_log>-icone = icon_message_warning.                                            "fs_log-icone IGUAL A ÍCONE DE ALERTA.
    ELSEIF <fs_saida>-qtd_nova = 0 OR <fs_saida>-qtd_nova = <fs_saida>-menge.           "SENÃO SE fs_saida-qdt_nova IGUAL A 0 OU fs_saida-qtd_nova IGUAL A fs_saida-menge.
      <fs_log>-resultado = 'Quantidade <0 ou igual a atual>. Não é possível modificar'. "fs_log-resultado IGUAL A STRING DE QUANTIDADE <0.
      <fs_log>-icone = icon_message_warning.                                            "fs_log_icone IGUAL A ÍCONE DE ALERTA.
    ELSE.                                                                               "SENÃO

      CALL FUNCTION 'ZFMGSF_SBUPD_REQ'                                                  "CHAMAR FUNÇÃO 'ZFMGSF_SBUPD_REQ' - Criada na SE37
        EXPORTING                                                                       "EXPORTANDO parâmetros de 'importação'
          id_banfn     = <fs_saida>-banfn                                               "id_banfn IGUAL A fs_saida-banfn
          id_bnfpo     = <fs_saida>-bnfpo                                               "id_banfn IGUAL A fs_saida-banfn
          id_nova_qtd  = <fs_saida>-qtd_nova                                            "id_banfn IGUAL A fs_saida-banfn
        IMPORTING                                                                       "IMPORTANDO parâmetro de 'exportação'
          ed_resultado = lv_result.                                                     "ed_result IGUAL A variável local lv_result.
      <fs_log>-resultado = lv_result.                                                   "fs_log-resultado IGUAL A lv_result.
      <fs_log>-icone = icon_checked.                                                    "fs_log-icone IGUAL A ÍCONE DE CERTINHO.
    ENDIF.                                                                              "Fim do IF (loekz).

  ENDLOOP.                                                                              "Fim do LOOP.

  CALL SCREEN 0200.                                                                     "CHAMAR TELA 0200.

ENDFORM.                                                                                "Fim do FORM zf_modificados.

* Faço meu formulário para exibição do ALV LOG. *
FORM zf_display_log.

  IF go_cc_log IS INITIAL.             "SE meu OBJETO GLOBAL go_cc_log FOR INICIAL (tem seu valor padrão).

    CREATE OBJECT go_cc_log            "CRIAR OBJETO go_cc_log (INSTANCIANDO UMA CLASSE).
      EXPORTING                        "EXPORTANDO.
        container_name = 'LOG'.        "container_name IGUAL a 'LOG' (nome do custom control que criei no LAYOUT da minha tela 200).
    CREATE OBJECT go_alv_log           "CRIAR OBJETO go_alv_log (INSTANCIANDO UMA CLASSE).
      EXPORTING                        "EXPORTANDO
        i_parent = go_cc_log.          "i_parent(CONTAINER PAI) IGUAL a go_cc_log.

* Declaração de tabela interna local e estrutura local de fieldcat para "configuração" das colunas *
    DATA: lt_fieldcat TYPE lvc_t_fcat,
          ls_fieldcat TYPE lvc_s_fcat.

* Monta o catálogo de campos, definindo nome e tamanho *
    FREE ls_fieldcat.
    ls_fieldcat-fieldname = 'ICONE'.
    ls_fieldcat-coltext   = 'Status'.
    ls_fieldcat-outputlen = 15.
    APPEND ls_fieldcat TO lt_fieldcat.

    FREE ls_fieldcat.
    ls_fieldcat-fieldname = 'BANFN'.
    ls_fieldcat-coltext   = 'Requisição'.
    ls_fieldcat-outputlen = 15.
    APPEND ls_fieldcat TO lt_fieldcat.

    FREE ls_fieldcat.
    ls_fieldcat-fieldname = 'BNFPO'.
    ls_fieldcat-coltext   = 'Item Requisição'.
    ls_fieldcat-outputlen = 15.
    APPEND ls_fieldcat TO lt_fieldcat.

    FREE ls_fieldcat.
    ls_fieldcat-fieldname = 'BADAT'.
    ls_fieldcat-coltext   = 'Data Requisição'.
    ls_fieldcat-outputlen = 15.
    APPEND ls_fieldcat TO lt_fieldcat.

    FREE ls_fieldcat.
    ls_fieldcat-fieldname = 'MATNR'.
    ls_fieldcat-coltext   = 'Material'.
    ls_fieldcat-outputlen = 15.
    APPEND ls_fieldcat TO lt_fieldcat.

    FREE ls_fieldcat.
    ls_fieldcat-fieldname = 'QTD_NOVA'.
    ls_fieldcat-coltext   = 'Quantidade nova'.
    ls_fieldcat-outputlen = 10.
    APPEND ls_fieldcat TO lt_fieldcat.

    FREE ls_fieldcat.
    ls_fieldcat-fieldname = 'QTD_ANTERIOR'.
    ls_fieldcat-coltext   = 'Quantidade anterior'.
    ls_fieldcat-outputlen = 10.
    APPEND ls_fieldcat TO lt_fieldcat.

    FREE ls_fieldcat.
    ls_fieldcat-fieldname = 'RESULTADO'.
    ls_fieldcat-coltext   = 'Resultado'.
    ls_fieldcat-outputlen = 100.
    APPEND ls_fieldcat TO lt_fieldcat.

* Chamada para exibição do ALV LOG *
    CALL METHOD go_alv_log->set_table_for_first_display         "MÉTODO DE CHAMADA go_alv_LOG ACESSANDO o método set_table_for_first_display.
      EXPORTING                                                 "EXPORTANDO
        is_layout       = VALUE lvc_s_layo( zebra = abap_true ) "is_layout IGUAL a VALOR lvc_s_layo ( zebra = abap_true ).
      CHANGING                                                  "MUDANDO
        it_outtab       = gt_log                                "it_outtab IGUAL a gt_log.
        it_fieldcatalog = lt_fieldcat.                          "it_fieldcatalog IGUAL a lt_fieldcat.

  ENDIF.                                                        "Fim do IF (go_cc_log).

ENDFORM.                                                        "Fim do FORM zf_display_log.
