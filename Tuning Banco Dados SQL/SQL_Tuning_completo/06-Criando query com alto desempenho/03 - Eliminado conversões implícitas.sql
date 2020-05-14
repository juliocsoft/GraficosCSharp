/*
Eliminando convers�es impl�citas.

- Convers�es impl�citas s�o quando o SQL Server realiza internamente convers�es 
  de tipos de dados entre colunas dentro de uma express�o e que n�o s�o vis�veis ao usu�rio. 

  Ref.: https://docs.microsoft.com/pt-br/sql/t-sql/data-types/data-type-conversion-database-engine?view=sql-server-2017

- Essas convers�es impl�citas entre tipos de dados acontece de acordo com regras de preced�ncia

  Ref.: https://docs.microsoft.com/pt-br/sql/t-sql/data-types/data-type-precedence-transact-sql?view=sql-server-2017

  A lista de preced�ncia de tipos de dados s�o:

      UDT (tipos de dados definidos pelo usu�rio) (maior)
      sql_variant
      xml
      datetimeoffset
      datetime2
      datetime
      smalldatetime
      date
      time
      float
      real
      decimal ou numeric
      money
      smallmoney
      bigint
      int
      smallint
      tinyint
      bit
      ntext
      text
      imagem
      timestamp
      uniqueidentifier
      nvarchar [incluindo nvarchar(max)]
      nchar
      varchar [incluindo varchar(max)]
      char
      varbinary [incluindo varbinary(max)]
      binary (mais baixo)

- Dependendo de como ocorre a convers�o impl�cita, uma express�o SARG pode virar uma express�o
  NoSARG e causar queda de desempenho na query.

- A regra geral aqui � os dados da express�es sempre do mesmo tipo e tamanho .

*/
use DBDemo
go

drop table if exists tCliente
go

Create Table tCliente (
   iidCliente smallint not null identity(1,1) ,
   cNome varchar(100), 
   cCPF char(14),
   Constraint PKCliente Primary key 
   (
      iidCliente 
   )
)
go


insert into tCliente (cNome, cCPF)
select top 32767 cNome, cCPF from eCommerce.dbo.tCliente
go

set statistics profile on 

Select * from tCliente where iidCliente = 2     -- Tinyint 
Select * from tCliente where iidCliente = 255   -- Tinyint 
Select * from tCliente where iidCliente = 256   -- Smallint 
Select * from tCliente where iidCliente = 50000


set statistics profile off


/*
Mas nesses casos n�o precisa fazer nada. A convers�o est� do lado do valor da express�o.
A pesquisa � uma SARG.
*/


/*
Convers�es entre tipos caracteres e n�meros. 

- � comum armazenar dados somente n�mero em colunas CHAR ou VARCHAR. 
  Casos em que os dados tem tamanho fixo e n�o efetuam qualquer tipo de c�lculo,
  em certos casos acabam sendo armazenados em colunas string. 

  Conversamos sobre isso na aula "Tipos de Dados, Dom�nio e armazenamento" na sess�o de Conceitos.

- Mas temos que tomar um cuidado quando realizamos uma pesquisa e desconhecemos a estrutura das
  tabelas e n�o respeitamos os tipos de dados. 

- Express�es de pesquisa onde os tipos de dados s�o diferentes, ocorre a convers�o impl�cita de 
  acordo com a preced�ncia dos tipos de dados, que pode levar a uma express�o NoSARG.

*/
use eCommerce
go

sp_helpindex2 tCliente
go

Create Index idxCPF on tCliente (cCPF) on INDICESTRANSACIONAIS

set statistics io  on 
go

Select * from tCliente
where cCPF = 71375968870   
go
set statistics io  off
go


/*
cCPF � uma coluna do tipo CHAR(14) e o n�mero do cpf informado na express�o est� sendo considerado
como NUMERIC(11).

Como a preced�ncia do tipo n�merico � maior do que o tipo caracter, o SQL Server converte impl�citamente 
a coluna cCPF para NUMERIC(12).

Como se fosse igual a: 

 */

Select * from tCliente
where cast(cCPF as numeric(11))= 71375968870   
go

/*
Neste caso, converter a express�o NoSARG para SARG 
*/

set statistics io  on 
go
Select * from tCliente
where cCPF = '71375968870'
go
set statistics io  off 
go


/*
Convers�es Ocultas 
*/

set statistics profile on 

Declare @dMovimento1 datetime = '2018-05-18'

Select COUNT(1) as nQtdMovimento  
  From tMovimento
 Where dMovimento >= @dMovimento1

Declare @dMovimento2 datetime2 = '2018-05-18'

Select COUNT(1) as nQtdMovimento  
  From tMovimento
 Where dMovimento >= @dMovimento2

set statistics profile off 

