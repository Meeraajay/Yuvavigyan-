import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../services/cloudinary_service.dart';

class ApplicationFormPage extends StatefulWidget {
  final String studentId;

  const ApplicationFormPage({
    super.key,
    required this.studentId,
  });

  @override
  State<ApplicationFormPage> createState() =>
      _ApplicationFormPageState();
}

class _ApplicationFormPageState
    extends State<ApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();

  final applicationNoController =
      TextEditingController();
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final ageController = TextEditingController();
  final permanentAddressController =
      TextEditingController();
  final permanentContactController =
      TextEditingController();
  final presentAddressController =
      TextEditingController();
  final presentContactController =
      TextEditingController();
  final qualificationController =
      TextEditingController();
  final pastEmploymentController =
      TextEditingController();
  final positionController =
      TextEditingController();
  final employmentContactController =
      TextEditingController();
  final declarationController =
      TextEditingController();

  late final SignatureController
      signatureController;

  bool isLoading = true;
  bool isSaving = false;
  bool existingApplication = false;

  String studentEmail = "";
  String batchId = "";
  String batchName = "";
  String tutorName = "";
  String tutorEmail = "";
  String existingSignatureUrl = "";

  String? maritalStatus;
  String? sex;

  @override
  void initState() {
    super.initState();

    signatureController =
        SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor:
          Colors.white,
    );

    _loadForm();
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

  Future<void> _loadForm() async {
    try {
      final studentDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.studentId)
              .get();

      if (!studentDoc.exists ||
          studentDoc.data() == null) {
        throw Exception(
          "Student record was not found.",
        );
      }

      final studentData =
          studentDoc.data()!;

      final currentTutor =
          FirebaseAuth.instance.currentUser;

      if (currentTutor == null) {
        throw Exception(
          "No tutor is currently logged in.",
        );
      }

      final tutorDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentTutor.uid)
              .get();

      final tutorData =
          tutorDoc.data() ?? {};

      final applicationDoc =
          await FirebaseFirestore.instance
              .collection(
                'student_applications',
              )
              .doc(widget.studentId)
              .get();

      final applicationData =
          applicationDoc.data();

      nameController.text =
          applicationData?['studentName']
                  ?.toString() ??
              studentData['name']
                  ?.toString() ??
              '';

      studentEmail =
          applicationData?['studentEmail']
                  ?.toString() ??
              studentData['email']
                  ?.toString() ??
              '';

      batchId =
          applicationData?['batchId']
                  ?.toString() ??
              studentData['batchId']
                  ?.toString() ??
              '';

      batchName =
          applicationData?['batchName']
                  ?.toString() ??
              studentData['batchName']
                  ?.toString() ??
              '';

      tutorName =
          tutorData['name']?.toString() ??
              'Tutor';

      tutorEmail =
          tutorData['email']?.toString() ??
              currentTutor.email ??
              '';

      if (applicationData != null) {
        existingApplication = true;

        applicationNoController.text =
            applicationData[
                        'applicationNo']
                    ?.toString() ??
                '';

        dobController.text =
            applicationData['dob']
                    ?.toString() ??
                '';

        ageController.text =
            applicationData['age']
                    ?.toString() ??
                '';

        permanentAddressController.text =
            applicationData[
                        'permanentAddress']
                    ?.toString() ??
                '';

        permanentContactController.text =
            applicationData[
                        'permanentContact']
                    ?.toString() ??
                '';

        presentAddressController.text =
            applicationData[
                        'presentAddress']
                    ?.toString() ??
                '';

        presentContactController.text =
            applicationData[
                        'presentContact']
                    ?.toString() ??
                '';

        qualificationController.text =
            applicationData[
                        'qualification']
                    ?.toString() ??
                '';

        maritalStatus =
            applicationData[
                    'maritalStatus']
                ?.toString();

        sex = applicationData['sex']
            ?.toString();

        pastEmploymentController.text =
            applicationData[
                        'pastEmployment']
                    ?.toString() ??
                '';

        positionController.text =
            applicationData[
                        'positionHeld']
                    ?.toString() ??
                '';

        employmentContactController.text =
            applicationData[
                        'employmentContact']
                    ?.toString() ??
                '';

        declarationController.text =
            applicationData[
                        'declaration']
                    ?.toString() ??
                '';

        existingSignatureUrl =
            applicationData[
                        'signatureUrl']
                    ?.toString() ??
                '';
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Could not load application form: $e",
          ),
        ),
      );
    }
  }

  Future<void> _selectDateOfBirth() async {
    final initial =
        dobController.text.isEmpty
            ? DateTime(1960)
            : DateTime(1960);

    final selectedDate =
        await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate == null) return;

    final now = DateTime.now();

    int age =
        now.year - selectedDate.year;

    if (now.month <
            selectedDate.month ||
        (now.month ==
                selectedDate.month &&
            now.day <
                selectedDate.day)) {
      age--;
    }

    setState(() {
      dobController.text =
          "${selectedDate.day.toString().padLeft(2, '0')}/"
          "${selectedDate.month.toString().padLeft(2, '0')}/"
          "${selectedDate.year}";

      ageController.text =
          age.toString();
    });
  }

  Future<void> _saveApplication() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (maritalStatus == null ||
        sex == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please complete all dropdown fields.",
          ),
        ),
      );
      return;
    }

    if (signatureController.isEmpty &&
        existingSignatureUrl.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Please provide the applicant's signature.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final currentTutor =
          FirebaseAuth.instance.currentUser;

      if (currentTutor == null) {
        throw Exception(
          "No tutor is currently logged in.",
        );
      }

      String signatureUrl =
          existingSignatureUrl;

      if (!signatureController.isEmpty) {
        final signatureBytes =
            await signatureController
                .toPngBytes();

        if (signatureBytes == null) {
          throw Exception(
            "Could not prepare the signature image.",
          );
        }

        final uploadedUrl =
            await CloudinaryService.uploadFile(
          fileBytes: signatureBytes,
          fileName:
              "${widget.studentId}_signature.png",
          resourceType: 'image',
        );

        if (uploadedUrl == null) {
          throw Exception(
            "Signature upload failed.",
          );
        }

        signatureUrl = uploadedUrl;
      }

      final applicationRef =
          FirebaseFirestore.instance
              .collection(
                'student_applications',
              )
              .doc(widget.studentId);

      final previous =
          await applicationRef.get();

      final data = <String, dynamic>{
        'studentId': widget.studentId,
        'studentName':
            nameController.text.trim(),
        'studentEmail': studentEmail,
        'batchId': batchId,
        'batchName': batchName,
        'applicationNo':
            applicationNoController.text
                .trim(),
        'dob':
            dobController.text.trim(),
        'age':
            ageController.text.trim(),
        'permanentAddress':
            permanentAddressController.text
                .trim(),
        'permanentContact':
            permanentContactController.text
                .trim(),
        'presentAddress':
            presentAddressController.text
                .trim(),
        'presentContact':
            presentContactController.text
                .trim(),
        'qualification':
            qualificationController.text
                .trim(),
        'maritalStatus':
            maritalStatus,
        'sex': sex,
        'pastEmployment':
            pastEmploymentController.text
                .trim(),
        'positionHeld':
            positionController.text
                .trim(),
        'employmentContact':
            employmentContactController.text
                .trim(),
        'declaration':
            declarationController.text
                .trim(),
        'signatureUrl':
            signatureUrl,
        'tutorId': currentTutor.uid,
        'tutorName': tutorName,
        'tutorEmail': tutorEmail,
        'status': 'completed',
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      if (!previous.exists) {
        data['createdAt'] =
            FieldValue.serverTimestamp();
      }

      await applicationRef.set(
        data,
        SetOptions(
          merge: true,
        ),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .update({
        'applicationCompleted': true,
        'applicationStatus':
            'completed',
        'applicationNo':
            applicationNoController.text
                .trim(),
      });

      if (!mounted) return;

      setState(() {
        existingApplication = true;
        existingSignatureUrl =
            signatureUrl;
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Application Form Saved Successfully",
          ),
          backgroundColor:
              Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Could not save application form: $e",
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 12,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 19,
          fontWeight:
              FontWeight.bold,
          color: Color(0xFF3F51B5),
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController
        controller,
    int maxLines = 1,
    TextInputType keyboardType =
        TextInputType.text,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType:
            keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor:
              const Color(
            0xFFF8FAFC,
          ),
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          suffixIcon:
              onTap != null
                  ? const Icon(
                      Icons
                          .calendar_today_outlined,
                    )
                  : null,
        ),
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return "Please enter $label";
          }

          return null;
        },
      ),
    );
  }

  Widget _signatureSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          "Applicant Signature",
        ),

        if (existingSignatureUrl
            .isNotEmpty) ...[
          const Text(
            "Saved signature",
            style: TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            constraints:
                const BoxConstraints(
              minHeight: 120,
              maxHeight: 180,
            ),
            padding:
                const EdgeInsets.all(8),
            decoration:
                BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color:
                    const Color(
                  0xFFE5E7EB,
                ),
              ),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Image.network(
              existingSignatureUrl,
              fit: BoxFit.contain,
              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return const Center(
                  child: Text(
                    "Saved signature could not be displayed.",
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Draw below only if you want to replace the saved signature.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
        ] else
          const Text(
            "Draw the applicant's signature below.",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          height: 210,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color:
                  const Color(
                0xFF3F51B5,
              ),
              width: 1.5,
            ),
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
            child: Signature(
              controller:
                  signatureController,
              backgroundColor:
                  Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Align(
          alignment:
              Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () {
              signatureController
                  .clear();
            },
            icon: const Icon(
              Icons.delete_outline,
            ),
            label:
                const Text(
              "Clear Drawing",
            ),
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
      backgroundColor:
          const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(
          existingApplication
              ? "Application Form"
              : "Complete Application",
        ),
        backgroundColor:
            Colors.white,
        foregroundColor:
            const Color(
          0xFF222222,
        ),
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                children: [
                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      18,
                    ),
                    decoration:
                        BoxDecoration(
                      gradient:
                          const LinearGradient(
                        colors: [
                          Color(
                            0xFF4859B9,
                          ),
                          Color(
                            0xFF7A89D7,
                          ),
                        ],
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        18,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        const Text(
                          "ST. TERESA'S COLLEGE, ERNAKULAM",
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Towards an Age Friendly College",
                          style:
                              TextStyle(
                            color:
                                Colors.white70,
                          ),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Text(
                          nameController
                                  .text
                                  .isEmpty
                              ? "Student Application"
                              : nameController
                                  .text,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        if (batchName
                            .isNotEmpty) ...[
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Batch: $batchName",
                            style:
                                const TextStyle(
                              color:
                                  Colors.white70,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  _sectionTitle(
                    "Application Details",
                  ),

                  _textField(
                    label:
                        "Application No.",
                    controller:
                        applicationNoController,
                  ),

                  _sectionTitle(
                    "Personal Details",
                  ),

                  _textField(
                    label: "Name",
                    controller:
                        nameController,
                  ),

                  if (studentEmail
                      .isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 16,
                      ),
                      child:
                          TextFormField(
                        initialValue:
                            studentEmail,
                        readOnly: true,
                        decoration:
                            InputDecoration(
                          labelText:
                              "Email",
                          filled: true,
                          fillColor:
                              const Color(
                            0xFFF3F4F6,
                          ),
                          border:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              12,
                            ),
                          ),
                        ),
                      ),
                    ),

                  _textField(
                    label:
                        "Date of Birth",
                    controller:
                        dobController,
                    readOnly: true,
                    onTap:
                        _selectDateOfBirth,
                  ),

                  _textField(
                    label: "Age",
                    controller:
                        ageController,
                    keyboardType:
                        TextInputType
                            .number,
                    readOnly: true,
                  ),

                  _textField(
                    label:
                        "Permanent Address",
                    controller:
                        permanentAddressController,
                    maxLines: 3,
                  ),

                  _textField(
                    label:
                        "Permanent Contact Number",
                    controller:
                        permanentContactController,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  _textField(
                    label:
                        "Present Address",
                    controller:
                        presentAddressController,
                    maxLines: 3,
                  ),

                  _textField(
                    label:
                        "Present Contact Number",
                    controller:
                        presentContactController,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  _sectionTitle(
                    "Educational & Employment Details",
                  ),

                  _textField(
                    label:
                        "Educational Qualifications",
                    controller:
                        qualificationController,
                  ),

                  DropdownButtonFormField<
                      String>(
                    initialValue:
                        maritalStatus,
                    decoration:
                        InputDecoration(
                      labelText:
                          "Marital Status",
                      filled: true,
                      fillColor:
                          const Color(
                        0xFFF8FAFC,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value:
                            "Married",
                        child:
                            Text(
                          "Married",
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            "Unmarried",
                        child:
                            Text(
                          "Unmarried",
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            "Widowed",
                        child:
                            Text(
                          "Widowed",
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            "Divorced",
                        child:
                            Text(
                          "Divorced",
                        ),
                      ),
                      DropdownMenuItem(
                        value:
                            "Other",
                        child:
                            Text(
                          "Other",
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        maritalStatus =
                            value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return "Please select marital status";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  DropdownButtonFormField<
                      String>(
                    initialValue: sex,
                    decoration:
                        InputDecoration(
                      labelText: "Sex",
                      filled: true,
                      fillColor:
                          const Color(
                        0xFFF8FAFC,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "Female",
                        child:
                            Text(
                          "Female",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Male",
                        child:
                            Text(
                          "Male",
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Other",
                        child:
                            Text(
                          "Other",
                        ),
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

                  const SizedBox(
                    height: 16,
                  ),

                  _textField(
                    label:
                        "Past Employment",
                    controller:
                        pastEmploymentController,
                  ),

                  _textField(
                    label:
                        "Position Held",
                    controller:
                        positionController,
                  ),

                  _textField(
                    label:
                        "Employment Contact Number",
                    controller:
                        employmentContactController,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  _sectionTitle(
                    "Declaration",
                  ),

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

                  const SizedBox(
                    height: 16,
                  ),

                  _textField(
                    label:
                        "Applicant Declaration / Name",
                    controller:
                        declarationController,
                  ),

                  TextFormField(
                    initialValue: today,
                    readOnly: true,
                    decoration:
                        InputDecoration(
                      labelText: "Date",
                      filled: true,
                      fillColor:
                          const Color(
                        0xFFF8FAFC,
                      ),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          12,
                        ),
                      ),
                    ),
                  ),

                  _signatureSection(),

                  const SizedBox(
                    height: 25,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,
                    child:
                        ElevatedButton.icon(
                      onPressed: isSaving
                          ? null
                          : _saveApplication,
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Icon(
                              Icons.save,
                            ),
                      label: Text(
                        isSaving
                            ? "Saving..."
                            : "Save Application Form",
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF3F51B5,
                        ),
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
    );
  }
}
