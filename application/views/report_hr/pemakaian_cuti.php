<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card card-flush overflow-hidden h-xl-100">
            <div class="card-body pt-0">
                <div class="py-5">
                    <div class="pb-5 table-responsive">
                        <table id="TableDataHistory" class="table-sm align-middle display compact table-rounded table-striped table-bordered border dataTable no-footer dt-inline">
                            <thead style="background-color: #3B6D8C;">
                                <tr class="text-white fw-bolder text-uppercase">
                                    <th class="text-center text-white">ID</th>
                                    <th class="text-center text-white">NIK</th>
                                    <th class="text-center text-white">NAME</th>
                                    <th class="text-center text-white">Department</th>
                                    <th class="text-center text-white">HIRE_DATE</th>
                                    <th class="text-center text-white">ANL DATE</th>
                                    <th class="text-center text-white">ANL-1</th>
                                    <th class="text-center text-white">ANL-2</th>
                                    <th class="text-center text-white">ANL-3</th>
                                    <th class="text-center text-white">ANL-4</th>
                                    <th class="text-center text-white">ANL-5</th>
                                    <th class="text-center text-white">ANL-6</th>
                                    <th class="text-center text-white">ANL-7</th>
                                    <th class="text-center text-white">ANL-8</th>
                                    <th class="text-center text-white">ANL-9</th>
                                    <th class="text-center text-white">ANL-10</th>
                                    <th class="text-center text-white">ANL-11</th>
                                    <th class="text-center text-white">ANL-12</th>
                                    <th class="text-center text-white">COUNT ANL</th>
                                </tr>
                            </thead>
                            <?php
                            $HR = $this->load->database('HR', TRUE);
                            $EmpCutiMasterData = $HR->query("SELECT DISTINCT 
                                                tHRMEmpPersonalData.EMP_ID, 
                                                tHRMEmpPersonalData.COMPANY_ID, 
                                                tHRMEmpPersonalData.FIRST_NAME, 
                                                tHRMEmpCompany.Emp_No,
                                                tHRMCostCenter.COSTCENTER_NAME_EN as Cost_Center,
                                                tHRMEmpPersonalData.HIRE_DATE, 
                                                (
                                                    CASE 
                                                        WHEN DATEADD(YEAR, COALESCE(YEAR(GETDATE()) - YEAR(tHRMEmpPersonalData.HIRE_DATE), 0), tHRMEmpPersonalData.HIRE_DATE) > GETDATE() 
                                                            THEN DATEADD(YEAR, COALESCE((YEAR(GETDATE()) - 1) - YEAR(tHRMEmpPersonalData.HIRE_DATE), 0), tHRMEmpPersonalData.HIRE_DATE)
                                                        ELSE DATEADD(YEAR, COALESCE(YEAR(GETDATE()) - YEAR(tHRMEmpPersonalData.HIRE_DATE), 0), tHRMEmpPersonalData.HIRE_DATE)
                                                    END
                                                ) AS TanggalAwalReset
                                                FROM 	tHRMEmpPersonalData
                                                left join tHRMEmpCompany on tHRMEmpCompany.Emp_ID = tHRMEmpPersonalData.Emp_ID 
                                                left join tHRMPosition on tHRMEmpCompany.Position_ID = tHRMPosition.Position_ID 
                                                left join tHRMCostCenter on tHRMPosition.Cost_Center = tHRMCostCenter.CostCenter_Code
                                                    WHERE (THRMEmpCompany.End_Date > GETDATE() OR  THRMEmpCompany.End_Date IS  NULL)
                                                AND THRMEmpPersonalData.Employee_Status = 'ACTIVE'")->result();
                            ?>
                            <tbody class="text-gray-600 fw-bold">
                                <?php foreach ($EmpCutiMasterData as $li) : ?>
                                    <tr>
                                        <td><?= $li->EMP_ID ?></td>
                                        <td>'<?= $li->Emp_No ?></td>
                                        <td><?= $li->FIRST_NAME ?></td>
                                        <td><?= $li->Cost_Center ?></td>
                                        <td><?= substr($li->HIRE_DATE, 0, 10) ?></td>
                                        <td><?= substr($li->TanggalAwalReset, 0, 10) ?></td>
                                        <?php
                                        $QdetailCuti = $HR->Query("SELECT 	tHRMEmpPersonalData.Emp_ID, 
                                            tHRMEmpPersonalData.First_Name,
                                            tHRMEmpPersonalData.HIRE_DATE,
                                            tHRMAttendanceStatus.Text_ID, 
                                            tHRMAttendanceDetail.Shift_Start, 
                                            tHRMAttendanceDetail.Attend_Code, 
                                            tHRMEmpCompany.Emp_No,
                                            tHRMCostCenter.CostCenter_Name_id as Cost_Center
                                    FROM 	tHRMAttendance
                                            left join tHRMEmpPersonalData on tHRMEmpPersonalData.Emp_ID = tHRMAttendance.Emp_ID 
                                            left join tHRMAttendanceDetail on tHRMAttendanceDetail.Emp_ID = tHRMAttendance.Emp_ID 
                                            left join tHRMAttendanceStatus on tHRMAttendanceStatus.Attend_Code = tHRMAttendanceDetail.Attend_Code 
                                            left join tHRMEmpCompany on tHRMEmpCompany.Emp_ID = tHRMEmpPersonalData.Emp_ID 
                                            left join tHRMPosition on tHRMEmpCompany.Position_ID = tHRMPosition.Position_ID 
                                            left join tHRMCostCenter on tHRMPosition.Cost_Center = tHRMCostCenter.CostCenter_Code 
                                    WHERE 	tHRMAttendance.company_ID = 73
                                    AND		tHRMPosition.Cost_Center IS NOT NULL
                                    AND 	tHRMAttendance.Shift_Start >=  '$li->TanggalAwalReset'
                                    AND 	tHRMAttendance.Shift_Start < GETDATE() 
                                    AND 	tHRMAttendance.Shift_Start =tHRMAttendanceDetail.Shift_Start 
                                    AND 	tHRMAttendanceDetail.Shift_Start >= '$li->TanggalAwalReset'
                                    AND 	tHRMAttendanceDetail.Shift_Start < GETDATE() 
                                    AND tHRMEmpPersonalData.User_ID  IN (SELECT Distinct(TAppGroupData.User_ID) FROM TAppGroupData WHERE AppGroup_ID  IN (716))
                                        AND 	tHRMEmpCompany.Company_ID =73
                                        AND 	tHRMCostCenter.Company_ID =73
                                        AND 	tHRMAttendanceDetail.Company_ID = 73 
                                        AND (tHRMEmpPersonalData.emp_id in  ('$li->EMP_ID'))
                                            AND (THRMEmpCompany.End_Date > GETDATE() OR  THRMEmpCompany.End_Date IS  NULL)
                                            AND THRMEmpPersonalData.Employee_Status = 'ACTIVE'
                                            AND tHRMAttendanceDetail.Attend_Code IN ('ANL')
                                    order by tHRMEmpPersonalData.Emp_ID, tHRMEmpPersonalData.First_Name,  tHRMAttendanceDetail.Shift_Start,tHRMAttendanceStatus.Text_ID");
                                        $CountDateANL = $QdetailCuti->num_rows()
                                        ?>
                                        <?php if ($QdetailCuti->num_rows() == 0) : ?>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">-</td>
                                            <td class="text-center">0</td>
                                        <?php else : ?>
                                            <?php $DataDetailANL = $QdetailCuti->result_array(); ?>
                                            <td class="text-center"><?php if (empty($DataDetailANL[0]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[0]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[1]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[1]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[2]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[2]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[3]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[3]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[4]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[4]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[5]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[5]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[6]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[6]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[7]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[7]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[8]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[8]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[9]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[9]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[10]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[10]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?php if (empty($DataDetailANL[11]['Shift_Start'])) echo '--';
                                                                    else echo  substr($DataDetailANL[11]['Shift_Start'], 0, 10);   ?></td>
                                            <td class="text-center"><?= $CountDateANL ?></td>
                                        <?php endif; ?>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="card-footer">
                <a href="<?= base_url() ?>" class="btn btn-danger float-end"><i class="far fa-arrow-alt-circle-left"></i> Back</a>
            </div>
        </div>
    </div>
</div>
<div id="location"></div>