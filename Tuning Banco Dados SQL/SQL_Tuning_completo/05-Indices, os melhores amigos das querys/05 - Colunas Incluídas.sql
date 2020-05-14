/*
Colunas inclu�das e �ndice de cobertura.

- Colunas inclu�das em um �ndice, � um recurso que permite inclu�r colunas na defini��o do
  �ndice e que n�o far�o parte da chave.

- �ndice � uma estrutura b-tree, onde as colunas chaves s�o distribu�das a partir do n� raiz,
  para as n�s intermedi�rios e por fins chegando aos n�s folhas. No SQL Server, os n�s s�o
  as p�ginas de �ndices.

- Essas colunas ser�o inclu�da no �ndice, mas ficar�o apenas nas p�ginas folhas. Como elas ficam
  nas p�ginas folhas, somente �ndices n�o clusterizado podem utilizar esse recurso.

- Colunas inclu�das no �ndices n�o s�o utilizadas como chave de pesquisa. Esse recurso
  existe para evitar o Key Lookup ou RID Lookup

Sintaxe: 
Create NonClustered Index <Nome do Indice> 
                       on <Nome da tabela>  (<Coluna1>,<Coluna2>,...) 
					   Include ((<Coluna3>,<Coluna4>,...) 


- �ndice de Cobertura � um conceito de �ndice que cont�m na chave todas as colunas que atende 
  a query. Todas as colunas que est�o no �ndice "cobre" todas as colunas da query. 
  Para evitar de sobrecarregar as chaves do �ndice, usamos a  op��o INCLUDE 

- A consulta carrega todos os dados que necessita apenas pesquisando no �ndice, sem a necessidade de acessar
  a tabela. 
  

Exemplo

*/

/*
Montar uma pesquisa que mostre somente os produtos de um determiando pedido 
que a multiplica��o da quantidade do produto pelo seu pre�o for maior que 
um valor informado. Apresentar o ID do produto, os valores separados e o valor
calculado.
*/

use eCommerce
go

sp_helpindex tItemMovimento
go

drop index if exists idxMovimento  on tItemMovimento
drop index if exists idxFKProduto on tItemMovimento
go

set statistics io  on 

Select iIDItem, nQuantidade, mPreco, nQuantidade * mPreco as mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
  

/*
Table 'tItemMovimento'. Scan count 3, logical reads 17287, physical reads 0, read-ahead reads 17180, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/

/*
Aloca��o dos dados 
*/ 
select object_name(p.object_id) as cTabela,
       rows,
       total_pages , 
       used_pages , 
       data_pages  , 
       p.data_compression_desc ,
	   p.index_id ,
	   i.name ,
	   i.type_desc 
  from sys.allocation_units au 
  join sys.partitions p
    on au.container_id =  p.partition_id
  join sys.indexes i 
    on p.index_id = i.index_id 
   and p.object_id = i.object_id
 where p.object_id in ( object_id('tItemMovimento') )
go

/*

cTabela	      rows	   total_pages		used_pages	data_pages	data_compression_desc	index_id	name			      type_desc
tItemMovimento	2611043	17219	         17211	      17179	      NONE	                  1	      PKItemMovimento	CLUSTERED
*/

Create Index IDXMovimento 
    on tItemMovimento (iIDMovimento, nQuantidade, mPreco) 
go

Select iIDItem, nQuantidade, mPreco, nQuantidade * mPreco as mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
go

/*
Table 'tItemMovimento'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.


cTabela	      rows	   total_pages		used_pages	data_pages	data_compression_desc	index_id	name			      type_desc
tItemMovimento	2611043	17219	         17211	      17179	      NONE	                  1	      PKItemMovimento	CLUSTERED
tItemMovimento	2611043	8443	         8431	      8396	      NONE	                  4	      IDXMovimento	   NONCLUSTERED
tItemMovimento	2611043	8443	         8418	      8396	      NONE	                  4	      IDXMovimento	   NONCLUSTERED
*/

sp_helpindex tItemMovimento


/*
Algumas percep��es :

- A coluna iidMovimento n�o � exclusiva na tabela e tamb�m possue uma SELETIVIDADE alta. Isso significa
  que os dados dessas coluna possuem baixa redund�ncia  e quando fazemos uma pesquisa
  por essa coluna, ela � bem seletiva, retornando poucas linhas.

- �ndice � utilizado para aumentar a performance da query. Ent�o na chave do �ndice somente coloque colunas
  que ser�o utilizada para realizar buscas e pesquisas. Assim elas tendem a ser tornar pequenas e eficientes.

*/

/*
Vamos usar ent�o a op��o INCLUDE e colocar as colunas nQuantidade, mPreco
*/


Create Index IDXMovimento 
     on tItemMovimento (iIDMovimento) 
include (nQuantidade, mPreco) 
   with (drop_existing=on)

go

Select iIDItem, nQuantidade, mPreco, nQuantidade * mPreco as mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
go

/*
Table 'tItemMovimento'. Scan count 1, logical reads 3, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
*/




/*
Para termos um indice de cobertura, temos que ter todas as colunas da query dentro do �ndice.

*/

Select iIDItem, iidProduto, nQuantidade, mPreco, nQuantidade * mPreco as mValor 
  from tItemMovimento 
 where iIDMovimento = 186324
go


 Create Index IDXMovimento 
     on tItemMovimento (iIDMovimento) 
include (nQuantidade, mPreco, iidProduto) 
  with (drop_existing=on)

go


/*
Como sei que um indice tem colunas inclu�das? 
*/

set statistics io off


sp_helpindex 'tItemMovimento'

---
select i.name  ,
		i.index_id , 
		c.name  , 
		is_descending_key  , 
		is_included_column , 
		key_ordinal
from sys.index_columns ic 
join sys.columns c 
	on ic.object_id = c.object_id and  ic.column_id = c.column_id
join sys.indexes i  on ic.object_id = i.object_id and  ic.index_id = i.index_id
where ic.object_id = object_id('tItemMovimento')
  and i.name  ='IDXMovimento'

/*
Ou utiliza a power procedure sp_helpindex2 
*/



sp_helpindex2 'tItemMovimento'
go

sp_helpindex2 'tItemMovimento' , @nOptions = 1
go

sp_helpindex2 'tItemMovimento' , @nOptions = 2
go

sp_helpindex2 'tItemMovimento' , 'IDXMovimento', @nOptions = 3
go

