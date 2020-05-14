/*
Chave Estrangeira.

O recurso da chave estrangeira na modelagem de dados garante que um tupla de uma entidade
se relaciona com um outra entidade que tem a chave prim�ria.

A ocorr�ncia de uma entidade somente existir� se a chave estrangeira dessa entidade 
se relacionar com a chave prim�ria da outra entidade.

Quando falamos em SQL SERVER, a FK (abrevia��o de Foreign Key) pode ser uma coluna ou conjunto de colunas
que deve possuir o mesmo tipo e tamanho de dados da PK (abrevia��o de Primary Key) da tabela que manter� o 
relacionamento.

Mas o que isso tem rela��o com �ndice?

Quando criamos um relacionamento entre duas tabelas, em algum momento do c�digo em SQL, utilizaremos os 
comandos de Jun��es (JOIN) para acessar dados de ambas as tabelas e o JOIN realizar� a pesquisa na 
tabela com a PK e a FK.

De forma semelhante, quando utilizarmos os comandos UPDATE e DELETE na tabela que tem a PK, ocorrer�
uma consultas nas tabelas quem tem FK para garantir a integridade referencial. 

Ent�o, se temos essas pesquisas e uma das tabelas tem uma PK que tem um �ndice clusterizado, um boa pr�tica e 
criarmos um �ndice (clusterizado ou n�o clusterizado) para as colunas da FK de outra tabela.

*/
use eCommerce
go

sp_helpindex tProduto
go

sp_helpindex tItemMovimento
go
drop index if exists IDXFKProduto on tItemMovimento


/*
Criar uma PK para tProduto e para tItemMovimento 

- Como as tabelas j� existem, vamos verificar se as colunas s�o pr�prias para PK

*/

Select top 10 * from tProduto


/*
Criar a PK
*/

Alter Table tProduto 
        add constraint PKProduto Primary Key (iidProduto) 
go
go


sp_helpindex 'tProduto'


/*
PK para ItemMovimento 
*/

Select top 10 * from tItemMovimento
go

Alter Table tItemMovimento 
        add constraint PKItemMovimento Primary key(iiDItem)
go

sp_helpindex 'tItemMovimento'
go

/*
A table tItemMovimento n�o tem chave estrangeira. 
*/

sp_fkeys  @fktable_name = 'tItemMovimento'
go

Alter Table tItemMovimento 
        add constraint FKProduto Foreign key (iidProduto) References tProduto(iidProduto)
go

sp_fkeys  @fktable_name = 'tItemMovimento'
go


/*
Diferente da PK, o fato de criar a FK n�o cria um �ndice com a colunas ou colunas.
*/

set statistics io on

Select tProduto.nPreco,
       tItemMovimento.iIDItem, 
       tItemMovimento.iIDMovimento, 
       tItemMovimento.nQuantidade, 
       tItemMovimento.mDesconto  
  From tProduto
  Join tItemMovimento 
    on tProduto.iIDProduto = tItemMovimento.iIDProduto
 where tItemMovimento.iIDProduto = 99911

set statistics io off

/*
Table 'tItemMovimento'. Scan count 1, logical reads 12384, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tProduto'. Scan count 0, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/


/*
Simulando a exclus�o de uma linha da tabela tProduto. 
Nessa simula��o, o produto existe na tabela tItemMovimento
e teremos um erro na execu��o. 
*/

set statistics io on
set statistics xml on

Delete tProduto where iIDProduto = 3078 

set statistics io off
set statistics xml off

/*
Nessa outra simula��o, o produto N�o existe na tabela tItemMovimento
e conseguiremos realizar a exclus�o. 
*/

Insert into tProduto(iIDCategoria, cCodigo,cTitulo,cDescricao,nPreco,mCustoKM, cCodigoExterno , nEstoque)
Select top 1 iIDCategoria, 'D9879-8268','Inativo',cDescricao,nPreco,mCustoKM, cCodigoExterno , nEstoque
  From tProduto
go

Select top 1 * From tProduto order by iIDProduto desc
go

/*
*/

set statistics io on
set statistics xml on

Delete from tProduto where iIDProduto = 100008

set statistics io off
set statistics xml off

sp_helpindex tProduto


