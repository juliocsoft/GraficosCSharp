/*
Armazenamento em colunas definidas com a restri��o NULL

- Quando definimos uma coluna com a restri��o NULL, estamos indicando para o SQL Server 
  que essa coluna n�o ter� o valor armazenados para algumas linhas da tabela. 

  Pelo que vimos na se��o "Armazenamento de Dados", quando uma coluna de tamanho fixo
  e definida com a restri��o NULL, o registro alocado na p�gina ter� o tamanho da coluna 
  de tamanho fixo alocada, mas sem qualquer tipo de dado armazenado. 

  Create Table tAluno (
     id int not null, 
     nome char(20) null, 
     nascimento datetime not null 
  ) 
  go
  insert into tAluno (id,cNome,nascimento) values (1000,null,'2001-05-02')
  
  +---------+----------+---------+--------+
  | 4 bytes | 32 bytes | 2 bytes | 1 byte | -- 39 bytes 
  +---------+----------+---------+--------+

  +---------------------------------------+
  |00001000                    20010502031|
  +---------------------------------------+

  go
  Create Table tAluno (
     id int not null,
     nome varchar(20) null, 
     nascimento datetime not null 
  ) 
  go
  insert into tAluno (id,cNome,nascimento) values (1000,null,'2001-05-02')

  +---------+----------+---------+--------+---------+---------+----------+
  | 4 bytes | 12 bytes | 2 bytes | 1 byte | 2 bytes | 2 bytes | 20 bytes | -- 43 bytes 
  +---------+----------+---------+--------+---------+---------+----------+
   
  +--------------------------------------------+
  |00001000200105020310101                     |
  +--------------------------------------------+
  
  Se o tamanho m�dio dos dados armazenados na coluna NOME � igual a 15 bytes ou mesmo,
  o varchar come�a a ser vantajoso.

  Se esse coluna tiver o tamanho constante de 20 bytes, mas com cerca de 10% de NULL,
  varchar tamb�m passa a ser vantajoso em rela��o ao armazenamento. 

  Isso pode levar a um desperd�cio de aloca��o de espa�o nas p�ginas de dados. 

  Veja essa simula��o.

*/

use DBDemo
go

drop table if exists tProduto
go

Create Table tProduto (
	iIDProduto int NOT NULL,
	iIDCategoria int NOT NULL,
	cCodigo char(10) NULL,
	cTitulo char(40) NULL,
	cDescricao char(740) NULL,
	nPreco smallmoney NOT NULL,
	mCustoKM smallmoney NOT NULL,
	cCodigoExterno varchar(10) NULL,
	nEstoque int NOT NULL
)
;
with cted as (
select datalength(cCodigo) nCodigo, 
       datalength(cTitulo) ntitulo , 
       datalength(cDescricao) nDescricao, 
       datalength(cCodigoExterno) nCodigoExterno 
  From eCommerce.dbo.tProduto
)
select  MAX(nCodigo), AVG(nCodigo) ,
        MAX(ntitulo), AVG(ntitulo) ,
        MAX(nDescricao), AVG(nDescricao) ,
        MAX(nCodigoExterno ), AVG(nCodigoExterno ) 
from cted

/*
Carrega 100000 linhas da tabela produto do banco de dados eCommerce.
Todas as colunas para todas as linhas est�o preenchidas. 
*/

insert into tProduto (iIDProduto ,iIDCategoria, cCodigo, cTitulo, cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque )
select iIDProduto ,iIDCategoria, cCodigo, cTitulo, cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque 
  From eCommerce.dbo.tProduto
go


select top 10 * from tProduto where cDescricao is null

/*
Consultando o armazenamento 
*/
declare @db_id int = db_id()
declare @object_id int = object_id('tproduto')

/*
Consultando a aloca��o da tabela 
*/
Select pa.index_id , pa.rows  ,
       au.type, au.type_desc , au.data_space_id , au.total_pages , au.data_pages 
  From sys.partitions pa
  Join sys.allocation_units au
    on pa.partition_id  = au.container_id 
 where pa.object_id = @object_id 


Select index_id , 
       index_type_desc , 
	   alloc_unit_type_desc , 
	   page_count , 
	   record_count  ,
	   min_record_size_in_bytes ,
	   max_record_size_in_bytes ,
	   avg_record_size_in_bytes
  from sys.dm_db_index_physical_stats(@db_id, @object_id , null,null,'DETAILED')
go

/*
Linhas      = 100.000
DataPages   = 11.112
Record Size = 827,52 bytes (Valor m�dio) 
*/

