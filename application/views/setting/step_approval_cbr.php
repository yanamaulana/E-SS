<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card shadow-sm">
            <div class="card-header">
                <h3 class="card-title"><?= $page_title; ?> : <?= $this->session->userdata('sys_sba_nama') ?></h3>
                <div class="card-toolbar">
                    <a href="<?= base_url() ?>" class="btn btn-sm btn-light-danger">
                        <i class="fas fa-arrow-alt-circle-left"></i> Back
                    </a>
                </div>
            </div>
            <div class="card-body">
                <form id="main-form" class="form-horizontal" enctype="multipart/form-data" action="javascript:void(0)">
                    <?php if ($approvals->num_rows() < 1) : ?>
                        <div class="row">
                            <div class="col-lg-5 col-md-12">
                                <div class="fv-row mb-5">
                                    <label class="form-label">APPROVAL STAFF :</label>
                                    <select id="Staff" name="Staff" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option selected disabled>-Choose-</option>
                                        <option value="0">NO</option>
                                        <option value="1">YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">APPROVAL CHIEF :</label>
                                    <select id="Chief" name="Chief" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option selected disabled>-Choose-</option>
                                        <option value="0">NO</option>
                                        <option value="1">YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">APPROVAL ASST. MANAGER :</label>
                                    <select id="AsstManager" name="AsstManager" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option selected disabled>-Choose-</option>
                                        <option value="0">NO</option>
                                        <option value="1">YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">APPROVAL MANAGER :</label>
                                    <select id="Manager" name="Manager" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option selected disabled>-Choose-</option>
                                        <option value="0">NO</option>
                                        <option value="1">YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">SENIOR MANAGER :</label>
                                    <select id="SeniorManager" name="SeniorManager" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option selected disabled>-Choose-</option>
                                        <option value="0">NO</option>
                                        <option value="1">YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">GENERAL MANAGER :</label>
                                    <select id="GeneralManager" name="GeneralManager" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option selected disabled>-Choose-</option>
                                        <option value="0">NO</option>
                                        <option value="1">YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">DIRECTOR PRD PIANO/GUITAR :</label>
                                    <select id="Director" name="Director" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option selected disabled>-Choose-</option>
                                        <option value="0">NO</option>
                                        <option value="1">YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">PRESIDENT DIRECTOR <span class="text-danger">*</span> :</label>
                                    <select disabled id="PresidentDirector" name="PresidentDirector" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <!-- <option value="0" selected>NO</option> -->
                                        <option selected value="1">YES</option>
                                    </select>
                                </div>
                                <!-- <div class="fv-row mb-5">
                                    <label class="form-label">FINANCE STAFF <span class="text-danger">*</span> :</label>
                                    <select disabled id="FinanceStaff" name="FinanceStaff" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option value="0" selected>NO</option>
                                        <option selected value="1">YES</option>
                                    </select>
                                </div> -->
                                <div class="fv-row mb-5">
                                    <label class="form-label">FINANCE MANAGER <span class="text-danger">*</span> :</label>
                                    <select disabled id="FInanceManager" name="FInanceManager" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <!-- <option value="0" selected>NO</option> -->
                                        <option selected value="1">YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">FINANCE DIRECTOR <span class="text-danger">*</span> :</label>
                                    <select disabled id="FinanceDirector" name="FinanceDirector" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <!-- <option value="0" selected>NO</option> -->
                                        <option selected value="1">YES</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    <?php else : ?>
                        <?php $approval = $approvals->row(); ?>
                        <div class="row">
                            <div class="col-lg-5 col-md-12">
                                <div class="fv-row mb-5">
                                    <label class="form-label">APPROVAL STAFF :</label>
                                    <select id="Staff" name="Staff" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option value="0" <?= ($approval->Staff == 0) ? 'selected' : ''  ?>>NO</option>
                                        <option value="1" <?= ($approval->Staff == 1) ? 'selected' : '' ?>>YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">APPROVAL CHIEF :</label>
                                    <select id="Chief" name="Chief" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option value="0" <?= ($approval->Chief == 0) ? 'selected' : ''  ?>>NO</option>
                                        <option value="1" <?= ($approval->Chief == 1) ? 'selected' : '' ?>>YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">APPROVAL ASST. MANAGER :</label>
                                    <select id="AsstManager" name="AsstManager" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option value="0" <?= ($approval->AsstManager == 0) ? 'selected' : ''  ?>>NO</option>
                                        <option value="1" <?= ($approval->AsstManager == 1) ? 'selected' : '' ?>>YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">APPROVAL MANAGER :</label>
                                    <select id="Manager" name="Manager" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option value="0" <?= ($approval->Manager == 0) ? 'selected' : ''  ?>>NO</option>
                                        <option value="1" <?= ($approval->Manager == 1) ? 'selected' : '' ?>>YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">SENIOR MANAGER :</label>
                                    <select id="SeniorManager" name="SeniorManager" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option value="0" <?= ($approval->SeniorManager == 0) ? 'selected' : ''  ?>>NO</option>
                                        <option value="1" <?= ($approval->SeniorManager == 1) ? 'selected' : '' ?>>YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">GENERAL MANAGER :</label>
                                    <select id="GeneralManager" name="GeneralManager" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option value="0" <?= ($approval->GeneralManager == 0) ? 'selected' : ''  ?>>NO</option>
                                        <option value="1" <?= ($approval->GeneralManager == 1) ? 'selected' : '' ?>>YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">DIRECTOR PRD PIANO/GUITAR:</label>
                                    <select id="Director" name="Director" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option value="0" <?= ($approval->Director == 0) ? 'selected' : ''  ?>>NO</option>
                                        <option value="1" <?= ($approval->Director == 1) ? 'selected' : '' ?>>YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">PRESIDENT DIRECTOR <span class="text-danger">*</span> :</label>
                                    <select disabled id="PresidentDirector" name="PresidentDirector" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <!-- <option value="0" selected>NO</option> -->
                                        <option selected value="1">YES</option>
                                    </select>
                                </div>
                                <!-- <div class="fv-row mb-5">
                                    <label class="form-label">FINANCE STAFF <span class="text-danger">*</span> :</label>
                                    <select disabled id="FinanceStaff" name="FinanceStaff" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <option value="0" selected>NO</option>
                                        <option selected value="1">YES</option>
                                    </select>
                                </div> -->
                                <div class="fv-row mb-5">
                                    <label class="form-label">FINANCE MANAGER <span class="text-danger">*</span> :</label>
                                    <select disabled id="FInanceManager" name="FInanceManager" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <!-- <option value="0" selected>NO</option> -->
                                        <option selected value="1">YES</option>
                                    </select>
                                </div>
                                <div class="fv-row mb-5">
                                    <label class="form-label">FINANCE DIRECTOR <span class="text-danger">*</span> :</label>
                                    <select disabled id="FinanceDirector" name="FinanceDirector" required class="form-select form-select-sm form-control form-control-sm" data-placeholder="-Pilih-">
                                        <!-- <option value="0" selected>NO</option> -->
                                        <option selected value="1">YES</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    <?php endif; ?>
                </form>
            </div>
            <div class="card-footer">
                <a href="<?= base_url() ?>" class="btn btn-danger float-end"><i class="far fa-times-circle"></i> Cancel</a>
                <button type="button" id="submit-main-data" class="btn btn-primary me-2 mb-2 shadow-sm">
                    <span class="svg-icon svg-icon-1 svg-icon-muted">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                            <path opacity="0.3" d="M10 4H21C21.6 4 22 4.4 22 5V7H10V4Z" fill="black" />
                            <path opacity="0.3" d="M13 14.4V9C13 8.4 12.6 8 12 8C11.4 8 11 8.4 11 9V14.4H13Z" fill="black" />
                            <path d="M10.4 3.60001L12 6H21C21.6 6 22 6.4 22 7V19C22 19.6 21.6 20 21 20H3C2.4 20 2 19.6 2 19V4C2 3.4 2.4 3 3 3H9.20001C9.70001 3 10.2 3.20001 10.4 3.60001ZM13 14.4V9C13 8.4 12.6 8 12 8C11.4 8 11 8.4 11 9V14.4H8L11.3 17.7C11.7 18.1 12.3 18.1 12.7 17.7L16 14.4H13Z" fill="black" />
                        </svg>
                    </span> &nbsp;&nbsp;<strong>Save</strong>&nbsp;&nbsp;
                </button>
            </div>
        </div>
    </div>
</div>