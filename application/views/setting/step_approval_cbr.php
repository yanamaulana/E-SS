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
                    <div class="row">
                        <div class="col-lg-5 col-md-12">
                            <div class="fv-row mb-5">
                                <label class="form-label">APPROVAL STAFF :</label>
                                <select id="Staff" name="Staff" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <option value="0" selected>NO</option>
                                    <option value="1">YES</option>
                                </select>
                            </div>
                            <div class="fv-row mb-5">
                                <label class="form-label">APPROVAL CHIEF :</label>
                                <select id="Chief" name="Chief" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <option value="0" selected>NO</option>
                                    <option value="1">YES</option>
                                </select>
                            </div>
                            <div class="fv-row mb-5">
                                <label class="form-label">APPROVAL ASST. MANAGER :</label>
                                <select id="AsstManager" name="AsstManager" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <option value="0" selected>NO</option>
                                    <option value="1">YES</option>
                                </select>
                            </div>
                            <div class="fv-row mb-5">
                                <label class="form-label">APPROVAL MANAGER :</label>
                                <select id="Manager" name="Manager" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <option value="0" selected>NO</option>
                                    <option value="1">YES</option>
                                </select>
                            </div>
                            <div class="fv-row mb-5">
                                <label class="form-label">SENIOR MANAGER :</label>
                                <select id="SeniorManager" name="SeniorManager" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <option value="0" selected>NO</option>
                                    <option value="1">YES</option>
                                </select>
                            </div>
                            <div class="fv-row mb-5">
                                <label class="form-label">GENERAL MANAGER :</label>
                                <select id="GeneralManager" name="GeneralManager" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <option value="0" selected>NO</option>
                                    <option value="1">YES</option>
                                </select>
                            </div>
                            <div class="fv-row mb-5">
                                <label class="form-label">DIRECTOR :</label>
                                <select id="Director" name="Director" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <option value="0" selected>NO</option>
                                    <option value="1">YES</option>
                                </select>
                            </div>
                            <div class="fv-row mb-5">
                                <label class="form-label">PRESIDENT DIRECTOR :</label>
                                <select disabled id="PresidentDirector" name="PresidentDirector" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <!-- <option value="0" selected>NO</option> -->
                                    <option selected value="1">YES</option>
                                </select>
                            </div>
                            <div class="fv-row mb-5">
                                <label class="form-label">FINANCE STAFF :</label>
                                <select disabled id="FinanceStaff" name="FinanceStaff" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <!-- <option value="0" selected>NO</option> -->
                                    <option selected value="1">YES</option>
                                </select>
                            </div>
                            <div class="fv-row mb-5">
                                <label class="form-label">FINANCE MANAGER :</label>
                                <select disabled id="FInanceManager" name="FInanceManager" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <!-- <option value="0" selected>NO</option> -->
                                    <option selected value="1">YES</option>
                                </select>
                            </div>
                            <div class="fv-row mb-5">
                                <label class="form-label">FINANCE DIRECTOR :</label>
                                <select disabled id="FinanceDirector" name="FinanceDirector" required class="form-select form-control" data-control="select2" data-placeholder="-Pilih-">
                                    <!-- <option value="0" selected>NO</option> -->
                                    <option selected value="1">YES</option>
                                </select>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="card-footer">
                <a href="<?= base_url() ?>" class="btn btn-danger float-end"><i class="far fa-times-circle"></i> Cancel</a>
                <button type="button" id="submit-main-form" class="btn btn-primary me-2 mb-2 shadow-sm">
                    <span class="svg-icon svg-icon-1">
                        <!--begin::Svg Icon | path: assets/media/icons/duotune/abstract/abs027.svg-->
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                            <path opacity="0.3" d="M21.25 18.525L13.05 21.825C12.35 22.125 11.65 22.125 10.95 21.825L2.75 18.525C1.75 18.125 1.75 16.725 2.75 16.325L4.04999 15.825L10.25 18.325C10.85 18.525 11.45 18.625 12.05 18.625C12.65 18.625 13.25 18.525 13.85 18.325L20.05 15.825L21.35 16.325C22.35 16.725 22.35 18.125 21.25 18.525ZM13.05 16.425L21.25 13.125C22.25 12.725 22.25 11.325 21.25 10.925L13.05 7.62502C12.35 7.32502 11.65 7.32502 10.95 7.62502L2.75 10.925C1.75 11.325 1.75 12.725 2.75 13.125L10.95 16.425C11.65 16.725 12.45 16.725 13.05 16.425Z" fill="black" />
                            <path d="M11.05 11.025L2.84998 7.725C1.84998 7.325 1.84998 5.925 2.84998 5.525L11.05 2.225C11.75 1.925 12.45 1.925 13.15 2.225L21.35 5.525C22.35 5.925 22.35 7.325 21.35 7.725L13.05 11.025C12.45 11.325 11.65 11.325 11.05 11.025Z" fill="black" />
                        </svg>
                        <!--end::Svg Icon-->
                    </span> &nbsp;&nbsp;<strong>Save</strong>&nbsp;&nbsp;
                </button>
            </div>
        </div>
    </div>
</div>