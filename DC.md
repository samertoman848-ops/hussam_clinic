# Hussam Clinic Project Overview

## lib
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| firebase_options.dart | Classes: DefaultFirebaseOptions<br/> | Logic for firebase_options.dart |
| main.dart | Classes: _DateModel, MyApp<br/>Key Funcs: build | Logic for main.dart |
| utils.dart | Classes: Event<br/>Key Funcs: getNotificationDate, getHashCode | Logic for utils.dart |


---

## lib\data
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| positioning_demo.dart |  | Logic for positioning_demo.dart |
| TimetableExample.dart | Classes: TimetableExample, _TimetableExampleState, _DoctorAppointmentsDialogWidget, _DoctorAppointmentsDialogWidgetState, _DemoEvent<br/>Key Funcs: initState, dispose, build, print, pickDate | Logic for TimetableExample.dart |
| TimetableWidgt.dart | Classes: TimetableWidgt, TimetableWidgtState<br/>Key Funcs: initState, copyExternalDB, build, userWidget | Logic for TimetableWidgt.dart |
| utils.dart | Classes: ExampleApp<br/>Key Funcs: initDebugOverlay, build | Logic for utils.dart |


---

## lib\datasource
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| expenseReview_datasource.dart | Classes: ExpenseReviewDataSource<br/>Key Funcs: buildRow, getRowBackgroundColor | Logic for expenseReview_datasource.dart |
| invoicesReview_datasource.dart | Classes: InvoicesReviewDataSource<br/>Key Funcs: buildRow, getRowBackgroundColor | Logic for invoicesReview_datasource.dart |
| journalsReview_datasource.dart | Classes: JournalsReviewDataSource<br/>Key Funcs: buildRow, getRowBackgroundColor | Logic for journalsReview_datasource.dart |


---

## lib\db
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| dbdate.dart | Classes: DbDate<br/> | Database access / Helper methods |
| dbemployee.dart | Classes: DbEmployee<br/>Key Funcs: allEmployeesModel | Database access / Helper methods |
| dbhelper.dart | Classes: DbHelper<br/>Key Funcs: configuredDbPath, databaseExists, copyAssetsDb, table_info, max | Database access / Helper methods |
| dbrooms.dart | Classes: DbRooms<br/>Key Funcs: createRoomsTable, allRooms, addRoom, addRoom, addRoom | Database access / Helper methods |


---

## lib\db\accounting
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| dbindex.dart | Classes: DbIndex<br/> | Database access / Helper methods |
| dbtree.dart | Classes: DbTree<br/> | Database access / Helper methods |


---

## lib\db\accounting\invoices
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| dbinvoicedetails.dart | Classes: DbInvoicesDetails<br/> | Database access / Helper methods |
| dbinvoices.dart | Classes: DbInvoices<br/> | Database access / Helper methods |


---

## lib\db\accounting\journal
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| dbjournaldetails.dart | Classes: DbJournalDetails<br/> | Database access / Helper methods |
| dbjournals.dart | Classes: DbJournals<br/> | Database access / Helper methods |


---

## lib\db\accounting\vouchers
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| dbvouchers.dart | Classes: DbVouchers<br/> | Database access / Helper methods |


---

## lib\db\patients
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| dbinvoices.dart | Classes: DbInvoices<br/> | Database access / Helper methods |
| dbpatient.dart | Classes: DbPatient<br/>Key Funcs: getPatientByFileNo, max, getPatientByFileNo | Database access / Helper methods |
| dbpatienthealth.dart | Classes: DbPatientHealth<br/> | Database access / Helper methods |
| dbpatienthealthdoctor.dart | Classes: DbPatientHealthDoctor<br/> | Database access / Helper methods |
| dbpicture.dart | Classes: DbPicture<br/> | Database access / Helper methods |
| dbtreatmentplans.dart | Classes: DbTreatmentPlans<br/> | Database access / Helper methods |


---

## lib\dialog
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| dating_add_dialog.dart | Classes: DatingAddDialog, _DatingAddDialogState, _DemoEvent<br/>Key Funcs: selecedtdatePlaceList, initState, dispose, build, textEditFisrtPage | Logic for dating_add_dialog.dart |
| dating_add_doctors.dart | Classes: DatingAddDoctors, _DatingAddDoctorsState, _DemoEvent<br/>Key Funcs: selecedtdatePlaceList, initState, dispose, build, textEditFisrtPage | Logic for dating_add_doctors.dart |
| dating_edite_dialog.dart | Classes: DatingEditeDialog, _DatingEditeDialogState, _DemoEvent<br/>Key Funcs: selecedtdatePlaceList, initState, dispose, build, textEditFisrtPage | Logic for dating_edite_dialog.dart |
| message_send.dart | Classes: MessageSend<br/>Key Funcs: build | Logic for message_send.dart |


