$(document).ready(function () {
    const Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
            toast.addEventListener('mouseenter', Swal.stopTimer)
            toast.addEventListener('mouseleave', Swal.resumeTimer)
        }
    })

    $('.date-picker').flatpickr();

    function Fn_Initialized_DataTable() {
        $("#TableDataHistory").DataTable({
            destroy: true,
            processing: true,
            serverSide: true,
            paging: true,
            dom: '<"row"<"col-sm-11"f><"col-sm-1"l>>rtip',
            select: false,
            "lengthMenu": [
                [10, 25, 50, 100, 9999],
                [10, 25, 50, 100, 9999]
            ],
            ajax: {
                url: $('meta[name="base_url"]').attr('content') + "MonitoringTermin/DT_List_Incomplete_Termin",
                dataType: "json",
                type: "POST",
                data: {
                    from: $('#from').val(),
                    until: $('#until').val(),
                    column_range: $('#column_range').val(),
                    employee: $('#employee').val()
                }
            },
            columns: [
                {
                    data: "CBReq_No",
                    name: "CBReq_No",
                    visible: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return meta.row + meta.settings._iDisplayStart + 1;
                    }
                },
                {
                    data: "CBReq_No",
                    name: "CBReq_No",
                },
                {
                    data: "Type",
                    name: "Type",
                    visible: false
                },
                {
                    data: "Document_Date",
                    name: "Document_Date",
                    render: function (data) {
                        return data.substring(0, data.indexOf(' '));
                    }
                },
                {
                    data: "Currency_Id",
                    name: "Currency_Id",
                },
                {
                    data: "Amount",
                    name: "Amount",
                    render: function (data) {
                        return parseFloat(data).toLocaleString('en-US', {
                            minimumFractionDigits: 4,
                            maximumFractionDigits: 4
                        });
                    }
                },
                {
                    data: "Document_Number",
                    name: "Document_Number",
                },
                {
                    data: "Descript",
                    name: "Descript",
                },
                {
                    data: "baseamount",
                    name: "baseamount",
                    visible: false
                },
                {
                    data: "curr_rate",
                    name: "curr_rate",
                    visible: false
                },
                {
                    data: "Approval_Status",
                    name: "Approval_Status",
                    visible: false
                },
                {
                    data: "CBReq_Status",
                    name: "CBReq_Status",
                    visible: false
                },
                {
                    data: "Paid_Status",
                    name: "Paid_Status",
                    render: function (data) {
                        if (data == 0 || data == null || data == '') {
                            return `<span class="text-dark badge badge-warning">Not Paid</span>`;
                        } else if (data == 3) {
                            return `<span class="text-white badge badge-info" style="background-color: #17a2b8;">Partially Paid</span>`;
                        } else if (data == 1) {
                            return `<span class="text-white badge badge-success">Fully Paid</span>`;
                        } else if (data == 2) {
                            return `<span class="text-white badge badge-danger">Payment Rejected</span>`;
                        } else {
                            return `<span class="text-dark badge badge-light">-</span>`;
                        }
                    }
                },
                {
                    data: "Creation_DateTime",
                    name: "Creation_DateTime",
                    visible: false
                },
                {
                    data: "UserDivision",
                    name: "UserDivision",
                    orderable: true
                },
                {
                    data: "First_Name",
                    name: "First_Name",
                    orderable: false,
                },
                {
                    data: "Last_Update",
                    name: "Last_Update",
                    visible: false
                },
                {
                    data: "Acc_ID",
                    name: "Acc_ID",
                    visible: false
                },
                {
                    data: "Approve_Date",
                    name: "Approve_Date",
                    visible: false
                },
                {
                    data: "Total_Termin_Submitted",
                    name: "Total_Termin_Submitted",
                    className: "text-center",
                    render: function (data) {
                        return `<span class="badge badge-warning">${data}</span>`;
                    }
                },
                {
                    data: "Total_Termin_Amount",
                    name: "Total_Termin_Amount",
                    className: "text-center",
                    render: function (data) {
                        return parseFloat(data).toLocaleString('en-US', {
                            minimumFractionDigits: 4,
                            maximumFractionDigits: 4
                        });
                    }
                },
                {
                    data: "Remaining_Amount",
                    name: "Remaining_Amount",
                    className: "text-center",
                    render: function (data) {
                        return `<span class="badge badge-danger">${parseFloat(data).toLocaleString('en-US', {
                            minimumFractionDigits: 4,
                            maximumFractionDigits: 4
                        })}</span>`;
                    }
                }
            ],
            order: [[1, 'desc']]
        });
    }

    Fn_Initialized_DataTable();

    $('#do--filter').on('click', function () {
        $("#TableDataHistory").DataTable().destroy();
        Fn_Initialized_DataTable();
    });
});
