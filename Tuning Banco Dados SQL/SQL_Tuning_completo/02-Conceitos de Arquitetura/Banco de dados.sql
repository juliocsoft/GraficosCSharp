/*
Dicas para criar um banco de dados com alto desempenho.

Como todos sabemos, um banco de dados � o local onde confiamos para que 
as aplica��es guardem os dados e mantenha os integros e seguros.

Mas tamb�m, o banco de dados devem garantir que o dados seja acessado o mais r�pido possivel.

Na realidade, n�o � o banco que deve garantir, mas quem o criou e configurou o 
banco de dados, o servi�o do SQL Server instalado e as configura��es do sistema operacional. 

Em suma, voce que est� vendo esse treinamento � o respons�vel que deve garantir o acesso com 
desempenho dos dados armazenados no banco de dados. 

Vamos ent�o ver quais s�o essas configura��es que devem realizar para garantir
o alto desempenho da consultas.
*/


/*
Servidor 
--------

1. Discos.

   - Preferencialmente devem ser r�pidos. Discos SSD s�o benvindos, devido a sua
     alta performance e em contra-partida temos o custo elevado. 
     Discos com tecnologia Fibre Channel s�o mais acess�veis e garante 
     alta performance. De prefer�ncia a discos que tenham 15K e evite os discos de grande
     capacidade com 1Tb ou mais. 

     Ref.: https://technet.microsoft.com/pt-br/library/dn610883%28v=ws.11%29.aspx?f=255&MSPPError=-2147217396

   - Utilizem v�rios discos para distribui��o de carga de dados. Nada impede de voce 
     instalar tudo em um �nico disco. Mas voce incorre a problemas de desempenho do 
     SO e banco de dados como tamb�m s�rios problemas de seguran�a.

     Boas pr�ticas.
     --------------

     1 Disco para o SO
     1 Disco para dados, �ndices e �rea tempor�ria 
     1 Disco para log       

     1 Disco para SO
     1 Disco para dados e �ndices
     1 Disco para log
     1 Disco para �rea tempor�ria 

     1 Disco para SO
     1 Disco para dados 
     1 Disco para �ndices
     1 Disco para log
     1 Disco para �rea tempor�ria 
          
   - Utilize formata��o de blocos de 64K para discos onde ser�o gravados os dados.
*/

select * from sys.dm_os_enumerate_fixed_drives

