/*
Preparando o ambiente
*/

use eCommerce

Drop Index if exists idxNome on tCliente
Drop Index if exists idxCPF on tCliente
Drop Index if exists idxCategoria on tPRoduto
Alter table tProduto drop constraint PKProduto 


Create Index idxCPF on tCliente (cCPF)
Create Index idxCategoria on tProduto (iidcategoria)
Alter table tProduto add constraint PKProduto Primary Key (iidproduto)


sp_helpindex tProduto



/*
Plano de execu��o  

- Plano de execu��o de uma consulta (Execution Plan) e o resultado de como o 
  Otimizador de Consulta calculou a maneira mais eficiente entre v�rias formas 
  de acessar o dados. 
  Um plano de execu��o pode ser visualizado em uma representa��o gr�fica ou textual,
  apresentando as etapas f�sicas e a ordem como s�o executadas de acesso ao dados. 

- Quando uma consulta enviada por um aplica��o chega no gerenciador de banco de dados, ela passa
  por algumas etapas antes do retorno dos dados. S�o as seguintes etapas:
  
  	- An�lise ou Parse
	  
	  Primira etapa executada quando a query chega no gerenciador de banco de dados � verificar
	  se a forma como a instru��o foi montada est� correta. Se a forma da consultar estiver errada,
	  o gerenciador retorna uma mensagem de erro. Caso contr�rio, ele monta uma �rvore de an�lise ou
	  �rvore de consulta quer ser� enviada para a pr�xima etapa.

*/
use eCommerce
go

Select iidCliente cNome cCPF fron tCliente  
 Where iIDCliente == 199617 

Select iidCliente, cNome, cCPF fron tCliente  
 Where iIDCliente == 199617 
 
Select iidCliente, cNome, cCPF from tCliente  
 Where iIDCliente == 199617 

Select iidCliente, cNome, cCPF from tCliente  
 Where iIDCliente = 199617 



/*
	- Algebrizer

	  Essa etapa recebe da etapa anterior a �rvore de consulta e realiza a resolu��o de todos os nomes
	  de todos os objetos, como as tabelas e colunas. Sintaxe como  "SELECT * FROM" ser� ajusta colocando
	  todas as colunas da tabela no lugar do asterisco. Esse proceso gera um bin�rio chamado �rvoce de 
	  processador de query e envia para a pr�xima etapa. 
*/

use eCommerce
go

Select iD, cNome, cCPF from Cliente  
 Where iiIDCliente = 199617 

Select iD, cNome, cCPF from tCliente  
 Where iiIDCliente = 199617 

Select iIDCliente, cNome, cCPF from tCliente  
 Where iIDCliente = 199617 


/*

	- Otimizador de Consultas

	   Recebe o Query Processor Tree e tentar identificar as v�rias alternativas para resolver a consulta,
	   considerando sempre o menor custo de processamento. Para as consultas simples, o Otimizador tem um
	   n�mero reduzido de alternativas, devido a pouca quantidade de objetos e predicados que
	   ser�o avaliados. 
	   
	   Mas em consultas complextas, onde temos diversas tabelas, com v�rios filtros
	   e agrega��es, as alternativas de resolver a query s�o tantas, que o tempo de an�lise pode ser maior
	   que o tempo de execu��o a pr�pria query. Ent�o o Otimizador limita o n�mero de tentativas e as 
	   vezes n�o consegue identificar a melhor forma.

	   As vezes o Otimizador de consulta pode identificar um predicado e o seu respectivo �ndice, mas
	   a quantidade de linhas que ser� retornada pode fazer com que o custo de processamento seja maior
	   do quer fazer um verradura completa na tabela. Neste caso o Otimizador gera um plano de execu��o
	   para realizar um Table Scan. 

      O Otimizador gera o plano de execu��o em um formato bin�rio, armazena o plano no Plan Cache 
      (Cache de Plano de execu��o) e envia para a pr�xima fase.

   - Execu��o 

	  Nessa �ltima etapa, temos a execu��o do plano de execu��o que � recebido pelo 
     mecanismo de armazenamento que executar� a query conforme o plano. 

*/

use eCommerce
go

set statistics xml on 

Select iidCliente, cNome, cCPF from tCliente  
 Where cCPF = '43303122842'

set statistics xml off
 
 


/*
Visualizar Plano de Execu��o Estimado e Plano de Execu��o Real. 

- Plano de execu��o Estimado.
  - Representa os valores fornecidos pelo Otimizador de Consulta.
  - Ele n�o executa a consulta
  - Selecione a consulta e pressione CTRL+L
*/

use eCommerce
go

Select iidCliente, cNome, cCPF from tCliente  
 Where cCPF = '43303122842'

/*
- Plano de execu��o Real.
  - Representa os valores pela execu��o do plano.
  - Ele somente � obtido quando voce executa a instru��o.
  - Pressione CTRL+M para ativar e novamente para desativar 

Os Planos estimado e real, em geral apresentam os mesmos valores. Mas dependendo
de como a fase de execu��o trata o plano de execu��o, ela pode realizar ajustes
para a execu��o e os planos podem ser diferentes. 

*/

use eCommerce
go

Select iidCliente, cNome, cCPF from tCliente  
 Where cCPF = '43303122842'

/*
Interpreta��o da visualiza��o do Plano de Execu��o 

- Leitura � da Direita para a Esquerda e de Cima para Baixo 
- Cada objeto representado s�o chamados de Operadores.
- As setas entre os operadores representam o fluxo de dados e
  sua espessura reprenta a quantidade de linhas. 
- O texto abaixo do Operador identifica:
   - O nome do Operador
   - O objeto de aloca��o de dados 
   - O custo (estimado ou real) em percentual do desse operador em 
     rela��o ao plano de execu��o.
*/

