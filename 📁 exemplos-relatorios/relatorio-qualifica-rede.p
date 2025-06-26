/* Projeto: Geração de relatório de produção por município
   Linguagem: Progress 4GL
   Desenvolvido por: Liliane Becker
   Objetivo: Ler códigos de procedimentos e gerar relatório de produção agrupado por cidade
*/

DEF STREAM ST-ARQUIVO.
DEF VAR C-ARQUIVO      AS CHAR INITIAL "" NO-UNDO.
DEF VAR w01-tipo       AS INT FORMAT "9".
def var w01-prestador-copia as int format "999999".
def var         sequencia       as int format "9999".
def var         w01-tabela      AS CHAR FORMAT "X(08)".

DEF TEMP-TABLE TABELA-DADOS NO-UNDO
      FIELD w01-sequencia                     AS INT FORMAT "9999"
      FIELD W01-procedimeNTO                  AS CHAR FORMAT "x(08)"
      FIELD w01-descricao                     AS CHAR FORMAT "X(30)" 
      FIELD w01-especialidade                 LIKE preserv.cd-esp-resid   
      FIELD w01-bage                          AS INT FORMAT "99999"
      FIELD w01-dom-pedrito                   as int format "99999"
      FIELD w01-lavras                        as int format "99999"
      FIELD w01-candiota                      as int format "99999"
      FIELD w01-acegua                        as int format "99999"
      FIELD w01-pinheiro-machado              as int format "99999"
      FIELD w01-outros                        as int format "99999"
      FIELD w01-pelotas                       as int format "99999"
      FIELD w01-hulha                         as int format "99999"
      FIELD w01-poa                           as int format "99999"
      FIELD w01-total                         as int format "9999999"    
      
INDEX tabela-dados IS PRIMARY UNIQUE w01-sequencia w01-procedimento.
       
FORM "Mensagem: "AT ROW  2 COLUMN 5 COLON-ALIGNED
    WITH FRAME f-janela3d
    TITLE "Gerando Relatório"
    THREE-D SIDE-LAB VIEW-AS DIALOG-BOX SIZE 50 BY 5.

UPDATE " Processando Aguarde ... " WITH FRAME f-janela3d.

/*-------------------------------------------------------------*
 Localizacao do depara
--------------------------------------------------------------*/
 
def var         c_local_entrada    AS CHAR no-undo.

assign c_local_entrada = "d:\qualifica\codigos.txt".

input from value(c_local_entrada).

REPEAT:

create tabela-dados.

sequencia = sequencia + 1.

IMPORT delimiter ";"
    
        W01-PROCEDIMENTO.
        
        w01-sequencia  = sequencia.
             
END.

/*-------------------------------------------------------------*/

ASSIGN C-ARQUIVO = "d:\qualifica\2022\GRC_001.CSV".

OUTPUT STREAM ST-ARQUIVO TO VALUE (C-ARQUIVO). 
      
PUT STREAM ST-ARQUIVO
"sequencia;Procedimento;Descricao ;total ;Cidade1;Cidade2;Cidade3;Cidade4;Cidade5;Cidade6;Cidade7; Outros;"
skip.
   		  				
FOR EACH docrecon where docrecon.dt-anoref = 2023
                  /*  and docrecon.nr-perref = 10 */
                      and docrecon.cd-unidade-prestadora = 0999  NO-LOCK:

 for each moviproc where moviproc.cd-unidade                 = docrecon.cd-unidade  
                       and moviproc.cd-unidade-prestadora    = docrecon.cd-unidade-prestadora
                       and moviproc.cd-transacao             = docrecon.cd-transacao 
                       and moviproc.nr-serie-doc-original    = docrecon.nr-serie-doc-original 
                       and moviproc.nr-doc-original          = docrecon.nr-doc-original 
                       and moviproc.nr-doc-sistema           = docrecon.nr-doc-sistema 
                       and moviproc.cd-modulo                < 500                        
                          no-lock: 

  IF moviproc.in-liberado-pagto <> "1"
   THEN
     NEXT.

  FIND   preserv
    WHERE preserv.cd-prestador = moviproc.cd-prestador
    AND   preserv.cd-unidade   = 0999 NO-LOCK NO-ERROR.
    
    IF AVAIL preserv
     THEN DO:  
     
