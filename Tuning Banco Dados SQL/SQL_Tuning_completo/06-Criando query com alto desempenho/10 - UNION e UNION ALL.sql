/*
Utilizando UNION ou UNION ALL 

- A instru��o UNION realiza a uni�o horizontal de linhas de duas instru��es
  SELECT. 

- Para executar essa instru��o voc� tem que observar algumas regras:
  
   - A quantidade de colunas das instru��es SELECT devem ser iguais;
   - Os tipos de dados das colunas que ser�o unidas devem ser, preferencialmente,
     do mesmo tipo e tamanho;

   Se os tipos forem diferentes, o SQL Server utiliza as convers�es impl�citas e para alguns
   cen�rio podem ocorre erro de convers�o, conforme visto na aula "Eliminando convers�es impl�citas".

*/

use eCommerce
go

Select count(1) from tCliente
Select count(1) from tEmpresa

/*
199519
100000
*/

Select cLogradouro, cCidade, cUF, cCEP from tCliente
union 
Select cLogradouro, cCidade, cUF, cCEP from tEmpresa
go

/*
Para os pr�ximos exemplos, carregue o arquivo
10a - Apoio UNION x UNION ALL.sql e execute todo o conte�do.
*/

use eCommerce
go

/*
-- Convers�es Impl�citas 
*/


/*
No processo de uni�o das linhas, se as colunas que ser�o associadas forem de
tipos de dados diferentes, o SQL Server realizar� as convers�es impl�citas.

Ref.: https://docs.microsoft.com/pt-br/sql/t-sql/data-types/data-type-precedence-transact-sql?view=sql-server-2017

*/

Select count(1) from tProduto
Select count(1) from tProdutoImportacao03
Select count(1) from tProdutoImportacao04

/*
100000
100
100
*/


set statistics io on 

Select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProduto
union 
select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProdutoImportacao03

-- Sem convers�o 
Select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProduto
union 
select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProdutoImportacao04

set statistics io off


/*
-- Diferen�as entre UNION e UNION ALL
*/

-- Union elimina a duplicidade de dados

Select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProduto
union
select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProdutoImportacao04
go

-- Union ALL preserve os dados
Select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProduto
union all
select cTitulo,cDescricao, nPreco,cCodigoExterno,nEstoque from tProdutoImportacao04
go


/*
Otimizando um query, trocando o operador OR pelo UNION ALL
*/

sp_helpindex2 tMovimento


 Create Index idxDataValidade 
     on tMovimento (dValidade,dMovimento) 
include (iidcliente) 
with (drop_existing=on)
     on indicestransacionais


set statistics io on

declare @dData date = '2018-05-17'

Select dValidade , dMovimento, iIDCliente, iIDMovimento  
  From tMovimento 
 Where (dValidade= @dData or dValidade is null)
   and dMovimento >= '2018-04-17'

Select dValidade , dMovimento, iIDCliente, iIDMovimento  from tMovimento 
where dValidade= @dData 
  and dMovimento >= '2018-04-17'
union all
Select dValidade , dMovimento, iIDCliente, iIDMovimento  from tMovimento 
where dValidade is null
  and dMovimento >= '2018-04-17'

set statistics io off


