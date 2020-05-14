/*

Validar dados antes de atualizar o dados.

- Essa aula n�o vai explicar em como proceder antes de atualizar os dados.

- Na verdade, vamos explicar que voce n�o precisa validar antes de o dados
  existe ou n�o existe antes de atualizar os dados.  

- Vamos imaginar o seguinte procedimento: Voc� deve criar uma procedure para 
  atualizar o cr�dito do cliente. A procedure deve receber o id do cliente e o valor 
  do cr�dito. Voce deve validar se o cliente existe. Se sim, realizar altera��o do 
  clientes, substitu�ndo o credito atual pelo novo. Se n�o, emitir uma mensagem de aviso
  para a aplica��o.
  
*/

use eCommerce
go

Create or Alter Procedure stp_AlteraClienteCredito
@iidCliente int,
@mCredito money
as
Begin
 
    set nocount on 
  
    declare @lClienteExiste int = 0 -- Assume o valor zero 

    Select @lClienteExiste = iidcliente 
      From tCliente 
     Where iIDCliente = @iidCliente 
    
    if @lClienteExiste <> 0

       update tCliente 
          set mCredito = @mCredito 
        where iIDCliente = @iidCliente

    else 

       raiserror('Cliente %d n�o existe', 16,1,@iidcliente)
    
    Return @lClienteExiste

End 
go

Select iidcliente, mCredito from tCliente where iIDCliente =39


set statistics io on 

declare @nRetorno int 
execute @nRetorno = stp_AlteraClienteCredito 39, $2000.000 
if @nRetorno <> 0
   select 'Cliente alterado.'
else 
   select 'Cliente n�o foi alterado.'

go

/*
Vamos analisar a procedure 
*/

set statistics io on 

declare @nRetorno int 
execute @nRetorno = stp_AlteraClienteCredito 39, $2000.000 
if @nRetorno <> 0
   select 'Cliente alterado.'
else 
   select 'Cliente n�o foi alterado.'

set statistics io off 

go
/*
Pelo Plano de Execu��o e a Estatisticas de I/O, precebemos que temos dois acesso ao
mesmo dados na tabela tCliente. Cada acesso lendo 3 p�ginas.

Podemos minimizar esses acesso com o seguinte c�digo. 

*/

Create or Alter Procedure stp_AlteraClienteCredito
@iidCliente int,
@mCredito money
as
Begin
 
    Set nocount on 

    Declare @lClienteExiste int = 0 -- Assume o valor zero 

    Update tCliente 
       Set mCredito = @mCredito 
     Where iIDCliente = @iidCliente
    
    Select @lClienteExiste = @@ROWCOUNT

    If @lClienteExiste = 0
    
       Raiserror('Cliente %d n�o existe', 16,1,@iidcliente)
     
    Return @lClienteExiste

End 
go

/*
Vamos analisar a procedure 
*/

set statistics io on 

declare @nRetorno int 
execute @nRetorno = stp_AlteraClienteCredito 454545, 80000 
if @nRetorno <> 0
   select 'Cliente alterado.'
else 
   select 'Cliente n�o foi alterado.'

set statistics io off 

set statistics io on 
go

declare @nRetorno int 
execute @nRetorno = stp_AlteraClienteCredito 39, $2000.000 
if @nRetorno <> 0
   select 'Cliente alterado.'
else 
   select 'Cliente n�o foi alterado.'

set statistics io off 
/*
*/

/*
- Vamos avaliar um outro cen�rio. Voc� deve criar uma procedure que 
  atualiza o  saldo do estoque com base na quantidade que foi movimentada,
  para um determinadom produto. 
  Ap�s esse atualiza��o, a procedure deve retornada para quem a executou, o
  novo saldo em estoque. 

  Utilizaremos nesse exemplo o par�metro de OUTPUT da procedure.
*/


use eCommerce
go

Create or Alter Procedure stp_AtualizaProdutoEstoque 
@iidProduto int,
@nQuantidade int ,
@nSaldo int output 
as
begin 

    set nocount on 

    declare @lProdutoExiste int = 0 

    Update tProduto 
       Set nEstoque = nEstoque + @nQuantidade
     Where iIDProduto = @iidProduto
    
    Select @lProdutoExiste = @@ROWCOUNT

    if @lProdutoExiste = 0 
       Raiserror('Produto %d n�o existe', 16,1,@iidProduto) 
    else 
       Select @nSaldo = nEstoque 
         From tProduto 
        where iIDProduto = @iidProduto
     
     Return  @lProdutoExiste
     
end 
go

Select * from tProduto where iIDProduto = 1

set statistics io on 
-- Ativar o Plano de Execu��o 

Declare @nSaldo int 
Declare @nRetorno int 

execute @nRetorno = stp_AtualizaProdutoEstoque 1, 100, @nSaldo OUTPUT 

if @nRetorno <> 0
   select 'Produto alterado.' , @nSaldo as NovoSaldo 
else 
   select 'Produto n�o foi alterado.'

set statistics io off
go

/*
No mesmo exemplo do anterior, o plano de execu��o mostro dois acesso a tabela 
tCliente, lendo para cada acessso 3 p�ginas.
*/


Create or Alter Procedure stp_AtualizaProdutoEstoque 
@iidProduto int,
@nQuantidade int ,
@nSaldo int output 
as
begin 

    set nocount on 

    declare @lProdutoExiste int = 0 

    Update tProduto 
       Set @nSaldo = nEstoque = nEstoque + @nQuantidade
     Where iIDProduto = @iidProduto
    
    Select @lProdutoExiste = @@ROWCOUNT

    if @lProdutoExiste = 0 
       Raiserror('Produto %d n�o existe', 16,1,@iidProduto) 
     
     Return  @lProdutoExiste
     
end 
go


set statistics io on 

Declare @nSaldo int 
Declare @nRetorno int 

execute @nRetorno = stp_AtualizaProdutoEstoque 1, 100, @nSaldo OUTPUT 

if @nRetorno <> 0
   select 'Produto alterado.' , @nSaldo as NovoSaldo 
else 
   select 'Produto n�o foi alterado.'

set statistics io off

/*
*/