---

## lib\dialog\accounting
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| select_person.dart | Classes: SelectPerson, _SelectPersonState<br/>Key Funcs: checkValues, initState, selecedId, build | Logic for select_person.dart |
| select_persons_group.dart | Classes: SelectPersonsGroup, _SelectPersonsGroupState<br/>Key Funcs: build | Logic for select_persons_group.dart |
| select_trees.dart | Classes: SelectTrees, _SelectTreesState<br/>Key Funcs: build, buildTree | Logic for select_trees.dart |


---

## lib\global_var
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| globals.dart | Key Funcs: appRootPath, getDatabasesPath, databaseExists | Logic for globals.dart |


---

## lib\model
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| DatesModel.dart | Classes: DateModel<br/>Key Funcs: id, kind, place, dateStart, dateEnd | Data structure / Model definition |
| PictureModel.dart | Classes: PictureModel<br/>Key Funcs: pictureId, patient_pic_patientId, pictureLocation | Data structure / Model definition |
| RoomModel.dart | Classes: RoomModel<br/> | Data structure / Model definition |


---

## lib\model\accounting
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| AccoutingTreeModel.dart | Classes: AccoutingTreeModel<br/>Key Funcs: branch_originalId, father_no, branch_no, name, id | Data structure / Model definition |
| VoucherModel.dart | Classes: VoucherModel<br/>Key Funcs: id, discription, jornal, currency, payment | Data structure / Model definition |


---

## lib\model\accounting\invoices
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| InvoicesDetailModel.dart | Classes: InvoicesDetailModel<br/>Key Funcs: id, invoices_id, item_no, item_name, unit_name | Data structure / Model definition |
| InvoicesModel.dart | Classes: InvoicesModel<br/>Key Funcs: type, discription, jornal, remaining, accountingTo_no | Data structure / Model definition |


---

## lib\model\accounting\journals
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| IndexModel.dart | Classes: IndexModel<br/>Key Funcs: ini_balance, last_tran_date, buying_currency, buying_price, selling_currency | Data structure / Model definition |
| JournalsDetailModel.dart | Classes: JournalsDetailModel<br/>Key Funcs: acc_amount, rate, currency, description, credit | Data structure / Model definition |
| journalsModel.dart | Classes: JournalsModel<br/>Key Funcs: id, date, discription, rate, currency | Data structure / Model definition |


---

## lib\model\Employment
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| EmployeeModel.dart | Classes: EmployeeModel<br/>Key Funcs: id, name, mobile, jop | Data structure / Model definition |


---

## lib\model\patients
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| InvoiceModel.dart | Classes: InvoiceModel<br/> | Data structure / Model definition |
| PatientHealthDoctorModel.dart | Classes: PatienHealthtDoctorModel<br/>Key Funcs: id, patientId, doctorId, doctorName, date | Data structure / Model definition |
| PatientHealthModel.dart | Classes: PatienHealthtModel<br/>Key Funcs: id, contraception_Ex, contraception, lactating_Ex, lactating | Data structure / Model definition |
| PatientModel.dart | Classes: PatientModel<br/>Key Funcs: id, birthDay, status, worries, resone | Data structure / Model definition |
| TreatmentPlanModel.dart | Classes: TreatmentPlanModel<br/> | Data structure / Model definition |


---

## lib\pages\accounting\invoices
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| expenseInvoices.dart | Classes: ExpenseInvoices, ExpenseInvoicesState<br/>Key Funcs: dispose, initState, build, tabledata | UI / Navigation Page |
| expenseInvoicesReview.dart | Classes: ExpenseInvoicesReview, ExpenseInvoicesReviewState<br/>Key Funcs: initState, build, datatable | UI / Navigation Page |
| saleInvoicesReview.dart | Classes: SaleInvoicesReview, SaleInvoicesReviewState<br/>Key Funcs: initState, build, datatable | UI / Navigation Page |
| SalesInvoices.dart | Classes: SalesInvoices, SalesInvoicesState<br/>Key Funcs: dispose, initState, build, onConfirm, tabledata | UI / Navigation Page |
| SalesInvoicesOptions.dart | Classes: SalesInvoicesOptions<br/>Key Funcs: build | UI / Navigation Page |


---

## lib\pages\accounting\journals
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| journalsPage.dart | Classes: JournalsPage, JournalsPageState<br/>Key Funcs: initState, build, firstRow, secondRow, thirdRow | UI / Navigation Page |
| journalsReview.dart | Classes: JournalsReview, JournalsReviewState<br/>Key Funcs: initState, build, datatable | UI / Navigation Page |


---

