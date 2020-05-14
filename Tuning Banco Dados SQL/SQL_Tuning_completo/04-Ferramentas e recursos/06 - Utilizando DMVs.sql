/*
Como utilizar DMV para identificar querys lentas 

- Como visto na Breve Introdu��o a DMVs, s�o objetos que informam o estado de diversos componentes de 
  uma inst�ncia do SQL Server, retornando um conjunto de informa��es
  �teis que ir�o n�s ajudar por exemplo em entender o armazenamento ou a 
  utiliza��o de recursos. Claro, ajudar a identificar as querys mais lentas.

- Para atender a se��o de identificar querys lentas, utilizaremos um grupo de DMV
  (vista na aulas de DMVs e novas DMVs) que retornam informa��es de consumo dos
  recursos da inst�ncia. 

*/

/*
Aten��o !!!

Abrir o arquivo 09a - Apoio a introdu��o a DMVs
ir at� "Segunda parte - Para explica��o das DMVs relacionadas a �ndices"
e executar o script 01, 02 e 03 juntos .
*/

-- Mostra as Sess�es autenticadas na inst�ncia do SQL Server.

Select * 
  From sys.dm_exec_sessions

/*
Session_id at� 50 s�o sess�es utilizadas internamente pelo SQL Server 
*/

Select * 
  From sys.dm_exec_sessions 
  Where session_id >= 51

  select @@SPID

/*
Explica��o de algumas colunas 

Login_time     - Data que a sess�o foi estabelecidade. 
Program_name   - Nome do programa cliente que iniciou a sess�o.
Login_name     - Nome do Login que iniciou a sess�o. Pode ser uma conta do Windows ou do SQL Server.
Status         - Status da sess�o:
                  - Executando (Running) - Executando uma solicita��o;
                  - Em Suspens�o (Slepping) - Aguardando uma solicita��o;
                  - Inativo (Dormant) - Sess�o reiniciado, aguarando pre-logon.
Cpu_time       - Tempo de CPU em millisegundos utilizado pelo sess�o.
Memory_usage   - Contagem de p�ginas usadas pela sess�o.
Reads          - Contagem de leitura executadas.
Write          - Contagem de grava��es executadas.
Logical_reads  - Contagem de leituras l�gicas

Ref.: 
https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-sessions-transact-sql?view=sql-server-2017
*/



-- Mostra as informa��es sobre as execu��es

Select * 
  From sys.dm_exec_requests 
  Where session_id >= 51

/*
Explica��o de algumas colunas 

Start_time  - Data e hora que a solicita��o 
Command     - Tipo do Comando. Exemplos : SELECT,INSERT, UPDATE, DELETE, BACKUP, CREATE entre outros. 
Database_id - ID do banco de dados. Voce pode usar a fun��o DB_NAME(Database_id) para retorna o nome do banco de dados
Blocking_session_id - Se a sess�o atual est� sendo bloqueada por outra sess�o.

Cpu_time,Reads,Write,Logical_reads s�o os mesmo da dm_exec_sessions, mas representam valores somente da solicita��o atual.

sql_handle              - Mapa de Hash do texto SQL da solicita��o. O texto � um NVARCHAR
statement_start_offset  - Posi��o inicial da instru��o em execu��o dentro da solicita��o
statement_end_offset    - Posi��o final da instru��o em execu��o dentro da solicita��o

Essa posi��o � o deslocamento em bytes desde o inicio do texto SQL. Como o retorno � 
um NVARCHAR, cada posi��o vale 2 bytes.

Para calcular a posi��o real, os valores acima devem ser divido por 2. 


*/
  
Select @@SPID  -- Retorna a Identifica��o da sess�o do processo da conex�o atual 

Select * 
  From sys.dm_exec_requests 
  Where session_id = @@SPID

/*
*/

Select session_id ,  program_name, login_name , status, cpu_time, memory_usage, reads, writes, logical_reads 
  From sys.dm_exec_sessions 
  where session_id >= 51 