/*
Regra aqui e utilizar a vari�vel do mesmo tipo e tamanho da coluna.
*/


/*
Tratar money como se fosse money.
*/



Select sum(mPreco) as mPreco 
from tItemMovimento
where iIDMovimento = 45865
and mPreco > 100
go



Select sum(mPreco) as mPreco 
from tItemMovimento
where iIDMovimento =  45865
and mPreco > 100.00
go



Select sum(mPreco) as mPreco 
from tItemMovimento
where iIDMovimento =  45865
and mPreco > $100.00


/*
Convers�es em JOIN

- N�o costumo ver convers�es impl�citas em JOIN em tabelas que tem integridade referencial 
  pela PK e FK.
  Quando se define um FK, as colunas das colunas envolvidas devem ser do mesmo tipo de dados.

- Mas quando o JOIN � realizado em colunas que n�o tem essa integridade ou quando 
  temos que tratar dados em tabelas tempor�rias de dados importados. 
  
*/

use eCommerce
go

sp_helpindex2 tProduto


/*
A tabela de produto precisa ser atualizada no Preco a partir de uma tabela de dados de importa��o
tProduto_Importacao 
A chave de pesquisa nessa tabela de importa��o � a coluna cCodigoExterno e ela deve ser utilizada
para encontrar os produtos na tabela tProduto.

Antes de atualizar o preco, voce deve realizar uma lista para comparar esses produtos e pre�os. 

Aten��o:
Abir o arquivom 03a - Apoio Convers�es Impl�citas.sql 
e execute seun conte�do.


*/
set statistics io on 
go



Select tProduto.iIDProduto, tProduto.cTitulo, tProduto.nPreco, 
       tProdutoImportacao.cTitulo, tProdutoImportacao.nPreco
  From tProduto 
  join tProdutoImportacao01 as tProdutoImportacao
    on tProduto.cCodigoExterno = tProdutoImportacao.cCodigoExterno 
    where tProdutoImportacao.cCodigoExterno like '8%'

 go



Select tProduto.iIDProduto, tProduto.cTitulo, tProduto.nPreco, 
       tProdutoImportacao.cTitulo, tProdutoImportacao.nPreco
  From tProduto 
  join tProdutoImportacao02 as tProdutoImportacao
    on tProduto.cCodigoExterno = tProdutoImportacao.cCodigoExterno 
    where tProdutoImportacao.cCodigoExterno like '8%'

 go


/*
Regra. As colunas do join devem ser sempre do mesmo tipo e tamanho. 
*/

/*
Erros de Convers�o 
*/

Select * from tCliente
where cCelular = '802168902'

/*
Observando o plano de execu��o estimado, o SQL Server converte a coluna celular que � CHAR
para o dado que est� do lado direito, que no caso � 802168902 do tipo INT.

Com isso, todos os dados dessa coluna s�o convertido para INT e o SQL Server avalida 
a express�o. Quando encontra o dados '19145 0581' e tenta converter para INT, apresenta o erro.
*/

select CAST('19145 0581' as int)


/*
Apresentar o valor do estoque por categoria .
*/

select top 10 * from tProduto 
go


Select iIDCategoria , sum(nPreco * nEstoque ) as nValorEstoque 
  From tProduto 
 Where nEstoque > 0 
 Group by iIDCategoria


Select nPreco, nEstoque  , nPreco*nEstoque as nValorEstoque
  From tProduto 
 Where iIDProduto = 2 


/*
nPreco � SMALLMONEY com precis�o 10 e escala 4 -> (10,4) e
nEstoque � INT.

Como a ordem de Preced�ncia � converter INT para SMALLMONEY, 
o resultado ser� SMALLMONEY.
*/

Select nPreco, nEstoque    from tProduto where iIDProduto = 2 

Select 928.52 * 288  -- > 267413.76

/*
O resultado � 267.413,76 .
� o limite para smallmoney e 214.748,3647.
Ent�o temos a mensagem de erro . 
*/

Select nPreco, nEstoque , nPreco * cast(nEstoque as decimal(10))  from tProduto where iIDProduto = 2 
Select nPreco, nEstoque , cast(nPreco as decimal(10,4)) * nEstoque   from tProduto where iIDProduto = 2 


Select iIDCategoria , cast(sum( nPreco * nEstoque ) as decimal(10,4)) as nValorEstoque 
  From tProduto 
 Where nEstoque > 0 
 Group by iIDCategoria


Select iIDCategoria , sum( nPreco * cast(nEstoque as numeric(10,4)))  as nValorEstoque 
  From tProduto 
 Where nEstoque > 0 
 Group by iIDCategoria




Drop table if exists tProdutoImportacao01; 
Drop table if exists tProdutoImportacao02; 
Drop table if exists tProdutoImportacao; 

