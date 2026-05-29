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

                            <!-- <div class="row mb-6">
                                <label for="Account" class="col-sm-1 col-form-label-sm col-form-label">Filter :</label>
                                <div class="col-sm-6">
                                    <div class="input-group">
                                        <select name="var" id="var" class="form-select form-select-sm">
                                            <option value="Emp_No">NIK</option>
                                            <option value="First_Name">Employee Name </option>
                                            <option value="Pos_Name">Position Name</option>
                                            <option value="Division_Name">Unit</option>
                                            <option value="costcenter_name">Section</option>

                                            <option value="Emai">Email</option>
                                            <option value="MOBILE_PHONE">Mobile Phone</option>
                                        </select>
                                        <span class=" input-group-text btn btn-sm btn-light" title="contain" data-toggle="tooltip"><b>=</b></span>
                                        <input name="param" id="param" required class="form-control form-control-sm">
                                        <button class="input-group-text btn btn-sm btn-primary" type="button" id="search" title="Search" data-toggle="tooltip"><i class="fas fa-search"></i></button>
                                    </div>
                                </div>
                            </div> -->

                            <div class="pb-5 table-responsive">
                                <table class="display compact table-bordered table-striped table-hover table-sm align-middle gy-5 gs-5" id="DataTable">
                                    <thead>
                                        <tr style="font-weight: bold; background-color: #3B6D8C;" align=" center">
                                            <th>No</th>
                                            <th>NIP</th>
                                            <th>EMP ID</th>
                                            <th>Nama Karyawan</th>
                                            <th>Jenis Kelamin</th>
                                            <th style="min-width: 250px !important;">Alamat</th>
                                            <th>Tempat Lahir</th>
                                            <th>Tanggal Lahir</th>
                                            <th>Umur</th>
                                            <th>Tanggal Bergabung</th>
                                            <th>Masa Kerja</th>
                                            <th>Tanggal Resign</th>
                                            <th>Jabatan</th>
                                            <th>Pendidikan</th>
                                            <th>Status Karyawan</th>
                                            <th>Status Pernikahan</th>
                                            <th>Status Pajak</th>
                                            <th>Gaji Pokok</th>
                                            <th>Tunjangan Insentif</th>
                                            <th>Tunjangan Jabatan</th>
                                            <th>Uang Makan</th>
                                            <th>Uang Transport</th>
                                            <th>Cost Center</th>
                                            <th>KTP</th>
                                            <th>No BPJS Kesehatan</th>
                                            <th>No BPJS Ketenagakerjaan</th>
                                            <th>Mobile Phone</th>
                                            <th>Email</th>
                                            <th>Bank Account</th>
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