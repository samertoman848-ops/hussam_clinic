import 'package:flutter/material.dart';

class DentalChartWidget extends StatefulWidget {
  final String initialTreatmentText;
  final ValueChanged<String> onChanged;
  final List<String> doctors;
  final String? initialDoctor;

  const DentalChartWidget({
    super.key,
    this.initialTreatmentText = "",
    required this.onChanged,
    this.doctors = const ["حسام العايدي"],
    this.initialDoctor,
    this.onSaveTreatment,
  });

  final Function(String tooth, String treatment, String doctor)?
      onSaveTreatment;

  @override
  State<DentalChartWidget> createState() => _DentalChartWidgetState();
}

class _DentalChartWidgetState extends State<DentalChartWidget> {
  Map<String, String> toothTreatments = {};
  // Track completion status for each tooth
  Map<String, bool> treatmentCompleted = {};
  // Track doctor name for each tooth
  Map<String, String> treatmentDoctor = {};
  Set<String> currentSelection = {};
  TextEditingController treatmentController = TextEditingController();
  String? hoveredTooth; // Track which tooth is being hovered
  late String selectedDoctor;

  @override
  void initState() {
    super.initState();
    _parseInitialText();
    selectedDoctor = widget.initialDoctor ??
        (widget.doctors.isNotEmpty ? widget.doctors[0] : "حسام العايدي");
  }

