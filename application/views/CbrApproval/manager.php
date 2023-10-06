<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card card-flush overflow-hidden h-xl-100">

            <div class="card-header py-5">
                <div class="card-toolbar">
                    <ul class="nav nav-tabs fs-6 border-0">
                        <li class="nav-item">
                            <a class="nav-link mr-5 active btn btn-flex btn-active-light-primary" data-bs-toggle="tab" href="#kt_tab_pane_4">
                                <h5 class="font-weight-bold" id="table-title-main">Need Approval</h5>
                            </a>
                        </li>
                        <li class="nav-item mr-5">
                            <a class="nav-link btn btn-flex btn-active-light-primary" data-bs-toggle="tab" href="#kt_tab_pane_5">
                                <h5 class="font-weight-bold" id="table-title-history">History Approval</h5>
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
                            <div class="pb-5 table-responsive">
                                <form action="#" id="form-submission" method="post">
                                    <table id="TableData" class="table-sm align-middle display compact dt-nowrap table-rounded table-striped table-bordered border gy-5 gs-5 dataTable no-footer dtr-inline">
                                        <thead style="background-color: #3B6D8C;">
                                            <tr class="text-start text-white fw-bolder text-uppercase">
                                                <th class="text-center text-white">
                                                    <div class="custom-checkbox">
                                                        <input class="form-check-input" type="checkbox" id="CheckAll" value="checkall" onclick="check_uncheck_checkbox(this.checked);">
                                                        <label for="CheckAll" class="custom-control-label"> All</label>
                                                    </div>
                                                </th>
                                                <th class="text-center text-white">Doc Numb</th>
                                                <th class="text-center text-white">Date</th>
                                                <th class="text-center text-white">Currency</th>
                                                <th class="text-center text-white">Amount</th>
                                                <th class="text-center text-white">Description</th>
                                                <th class="text-center text-white">Status</th>
                                                <th class="text-center text-white">Approval</th>
                                                <th class="text-center text-white">Approved Date</th>
                                                <th class="text-center text-white"><i class="fas fa-cogs"></i></th>
                                            </tr>
                                        </thead>
                                        <tbody class="text-gray-600 fw-bold">
                                        </tbody>
                                    </table>
                                </form>
                            </div>
                        </div>
                        <div class="tab-pane fade" id="kt_tab_pane_5" role="tabpanel">
                            <div class="pb-5 table-responsive">
                                <table id="TableDataHistory" class="table-sm align-middle display compact dt-nowrap table-rounded table-striped table-bordered border gy-5 gs-5 dataTable no-footer dtr-inline">
                                    <thead style="background-color: #3B6D8C;">
                                        <tr class="text-start text-white fw-bolder text-uppercase">
                                            <th class="text-center text-white">#</th>
                                            <th class="text-center text-white">NAME</th>
                                            <th class="text-center text-white">ID ACCESS</th>
                                            <th class="text-center text-white">SOURCE</th>
                                            <th class="text-center text-white">DATE</th>
                                            <th class="text-center text-white">TIME</th>
                                            <th class="text-center text-white">SCHEDULE NUMBER</th>
                                            <th class="text-center text-white">DAY</th>
                                            <th class="text-center text-white">CLASS</th>
                                            <th class="text-center text-white">SUBJECT</th>
                                            <th class="text-center text-white">START TIME</th>
                                            <th class="text-center text-white">TIME OVER</th>
                                            <th class="text-center text-white">STAND HOUR</th>
                                            <th class="text-center text-white">STATUS</th>
                                        </tr>
                                    </thead>
                                    <tbody class="text-gray-600 fw-bold">
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