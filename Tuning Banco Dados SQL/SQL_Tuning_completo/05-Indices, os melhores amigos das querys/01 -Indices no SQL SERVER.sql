/*
�ndices no SQL Server.

- Um �ndices � um objeto de aloca��o de dados associado a uma tabela ou exibi��o 
  que tem o �nico objetivo de aumentar o desempenho na recupera��o de dados.
  Em um caso espec�fico, um �ndice armazenar� os dados da tabela inteira. 

- Import�ncia de um �ndices:
    - Se n�o existir, ter� problema de performance.
	 - Se criado de forma inadequada, ter� problema de performance.
	 - Se criar muitos �ndices, ter� problema de performance.
    
*/

use DBDemo
go

drop table if exists tAluno
go

Create Table tAluno (
   Id int,                 
   Nome varchar(50),       
   Cpf char(11),           
   Nascimento datetime,    
   Endereco varchar(30)  
)

insert into tAluno (Id,Nome,Cpf,Nascimento,Endereco) values (1,'Joao da Silva','12345670801'  ,'2001-06-27','Rua A')
insert into tAluno (Id,Nome,Cpf,Nascimento,Endereco) values (92,'Jose de Souza'  ,'54875214801','1997-12-17','Rua Numero 2')
insert into tAluno (Id,Nome,Cpf,Nascimento,Endereco) values (83,'Maria Aparecida','45872155801','2003-03-18','Rua BBB')
insert into tAluno (Id,Nome,Cpf,Nascimento,Endereco) values (44,'Joaquim Gomes','12548568801'  ,'1995-10-28','Rua XPTO')
insert into tAluno (Id,Nome,Cpf,Nascimento,Endereco) values (05,'Manoel Cintra','25425865801'  ,'2002-11-02','Rua Letra X')
insert into tAluno (Id,Nome,Cpf,Nascimento,Endereco) values (56,'Joao da Silva','52411585801'  ,'2003-01-15','Rua 456')
insert into tAluno (Id,Nome,Cpf,Nascimento,Endereco) values (17,'Jose da Silva' ,'63584558801' ,'1998-02-23','Rua JKKK')
insert into tAluno (Id,Nome,Cpf,Nascimento,Endereco) values (28,'Patricio Porto'    ,'52458554801','1994-09-30','Rua 434')
insert into tAluno (Id,Nome,Cpf,Nascimento,Endereco) values (59,'Manuela dos Montes','54114856801','1999-10-10','Rua B')
insert into tAluno (Id,Nome,Cpf,Nascimento,Endereco) values (10,'Joao da Silva'    ,'54788565801','2001-06-14','Rua 999')
go

Select * from tAluno


/*
tAluno 
+--+------------------+-----------+----------+------------+
|Id|Nome              |Cpf        |Nascimento|Endereco    |
+--+------------------+-----------+----------+------------+
|1 |Joao da Silva     |12345670801|2001-06-27|Rua A       |
|92|Jose de Souza     |54875214801|1997-12-17|Rua Numero 2|
|83|Maria Aparecida   |45872155801|2003-03-18|Rua BBB     |
|44|Joaquim Gomes     |12548568801|1995-10-28|Rua XPTO    |
|5 |Manoel Cintra     |25425865801|2002-11-02|Rua Letra X |
|56|Joao da Silva     |52411585801|2003-01-15|Rua 456     |
|17|Jose da Silva     |63584558801|1998-02-23|Rua JKKK    |
|28|Patricio Porto    |52458554801|1994-09-30|Rua 434     |
|59|Manuela dos Montes|54114856801|1999-10-10|Rua B       |
|10|Joao da Silva     |54788565801|2001-06-14|Rua 999     |
+--+------------------+-----------+----------+------------+

Create Index idxID on tAluno (id) 

tAluno                                                      -->>   idxID   
+--+------------------+-----------+----------+------------+        +--+
|Id|Nome              |Cpf        |Nascimento|Endereco    |        |Id|
+--+------------------+-----------+----------+------------+        +--+
|1 |Joao da Silva     |12345670801|2001-06-27|Rua A       | <------|1 |
|92|Jose de Souza     |54875214801|1997-12-17|Rua Numero 2|   +----|5 |
|83|Maria Aparecida   |45872155801|2003-03-18|Rua BBB     |   | +--|10|
|44|Joaquim Gomes     |12548568801|1995-10-28|Rua XPTO    |   | |  |17|
|5 |Manoel Cintra     |25425865801|2002-11-02|Rua Letra X | <-+ |  |28|
|56|Joao da Silva     |52411585801|2003-01-15|Rua 456     |     |  |44|
|17|Jose da Silva     |63584558801|1998-02-23|Rua JKKK    |     |  |56|
|28|Patricio Porto    |52458554801|1994-09-30|Rua 434     |     |  |59|
|59|Manuela dos Montes|54114856801|1999-10-10|Rua B       |     |  |83|
|10|Joao da Silva     |54788565801|2001-06-14|Rua 999     | <-- +  |92|
+--+------------------+-----------+----------+------------+        +--+

- Essa estrutura de �ndice ocupar� fisicamente as p�ginas (que ser�o as p�ginas 
  de �ndices, com 8192 bytes) e essas p�ginas poder�o ser contabilizadas na 
  aloca��o total de dados da tabela. 

- Uma estrutura que utiliza a arquitetura de �rvore balanceda, onde as colunas selecionadas
  de uma tabela ser�o as chaves de pesquisa.
  
- Como visto na aula "Conceitos de Arvore Balanceada", uma b-tree � uma estrutura que organiza
  os dados a partir de um n� raiz (root), onde ele armazena as chaves e cria os ponteiros para os n�s
  intermedi�rios at� chegar aos n�s que n�o tem ponteiros ou n�s folhas. 

- Criando essa estrutura no SQL Server, cada n� de um �ndice ser� uma p�gina de �ndice. Cada p�gina
  ter� os dados das colunas selecionadas, distribu�das de forma ordenada sempre come�ando 
  pela p�gina raiz.

- As p�ginas intermedi�rias conter�o as refer�ncias da p�gina anterior ou da raiz. At� chegarem nas 
  p�ginas folhas.

- As p�ginas folhas, ter�o duas fun��es de acordo com o tipo de indice que utilizaremos:
    - Elas ser�o as p�ginas de dados que conter�o todas as linhas e colunas. 
	 - Elas ser�o p�ginas de �ndices e ter�o um pointeiro que ir� fazer uma refer�ncia a linha da tabela.
 
- Comando b�sico para criar um �ndice:

  Create Index <Nome do Indice> on <Nome da tabela>  (<Coluna1>,<Coluna2>,...) .....

  
*/
use eCommerce
go

