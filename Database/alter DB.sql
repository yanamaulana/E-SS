ALTER TABLE dbsai_erp_uat.dbo.Ttrx_Cbr_Approval ADD Payment_Status int DEFAULT 0 NOT NULL;
ALTER TABLE dbsai_erp_uat.dbo.Ttrx_Cbr_Approval ADD Payment_Status_Time_Change datetime NULL;
ALTER TABLE dbsai_erp_uat.dbo.Ttrx_Cbr_Approval ADD Payment_Status_Change_By varchar(100) NULL;


CREATE TABLE tmst_user_check_payment_permission (
    SysId BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL,
    inserted_at DATETIME DEFAULT GETDATE(),
    inserted_by NVARCHAR(100)
);

CREATE TABLE thist_user_check_payment_permission (
    HistoryId BIGINT IDENTITY(1,1) PRIMARY KEY,
    SysId BIGINT, -- ID asli dari tabel utama
    UserName NVARCHAR(100),
    inserted_at DATETIME,
    inserted_by NVARCHAR(100),
    deleted_at DATETIME DEFAULT GETDATE(),
    deleted_by NVARCHAR(100)
);