/*

2. Mem�ria.

   - Quanto mais, melhor. Mem�ria ser� utilizada para carregar os dados que est�o em 
     disco para um �rea no SQL Server conhecida como Buffer Pool.

   - Quando mais dados o SQL Server conseguir manter em mem�ria, melhor. Servidores com 
     16Gb, 32GB ou 64Gb atende a maioria das demandas. Mas encontramos instala��es que 
     chegam a mais de 512Gb de mem�ria. 

     Apesar da recomenda��o m�nima da Microsoft para mem�ria do SQL Server � de 1Gb, 
     eu recomendo inicial com 4Gb, mas o correto deve ser a anal�se do ambiente para 
     um melhor dimensionamento.

3. CPU

   - Processador ou core est� relacionado diretamente a velocidade de processamento como
     tamb�m a forma como o licenciamento do SQL Server deve ser adquirido. 
   - Quanto mais r�pido melhor. Olhando para o licenciamento, voce deve ter uma CPU com
     pelo menos 2 core. Recomenda-se iniciar com 4 cores, mas vale a an�lise do ambiente.


Sistema Operacional - Windows 
-----------------------------

1. Windows Server a partir da vers�o 2016 Standard. Claro que quanto maior a edi��o,
   mais recursos de hardware voce poder� utilizar. Por exemplo, o total de n�cleos de CPU
   que uma vers�o do SQL Server suporte � limitada ao m�ximo que o Windows Server suporta. 

2. Configura��o de plano de energia. 

   - Um servidor de banco de dados sempre ficar� ligado e n�o ser� necess�rio um monitor ligado 24
     horas e, novamente, deve garantir alto desempenho. Existe uma configura��o no Windows de plano
     de energia que voce configura para obter mais desempenho. 

   - Demonstra��o

3. Lock Page in Memory.

   O Windows Server "ainda" trabalha com o conceito de mem�ria virtual em disco 
   (arquivo de pagina��o) que ele utiliza para paginar dados entre a mem�ria fisica e a virutal.

   O conceito � transferir para o arquivo de pagina��o, dados que est�o em mem�ria mas n�o 
   est�o em utiliza��o pelas aplica��es. Ent�o o Windows transfere esses dados da mem�ria
   f�sica para a mem�ria virtual. Se o dados for acessado pela aplica��o, o Windows ent�o
   carrega os dados da mem�ria virtual e transfere para a mem�ria f�sica, fazendo uma troca 
   com os dados mais antigos em mem�ria. 

   No caso do SQL Server, al�m de armazenar os dados em mem�ria, ele tamb�m armezana informa��es
   sobre as tabelas, planos de execu��o entre outros que podem ser raramente acessados. Com isso,
   eles podem ser enviados para o arquivo de pagina��o.

   Para enviar isso, o Windows tem um mecanismo que impede essa troca de dados. Esse mecanismo
   � uma permiss�o que � concedida a conta do usu�rio que executa o servi�o do SQL SERVER 
   chamado de "Lock Pages in Memory" 

   Demonstra��o:

   - Identificando a conta que executa o servi�o do SQL Server.
   - Conceder a permiss�o.

   Ref.: https://docs.microsoft.com/pt-br/sql/database-engine/configure-windows/enable-the-lock-pages-in-memory-option-windows

4. Performance Volume Maintenance Tasks.

   Quando o Windows recebe uma solita��o do SQL SERVER para criar um um arquivo ou 
   aumentar um arquivo em disco, o Windows aloca esse espa�o em disco e come�a a preencher 
   com zeros. Esse procedimento � o padr�o para substituir dados de arquivos que foram exclu�dos.
   Ent�o isso leva um certo tempo, at� o processo terminar e o Windows liberar o arquivo para  
   o SQL Server.
   
   Quando voc� est� criando um banco de dados para colocar um sistema em produ��o ou criando um
   novo servidor, o fato de Windows preencher com zeros o conte�do dos arquivos n�o � t�o cr�tico 
   pois n�o existe nesse momento um necessidade das consultas terem um alto desempenho.

   Mas quando temos um banco em produ��o com diversas consultas em execu��o, o SQL SERVER 
   por meio dos seus mecanismos interno, solicita ao Windows um aumento no tamanho do arquivo 
   de dados. Quando o Windows recebe essa solicita��o, ele inicia a aloca��o do espa�o solicitado,
   preenche esse espa�o com zeros e devolve ao SQL Server o arquivo modificado. Esse tempo de alocar, 
   preencher e devolver, pode afetar o tempo de execu��o das consultas.

   Existe uma forma de impedir que o Windows execute a etapa de preencher com zeros, realizando
   somente a aloca��o do espa�o e a devolu��o do arquivo para o SQL Server. 

   � uma outra permiss�o que � concedida a conta do usu�rio que executa o servi�o do SQL SERVER 
   chamado de "Performance Volume Maintenance Tasks" 

   Demonstra��o:

   Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/databases/database-instant-file-initialization


SQL Server 
----------

1. Configurando a mem�ria no SQL SERVER.

   Quando instalamos o SQL SERVER, ele configura autom�ticamente a utiliza��o da mem�ria dispon�vel
   no servidor. Ele tem as op��es de "Max Server Memory" e "Min Server Memory"  que voce pode consultar
   com o seguinte comando:
*/

execute sp_configure 'show advanced options' , 1
go
reconfigure with override 

execute sp_configure 'min memory per query (KB)'
execute sp_configure 'max server memory (MB)'

/*
   Na execu��o acima temos 1024Kb de memoria m�nima e  2147483647KB(?) de memoria m�xima.
   2 Tb de mem�ria m�xima? 

   Min Server Memory, n�o significa mem�ria m�nima que o SQL SERVER utiliza.
   
   - Quando inicializamos o servi�o do SQL Server, ele aloca inicialmente 128Kb e espera as atividades
     de inclus�o, altera��o e exclus�o de dados pela aplica��o. No decorrer da execu��o das consultas, 
     o SQL SERVER carrega os dados do disco e aloca na mem�ria que ele reservou. Essa mem�ria inicial 
     at� atingir o valor de 'Min Server Memory' � do SQL SERVER e ele n�o entrega ao SO, se ele solicitar. 

     Quando a aloca��o ultrapassa esse valor m�nimo, O SQL Server continua a alocar mais mem�ria. Mas se 
     por algum motivo, o SO solicitar mem�ria do SQL Server, o mesmo pode liberar a mem�ria, mas at� 
     atingir o limite m�nimo.

   Max Server Memory, n�o significa mem�ria m�xima que o SQL SERVER utiliza. 

   - Quando o SQL SERVER continua a realizar a aloca��o de dados do disco para a mem�ria, ele somente 
     realiza as aloca��es at� atingir o valor de 'Max Server Memory'. Se o SQL Server precisar alocar 
     novos dados em memoria, ele come�a grava em discos os dados mais antigos em discos, liberar a area 
     da mem�ria e aloca os novos dados. 

     Se o SO n�o tiver mem�ria suficiente para trabalhar ou para outras aplica��es alocarem seus dados,
     o SO solicita ao SQL Server mem�ria. Se a mem�ria do SQL SERVER reservado n�o estivar alocada com 
     dados, ele libera��o essa mem�ria para o SO. Se esse mem�ria estiver aloca��o, o SQL Server grava
     os dados em disco e libera a memoria para o SO. 

     O SQL Server liberar mem�ria at� atingir o valor de 'Min Server Memory'

     ReF.: https://www.youtube.com/watch?v=OijdLj4lw5c

*/