  @override
  void didUpdateWidget(DentalChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTreatmentText != widget.initialTreatmentText) {
      _parseInitialText();
      setState(() {});
    }
  }

  final Color primaryColor = const Color(0xFF0D7A77);
  final Color secondaryColor = const Color(0xFF14A098);

  // Common dental treatments list
  final List<String> commonTreatments = [
    "فحص دوري (Checkup)",
    "تشخيص شامل (Diagnosis)",
    "تنظيف أسنان (Scaling)",
    "تلميع أسنان (Polishing)",
    "حشوة كمبوزيت (Composite Filling)",
    "حشوة أملغم (Amalgam Filling)",
    "حشوة مؤقتة (Temporary Filling)",
    "علاج عصب - جلسة واحدة (Root Canal - Single)",
    "علاج عصب - جلسات متعددة (Root Canal - Multi)",
    "إعادة علاج عصب (Re-Root Canal)",
    "خلع بسيط (Simple Extraction)",
    "خلع جراحي (Surgical Extraction)",
    "خلع ضرس العقل (Wisdom Tooth Extraction)",
    "قص اللثة (Gingivectomy)",
    "تلبيسة زيركون (Zirconia Crown)",
    "تلبيسة بورسلين (Porcelain Crown)",
    "جسر أسنان (Dental Bridge)",
    "فينيير (Veneers)",
    "زراعة سن (Dental Implant)",
    "تطعيم عظمي (Bone Graft)",
    "تبييض أسنان (Teeth Whitening)",
    "واقي ليلي (Night Guard)",
    "تقويم أسنان (Orthodontics)",
    "حافظ مسافة (Space Maintainer)",
    "صورة أشعة صغيرة (Periapical X-Ray)",
    "صورة بانوراما (Panorama X-Ray)",
    "طقم أسنان كامل (Full Denture)",
    "طقم أسنان جزئي (Partial Denture)",
  ];
  String? selectedTreatment;

  @override
  void dispose() {
    treatmentController.dispose();
    super.dispose();
  }

  void _parseInitialText() {
    try {
      String text = widget.initialTreatmentText;
      toothTreatments.clear();

      RegExp planExp = RegExp(r'\[الخطة العلاجية: (.*?)\]');
      var match = planExp.firstMatch(text);

      if (match != null) {
        String content = match.group(1) ?? "";
        if (content.isNotEmpty) {
          // Both comma types for flexibility
          List<String> parts = content.contains('، ')
              ? content.split('، ')
              : content.split(', ');
          for (var part in parts) {
            // New format: tooth|treatment|completed|doctor
            // Old format: tooth:treatment
            if (part.contains('|')) {
              List<String> sub = part.split('|');
              if (sub.length >= 2) {
                String key = sub[0].trim();
                String treatment = sub[1].trim();
                toothTreatments[key] = treatment;
                if (sub.length >= 3) {
                  treatmentCompleted[key] =
                      sub[2].trim().toLowerCase() == 'true';
                }
                if (sub.length >= 4) treatmentDoctor[key] = sub[3].trim();

                // If key is ALL_TEETH (special marker for all teeth), expand it
                if (key == "ALL_TEETH") {
                  final List<String> allTeethNumbers = [
                    "18",
                    "17",
                    "16",
                    "15",
                    "14",
                    "13",
                    "12",
                    "11",
                    "21",
                    "22",
                    "23",
                    "24",
                    "25",
                    "26",
                    "27",
                    "28",
                    "48",
                    "47",
                    "46",
                    "45",
                    "44",
                    "43",
                    "42",
                    "41",
                    "31",
                    "32",
                    "33",
                    "34",
                    "35",
                    "36",
                    "37",
                    "38"
                  ];
                  for (var tooth in allTeethNumbers) {
                    toothTreatments[tooth] = treatment;
                    if (sub.length >= 3) {
                      treatmentCompleted[tooth] =
                          sub[2].trim().toLowerCase() == 'true';
                    }
                    if (sub.length >= 4) treatmentDoctor[tooth] = sub[3].trim();
                  }
                  toothTreatments.remove("ALL_TEETH"); // Remove the placeholder
                }
              }
            } else if (part.contains(':')) {
              int colonIndex = part.indexOf(':');
              String key = part.substring(0, colonIndex).trim();
              String val = part.substring(colonIndex + 1).trim();
              toothTreatments[key] = val;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error parsing dental chart text: $e");
    }
  }

  void _generateOutput() {
    if (toothTreatments.isEmpty) {
      Future.microtask(() {
        if (mounted) widget.onChanged("");
      });
      return;
    }

    final List<String> allTeethNumbers = [
      "18",
      "17",
      "16",
      "15",
      "14",
      "13",
      "12",
      "11",
      "21",
      "22",
      "23",
      "24",
      "25",
      "26",
      "27",
      "28",
      "48",
      "47",
      "46",
      "45",
      "44",
      "43",
      "42",
      "41",
      "31",
      "32",
      "33",
      "34",
      "35",
      "36",
      "37",
      "38"
    ];

    // Group treatments by type
    Map<String, List<String>> treatmentGroups = {};
    toothTreatments.forEach((tooth, treatment) {
      if (!treatmentGroups.containsKey(treatment)) {
        treatmentGroups[treatment] = [];
      }
      treatmentGroups[treatment]!.add(tooth);
    });

    List<String> parts = [];
    treatmentGroups.forEach((treatment, teeth) {
      // Sort teeth
      teeth.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

      // Check if all teeth have this treatment
      bool isAllTeeth = teeth.length == allTeethNumbers.length &&
          teeth.every((t) => allTeethNumbers.contains(t));

      if (isAllTeeth) {
        // Use special marker for all teeth
        bool completed = treatmentCompleted[teeth.first] ?? false;
        String doctor = treatmentDoctor[teeth.first] ?? "حسام العايدي";
        parts.add("ALL_TEETH|$treatment|$completed|$doctor");
      } else {
        // Add individual teeth
        for (var tooth in teeth) {
          bool completed = treatmentCompleted[tooth] ?? false;
          String doctor = treatmentDoctor[tooth] ?? "حسام العايدي";
          parts.add("$tooth|$treatment|$completed|$doctor");
        }
      }
    });

    String planBlock = "[الخطة العلاجية: ${parts.join(', ')}]";

    Future.microtask(() {
      if (mounted) widget.onChanged(planBlock);
    });
  }

  void _toggleTooth(String toothNumber) {
    setState(() {
      if (currentSelection.contains(toothNumber)) {
        currentSelection.remove(toothNumber);
      } else {
        currentSelection.add(toothNumber);
      }
    });
  }

  void _selectAll(List<int> teeth) {
    setState(() {
      bool allSelected =
          teeth.every((t) => currentSelection.contains(t.toString()));
      if (allSelected) {
        // Deselect these
        for (var t in teeth) {
          currentSelection.remove(t.toString());
        }
      } else {
        // Select these
        for (var t in teeth) {
          currentSelection.add(t.toString());
        }
      }
    });
  }

  void _applyTreatment() {
    String treatment = selectedTreatment ?? treatmentController.text;

    if (treatment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار أو كتابة العلاج المطلوب")),
      );
      return;
    }

    // Special logic for "Cleaning" - it applies to all teeth
    if (treatment.contains("تنظيف") || treatment.contains("Scaling")) {
      List<int> allTeeth = [
        18,
        17,
        16,
        15,
        14,
        13,
        12,
        11,
        21,
        22,
        23,
        24,
        25,
        26,
        27,
        28,
        48,
        47,
        46,
        45,
        44,
        43,
        42,
        41,
        31,
        32,
        33,
        34,
        35,
        36,
        37,
        38
      ];
      setState(() {
        // Auto-select all teeth for cleaning
        for (var t in allTeeth) {
          currentSelection.add(t.toString());
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديد كامل الأسنان للتنظيف")),
      );
    }

    _addTreatment(treatment);
  }

  void _addTreatment(String treatment) {
    if (currentSelection.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى تحديد سن أو أكثر أولاً")));
      return;
    }

    if (widget.onSaveTreatment != null) {
      for (var tooth in currentSelection) {
        widget.onSaveTreatment!(tooth, treatment, selectedDoctor);
      }
      setState(() {
        currentSelection.clear();
        treatmentController.clear();
        selectedTreatment = null;
      });
    } else {
      setState(() {
        for (var tooth in currentSelection) {
          toothTreatments[tooth] = treatment;
          treatmentCompleted[tooth] = false; // Initially not completed
          treatmentDoctor[tooth] = selectedDoctor;
        }
        currentSelection.clear();
        treatmentController.clear();
        selectedTreatment = null; // Reset selection
      });
      _generateOutput();
    }
  }

  void _deleteTreatment(String toothNumber) {
    setState(() {
      toothTreatments.remove(toothNumber);
      treatmentCompleted.remove(toothNumber);
      treatmentDoctor.remove(toothNumber);
    });
    _generateOutput();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoCard(),
        const SizedBox(height: 15),

        // --- Visual Chart ---
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 1,
              )
            ],
          ),
          child: Column(
            children: [
              // Global Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      List<int> allTeeth = [
                        18,
                        17,
                        16,
                        15,
                        14,
                        13,
                        12,
                        11,
                        21,
                        22,
                        23,
                        24,
                        25,
                        26,
                        27,
                        28,
                        48,
                        47,
                        46,
                        45,
                        44,
                        43,
                        42,
                        41,
                        31,
                        32,
                        33,
                        34,
                        35,
                        36,
                        37,
                        38
                      ];
                      _selectAll(allTeeth);
                    },
                    icon: const Icon(Icons.select_all_outlined, size: 20),
                    label: const Text("تحديد الكل / إلغاء"),
                  ),
                ],
              ),
              _buildJawSection("الفك العلوي", [
                18,
                17,
                16,
                15,
                14,
                13,
                12,
                11,
                21,
                22,
                23,
                24,
                25,
                26,
                27,
                28
              ]),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(thickness: 1, indent: 20, endIndent: 20),
              ),
              _buildJawSection("الفك السفلي", [
                48,
                47,
                46,
                45,
                44,
                43,
                42,
                41,
                31,
                32,
                33,
                34,
                35,
                36,
                37,
                38
              ]),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- Input Section ---
        _buildInputSection(),

        const SizedBox(height: 20),

        // --- Summary List ---
        // --- Summary List Removed (Replaced by DB List) ---
      ],
    );
  }

  Widget _buildJawSection(String title, List<int> teeth) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
            TextButton.icon(
              onPressed: () => _selectAll(teeth),
              icon: const Icon(Icons.select_all, size: 20),
              label: const Text("تحديد الكل"),
            )
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 12,
          children: [
            // Split teeth list into Right and Left for display gap
            ...teeth.take(8).map((t) => _buildToothItem(t)),
            const SizedBox(width: 20), // Midline gap
            ...teeth.skip(8).map((t) => _buildToothItem(t)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1), // Light teal
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "قم بتحديد الأسنان، ثم اختر العلاج. الأشكال توضح: قواطع، أنياب، ضواحك، أضراس.",
              style: TextStyle(
                  color: primaryColor.withOpacity(0.9),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToothItem(int toothNumber) {
    String tNumStr = toothNumber.toString();
    bool isSelected = currentSelection.contains(tNumStr);
    bool hasTreatment = toothTreatments.containsKey(tNumStr);
    bool isCompleted = treatmentCompleted[tNumStr] ?? false;
    ToothType type = _getToothType(toothNumber);

    String tooltipMsg = "السن $tNumStr";
    if (hasTreatment) {
      tooltipMsg += "\n${toothTreatments[tNumStr]}";
      if (isCompleted) tooltipMsg += " (مكتمل)";
      if (treatmentDoctor.containsKey(tNumStr)) {
        tooltipMsg += "\nالدكتور: ${treatmentDoctor[tNumStr]}";
      }
    } else {
      tooltipMsg += "\nاضغط للتحديد، زر يمين للقائمة";
    }

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredTooth = tNumStr),
      onExit: (_) => setState(() => hoveredTooth = null),
      child: GestureDetector(
        onTap: () => _toggleTooth(tNumStr),
        onSecondaryTapUp: (details) =>
            _showTreatmentMenu(context, details.globalPosition, tNumStr),
        onLongPressStart: (details) =>
            _showTreatmentMenu(context, details.globalPosition, tNumStr),
        child: Tooltip(
          message: tooltipMsg,
          padding: const EdgeInsets.all(8),
          textStyle: const TextStyle(fontSize: 14, color: Colors.white),
          decoration: BoxDecoration(
              color: Colors.black87, borderRadius: BorderRadius.circular(8)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withOpacity(0.15)
                  : (hasTreatment
                      ? (isCompleted
                          ? Colors.green.withOpacity(0.12)
                          : Colors.orange.withOpacity(0.12))
                      : Colors.grey.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: primaryColor, width: 2.5)
                  : (hasTreatment
                      ? Border.all(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.5)
                              : Colors.orange.withOpacity(0.5),
                          width: 1.5)
                      : Border.all(color: Colors.grey.shade300, width: 1)),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]
                  : [],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    CustomPaint(
                      size: const Size(42, 42),
                      painter: ToothPainter(
                        fillColor: isSelected
                            ? primaryColor
                            : (hasTreatment
                                ? (isCompleted ? Colors.green : Colors.orange)
                                : Colors.white),
                        strokeColor: hasTreatment
                            ? (isCompleted ? Colors.green : Colors.orangeAccent)
                            : Colors.black87,
                        type: type,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tNumStr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? primaryColor : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                if (hasTreatment)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: isCompleted,
                        activeColor: Colors.green,
                        checkColor: Colors.white,
                        shape: const CircleBorder(),
                        side: BorderSide(
                            color: Colors.green.shade700, width: 1.5),
                        onChanged: (val) {
                          setState(() {
                            treatmentCompleted[tNumStr] = val ?? false;
                          });
                          _generateOutput();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTreatmentMenu(
      BuildContext context, Offset globalPosition, String toothNumber) async {
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx + 1,
        globalPosition.dy + 1,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: Text("إجراء للسن $toothNumber",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const PopupMenuDivider(),
        ...commonTreatments.map((t) => PopupMenuItem(
              value: t,
              child: Text(t),
            )),
        if (toothTreatments.containsKey(toothNumber)) ...[
          const PopupMenuDivider(),
          PopupMenuItem(
            value: "DELETE",
            child: Row(
              children: const [
                Icon(Icons.delete_forever, color: Colors.red),
                SizedBox(width: 8),
                Text("حذف الإجراء الحالي", style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ],
    );

    if (selected != null) {
      if (selected == "DELETE") {
        _deleteTreatment(toothNumber);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تم حذف الإجراء للسن $toothNumber")),
        );
      } else {
        setState(() {
          toothTreatments[toothNumber] = selected;
          treatmentCompleted[toothNumber] = false; // Default to not completed
          treatmentDoctor[toothNumber] =
              selectedDoctor; // Use currently selected doctor
        });
        _generateOutput();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "تم إضافة $selected للسن $toothNumber بواسطة الدكتور $selectedDoctor"),
              duration: const Duration(seconds: 1)),
        );
      }
    }
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (currentSelection.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "الأسنان المحددة: ${currentSelection.join('، ')}",
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            // Treatment Dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedTreatment,
              decoration: InputDecoration(
                labelText: "اختر الإجراء العلاجي",
                prefixIcon: const Icon(Icons.list_alt),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: commonTreatments
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedTreatment = val;
                  treatmentController.text = val ?? ""; // Sync text controller
                });
              },
            ),
            const SizedBox(height: 10),
            // Manual Input (Optional)
            TextField(
              controller: treatmentController,
              decoration: InputDecoration(
                labelText: "أو اكتب وصفاً إضافياً",
                hintText: "ملاحظات إضافية...",
                prefixIcon: const Icon(Icons.edit_note),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _applyTreatment,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("إضافة إلى الخطة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryList() {
    // All teeth FDI numbers (32 teeth total)
    final List<String> allTeethNumbers = [
      "18",
      "17",
      "16",
      "15",
      "14",
      "13",
      "12",
      "11",
      "21",
      "22",
      "23",
      "24",
      "25",
      "26",
      "27",
      "28",
      "48",
      "47",
      "46",
      "45",
      "44",
      "43",
      "42",
      "41",
      "31",
      "32",
      "33",
      "34",
      "35",
      "36",
      "37",
      "38"
    ];

    // Group identical treatments by name
    Map<String, List<String>> groups = {};
    toothTreatments.forEach((tooth, treatment) {
      if (!groups.containsKey(treatment)) groups[treatment] = [];
      groups[treatment]!.add(tooth);
    });

    // Sort treatments for consistent display
    var sortedGroups = groups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      children: sortedGroups.map((entry) {
        String treatment = entry.key;
        List<String> teeth = entry.value;
        // Natural sort
        teeth.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

        // Check if all teeth are selected for this treatment
        bool isAllTeeth = teeth.length == allTeethNumbers.length &&
            teeth.every((t) => allTeethNumbers.contains(t));

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.medical_services_rounded,
                        color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        treatment,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                            fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded,
                          color: Colors.red),
                      onPressed: () {
                        setState(() {
                          for (var t in teeth) {
                            toothTreatments.remove(t);
                            treatmentCompleted.remove(t);
                            treatmentDoctor.remove(t);
                          }
                        });
                        _generateOutput();
                      },
                    ),
                  ],
                ),
              ),
              // If all teeth are selected, show a single "كل الأسنان" entry
              if (isAllTeeth)
                CheckboxListTile(
                  activeColor: Colors.green,
                  title: const Text("كل الأسنان",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF167774),
                          fontSize: 16)),
                  subtitle: Text(
                      "الدكتور: ${treatmentDoctor[teeth.first] ?? selectedDoctor}",
                      style: const TextStyle(fontSize: 12)),
                  value: treatmentCompleted[teeth.first] ?? false,
                  onChanged: (val) {
                    setState(() {
                      for (var t in teeth) {
                        treatmentCompleted[t] = val ?? false;
                      }
                    });
                    _generateOutput();
                  },
                  secondary: IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        for (var t in teeth) {
                          toothTreatments.remove(t);
                          treatmentCompleted.remove(t);
                          treatmentDoctor.remove(t);
                        }
                      });
                      _generateOutput();
                    },
                  ),
                )
              else
                // Otherwise, show individual teeth
                ...teeth.map((tooth) {
                  bool isCompleted = treatmentCompleted[tooth] ?? false;
                  return CheckboxListTile(
                    activeColor: Colors.green,
                    title: Text("السن $tooth",
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        "الدكتور: ${treatmentDoctor[tooth] ?? selectedDoctor}",
                        style: const TextStyle(fontSize: 12)),
                    value: isCompleted,
                    onChanged: (val) {
                      setState(() {
                        treatmentCompleted[tooth] = val ?? false;
                      });
                      _generateOutput();
                    },
                    secondary: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => _deleteTreatment(tooth),
                    ),
                  );
                }),
            ],
          ),
        );
      }).toList(),
    );
  }

  ToothType _getToothType(int number) {
    int n = number % 10; // Last digit tells us the position from midline
    if (n == 1 || n == 2) return ToothType.incisor;
    if (n == 3) return ToothType.canine;
    if (n == 4 || n == 5) return ToothType.premolar;
    return ToothType.molar;
  }
}

