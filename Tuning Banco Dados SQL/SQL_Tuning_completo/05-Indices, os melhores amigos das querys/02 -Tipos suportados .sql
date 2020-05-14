/*
O SQL Server 2017 tem suporte a diversos tipos de �ndices. S�o eles:

Hash 
N�o clusterizado com otimiza��o de mem�ria.
Clusterizado
N�o Clusterizado
Exclusivo
ColumnStore
Indices com colunas inclu�das
Indices com colunas computadas
Indices filtrados
Espacial
XML
Indice para Full Text Search 

Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/indexes/indexes?view=sql-server-2017


Nossa !! Sim, tudo isso para que voce tenha as querys com a melhor performance... 

Mas n�o veremos todos eles. Vou focar nos mais utilizados e com base em todo o conte�do quem foi explicado 
at� agora.  S�o Eles:

Clusterizado
N�o Clusterizado
Exclusivo
Indices com colunas inclu�das
Indices com colunas computadas
Indices filtrados

Clusterizado e N�o Clusterizado.
-------------------------------

Esses tipos de �ndices tem a basicamente a mesma estrutura de armazanamento.
   - Voce define as colunas que ser�o chaves.
   - Ele criar um estrutura b-tree e distribui as chaves desde a p�gina raiz at� as p�ginas folhas.

A diferen�a:

   - Em um �ndice Clusterizado, os dados da tabela s�o movidos para as p�ginas folhas e organizados 
     de acordo com a chave do �ndice. Podemos dizer que quando voc� pesquisa em um �ndice cluster, voc�
	  est� pesquisando na pr�pria tabela. Quando criamos um �ndices clusterizado, a tabela deixa de ser uma
	  HEAP TABLE e passa a ser uma CLUSTERED TABLE. 

	 Somente um �ndice Clusterizado pode ser criando na tabela.

   - Em um �ndice n�o Clusterizado, todas as p�ginas do �ndice tem somente as chaves do �ndice. 
     Quando um query utiliza um �ndice n�o Clusterizado, o SQL Server efetua a pesquisa pelo �ndice at�
	  encontrar as chaves da pesquisa nas p�ginas folhas. 

   - Essas p�ginas cont�m as chaves de pesquisa mais um ponteiro para recuperar os demais dados. 
	  Se os dados est�o em uma HEAP TABLE, as chaves do �ndice tem um ponteiro para as linhas da tabela. 
	  Se os dados est�o em uma CLUSTERED TABLE, as chaves do �ndice tem a chave do �ndice Clusterizado.

     J� os �ndices n�o Clusterizado, podem ser criados at� 999 (argh!!) por tabela. 

Algumas limita��es:
  -- Tamanho da chave at� 900 bytes pra Clusterizado e 1700 bytes para n�o clusterizado.
  -- At� 32 colunas por chave de �ndice.
  
*/

use DBDemo
go

Select * from tAluno



/*
Exemplo de Indice Clusterizado 

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

Create Clustered Index idcID on tAluno (id) 

+--+------------------+-----------+----------+------------+
|Id|Nome              |Cpf        |Nascimento|Endereco    |
+--+------------------+-----------+----------+------------+
|1 |Joao da Silva     |12345670801|2001-06-27|Rua A       |
|5 |Manoel Cintra     |25425865801|2002-11-02|Rua Letra X |
|10|Joao da Silva     |54788565801|2001-06-14|Rua 999     |
|17|Jose da Silva     |63584558801|1998-02-23|Rua JKKK    |
|28|Patricio Porto    |52458554801|1994-09-30|Rua 434     |
|44|Joaquim Gomes     |12548568801|1995-10-28|Rua XPTO    |
|56|Joao da Silva     |52411585801|2003-01-15|Rua 456     |
|59|Manuela dos Montes|54114856801|1999-10-10|Rua B       |
|83|Maria Aparecida   |45872155801|2003-03-18|Rua BBB     |
|92|Jose de Souza     |54875214801|1997-12-17|Rua Numero 2|
+--+------------------+-----------+----------+------------+
*/

