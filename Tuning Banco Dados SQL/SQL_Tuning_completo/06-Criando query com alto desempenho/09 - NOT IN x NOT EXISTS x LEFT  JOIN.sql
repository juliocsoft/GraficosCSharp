/*
Quando utilizar NOT IN ou NOT EXISTS 

- Os operadores NOT INT e NOT EXISTS s�o operadores de nega��o que trabalham com um 
  subconjuntos de dados. 

- O operador l�gico IN valida se a express�o informada est� contida dentro de 
  de valores de uma subconsulta ou dentro de uma lista de valores.

  Where <express�o> IN (<subconsulta> ou <Lista de valores>)

- O operador l�gico EXISTS valida se uma subconsulta tem a exist�ncias de linhas.

  Where EXISTS (<subconsulta>)

- O operador l�gico IN avalia os tr�s valores poss�veis para testar a express�o: 

   - Verdadeiro, quando a express�o est� contida nos valores da subconsulta ou
     v�lida para um item de uma lista.
   - Falso, quando a express�o n�o est� contida nos valores da subsconsulta ou 
     inv�lida para um item de uma lista.
   - Desconhecido, quando o valor da express�o � v�lido (n�o nulo), n�o � encontrado
     na nova valores da subconsulta ou itens de uma lista e dentro  

- O operador l�gico EXISTS avalida dois valores poss�veis para testar a exist�ncia
  de uma linha da subconsulta:

   - Verdadeiro, se existe pelo menos uma linha dentro da subconsulta.
   - Falso, se n�o existe linhas dentro da subconsulta.

- Quando utilizamos o operador de nega��o NOT junto com IN e EXISTS.

   - No caso do operador EXISTS, o operador NOT negar� os dois valores para testar 
     a express�o:

     - Verdadeiro, se n�o existe linhas dentro da subconsulta.
     - Falso, se existe pelo menos uma linha dentro da subconsulta.
     
   - No caso do operador IN, o operador NOT negar� os valores para Verdadeiro ou Falso:

      - Falso, quando a express�o est� contida nos valores da subconsulta ou
        v�lida para um item de uma lista.
      - Verdadeiro, quando a express�o n�o est� contida nos valores da subsconsulta ou 
        inv�lida para um item de uma lista.

      - Quando existir dentro dos valores da subconsulta ou dentro de um item de uma lista 
        pelo menos um valor NULL, toda a express�o ser� validada como Desconhecida, 
        independente se o valor estiver contido na lista.

*/

use eCommerce
go

set statistics io on 

Select tCliente.iidcliente,
       tCliente.cNome 
  From tCliente
 Where tCliente.cUF = 'PB' and tCliente.cCidade = 'J�ao Pessoa'
   and tCliente.iIDCliente not in (Select iIDCliente 
                                     From tMovimento
                                  )
go
set statistics io off



set statistics io on 

Select tCliente.iidcliente,
       tCliente.cNome 
  From tCliente
 Where tCliente.cUF = 'PB' and tCliente.cCidade = 'J�ao Pessoa'
   and not exists (Select iIDCliente 
                     From tMovimento 
                    Where tMovimento.iIDCliente = tCliente.iIDCliente
                  )
go
set statistics io off




/*
NOT IN e NOT EXISTS, quando a coluna da subconsulta 
utilizada na express�o cont�m valor NULL.
-- Rodar o script 1 do arquivo 09a - Apoio NOT IN x NOT EXISTS.sql 

*/

use eCommerce
go

Select cCodigoExterno 
  From tProdutoImportacao01
 Where cCodigoExterno = '00.002.47'

 Select cCodigoExterno 
  From tProduto
 Where cCodigoExterno = '00.002.47'


Select cCodigoExterno 
  From tProdutoImportacao01
 Where cCodigoExterno not in (Select cCodigoExterno 
                                From tProduto 
                             )

Select cCodigoExterno 
  From tProdutoImportacao01
 Where not exists (Select cCodigoExterno 
                     From tProduto 
                    Where tProduto.cCodigoExterno = tProdutoImportacao01.cCodigoExterno
                  )



set statistics io on 
set nocount on 

Select cCodigoExterno 
  From tProdutoImportacao01
 Where cCodigoExterno not in (Select cCodigoExterno 
                                From tProduto 
                               Where cCodigoExterno is not null)

Select cCodigoExterno 
  From tProdutoImportacao01
 Where not exists (Select cCodigoExterno 
                     From tProduto 
                    Where tProduto.cCodigoExterno = tProdutoImportacao01.cCodigoExterno)

set statistics io off

/*
Realizar o teste com o Client Statistics 
-- Reset Client Statistics 
-- Desativar o Plano de Execu��o 
-- Rodar o script 2 do arquivo 09a - Apoio NOT IN x NOT EXISTS.sql 
*/

set nocount on
set statistics io off

go
-- Trial 1 
Select cCodigoExterno 
  From tProdutoImportacao01
 Where cCodigoExterno not in (Select cCodigoExterno 
                                From tProduto 
                               Where cCodigoExterno is not null)
go 1000

-- Trial 2                               
Select cCodigoExterno 
  From tProdutoImportacao01
 Where not exists (Select cCodigoExterno 
                     From tProduto 
                    Where tProduto.cCodigoExterno = tProdutoImportacao01.cCodigoExterno)
go 1000


/*
E o LEFT JOIN ???
*/


Select tProdutoImportacao01.cCodigoExterno 
  From tProdutoImportacao01
  Left Join tProduto 
  on tProdutoImportacao01.cCodigoExterno = tProduto.cCodigoExterno 
  where tProduto.iidProduto is null
go 1000