-- Visualizando memoria total do servidor 

select total_physical_memory_kb / 1024.0     as MemoriaTotal ,
       available_physical_memory_kb / 1024.0 as MemoriaDisponivel 
from sys.dm_os_sys_memory

/*
MemoriaTotal	MemoriaDisponivel
------------   -----------------
 2047.421875	       403.734375
*/


execute sp_configure 'min memory per query (KB)' , 512
go
reconfigure with override 
go
execute sp_configure 'max server memory (MB)' , 1536
go
reconfigure with override 


select db_name(database_id) as BancoDeDados, 
       (count(1) * 8192 ) / 1024 /1024
  from sys.dm_os_buffer_descriptors
group by db_name(database_id)  


/*

2. Configura��o do banco TEMPDB

   O banco de dados TEMPDB � um entre os diversos bancos de dados chamados de banco 
   de sistemas do SQL SERVER como o MASTER, MSDB, MODEL. O papel do TEMPDB � ser 
   uma �rea tempor�ria de dados. Ele pode ser usando para criar tabelas tempor�rias, 
   indices, versionamento de linhas de transa��es, armazenamento de tabelas do tipo vari�veis, 
   resultados intermedi�rios de GROUP BY, ORDER BY ou UNION, etc..

   Quando uma consulta � executada pela aplica��o, em algum momento ela deve carregar os dados
   para serem processados no CPU. O processo por sua vez pode exigir que dados criados pela 
   consulta fiquem registrados em uma �rea tempor�ria. 

   Para isso, o SQL Server utiliza o TEMPDB. Ele acessa o banco de dados, cria uma tabela 
   tempor�ria e grava os dados nessa tabela. 
   
   Como um banco de dados � formado no m�nimo por um arquivo de dados, toda a demanda de
   criar dados no TEMPDB deve passar por um �nico arquivo de dados. 

   Em sistema de grandes capacidades e processamento, esse acesso por um �nico arquivo
   pode gerar a chamada conten��o do TEMPDB. onde pode-se gerar um fila para acesso aos dados 
   tempor�rios. 

   Se temos uma instala��o do SQL Server em um servidor com 4 cores, cada um deles pode
   receber diversas solicita��es de processamento e consequentemente solicitar para armazenar
   dados no TEMPDB. Como o acesso a CPU � superiormente mais r�pido que o acesso a disco,
   os processos em cada core ficam aguardando a resposta do TEMPDB. 

   Agora imagine uma instala��o com 32 cores !!!

   Para diminuir essas conten��o, podendos criar ou adicionar arquivos de dados no banco de 
   dados TEMPDB. 

*/

use tempdb
GO

select * from sys.sysfiles

use master
go

Alter database Tempdb modify file ( name = tempdev , filename = 'G:\Tempdb.mdf')
go
Alter database Tempdb modify file ( name = templog , filename = 'G:\Templog.ldf')
go
Alter database Tempdb add file ( name = tempdev1 , filename = 'G:\Tempdev1.ndf')
go
Alter database Tempdb add file ( name = tempdev2 , filename = 'G:\Tempdev2.ndf')
go
Alter database Tempdb add file ( name = tempdev3 , filename = 'G:\Tempdev3.ndf')
go

/*



-------------sf
Banco de dados..

   Defini��o cl�ssica: Um banco de dados � uma cole��o de tabelas estruturadas que 
   armazena um conjunto de dados.......

   O que interessa. Os dados armazenados ficam registrados em arquivos em disco.
   Cada banco de dados no SQL Server tem no m�nimo dois arquivos. Uma arquivo de dados
   conhecido como arquivo Prim�rio e tem a extens�o MDF e outro arquivo de log 
   com a extens�o LDF para registrar os log de trans��o (vamos tratar somente de
   arquivo de dados neste treinamento). 

   No MDF al�m de termos os dados da aplica��o, temos tamb�m informa��es sobre a 
   inicializa��o do banco de dados e a refer�ncia para outros arquivos de dados, como 
   tamb�m os metadados de todos os objetos de banco de dados criados pelos desenvolvedores.

   Existe um outro tipo de arquivo conhecido como Secund�rio onde cont�m somente os dados
   da aplica��o. Ele tem a extens�o NDF.

   Cada arquivo de dados:

      - Ser� agrupado junto com outros arquivos de dados em um grupo l�gico chamado
        de FILEGROUP (FG). Se n�o especificado, o arquivo fica no grupo de arquivo PRIMARY.

      - Deve ter um nome l�gico que ser� utilizado em instru��es T-SQL 

      - Deve ter um nome f�sico onde consta o local o arquivo no sistema operacional.

      - Dever ter um tamannho inicial para atender a carga de dados atual e uma previs�o
        futura.  

      - Deve ter uma taxa de crescimento definida. Ela ser� utiliza para aumentar o 
        tamanho do arquivo de dados quando o mesmo estiver cheio.

      - Deve ter um limite m�ximo de crescimento. Isso � importante para evitar 
        que arquivos crescem � ocupem todo o espa�o em disco. 

Exemplos de cria��o de banco de dados 

*/