/*
Executando duas solicita��es e realizando compara��es 
*/

Select iidCliente, cNome, cCPF from tCliente  
 Where cCPF = '43303122842'

Select iidCliente, cNome, cCPF from tCliente  
 Where cast(cCPF as bigint) = 43303122842
 
/*
Alguns operadores que podemos evitar

- Table Scan
- Index Scan 
- Sort
- RID Lookup (Heap)
- Compute Scalar 
*/

Select * from tEmpresa
where iidEmpresa = 1

Select iidProduto,cTitulo from tProduto where iIDCategoria = 12

Select * from tMovimento 
   join tCliente 
   on tMovimento.iidcliente = tCliente.iIDCliente
where cCodigo = 'CB75A0'
order by dMovimento 



Select nQuantidade*mPreco from tItemMovimento where iIDMovimento = 1587


Select nQuantidade,mPreco from tItemMovimento where iIDMovimento = 1587


--------------------------------------------------------------------------------------------------------------
/*
Observando o Cache de Planos.

- Todos os planos de consulta que s�o gerandos, ficam armazenados em um espa�o da mem�ria 
  chamado Cache de Planos (Plan Cache). 
- Quando o otimizado gera um plano estimado, ele compara com os planos de execu��o que est�o
  no Plan Cache. Se encontrar um plano id�ntico, ele reaproveita esse plano sem a necessidade de
  criar um plano de execu��o real.
- Plano de execu��o n�o ficam para sempre no Plan Cache. A medida que passa o tempo, eles s�o 
  eliminados. 

- Podemos visualizar dados do Plan Cache com a DMV sys.dm_exec_cached_plans
  Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-cached-plans-transact-sql?view=sql-server-2017

*/

use eCommerce
go
Select * 
  From sys.dm_exec_cached_plans CachedPlans

/*
Colunas relavantes :

   - Usecounts - N�mero de vezes que o objeto do cache foi referenciado.
   - Size_in_Bytes - Bytes consumido pelo objeto do cache.
   - Cacheobjtype - Tipo do objeto no cache.
   - Objtype   - Tipo de objeto 
         - Proc - Procedure
         - Adhoc - Consultas SQL 
   - Plan_handle - Identificador do plano na mem�ria.
*/

/*
Limpa todo o Plan Cache
*/

DBCC FREEPROCCACHE
go

Select * 
  From sys.dm_exec_cached_plans CachedPlans

/*
Observando a entrada de uma consulta no Plan Cache 
*/

Select * from tProduto where iIDProduto = 83838
go
Select * from tProduto where iIDProduto = 5666
go

/*

*/
Select CachedPlans.usecounts , 
       CachedPlans.size_in_bytes , 
       CachedPlans.cacheobjtype, 
       CachedPlans.objtype , 
       CachedPlans.plan_handle,
       QueryText.text  -- N�o 09-Plano 
  From sys.dm_exec_cached_plans CachedPlans
 Cross Apply sys.dm_exec_sql_text(CachedPlans.plan_handle) as QueryText 
 where QueryText.text like '% tProduto %'
   and QueryText.text not like '%CachedPlans%'



/*

*/
DBCC FREEPROCCACHE
go


declare @iid int = 83838
Select * from tProduto where iIDProduto = @iid --Teste
go
declare @iid int =5666
Select * from tProduto where iIDProduto = @iid --Teste


Select CachedPlans.usecounts , 
       CachedPlans.size_in_bytes , 
       CachedPlans.cacheobjtype, 
       CachedPlans.objtype , 
       CachedPlans.plan_handle,
       QueryText.text  -- N�o 09-Plano 
  From sys.dm_exec_cached_plans CachedPlans
 Cross Apply sys.dm_exec_sql_text(CachedPlans.plan_handle) as QueryText 
 where QueryText.text like '% tProduto %'
   and QueryText.text not like '%CachedPlans%'


/*

*/
DBCC FREEPROCCACHE
go


declare @iid int = cast(rand()*100004 as int)+1
Select * from tProduto where iIDProduto = @iid --Teste
go
declare @iid int = cast(rand()*100004 as int)+1
Select * from tProduto where iIDProduto = @iid --Teste


Select CachedPlans.usecounts , 
       CachedPlans.size_in_bytes , 
       CachedPlans.cacheobjtype, 
       CachedPlans.objtype , 
       CachedPlans.plan_handle,
       QueryText.text  -- N�o 09-Plano 
  From sys.dm_exec_cached_plans CachedPlans
 Cross Apply sys.dm_exec_sql_text(CachedPlans.plan_handle) as QueryText 
 where QueryText.text like '% tProduto %'
   and QueryText.text not like '%CachedPlans%'


/*
Examinando a execu��o de uma Store Procedure 
*/


Create or Alter Procedure stp_ConsultaProduto 
@id int
as
begin

  Select * 
    From tProduto 
   Where iIDProduto = @id --Teste

end 
go


DBCC FREEPROCCACHE
go


stp_ConsultaProduto  5666
go
stp_ConsultaProduto  83838


Select CachedPlans.usecounts , 
       CachedPlans.size_in_bytes , 
       CachedPlans.cacheobjtype, 
       CachedPlans.objtype , 
       CachedPlans.plan_handle,
       QueryText.text  -- N�o 09-Plano 
  From sys.dm_exec_cached_plans CachedPlans
 Cross Apply sys.dm_exec_sql_text(CachedPlans.plan_handle) as QueryText 
 where QueryText.text like '% tProduto %'
   and QueryText.text not like '%CachedPlans%'

/*
*/