/*
Table 'tItemMovimento'. Scan count 1, logical reads 34443, physical reads 358, read-ahead reads 29698, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tProduto'. Scan count 0, logical reads 10, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

Select top 10 * from tItemMovimento order by NEWID()
go

set statistics io on 
update tItemMovimento set iIDProduto = 36803 where iIDItem = 523601
set statistics io off

/*
Table 'tProduto'. Scan count 0, logical reads 3, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tItemMovimento'. Scan count 0, logical reads 6, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/


/*
Criando um �ndice n�o clusterizado para a coluna iidProduto que � a chave da chave estrangeira 
FKProduto 
*/

sp_fkeys  @fktable_name = 'tItemMovimento'
go

Create Index IDXFKProduto on tItemMovimento (iidproduto) 

sp_helpindex tItemMovimento 
go


/*
*/
set statistics io on

Select tProduto.nPreco,
       tItemMovimento.iIDItem, 
       tItemMovimento.iIDMovimento, 
       tItemMovimento.nQuantidade, 
       tItemMovimento.mDesconto  
  From tProduto
  Join tItemMovimento 
    on tProduto.iIDProduto = tItemMovimento.iIDProduto
 where tItemMovimento.iIDProduto = 99911

set statistics io off

/*
Table 'tItemMovimento'. Scan count 1, logical reads 78, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tProduto'. Scan count 0, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/


/*
Simulando a exclus�o de uma linha da tabela tProduto. 
Nessa simula��o, o produto existe na tabela tItemMovimento.

*/

Delete tProduto where iIDProduto = 3078 


/*
Table 'tItemMovimento'. Scan count 1, logical reads 374, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tProduto'. Scan count 0, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/



/*
Nessa simula��o, o produto N�o existe na tabela tItemMovimento.
*/

Insert into tProduto(iIDCategoria, cCodigo,cTitulo,cDescricao,nPreco,mCustoKM, cCodigoExterno , nEstoque)
select top 1 iIDCategoria, 'D9879-8268','Inativo',cDescricao,nPreco,mCustoKM, cCodigoExterno , nEstoque
 From tProduto
go

Select top 1 * From tProduto order by iIDProduto desc
go

/*
*/

set statistics io on
set statistics xml on

Delete from tProduto where iIDProduto = 100009

set statistics io off
set statistics xml off

/*
Table 'tItemMovimento'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tProduto'. Scan count 0, logical reads 10, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/


/*
*/

Select top 10 * from tItemMovimento order by NEWID()




set statistics io on 
update tItemMovimento set iIDProduto = 98241 where iIDItem = 61465
set statistics io off
go

sp_helpindex tItemMovimento
go

sp_helpindex2 tItemMovimento
go

/*
Table 'tProduto'. Scan count 0, logical reads 3, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tItemMovimento'. Scan count 0, logical reads 22, physical reads 4, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

-- Ele tevem que atualizar 3 indices
-- E houve leitura de p�gina maior que antes de ter o �ndice.

*/




/*
Devo ent�o criar �ndices para todas as Foreign Key?
---------------------------------------------------

Quando criamos uma Foreing Key, j� estamos assumindo que duas
tabelas ter�o relacionamentos e que em algum momento ser� feito
uma consulta que envolver� as duas tabelas. 

Tamb�m estamos assumindo que se ocorrer uma exclus�o de uma linha na 
tabela "Pai", pela integridade referencial da PK/FK, a tabela "Filho"
(ou as tabelas) ser�o pesquisadas para verificar se essa integridade 
n�o ser� violada. Para isso, o SQL Server pesquisar� a linha exclu�da
na tabela "Pai", na tabela "Filho". 

Quando devo criar um �ndice em uma FK?

- Quando a tabela "Pai" tem um grande incid�ncia de DELETE e existe 
  muitas tabelas "Filhos" relacionadas pela FK. Ent�o voce deve 
  criar os �ndices nas tabelas "Filhos".

- Se temos muitas consultas da tabela "Pai" relacionada com as tabelas 
  "Filho" usando JOIN com as colunas chave. Ent�o voce deve 
  criar os �ndices nas tabelas "Filhos".

- Se a coluna da tabela Filho, que faz parta da FK,  tem alta seletividade. 
  Ent�o voce deve criar os �ndices nessa tabela;

  

*/