CREATE DATABASE DBDemo_01
GO

USE DBDemo_01
GO

Select * from sys.sysfiles

Select size*8 as TamanhoKb , growth *8 as CrescimentoKB , *  from sys.sysfiles

use Master
go

drop database DBDemo_01
GO

/*

*/
DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA
ON PRIMARY                                   -- FG PRIMARY 
 ( NAME = 'Primario',                        -- Nome l�gico do arquivo
   FILENAME = 'D:\DBDemoA_Primario.mdf' ,    -- Nome f�sico do arquivo
   SIZE = 256MB                              -- Tamanho inicial do arquivo 
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 12MB 
  )
GO

use DBDemoA
go

Select size*8 as TamanhoKb , growth *8 as CrescimentoKB , *  from sys.sysfiles
go

/*
*/
Use Master
go

DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA
ON PRIMARY 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 256MB 
 ),                                             -- Segundo Arquivo de dados, no mesmo FG
 ( NAME = 'Secundario',                         
   FILENAME = 'E:\DBDemoA_Secundario.ndf' , 
   SIZE = 256MB 
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 12MB 
  )
GO

/*
   No exemplo acima, temos dois arquivos de dados no FG PRIMARY. Os dados gravados
   nesse grupo ser�o distribuidos de forma proporcional dentro dos arquivos 
*/

use DBDemoA
go

Select size*8 as TamanhoKb , growth *8 as CrescimentoKB , *  from sys.sysfiles

/*

FILEGROUP
---------

   FILEGROUP � um agrupamento l�gico de arquivos de dados para distribuir melhor a 
   aloca��o de dados entre os discos, agrupar dados de acordo com contextos ou 
   arquivamentos como tamb�m permitir ao DBA uma melhor forma de administra��o.

   No nosso caso, vamos focar em melhorar o desempenho das consultas.
      
*/

Use Master
go

DROP DATABASE if exists DBDemoA
GO

CREATE DATABASE DBDemoA
ON PRIMARY 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 64MB 
 ), 
FILEGROUP DADOS
 ( NAME = 'DadosTransacional1', 
   FILENAME = 'E:\DBDemoA_SecundarioT1.ndf' , 
   SIZE = 1024MB
 ) ,
 ( NAME = 'DadosTransacional2', 
   FILENAME = 'E:\DBDemoA_SecundarioT2.ndf' , 
   SIZE = 1024MB
 ) 
LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 512MB 
  )
GO

ALTER DATABASE [DBDemoA] MODIFY FILEGROUP [DADOS] DEFAULT
GO

USE DBDemoA
GO
Select size*8 as TamanhoKb , growth *8 as CrescimentoKB , *  from sys.sysfiles

use eCommerce
select 488*8

SELECT * FROM SYS.dm_db_file_space_usage


/*
Ref.: https://docs.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-views/sys-dm-db-file-space-usage-transact-sql

*/


CREATE DATABASE DBDemoA
ON PRIMARY 
 ( NAME = 'Primario', 
   FILENAME = 'D:\DBDemoA_Primario.mdf' , 
   SIZE = 64MB ,
   MAXSIZE =  
 ), 
FILEGROUP DADOS
 ( NAME = 'DadosTransacional1', 
   FILENAME = 'E:\DBDemoA_SecundarioT1.ndf' , 
   SIZE = 1024MB
 ) ,
 ( NAME = 'DadosTransacional2', 
   FILENAME = 'E:\DBDemoA_SecundarioT2.ndf' , 
   SIZE = 1024MB
 ) ,
FILEGROUP DADOSHISTORICO
 ( NAME = 'DadosHistorico1', 
   FILENAME = 'E:\DBDemoA_SecundarioH1.ndf' , 
   SIZE = 1024MB
 ) ,
 ( NAME = 'DadosHistorico2', 
   FILENAME = 'E:\DBDemoA_SecundarioH2.ndf' , 
   SIZE = 1024MB
 ) 

LOG ON 
 ( NAME = 'Log', 
   FILENAME = 'F:\DBDemoA_Log.ldf' , 
   SIZE = 512MB 
  )
GO


/*
Analisando o Banco
*/

use DBDemoA
go

select * from sys.sysfiles
select 131072 * 8192/1024 /1024


