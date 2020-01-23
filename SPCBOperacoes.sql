USE ProjetoContaBancaria

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[OpDeposito]') AND objectproperty(id, N'IsPROCEDURE')=1)
	DROP PROCEDURE [dbo].[OpDeposito]
GO 

CREATE PROCEDURE [dbo].[OpDeposito]
					 @Vlr_Valor		decimal(9,2),
					 @Num_Conta		int
	AS

	/*
	Documenta��o
	Arquivo Fonte.....: SPCBOperacoes.sql
	Objetivo..........: Dep�sito em conta
	Autor.............: Alexandre Higino
 	Data..............: 23/01/2020
	Coment�rios.......: 0 - Dep�sito realizado com sucesso
	*/

	BEGIN
		
		UPDATE [dbo].[Contas]
			SET Vlr_Saldo = Vlr_Saldo + @Vlr_Valor
			WHERE Num_Conta = @Num_Conta
		
		INSERT INTO [dbo].[Operacoes]
				(Nom_Tipo, Dat_Realizacao, Vlr_Operacao, Num_Conta)
			VALUES ('Deposito', GETDATE(), @Vlr_Valor, @Num_Conta)

		RETURN 0

	END
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[OpSaque]') AND objectproperty(id, N'IsPROCEDURE')=1)
	DROP PROCEDURE [dbo].[OpSaque]
GO 

CREATE PROCEDURE [dbo].[OpSaque]
					 @Vlr_Valor		decimal(9,2),
					 @Num_Conta		int
	AS

	/*
	Documenta��o
	Arquivo Fonte.....: SPCBOperacoes.sql
	Objetivo..........: Saque em conta
	Autor.............: Alexandre Higino
 	Data..............: 23/01/2020
	Coment�rios.......: 0 - Saque realizado com sucesso
	*/

	BEGIN
		
		UPDATE [dbo].[Contas]
			SET Vlr_Saldo = Vlr_Saldo - @Vlr_Valor
			WHERE Num_Conta = @Num_Conta
		
		INSERT INTO [dbo].[Operacoes]
				(Nom_Tipo, Dat_Realizacao, Vlr_Operacao, Num_Conta)
			VALUES ('Saque', GETDATE(), @Vlr_Valor, @Num_Conta)

		RETURN 0

	END
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[OpTransferencia]') AND objectproperty(id, N'IsPROCEDURE')=1)
	DROP PROCEDURE [dbo].[OpTransferencia]
GO 

CREATE PROCEDURE [dbo].[OpTransferencia]
					 @Num_Conta_Env		int,
					 @Num_Conta_Rec		int,
					 @Vlr_Valor			decimal(9,2)
	AS

	/*
	Documenta��o
	Arquivo Fonte.....: SPCBOperacoes.sql
	Objetivo..........: Transfer�ncia entre contas
	Autor.............: Alexandre Higino
 	Data..............: 23/01/2020
	Coment�rios.......: 0 - Transfer�ncia realizada com sucesso
						1 - Conta � transferir n�o encontrado
	*/

	BEGIN
		
		IF EXISTS(SELECT *
			FROM [dbo].[Contas] WITH(NOLOCK)
			WHERE Num_Conta = @Num_Conta_Rec)
		BEGIN

			UPDATE [dbo].[Contas]
				SET Vlr_Saldo = Vlr_Saldo - @Vlr_Valor
				WHERE Num_Conta = @Num_Conta_Env

			UPDATE [dbo].[Contas]
				SET Vlr_Saldo = Vlr_Saldo + @Vlr_Valor
				WHERE Num_Conta = @Num_Conta_Rec
	
			INSERT INTO [dbo].[Operacoes]
				(Nom_Tipo, Dat_Realizacao, Vlr_Operacao, Num_Conta)
			VALUES ('Transferencia', GETDATE(), @Vlr_Valor, @Num_Conta_Rec)

			INSERT INTO [dbo].[Operacoes]
				(Nom_Tipo, Dat_Realizacao, Vlr_Operacao, Num_Conta)
			VALUES ('Transferencia', GETDATE(), -@Vlr_Valor, @Num_Conta_Env)

			RETURN 0

		END

		RETURN 1

	END
GO