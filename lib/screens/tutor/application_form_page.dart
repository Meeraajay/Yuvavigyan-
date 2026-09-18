import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class ApplicationFormPage extends StatefulWidget {
  const ApplicationFormPage({super.key});

  @override
  State<ApplicationFormPage> createState() => _ApplicationFormPageState();
}

class _ApplicationFormPageState extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  final applicationNoController = TextEditingController();
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final ageController = TextEditingController();
  final permanentAddressController = TextEditingController();
  final permanentContactController = TextEditingController();
  final presentAddressController = TextEditingController();
  final presentContactController = TextEditingController();
  final qualificationController = TextEditingController();
  final pastEmploymentController = TextEditingController();
  final positionController = TextEditingController();
  final employmentContactController = TextEditingController();
  final declarationController = TextEditingController();

  late SignatureController signatureController;

  String? maritalStatus;
  String? sex;

  @override
  void initState() {
    super.initState();

    signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    applicationNoController.dispose();
    nameController.dispose();
    dobController.dispose();
    ageController.dispose();
    permanentAddressController.dispose();
    permanentContactController.dispose();
    presentAddressController.dispose();
    presentContactController.dispose();
    qualificationController.dispose();
    pastEmploymentController.dispose();
    positionController.dispose();
    employmentContactController.dispose();
    declarationController.dispose();

    signatureController.dispose();

    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1960),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    setState(() {
      dobController.text =
          "${selectedDate.day.toString().padLeft(2, '0')}/"
          "${selectedDate.month.toString().padLeft(2, '0')}/"
          "${selectedDate.year}";

      int age = DateTime.now().year - selectedDate.year;

      if (DateTime.now().month < selectedDate.month ||
          (DateTime.now().month == selectedDate.month &&
              DateTime.now().day < selectedDate.day)) {
        age--;
      }

      ageController.text = age.toString();
    });
  }

  void _saveApplication() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide the applicant's signature."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Application Form Saved Successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: onTap != null
              ? const Icon(Icons.calendar_today_outlined)
              : null,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
      ),
    );
  }

  Widget _signatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Applicant Signature"),

        const Text(
          "Please draw the applicant's signature below.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.deepPurple,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Signature(
              controller: signatureController,
              backgroundColor: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                signatureController.clear();
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text("Clear Signature"),
            ),
          ],
        ),

        const Text(
          "Use your mouse or finger to draw the signature.",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final today =
        "${DateTime.now().day.toString().padLeft(2, '0')}/"
        "${DateTime.now().month.toString().padLeft(2, '0')}/"
        "${DateTime.now().year}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Application Form"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Text(
                      "ST. TERESA'S COLLEGE, ERNAKULAM",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "TOWARDS AN\nAGE FRIENDLY COLLEGE",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "APPLICATION FORM",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.deepPurple.shade50,
                      child: const Icon(
                        Icons.person,
                        size: 45,
                        color: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Applicant Photograph",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              _sectionTitle("Application Details"),

              _textField(
                label: "Application No.",
                controller: applicationNoController,
              ),

              _sectionTitle("Personal Details"),

              _textField(
                label: "Name",
                controller: nameController,
              ),

              _textField(
                label: "Date of Birth",
                controller: dobController,
                readOnly: true,
                onTap: _selectDateOfBirth,
              ),

              _textField(
                label: "Age",
                controller: ageController,
                keyboardType: TextInputType.number,
                readOnly: true,
              ),

              _textField(
                label: "Permanent Address",
                controller: permanentAddressController,
                maxLines: 3,
              ),

              _textField(
                label: "Contact Number",
                controller: permanentContactController,
                keyboardType: TextInputType.phone,
              ),

              _textField(
                label: "Present Address",
                controller: presentAddressController,
                maxLines: 3,
              ),

              _textField(
                label: "Contact Number",
                controller: presentContactController,
                keyboardType: TextInputType.phone,
              ),

              _sectionTitle("Educational & Employment Details"),

              _textField(
                label: "Educational Qualifications",
                controller: qualificationController,
              ),

              DropdownButtonFormField<String>(
                initialValue: maritalStatus,
                decoration: InputDecoration(
                  labelText: "Marital Status",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Married",
                    child: Text("Married"),
                  ),
                  DropdownMenuItem(
                    value: "Unmarried",
                    child: Text("Unmarried"),
                  ),
                  DropdownMenuItem(
                    value: "Widowed",
                    child: Text("Widowed"),
                  ),
                  DropdownMenuItem(
                    value: "Divorced",
                    child: Text("Divorced"),
                  ),
                  DropdownMenuItem(
                    value: "Other",
                    child: Text("Other"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    maritalStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select marital status";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: sex,
                decoration: InputDecoration(
                  labelText: "Sex",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Female",
                    child: Text("Female"),
                  ),
                  DropdownMenuItem(
                    value: "Male",
                    child: Text("Male"),
                  ),
                  DropdownMenuItem(
                    value: "Other",
                    child: Text("Other"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    sex = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Please select sex";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              _textField(
                label: "Past Employment",
                controller: pastEmploymentController,
              ),

              _textField(
                label: "Position Held",
                controller: positionController,
              ),

              _textField(
                label: "Contact Number",
                controller: employmentContactController,
                keyboardType: TextInputType.phone,
              ),

              _sectionTitle("Declaration"),

              const Text(
                "I hereby undertake, on being admitted to the College, "
                "to abide by the rules and regulations of the College "
                "and promise to do nothing either inside or outside "
                "the College that will interfere with its orderly "
                "working and discipline.",
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 16),

              _textField(
                label: "Applicant Declaration / Name",
                controller: declarationController,
              ),

              const SizedBox(height: 10),

              TextFormField(
                initialValue: today,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Date",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              _signatureSection(),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveApplication,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Save Application Form",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}