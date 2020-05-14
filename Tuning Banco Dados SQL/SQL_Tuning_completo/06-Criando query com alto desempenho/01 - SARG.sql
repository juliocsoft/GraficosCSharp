use eCommerce
go

/*
- SARG � a redu��o de Search Argument ou Argumento de Pesquisa. 

- SARG � um conceito que, aplicado nas nossas querys, restringe uma 
  busca porque especifica uma correspod�ncia exata, um intervalo 
  de valores ou um conjunto de duas ou mais express�es unidas 
  pelo operador 'AND'.

- Uma express�o SARG � avalida pelo Otimizador de consulta que consegue 
  interpretar o seu conte�do e com base nesse conte�do, tenta escolher o 
  melhor �ndice para fazer essa pesquisa.

- Considerando que uma express�o SARG pode ser utiliza na cl�usula WHERE ou HAVING para filtro de linhas 
  ou em cl�usula ON de um JOIN, ela � composta por :
   
   - <Coluna> <Operador> <Valor> 

     Onde: 
      <Coluna>   - Nome da coluna que ser� pesquisada. 
                   N�o deve existir mais nada al�m do nome da coluna. Enfim, ele deve ficar sozinha.
      <Operador> - Operador de compara��o considerados inclusivos : S�o eles 
                   = 
                   >
                   <
                   >=
                   <=
                   Between
                   Like ( � somente um caso).
      <Valor>    - Express�o constante, do mesmo tipo da coluna. Pode ser uma v�riavel.             


- Fora da regra acima, a pesquisa � considerada NoSARG.
  
*/

Create Index idxCadastro on tCliente(dCadastro) on IndicesTransacionais 
Create Index idxNome on tCliente(cNome) on IndicesTransacionais 
Create Index idxCodigoExterno  on tProduto (cCodigoExterno) on IndicesTransacionais 
Create Index idxStatus on tMovimento (dCancelamento ) include(cTipo)  with (drop_existing=on) on IndicesTransacionais 
Create Index idxStatus1 on tMovimento (cStatus) include (cTipo) on IndicesTransacionais



/*
Exemplos de pesquisas SARG 
*/

set statistics io on 

Select iidCategoria , cCodigo , cTitulo 
  From tProduto 
 Where iidproduto = 1
go

Select * From tProduto
where cCodigoExterno like '86%'


Select iidCliente, cNome, cCPF, dCadastro 
  From tCliente 
 Where dCadastro > '2018-01-01'
go

Select iidMovimento,iidCliente, cCodigo, nNUmero, dMovimento  
  From tMovimento 
 where dMovimento >= '2018-05-15' 
   and dMovimento <= '2018-05-16'

go

Select iIDCliente, cNome, cCPF  from tCliente 
Where cNome = 'Mason M. Moore'

go


Select iIDCliente, cNome, cCPF  from tCliente 
Where cNome like 'Wallace%'


Select * 
  from tMovimento Mov
  join tItemMovimento Item
  on Mov.iIDMovimento = Item.iIDMovimento 
where dMovimento >= '2018-05-18' and cTipo = 'PD'


/*
Exemplo de pesquisas NoSARG 
*/

sp_helpindex tProduto

Set statistics io on 

Select iidCategoria , cCodigo , cTitulo 
  From tProduto 
 Where iidproduto = 1
go

Select iidCategoria , cCodigo , cTitulo 
  From tProduto 
 Where iidproduto * 1 = 1
go


Select iidCliente, cNome, cCPF, dCadastro 
  From tCliente 
 Where cast(dCadastro as datetime) > '2018-01-01'
go


Select * From tProduto
where substring(cCodigoExterno, 1,2) = '86'


Select iidMovimento,iidCliente, cCodigo, nNUmero, dMovimento  
  From tMovimento 
 Where YEAR(dMovimento) = 2018 
   and MONTH(dMovimento) = 5 
   and DAY(dMovimento)= 15


Select iidMovimento,iidCliente, cCodigo, nNUmero, dMovimento  
  From tMovimento 
 Where CAST(dMovimento as date) = '2018-05-15'

Select iIDCliente, cNome, cCPF  from tCliente 
Where upper(cNome) = 'MASON M. MOORE'


Select * 
  from tMovimento Mov
  join tItemMovimento Item
  on cast(Mov.iIDMovimento as bigint) = cast(Item.iIDMovimento as bigint) 
where dMovimento >= '2018-05-18' and cTipo = 'PD'


Set statistics io off