Truncate table tProduto
go

insert into tProduto (iIDProduto ,iIDCategoria, cCodigo, cTitulo, cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque )
Select iIDProduto ,iIDCategoria, cCodigo, cTitulo, iif(iIDProduto%2 = 0,null,cDescricao) as cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque 
  From eCommerce.dbo.tProduto 
go


/*
100% linhas preenchidas 

Linhas      = 100.000
DataPages   = 11.112
Record Size = 827,52 bytes (Valor m�dio) 

25% das linhas com a coluna cDescricao is null 
50% das linhas com a coluna cDescricao is null 
75% das linhas com a coluna cDescricao is null 
100% das linhas com a coluna cDescricao is null 

*/


Truncate table tProduto
go

insert into tProduto (iIDProduto ,iIDCategoria, cCodigo, cTitulo, cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque )
select iIDProduto ,iIDCategoria, cCodigo, cTitulo, null as cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque 
  From eCommerce.dbo.tProduto 
go

/*
Agora vamos transforma a coluna cDescricao que est� definida como CHAR(740) para VARCHAR(740) e 
mantendo a restri��o NULL;
*/
use DBDemo
go

drop table if exists tProduto
go

Create Table tProduto (
	iIDProduto int NOT NULL,
	iIDCategoria int NOT NULL,
	cCodigo varchar(10) NULL,
	cTitulo varchar(40) NULL,
	cDescricao varchar(740) NULL, --<<<<<<<<<<
	nPreco smallmoney NOT NULL,
	mCustoKM smallmoney NOT NULL,
	cCodigoExterno varchar(10) NULL,
	nEstoque int NOT NULL
)
go

insert into tProduto (iIDProduto ,iIDCategoria, cCodigo, cTitulo, cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque )
select iIDProduto ,iIDCategoria, cCodigo, cTitulo, cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque 
  From eCommerce.dbo.tProduto
go



/*
Consultando o armazenamento 
*/

declare @db_id     int = db_id()
declare @object_id int = object_id('tproduto')

Select pa.index_id , 
       pa.rows  ,
       au.type, 
       au.type_desc , 
       au.data_space_id , 
       au.total_pages , 
       au.data_pages 
  From sys.partitions pa
  Join sys.allocation_units au
    on pa.partition_id  = au.container_id 
 where pa.object_id = @object_id 


Select index_id , 
       index_type_desc , 
	    alloc_unit_type_desc , 
	    page_count , 
	    record_count  ,
	    min_record_size_in_bytes ,
	    max_record_size_in_bytes ,
	    avg_record_size_in_bytes
  from sys.dm_db_index_physical_stats(@db_id, @object_id , null,null,'DETAILED')
go

/*
*/

/*
100% linhas preenchidas com a coluna cDescricao preenchida 

Linhas      = 100.000
DataPages   = 5.247
Record Size = 413.35 bytes (Valor m�dio) 

50% das linhas com a coluna cDescricao is null 

Linhas      = 100.000
DataPages   = 3.088
Record Size = 243.38 bytes (Valor m�dio) 

100% as linhas com a coluna cDescricao is null 

Linhas      = 100.000
DataPages   = 946
Record Size = 74.17 bytes (Valor m�dio) 

*/


Truncate table tProduto
go

insert into tProduto (iIDProduto ,iIDCategoria, cCodigo, cTitulo, cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque )
select iIDProduto ,iIDCategoria, cCodigo, cTitulo, iif(iIDProduto%2 = 0,null,cDescricao) as cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque 
  From eCommerce.dbo.tProduto 
go

Truncate table tProduto
go

insert into tProduto (iIDProduto ,iIDCategoria, cCodigo, cTitulo, cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque )
select iIDProduto ,iIDCategoria, cCodigo, cTitulo, null as cDescricao, nPreco, mCustoKM, cCodigoExterno, nEstoque 
  From eCommerce.dbo.tProduto 
go

/*
------------------------------------------------
Como definir uma coluna com restri��o NULL.

- Colunas de tamanho fixo, devem ser definidas com tamanho real de armazenamento.

- Avalie o percentual de valores NULL que uma columa ir� receber para todas as linhas da tabela.
  Um percentual alto de NULL levam uma ocupa��o de espa�o desnecess�rio. 

- Para um percentual alto de NULL para colunas CHAR(n) e que essa coluna n�o � pesquis�vel (n�o faz 
  parte de WHERE, HAVING ou JOIN), avalie e troca para um VARCHAR(n).

*/