/*
Criando um indice Clusterizado
------------------------------

Sintaxe:
Create Clustered Index <Nome do Indice> on <Nome da tabela>  (<Coluna1>,<Coluna2>,...) 

*/
use eCommerce
go

/*
Aloca��o dos dados 
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


select sys.fn_PhysLocFormatter(%%physloc%%), * 
  from tMovimento 
 where iIDMovimento = 127461
go


/*
RID  (6:2888:60) para movimento 127461, em uma Heap Table 
*/

Create Clustered Index idcIdMovimento on tMovimento(iidmovimento)
go

Select sys.fn_PhysLocFormatter(%%physloc%%), * 
  from tMovimento 
 where iIDMovimento = 127461

/*
RID  (6:28354:51)para movimento 127461, em um Clustered Table. 

Veja que os dados da linha "iIDMovimento = 127461" foram movidas da p�gina  2888 para a p�gina 28354 

*/


/*
Aloca��o dos dados 
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
Exemplo de �ndices n�o Clusterizado.

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
*/

/*

Criando um indice N�o Clusterizado
------------------------------
Sintaxe:

Create NonClustered Index <Nome do Indice> on <Nome da tabela>  (<Coluna1>,<Coluna2>,...) 
ou
Create Index <Nome do Indice> on <Nome da tabela>  (<Coluna1>,<Coluna2>,...) 

*/

set statistics io on 
set statistics xml on

select * from tMovimento where dMovimento = '2016-03-30 15:31:40.000'
select * from tCliente where cCPF = '1677022136699'

set statistics io off
set statistics xml off


-- �ndice pela Data do Movimento. Coluna dMovimento, datetime 
Create Nonclustered Index IdxDataMovimento on tMovimento (dMovimento) 
go

-- �ndice pelo CPF do cliente. Coluna cCPF, char(14) 
Create  Index IdxCPF on tCliente (cCPF) 
go


/*
Demonstrando em um �ndice n�o clusterizado, que as chaves pode conter um ponteiro para um
HEAP TABLE ou conter a chave de um �ndice Clusterizado.

Para isso, temos que ativar a apresenta��o do Plano de Execu��o.

*/

set statistics io on 
set statistics xml on

select * from tMovimento where dMovimento = '2016-03-30 15:31:40.000'
select * from tCliente where cCPF = '1677022136699'

set statistics io off
set statistics xml off




/*
Outro exemplo que a chave do �ndice Clusterizado est� dentro do �ndice N�o Clusterizado.
*/

sp_helpindex 'tMovimento'

set statistics io on 
Select dMovimento 
  From tMovimento 
 Where dMovimento = '2016-03-30 15:31:40.000'

Select iidcliente, dMovimento 
  From tMovimento 
 Where dMovimento = '2016-03-30 15:31:40.000'

Select iIDMovimento, dMovimento 
  From tMovimento 
 Where dMovimento = '2016-03-30 15:31:40.000'


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
 where p.object_id in ( object_id('tMovimento') , object_id('tCliente'))
go



/*

*/

sp_helpindex 'tMovimento'
go

/*
idcIdMovimento		clustered located on INDICESTRANSACIONAIS		iIDMovimento
IdxCodigo			nonclustered located on INDICESTRANSACIONAIS	cCodigo
IdxDataMovimento	nonclustered located on INDICESTRANSACIONAIS	dMovimento
*/

/*
Como os indices s�o selecionados 
*/

set statistics io on 

Select * from tMovimento where nNumero = 45929

Select * from tMovimento where dMovimento = '2016-03-20 12:02:24.000'

Select * from tMovimento where dMovimento >= '2016-03-20' and dMovimento < '2016-03-21'

Select * from tMovimento where dMovimento >= '2017-12-10' and dMovimento <= '2017-12-12'


sp_helpindex tcliente