## lib\pages\accounting\vouchers
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| receiptVoucher.dart | Classes: ReceiptVoucherPage, _ReceiptVoucherPageState<br/>Key Funcs: dispose, initState, build | UI / Navigation Page |
| receiptVouchersReview.dart | Classes: ReceiptVouchersReview, _ReceiptVouchersReviewState<br/>Key Funcs: initState, build | UI / Navigation Page |


---

## lib\pages\costumer
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| PageAddCostumers.dart | Classes: PageAddCostumers, _PageAddCostumersState, _PatienHealthtModel<br/>Key Funcs: initState, selecedDoctorList, inputDecoration, inputDecorationNoIcon, build | UI / Navigation Page |
| PageCostumers.dart | Classes: PageCostumers, _PageCostumersState<br/>Key Funcs: initState, build | UI / Navigation Page |
| PageEditCostumers.dart | Classes: PageEditCostumers, _PageEditCostumersState<br/>Key Funcs: initState, intValues, pickDate, pickDate, inputDecoration | UI / Navigation Page |


---

## lib\pages\employment
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| PageAddEmployee.dart | Classes: PageAddEmployee, _PageAddEmployeeState<br/>Key Funcs: build | UI / Navigation Page |
| PageEditEmployee.dart | Classes: PageEditEmployee, _PageEditEmployeeState<br/>Key Funcs: initState, build | UI / Navigation Page |
| PageEmployees.dart | Classes: PageEmployees, _PageEmployeesState<br/>Key Funcs: initState, build | UI / Navigation Page |


---

## lib\pages\settings
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| DbSettingsPage.dart | Classes: DbSettingsPage, _DbSettingsPageState<br/>Key Funcs: build | UI / Navigation Page |


---

## lib\reports
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| reportExpenseInvoicePDF.dart | Classes: reportExpenseInvoicePDF<br/>Key Funcs: remaningMony, payedMony, tableBorder, buildTableExportItems, paddedTextCell | Logic for reportExpenseInvoicePDF.dart |
| reportSalesInvoicePDF.dart | Classes: reportSalesInvoicePDF<br/>Key Funcs: remaningMony, payedMony, tableBorder, buildTableExportItems, paddedTextCell | Logic for reportSalesInvoicePDF.dart |


---

## lib\services
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| firebase_sync_service.dart | Classes: FirebaseSyncService<br/>Key Funcs: syncData, syncPatient, syncData, syncPatientHealth, syncData | Logic for firebase_sync_service.dart |
| notification_service.dart | Classes: NotificationService<br/>Key Funcs: startMonitoring, dispose | Logic for notification_service.dart |
| StorageService.dart | Classes: StorageService<br/>Key Funcs: saveConfig | Logic for StorageService.dart |


---

## lib\theme
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| app_theme.dart | Classes: AppTheme<br/> | Logic for app_theme.dart |


---

## lib\themes
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| custom_theme.dart | Classes: CustomTheme<br/> | Logic for custom_theme.dart |


---

## lib\View_model
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| ViewModelEditCostumers.dart | Classes: ViewModelEditCostumers<br/>Key Funcs: inputDecoration, inputDecorationNoIcon | Data structure / Model definition |
| ViewModelExpenseInvoices.dart | Classes: ViewModelExpenseInvoices<br/>Key Funcs: selecedId, selecedIndexId, checkValues2, checkValues, inputDecorationNoIcon | Data structure / Model definition |
| ViewModelGlobal.dart | Classes: ViewModelGlobal<br/> | Data structure / Model definition |
| ViewModelJournals.dart | Classes: ViewModelJournals<br/> | Data structure / Model definition |
| ViewModelJournalsDetailsReview.dart | Classes: ViewModelJournalsDetailsReview<br/>Key Funcs: selecedId, selecedIndexId, checkValues2, checkValues | Data structure / Model definition |
| ViewModelSalesInvoices.dart | Classes: ViewModelSalesInvoices<br/>Key Funcs: selecedId, selecedIndexId, checkValues2, checkValues, inputDecorationNoIcon | Data structure / Model definition |


---

## lib\widgets
| File Name | Descriptions / Classes / Key Functions | Purpose |
| :--- | :--- | :--- |
| animated_card.dart | Classes: AnimatedCard, _AnimatedCardState<br/>Key Funcs: initState, dispose, build | Reusable UI component |
| app_drawer.dart | Classes: AppDrawer<br/>Key Funcs: build | Reusable UI component |
| dental_chart.dart | Classes: DentalChartWidget, _DentalChartWidgetState, ToothPainter<br/>Key Funcs: initState, didUpdateWidget, dispose, build, paint | Reusable UI component |
| page_transition.dart | Classes: PageTransition<br/> | Reusable UI component |
| TimePickerWithBookedHours.dart | Classes: TimePickerWithBookedHours<br/>Key Funcs: build | Reusable UI component |


---

