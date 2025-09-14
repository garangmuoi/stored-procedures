USE [DHTN-2025]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Tran Duc Binh
-- Create date:	12/09/2025
-- Description:	Get logging document transfer to recipients.
-- =============================================
CREATE PROCEDURE [edoc].[Prc_UserIncomingDocGetByIncomingDocIdFullName]
    -- Add the parameters for the stored procedure here
    @IncomingDocId BIGINT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    BEGIN TRY
        --
        -- All other declarations and initialisation
        --

        SELECT 
            uid.IncomingDocId,
            uid.UserSend,
            UserSendName = CONCAT(s_send.FirstName, ' ', s_send.LastName),
            uid.UserReceive,
            UserReceiveName = CONCAT(s_receive.FirstName, ' ', s_receive.LastName),
            UserReceiveDepartmentId = s_receive.DepartmentId,
            UserReceiveDepartmentName = d.Name,
            uid.SendDate,
            uid.ReadDate,
            uid.ExpiredDate,
            uid.CompleteDate,
            uid.Status,
            uid.SendType,
            uid.UserSendRoleId,
            UserSendRoleName = r.Name
        FROM edoc.UserIncomingDoc (NOLOCK) uid
        LEFT JOIN dbo.Staff (NOLOCK) s_send ON uid.UserSend = s_send.Id
        LEFT JOIN dbo.Staff (NOLOCK) s_receive ON uid.UserReceive = s_receive.Id
        LEFT JOIN dbo.Department (NOLOCK) d ON s_receive.DepartmentId = d.Id
        LEFT JOIN dbo.Role (NOLOCK) r ON uid.UserSendRoleId = r.Id
        WHERE uid.IncomingDocId = @IncomingDocId
        ORDER BY uid.SendDate DESC;

    /*******************************************************************************
		* End of SQL statement(s).
		*******************************************************************************/
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(MAX),
                @ErrorNumber INT,
                @ErrorSeverity INT,
                @ErrorState INT,
                @ErrorLine INT,
                @ErrorProcedure NVARCHAR(200);

        -- Assign variables to error-handling functions that capture information for RAISERROR.
        SELECT @ErrorNumber = ERROR_NUMBER(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE(),
               @ErrorLine = ERROR_LINE(),
               @ErrorProcedure = ISNULL(ERROR_PROCEDURE(), '-');

        -- Build the message string that will contain original error information.
        SELECT @ErrorMessage = N'Error %d, Level %d, State %d, Procedure %s, Line %d, Message: ' + ERROR_MESSAGE();

        -- Only set the error state if its been set to zero
        IF (@ErrorState = 0)
            SET @ErrorState = 1;

        -- Raise an error: msg_str parameter of RAISERROR will contain the original error information.
        RAISERROR(   @ErrorMessage,
                     @ErrorSeverity,
                     @ErrorState,
                     @ErrorNumber,    -- parameter: original error number.
                     @ErrorSeverity,  -- parameter: original error severity.
                     @ErrorState,     -- parameter: original error state.
                     @ErrorProcedure, -- parameter: original error procedure name.
                     @ErrorLine       -- parameter: original error line number.
                 );
    END CATCH;

    SET NOCOUNT OFF;
END;