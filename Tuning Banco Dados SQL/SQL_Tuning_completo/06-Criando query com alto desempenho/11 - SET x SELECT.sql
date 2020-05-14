/*
Atribui��o de valor na vari�vel: Utilizar SET ou SELECT 

- Como o nosso treinamento � voltando para query com alta performance,
  temos que tomar o cuidado de tamb�m incluir outros comandos que fazem
  parte da linguagem T-SQL. No caso desse aula, vamos comparar a utiliza��o
  das instru��es SET e SELECT para atribuir valor a uma vari�vel. 

- SET @variavel � utilizada para atribuir um valor para uma vari�vel.

   - Somente uma vari�vel;
   - Padr�o ANSI.
   - Recomenda��o de uso pela Microsoft.

- SELECT @variavel tamb�m � utilizada para atribuir um valor para uma vari�vel.

   - Utiliza v�rias vari�veis separadas por v�rgula;
  
*/

use eCommerce
go

declare @cValor1 char(10)
declare @cValor2 char(10)

--set @cValor1 = 'Teste1', @cvalor2 = 'Teste2' -- N�o funciona...

set @cValor1 = 'TesteA'
set @cvalor2 = 'TesteB'

select @cValor1  = 'TesteC', @cValor2 = 'TesteD'
go

/*
- Quem tem o melhor desempenho ?

- Diferen�as de tempos entre utilizar SET ou SELECT para definir um valor para:
  - 10 vari�veis do tipo CHAR(20), 
  - 10 vari�veis do tipo INT 
  - 10 vari�veis do tipo DATETIME2(7)
   
*/

set nocount on
go
Drop Table if exists #tTempo 
go
Create Table #tTempo (cTeste char(30), nTempoSet int , nTempoSelect int )
GO

/*
Exemplos com vari�veis do tipo CHAR(20)
*/

Declare @nPonteiro int = 0 
Declare @dInicio datetime
Declare @nTempoSet int 
Declare @nTempoSelect int 

Declare @VarExemplo01 char(20),@VarExemplo02 char(20),@VarExemplo03 char(20),@VarExemplo04 char(20),@VarExemplo05 char(20),
        @VarExemplo06 char(20),@VarExemplo07 char(20),@VarExemplo08 char(20),@VarExemplo09 char(20),@VarExemplo10 char(20)

Select @dInicio = GETDATE()

while @nPonteiro <= 1000000 begin -- Executa 1 milh�o de vezes 
      
      Set @VarExemplo01 = '12345678901234567890'
      Set @VarExemplo02 = '12345678901234567890'
      Set @VarExemplo03 = '12345678901234567890'
      Set @VarExemplo04 = '12345678901234567890'
      Set @VarExemplo05 = '12345678901234567890'
      Set @VarExemplo06 = '12345678901234567890'
      Set @VarExemplo07 = '12345678901234567890'
      Set @VarExemplo08 = '12345678901234567890'
      Set @VarExemplo09 = '12345678901234567890'
      Set @VarExemplo10 = '12345678901234567890'

      set @nPonteiro += 1

end 

Select @nTempoSet = DATEDIFF(ms,@dinicio,getdate())

Select @nPonteiro = 0 
Select @dInicio = GETDATE()

while @nPonteiro <= 1000000 begin 
      
      Select @VarExemplo01 = '12345678901234567890',
             @VarExemplo02 = '12345678901234567890',
             @VarExemplo03 = '12345678901234567890',
             @VarExemplo04 = '12345678901234567890',
             @VarExemplo05 = '12345678901234567890',
             @VarExemplo06 = '12345678901234567890',
             @VarExemplo07 = '12345678901234567890',
             @VarExemplo08 = '12345678901234567890',
             @VarExemplo09 = '12345678901234567890',
             @VarExemplo10 = '12345678901234567890'

      set @nPonteiro += 1

end 

Select @nTempoSelect = DATEDIFF(ms,@dinicio,getdate())

insert into #tTempo values ('Variavel CHAR(20)', @nTempoSet, @nTempoSelect)

go

/*
Exemplo com variaveis do tipo INT 
*/

Declare @nPonteiro int = 0 ,
        @dInicio datetime  ,
        @nTempoSet int     ,
        @nTempoSelect int  

Declare @VarExemplo01 int ,@VarExemplo02 int , @VarExemplo03 int , @VarExemplo04 int , @VarExemplo05 int ,
        @VarExemplo06 int ,@VarExemplo07 int , @VarExemplo08 int , @VarExemplo09 int , @VarExemplo10 int 

Select @dInicio = GETDATE()

while @nPonteiro <= 1000000 begin 
      
      Set @VarExemplo01 = 2147483647
      Set @VarExemplo02 = 2147483647
      Set @VarExemplo03 = 2147483647
      Set @VarExemplo04 = 2147483647
      Set @VarExemplo05 = 2147483647
      Set @VarExemplo06 = 2147483647
      Set @VarExemplo07 = 2147483647
      Set @VarExemplo08 = 2147483647
      Set @VarExemplo09 = 2147483647
      Set @VarExemplo10 = 2147483647

      set @nPonteiro += 1

end 

Select @ntemposet = DATEDIFF(ms,@dinicio,getdate())

set @nPonteiro = 0 
set @dInicio = GETDATE()

while @nPonteiro <= 1000000 begin 
      
      Select @VarExemplo01 = 2147483647,
             @VarExemplo02 = 2147483647,
             @VarExemplo03 = 2147483647,
             @VarExemplo04 = 2147483647,
             @VarExemplo05 = 2147483647,
             @VarExemplo06 = 2147483647,
             @VarExemplo07 = 2147483647,
             @VarExemplo08 = 2147483647,
             @VarExemplo09 = 2147483647,
             @VarExemplo10 = 2147483647

      set @nPonteiro += 1

