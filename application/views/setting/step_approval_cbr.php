<div class="row gx-5 gx-xl-10">
    <div class="col-xl-12">
        <div class="card shadow-sm">
            <div class="card-header">
                <h3 class="card-title"><?= $page_title; ?> : Logistik (Hard Code)</h3>
                <div class="card-toolbar">
                    <a href="<?= base_url() ?>" class="btn btn-sm btn-light-danger">
                        <i class="fas fa-arrow-alt-circle-left"></i> Back
                    </a>
                </div>
            </div>
            <div class="card-body">
                <form id="main-form" class="form-horizontal" enctype="multipart/form-data" action="javascript:void(0)">

                    <div class="row">
                        <div class="col-lg-3 col-md-6">
                            <label class="form-label pr-5">APPROVAL Staff :</label>
                            <div class="fv-row pt-5">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" name="Staff" id="Staff_Yes" value="1">
                                    <label class="form-check-label" for="Staff_Yes">YES</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" name="Staff" id="Staff_No" value="0" checked>
                                    <label class="form-check-label" for="Staff_No">NO</label>
                                </div>

                            </div>
                        </div>
                        <div class="col-lg-4 col-md-6">
                            <label class="form-label pr-5">Staff PERSON :</label>
                            <div class="input-group">
                                <input type="text" class="form-control nik" name="Staff_person" id="Staff_person" placeholder="NIK/Username ERP Sunfish" aria-label="Recipient's username" aria-describedby="button-addon2" data-fin="0" data-dir="0">

                                <input type="hidden" name="Staff_valid" id="Staff_valid" class="validation" value="0">

                                <div class="input-group-append">
                                    <button class="btn btn-danger validate-person" type="button"><i class="fas fa-user"></i> Validation</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <hr class="devider">





                    <div class="row">
                        <div class="col-lg-3 col-md-6">
                            <label class="form-label pr-5">APPROVAL General Manager :</label>
                            <div class="fv-row pt-5">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" name="GeneralManager" id="GeneralManager_Yes" value="1">
                                    <label class="form-check-label" for="GeneralManager_Yes">YES</label>
                                </div>
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="radio" name="GeneralManager" id="GeneralManager_No" value="0" checked>
                                    <label class="form-check-label" for="GeneralManager_No">NO</label>
                                </div>

                            </div>
                        </div>
                        <div class="col-lg-4 col-md-6">
                            <label class="form-label pr-5">General Manager PERSON :</label>
                            <div class="input-group">
                                <input type="text" class="form-control nik" name="GeneralManager_person" id="GeneralManager_person" placeholder="NIK/Username ERP Sunfish" aria-label="Recipient's username" aria-describedby="button-addon2" value="07826" data-fin="0" data-dir="0">

                                <input type="hidden" name="GeneralManager_valid" id="GeneralManager_valid" class="validation" value="0">

                                <div class="input-group-append">
                                    <button class="btn btn-danger validate-person" type="button"><i class="fas fa-user"></i> Validation</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <hr class="devider">



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