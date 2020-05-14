/*
- UDF ou fun��es definidas pelo usu�rios, s�o objetos de programa��o em T-SQL
  semelhantes as store procedures. Elas podem ser esclares, quando retorno um 
  valor escalar (valor com tipo e tamanho) ou podem ser com valor de tabela
  (Inline Table-Valued ou Multi-Statement Table-Valued), quando retornam um tabela.

  Ref.: https://docs.microsoft.com/pt-br/sql/t-sql/statements/create-function-transact-sql?view=sql-server-2017
  
- O uso das UDF devem ser avalidas e testadas com cuidados quando utilizada juntamente com uma
  query.

- Vamos aplicar alguns exemplos usando fun��es escalares e de valor de tabela.


*/

/*
Realizar a formata��o de Endere�o do Clientes
*/
use eCommerce
go

Create or Alter Function dbo.fnMontaEndereco
(
@cLogradouro varchar(180),
@cCidade varchar(30),
@cUF char(2),
@cCEP char(8)
)
Returns varchar(250)
as
begin
   
   Declare @cEndereco varchar(250) 

   set @cEndereco = @cLogradouro+', '+@cCidade +' - ' + @cUF+'. CEP : '+@cCEP
   
   Return @cEndereco 

end 
go


Select dbo.fnMontaEndereco('Pra�a da S�     ', 'S�o Paulo' , 'SP','01000-000')


/*
Carregar o profile e escolhar o evento SP:Completed e SQL:StmtCompleted
*/


set statistics io on 

Select cNome , dbo.fnMontaEndereco(cLogradouro,cCidade,cUF,cCEP) as cEnderecoCompleto from tCliente
go

Select cNome , cLogradouro+', '+cCidade +' - ' + cUF+'. CEP : '+cCEP as cEnderecoCompleto from tCliente
go 

set statistics io off
go

/*
- Evite formata��o de dados como inclus�o de m�scara em CPF ou CEP. Deixe isso para a aplica��o.
- Evite a carga de dados por meio de fun��es na fase SELECT. Para cada linha apresentada no SELECT,
  ser� executada a fun��o.

  Em certos casos, podemos converter uma fun��o escalar para Inline Table-Valued e conseguimos
  alguns ganhos de desempenho. 

*/

/*
*/

/*
Fun��o Scalar 
- Retorna uma string com os tres �ltimos pedidos de um cliente, separados por v�rgula. 

*/

Create or Alter Function dbo.fnNumeroUltimosPedidos
(
   @iIDCliente int 
)
Returns varchar(250) 
as
begin
     
     declare @cUltimoPedidos varchar(250) = ''

     Select top 3 @cUltimoPedidos = @cUltimoPedidos + cast(nNumero as varchar(250))+','
       From tMovimento
      Where iIDCliente = @iIDCliente 
        and cTipo = 'PD'
      Order by dMovimento desc 

      Return trim(',' from @cUltimoPedidos)
end 
go

/*
Carregando os dados de um cliente 
*/
set statistics io on 
go
Select cNome , dbo.fnNumeroUltimosPedidos(iidcliente) as cUltimosPedidos 
from tCliente 
where iIDCliente = 115770
go
set statistics io off


/*

*/

set statistics io on 
go
Select cNome , dbo.fnNumeroUltimosPedidos(iidcliente) as cUltimosPedidos 
from tCliente 
where dCadastro >= '2018-01-01'
go
set statistics io off



set statistics io on 
go
Select cNome , cUltimosPedidos 
from tCliente 
cross apply (Select dbo.fnNumeroUltimosPedidos(iidcliente)) as UltimosPedido (cUltimosPedidos )
where dCadastro >= '2018-01-01'
go
set statistics io off
go


/*
Transformando a fun��o escalar em Inline Table-Valued e respeitando
a regra de neg�cio.

*/

drop function dbo.fnNumeroUltimosPedidos
go

Create or Alter Function dbo.fnNumeroUltimosPedidos
(
@iIDCliente int 
)
Returns table 
as
return (     
     Select cUltimosPedidos 
       From (Select top 3 cast(nNumero as varchar(10))+',' as [text()] 
               From tMovimento
              Where iIDCliente = @iIDCliente 
                and cTipo = 'PD'
              order by dMovimento desc 
                for xml path('') 
            ) as UltimosPedido (cUltimosPedidos)
)

go

Select * from dbo.fnNumeroUltimosPedidos(115770)

/*
Carregar o profile e escolhar o evento SP:Completed e SQL:StmtCompleted
*/

set statistics io on 
go
Select cNome , (select * from dbo.fnNumeroUltimosPedidos(iidcliente)) as cUltimosPedidos 
from tCliente 
where dCadastro >= '2018-01-01'
go
set statistics io off



set statistics io on 
go
Select cNome , UltimosPedidos.cUltimosPedidos
from tCliente 
cross apply dbo.fnNumeroUltimosPedidos(iidcliente) as UltimosPedidos
where dCadastro >= '2018-01-01'
go



/*
*/






Select tCliente.cNome , STRING_AGG(cast(tMovimento.nNumero as varchar(10)),',') within group (order by tMovimento.dMovimento desc ) as cUltimosPedidos
from tCliente 
left join tMovimento 
  on tCliente.iIDCliente = tMovimento.iIDCliente and tMovimento.cTipo = 'PD'
where tCliente.dCadastro >= '2018-01-01'
group by tCliente.cNome 

--*** Obs: Nesse caso, ser� considerado todos os Numeros de Movimento.

set statistics io off

Create Index idxNomeCadastro on tCliente (dCadastro) include (cNome) ON INDICESTRANSACIONAIS

Drop  Index idxNomeCadastro on tCliente 