<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card card-flush overflow-hidden h-xl-100">
            <div class="card-header py-5">
                <div class="card-toolbar">
                    <ul class="nav nav-tabs fs-6 border-0">
                        <li class="nav-item">
                            <a class="nav-link mr-5 active btn btn-flex btn-active-light-primary" data-bs-toggle="tab" href="#kt_tab_pane_4">
                                <h5 class="font-weight-bold" id="table-title-main"> Employee Active</h5>
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="card-toolbar">
                    <a href="<?= base_url('Dashboard') ?>" type="button" class="btn btn-sm btn-light-danger"><i class="far fa-arrow-alt-circle-left"></i> Back</a>
                </div>
            </div>
            <div class="card-body pt-0">
                <div class="py-5">
                    <div class="tab-content" id="myTabContent">
                        <div class="tab-pane fade active show" id="kt_tab_pane_4" role="tabpanel">

                            <div class="row mb-6">
                                <label for="Account" class="col-sm-1 col-form-label-sm col-form-label">Filter :</label>
                                <div class="col-sm-6">
                                    <div class="input-group">
                                        <select name="var" id="var" class="form-select form-select-sm">
                                            <option value="Emp_No">NIK</option>
                                            <option value="First_Name">Employee Name </option>
                                            <option value="Pos_Name">Position Name</option>
                                            <option value="Division_Name">Unit</option>
                                            <!-- <option value="costcenter_name">Section</option> -->
                                            <!-- <option value="EMPLOYMENTSTATUS_NAME">Status</option> -->
                                            <option value="Emai">Email</option>
                                            <option value="MOBILE_PHONE">Mobile Phone</option>
                                        </select>
                                        <span class=" input-group-text btn btn-sm btn-light" title="contain" data-toggle="tooltip"><b>=</b></span>
                                        <input name="param" id="param" required class="form-control form-control-sm">
                                        <button class="input-group-text btn btn-sm btn-primary" type="button" id="search" title="Search" data-toggle="tooltip"><i class="fas fa-search"></i></button>
                                    </div>
                                </div>
                            </div>

                            <div class="pb-5 table-responsive">
                                <table class="display compact table-bordered table-striped table-hover table-sm align-middle gy-5 gs-5" id="DataTable">
                                    <thead>
                                        <tr style="background-color: #3B6D8C;">
                                            <th>#</th>
                                            <th>NIK</th>
                                            <th>NAME</th>
                                            <th>POSITION</th>
                                            <th>UNIT</th>
                                            <th>STATUS</th>
                                            <th>AGE</th>
                                            <th>TENURE</th>
                                            <th>EMAIL</th>
                                            <th>PHONE</th>
                                            <th>PHOTO</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <!-- Hey i do some magic here -->
                                    </tbody>
                                </table>

                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div id="location"></div>