Select session_id, start_time , status, command  , database_id , cpu_time , reads, writes, logical_reads, sql_handle
  From sys.dm_exec_requests 
  Where session_id >= 51


Select session_id, start_time , status, command  , database_id , cpu_time , reads, writes, logical_reads ,
       sql_handle ,
       statement_start_offset,
       statement_end_offset
  From sys.dm_exec_requests 
  Where session_id >= 51


/*
Fun��o de gerenciamento din�mico sys.dm_exec_sql_text()

Recebe como par�metro o Map de Hash da solicita��o e retorna na
coluna 'Text', o conjunto de instru��es da solicita��o.

*/

select text from sys.dm_exec_sql_text(0x0200000027B0B720D06E6AB5DA7508812CAD4C09AA8082730000000000000000000000000000000000000000)

/*
Colunas statement_start_offset tem o valor 1648 e o statement_end_offset o valor 1908 
*/

declare @nInicial int = 1648 
declare @nFinal   int = 1908 

Select SUBSTRING(Text, @nInicial/2, (@nFinal-@nInicial)/2) as Instrucao 
  From sys.dm_exec_sql_text(0x0200000027B0B720D06E6AB5DA7508812CAD4C09AA8082730000000000000000000000000000000000000000)
go


-- Apresenta as execu��es de comandos das conex�es atuais.

SELECT session_id, start_time , status, command  , database_id , cpu_time , reads, writes, logical_reads ,
        substring (SqlText.text,
                  (Requests.statement_start_offset/2)+1,   
                  ((Requests.statement_end_offset - Requests.statement_start_offset)/2) + 1) AS statement_text  
FROM sys.dm_exec_requests AS Requests
CROSS APPLY sys.dm_exec_sql_text(Requests.sql_handle) AS SqlText 
where Requests.session_id = 58
go


Select session_id ,  program_name, login_name , status, cpu_time, memory_usage, reads, writes, logical_reads 
  From sys.dm_exec_sessions 
  where session_id = 56 



/*
Analisando o plano de cache com a DMVs. sys.dm_exec_query_stats
*/

select * from  sys.dm_exec_query_stats

use DBDemo
go

select total_worker_time/1000000.0 ,total_elapsed_time/1000000.0 ,  *  from sys.dm_exec_query_stats


SELECT TOP 10
       CAST((QueryStat.total_worker_time) / 1000000.0 AS DECIMAL(28,2)) AS [nTempoTotalCPU(s)],
       CAST(QueryStat.total_worker_time * 100.0 / QueryStat.total_elapsed_time AS DECIMAL(28,2)) AS [n%CPU],
       CAST((QueryStat.total_elapsed_time - QueryStat.total_worker_time)* 100.0 /QueryStat.total_elapsed_time AS DECIMAL(28, 2)) AS [n%Esperando] ,
       QueryStat.execution_count as nExecucoes ,
       CAST((QueryStat.total_worker_time) / 1000000.0	/ QueryStat.execution_count AS DECIMAL(28, 2)) AS [nTempoMedioCPU(s)],
       QueryStat.total_logical_reads as  nTotalLeiuraLogicas, 
       SUBSTRING (QueryText.text,
                 (QueryStat.statement_start_offset/2) + 1, 
                 ( (case when QueryStat.statement_end_offset = -1
	                      then datalength(QueryText.text) 
	                      else QueryStat.statement_end_offset
	                 end - QueryStat.statement_start_offset)/2
                 ) + 1
                 ) AS cComando,
       QueryText.text AS cObjeto ,
       db_name(QueryText.dbid) AS cBancoDeDados,
       QueryStat.creation_time as dCriacao, 
       QueryStat.last_execution_time as dUltimaExecucao 
 FROM sys.dm_exec_query_stats QueryStat
 CROSS APPLY sys.dm_exec_sql_text(QueryStat.sql_handle) as QueryText
 WHERE QueryStat.total_elapsed_time > 0
 ORDER BY 1 DESC


 /*
 */






