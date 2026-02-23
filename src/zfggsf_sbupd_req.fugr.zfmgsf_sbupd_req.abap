FUNCTION zfmgsf_sbupd_req.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(ID_BANFN) TYPE  EBAN-BANFN
*"     REFERENCE(ID_BNFPO) TYPE  EBAN-BNFPO
*"     REFERENCE(ID_NOVA_QTD)
*"  EXPORTING
*"     REFERENCE(ED_RESULTADO) TYPE  CHAR200
*"----------------------------------------------------------------------

  DATA: ls_prheader  TYPE bapimereqheader,
        ls_prheaderx TYPE bapimereqheaderx,
        ls_pritem    TYPE bapimereqitemimp,
        ls_pritemx   TYPE bapimereqitemx,
        lt_pritem    TYPE STANDARD TABLE OF bapimereqitemimp,
        lt_pritemx   TYPE STANDARD TABLE OF bapimereqitemx,
        lt_return    TYPE STANDARD TABLE OF bapiret2,
        ls_return    TYPE bapiret2,
        lv_erro      TYPE string,
        lv_werks     TYPE eban-werks.

  "Busca o centro do registro selecionado
  SELECT SINGLE werks
    INTO lv_werks
    FROM eban
    WHERE banfn = id_banfn
      AND bnfpo = id_bnfpo.

  IF sy-subrc IS NOT INITIAL.
    ed_resultado = 'Erro: Centro não encontrado para a requisição'.
    RETURN.
  ENDIF.

  "Preencher PRHEADER e PRHEADERX
  CLEAR: ls_prheader,
         ls_prheaderx.

  ls_prheader-preq_no  = id_banfn.
  ls_prheaderx-preq_no = abap_true.

  "Preencher item com nova quantidade
  lt_pritem = VALUE #(
   ( preq_item = id_bnfpo
     plant     = lv_werks
     quantity  = id_nova_qtd ) ).

  "Preencher itemx para sinalizar campo alterado
  lt_pritemx = VALUE #(
   ( preq_item = id_bnfpo
     quantity  = abap_true
     plant     = abap_true ) ).

  "Chamar a BAPI
  CALL FUNCTION 'BAPI_PR_CHANGE'
    EXPORTING
      number    = id_banfn
      prheader  = ls_prheader
      prheaderx = ls_prheaderx
*     testrun   = 'X'   " Ativar para teste
    TABLES
      pritem    = lt_pritem
      pritemx   = lt_pritemx
      return    = lt_return.

  "Verificar mensagens de erro
  LOOP AT lt_return INTO ls_return.
    IF ls_return-type = 'E' OR ls_return-type = 'A'.
      lv_erro = |{ lv_erro } / { ls_return-message }|.
    ENDIF.
  ENDLOOP.

  IF lv_erro IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
    ed_resultado = 'Sucesso'.
  ELSE.
    ed_resultado = lv_erro.
  ENDIF.

ENDFUNCTION.
