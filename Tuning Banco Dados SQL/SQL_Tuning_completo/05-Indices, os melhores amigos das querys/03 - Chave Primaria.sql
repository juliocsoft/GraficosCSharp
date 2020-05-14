/*
Chave Prim�ria e o �ndice Clusterizado.

Chave Prim�ria � uma coluna ou v�rias colunas de uma tabela que garante a unicidade da linha. 
Por boas pr�ticas, 99% das tabelas devem possuir uma chave prim�ria.

Como ela tem o papel de garantir a unicidade do dado, ela pode ser uma coluna do tipo inteiro (n�o tem rela��o
com os dados da aplica��o) que tamb�m ser� utilizada para refer�ncias outras tabelas.

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

Como boa pr�tica, a chave prim�ria pode ser um INTEIRO com numera��o sequencial crescente.

Quando criamos em uma tabela uma constraint do tipo Primary Key, o SQL Server j� cria um �ndice
Clusterizado �nico para manter essa restri��o.

Exemplos:

*/

use DBDemo
go

drop table if exists tCliente
go

Create Table tCliente (
   iidCliente int not null identity(1,1) ,
   cNome varchar(100), 
   cCPF char(14),
   Constraint PKCliente Primary key 
   (
      iidCliente 
   )
)
go

sp_helpindex 'tCliente'
go
sp_pkeys 'tCliente'


insert into tCliente (cNome, cCPF)
select top 10000 cNome, cCPF from eCommerce.dbo.tCliente
go


set statistics io on
set statistics xml on

Select * from tCliente where iidcliente = 5000

set statistics io off
set statistics xml off

/*
Boa pr�tica

- Criar a chave prim�ria com �ndice Clusterizado.
- Selecionar a coluna que ser� a chave prim�ria como sendo artificial, que n�o faz parte da
  regra de neg�cio da tabela e que n�o sofra modifica��o devido a mundan�as das regras de neg�cio.
- A coluna deve ser n�merica e do tipo inteiro. (mas n�o obrigat�rio).
- Atribua uma n�mera��o autom�tica, usando IDENTITY ou SEQUENCE.
- Evite ao m�ximo colocar duas colunas como chave prim�ria.

*/


/*
Aten��o, o fato de voc� criar um �ndice Clusterizado em uma tabela que n�o tem chave prim�ria, 
a cria��o desse  �ndice n�o significa que a chave prim�ria foi criada.
*/


use DBDemo
go

drop table if exists tCliente
go

Create Table tCliente (
   iidCliente int not null identity(1,1) ,
   cNome varchar(100), 
   cCPF char(14)
)
go

Create Unique Clustered Index PKCliente on tCliente (iidcliente)
go

sp_helpindex 'tCliente'
go
sp_pkeys 'tCliente'


insert into tCliente (cNome, cCPF)
select top 10000 cNome, cCPF from eCommerce.dbo.tCliente
go


set statistics io on
set statistics xml on

Select * from tCliente where iidcliente = 5000

set statistics io off
set statistics xml off