end 

Select @nTempoSelect = DATEDIFF(ms,@dinicio,getdate())
insert into #tTempo values ('Variavel INT', @nTempoSet, @nTempoSelect)
go

/*
Exemplo com variaveis do tipo DATETIME2
*/


Declare @nPonteiro int = 0 ,
        @dInicio datetime  ,
        @nTempoSet int     ,
        @nTempoSelect int  

Declare @VarExemplo01 datetime2(7) ,@VarExemplo02 datetime2(7) , @VarExemplo03 datetime2(7) , @VarExemplo04 datetime2(7) , @VarExemplo05 datetime2(7) ,
        @VarExemplo06 datetime2(7) ,@VarExemplo07 datetime2(7) , @VarExemplo08 datetime2(7) , @VarExemplo09 datetime2(7) , @VarExemplo10 datetime2(7) 

Select @dInicio = GETDATE()

while @nPonteiro <= 1000000 begin 
      
      Set @VarExemplo01 = '2018-06-07 11:10:09.123456789'
      Set @VarExemplo02 = '2018-06-07 11:10:09.123456789'
      Set @VarExemplo03 = '2018-06-07 11:10:09.123456789'
      Set @VarExemplo04 = '2018-06-07 11:10:09.123456789'
      Set @VarExemplo05 = '2018-06-07 11:10:09.123456789'
      Set @VarExemplo06 = '2018-06-07 11:10:09.123456789'
      Set @VarExemplo07 = '2018-06-07 11:10:09.123456789'
      Set @VarExemplo08 = '2018-06-07 11:10:09.123456789'
      Set @VarExemplo09 = '2018-06-07 11:10:09.123456789'
      Set @VarExemplo10 = '2018-06-07 11:10:09.123456789'

      set @nPonteiro += 1

end 

Select @ntemposet = DATEDIFF(ms,@dinicio,getdate())

set @nPonteiro = 0 
set @dInicio = GETDATE()

while @nPonteiro <= 1000000 begin 
      
      Select @VarExemplo01 = '2018-06-07 11:10:09.123456789',
             @VarExemplo02 = '2018-06-07 11:10:09.123456789',
             @VarExemplo03 = '2018-06-07 11:10:09.123456789',
             @VarExemplo04 = '2018-06-07 11:10:09.123456789',
             @VarExemplo05 = '2018-06-07 11:10:09.123456789',
             @VarExemplo06 = '2018-06-07 11:10:09.123456789',
             @VarExemplo07 = '2018-06-07 11:10:09.123456789',
             @VarExemplo08 = '2018-06-07 11:10:09.123456789',
             @VarExemplo09 = '2018-06-07 11:10:09.123456789',
             @VarExemplo10 = '2018-06-07 11:10:09.123456789'

      set @nPonteiro += 1

end 

Select @nTempoSelect = DATEDIFF(ms,@dinicio,getdate())
insert into #tTempo values ('Variavel Datetime2(7)', @nTempoSet, @nTempoSelect)

go 

Select * from #tTempo

/*
Fim do teste
*/

/*
- Nem tudo � rosas para utilizar o SELECT na atribui��o. Mesmo nos testes acima demonstrando
  que a instru��o SELECT tem a melhor performance, voc� deve tomar alguna cuidados
  na programa��o. 

- Vamos ver dois cen�rios em que voc� deve prestar aten��o ao usar SET ou SELECT. 

*/


/*
Capturar dados de uma subquery 
*/

use eCommerce
go

-- Quando a subquery retorna uma linha 
Declare @cNomeCliente1 varchar(100) 
Set @cNomeCliente1 = (Select cNome From tCliente where iIDCliente  = 1)

Declare @cNomeCliente2 varchar(100) 
Select @cNomeCliente2 = cNome From tCliente where iIDCliente  = 1

select @cNomeCliente1, @cNomeCliente2 
go

-- Quando a subquery retorna v�rias linhas (Testar com saida texto) 
Declare @cNomeCliente1 varchar(100) 
Set @cNomeCliente1 = (Select cNome From tCliente where cUF = 'SP')

Declare @cNomeCliente2 varchar(100) 
Select @cNomeCliente2 = cNome From tCliente where cUF = 'SP' order by dNascimento

select  @cNomeCliente2 
go 

Select cNome From tCliente where cUF = 'SP' order by dNascimento

-- No SET voc� recebe um erro e no SELECT voc� n�o ter certeza de qual valor receber�.
-- Nesse caso, minha sugest�o � controlar o valor de retorno da sele��o dos dados
-- quando utilizar o SELECT como atribui��o.


/*
Conte�do do valor da vari�vel 
*/

Declare @cNomeCliente1 varchar(100) 
Select @cNomeCliente1  = 'Jose da Silva' 
Set @cNomeCliente1 = (Select cNome From tCliente where iIDCliente  = 0  )
Select @cNomeCliente1  


Declare @cNomeCliente2 varchar(100) 
Select @cNomeCliente2  = 'Jose da Silva' 
Select @cNomeCliente2 = cNome From tCliente where iIDCliente  = 0
Select @cNomeCliente2

-- No caso do SET, o conte�do da vari�vel foi perdido.
-- No caso do SELECT, o valor da vari�vel foi preservado. 


select @cNomeCliente1, @cNomeCliente2 
go


