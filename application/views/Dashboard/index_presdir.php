<div class="row gy-5 g-xl-12">
    <div class="col-xl-4">
        <!--begin::Mixed Widget 2-->
        <div class="card card-xxl-stretch">
            <!--begin::Header-->
            <div class="card-header border-0 py-5" style="background-color: #1E1E2D;">
                <h3 class="display-6 fw-bolder text-white">E-Samick Budget Approval - Quick Dashboard <br><?= date('F Y') ?></h3>
            </div>
            <!--end::Header-->
            <!--begin::Body-->
            <div class="card-body p-0" style="position: relative;">
                <!--begin::Chart-->
                <div class="mixed-widget-2-chart card-rounded-bottom" data-kt-color="success" style="height: 100px; min-height: 20px; background-color: #1E1E2D;">
                    <!-- <div id="apexcharts5vtmudhc" class="apexcharts-canvas apexcharts5vtmudhc apexcharts-theme-light" style="width: 403px; height: 50px;">

                        <div class="apexcharts-legend" style="max-height: 100px;"></div>
                        <div class="apexcharts-tooltip apexcharts-theme-light">
                            <div class="apexcharts-tooltip-title" style="font-family: inherit; font-size: 12px;"></div>
                            <div class="apexcharts-tooltip-series-group" style="order: 1;"><span class="apexcharts-tooltip-marker" style="background-color: transparent;"></span>
                                <div class="apexcharts-tooltip-text" style="font-family: inherit; font-size: 12px;">
                                    <div class="apexcharts-tooltip-y-group"><span class="apexcharts-tooltip-text-y-label"></span><span class="apexcharts-tooltip-text-y-value"></span></div>
                                    <div class="apexcharts-tooltip-goals-group"><span class="apexcharts-tooltip-text-goals-label"></span><span class="apexcharts-tooltip-text-goals-value"></span></div>
                                    <div class="apexcharts-tooltip-z-group"><span class="apexcharts-tooltip-text-z-label"></span><span class="apexcharts-tooltip-text-z-value"></span></div>
                                </div>
                            </div>
                        </div>
                        <div class="apexcharts-yaxistooltip apexcharts-yaxistooltip-0 apexcharts-yaxistooltip-left apexcharts-theme-light">
                            <div class="apexcharts-yaxistooltip-text"></div>
                        </div>
                    </div> -->
                </div>
                <!--end::Chart-->
                <!--begin::Stats-->
                <style>
                    /* Tambahan CSS ringan untuk efek hover jika template Anda belum memilikinya */
                    .card-hover-elevate {
                        transition: transform 0.3s ease, box-shadow 0.3s ease;
                    }

                    .card-hover-elevate:hover {
                        transform: translateY(-5px);
                        box-shadow: 0 .5rem 1rem rgba(0, 0, 0, .15) !important;
                    }
                </style>

                <div class="card-p mt-n20 position-relative">
                    <!--begin::Row-->
                    <div class="row g-5">

                        <!--begin::Col - Awaiting Approvals-->
                        <div class="col-12 col-md-6">
                            <div class="card shadow alert alert-warning border-5 card-hover-elevate h-100">
                                <div class="card-body p-6">
                                    <!-- Header: Icon & Title -->
                                    <div class="d-flex align-items-center mb-4">
                                        <span class="svg-icon svg-icon-3x svg-icon-dark rotate-90 me-3">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 14 21" fill="none">
                                                <path opacity="0.3" d="M12 6.2V1.2H2V6.2C2 6.5 2.1 6.7 2.3 6.9L5.6 10.2L2.3 13.5C2.1 13.7 2 13.9 2 14.2V19.2H12V14.2C12 13.9 11.9 13.7 11.7 13.5L8.4 10.2L11.7 6.9C11.9 6.7 12 6.5 12 6.2Z" fill="black" />
                                                <path d="M13 2.2H1C0.4 2.2 0 1.8 0 1.2C0 0.6 0.4 0.2 1 0.2H13C13.6 0.2 14 0.6 14 1.2C14 1.8 13.6 2.2 13 2.2ZM13 18.2H10V16.2L7.7 13.9C7.3 13.5 6.7 13.5 6.3 13.9L4 16.2V18.2H1C0.4 18.2 0 18.6 0 19.2C0 19.8 0.4 20.2 1 20.2H13C13.6 20.2 14 19.8 14 19.2C14 18.6 13.6 18.2 13 18.2ZM4.4 6.2L6.3 8.1C6.7 8.5 7.3 8.5 7.7 8.1L9.6 6.2H4.4Z" fill="black" />
                                            </svg>
                                        </span>
                                    </div>
                                    <span class="fw-bolder d-block fs-2x lh-1 ls-n1 mb-1">Awaiting Approval</span>
                                    <span class="fw-bolder d-block fs-2qx lh-1 ls-n1 mb-1 mt-5"><?= $Awaiting_Approvals ?> <small class="text-muted fs-5 fw-bold">CBRs</small></span>
                                </div>
                            </div>
                        </div>
                        <!--end::Col-->

                        <!--begin::Col - Approved-->
                        <div class="col-12 col-md-6">
                            <div class="card shadow alert alert-success border-5 card-hover-elevate h-100">
                                <div class="card-body p-6">
                                    <div class="d-flex align-items-center mb-4">
                                        <span class="svg-icon svg-icon-4x svg-icon-primary me-3">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                                <path opacity="0.5" d="M12.8956 13.4982L10.7949 11.2651C10.2697 10.7068 9.38251 10.7068 8.85731 11.2651C8.37559 11.7772 8.37559 12.5757 8.85731 13.0878L12.7499 17.2257C13.1448 17.6455 13.8118 17.6455 14.2066 17.2257L21.1427 9.85252C21.6244 9.34044 21.6244 8.54191 21.1427 8.02984C20.6175 7.47154 19.7303 7.47154 19.2051 8.02984L14.061 13.4982C13.7451 13.834 13.2115 13.834 12.8956 13.4982Z" fill="black" />
                                                <path d="M7.89557 13.4982L5.79487 11.2651C5.26967 10.7068 4.38251 10.7068 3.85731 11.2651C3.37559 11.7772 3.37559 12.5757 3.85731 13.0878L7.74989 17.2257C8.14476 17.6455 8.81176 17.6455 9.20663 17.2257L16.1427 9.85252C16.6244 9.34044 16.6244 8.54191 16.1427 8.02984C15.6175 7.47154 14.7303 7.47154 14.2051 8.02984L9.06096 13.4982C8.74506 13.834 8.21146 13.834 7.89557 13.4982Z" fill="black" />
                                            </svg>
                                        </span>
                                    </div>

                                    <span class="fw-bolder d-block fs-2x lh-1 ls-n1 mb-1">Approved</span>
                                    <span class="fw-bolder d-block fs-2qx lh-1 ls-n1 mb-1 mt-5"><?= $Approved ?> <small class="text-muted fs-5 fw-bold">CBRs</small></span>
                                </div>
                            </div>
                        </div>
                        <!--end::Col-->

                        <!--begin::Col - Rejected-->
                        <div class="col-12 col-md-6">
                            <div class="card shadow alert alert-danger border-5 card-hover-elevate h-100">
                                <div class="card-body p-6">
                                    <div class="d-flex align-items-center mb-4">
                                        <span class="svg-icon svg-icon-3x svg-icon-dark me-3">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                                <path opacity="0.3" d="M6.7 19.4L5.3 18C4.9 17.6 4.9 17 5.3 16.6L16.6 5.3C17 4.9 17.6 4.9 18 5.3L19.4 6.7C19.8 7.1 19.8 7.7 19.4 8.1L8.1 19.4C7.8 19.8 7.1 19.8 6.7 19.4Z" fill="black" />
                                                <path d="M19.5 18L18.1 19.4C17.7 19.8 17.1 19.8 16.7 19.4L5.40001 8.1C5.00001 7.7 5.00001 7.1 5.40001 6.7L6.80001 5.3C7.20001 4.9 7.80001 4.9 8.20001 5.3L19.5 16.6C19.9 16.9 19.9 17.6 19.5 18Z" fill="black" />
                                            </svg>
                                        </span>
                                    </div>
                                    <span class="fw-bolder d-block fs-2x lh-1 ls-n1 mb-1">Rejected</span>
                                    <span class="fw-bolder d-block fs-2qx lh-1 ls-n1 mb-1 mt-5"><?= $Rejected ?> <small class="text-muted fs-5 fw-bold">CBRs</small></span>
                                </div>
                            </div>
                        </div>
                        <!--end::Col-->

                        <!--begin::Col - Amount Approved-->
                        <div class="col-12 col-md-6">
                            <div class="card shadow bg-light border-5 card-hover-elevate h-100">
                                <div class="card-body p-6">
                                    <div class="d-flex align-items-center mb-4">
                                        <span class="svg-icon svg-icon-2x svg-icon-primary me-3">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                                <path d="M6 8.725C6 8.125 6.4 7.725 7 7.725H14L18 11.725V12.925L22 9.725L12.6 2.225C12.2 1.925 11.7 1.925 11.4 2.225L2 9.725L6 12.925V8.725Z" fill="black"></path>
                                                <path opacity="0.3" d="M22 9.72498V20.725C22 21.325 21.6 21.725 21 21.725H3C2.4 21.725 2 21.325 2 20.725V9.72498L11.4 17.225C11.8 17.525 12.3 17.525 12.6 17.225L22 9.72498ZM15 11.725H18L14 7.72498V10.725C14 11.325 14.4 11.725 15 11.725Z" fill="black"></path>
                                            </svg>
                                        </span>
                                        <a href="#" class="text-primary fw-bolder fs-5 text-hover-dark mb-0 text-decoration-none">Amount Approved</a>
                                    </div>

                                    <div class="d-flex flex-column gap-2 text-dark">
                                        <?php
                                        if (empty($Amount_Approved)) {
                                            echo '<div class="fs-2 fw-bolder">0</div>';
                                        } else {
                                            foreach ($Amount_Approved as $currency => $total) {
                                                $formatted_total = number_format($total, 2, '.', ',');
                                                // Tampilan dipisah agar lebih estetik
                                                echo '<div class="d-flex justify-content-between align-items-center bg-white bg-opacity-50 rounded px-3 py-2">
                                        <span class="fw-bold"><b>' . htmlspecialchars($currency) . '</b></span>
                                        <span class="fs-4 fw-bolder text-dark">' . $formatted_total . '</span>
                                      </div>';
                                            }
                                        }
                                        ?>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!--end::Col-->

                    </div>
                    <!--end::Row-->
                </div>
                <!--end::Stats-->
                <div class="resize-triggers">
                    <div class="expand-trigger">
                        <div style="width: 404px; height: 462px;"></div>
                    </div>
                    <div class="contract-trigger"></div>
                </div>
            </div>
            <!--end::Body-->
        </div>
        <!--end::Mixed Widget 2-->
    </div>
    <!--end::Col-->
    <div class="col-xl-8">
        <!--begin::Tables Widget 9-->
        <div class="card card-xl-stretch mb-5 mb-xl-8">
            <!--begin::Header-->
            <div class="card-header border-0 pt-5">
                <h3 class="card-title align-items-start flex-column">
                    <span class="card-label fw-bolder fs-3 mb-1">Awaiting Approvals</span>
                    <span class="text-muted mt-1 fw-bold fs-7">Details of <?= $Awaiting_Approvals ?> submissions</span>
                </h3>
                <div class="card-toolbar">
                    <a href="#" class="btn btn-sm btn-light btn-primary">
                        <!--begin::Svg Icon | path: icons/duotune/arrows/arr075.svg-->
                        <!--begin::Svg Icon | path: assets/media/icons/duotune/files/fil002.svg-->
                        <span class="svg-icon"><svg xmlns="http://www.w3.org/2000/svg" width="20" height="21" viewBox="0 0 20 21" fill="none">
                                <path opacity="0.3" d="M19 3.40002C18.4 3.40002 18 3.80002 18 4.40002V8.40002H14V4.40002C14 3.80002 13.6 3.40002 13 3.40002C12.4 3.40002 12 3.80002 12 4.40002V8.40002H8V4.40002C8 3.80002 7.6 3.40002 7 3.40002C6.4 3.40002 6 3.80002 6 4.40002V8.40002H2V4.40002C2 3.80002 1.6 3.40002 1 3.40002C0.4 3.40002 0 3.80002 0 4.40002V19.4C0 20 0.4 20.4 1 20.4H19C19.6 20.4 20 20 20 19.4V4.40002C20 3.80002 19.6 3.40002 19 3.40002ZM18 10.4V13.4H14V10.4H18ZM12 10.4V13.4H8V10.4H12ZM12 15.4V18.4H8V15.4H12ZM6 10.4V13.4H2V10.4H6ZM2 15.4H6V18.4H2V15.4ZM14 18.4V15.4H18V18.4H14Z" fill="black" />
                                <path d="M19 0.400024H1C0.4 0.400024 0 0.800024 0 1.40002V4.40002C0 5.00002 0.4 5.40002 1 5.40002H19C19.6 5.40002 20 5.00002 20 4.40002V1.40002C20 0.800024 19.6 0.400024 19 0.400024Z" fill="black" />
                            </svg></span>
                        <!--end::Svg Icon-->
                        <!--end::Svg Icon--><?= date('F Y') ?></a>
                </div>
            </div>
            <!--end::Header-->
            <!--begin::Body-->
            <div class="card-body py-3">
                <!--begin::Table container-->
                <div class="table-responsive">
                    <!--begin::Table-->
                    <?php
                    // ++ TAMBAHAN UNTUK TOTAL: Siapkan variabel penampung ++
                    $grandTotalCBRs = 0;
                    $grandTotalAmounts = [];

                    // Inisialisasi nilai 0 untuk setiap mata uang yang ada
                    foreach ($currencies as $curr) {
                        $grandTotalAmounts[$curr] = 0;
                    }
                    // ++ AKHIR TAMBAHAN ++
                    ?>

                    <table class="table table-row-dashed table-row-gray-500 align-middle gs-0 gy-4">
                        <thead>
                            <tr class="fw-bolder text-muted">
                                <th class="w-25px">
                                    <div class="form-check form-check-sm form-check-custom form-check-solid">
                                        <input class="form-check-input" type="checkbox" disabled value="1" data-kt-check="true" data-kt-check-target=".widget-9-check">
                                    </div>
                                </th>
                                <th>Division</th>
                                <th>Total CBRs</th>
                                <?php foreach ($currencies as $curr): ?>
                                    <th>Total Amount (<?= $curr; ?>)</th>
                                <?php endforeach; ?>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($divisions as $divName => $data): ?>
                                <?php
                                // ++ TAMBAHAN UNTUK TOTAL: Akumulasi Total CBRs ++
                                $grandTotalCBRs += $data['Total_CBRs'];
                                // ++ AKHIR TAMBAHAN ++
                                ?>
                                <tr>
                                    <td>
                                        <span class="bullet bullet-vertical h-40px bg-warning"></span>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="symbol symbol-45px me-5">
                                                <img src="<?= base_url() ?>assets/media/Department/<?= str_replace(' ', '_', $divName) ?>.png" alt="<?= $divName ?>">
                                            </div>
                                            <div class="d-flex justify-content-start flex-column">
                                                <span href="#" class="text-dark fw-bolder text-hover-primary fs-6"><?= $divName ?></span>
                                                <span class="text-muted fw-bold text-muted d-block fs-7">Department</span>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span href="#" class="text-dark fw-bolder text-hover-primary d-block fs-6"><?= $data['Total_CBRs']; ?></span>
                                        <span class="text-muted fw-bold text-muted d-block fs-7">Total CBR Submitted</span>
                                    </td>
                                    <?php foreach ($currencies as $curr): ?>
                                        <td>
                                            <?php
                                            // Cek apakah ada nominal untuk mata uang ini di divisi ini
                                            $amount = isset($data['Amounts'][$curr]) ? $data['Amounts'][$curr] : 0;

                                            // ++ TAMBAHAN UNTUK TOTAL: Akumulasi nilai mata uang ++
                                            $grandTotalAmounts[$curr] += $amount;
                                            // ++ AKHIR TAMBAHAN ++

                                            // Format angka (IDR & JPY tanpa desimal, selainnya 2 desimal)
                                            if ($curr === 'IDR' || $curr === 'JPY') {
                                                echo number_format($amount, 0, ',', '.');
                                            } else {
                                                echo number_format($amount, 2, '.', ',');
                                            }
                                            ?>
                                        </td>
                                    <?php endforeach; ?>

                                </tr>
                            <?php endforeach; ?>

                            <tr class="bg-light fw-bolder text-dark">
                                <td></td>
                                <td class="text-end pe-5 fs-5">GRAND TOTAL :</td>
                                <td class="fs-5"><?= $grandTotalCBRs; ?></td>

                                <?php foreach ($currencies as $curr): ?>
                                    <td class="fs-5">
                                        <?php
                                        $totalAmt = $grandTotalAmounts[$curr];
                                        if ($curr === 'IDR' || $curr === 'JPY') {
                                            echo number_format($totalAmt, 0, ',', '.');
                                        } else {
                                            echo number_format($totalAmt, 2, '.', ',');
                                        }
                                        ?>
                                    </td>
                                <?php endforeach; ?>
                            </tr>
                        </tbody>
                    </table>
                    <!--end::Table-->
                </div>
                <!--end::Table container-->
            </div>
        </div>
    </div>
    <div class="col-xl-12">
        <div class="card card-xl-stretch mb-5 mb-xl-8">
            <div class="card-header border-0 pt-5">
                <h3 class="card-title align-items-start flex-column">
                    <span class="card-label fw-bolder fs-3 mb-1">Archived Submission Approved</span>
                    <span class="text-muted mt-1 fw-bold fs-7">Summarize All submissions approved By Division</span>
                </h3>
                <div class="card-toolbar">
                    <div class="row">
                        <div class="col-md-6">
                            <select name="year_hist" id="year_hist" class="form-select form-select-solid me-2">
                                <?php
                                $currentYear = date('Y');
                                for ($year = $currentYear; $year >= 2026; $year--) {
                                    echo "<option value='{$year}'>{$year}</option>";
                                }
                                ?>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <select name="month_hist" id="month_hist" class="form-select form-select-solid me-2">
                                <?php
                                $months = [
                                    1 => 'January',
                                    2 => 'February',
                                    3 => 'March',
                                    4 => 'April',
                                    5 => 'May',
                                    6 => 'June',
                                    7 => 'July',
                                    8 => 'August',
                                    9 => 'September',
                                    10 => 'October',
                                    11 => 'November',
                                    12 => 'December'
                                ];
                                $last_month = date('n', strtotime('0 month'));
                                foreach ($months as $num => $name) {
                                    $is_selected = ($num == $last_month) ? 'selected' : '';
                                    echo "<option value='{$num}' {$is_selected}>{$name}</option>";
                                }
                                ?>
                            </select>
                        </div>
                    </div>
                    &nbsp;&nbsp;
                    <button type="button" class="btn btn-sm btn-danger" id="btn_search_history">
                        <span class="svg-icon"><i class="fas fa-search"></i></span> Search
                    </button>
                </div>
            </div>
            <div class="card-body py-3">
                <div class="table-responsive">
                    <table class="table table-row-dashed table-striped table-row-gray-500 align-middle gs-0 gy-4" id="history_table">
                        <thead id="history_head">
                            <tr class="fw-bolder text-muted">
                                <th class="w-25px">
                                    <div class="form-check form-check-sm form-check-custom form-check-solid">
                                        <input class="form-check-input" type="checkbox" disabled value="1" data-kt-check="true" data-kt-check-target=".widget-9-check">
                                    </div>
                                </th>
                                <th>Division</th>
                                <th>Total CBRs</th>
                                <th>Total Amount (IDR)</th>
                            </tr>
                        </thead>
                        <tbody id="history_body">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>