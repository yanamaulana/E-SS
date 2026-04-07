ALTER VIEW dbo.ERPQview_User_Employee AS
SELECT tuser.User_ID, TUserPersonal.First_Name, User_Name, User_Password, User_Pass_Txt, User_Hints, User_Answer, Site_ID, Language_ID, User_Type, Forget_Password,
security_password, WH_ID, is_Passive, User_Status, flag_eula, eula_date, LoginFail_Ip, User_Ldap,
TUserPersonal.Middle_Name, TUserPersonal.Last_Name, TUserPersonal.Gender, TUserPersonal.Date_of_Birth, Email_Address, TUserPersonal.Address1, TUserPersonal.Address2, City, State, Country_ID, Postal_Code, 
Fax, TUserPersonal.Phone, HandPhone, Web_Site, TUserPersonal.GMT_ID, Signature, POP3_Address, Mail_Acc_User_ID, Mail_Acc_User_Password, Leave_Mail_on_Server, Upload_Extra_Size,
Upload_Extra_Type, Port_Number, Category_id, Server_Time_Out, User_Title, User_NickName, Anniversary, THRMEmpPersonalData.isSalesPerson
FROM dbsai_erp_uat.dbo.tuser
inner join TUserPersonal on tuser.User_ID = TUserPersonal.User_ID
left join THRMEmpPersonalData on THRMEmpPersonalData.Emp_ID = tuser.User_Name