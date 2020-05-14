/*
Um recurso da ferramenta SSMS, � a coleta de informa��es
referente a execu��o do comandos e a apresenta��o ap�s o seu t�rmino
de execu��o. 

De forma semelhante ao SET STATISTICS, o recurso nativo do SMSS
Include Cliente Statistics, apresenta um conjunto de informa��es

*/

use DBDemo
go


select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

/*

Acionando o Client Statistics 

Com uma query aberta, v� at� o menu principal e selecione Query.
Depois selecione Include Client Statistics.
Se preferir, Shift + Alt + S

Depois execute a query abaixo:
*/

use DBDemo
go
select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

/*
----------------------------------------------
Client Execution Time	18:47:42	
	
Query Profile Statistics	
------------------------		
  Number of INSERT, DELETE and UPDATE statements		
  Rows affected by INSERT, DELETE, or UPDATE statements	
  Number of SELECT statements 							
  Rows returned by SELECT statements	
  Number of transactions 	

Network Statistics	
------------------		
  Number of server roundtrips	
  TDS packets sent from client	
  TDS packets received from server	
  Bytes sent from client	
  Bytes received from server	

  * TDS - Tabular Data Stream - Protocolo de aplicativo usado para transfer�ncia
  de solicita��es e respostas entre clientes e servidor de banco de dados.

Time Statistics	
---------------		
  Client processing time	
  Total execution time	
  Wait time on server replies	

As colunas Trialn (onde n � um n�mero sequencial), representa a identifica��o
da execu��o e a colunva Average (M�dia) representa os valores m�dios das execu��es.

*/


/*
Um exemplo utilizando 3 comandos 
*/

select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)
  go
  select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)
  go
select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

set nocount off


/*
Utilizandos SELECT , INSERT, UPDATE E DELETE 
*/

Begin transaction 

select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

update tCliente set mCredito = mCredito * 1.10
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

delete tCliente 
where iIDCliente >= cast(rand()*200000 as int) 
  and iIDCliente <= cast(rand()*200000 as int)

insert into tCliente (iIDEstado, cNome, cCPF, cEmail, cCelular, dCadastro, 
dNascimento, cLogradouro, cCidade, cUF, cCEP, 
dDesativacao, mCredito
) Select top 10 iIDEstado, cNome, cCPF, cEmail, cCelular, dCadastro, 
dNascimento, cLogradouro, cCidade, cUF, cCEP, 
dDesativacao, mCredito
 from eCommerce.dbo.tCliente 
 
Rollback 