enum ToothType { incisor, canine, premolar, molar }

class ToothPainter extends CustomPainter {
  final Color fillColor;
  final Color strokeColor;
  final ToothType type;

  ToothPainter(
      {required this.fillColor, required this.strokeColor, required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Main tooth fill
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Stroke/outline
    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Shadow/gradient effect
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Draw the tooth based on type
    switch (type) {
      case ToothType.incisor:
        _drawIncisor(canvas, w, h, fillPaint, strokePaint, shadowPaint);
        break;
      case ToothType.canine:
        _drawCanine(canvas, w, h, fillPaint, strokePaint, shadowPaint);
        break;
      case ToothType.premolar:
        _drawPremolar(canvas, w, h, fillPaint, strokePaint, shadowPaint);
        break;
      case ToothType.molar:
        _drawMolar(canvas, w, h, fillPaint, strokePaint, shadowPaint);
        break;
    }
  }

  void _drawIncisor(Canvas canvas, double w, double h, Paint fillPaint,
      Paint strokePaint, Paint shadowPaint) {
    final Path path = Path();

    // Root (bottom part)
    path.moveTo(w * 0.5, h * 0.95);
    path.quadraticBezierTo(w * 0.35, h * 0.7, w * 0.3, h * 0.5);

    // Left side of crown
    path.quadraticBezierTo(w * 0.25, h * 0.4, w * 0.2, h * 0.25);
    path.quadraticBezierTo(w * 0.15, h * 0.15, w * 0.18, h * 0.1);

    // Top/biting edge
    path.quadraticBezierTo(w * 0.35, h * 0.05, w * 0.5, h * 0.05);
    path.quadraticBezierTo(w * 0.65, h * 0.05, w * 0.82, h * 0.1);

    // Right side of crown
    path.quadraticBezierTo(w * 0.85, h * 0.15, w * 0.8, h * 0.25);
    path.quadraticBezierTo(w * 0.75, h * 0.4, w * 0.7, h * 0.5);

    // Root (right side)
    path.quadraticBezierTo(w * 0.65, h * 0.7, w * 0.5, h * 0.95);
    path.close();

    // Draw shadow on left side
    final Path shadowPath = Path();
    shadowPath.moveTo(w * 0.2, h * 0.25);
    shadowPath.quadraticBezierTo(w * 0.25, h * 0.4, w * 0.3, h * 0.5);
    shadowPath.quadraticBezierTo(w * 0.35, h * 0.7, w * 0.45, h * 0.85);
    shadowPath.quadraticBezierTo(w * 0.35, h * 0.7, w * 0.3, h * 0.5);
    shadowPath.quadraticBezierTo(w * 0.25, h * 0.4, w * 0.2, h * 0.25);
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Add subtle surface detail line
    final Path detailLine = Path();
    detailLine.moveTo(w * 0.38, h * 0.08);
    detailLine.quadraticBezierTo(w * 0.4, h * 0.35, w * 0.42, h * 0.65);
    canvas.drawPath(
        detailLine,
        strokePaint
          ..strokeWidth = 0.6
          ..color = strokePaint.color.withOpacity(0.4));
  }

  void _drawCanine(Canvas canvas, double w, double h, Paint fillPaint,
      Paint strokePaint, Paint shadowPaint) {
    final Path path = Path();

    // Root
    path.moveTo(w * 0.5, h * 0.97);
    path.quadraticBezierTo(w * 0.35, h * 0.7, w * 0.28, h * 0.48);

    // Left bulge of crown
    path.quadraticBezierTo(w * 0.22, h * 0.35, w * 0.18, h * 0.22);
    path.quadraticBezierTo(w * 0.15, h * 0.12, w * 0.22, h * 0.06);

    // Sharp tip (point of canine)
    path.lineTo(w * 0.5, h * 0.02);

    // Right bulge of crown
    path.lineTo(w * 0.78, h * 0.06);
    path.quadraticBezierTo(w * 0.85, h * 0.12, w * 0.82, h * 0.22);
    path.quadraticBezierTo(w * 0.78, h * 0.35, w * 0.72, h * 0.48);

    // Root right side
    path.quadraticBezierTo(w * 0.65, h * 0.7, w * 0.5, h * 0.97);
    path.close();

    // Shadow effect
    final Path shadowPath = Path();
    shadowPath.moveTo(w * 0.18, h * 0.22);
    shadowPath.quadraticBezierTo(w * 0.22, h * 0.35, w * 0.28, h * 0.48);
    shadowPath.quadraticBezierTo(w * 0.35, h * 0.7, w * 0.42, h * 0.9);
    shadowPath.quadraticBezierTo(w * 0.35, h * 0.7, w * 0.28, h * 0.48);
    shadowPath.quadraticBezierTo(w * 0.22, h * 0.35, w * 0.18, h * 0.22);
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Central ridge detail
    final Path ridge = Path();
    ridge.moveTo(w * 0.5, h * 0.06);
    ridge.quadraticBezierTo(w * 0.48, h * 0.4, w * 0.47, h * 0.8);
    canvas.drawPath(
        ridge,
        strokePaint
          ..strokeWidth = 0.7
          ..color = strokePaint.color.withOpacity(0.35));
  }

  void _drawPremolar(Canvas canvas, double w, double h, Paint fillPaint,
      Paint strokePaint, Paint shadowPaint) {
    final Path path = Path();

    // Root
    path.moveTo(w * 0.5, h * 0.95);
    path.quadraticBezierTo(w * 0.32, h * 0.72, w * 0.25, h * 0.55);

    // Left crown curve
    path.quadraticBezierTo(w * 0.18, h * 0.4, w * 0.15, h * 0.25);
    path.quadraticBezierTo(w * 0.12, h * 0.12, w * 0.28, h * 0.08);

    // Left cusp peak
    path.quadraticBezierTo(w * 0.38, h * 0.04, w * 0.45, h * 0.08);

    // Center dip
    path.quadraticBezierTo(w * 0.5, h * 0.12, w * 0.55, h * 0.08);

    // Right cusp peak
    path.quadraticBezierTo(w * 0.62, h * 0.04, w * 0.72, h * 0.08);

    // Right crown curve
    path.quadraticBezierTo(w * 0.88, h * 0.12, w * 0.85, h * 0.25);
    path.quadraticBezierTo(w * 0.82, h * 0.4, w * 0.75, h * 0.55);

    // Root right
    path.quadraticBezierTo(w * 0.68, h * 0.72, w * 0.5, h * 0.95);
    path.close();

    // Shadow on left
    final Path shadowPath = Path();
    shadowPath.moveTo(w * 0.15, h * 0.25);
    shadowPath.quadraticBezierTo(w * 0.18, h * 0.4, w * 0.25, h * 0.55);
    shadowPath.quadraticBezierTo(w * 0.32, h * 0.72, w * 0.42, h * 0.88);
    shadowPath.quadraticBezierTo(w * 0.32, h * 0.72, w * 0.25, h * 0.55);
    shadowPath.quadraticBezierTo(w * 0.18, h * 0.4, w * 0.15, h * 0.25);
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Central groove
    final Path groove = Path();
    groove.moveTo(w * 0.5, h * 0.08);
    groove.lineTo(w * 0.5, h * 0.4);
    canvas.drawPath(
        groove,
        strokePaint
          ..strokeWidth = 0.65
          ..color = strokePaint.color.withOpacity(0.35));
  }

  void _drawMolar(Canvas canvas, double w, double h, Paint fillPaint,
      Paint strokePaint, Paint shadowPaint) {
    final Path path = Path();

    // Left root
    path.moveTo(w * 0.3, h * 0.95);
    path.quadraticBezierTo(w * 0.2, h * 0.72, w * 0.18, h * 0.55);

    // Left crown curve
    path.quadraticBezierTo(w * 0.12, h * 0.4, w * 0.1, h * 0.22);
    path.quadraticBezierTo(w * 0.08, h * 0.08, w * 0.25, h * 0.05);

    // Left-center cusp
    path.quadraticBezierTo(w * 0.35, h * 0.0, w * 0.4, h * 0.08);

    // Left-center dip
    path.quadraticBezierTo(w * 0.45, h * 0.12, w * 0.5, h * 0.06);

    // Center-right cusp
    path.quadraticBezierTo(w * 0.55, h * 0.0, w * 0.65, h * 0.08);

    // Center dip
    path.quadraticBezierTo(w * 0.7, h * 0.12, w * 0.75, h * 0.05);

    // Right crown curve
    path.quadraticBezierTo(w * 0.92, h * 0.08, w * 0.9, h * 0.22);
    path.quadraticBezierTo(w * 0.88, h * 0.4, w * 0.82, h * 0.55);

    // Right root
    path.quadraticBezierTo(w * 0.8, h * 0.72, w * 0.7, h * 0.95);

    // Root valley (characteristic of molars with 2 roots)
    path.quadraticBezierTo(w * 0.5, h * 0.75, w * 0.3, h * 0.95);
    path.close();

    // Shadow on left root
    final Path shadowPath = Path();
    shadowPath.moveTo(w * 0.1, h * 0.22);
    shadowPath.quadraticBezierTo(w * 0.12, h * 0.4, w * 0.18, h * 0.55);
    shadowPath.quadraticBezierTo(w * 0.2, h * 0.72, w * 0.28, h * 0.88);
    shadowPath.quadraticBezierTo(w * 0.2, h * 0.72, w * 0.18, h * 0.55);
    shadowPath.quadraticBezierTo(w * 0.12, h * 0.4, w * 0.1, h * 0.22);
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Central groove between roots
    final Path centralGroove = Path();
    centralGroove.moveTo(w * 0.5, h * 0.1);
    centralGroove.quadraticBezierTo(w * 0.5, h * 0.45, w * 0.5, h * 0.75);
    canvas.drawPath(
        centralGroove,
        strokePaint
          ..strokeWidth = 0.7
          ..color = strokePaint.color.withOpacity(0.35));

    // Occlusal (chewing) surface details
    final Path occlushalDetail = Path();
    occlushalDetail.moveTo(w * 0.35, h * 0.1);
    occlushalDetail.lineTo(w * 0.65, h * 0.1);
    canvas.drawPath(
        occlushalDetail,
        strokePaint
          ..strokeWidth = 0.5
          ..color = strokePaint.color.withOpacity(0.25));
  }

  @override
  bool shouldRepaint(covariant ToothPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.type != type;
  }
}