sp_spaceused 'tMovimento'
go

/*
sp_spaceused

name		   rows					   reserved	   data		   index_size	unused
tMovimento	217430              	26888 KB 	26776 KB	   8 KB	      104 KB
*/

/*
Limpar a �rea de buffer.
*/
Checkpoint 
go
dbcc DROPCLEANBUFFERS
go 

select * from sys.dm_os_buffer_descriptors
where database_id = DB_ID()


/*
Aloca��o em mem�ria 
*/
select b.page_type as cTipoPagina, 
       count(b.page_id) as nQtdPaginas, 
	   count(b.page_id) / 128.0 as nMemoriaMB  
  from sys.dm_os_buffer_descriptors b -- Cont�m as informa��es do Buffer 
  join sys.allocation_units a         -- Informa��es de unidade de aloca��o dos objetos
    on b.allocation_unit_id = a.allocation_unit_id
  join sys.partitions p               -- Parti��es dos objetos de aloca��o.
    on a.container_id = p.partition_id
 where p.object_id = object_id('tMovimento')  
   and b.page_type in ( 'DATA_PAGE' , 'INDEX_PAGE')
   and b.database_id = DB_ID()
   group by b.page_type
go

/*
Aloca��o f�sica dos dados
*/	 
select rows,
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
 where p.object_id = object_id('tMovimento')
go


/*
rows	   total_pages	used_pages	data_pages	data_compression_desc	index_id	name	type_desc
217430	3361	      3348	      3347	      NONE	                  0	      NULL	HEAP

*/

 
/*
Ativar a apresenta��o do Plano de Execu��o 
*/
set statistics io on 
set statistics xml on

Select  iIDMovimento , nNumero, dMovimento  from tMovimento where iIDCliente = 106782

set statistics io off -- N�o esquecer de executar
set statistics xml off


/*
Table 'tMovimento'. Scan count 1, logical reads 3347, physical reads 0, read-ahead reads 3354, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tMovimento'. Scan count 1, logical reads 4, physical reads 4, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

*/

set statistics io off 
/*
Desativar a apresenta��o do Plano de Execu��o 
*/

/*
Aloca��o em mem�ria 
*/
select b.page_type as cTipoPagina, 
       count(b.page_id) as nQtdPaginas, 
	   count(*) / 128.0 as nMemoriaMB , 
	   sum(case when is_modified=1 then 1 else 0 end) nQtdPaginasAlteradas
  from sys.dm_os_buffer_descriptors b -- Cont�m as informa��es do Buffer 
  join sys.allocation_units a         -- Informa��es de unidade de aloca��o dos objetos
    on b.allocation_unit_id = a.allocation_unit_id
  join sys.partitions p               -- Parti��es dos objetos de aloca��o.
    on a.container_id = p.partition_id
 where p.object_id = object_id('tMovimento')  -- Somente visualizar para a tabela tMovimento.
   and b.page_type in ( 'DATA_PAGE' , 'INDEX_PAGE') -- Visualizar Paginas de Dados e P�ginas de Indices.
   and b.database_id = DB_ID()
   group by b.page_type
go

go

/*

cTipoPagina   nQtdPaginas nMemoriaMB                              nQtdPaginasAlteradas
------------- ----------- --------------------------------------- --------------------
DATA_PAGE	  3347	     26.148437	                              0

*/

/*
Criando um indice 
*/
Create Index IDX_IDCLIENTE on tMovimento (iIDCliente) 


/*

Excluir um �ndice 

*/

Drop Index tMovimento.idx_idcliente