/*---------------------------------------------------------------------*/

      FIND endpres
       WHERE  endpres.cd-unidade     = preserv.cd-unidade                 
       AND    endpres.cd-prestador   = preserv.cd-prestador                
       AND    endpres.nr-seq-endereco = 1 NO-LOCK NO-ERROR.  
      
      IF NOT AVAIL endpres
        THEN
          NEXT.
          
      FIND dzcidade
       WHERE dzcidade.cd-cidade =  endpres.cd-cidade NO-LOCK NO-ERROR. 
       
       IF NOT AVAIL dzcidade
         THEN
           PUT STREAM ST-ARQUIVO  preserv.cd-prestador                                   
                                  preserv.cd-cidade at 01.
                       
/*---------------------------------------------------------------------*/      

     w01-tabela = string(moviproc.cd-esp-amb,"99") +
                  string(moviproc.cd-grupo-proc-amb,"99") +
                  string(moviproc.cd-procedimento,"999") +
                  string(moviproc.dv-procedimento,"9"). 
 
        FIND TABELA-DADOS
          WHERE w01-procedimento = w01-tabela NO-LOCK NO-ERROR.
   
         IF AVAIL tabela-dados
          THEN DO:
                         
          IF endpres.cd-cidade = 096400 
          OR endpres.cd-cidade = 096410
             THEN DO:              
                w01-bage = w01-bage + qt-procedimento.  
                           
             END.
             
             IF endpres.cd-cidade = 096450 
             OR endpres.cd-cidade = 068837
               THEN DO:
                 w01-dom-pedrito = w01-dom-pedrito + qt-procedimento.
                          
                END.
                
                IF endpres.cd-cidade = 096495  
                   THEN DO:
                    w01-candiota = w01-candiota + qt-procedimento.
                            
                  END.
                    
                    IF endpres.cd-cidade = 096445
                       THEN DO:
                        w01-acegua = w01-acegua + qt-procedimento.
                                 
                       END.
                       
                        IF endpres.cd-cidade = 096470
                         OR endpres.cd-cidade = 096020
                           THEN DO:
                           w01-pinheiro-machado = w01-pinheiro-machado + qt-procedimento.
                                           
                          END.

                           IF endpres.cd-cidade = 097390
                              THEN DO:
                              w01-lavras = w01-lavras + qt-procedimento.
                                             
                                END. 
                               
                                 IF endpres.cd-cidade = 090000
                                    THEN DO:
                                    w01-outros = w01-outros + qt-procedimento.
                                              
                                    END.

                                     IF endpres.cd-cidade = 096460
                                      THEN DO:
                                        w01-hulha = w01-hulha + qt-procedimento.
                                                                               
                                      END.
                                      
                 w01-total = w01-total + qt-procedimento.                     
                                        
        END.     
            
/*------------------------------*/
 
  END.
  
 END.
      
END. 

FOR EACH tabela-dados where w01-procedimento <> "" NO-LOCK. 
   
   FIND ambproc
      WHERE  cd-esp-amb           = INT(SUBSTR(STRING(w01-procedimento,"99999999"),1,2))
      AND    cd-grupo-proc-amb    = INT(SUBSTR(STRING(w01-procedimento,"99999999"),3,2))
      AND    cd-procedimento      = INT(SUBSTR(STRING(w01-procedimento,"99999999"),5,3))
      AND    dv-procedimento      = INT(SUBSTR(STRING(w01-procedimento,"99999999"),8,1)) NO-LOCK NO-ERROR.
      
 IF  AVAIL ambproc
     THEN 
     
     w01-descricao   =  ambproce.ds-procedimento[1].
   
   ELSE
   
    w01-descricao = "".
      
          put STREAM ST-ARQUIVO
                  w01-sequencia   
                  ";"
                  w01-procedimento   
                  ";"
                  w01-descricao      
                  ";"
                  w01-total  
                  ";"             
                  w01-cidade1          
                  ";"                
                  w01-cidade2        
                  ";"                
                  w01-cidade3      
                  ";"                 
                  w01-cidade4   
                  ";"                 
                  w01-cidade5          
                  ";"                
                  w01-cidade6        
                  ";"                
                  w01-cidade7
                  ";"                            
                  w01-outros                    
                                                       
                 SKIP.
                       
END.

OUTPUT STREAM st-arquivo CLOSE.

MESSAGE "Final de Relatório" 
    VIEW-AS ALERT-BOX.
    DOS SILENT notepad d:\qualifica\2023\GRC_001.CSV.
    
    HIDE ALL NO-PAUSE.
    LEAVE.
