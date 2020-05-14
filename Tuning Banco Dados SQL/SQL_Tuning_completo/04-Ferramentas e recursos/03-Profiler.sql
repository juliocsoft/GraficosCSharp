/*
Profiler - Ferramenta para rastrear eventos que ocorrem  
no lado do servidor de banco de dados.

Ref.: https://docs.microsoft.com/pt-br/sql/tools/sql-server-profiler/sql-server-profiler?view=sql-server-2017

Eventos:

S�o a��es criadas por um inst�ncia do SQL SERVER, como :

- Conex�es, desconex�es e falhas;
- Bloqueios criados e liberados;
- Aumento e Redu��o do banco de dados;
- Mensagens de erros e avisos.
- Execu��es de comandos SELECT, INSERT, UPDATE e DELETE.
.... 

Os eventos s�o agrupados em classes de eventos. 

A classe de eventos TSQL, por exemplo, tem os seguintes eventos:

Exec Prepared SQL	   Indica que SqlClient, ODBC, OLE DB ou DB-Library 
					   executou uma ou mais instru��es Transact-SQL preparadas.
Prepare SQL			   Indica que SqlClient, ODBC, OLE DB ou DB-Library preparou uma ou mais instru��es Transact-SQL para uso.
SQL:BatchCompleted	   Indica que o lote Transact-SQL foi conclu�do.
SQL:BatchStarting	   Indica que o lote Transact-SQL est� iniciando.
SQL:StmtCompleted	   Indica que uma instru��o Transact-SQL foi conclu�da.
SQL:StmtRecompile	   Indica recompila��es em n�vel de instru��o causadas por todos os tipos de lotes: procedimentos armazenados, gatilhos, lotes ad hoc e consultas.
SQL:StmtStarting	   Indica que uma instru��o Transact-SQL est� iniciando.
Unprepare SQL		   Indica que SqlClient, ODBC, OLE DB ou DB-Library excluiu uma ou mais instru��es Transact-SQL preparadas.
XQuery Static Type	   Ocorre quando o SQL Server executa uma express�o XQuery.

Coluna de dados 
---------------

Atributo de uma classe de eventos que foi rastreado pelo Profiler.
Nem todas as colunas s�o aplicadas para as classes de eventos.
Alguns colunas importantes para o evento "SQL:StmtCompleted"

SPID		   Identifica��o da Sess�o
CPU			Tempo da CPU (em milissegundos) usado pelo evento.	
Dura��o		Per�odo de tempo (em microssegundos) utilizado pelo evento.	
Reads		   N�mero de leituras de p�gina emitidas pela instru��o SQL.	
RowCounts	N�mero de linhas afetadas por um evento.	
TextData	   Texto da instru��o que foi executada.	
Writes		N�mero de grava��es de p�ginas emitidas pela instru��o SQL.	

Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/event-classes/sql-stmtcompleted-event-class?view=sql-server-2017


Filtros

Utilizados para reduzir a quantidade de eventos que s�o capturados.
Ele s�o criados com base nas colunas de dados e utilizam as regras
de condi��es e express�es padr�o.

Vamos a pr�tica. 

*/

select @@SPID

use eCommerce
go

select iIDCliente,cNome, cCPF from tCliente 
where iIDCliente >= cast(rand()*200000 as int) and iIDCliente <= cast(rand()*200000 as int)
go

Select * from tProduto 
where iIDCategoria = 16
go


declare @data datetime 

select top 1 @data = dEntregaRealizada 
  from tMovimento  
  where dEntregaRealizada  is not null 
  order by iIDMovimento desc 

set statistics io on 

Select * from tMovimento 
   join tItemMovimento on tMovimento.iIDMovimento = tItemMovimento.iIDMovimento
where dEntregaRealizada = @data

set statistics io off
go


/*
Table 'tItemMovimento'. Scan count 1, logical reads 3341, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'tMovimento'.		Scan count 1, logical reads 683, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

select 4455 + 2616
*/






/*
Criando um Template para as pr�ximas aulas.
*/

